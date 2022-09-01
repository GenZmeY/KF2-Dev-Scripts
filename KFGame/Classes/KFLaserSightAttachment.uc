//=============================================================================
// KFLaserSightAttachment
//=============================================================================
// Attach and manage laser sight to a weapon in 1st person
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
// - Sakib Saikia
//=============================================================================

class KFLaserSightAttachment extends Object
	hidecategories(Object)
	native(Effect);

/** Distance at which we should start scaling the dot size and depth bias (5m) */
var() float LaserDotLerpStartDistance;
/** Distance at which we should stop scaling the dot size and depth bias (60m) */
var() float LaserDotLerpEndDistance;
/** Max scale is clamped at 20x */
var() float LaserDotMaxScale;
/** How much to pull the laser dot back to make sure it doesn't clip through what it hit */
var() float LaserDotDepthBias;

/*********************************************************************************************
 * @name	Attachments
 ********************************************************************************************* */

/** Static Mesh */
var() StaticMesh LaserDotMesh;
var transient StaticMeshComponent LaserDotMeshComp;

/** Laser Sight Mesh */
var()		  SkeletalMesh				LaserSightMesh;
var transient KFSkeletalMeshComponent	LaserSightMeshComp;

/** Laser Mesh */
var()		  SkeletalMesh				LaserBeamMesh;
var transient KFSkeletalMeshComponent	LaserBeamMeshComp;

/** Socket to attach the LaserSight to */
var() name LaserSightSocketName;
var() float LaserSightRange;

/** Specifies how much animation to blend in for the laser dot.
	If 0, the dot will match the aim direction perfectly.
	If 1, the dot will be completely controlled by animation
	NOTE: First person only.
 */
var float AnimWeight;

/** Specifies blending rate between aim and animation */
var() float AnimBlendRate;

/** How strongly the laser sight should adhere to the aim direction.
	Used to blend in and out of the weapon's active state
 */
var transient 			float 			LaserSightAimStrength;
var transient 			float 			DesiredAimStrength;

var transient bool IsVisible;

