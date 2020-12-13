//=============================================================================
// KFProj_HansHEGrenade
//=============================================================================
// Hans' High Explosive Grenade projectile class
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
// John "Ramm-Jaeger" Gibson
//=============================================================================

class KFProj_HansHEGrenade extends KFProj_Grenade
	hidedropdown;

simulated function PostBeginPlay()
{
	super(KFProjectile).PostBeginPlay();
	SpecialRandSpin(200000);

	if( Role == ROLE_Authority )
	{
	   SetTimer(FuseTime, false, 'ExplodeTimer');
	}
}

/** Special random spin that gets the grenade flipping more end over end due to its shape */
simulated function SpecialRandSpin(float spinRate)
{
	RotationRate.Yaw = (spinRate * 2 *FRand() - spinRate) * 0.05;
	RotationRate.Pitch = -SpinRate;
	RotationRate.Roll = (spinRate * 2 *FRand() - spinRate) * 0.05;
}

defaultproperties
{
    LandedTranslationOffset=(X=-5)

	ProjFlightTemplate=ParticleSystem'ZED_Hans_EMIT.FX_Grenade_Explosive_01'
	ExplosionActorClass=class'KFExplosionActor'

	FuseTime=3

	// explosion
	Begin Object Class=KFGameExplosion Name=ExploTemplate0
		Damage=95
		DamageRadius=800
		DamageFalloffExponent=2.f
		DamageDelay=0.f

		// Damage Effects
		MyDamageType=class'KFDT_Explosive_HansHEGrenade'
		KnockDownStrength=0
		FractureMeshRadius=200.0
		FracturePartVel=500.0
		ExplosionEffects=KFImpactEffectInfo'FX_Impacts_ARCH.Explosions.HEGrenade_Explosion'
		ExplosionSound=AkEvent'WW_ZED_Hans.ZED_Hans_SFX_Grenade_Frag'

        // Dynamic Light
        ExploLight=ExplosionPointLight
        ExploLightStartFadeOutTime=0.0
        ExploLightFadeOutTime=0.2

		// Camera Shake
		CamShake=CameraShake'FX_CameraShake_Arch.Grenades.Default_Grenade'
		CamShakeInnerRadius=450
		CamShakeOuterRadius=900
		CamShakeFalloff=1.f
		bOrientCameraShakeTowardsEpicenter=true
	End Object
	ExplosionTemplate=ExploTemplate0

	// Temporary effect (5.14.14)
	ProjDisintegrateTemplate=ParticleSystem'ZED_Siren_EMIT.FX_Siren_grenade_disable_01'
}


