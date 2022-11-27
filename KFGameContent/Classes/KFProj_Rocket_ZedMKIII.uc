//=============================================================================
// KFProj_Rocket_ZedMKIII
//=============================================================================
// KFProj_Rocket_ZedMKIII rocket
//=============================================================================
// Killing Floor 2
// Copyright (C) 2022 Tripwire Interactive LLC
//=============================================================================
class KFProj_Rocket_ZedMKIII extends KFProj_BallisticExplosive
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
		TargetImpactPos = class'KFWeap_ZedMKIII'.static.GetLockedTargetLoc( LockedTarget );

		// Seek towards target
		Speed = VSize( Velocity );
		DirToTarget = Normal( TargetImpactPos - Location );
		Velocity = Normal( Velocity + (DirToTarget * (SeekStrength * DeltaTime)) ) * Speed;

		// Aim rotation towards velocity every frame
		SetRotation( rotator(Velocity) );
	}
}

defaultproperties
{
	Physics=PHYS_Projectile
	Speed=4000 //6000
	MaxSpeed=4000  //6000
	TossZ=0
	GravityScale=1.0
    MomentumTransfer=50000.0f
	ArmDistSquared=110000.0f //20000.0f // 110000.0f // 4 meters 150000.0
    
    SeekStrength=928000.0f  // 128000.0f

	bWarnAIWhenFired=true

	ProjFlightTemplate=ParticleSystem'WEP_ZEDMKIII_EMIT.FX_ZEDMKIII_Rocket'
	ProjFlightTemplateZedTime=ParticleSystem'WEP_ZEDMKIII_EMIT.FX_ZEDMKIII_Rocket_ZED_TIME'
	ProjDudTemplate=ParticleSystem'WEP_ZEDMKIII_EMIT.FX_ZEDMKIII_Rocket_Dud'
	GrenadeBounceEffectInfo=KFImpactEffectInfo'WEP_RPG7_ARCH.RPG7_Projectile_Impacts'
    ProjDisintegrateTemplate=ParticleSystem'ZED_Siren_EMIT.FX_Siren_grenade_disable_01'

	AmbientSoundPlayEvent=AkEvent'WW_WEP_ZEDMKIII.Play_WEP_ZEDMKIII_Rocket_LP'
  	AmbientSoundStopEvent=AkEvent'WW_WEP_ZEDMKIII.Stop_WEP_ZEDMKIII_Rocket_LP'

  	AltExploEffects=KFImpactEffectInfo'WEP_ZEDMKIII_ARCH.FX_ZEDMKIII_Explosion_Concussive_force'

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
		Damage=200
		DamageRadius=300
		DamageFalloffExponent=2
		DamageDelay=0.f

		// Damage Effects
		MyDamageType=class'KFDT_Explosive_ZedMKIII'
		KnockDownStrength=0
		FractureMeshRadius=200.0
		FracturePartVel=500.0
		ExplosionEffects=KFImpactEffectInfo'WEP_ZEDMKIII_ARCH.FX_ZEDMKIII_Explosion'
		ExplosionSound=AkEvent'WW_WEP_ZEDMKIII.Play_WEP_ZEDMKIII_Explosion'

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
	End Object
	ExplosionTemplate=ExploTemplate0
}
