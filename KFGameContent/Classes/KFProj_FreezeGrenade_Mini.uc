//=============================================================================
// KFProj_FreezeGrenade
//=============================================================================
// Freeze Grenade projectile class
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
// - Jeff Robinson
//=============================================================================

class KFProj_FreezeGrenade_Mini extends KFProj_FreezeGrenade
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
    FuseTime=0.15 //0.5

	
	Speed=4000
	MaxSpeed=4000
	TerminalVelocity=4000
	TossZ=150

	ProjFlightTemplate = ParticleSystem'WEP_3P_M79_EMIT.FX_M79_40mm_Projectile'
	ProjFlightTemplateZedTime = ParticleSystem'WEP_3P_M79_EMIT.FX_M79_40mm_Projectile_ZEDTIME'
	ExplosionActorClass=class'KFExplosionActor'
	WeaponSelectTexture=Texture2D'WEP_UI_LN2_Grenade_TEX.UI_WeaponSelect_SharpshooterGrenade'

	// Grenade explosion light
	Begin Object Name=ExplosionPointLight
	    LightColor=(R=128,G=200,B=255,A=255)
		Brightness=4.f
		Radius=750.f //1500
		FalloffExponent=10.f
		CastShadows=False
		CastStaticShadows=FALSE
		CastDynamicShadows=True
		bEnabled=FALSE
		LightingChannels=(Indoor=TRUE,Outdoor=TRUE,bInitialized=TRUE)
	End Object

	// explosion
	Begin Object Class=KFGameExplosion Name=ExploTemplate0
		Damage=12   //100
		DamageRadius=450//600
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


