//=============================================================================
// KFProj_Rocket_HRG_MedicMissile
//=============================================================================
// Killing Floor 2
// Copyright (C) 2022 Tripwire Interactive LLC
//=============================================================================

class KFProj_Rocket_HRG_MedicMissile extends KFProj_BallisticExplosive
	hidedropdown;

simulated function bool AllowNuke()
{
    return false;
}

simulated function bool AllowDemolitionistConcussive()
{
	return false;
}

simulated function bool AllowDemolitionistExplosionChangeRadius()
{
	return false;
}

simulated protected function PrepareExplosionTemplate()
{
	local Weapon OwnerWeapon;
	local Pawn OwnerPawn;
	local KFPerk_Survivalist Perk;
	
	super(KFProjectile).PrepareExplosionTemplate();

	OwnerWeapon = Weapon(Owner);
	if (OwnerWeapon != none)
	{
		OwnerPawn = Pawn(OwnerWeapon.Owner);
		if (OwnerPawn != none)
		{
			Perk = KFPerk_Survivalist(KFPawn(OwnerPawn).GetPerk());
			if (Perk != none)
			{
				ExplosionTemplate.DamageRadius *= KFPawn(OwnerPawn).GetPerk().GetAoERadiusModifier();
			}
		}
	}
}

simulated function AdjustCanDisintigrate()
{
	// This weapon is not from Demolitionist, so always enable Siren disintegrate
	bCanDisintegrate = true;
}

defaultproperties
{
	Physics=PHYS_Projectile
	Speed=5000
	MaxSpeed=5000
	TossZ=0
	GravityScale=1.0
    MomentumTransfer=50000.0
	ArmDistSquared=150000 // 4 meters

	bCollideWithTeammates=true

	bWarnAIWhenFired=true

	ProjFlightTemplate=ParticleSystem'WEP_HRG_MedicMissile_EMIT.FX_HRG_MedicMissile_Projectile'
	ProjFlightTemplateZedTime=ParticleSystem'WEP_HRG_MedicMissile_EMIT.FX_HRG_MedicMissile_Projectile_ZED_TIME'
	ProjDudTemplate=ParticleSystem'WEP_HRG_MedicMissile_EMIT.FX_HRG_MedicMissile_Projectile_Dud'
	GrenadeBounceEffectInfo=KFImpactEffectInfo'WEP_HRG_MedicMissile_ARCH.HRG_MedicMissile_Projectile_Impacts'

    ProjDisintegrateTemplate=ParticleSystem'ZED_Siren_EMIT.FX_Siren_grenade_disable_01'
	bCanDisintegrate=true

	AmbientSoundPlayEvent=AkEvent'WW_WEP_HRG_MedicMissile.Play_WEP_HRG_MedicMissile_Projectile_Loop'
  	AmbientSoundStopEvent=AkEvent'WW_WEP_HRG_MedicMissile.Stop_WEP_HRG_MedicMissile_Projectile_Loop'

	AltExploEffects=KFImpactEffectInfo'WEP_HRG_MedicMissile_ARCH.HRG_MedicMissile_Explosion_Concussive_Force'

	ExplosionActorClass=class'KFExplosion_HRG_MedicMissile'

	// Grenade explosion light
	Begin Object Class=PointLightComponent Name=ExplosionPointLight
	    LightColor=(R=60,G=200,B=255,A=255)
		Brightness=2.f
		Radius=1500.f
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
		Damage=400
		DamageRadius=300
		DamageFalloffExponent=2
		DamageDelay=0.f

		// Damage Effects
		MyDamageType=class'KFDT_Explosive_HRG_MedicMissile'
		KnockDownStrength=0
		FractureMeshRadius=0.0
		FracturePartVel=0.0
		ExplosionEffects=KFImpactEffectInfo'WEP_HRG_MedicMissile_ARCH.HRG_MedicMissile_Explosion'
		ExplosionSound=AkEvent'WW_WEP_HRG_MedicMissile.Play_WEP_HRG_MedicMissile_Explosion'

        // Dynamic Light
        ExploLight=ExplosionPointLight
        ExploLightStartFadeOutTime=0.0
        ExploLightFadeOutTime=0.2

		// Camera Shake
		CamShake=CameraShake'FX_CameraShake_Arch.Misc_Explosions.Light_Explosion_Rumble'
		CamShakeInnerRadius=200
		CamShakeOuterRadius=900
		CamShakeFalloff=1.5f
		bOrientCameraShakeTowardsEpicenter=true
	End Object
	ExplosionTemplate=ExploTemplate0

	bCanApplyDemolitionistPerks=false
}