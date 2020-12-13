//=============================================================================
// KFProj_NailBombGrenade
//=============================================================================
// Nail bomb projectile class
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
// - Christian "schneidzekk" Schneider
//=============================================================================

class KFProj_NailBombGrenade_Mini extends KFProj_NailBombGrenade
	hidedropdown;

//==============
// Touching
simulated function ProcessTouch(Actor Other, Vector HitLocation, Vector HitNormal)
{
	if (Other != Instigator && !Other.bWorldGeometry)
	{
		// Don't hit teammates
		if (Other.GetTeamNum() == GetTeamNum())
		{
			return;
		}
		if (!bHasExploded && !bHasDisintegrated)
		{
			GetExplodeEffectLocation(HitLocation, HitNormal, Other);
			TriggerExplosion(HitLocation, HitNormal, Other);
		}
	}

	super.ProcessTouch(Other, HitLocation, HitNormal);
}

defaultproperties
{
	bWarnAIWhenFired=true

    LandedTranslationOffset=(X=2)

	Speed=4000
	MaxSpeed=4000
	TerminalVelocity=4000
	TossZ=150

	ProjFlightTemplate = ParticleSystem'WEP_3P_M79_EMIT.FX_M79_40mm_Projectile'
	ProjFlightTemplateZedTime = ParticleSystem'WEP_3P_M79_EMIT.FX_M79_40mm_Projectile_ZEDTIME'
	ExplosionActorClass=class'KFExplosionActor'
	WeaponSelectTexture=Texture2D'wep_ui_nailbomb_tex.UI_WeaponSelect_GunslingerGrenade'

	FuseTime=2.0
	DampenFactor=0.40000
    DampenFactorParallel=0.60000

	// explosion
	Begin Object Class=KFGameExplosion Name=ExploTemplate0
		Damage=50  //300
		DamageRadius=500  //600
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
		CamShakeInnerRadius=100
		CamShakeOuterRadius=450
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
