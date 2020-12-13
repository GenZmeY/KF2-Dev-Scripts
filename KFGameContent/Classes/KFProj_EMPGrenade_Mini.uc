//=============================================================================
// KFProj_EMPGrenade_Mini
//=============================================================================
// EMP Grenade projectile class
//=============================================================================
// Killing Floor 2
// Copyright (C) 2018 Tripwire Interactive LLC
// - Zane Gholson
//=============================================================================

class KFProj_EMPGrenade_Mini extends KFProj_EMPGrenade
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
    LandedTranslationOffset=(X=2)
    FuseTime=0.25 //0.5

	Speed=4000
	MaxSpeed=4000
	TerminalVelocity=4000
	TossZ=150

	ProjFlightTemplate = ParticleSystem'WEP_3P_M79_EMIT.FX_M79_40mm_Projectile'
	ProjFlightTemplateZedTime = ParticleSystem'WEP_3P_M79_EMIT.FX_M79_40mm_Projectile_ZEDTIME'
	ExplosionActorClass=class'KFExplosionActor'
	WeaponSelectTexture=Texture2D'ui_weaponselect_tex.UI_WeaponSelect_EMPGrenade'

	// Grenade explosion light
	Begin Object Name=ExplosionPointLight
	    LightColor=(R=128,G=200,B=255,A=255)
		Brightness=4.f
		Radius=750.f
		FalloffExponent=10.f
		CastShadows=False
		CastStaticShadows=FALSE
		CastDynamicShadows=True
		bEnabled=FALSE
		LightingChannels=(Indoor=TRUE,Outdoor=TRUE,bInitialized=TRUE)
	End Object

	// explosion
	Begin Object Class=KFGameExplosion Name=ExploTemplate0
		Damage=15  //100
		DamageRadius=350   //600
		DamageFalloffExponent=1  //2
		DamageDelay=0.f

		// Damage Effects
		MyDamageType=class'KFDT_EMP_EMPGrenade'
		FractureMeshRadius=100
		FracturePartVel=250.0
		ExplosionEffects=KFImpactEffectInfo'FX_Impacts_ARCH.Explosions.EMPGrenade_Explosion'
		ExplosionSound=AkEvent'WW_WEP_EXP_Grenade_EMP.Play_WEP_EXP_Grenade_EMP_Explosion'

        // Dynamic Light
        ExploLight=ExplosionPointLight
        ExploLightStartFadeOutTime=0.5
        ExploLightFadeOutTime=0.25
        ExploLightFlickerIntensity=5.f
        ExploLightFlickerInterpSpeed=15.f

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

	AssociatedPerkClass=class'KFPerk_Berserker'
}


