//=============================================================================
// KFProj_HansSmokeGrenade
//=============================================================================
// Smoke grenade projectile class for boss character Hans
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
// - John "Ramm-Jaeger" Gibson
//=============================================================================

class KFProj_HansSmokeGrenade extends KFProj_Grenade
	hidedropdown;

simulated function PostBeginPlay()
{
	super(KFProjectile).PostBeginPlay();
	SpecialRandSpin(200000);
}

/** Special random spin that gets the grenade flipping more end over end due to its shape */
simulated function SpecialRandSpin(float spinRate)
{
	RotationRate.Yaw = (spinRate * 2 *FRand() - spinRate) * 0.05;
	RotationRate.Pitch = -SpinRate;
	RotationRate.Roll = (spinRate * 2 *FRand() - spinRate) * 0.05;
}

simulated event GrenadeIsAtRest()
{
	super.GrenadeIsAtRest();

	if (Role == ROLE_Authority)
	{
		ProjEffectsFadeOutDuration=PostExplosionLifetime;
		SetTimer(FuseTime, false, 'ExplodeTimer');
	}
}

simulated protected function StopFlightEffects();

defaultproperties
{
	FuseTime=1
	PostExplosionLifetime=15

    LandedTranslationOffset=(X=-5)
	bStopAmbientSoundOnExplode=false

	ProjFlightTemplate=ParticleSystem'ZED_Hans_EMIT.FX_Grenade_Smoke_01'
	ExplosionActorClass=class'KFExplosion_HansSmokeGrenade'

	// explosion
	Begin Object Class=KFGameExplosion Name=ExploTemplate0
		Damage=0
		DamageRadius=350
		DamageFalloffExponent=0.f
		DamageDelay=0.f
		MyDamageType=none

		// Damage Effects
		KnockDownStrength=0
		KnockDownRadius=0
		FractureMeshRadius=0
		FracturePartVel=0
		ExplosionEffects=KFImpactEffectInfo'ZED_Hans_EMIT.SmokeGrenade_Explosion'
		ExplosionSound=AkEvent'WW_ZED_Hans.ZED_Hans_SFX_Grenade_Smoke'
		MomentumTransferScale=0

		// Camera Shake
		CamShake=CameraShake'FX_CameraShake_Arch.Grenades.HansSmoke'
		CamShakeInnerRadius=0
		CamShakeOuterRadius=450
		CamShakeFalloff=2.f
		bOrientCameraShakeTowardsEpicenter=true
	End Object
	ExplosionTemplate=ExploTemplate0

	// Temporary effect (5.14.14)
	ProjDisintegrateTemplate=ParticleSystem'ZED_Siren_EMIT.FX_Siren_grenade_disable_01'
}


