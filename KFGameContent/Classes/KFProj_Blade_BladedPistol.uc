//=============================================================================
// KFProj_Blade_BladedPistol
//=============================================================================
// Blade class for the BladedPistol
//=============================================================================
// Killing Floor 2
// Copyright (C) 2021 Tripwire Interactive LLC
//=============================================================================

class KFProj_Blade_BladedPistol extends KFProj_RicochetStickBullet
	hidedropdown;

// Make sure that last location always exists.
simulated event PostBeginPlay()
{
    Super.PostBeginPlay();

    LastLocation = Location;
}

simulated function bool ShouldProcessBulletTouch()
{
	return BouncesLeft > 0 && GravityScale == default.GravityScale;
}

defaultproperties
{
	MaxSpeed=4000.0 //2500.0
	Speed=4000.0 //2500.0
	GravityScale=0.8 //0.75

	DamageRadius=0

	bWarnAIWhenFired=true

    BouncesLeft=2
    DampingFactor=0.8 //0.95
    RicochetEffects=KFImpactEffectInfo'WEP_BladedPistol_ARCH.BladedImpacts'
    LifeSpan=8
    LifeSpanAfterStick=180

	Begin Object Name=CollisionCylinder
		CollisionRadius=6
		CollisionHeight=2
	End Object

	// Additional zero-extent line traces
	//ExtraLineCollisionOffsets.Add((Y=-8))
	//ExtraLineCollisionOffsets.Add((Y=8))
	ExtraLineCollisionOffsets.Add((Y=-16))
	ExtraLineCollisionOffsets.Add((Y=16))
	ExtraLineCollisionOffsets.Add((Z=-6))
	ExtraLineCollisionOffsets.Add((Z=6))
	// Since we're still using an extent cylinder, we need a line at 0
	ExtraLineCollisionOffsets.Add(())

    bAmbientSoundZedTimeOnly=false
	bNoReplicationToInstigator=false
	bUseClientSideHitDetection=true
	bUpdateSimulatedPosition=true
	bRotationFollowsVelocity=false
	bNetTemporary=False


	ProjFlightTemplate=ParticleSystem'WEP_BladedPistol_EMIT.FX_bladed_projectile_01'
	ProjFlightTemplateZedTime=ParticleSystem'WEP_BladedPistol_EMIT.FX_bladed_projectile_01'

	ImpactEffects=KFImpactEffectInfo'WEP_BladedPistol_ARCH.BladedEmbedFX'

	AmbientSoundPlayEvent=AkEvent'WW_WEP_BladedPistol.Play_WEP_BladedPistol_Projectile_Loop'
	AmbientSoundStopEvent=AkEvent'WW_WEP_BladedPistol.Stop_WEP_BladedPistol_Projectile_Loop'

    PickupRadius=250   //200
	WeaponClassName=KFWeap_Pistol_Bladed
	ProjPickupTemplate=ParticleSystem'WEP_BladedPistol_EMIT.FX_bladed_pickup_01'
    AmmoPickupSound=AkEvent'WW_WEP_BladedPistol.Play_WEP_BladedPistol_Projectile_Pickup'

    TouchTimeThreshhold=0.15
}
