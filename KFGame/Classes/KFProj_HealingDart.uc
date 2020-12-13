//=============================================================================
// KFProj_HealingDart
//=============================================================================
// Healing Dart projectile
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
// John "Ramm-Jaeger" Gibson
//=============================================================================

class KFProj_HealingDart extends KFProj_Bullet
	hidedropdown;

var Actor SeekTarget;
var vector InitialDir;

/** Tracking strength multiplier */
var(Locking) float TrackingStrength;

/** Offset to apply to SeekTarget's location */
var vector SeekOffset;
/** Set on first tick with a valid SeekTarget */
var bool bSeekInitialized;

replication
{
    if( bNetInitial && (Role==ROLE_Authority) )
        SeekTarget, InitialDir;
}

/** Called from Tick the first time we have a valid target */
simulated function InitializeSeek()
{
	local KFPawn KFP;

	if ( IsZero(InitialDir) )
	{
		InitialDir = Normal(Velocity);
	}

	// Instead of aiming at the cylinder aim for a bone on the mesh that will collide with this
	// projectile. Fixes an issue where the dart can miss a stationary target (see MTO_IKFloorConform)
	KFP = KFPawn(SeekTarget);
	if ( KFP != None && KFP.TorsoBoneName != '' )
	{
		SeekOffset = KFP.Mesh.GetBoneLocation(KFP.TorsoBoneName) - KFP.Location;
	}
}

/** Handle flight FX fading */
simulated event Tick(float DeltaTime)
{
    local vector SeekingVector, ForceDir;
    local float VelMag;

    super.Tick(DeltaTime);

	if ( bShuttingDown || SeekTarget == none )
	{
		return;
	}

	if ( SeekTarget == Instigator )
	{
		SeekTarget = none;
		return;
	}

	// Initialize seek vars
    if ( !bSeekInitialized )
	{
		InitializeSeek();
		bSeekInitialized = true;
	}

	SeekingVector = SeekTarget.Location + SeekOffset;
	ForceDir = Normal(SeekingVector - Location);

	if( (ForceDir Dot InitialDir) > 0.f )
	{
		VelMag = VSize(Velocity);
		Acceleration = TrackingStrength * VelMag * ForceDir;
	}
	else
	{
		Acceleration = Vect(0,0,0);
	}
}

/** Skip projectile HitWall since the healing dart does no damage and just explode/shutdown */
simulated event HitWall(vector HitNormal, Actor Wall, PrimitiveComponent WallComp)
{
	Explode(Location, HitNormal);
}

defaultproperties
{
	MaxSpeed=10000.0
	Speed=10000.0

	TrackingStrength=75

	// @note: Use caution when bNoReplicationToInstigator != bUseClientSideHitDetection or if bSyncToOriginalLocation !=
	// bUpdateSimulatedPosition.  Using CSHD with server replicated projectiles can be error prone if not careful.

	bAmbientSoundZedTimeOnly=false
    bNoReplicationToInstigator=false
	bUseClientSideHitDetection=true
	bUpdateSimulatedPosition=false
	bRotationFollowsVelocity=true//false
	bNetTemporary=false

	bDamageDestructiblesOnTouch=false
}

