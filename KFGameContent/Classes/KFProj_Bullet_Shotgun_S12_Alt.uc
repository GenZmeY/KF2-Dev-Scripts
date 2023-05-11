//=============================================================================
// KFProj_Bullet_Shotgun_S12_Alt
//=============================================================================
// Class Description
//=============================================================================
// Killing Floor 2
// Copyright (C) 2023 Tripwire Interactive LLC
//=============================================================================

class KFProj_Bullet_Shotgun_S12_Alt extends KFProj_BallisticExplosive
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

	if (KFPawn(Instigator) != none)
	{
		// Explode right away
		ForceExplode();
	}
}

reliable client function ForceExplode()
{
	local vector Normal, MuzzleLocation;

	if (KFPawn(Instigator) != none)
	{
		Normal.X = 0.f;
		Normal.Y = 0.f;
		Normal.Z = 1.f;

		KFSkeletalMeshComponent(OwnerWeapon.Mesh).GetSocketWorldLocationAndRotation('MuzzleFlashAlt', MuzzleLocation);

		Explode(MuzzleLocation, Normal);

		Detonate();
	}
}

simulated function bool CanDud()
{
    return false;
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
	ArmDistSquared=0.f

	MaxSpeed=0.0
	Speed=0.0

	DamageRadius=0

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
		Damage=200
        DamageRadius=800
		DamageFalloffExponent=0.f
		DamageDelay=0.f
		MomentumTransferScale=10000
		bAlwaysFullDamage=true
		bDoCylinderCheck=true

		// Damage Effects
		MyDamageType=class'KFDT_Explosive_Shotgun_S12'
		KnockDownStrength=150
		FractureMeshRadius=200.0
		FracturePartVel=500.0
		
		ExplosionSound=AkEvent'WW_WEP_Saiga12.Play_WEP_Saiga12_Alt_Fire_1P'
		ExplosionEffects=KFImpactEffectInfo'WEP_Saiga12_ARCH.WEP_Saiga12_Impacts'

        // Dynamic Light
        ExploLight=ExplosionPointLight
        ExploLightStartFadeOutTime=0.0
        ExploLightFadeOutTime=0.3

		bIgnoreInstigator=true
		ActorClassToIgnoreForDamage = class'KFPawn_Human'

		// Camera Shake
		CamShake=CameraShake'FX_CameraShake_Arch.Misc_Explosions.Light_Explosion_Rumble'
		CamShakeInnerRadius=0
		CamShakeOuterRadius=300
		CamShakeFalloff=1.5f
		bOrientCameraShakeTowardsEpicenter=true
	End Object
	ExplosionTemplate=ExploTemplate0
}

