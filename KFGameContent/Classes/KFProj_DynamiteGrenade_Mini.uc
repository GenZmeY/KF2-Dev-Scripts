//=============================================================================
// KFProj_DynamiteGrenade
//=============================================================================
// Dynamite projectile class
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
// - John "Ramm-Jaeger" Gibson and Jeff Robinson
//=============================================================================

class KFProj_DynamiteGrenade_Mini extends KFProj_DynamiteGrenade
	hidedropdown;


defaultproperties
{
	bWarnAIWhenFired=true

	LandedTranslationOffset=(X=-8)

	FuseTime=3.0

	DampenFactor=0.200000
    DampenFactorParallel=0.300000


	Speed=4000
	MaxSpeed=4000
	TerminalVelocity=4000
	TossZ=150

	ProjFlightTemplate = ParticleSystem'WEP_3P_M79_EMIT.FX_M79_40mm_Projectile'
	ProjFlightTemplateZedTime = ParticleSystem'WEP_3P_M79_EMIT.FX_M79_40mm_Projectile_ZEDTIME'
	ExplosionActorClass=class'KFExplosionActor'
	WeaponSelectTexture=Texture2D'wep_ui_dynamite_tex.UI_WeaponSelect_Dynamite'

	AltExploEffects=KFImpactEffectInfo'WEP_Dynamite_ARCH.Dynamite_Explosion_Concussive_Force'

	// explosion
	Begin Object Class=KFGameExplosion Name=ExploTemplate0
		Damage=150  //400
		DamageRadius=200  //900
		DamageFalloffExponent=2  //3
		DamageDelay=0.f

		// Damage Effects
		MyDamageType=class'KFDT_Explosive_DynamiteGrenade'
		KnockDownStrength=0
		FractureMeshRadius=200.0
		FracturePartVel=500.0
		ExplosionEffects=KFImpactEffectInfo'WEP_Dynamite_ARCH.Dynamite_Explosion'
		ExplosionSound=AkEvent'WW_WEP_EXP_Dynamite.Play_WEP_EXP_Dynamite_Explosion'

        // Dynamic Light
        ExploLight=ExplosionPointLight
        ExploLightStartFadeOutTime=0.0
        ExploLightFadeOutTime=0.2

		// Camera Shake
		CamShake=CameraShake'FX_CameraShake_Arch.Grenades.Default_Grenade'
		CamShakeInnerRadius=100
		CamShakeOuterRadius=450
		CamShakeFalloff=1.5f
		bOrientCameraShakeTowardsEpicenter=true
	End Object
	ExplosionTemplate=ExploTemplate0

	// Temporary effect (5.14.14)
	ProjDisintegrateTemplate=ParticleSystem'ZED_Siren_EMIT.FX_Siren_grenade_disable_01'

	GlassShatterType=FMGS_ShatterNone

	FuseEvent=AkEvent'WW_WEP_EXP_Dynamite.Play_WEP_EXP_Dynamite_Fuse_LP'

	AssociatedPerkClass=class'KFPerk_Demolitionist'
}


