//=============================================================================
// KFProj_FlashBangGrenade
//=============================================================================
// High Explosive Grenade projectile class
//=============================================================================
// Killing Floor 2
// Copyright (C) 2016 Tripwire Interactive LLC
// - Chris "schneidezekk" Schneider
//=============================================================================

class KFProj_FlashBangGrenade extends KFProj_Grenade
	hidedropdown;

simulated function PostBeginPlay()
{
	super.PostBeginPlay();

	// fuze starts at rest
	ClearTimer(nameof(ExplodeTimer));
}

simulated event GrenadeIsAtRest()
{
	super.GrenadeIsAtRest();

	if (Role == ROLE_Authority)
	{
		SetTimer(FuseTime, false, 'ExplodeTimer');
	}
}

defaultproperties
{
    LandedTranslationOffset=(X=2)
    FuseTime=0.25 //0.5

	ProjFlightTemplate=ParticleSystem'WEP_M84_EMIT.FX_M84_Grenade_Mesh'
	ExplosionActorClass=class'KFExplosionActor'
	WeaponSelectTexture=Texture2D'ui_weaponselect_tex.UI_WeaponSelect_MK3_Grenade'

	// explosion
	Begin Object Class=KFGameExplosion Name=ExploTemplate0
		Damage=125  //300
		DamageRadius=700  //800
		DamageFalloffExponent=2.f
		DamageDelay=0.f

		// Damage Effects
		MyDamageType=class'KFDT_Explosive_FlashBangGrenade'
		KnockDownStrength=0
		FractureMeshRadius=200.0
		FracturePartVel=500.0	
		ExplosionEffects=KFImpactEffectInfo'WEP_M84_ARCH.M84_Explosion'
		ExplosionSound=AkEvent'WW_WEP_EXP_Grenade_Frag.Play_WEP_Flashbang'

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

	AssociatedPerkClass=class'KFPerk_SWAT'


}