//=============================================================================
// KFDynamicFogAndDamageVolumeInfo
//=============================================================================
// A fog volume that can be dynamically blended in and out, and which can
// also damage actors within the bounds of the volume
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
// - John "Ramm-Jaeger" Gibson
//=============================================================================
class KFDynamicFogAndDamageVolumeInfo extends FogVolumeConstantDensityInfo
	showcategories(Movement)
	placeable;

/** The spawn group setup of a wave */

/** This property allows the fog volume to damage a player as long as they are within it. Using a negative value will allow the volume to have a regenerative effect. NB. bPainCausing must be set to TRUE to activate this */
var()		float				DamagePerSec;
/** When damage is applied to an object, it is done so using a specific DamageType. Each available DamageType has a KDamageImpulse property which controls the magnitude of the impulse to be applied along the momentum vector. */
var()		class<DamageType>	DamageType<AllowAbstract>;

/** This property activates the ability to cause damage. Used in conjunction with DamagePerSecond and PainInterval */
var()		bool				bPainCausing;
/** Amount of time, in seconds, between damage applications. NB. bPainCausing must be set to TRUE to activate this */
var()		float				PainInterval;
/** True if this volume should damage zeds */
var()		bool				bDamageZeds;

/** How long to take to blend fog in/out. Note: Damage blends in/out with the fading */
var()		float				FogBlendTime;
/** The remaining time for this fog blend transition */
var         float				FogBlendTimeRemaining;
/** Fog is blending in */
var         bool    			bBlendingFogIn;
/** Fog is blending out */
var         bool	       	    bBlendingFogOut;

/** Stores the old value of bEnabled for checking against */
var         bool	       	    bOldEnabled;

/** Fog is blending out */
var repnotify		byte        FogBlendAmountRep;

/** What was the density when this fog volume spawned */
var         float               InitialDensity;
/** What is the current fog density */
var         float               CurrentDensity;

/** Temp message to play when this volume activates */
var()       String              ActivateMessage;
/** Temp message to play when this volume deactivates */
var()       String              DeactivateMessage;

replication
{
	if (Role == ROLE_Authority)
		FogBlendAmountRep;
}

simulated event PostBeginPlay()
{
	Super.PostBeginPlay();

    // Store the initial density
    InitialDensity = FogVolumeConstantDensityComponent(DensityComponent).Density;
    CurrentDensity = InitialDensity;

    // Clear the density if it's not enabled, so it won't pop in with density
    if( !bEnabled )
    {
        FogVolumeConstantDensityComponent(DensityComponent).Density = 0;
        ReattachComponent(DensityComponent);
    }

	if ( Role < ROLE_Authority )
		return;
	if ( bPainCausing )
	{
		SetTimer(PainInterval, true, nameof(TimerPop));
	}
}

simulated event ReplicatedEvent(name VarName)
{
    local float BlendedFogAmount;

    if (VarName == 'FogBlendAmountRep')
	{
		BlendedFogAmount = Float(FogBlendAmountRep)/255.0;
        SetFogDensity( BlendedFogAmount );
	}
	else if (VarName != 'bEnabled')
	{
		Super.ReplicatedEvent(VarName);
	}
}


/* epic ===============================================
* ::OnToggle
*
* Scripted support for toggling height fog, checks which
* operation to perform by looking at the action input.
*
* Input 1: turn on
* Input 2: turn off
* Input 3: toggle
*
* =====================================================
*/
simulated function OnToggle(SeqAct_Toggle action)
{
	if (action.InputLinks[0].bHasImpulse)
	{
		// turn on
		StartBlendIn();
	}
	else if (action.InputLinks[1].bHasImpulse)
	{
		// turn off
		StartBlendOut();
	}
	else if (action.InputLinks[2].bHasImpulse)
	{
		// toggle
		if( bEnabled )
		{
            StartBlendOut();
		}
		else
		{
            StartBlendIn();
		}

	}
}

/** Set the fog density and handle setting replicated fog density */
simulated function SetFogDensity( float NewDensity )
{
	if ( Role < ROLE_Authority )
    {
        if( NewDensity == 0 )
        {
            if( bOldEnabled )
                Deactivate();
        }
        else
        {
            if( !bOldEnabled )
                Activate();
        }
    }

    FogVolumeConstantDensityComponent(DensityComponent).Density = NewDensity * InitialDensity;
    CurrentDensity = FogVolumeConstantDensityComponent(DensityComponent).Density;

    if ( Role == ROLE_Authority )
    {
        FogBlendAmountRep = CurrentDensity/InitialDensity * 255;
        bNetDirty = true;
        bForceNetUpdate = TRUE;
    }

    //`log("FogBlendAmountRep = "$FogBlendAmountRep$" CurrentDensity = "$CurrentDensity$" InitialDensity = "$InitialDensity);

    // Must reattach the component to get the fog values to change. TODO: this may be expensive, so might need a graphics programmer to improve this
    if( WorldInfo.NetMode != NM_DedicatedServer )
    {
        ReattachComponent(DensityComponent);
    }
}

