//=============================================================================
// KFProj_Explosive_HRGWinterbite
//=============================================================================
//=============================================================================
// Killing Floor 2
// Copyright (C) 2019 Tripwire Interactive LLC
//=============================================================================

class KFProj_Explosive_HRGWinterbite extends KFProj_BallisticExplosive;

simulated function AdjustCanDisintigrate() {}

simulated protected function PrepareExplosionTemplate()
{
	// skip KFProj_BallisticExplosive because it applies Demo skills
    super(KFProjectile).PrepareExplosionTemplate();
}

simulated protected function SetExplosionActorClass()
{
	// skip KFProj_BallisticExplosive because it applies Demo skills
    super(KFProjectile).SetExplosionActorClass();
}

defaultproperties
{
	Physics=PHYS_Falling
	Speed= 9000//7500
	MaxSpeed= 9000//7500
	TerminalVelocity= 9000//7500
	TossZ=150
	GravityScale=0.15 //0.25
    MomentumTransfer=50000.0
    ArmDistSquared=0 // set to 0 to keep from dudding
	LifeSpan = +10.0f

	ProjFlightTemplate=ParticleSystem'WEP_HRG_Winterbite_EMIT.FX_WinterBite_Projectile'
	ProjFlightTemplateZedTime=ParticleSystem'WEP_HRG_Winterbite_EMIT.FX_WinterBite_Projectile_ZEDTIME'
	ProjDudTemplate=ParticleSystem'WEP_HRG_Winterbite_EMIT.FX_WinterBite_Projectile_Dud'
	GrenadeBounceEffectInfo=KFImpactEffectInfo'WEP_HRG_Winterbite_ARCH.FX_Winterbite_Projectile_Impacts'
	ProjDisintegrateTemplate=ParticleSystem'ZED_Siren_EMIT.FX_Siren_grenade_disable_01'
	AltExploEffects=KFImpactEffectInfo'WEP_HRG_Winterbite_ARCH.FX_WinterBite_Projectile_Explosion_Concussive_Force'

	Begin Object Name=CollisionCylinder
		CollisionRadius=0.f
		CollisionHeight=0.f
	End Object

	// Grenade explosion light
	Begin Object Class=PointLightComponent Name=ExplosionPointLight
	    LightColor=(R=50,G=100,B=150,A=255)
		Brightness=1.f
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
		Damage=20
		DamageRadius=200
		DamageFalloffExponent=0
		DamageDelay=0.f

		//Impulse applied to Zeds
		MomentumTransferScale=1
		
		// Damage Effects
		MyDamageType=class'KFDT_Explosive_HRGWinterbite'
		KnockDownStrength=0
		FractureMeshRadius=200.0
		FracturePartVel=500.0
		ExplosionEffects=KFImpactEffectInfo'WEP_HRG_Winterbite_ARCH.FX_WinterBite_Projectile_Explosion'
		ExplosionSound=AkEvent'WW_WEP_Flare_Gun.Play_WEP_Flare_Gun_Explode_Ice'

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

