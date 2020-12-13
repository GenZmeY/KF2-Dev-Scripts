//=============================================================================
// KFProj_MolotovGrenade_mini
//=============================================================================
//=============================================================================
// Killing Floor 2
// Copyright (C) 2018 Tripwire Interactive LLC
// - Zane Gholson
//=============================================================================

class KFProj_MolotovGrenade_Mini extends KFProj_MolotovGrenade
	hidedropdown;

/** Blow up on impact */
simulated event HitWall(vector HitNormal, Actor Wall, PrimitiveComponent WallComp)
{
	if( StaticMeshComponent(WallComp) != none && StaticMeshComponent(WallComp).CanBecomeDynamic() )
	{
		// pass through meshes that can move (like those little coffee tables in biotics)
		return;
	}

	Explode( Location, HitNormal );
}

defaultproperties
{
	bWarnAIWhenFired=true

	FuseTime=10 // molotov should only explode on contact, but it's probably good to have a fallback

	Speed=4000
	MaxSpeed=4000
	TerminalVelocity=4000
	TossZ=150

	ProjFlightTemplate = ParticleSystem'WEP_3P_M79_EMIT.FX_M79_40mm_Projectile'
	ProjFlightTemplateZedTime = ParticleSystem'WEP_3P_M79_EMIT.FX_M79_40mm_Projectile_ZEDTIME'
	ExplosionActorClass=class'KFExplosionActor'
	WeaponSelectTexture=Texture2D'wep_ui_molotov_tex.UI_WeaponSelect_MolotovCocktail'

	ResidualFlameProjClass=class'KFProj_MolotovSplash'
	NumResidualFlames=4
	
	// explosion
	Begin Object Class=KFGameExplosion Name=ExploTemplate0
		Damage=60  //60
		DamageRadius=250  //200
		DamageFalloffExponent=1.f
		DamageDelay=0.f

		MomentumTransferScale=0

		// Damage Effects
		MyDamageType=class'KFDT_Fire_MolotovGrenade'
		KnockDownStrength=0
		FractureMeshRadius=0
		FracturePartVel=500.0
		ExplosionEffects=KFImpactEffectInfo'wep_molotov_arch.Molotov_Explosion'

		ExplosionSound=AkEvent'WW_WEP_EXP_MOLOTOV.Play_WEP_EXP_Molotov_Explosion'

        // Dynamic Light
        ExploLight=FlamePointLight
        ExploLightStartFadeOutTime=0.4
        ExploLightFadeOutTime=0.2

		// Camera Shake
		CamShake=KFCameraShake'FX_CameraShake_Arch.Grenades.Molotov'
		CamShakeInnerRadius=125
		CamShakeOuterRadius=200
		CamShakeFalloff=1.f
		bOrientCameraShakeTowardsEpicenter=true
	End Object
	ExplosionTemplate=ExploTemplate0

	// Temporary effect (5.14.14)
	ProjDisintegrateTemplate=ParticleSystem'ZED_Siren_EMIT.FX_Siren_grenade_disable_01'

	ThrowAkEvent=AkEvent'WW_WEP_EXP_MOLOTOV.Play_WEP_EXP_Molotov_Throw'

	AssociatedPerkClass=class'KFPerk_Firebug'
}