event Tick( float DeltaTime )
{
	if ( Role < ROLE_Authority )
		return;

    if( bBlendingFogIn )
    {
        FogBlendTimeRemaining -= DeltaTime;

        if( FogBlendTimeRemaining <= 0 )
        {
            SetFogDensity( 1.0 );
            bBlendingFogIn=false;
            //`log("Blending in complete, density = "$FogVolumeConstantDensityComponent(DensityComponent).Density);
        }
        else
        {
            SetFogDensity( 1.0 - (FogBlendTimeRemaining/FogBlendTime) );
            //`log("Blending in, density = "$FogVolumeConstantDensityComponent(DensityComponent).Density$" blend time: "$(FogBlendTimeRemaining/FogBlendTime));
        }
    }
    else if( bBlendingFogOut )
    {
        FogBlendTimeRemaining -= DeltaTime;

        if( FogBlendTimeRemaining <= 0 )
        {
            SetFogDensity( 0 );
            bBlendingFogOut=false;
            //`log("Blending out complete, density = "$FogVolumeConstantDensityComponent(DensityComponent).Density);
            Deactivate();
        }
        else
        {
            SetFogDensity( FogBlendTimeRemaining/FogBlendTime );
            //`log("Blending out, density = "$FogVolumeConstantDensityComponent(DensityComponent).Density$" blend time: "$(FogBlendTimeRemaining/FogBlendTime));
        }

    }
}

event Touch( Actor Other, PrimitiveComponent OtherComp, vector HitLocation, vector HitNormal )
{
	Super.Touch(Other, OtherComp, HitLocation, HitNormal);
	if ( (Other == None) || Other.bStatic )
		return;

	if ( bPainCausing )
	{
		if ( Other.bCanBeDamaged )
		{
			if( bEnabled )
			{
                CausePainTo(Other);
            }
		}
	}
}

function CausePainTo(Actor Other)
{
    if( !bDamageZeds && KFPawn_Monster(Other) != none )
    {
        return;
    }

	if (DamagePerSec > 0)
	{
		if ( (DamageType == None) || (DamageType == class'DamageType') )
			`log("No valid damagetype ("$DamageType$") specified for "$PathName(self));
		Other.TakeDamage(DamagePerSec*PainInterval*(CurrentDensity/InitialDensity), none/*DamageInstigator*/, Location, vect(0,0,1), DamageType,, self);
		//`log("Damaging other for "$DamagePerSec*PainInterval*(CurrentDensity/InitialDensity));
	}
	else
	{
		Other.HealDamage(-DamagePerSec * PainInterval*(CurrentDensity/InitialDensity), none/*DamageInstigator*/, DamageType);
	}
}

/*
TimerPop
damage touched actors if pain causing.
*/
function TimerPop()
{
	local Actor A;

	if( !bEnabled )
	{
        return;
    }

	if ( !bPainCausing )
		return;

	ForEach TouchingActors(class'Actor', A)
	{
		if ( A.bCanBeDamaged && !A.bStatic )
		{
			CausePainTo(A);
		}
	}
}

/** Activate this fog volume */
simulated function Activate()
{
    SetEnabled( true );
    TempMessagePlayers( ActivateMessage );
}

/** Deactivate this fog volume */
simulated function Deactivate()
{
    if( bEnabled )
    {
        TempMessagePlayers( DeactivateMessage );
    }

    SetEnabled( false );
}

/** Blend in and activate this fog volume */
simulated function StartBlendIn()
{
    Activate();
    bBlendingFogIn = true;
    bBlendingFogOut = false;
    FogBlendTimeRemaining = FogBlendTime;
}

/** Blend out and deactivate this fog volume */
simulated function StartBlendOut()
{
    if( bEnabled )
    {
        bBlendingFogOut = true;
        bBlendingFogIn = false;
        FogBlendTimeRemaining = FogBlendTime;
    }
}

/** Toggled the enabled setting for this fog volume */
simulated function SetEnabled( bool bNewEnabled )
{
	DensityComponent.SetEnabled(bNewEnabled);
	bEnabled = DensityComponent.bEnabled;
	bOldEnabled = bEnabled;
	ForceNetRelevant();
	SetForcedInitialReplicatedProperty(Property'Engine.FogVolumeDensityInfo.bEnabled', (bEnabled == default.bEnabled));
	NetUpdateFrequency = 5.0;
}

/** Temporary method of handling messaging the players for this volume */
simulated function TempMessagePlayers( coerce String Msg )
{
`if(`notdefined(FINAL_RELEASE))
	local KFPlayerController KFPC;

	`log( "!!!!"@Msg@"!!!!" );

	foreach LocalPlayerControllers(class'KFPlayerController', KFPC)
	{
		KFPC.MyGFxHUD.ShowNonCriticalMessage( Msg );
	}
`endif
}

defaultproperties
{
	Begin Object Name=AutomaticMeshComponent0
        CollideActors=true
		StaticMesh=StaticMesh'EngineMeshes.Cube'
		bCastDynamicShadow=FALSE
		BlockActors=false
		BlockZeroExtent=false
		BlockNonZeroExtent=true
		BlockRigidBody=false
		bForceDirectLightMap=FALSE
		bAcceptsDynamicLights=FALSE
		bAcceptsLights=FALSE
		CastShadow=FALSE
		bUsePrecomputedShadows=FALSE
		bAcceptsStaticDecals=FALSE
		bAcceptsDynamicDecals=FALSE
		bUseAsOccluder=FALSE
		bSelectable=FALSE
		bIgnoreOwnerHidden=TRUE
		WireframeColor=(R=100,G=100,B=200,A=255)
	End Object

    bCollideActors=True

	DamageType=class'Engine.DamageType'
	PainInterval=1.f
	FogBlendTime=3.0
}
