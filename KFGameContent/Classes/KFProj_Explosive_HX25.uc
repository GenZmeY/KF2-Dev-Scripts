//=============================================================================
// KFProj_Explosive_HX25
//=============================================================================
// High explosive grenade launcher grenade for the HX25
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
// - John "Ramm-Jaeger" Gibso
//=============================================================================

class KFProj_Explosive_HX25 extends KFProj_BallisticExplosive
	hidedropdown;

defaultproperties
{
	Physics=PHYS_Falling
	Speed=4000
	MaxSpeed=4000
	TerminalVelocity=4000
	TossZ=150
	GravityScale=1
    MomentumTransfer=50000.0
    ArmDistSquared=122500 // 3.5 meters
	LifeSpan = +1000.0f

	ProjFlightTemplate=ParticleSystem'WEP_HX25_Pistol_EMIT.FX_HX25_Pistol_Projectile'
	ProjFlightTemplateZedTime=ParticleSystem'WEP_HX25_Pistol_EMIT.FX_HX25_Pistol_Projectile_ZEDTIME'
	ProjDudTemplate=ParticleSystem'WEP_HX25_Pistol_EMIT.FX_HX25_Pistol_Projectile_Dud'
	GrenadeBounceEffectInfo=KFImpactEffectInfo'FX_Impacts_ARCH.DefaultGrenadeImpacts'
	ProjDisintegrateTemplate=ParticleSystem'ZED_Siren_EMIT.FX_Siren_grenade_disable_01'
	AltExploEffects=KFImpactEffectInfo'WEP_HX25_Pistol_ARCH.HX25_Pistol_Grenade_Explosion_Concussive_Force'

	// Grenade explosion light
	Begin Object Class=PointLightComponent Name=ExplosionPointLight
	    LightColor=(R=252,G=218,B=171,A=255)
		Brightness=4.f
		Radius=2000.f
		FalloffExponent=10.f
		CastShadows=False
		CastStaticShadows=FALSE
		CastDynamicShadows=False
		bCastPerObjectShadows=false
		bEnabled=FALSE
		LightingChannels=(Indoor=TRUE,Outdoor=TRUE,bInitialized=TRUE)
	End Object

	// explosion
	Begin Object Class=KFGameExplosion Name=ExploTemplate0
		Damage=125
		DamageRadius=400
		DamageFalloffExponent=1.0f
		DamageDelay=0.f

		// Damage Effects
		MyDamageType=class'KFDT_Explosive_HX25'
		KnockDownStrength=0
		FractureMeshRadius=200.0
		FracturePartVel=500.0
		ExplosionEffects=KFImpactEffectInfo'WEP_HX25_Pistol_ARCH.HX25_Pistol_Grenade_Explosion'
		ExplosionSound=AkEvent'WW_WEP_SA_HX25.Play_WEP_SA_HX25_Explosion'

        // Dynamic Light
        ExploLight=ExplosionPointLight
        ExploLightStartFadeOutTime=0.0
        ExploLightFadeOutTime=0.3

		// Camera Shake
		CamShake=CameraShake'FX_CameraShake_Arch.Misc_Explosions.Light_Explosion_Rumble'
		CamShakeInnerRadius=0
		CamShakeOuterRadius=300
		CamShakeFalloff=1.5f
		bOrientCameraShakeTowardsEpicenter=true
	End Object
	ExplosionTemplate=ExploTemplate0

	AmbientSoundPlayEvent=AkEvent'WW_WEP_SA_M79.Play_WEP_SA_M79_Projectile_Loop'
    AmbientSoundStopEvent=AkEvent'WW_WEP_SA_M79.Stop_WEP_SA_M79_Projectile_Loop'
}

