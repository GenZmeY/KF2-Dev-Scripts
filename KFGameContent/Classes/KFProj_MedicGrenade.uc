//=============================================================================
// KFProj_NanoGasGrenade
//=============================================================================
// Nano gas player healing/zed hurting projectile class
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
// - John "Ramm-Jaeger" Gibso
//=============================================================================

class KFProj_MedicGrenade extends KFProj_Grenade
	hidedropdown;

var array<KFPawn> HealedPawns; 

simulated function PostBeginPlay()
{
	super(KFProjectile).PostBeginPlay();
	RandSpin(100000);
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

simulated function Destroyed()
{
	HealedPawns.Remove( 0, HealedPawns.Length );

	super.Destroyed();
}


simulated protected function StopFlightEffects();

defaultproperties
{
	FuseTime=0.5  //1
	PostExplosionLifetime=15

    LandedTranslationOffset=(X=2)
	bStopAmbientSoundOnExplode=false

	ProjFlightTemplate=ParticleSystem'WEP_3P_Medic_Grenade_EMIT.FX_Medic_Grenade_Mesh'
	ExplosionActorClass=class'KFExplosion_MedicGrenade'
	WeaponSelectTexture=Texture2D'ui_weaponselect_tex.UI_WeaponSelect_MedicGrenade'

	// Grenade explosion light
	Begin Object Name=ExplosionPointLight
	    LightColor=(R=0,G=128,B=255,A=255)
		Brightness=4.f
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
		Damage=50  //50
		DamageRadius=350
		DamageFalloffExponent=0.f
		DamageDelay=0.f
		MyDamageType=class'KFDT_Toxic_MedicGrenade'

		// Damage Effects
		KnockDownStrength=0
		KnockDownRadius=0
		FractureMeshRadius=0
		FracturePartVel=0
		ExplosionEffects=KFImpactEffectInfo'FX_Impacts_ARCH.Explosions.MedicGrenade_Explosion'
		ExplosionSound=AkEvent'WW_WEP_EXP_Grenade_Medic.Play_WEP_EXP_Grenade_Medic_Explosion'
		MomentumTransferScale=0

        // Dynamic Light
        ExploLight=ExplosionPointLight
        ExploLightStartFadeOutTime=7.0
        ExploLightFadeOutTime=1.0
        ExploLightFlickerIntensity=5.f
        ExploLightFlickerInterpSpeed=15.f

		// Camera Shake
		CamShake=none
		CamShakeInnerRadius=0
		CamShakeOuterRadius=0
		CamShakeFalloff=1.5f
		bOrientCameraShakeTowardsEpicenter=true
	End Object
	ExplosionTemplate=ExploTemplate0

	// Temporary effect (5.14.14)
	ProjDisintegrateTemplate=ParticleSystem'ZED_Siren_EMIT.FX_Siren_grenade_disable_01'
	bAllowTossDuringZedGrabRotation=true

	AssociatedPerkClass=class'KFPerk_FieldMedic'
}


