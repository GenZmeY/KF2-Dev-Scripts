//=============================================================================
// KFProj_Husk_Fireball
//=============================================================================
// Husk's fireball projectile
//=============================================================================
// Killing Floor 2
// Copyright (C) 2016 Tripwire Interactive LLC
//=============================================================================
class KFProj_Husk_Fireball extends KFProjectile;

/** How long the ground fire should stick around */
var const protected float BurnDuration;

/** How often, in seconds, we should apply burn */
var const protected float BurnDamageInterval;

/** Explosion actor class to use for ground fire */
var const protected class<KFExplosionActorLingering> GroundFireExplosionActorClass;

/** Determines if the ground fire explosion will spawn */
var bool bSpawnGroundFire;

/** Explosion template to use for ground fire */
var KFGameExplosion GroundFireExplosionTemplate;

replication
{
	if( bNetInitial )
		bSpawnGroundFire;
}

simulated function ProcessTouch(Actor Other, Vector HitLocation, Vector HitNormal)
{
	local KFPawn_Monster KFPM;

	if (Role < ROLE_Authority)
	{
		return;
	}

	KFPM = KFPawn_Monster(Other);

	if (KFPM != none && (KFPM.IsDoingSpecialMove(SM_Knockdown) || !KFPM.IsAliveAndWell()))
	{
		return;
	}

	super.ProcessTouch(Other, HitLocation, HitNormal);
}

/** Both explosions should ignore the instigator for damage */
simulated protected function PrepareExplosionTemplate()
{
	super.PrepareExplosionTemplate();

	/** Since bIgnoreInstigator is transient, its value must be defined here */
	ExplosionTemplate.bIgnoreInstigator = true;
	GroundFireExplosionTemplate.bIgnoreInstigator = true;
}

/** Spawn our groundfire explosion */
simulated function TriggerExplosion( Vector HitLocation, Vector HitNormal, Actor HitActor )
{
	local KFExplosionActorLingering GFExplosionActor;

	if( bHasDisintegrated )
	{
		return;
	}

	if( !bHasExploded && bSpawnGroundFire )
	{
		// Spawn our explosion and set up its parameters
	    GFExplosionActor = Spawn( GroundFireExplosionActorClass, self,, HitLocation + (HitNormal * 32.f), rotator(HitNormal) );
		if (GFExplosionActor != None)
		{
			GFExplosionActor.Instigator = Instigator;
			GFExplosionActor.InstigatorController = InstigatorController;

			// These are needed for the decal tracing later in GameExplosionActor.Explode()
			GroundFireExplosionTemplate.HitLocation = HitLocation;
			GroundFireExplosionTemplate.HitNormal = HitNormal;

			// Apply explosion direction
			if( GroundFireExplosionTemplate.bDirectionalExplosion )
			{
				HitNormal = GetExplosionDirection( HitNormal );
			}

			// Set our duration
			GFExplosionActor.MaxTime = BurnDuration;

			// Set our burn interval
			GFExplosionActor.Interval = BurnDamageInterval;

			// Boom
			GFExplosionActor.Explode( GroundFireExplosionTemplate, HitNormal );
		}
	}

	super.TriggerExplosion( HitLocation, HitNormal, HitActor );
}

DefaultProperties
{
	Physics=PHYS_Projectile
	// Speeds below are overridden by KFPawn_ZedHusk FireballSpeed property
	Speed=1800
	MaxSpeed=1800
	//MyDamageType=class'KFDT_Explosive_FragGrenade'
	ProjFlightTemplate=ParticleSystem'ZED_Husk_EMIT.FX_Husk_projectile_01'
	ExplosionActorClass=class'KFExplosionActor'

    bCollideComplex=true	// Ignore simple collision on StaticMeshes, and collide per poly
	bBlockedByInstigator=false

	bNetTemporary=False
	bAlwaysReplicateExplosion=true

	// Grenade explosion light
	Begin Object Class=PointLightComponent Name=ExplosionPointLight
	    LightColor=(R=245,G=190,B=140,A=255)
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
		Damage=25
		DamageRadius=300
		DamageFalloffExponent=1.f
		DamageDelay=0.f

		// Damage Effects
		MyDamageType=class'KFDT_Fire_HuskFireball'
		MomentumTransferScale=60000.f
		KnockDownStrength=100
		FractureMeshRadius=200.0
		FracturePartVel=500.0
		ExplosionEffects=KFImpactEffectInfo'FX_Impacts_ARCH.Explosions.HuskProjectile_Explosion'
		ExplosionSound=AkEvent'WW_ZED_Husk.ZED_Husk_SFX_Ranged_Shot_Impact'

        // Dynamic Light
        ExploLight=ExplosionPointLight
        ExploLightStartFadeOutTime=0.0
        ExploLightFadeOutTime=0.5

		// Camera Shake
		CamShake=CameraShake'FX_CameraShake_Arch.Misc_Explosions.HuskFireball'
		CamShakeInnerRadius=450
		CamShakeOuterRadius=900
		CamShakeFalloff=1.f
		bOrientCameraShakeTowardsEpicenter=true
	End Object
	ExplosionTemplate=ExploTemplate0

	// Ground fire
	BurnDuration=4.f
	BurnDamageInterval=0.5f
	GroundFireExplosionActorClass=class'KFExplosion_HuskFireballGroundFire'

	// Fire light
	Begin Object Class=PointLightComponent Name=FlamePointLight
	    LightColor=(R=245,G=190,B=140,A=255)
		Brightness=4.f
		Radius=500.f
		FalloffExponent=10.f
		CastShadows=False
		CastStaticShadows=FALSE
		CastDynamicShadows=TRUE
		bCastPerObjectShadows=false
		bEnabled=FALSE
		LightingChannels=(Indoor=TRUE,Outdoor=TRUE,bInitialized=TRUE)
	End Object

	Begin Object Class=KFGameExplosion Name=ExploTemplate1
		Damage=3
		DamageRadius=150
		DamageFalloffExponent=1.f
		DamageDelay=0.f
		// Don't burn the guy that tossed it, it's just too much damage with multiple fires, its almost guaranteed to kill the guy that tossed it
        bIgnoreInstigator=true

		MomentumTransferScale=0

		// Damage Effects
		MyDamageType=class'KFDT_Fire_ZedGround'
		KnockDownStrength=0
		FractureMeshRadius=0
		ExplosionEffects=KFImpactEffectInfo'wep_molotov_arch.Molotov_GroundFire'

		bDirectionalExplosion=true

		// Camera Shake
		CamShake=none

		// Dynamic Light
        ExploLight=FlamePointLight
        ExploLightStartFadeOutTime=1.5f
        ExploLightFadeOutTime=0.3
	End Object
	GroundFireExplosionTemplate=ExploTemplate1

	Begin Object Class=AkComponent name=AmbientAkSoundComponent
		bStopWhenOwnerDestroyed=true
        bForceOcclusionUpdateInterval=true
        OcclusionUpdateInterval=0.1f
    End Object
    AmbientComponent=AmbientAkSoundComponent
    Components.Add(AmbientAkSoundComponent)

	bAutoStartAmbientSound=true
	bStopAmbientSoundOnExplode=true
	AmbientSoundPlayEvent=AkEvent'WW_ZED_Husk.ZED_Husk_SFX_Ranged_Shot_LP'
    AmbientSoundStopEvent=AkEvent'WW_ZED_Husk.ZED_Husk_SFX_Ranged_Shot_LP_Stop'
}
