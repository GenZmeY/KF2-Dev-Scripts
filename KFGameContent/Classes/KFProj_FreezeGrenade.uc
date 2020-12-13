//=============================================================================
// KFProj_FreezeGrenade
//=============================================================================
// Freeze Grenade projectile class
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
// - Jeff Robinson
//=============================================================================

class KFProj_FreezeGrenade extends KFProj_Grenade
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
    FuseTime=0.15 //0.5

	ProjFlightTemplate=ParticleSystem'WEP_Freeze_Grenade_EMIT.FX_Freeze_Grenade_Mesh'
	ExplosionActorClass=class'KFExplosionActor'
	WeaponSelectTexture=Texture2D'WEP_UI_LN2_Grenade_TEX.UI_WeaponSelect_SharpshooterGrenade'

	// Grenade explosion light
	Begin Object Name=ExplosionPointLight
	    LightColor=(R=128,G=200,B=255,A=255)
		Brightness=4.f
		Radius=1500.f //1500
		FalloffExponent=10.f
		CastShadows=False
		CastStaticShadows=FALSE
		CastDynamicShadows=True
		bEnabled=FALSE
		LightingChannels=(Indoor=TRUE,Outdoor=TRUE,bInitialized=TRUE)
	End Object

	// explosion
	Begin Object Class=KFGameExplosion Name=ExploTemplate0
		Damage=25   //100
		DamageRadius=900//600
		DamageFalloffExponent=1  //2
		DamageDelay=0.f

		// Damage Effects
		MyDamageType=class'KFDT_Freeze_FreezeGrenade'
		FractureMeshRadius=200.0
		FracturePartVel=500.0
		ExplosionEffects=KFImpactEffectInfo'WEP_Freeze_Grenade_Arch.FreezeGrenade_Explosion'
		ExplosionSound=AkEvent'WW_WEP_Freeze_Grenade.Play_Freeze_Grenade_Explo'
		MomentumTransferScale=1

        // Dynamic Light
        ExploLight=ExplosionPointLight
        ExploLightStartFadeOutTime=0.5
        ExploLightFadeOutTime=0.25
        ExploLightFlickerIntensity=5.f
        ExploLightFlickerInterpSpeed=15.f

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

	AssociatedPerkClass=class'KFPerk_Sharpshooter'
}


