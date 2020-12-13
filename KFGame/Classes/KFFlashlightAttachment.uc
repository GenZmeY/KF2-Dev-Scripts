//=============================================================================
// KFFlashlightAttachment
//=============================================================================
// Attach and manage flash light components (light, cone, etc..) to a
// weapon in 1st or 3rd person
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
// - Andrew "Strago" Ladenberger
//=============================================================================

class KFFlashlightAttachment extends Object
	hidecategories(Object)
	config(Game)
	native(Effect);

var config bool bSkipBestFlashlightCheck;

/** Cached parent (attachment) mesh */
var protected transient SkeletalMeshComponent OwnerMesh;

/** Is this flashlight turned on? */
var protected transient bool bEnabled;

/** Initialized the first time the light is turned on */
var protected transient bool bLightInitialized;

/*********************************************************************************************
 * @name	Attachments
 ********************************************************************************************* */

/** Spot Light */
var()			SpotLightComponent LightTemplate;
var() transient	SpotLightComponent Light;

/** Light Cone Mesh*/
var()		  StaticMesh			LightConeMesh;
var 	  	  StaticMeshComponent	LightConeMeshComp;

/** Mesh attachment (always visible) */
var()		  StaticMesh			AttachmentMesh;
var transient StaticMeshComponent	AttachmentMeshComp;

/** Socket name to attach the flashlight to */
var() name FlashlightSocketName;

/** Within this radius don't turn off a teammate's flashlight unless ours is turned on */
var float TeammateSwitchRadius;
var float TeammateSwitchTimer;

/** Debug logging */
var bool bDebug;

/** Maximum distance to warn AI */
var protected const float MaxAIWarningDistSQ;

/** Maximum distance from center of line to warn AI */
var protected const float MaxAIWarningDistFromPointSQ;

/** Create/Attach flashlight components */
function AttachFlashlight(SkeletalMeshComponent Mesh, optional name SocketNameOverride)
{
	if ( OwnerMesh != None && OwnerMesh != Mesh )
	{
		return; // unsupported attachment
	}
	OwnerMesh = Mesh;

	// Allow code to override attachment socket
	if ( SocketNameOverride != '' )
	{
		FlashlightSocketName = SocketNameOverride;
	}

	// The AttachmentMesh must be attached right away.  However, the lights are only created
	// if/when the flashlight is turned on for the first time
	if ( AttachmentMesh != None )
	{
		if ( AttachmentMeshComp == None )
		{
			AttachmentMeshComp = new(self) class'StaticMeshComponent';
			AttachmentMeshComp.CastShadow = FALSE;
			AttachmentMeshComp.SetStaticMesh(AttachmentMesh);
		}
		else
		{
			// Cleanup previous attachment.  For example, during customization mesh swap the
			// link to parent is lost, but the child link is retained for some reason.
			Mesh.DetachComponent(AttachmentMeshComp);
		}
		AttachFlashlightComponent(Mesh, AttachmentMeshComp);

		if ( IsOwnerFirstPerson() )
		{
			SetFirstPersonVisibility(true);
		}
	}

	SetLightingChannels(Mesh.LightingChannels);
}

/** Need to reattach when owner mesh changes (e.g. Customization) */
function Reattach()
{
	if ( AttachmentMeshComp != None && !AttachmentMeshComp.bAttached )
	{
		// Cleanup previous attachment.  For example, during customization mesh swap the
		// link to parent is lost, but the child link is retained for some reason.
		OwnerMesh.DetachComponent(AttachmentMeshComp);

		AttachFlashlightComponent(OwnerMesh, AttachmentMeshComp);
	}
}

/** Remove/Detach flashlight components */
function DetachFlashlight()
{
	if ( Light != none )
	{
		Light.DetachFromAny();
	}

	if ( LightConeMeshComp != none )
	{
		LightConeMeshComp.DetachFromAny();
	}

	if ( AttachmentMeshComp != None )
	{
		AttachmentMeshComp.DetachFromAny();
	}
}

