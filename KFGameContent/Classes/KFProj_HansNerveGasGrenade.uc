//=============================================================================
// KFProj_HansNerveGasGrenade
//=============================================================================
// Nerve gas grenade projectile class for boss character Hans
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
// - John "Ramm-Jaeger" Gibson
//=============================================================================

class KFProj_HansNerveGasGrenade extends KFProj_Grenade
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

/**
 * Force the explosion actor not to damage the instigator, since setting it in the default props is not working for some reason - Ramm
 */
simulated protected function PrepareExplosionTemplate()
{
	ExplosionTemplate.bIgnoreInstigator=true;
}

defaultproperties
{
	FuseTime=1
	PostExplosionLifetime=15

    LandedTranslationOffset=(X=2)
	bStopAmbientSoundOnExplode=false

	ProjFlightTemplate=ParticleSystem'ZED_Hans_EMIT.FX_Grenade_Nerve_Gas_01'
	ExplosionActorClass=class'KFExplosion_HansNerveGasGrenade'

	// Grenade explosion light
	Begin Object Name=ExplosionPointLight
	    LightColor=(R=200,G=200,B=0,A=255)
		Brightness=2.f
		Radius=500.f
		FalloffExponent=10.f
		CastShadows=False
		CastStaticShadows=FALSE
		CastDynamicShadows=True
		bEnabled=FALSE
		LightingChannels=(Indoor=TRUE,Outdoor=TRUE,bInitialized=TRUE)
	End Object

	// explosion
	Begin Object Class=KFGameExplosion Name=ExploTemplate0
		Damage=7
		DamageRadius=450
		DamageFalloffExponent=0.f
		DamageDelay=0.f
		MyDamageType=class'KFDT_Toxic_HansGrenade'
		//bIgnoreInstigator is set to true in PrepareExplosionTemplate

		// Damage Effects
		KnockDownStrength=0
		KnockDownRadius=0
		FractureMeshRadius=0
		FracturePartVel=0
		ExplosionEffects=KFImpactEffectInfo'ZED_Hans_EMIT.NerveGasGrenade_Explosion'
		ExplosionSound=AkEvent'WW_ZED_Hans.ZED_Hans_SFX_Grenade_Poison'
		MomentumTransferScale=0

        // Dynamic Light
        ExploLight=ExplosionPointLight
        ExploLightStartFadeOutTime=7.0
        ExploLightFadeOutTime=1.0
        ExploLightFlickerIntensity=5.f
        ExploLightFlickerInterpSpeed=15.f

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