/** Create/Attach lasersight components */
function AttachLaserSight(SkeletalMeshComponent OwnerMesh, bool bFirstPerson, optional name SocketNameOverride)
{
    local KFSkeletalMeshComponent KFMesh;

	if ( OwnerMesh == None )
	{
		`log("Invalid mesh for laser sight " @self);
		return;
	}

	// Allow code to override attachment socket
	if ( SocketNameOverride != '' )
	{
		LaserSightSocketName = SocketNameOverride;
	}

	if ( LaserDotMesh != None && bFirstPerson )
	{
		LaserDotMeshComp.SetStaticMesh(LaserDotMesh);
		OwnerMesh.AttachComponentToSocket(LaserDotMeshComp, LaserSightSocketName);
	}

	if ( LaserSightMesh != None )
	{
        LaserSightMeshComp.SetSkeletalMesh(LaserSightMesh);
		OwnerMesh.AttachComponentToSocket(LaserSightMeshComp, LaserSightSocketName);
        if( bFirstPerson )
        {
            LaserSightMeshComp.SetDepthPriorityGroup(SDPG_Foreground);
        }
	}

	if ( LaserBeamMesh != None )
	{
		LaserBeamMeshComp.SetSkeletalMesh(LaserBeamMesh);
		OwnerMesh.AttachComponentToSocket(LaserBeamMeshComp, LaserSightSocketName);

		if( bFirstPerson )
		{
			LaserBeamMeshComp.SetDepthPriorityGroup(SDPG_Foreground);
		}
	}

    KFMesh =  KFSkeletalMeshComponent(OwnerMesh);

	// If attaching to a mesh with a custom FOV
	if (KFMesh != none && KFMesh.FOV > 0)
	{
		SetMeshFOV( KFMesh.FOV );
	}
}

/** Set the FOV of the laser sight mesh */
simulated function SetMeshFOV( float NewFOV )
{
	if( LaserBeamMeshComp.SkeletalMesh != none )
	{
        LaserBeamMeshComp.SetFOV( NewFOV );
    }

    if( LaserSightMeshComp.SkeletalMesh != none )
    {
	   LaserSightMeshComp.SetFOV( NewFOV );
	}
}

/** Set the lighting channels on all the appropriate weapon attachment mesh(es) */
simulated function SetMeshLightingChannels(LightingChannelContainer NewLightingChannels)
{
	if( LaserSightMeshComp.SkeletalMesh != none  )
	{
		LaserSightMeshComp.SetLightingChannels(NewLightingChannels);
	}
}

simulated event ChangeVisibility(bool bVisible)
{
	IsVisible = bVisible;

    LaserDotMeshComp.SetHidden(!bVisible);
    LaserSightMeshComp.SetHidden(!bVisible);
    LaserBeamMeshComp.SetHidden(!bVisible);
}

/** 
 * Update function called from currently equipped 1st person weapon 
 * @todo: move to c++?
 */
simulated function Update(float DeltaTime, KFWeapon OwningWeapon)
{
	local vector TraceStart, TraceEnd;
	local vector InstantTraceHitLocation, InstantTraceHitNormal;
	local vector HitLocation, HitNormal;
	local vector TraceAimDir;
	local vector SocketSpaceNewTraceDir, WorldSpaceNewTraceDir;
	local vector SocketSpaceAimLocation, SocketSpaceAimDir;
	local Actor	HitActor;
	local rotator SocketRotation;
	local matrix SocketToWorldTransform;
	local vector DirA, DirB;
	local Quat Q;
	local TraceHitInfo		HitInfo;

	if (IsVisible == false)
	{
		return;
	}

	if( OwningWeapon != None &&
		OwningWeapon.Instigator != None &&
		OwningWeapon.Instigator.Weapon == OwningWeapon &&
		OwningWeapon.Instigator.IsFirstPerson() )
	{
		UpdateFirstPersonAimStrength(DeltaTime, OwningWeapon);

		// This is where we would start an instant trace
		TraceStart = OwningWeapon.Instigator.GetWeaponStartTraceLocation();
		TraceAimDir = Vector(OwningWeapon.Instigator.GetAdjustedAimFor( OwningWeapon, TraceStart ));

		// Do aim calculations only when weapon is in active state
		if( LaserSightAimStrength > 0.f )
		{
			// Simulate an instant trace where weapon is aiming, Get hit info.
			// Take minimal part of CalcWeaponFire()
			TraceEnd = TraceStart + TraceAimDir * LaserSightRange;
			HitActor = OwningWeapon.GetTraceOwner().Trace(InstantTraceHitLocation, InstantTraceHitNormal, TraceEnd, TraceStart, TRUE, vect(0,0,0), HitInfo, OwningWeapon.TRACEFLAG_Bullet);

			//OwningWeapon.MySkelMesh.GetSocketWorldLocationAndRotation(LaserSightSocketName, SocketLocation);
			//OwningWeapon.DrawDebugLine(SocketLocation, InstantTraceHitLocation, 255, 255, 0, FALSE);

			if( HitActor != None )
			{
				// If aim strength is not 100%, then blend in animation
				if( LaserSightAimStrength < 1.f )
				{
					if( OwningWeapon.MySkelMesh != None &&
						OwningWeapon.MySkelMesh.GetSocketWorldLocationAndRotation(LaserSightSocketName,  TraceStart,  SocketRotation) )
					{

						//OwningWeapon.DrawDebugLine(TraceStart, TraceStart + 1000*Vector(SocketRotation), 0, 255, 255, FALSE);

						SocketToWorldTransform = OwningWeapon.MySkelMesh.GetSocketMatrix(LaserSightSocketName);
						SocketSpaceAimLocation = InverseTransformVector(SocketToWorldTransform, InstantTraceHitLocation);

                		// Basically SocketSpaceAimLocation - (0,0,0)
                		SocketSpaceAimDir = Normal(SocketSpaceAimLocation);

						// Clamp the maximum aim adjustment for the AimDir so you don't get weird
						// cases where the aim dir is rotated away from the location where you
						// are aiming. This can happen if you are really close to an object.
						// Note : DirB is the socket face dir
						DirB = vect(1,0,0);
						DirA = SocketSpaceAimDir;

						if ( (DirA dot DirB) < class'KFWeapon'.const.MaxAimAdjust_Cos )
						{
							Q = QuatFromAxisAndAngle(Normal(DirB cross DirA), class'KFWeapon'.const.MaxAimAdjust_Angle );
							SocketSpaceAimDir = QuatRotateVector(Q,DirB);
						}

		                // Apply relative rotation to aim along desired direction
						SocketSpaceNewTraceDir = LaserSightAimStrength * SocketSpaceAimDir + (1.f - LaserSightAimStrength) * DirB;

						// Transform the direction to world space. Convert direction vector  in socket space to point
						// in world space and subtract the socket location to get direction vector in world space
						WorldSpaceNewTraceDir = TransformVector(SocketToWorldTransform, SocketSpaceNewTraceDir) - TraceStart;

						// Trace from socket along new trace direction
						TraceEnd = TraceStart + Normal(WorldSpaceNewTraceDir) * LaserSightRange;
						HitActor = OwningWeapon.GetTraceOwner().Trace(HitLocation, HitNormal, TraceEnd, TraceStart, TRUE, vect(0,0,0), HitInfo, OwningWeapon.TRACEFLAG_Bullet);

						if( HitActor != None )
						{
							// Unhide the dot mesh and make it point at given hit location
							// Note: SetHidden() checks for previous visibility state before reattaching
							LaserDotMeshComp.SetHidden(false);
							AimAt(HitLocation, HitNormal, OwningWeapon.MySkelMesh);
							//OwningWeapon.DrawDebugLine(HitLocation, HitLocation + 50*Normal(HitNormal), 0, 255, 0, FALSE);
						}
						else
						{
							// Hide the dot mesh if it didn't hit anything
							LaserDotMeshComp.SetHidden(true);
						}
	                }
				}
				else
				{
					// If aim strength is 100%, then just aim at the instant trace location
					LaserDotMeshComp.SetHidden(false);
					AimAt(InstantTraceHitLocation, InstantTraceHitNormal, OwningWeapon.MySkelMesh);
				}
			}
			else
			{
				// Hide the dot mesh if it didn't hit anything
				LaserDotMeshComp.SetHidden(true);
			}
		}
		else
		{
			// Weapon is in "Inactive" state when it is unequipped. Skip these
			// calculations when unequipped
			if( OwningWeapon.MySkelMesh != None &&
				OwningWeapon.MySkelMesh.GetSocketWorldLocationAndRotation(LaserSightSocketName,  TraceStart,  SocketRotation) )
			{
				DirA = vector(SocketRotation);
				DirB = TraceAimDir;

				// If we're off by more than 20 degrees just hide the dot.  This 
				// covers up an issue where the weapon FOV adjustment causes a desync
				if ( (DirA dot DirB) < 0.94f)
				{
					LaserDotMeshComp.SetHidden(true);
					return;
				}

				TraceEnd = TraceStart + vector(SocketRotation) * LaserSightRange;
				HitActor = OwningWeapon.GetTraceOwner().Trace(HitLocation, HitNormal, TraceEnd, TraceStart, TRUE, vect(0,0,0), HitInfo, OwningWeapon.TRACEFLAG_Bullet);
				if( HitActor != None )
				{
					// Unhide the dot mesh and make it point at given hit location
					// Note: SetHidden() checks for previous visibility state before reattaching
					LaserDotMeshComp.SetHidden(false);
					AimAt(HitLocation, HitNormal, OwningWeapon.MySkelMesh);
				}
				else
				{
					// Hide the dot mesh if it didn't hit anything
					LaserDotMeshComp.SetHidden(true);
				}
			}
		}
	}
}

/** Determine how much to weigh screen center versus weapon socket */
function UpdateFirstPersonAImStrength(float DeltaTime, KFWeapon W)
{
	// aim at center of screen
	if ( W.IsInState('Active') &&
		// If additive bob is off we're playing a fidget animation and need to follow weapon
		W.IdleBobBlendNode != None && W.IdleBobBlendNode.Child2WeightTarget == 1.f )
	{
		DesiredAimStrength = 1.f - AnimWeight;
	}
	// follow weapon
	else 
	{
		DesiredAimStrength = 0.f;
	}

	if( LaserSightAimStrength < DesiredAimStrength )
	{
		LaserSightAimStrength = FMin(LaserSightAimStrength + AnimBlendRate * DeltaTime, DesiredAimStrength);
	}
	else if( LaserSightAimStrength > DesiredAimStrength )
	{
		LaserSightAimStrength = FMax(LaserSightAimStrength - AnimBlendRate * DeltaTime, DesiredAimStrength);
	}
}

/**
 * Draw the laser dot at the given world space location and oriented in the direction of the given hit normal
 */
function AimAt(vector HitLocation, vector HitNormal, SkeletalMeshComponent ParentMesh)
{
	local vector SocketSpaceAimLocation;
	local matrix SocketToWorldTransform;
	local float LaserDotScale;
	local vector SocketLocation;
	local vector SocketToHit;

    ParentMesh.GetSocketWorldLocationAndRotation(LaserSightSocketName, SocketLocation);

    // Pull the hit location back a bit to keep the laser dot from clipping
    SocketToHit = (HitLocation - SocketLocation) * LaserDotDepthBias;
    HitLocation = SocketLocation + SocketToHit;

	SocketToWorldTransform = ParentMesh.GetSocketMatrix(LaserSightSocketName);

	// Transform the aim location to the coordinate system of the laser sight socket
	SocketSpaceAimLocation = InverseTransformVector(SocketToWorldTransform, HitLocation);
	LaserDotMeshComp.SetTranslation(SocketSpaceAimLocation);

	// Scale laser dot based on distance clamped at 10x at 30m
	LaserDotScale = 1.f + (LaserDotMaxScale - 1.f) * FMax((SocketSpaceAimLocation.X - LaserDotLerpStartDistance)/(LaserDotLerpEndDistance - LaserDotLerpStartDistance), 0.f);
	LaserDotMeshComp.SetScale(LaserDotScale);

	// START DEBUG
//	`log("Distance = " $ SocketSpaceAimLocation.X @ "Scale = " $ LaserDotScale);
//	class'WorldInfo'.static.GetWorldInfo().DrawDebugLine(HitLocation, HitLocation + 50*Normal(HitNormal), 0, 0, 255, FALSE);
	// END DEBUG
}

/** 
 * Since 1st person weapons have a custom rendered FOV when we need accuracy 
 * GetSocketWorldLocationAndRotation() is not good enough.  This is not without
 * problems as it's expensive to compute and introduces a frame lag because
 * skeletal mesh FOV is adjusted on the render thread.
 */
native function bool GetFOVAdjustedLaserSocket(KFSkeletalMeshComponent Mesh, name InSocketName, out vector OutLocation, out rotator OutRotation);

defaultproperties
{
	Begin Object Class=StaticMeshComponent Name=LaserDotStaticMeshComponent_0
		CastShadow=FALSE
		CollideActors=FALSE
		BlockActors=FALSE
		BlockZeroExtent=FALSE
		BlockNonZeroExtent=FALSE
		BlockRigidBody=FALSE
		bAcceptsDecals=FALSE
		TickGroup=TG_PostAsyncWork
		DepthPriorityGroup=SDPG_Foreground // First person only
	End Object
	LaserDotMeshComp=LaserDotStaticMeshComponent_0

	Begin Object Class=KFSkeletalMeshComponent Name=LaserSightMeshComponent_0
		CollideActors=FALSE
		BlockActors=FALSE
		BlockZeroExtent=FALSE
		BlockNonZeroExtent=FALSE
		BlockRigidBody=FALSE
		bAcceptsDecals=FALSE
		bOwnerNoSee=true
		bOnlyOwnerSee=false
		AlwaysLoadOnClient=true
		AlwaysLoadOnServer=false
		MaxDrawDistance=4000
		bAcceptsDynamicDecals=FALSE
		CastShadow=true
		bCastDynamicShadow=true
		bUpdateSkelWhenNotRendered=false
		bIgnoreControllersWhenNotRendered=true
		bOverrideAttachmentOwnerVisibility=true
		// Default to outdoor. If indoor, this will be set when TWIndoorLightingVolume::Touch() event is received at spawn.
		LightingChannels=(Outdoor=TRUE,bInitialized=TRUE)
		TickGroup=TG_PostAsyncWork
	End Object
	LaserSightMeshComp=LaserSightMeshComponent_0

	Begin Object Class=KFSkeletalMeshComponent Name=LaserBeamMeshComp_0
		CastShadow=FALSE
	End Object
	LaserBeamMeshComp=LaserBeamMeshComp_0

	LaserSightRange=20000 //200m

	// Set AnimWeight to 0 as it causes the laser dot to diverge from the
	// aim location when you the player is right up against an obstace
	AnimWeight=0.f
	AnimBlendRate=3.f

    LaserDotLerpStartDistance=25.f
    LaserDotLerpEndDistance=6000.f
    LaserDotMaxScale=10.f
    LaserDotDepthBias=0.95f

	IsVisible=true
}