/** Toggle flash light components */
protected function SetEnabled(bool bNewEnabled)
{
	if ( bNewEnabled && !bLightInitialized )
	{
		InitializeLight();
	}

	if ( Light != None )
	{
		Light.SetEnabled(bNewEnabled);
	}

	if ( LightConeMeshComp != None )
	{
		LightConeMeshComp.SetHidden(!bNewEnabled || IsOwnerFirstPerson());
	}

	bEnabled = bNewEnabled;

	if( OwnerMesh.Outer != none && class'WorldInfo'.static.GetWorldInfo().NetMode != NM_Client )
	{
		if( bEnabled )
		{
			Timer_WarnAI();
			Actor(OwnerMesh.Outer).SetTimer( 1.f, true, nameOf(Timer_WarnAI), self );
		}
		else
		{
			Actor(OwnerMesh.Outer).ClearTimer( nameOf(Timer_WarnAI), self );
		}
	}

	`log("Turning flashlight"@bNewEnabled@"for teammate:"@OwnerMesh.Outer, bDebug);
}

/** Warns AI when flaslight is on */
function Timer_WarnAI()
{
    local Pawn Instigator, P;
    local KFWeapon OwnerWeapon;
    local KFPawn_Monster HitMonster;
    local vector Direction, Projection, DangerPoint;

    // Get owner pawn
    Instigator = Pawn( OwnerMesh.Outer );
    if( Instigator == none )
    {
    	return;
    }

    // Get owner weapon. Don't process AI warnings if weapon is already doing so.
    OwnerWeapon = KFWeapon( Instigator.Weapon );
    if( OwnerWeapon != none && OwnerWeapon.IsWarningAI() )
    {
    	return;
    }

    Direction = vector( Instigator.GetBaseAimRotation() );

    // Iterate through pawns and find AI we want to warn
    foreach Instigator.WorldInfo.AllPawns( class'Pawn', P )
    {
        if( P.GetTeamNum() != Instigator.GetTeamNum() && !P.IsHumanControlled() && P.IsAliveAndWell() )
        {
            // Determine if AI is within range as well as within our field of view
            Projection = P.Location - Instigator.Location;
            if( VSizeSQ(Projection) < MaxAIWarningDistSQ )
            {
                PointDistToLine( P.Location, Direction, Instigator.Location, DangerPoint );

                if( VSizeSQ(DangerPoint - P.Location) < MaxAIWarningDistFromPointSQ )
                {
                    // Tell the AI to evade away from the DangerPoint
                    HitMonster = KFPawn_Monster( P );
                    if( HitMonster != none && HitMonster.MyKFAIC != none )
                    {
                        HitMonster.MyKFAIC.ReceiveLocationalWarning( DangerPoint, Instigator.Location, self );
                    }
                }
            }
        }
    }
}

/** Called once the first time the light is activated.  Seperated from AttachFlashlight and the AttachmentMesh */
protected function InitializeLight()
{
	if ( OwnerMesh == None )
	{
		`log("Invalid mesh for flashlight"@self);
		return;
	}

	if ( Light == None && LightTemplate != None )
	{
		Light = new(self) Class'SpotLightComponent' (LightTemplate);
		AttachFlashlightComponent(OwnerMesh, Light);
	}

	if ( LightConeMesh != None )
	{
		LightConeMeshComp.SetStaticMesh(LightConeMesh);
		AttachFlashlightComponent(OwnerMesh, LightConeMeshComp);
	}

	bLightInitialized = true;

	if ( IsOwnerFirstPerson() )
	{
		SetFirstPersonVisibility(true);
	}
}

/** attachment helper */
private function AttachFlashlightComponent(SkeletalMeshComponent ParentMesh, ActorComponent Attachment)
{
	ParentMesh.AttachComponentToSocket(Attachment, FlashlightSocketName);
}

/** Cleanup */
simulated function OwnerDied()
{
	if ( bEnabled )
	{
		SetEnabled(false);
	}

	// make sure SpotLightComponent is removed (in case of 1st person camera attachment)
	if ( Light != None )
	{
		Light.DetachFromAny();
	}
}

/** Set the lighting channels on all the appropriate pawn meshes */
simulated function SetLightingChannels(const out LightingChannelContainer NewLightingChannels)
{
	if ( AttachmentMeshComp != None )
	{
		AttachmentMeshComp.SetLightingChannels(NewLightingChannels);
	}
}

/*********************************************************************************************
 * @name	1st person attachment
 ********************************************************************************************* */

/** attachment helper */
private function bool IsOwnerFirstPerson()
{
	local Pawn P;
	P = Pawn(OwnerMesh.Outer);
	return (P != None) ? P.IsFirstPerson() : false;
}

/** Special handling for components attached to character mesh while in 1st person */
simulated function SetFirstPersonVisibility(bool bFirstPerson)
{
	local KFPawn P;

	if ( bLightInitialized )
	{
		P = KFPawn(OwnerMesh.Outer);
		if ( Light != None && P != None )
		{
			if ( bFirstPerson )
			{
				if( P.Controller != none && PlayerController(P.Controller) != none && PlayerController(P.Controller).PlayerCamera != none )
				{
					PlayerController(P.Controller).PlayerCamera.AttachComponent(Light);
				}

				//Light.SetTranslation(vect(0, -100, -50));
			}
			else
			{
				AttachFlashlightComponent(P.Mesh, Light);
				//Light.SetTranslation(vect(0, 0, 0));
			}
		}

		if ( LightConeMeshComp != None )
		{
			LightConeMeshComp.SetHidden(!bEnabled || bFirstPerson);
		}
	}

	if ( AttachmentMeshComp != None )
	{
		AttachmentMeshComp.SetHidden(bFirstPerson);
	}
}

/*********************************************************************************************
 * @name	Limit 1 flashlight per client
 ********************************************************************************************* */

