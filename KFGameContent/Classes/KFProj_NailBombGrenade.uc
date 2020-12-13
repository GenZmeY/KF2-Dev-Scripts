//=============================================================================
// KFProj_NailBombGrenade
//=============================================================================
// Nail bomb projectile class
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
// - Christian "schneidzekk" Schneider
//=============================================================================

class KFProj_NailBombGrenade extends KFProj_Grenade
	hidedropdown;

defaultproperties
{
	bWarnAIWhenFired=true

    LandedTranslationOffset=(X=2)

	ProjFlightTemplate=ParticleSystem'WEP_Nailbomb_EMIT.FX_Nailbomb_Mesh'
	ExplosionActorClass=class'KFExplosionActor'
	WeaponSelectTexture=Texture2D'wep_ui_nailbomb_tex.UI_WeaponSelect_GunslingerGrenade'

	FuseTime=2.0
	DampenFactor=0.40000
    DampenFactorParallel=0.60000

	// explosion
	Begin Object Class=KFGameExplosion Name=ExploTemplate0
		Damage=100  //300
		DamageRadius=1000  //600
		DamageFalloffExponent=1.f
		DamageDelay=0.f

		// Damage Effects
		MyDamageType=class'KFDT_Explosive_NailBombGrenade'
		KnockDownStrength=0
		FractureMeshRadius=200.0
		FracturePartVel=500.0
		ExplosionEffects=KFImpactEffectInfo'wep_Nailbomb_arch.Nailbomb_Explosion'
		ExplosionSound=AkEvent'WW_EXP_Nail_Bomb.Play_Nail_Bomb_Explode'


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

		// Shards
		ShardClass=class'KFProj_NailShard'
		NumShards=10
	End Object
	ExplosionTemplate=ExploTemplate0

	// Bounce Effects
	GrenadeBounceEffectInfo=KFImpactEffectInfo'wep_Nailbomb_arch.Nail_Bomb_Grenade_Impacts'

	// Temporary effect (5.14.14)
	ProjDisintegrateTemplate=ParticleSystem'ZED_Siren_EMIT.FX_Siren_grenade_disable_01'

	AssociatedPerkClass=class'KFPerk_Gunslinger'
}
