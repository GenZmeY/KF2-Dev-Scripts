//=============================================================================
// KFProj_HEGrenade
//=============================================================================
// High Explosive Grenade projectile class
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
// - John "Ramm-Jaeger" Gibso
//=============================================================================

class KFProj_HEGrenade extends KFProj_Grenade
	hidedropdown;

defaultproperties
{
	bWarnAIWhenFired=true

    LandedTranslationOffset=(X=2)

	ProjFlightTemplate=ParticleSystem'WEP_3P_MK3_EMIT.FX_MK3_Grenade_Mesh'
	ExplosionActorClass=class'KFExplosionActor'
	WeaponSelectTexture=Texture2D'ui_weaponselect_tex.UI_WeaponSelect_MK3_Grenade'

	// explosion
	Begin Object Class=KFGameExplosion Name=ExploTemplate0
		Damage=300  //300
		DamageRadius=650  //800
		DamageFalloffExponent=2.f
		DamageDelay=0.f

		// Damage Effects
		MyDamageType=class'KFDT_Explosive_HEGrenade'
		KnockDownStrength=0
		FractureMeshRadius=200.0
		FracturePartVel=500.0	
		ExplosionEffects=KFImpactEffectInfo'FX_Impacts_ARCH.Explosions.HEGrenade_Explosion'
		ExplosionSound=AkEvent'WW_WEP_EXP_Grenade_HE.Play_WEP_EXP_Grenade_HE_Explosion'

        // Dynamic Light
        ExploLight=ExplosionPointLight
        ExploLightStartFadeOutTime=0.0
        ExploLightFadeOutTime=0.2

		// Camera Shake
		CamShake=CameraShake'FX_CameraShake_Arch.Grenades.Default_Grenade'
		CamShakeInnerRadius=200
		CamShakeOuterRadius=900
		CamShakeFalloff=1.5f
		bOrientCameraShakeTowardsEpicenter=true
	End Object
	ExplosionTemplate=ExploTemplate0

	// Temporary effect (5.14.14)
	ProjDisintegrateTemplate=ParticleSystem'ZED_Siren_EMIT.FX_Siren_grenade_disable_01'

	AssociatedPerkClass=class'KFPerk_Commando'

	FuseTime=1.0
}