simulated function UpdateFlashlightFor(KFPawn_Human InPawn)
{
	local PlayerController PC;
	local KFPawn_Human P;

	if ( bSkipBestFlashlightCheck )
	{
		InPawn.Flashlight.SetEnabled(InPawn.bFlashlightOn);
		return;
	}

	if ( !InPawn.bFlashlightOn )
	{
		// If the active flashlight is being turned off, choose another
		if ( InPawn.Flashlight.bEnabled )
		{
			InPawn.Flashlight.SetEnabled(false);
			ChooseBestFlashlight();
		}
	}
	else
	{
		PC = class'WorldInfo'.static.GetWorldInfo().GetALocalPlayerController();
		if ( PC == None )
		{
			return;
		}

		// If local player (or spectator) uses flashlight turn off all others
		if ( PC.ViewTarget == InPawn )
		{
			foreach PC.WorldInfo.AllPawns( class'KFPawn_Human', P )
			{
				if ( P.Flashlight.bEnabled )
				{
					P.Flashlight.SetEnabled(false);
				}
			}

			InPawn.Flashlight.SetEnabled(true);
		}
		// If nobody else has a flash light choose one now
		else if ( !PC.IsTimerActive(nameof(ChooseBestFlashlightTimer), self) )
		{
			ChooseBestFlashlight();
			PC.SetTimer(TeammateSwitchTimer, true, nameof(ChooseBestFlashlightTimer), self);
		}
		else
		{
			// timer is already going... just wait
		}
	}
}

/** Called by local player on looping timer while another teammate has light on */
simulated function ChooseBestFlashlightTimer()
{
	ChooseBestFlashlight();
}

/** Choose a nearby teammate to enable flashlight for */
simulated function ChooseBestFlashlight()
{
	local PlayerController PC;
	local KFPawn_Human P, BestPawn;
	local array<KFPawn_Human> DisableList;
	local float BestDistSq, DistSq;
	local float TeammateSwitchRadiusSq;
	local int i;

	TeammateSwitchRadiusSq = Square(TeammateSwitchRadius);
	PC = class'WorldInfo'.static.GetWorldInfo().GetALocalPlayerController();

	// find other players that are using their flashlight and choose the nearest
	// @todo: move to native for performance, or better yet add a AllHumans iterator
	foreach PC.WorldInfo.AllPawns( class'KFPawn_Human', P )
	{
		if ( !P.bFlashlightOn || !P.IsAliveAndWell() )
			continue;

		DistSq = VSizeSq(P.Location - PC.ViewTarget.Location);

		// if pawn has flashlight on we may be done
		if ( P.Flashlight.bEnabled )
		{
			if ( PC.ViewTarget == P )
			{
				`log("Flashlight staying on for view target", bDebug);
				return; // leave flashlight on
			}
			else if ( DistSq < TeammateSwitchRadiusSq )
			{
				`log("Flashlight staying on for"@P, bDebug);
				return; // leave flashlight on
			}

			DisableList.AddItem(P);
		}

		// rate by distance
		if ( BestPawn == None || DistSq < BestDistSq )
		{
			BestPawn = P;
			BestDistSq = DistSq;
		}
	}

	// If no players have their light on we can stop the timer
	if ( BestPawn == None )
	{
		PC.ClearTimer(nameof(ChooseBestFlashlightTimer), self);
	}
	// Enable flashlight on bestPawn and disable on others
	else if ( BestPawn != None && !BestPawn.Flashlight.bEnabled )
	{
		BestPawn.Flashlight.SetEnabled(true);
		// Disable others (Length "should" always be 1)
		for(i = 0; i < DisableList.Length; i++)
		{
			DisableList[i].Flashlight.SetEnabled(false);
		}
	}
}

defaultproperties
{
	Begin Object Class=LightFunction Name=FlashLightFunction_0
		SourceMaterial=Material'FX_Mat_Lib.VFX_Flashlight_PM'
	End Object

	Begin Object Class=SpotLightComponent Name=FlashlightTemplate_0
		Brightness=0.5
		InnerConeAngle=5
		OuterConeAngle=20
		Radius=3000
		CastShadows=FALSE
		CastStaticShadows=FALSE
		CastDynamicShadows=FALSE
		bCastPerObjectShadows=false
		ForceCastDynamicShadows=FALSE
		Function=FlashLightFunction_0
		LightingChannels=(Indoor=TRUE,Outdoor=TRUE,bInitialized=TRUE)
		bEnabled=FALSE
		bUpdateOwnerRenderTime=TRUE
	End Object
	LightTemplate=FlashlightTemplate_0

	Begin Object Class=StaticMeshComponent Name=LightConeComp_0
		CastShadow=FALSE
		bAcceptsStaticDecals=FALSE
		bAcceptsDecals=FALSE
		CollideActors=FALSE
		BlockActors=FALSE
		BlockZeroExtent=FALSE
		BlockNonZeroExtent=FALSE
		BlockRigidBody=FALSE
	End Object
	LightConeMeshComp=LightConeComp_0

	FlashlightSocketName=FlashLight

	TeammateSwitchRadius=1500 // 15m
	TeammateSwitchTimer=10.f

	MaxAIWarningDistSQ=4000000
	MaxAIWarningDistFromPointSQ=16384
}