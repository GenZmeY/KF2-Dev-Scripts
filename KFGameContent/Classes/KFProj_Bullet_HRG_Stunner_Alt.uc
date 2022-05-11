//=============================================================================
// KFProj_Bullet_HRG_Boomy
//=============================================================================
// Class Description
//=============================================================================
// Killing Floor 2
// Copyright (C) 2021 Tripwire Interactive LLC
//=============================================================================

class KFProj_Bullet_HRG_Stunner_Alt extends KFProj_BallisticExplosive
	hidedropdown;

var protected KFWeapon OwnerWeapon;

/** Initialize the projectile */
function Init( vector Direction )
{
	super.Init( Direction );

	OwnerWeapon = KFWeapon( Owner );
	if( OwnerWeapon != none )
	{
		OwnerWeapon.LastPelletFireTime = WorldInfo.TimeSeconds;
	}
}

/** Don't allow more than one pellet projectile to perform this check in a single frame */
function bool ShouldWarnAIWhenFired()
{
	return super.ShouldWarnAIWhenFired() && OwnerWeapon != none && OwnerWeapon.LastPelletFireTime < WorldInfo.TimeSeconds;
}

simulated protected function PrepareExplosionTemplate()
{
	super.PrepareExplosionTemplate();

	/** Since bIgnoreInstigator is transient, its value must be defined here */
	ExplosionTemplate.bIgnoreInstigator = true;
}

simulated function AdjustCanDisintigrate() {}

/** Can be overridden in subclasses to exclude specific projectiles from nuking */
simulated function bool AllowNuke()
{
    return false;
}

defaultproperties
{
	MaxSpeed=22500.0
	Speed=22500.0

	DamageRadius=0

	ProjDisintegrateTemplate=ParticleSystem'ZED_Siren_EMIT.FX_Siren_grenade_disable_01'
	ProjFlightTemplate=ParticleSystem'WEP_HRG_Stunner_EMIT.FX_HRG_Stunner_ALT_Tracer_ZEDTime'
	ProjFlightTemplateZedTime=ParticleSystem'WEP_HRG_Stunner_EMIT.FX_HRG_Stunner_ALT_Tracer_ZEDTime'

	// Grenade explosion light
	Begin Object Class=PointLightComponent Name=ExplosionPointLight
	    LightColor=(R=252,G=218,B=171,A=255)
		Brightness=0.5f
		Radius=400.f
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
		Damage=40 //50
        DamageRadius=300 //250 //150
		DamageFalloffExponent=2.f
		DamageDelay=0.f
		MomentumTransferScale=10000

		// Damage Effects
		MyDamageType=class'KFDT_Explosive_HRG_Stunner'
		KnockDownStrength=150
		FractureMeshRadius=200.0
		FracturePartVel=500.0
		
		ExplosionSound=AkEvent'WW_WEP_HRG_Stunner.Play_WEP_HRG_Stunner_Alt_Fire_Explosion'
		ExplosionEffects=KFImpactEffectInfo'WEP_HRG_Stunner_ARCH.WEB_HRG_Stunner_Impacts'

        // Dynamic Light
        ExploLight=ExplosionPointLight
        ExploLightStartFadeOutTime=0.0
        ExploLightFadeOutTime=0.3

		bIgnoreInstigator=true

		// Camera Shake
		CamShake=CameraShake'FX_CameraShake_Arch.Misc_Explosions.Light_Explosion_Rumble'
		CamShakeInnerRadius=0
		CamShakeOuterRadius=300
		CamShakeFalloff=1.5f
		bOrientCameraShakeTowardsEpicenter=true
	End Object
	ExplosionTemplate=ExploTemplate0
}

