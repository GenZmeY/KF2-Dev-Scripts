//=============================================================================
// KFProj_HRG_Locust
//=============================================================================
// HRG Locust projectile
//=============================================================================
// Killing Floor 2
// Copyright (C) 2022 Tripwire Interactive LLC
//
//=============================================================================
class KFProj_HRG_Locust extends KFProj_BallisticExplosive
	hidedropdown;

/** Our intended target actor */
var private KFPawn LockedTarget;

/** How much 'stickyness' when seeking toward our target. Determines how accurate rocket is */
var const float SeekStrength;

replication
{
	if( bNetInitial )
		LockedTarget;
}

function SetLockedTarget( KFPawn NewTarget )
{
	LockedTarget = NewTarget;
}

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

simulated event Tick( float DeltaTime )
{
	local vector TargetImpactPos, DirToTarget;

	super.Tick( DeltaTime );

	// Skip the first frame, then start seeking
	if( !bHasExploded
		&& LockedTarget != none
		&& Physics == PHYS_Projectile
		&& Velocity != vect(0,0,0)
		&& LockedTarget.IsAliveAndWell()
		&& `TimeSince(CreationTime) > 0.03f )
	{
		// Grab our desired relative impact location from the weapon class
		TargetImpactPos = class'KFWeap_HRG_Locust'.static.GetLockedTargetLoc( LockedTarget );

		// Seek towards target
		Speed = VSize( Velocity );
		DirToTarget = Normal( TargetImpactPos - Location );
		Velocity = Normal( Velocity + (DirToTarget * (SeekStrength * DeltaTime)) ) * Speed;

		// Aim rotation towards velocity every frame
		SetRotation( rotator(Velocity) );
	}
}

simulated protected function PrepareExplosionTemplate()
{
	local Weapon OwnerWeapon;
	local Pawn OwnerPawn;
	local KFPerk_Survivalist Perk;
	
	super(KFProjectile).PrepareExplosionTemplate();

	ExplosionTemplate.bIgnoreInstigator = true;

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

defaultproperties
{
	Physics=PHYS_Projectile
	Speed=4000 //6000
	MaxSpeed=4000  //6000
	TossZ=0
	GravityScale=1.0
    MomentumTransfer=0.0f

	Damage=10
	DamageRadius=0

    SeekStrength=928000.0f  // 128000.0f

	bWarnAIWhenFired=true

	ProjFlightTemplate=ParticleSystem'WEP_HRG_Locust_EMIT.FX_HRG_Locust_Projectile'
	ProjFlightTemplateZedTime=ParticleSystem'WEP_HRG_Locust_EMIT.FX_HRG_Locust_Projectile_ZED_TIME'
    ProjDisintegrateTemplate=ParticleSystem'WEP_HRG_Locust_EMIT.FX_Flying_Bugs_dispersion'

	AmbientSoundPlayEvent=AkEvent'WW_WEP_Seeker_6.Play_WEP_Seeker_6_Projectile'
  	AmbientSoundStopEvent=AkEvent'WW_WEP_Seeker_6.Stop_WEP_Seeker_6_Projectile'

	ExplosionActorClass=class'KFExplosion_HRG_Locust'

  	AltExploEffects=KFImpactEffectInfo'WEP_HRG_Locust_ARCH.FX_HRG_Locust_Explosion_Concussive_force'

	// Grenade explosion light
	Begin Object Class=PointLightComponent Name=ExplosionPointLight
	    LightColor=(R=252,G=218,B=171,A=255)
		Brightness=4.f
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
		Damage=60
		DamageRadius=200
		DamageFalloffExponent=0.5f
		DamageDelay=0.f

		//Impulse applied to Zeds
		MomentumTransferScale=1
		
		// Damage Effects
		MyDamageType=class'KFDT_Explosive_HRG_Locust'
		KnockDownStrength=0
		FractureMeshRadius=0.0
		FracturePartVel=0.0
		ExplosionEffects=KFImpactEffectInfo'WEP_HRG_Locust_ARCH.FX_HRG_Locust_Explosion_Concussive_force'
		ExplosionSound=AkEvent'WW_WEP_Seeker_6.Play_WEP_Seeker_6_Explosion'

        // Dynamic Light
        ExploLight=ExplosionPointLight
        ExploLightStartFadeOutTime=0.0
        ExploLightFadeOutTime=0.2

		// Camera Shake
		CamShake=CameraShake'FX_CameraShake_Arch.Misc_Explosions.Light_Explosion_Rumble'
		CamShakeInnerRadius=0
		CamShakeOuterRadius=500
		CamShakeFalloff=3.f
		bOrientCameraShakeTowardsEpicenter=true

		bIgnoreInstigator=true
	End Object
	ExplosionTemplate=ExploTemplate0

	bCanDisintegrate=false
}
