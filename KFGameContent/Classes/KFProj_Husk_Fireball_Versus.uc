//=============================================================================
// KFProj_Husk_Fireball_Versus
//=============================================================================
// Versus version of the husk fireball
//=============================================================================
// Killing Floor 2
// Copyright (C) 2016 Tripwire Interactive LLC
//=============================================================================
class KFProj_Husk_Fireball_Versus extends KFProj_Husk_Fireball;

DefaultProperties
{
	ProjFlightTemplate=ParticleSystem'ZED_Patriarch_EMIT.FX_Patriarch_Rocket_Projectile'

	// Explosion template
	Begin Object Name=ExploTemplate0
		Damage=23
		DamageRadius=650 //450 //550
		DamageFalloffExponent=1.f //1.0
		DamageDelay=0.f

		// Damage Effects
		MyDamageType=class'KFDT_Fire_HuskFireball'
		MomentumTransferScale=60000.f
		KnockDownStrength=100
		FractureMeshRadius=200.0
		FracturePartVel=500.0
		ExplosionEffects=KFImpactEffectInfo'FX_Impacts_ARCH.Explosions.HuskProjectile_Explosion'
		ExplosionSound=AkEvent'WW_ZED_Husk.ZED_Husk_SFX_Ranged_Shot_Impact'
		ExplosionEmitterScale=2.f

        // Dynamic Light
        ExploLight=ExplosionPointLight
        ExploLightStartFadeOutTime=0.0
        ExploLightFadeOutTime=0.5

		// Camera Shake
		CamShake=CameraShake'FX_CameraShake_Arch.Misc_Explosions.HuskFireball'
		CamShakeInnerRadius=450
		CamShakeOuterRadius=900
		CamShakeFalloff=1.f
		bOrientCameraShakeTowardsEpicenter=true
	End Object
	ExplosionTemplate=ExploTemplate0

	// Ground fire
	bSpawnGroundFire=true
	BurnDuration=4.f
	BurnDamageInterval=0.25f
	GroundFireExplosionActorClass=class'KFExplosion_HuskFireballGroundFire'

	// Fire light
	Begin Object Name=FlamePointLight
	    LightColor=(R=245,G=190,B=140,A=255)
		Brightness=4.f
		Radius=500.f
		FalloffExponent=10.f
		CastShadows=False
		CastStaticShadows=FALSE
		CastDynamicShadows=TRUE
		bEnabled=FALSE
		LightingChannels=(Indoor=TRUE,Outdoor=TRUE,bInitialized=TRUE)
	End Object

	Begin Object Name=ExploTemplate1
		Damage=1
		DamageRadius=150
		DamageFalloffExponent=1.f
		DamageDelay=0.f
		// Don't burn the guy that tossed it, it's just too much damage with multiple fires, its almost guaranteed to kill the guy that tossed it
        bIgnoreInstigator=true

		MomentumTransferScale=0

		// Damage Effects
		MyDamageType=class'KFDT_Fire_ZedGround'
		KnockDownStrength=0
		FractureMeshRadius=0
		ExplosionEffects=KFImpactEffectInfo'wep_molotov_arch.Molotov_GroundFire'

		bDirectionalExplosion=true

		// Camera Shake
		CamShake=none

		// Dynamic Light
        ExploLight=FlamePointLight
        ExploLightStartFadeOutTime=1.5f
        ExploLightFadeOutTime=0.3
	End Object
	GroundFireExplosionTemplate=ExploTemplate1
}
