//=============================================================================
// KFProj_Grenade_HRGIncendiaryRifle
//=============================================================================
// High explosive and incendiary grenade that on explosion leaves behind small
// patches of fire, like a molotov grenade.
//=============================================================================
// Killing Floor 2
// Copyright (C) 2019 Tripwire Interactive LLC
//=============================================================================

class KFProj_Grenade_HRGIncendiaryRifle extends KFProj_HighExplosive_M16M203;

/** Class for spawning residual flames **/
var class<KFProjectile> ResidualFlameProjClass;

/** Number of lingering flames to spawn */
var() int NumResidualFlames;

/** Explosion actor class to use for ground fire */
var const protected class<KFExplosionActorLingering> GroundFireExplosionActorClass;

/** Explosion template to use for ground fire */
var KFGameExplosion GroundFireExplosionTemplate;

/** Allows the projectile to spawn the ground fire **/
var bool bSpawnGroundFire;

var bool bUseAltGroundFireEffect;
var KFImpactEffectInfo AltGroundFireEffect;

/** Last Velocity from Explode() */
var vector LastVelocity;

replication
{
	if( bNetInitial )
		bSpawnGroundFire;
}

simulated function ProcessTouch(Actor Other, Vector HitLocation, Vector HitNormal)
{
	// Onyl spawn the ground fire if the projectile doesn't touch any pawn
	if (ClassIsChildOf(Other.class, class'KFPawn'))
	{
		bSpawnGroundFire = false;
	}

	super.ProcessTouch(Other, HitLocation, HitNormal);
}

/** Spawn several projectiles that explode and linger on impact */
function SpawnResidualFlames (vector HitLocation, vector HitNormal, vector HitVelocity)
{
	local int i;
	local vector HitVelDir;
	local float HitVelMag;
	local vector SpawnLoc, SpawnVel;

	HitVelMag = VSize (HitVelocity);
	HitVelDir = Normal (HitVelocity);

	SpawnLoc = HitLocation + (HitNormal * 10.f);

	// spawn random lingering fires (rather, projectiles that cause little fires)
	for( i = 0; i < NumResidualFlames; ++i )
	{
		SpawnVel = CalculateResidualFlameVelocity( HitNormal, HitVelDir, HitVelMag );
		SpawnResidualFlame( ResidualFlameProjClass, SpawnLoc, SpawnVel );
	}
}

// Based on HuskCannon Ground Fire TriggerExplosion:
simulated function TriggerExplosion(Vector HitLocation, Vector HitNormal, Actor HitActor)
{
	local vector FlameSpawnVel;
	local KFExplosionActorLingering GFExplosionActor;
	local vector GroundExplosionHitNormal;
	local bool bDoExplosion;

	if (bHasDisintegrated)
	{
		return;
	}

	bDoExplosion = !bHasExploded && Role == ROLE_Authority;

	if (bDoExplosion && bSpawnGroundFire)
	{
		if (bUseAltGroundFireEffect && AltGroundFireEffect != none)
		{
			GroundFireExplosionTemplate.ExplosionEffects = AltGroundFireEffect;
		}

		GroundExplosionHitNormal = HitNormal;

		// Spawn our explosion and set up its parameters
		GFExplosionActor = Spawn(GroundFireExplosionActorClass, self, , HitLocation + (HitNormal * 32.f), rotator(HitNormal));
		if (GFExplosionActor != None)
		{
			GFExplosionActor.Instigator = Instigator;
			GFExplosionActor.InstigatorController = InstigatorController;

			// These are needed for the decal tracing later in GameExplosionActor.Explode()
			GroundFireExplosionTemplate.HitLocation = HitLocation;
			GroundFireExplosionTemplate.HitNormal = GroundExplosionHitNormal;

			// Apply explosion direction
			if (GroundFireExplosionTemplate.bDirectionalExplosion)
			{
				GroundExplosionHitNormal = GetExplosionDirection(GroundExplosionHitNormal);
			}

			GFExplosionActor.Explode(GroundFireExplosionTemplate, GroundExplosionHitNormal);
		}
	}

	if (bDoExplosion)
	{
		FlameSpawnVel = 0.25f * CalculateResidualFlameVelocity(HitNormal, Normal(LastVelocity), VSize(LastVelocity));
		SpawnResidualFlames (HitLocation, HitNormal, FlameSpawnVel);
	}

	super.TriggerExplosion(HitLocation, HitNormal, HitActor);
}

simulated function Explode (vector HitLocation, vector HitNormal)
{
	LastVelocity = Velocity;
	super.Explode (HitLocation, HitNormal);
}

simulated function PostBeginPlay()
{
	local KFPlayerReplicationInfo InstigatorPRI;

	if(Instigator != none)
	{
		if (AltGroundFireEffect != none)
		{
			InstigatorPRI = KFPlayerReplicationInfo(Instigator.PlayerReplicationInfo);
			if (InstigatorPRI != none)
			{
				// Use alternative explosion effects when Ground Fire Perk is active:
				bUseAltGroundFireEffect = InstigatorPRI.bSplashActive;
			}
		}
		else
		{
			bUseAltGroundFireEffect = false;
		}
	}

	super.PostBeginPlay();
}

simulated protected function PrepareExplosionTemplate()
{
	Super.PrepareExplosionTemplate();
	// Swap the ExplosionTemplate's effect if necessary
	if( bAltExploEffects )
	{
		ExplosionTemplate.ExplosionEffects = AltExploEffects;
	}
}

defaultproperties
{
    Physics=PHYS_Falling
	ResidualFlameProjClass=class'KFProj_Flame_HRGIncendiaryRifle'
	NumResidualFlames=4

	bSpawnGroundFire=true
	GroundFireExplosionActorClass=class'KFExplosion_HRGIncendiaryRifleGroundFire'

	AltGroundFireEffect=KFImpactEffectInfo'WEP_Flamethrower_ARCH.GroundFire_Splash_Impacts'

	// From MolotovGrenade:
	Begin Object Class=PointLightComponent Name=FlamePointLight
	    LightColor=(R=245,G=190,B=140,A=255)
		Brightness=3.f
		Radius=700.f
		FalloffExponent=10.f
		CastShadows=False
		CastStaticShadows=FALSE
		CastDynamicShadows=FALSE
		bCastPerObjectShadows=false
		bEnabled=FALSE
		LightingChannels=(Indoor=TRUE,Outdoor=TRUE,bInitialized=TRUE)
	End Object

	// explosion
	Begin Object Name=ExploTemplate0
		Damage=100
		DamageRadius=500
		DamageFalloffExponent=1.f
		DamageDelay=0.f

		bIgnoreInstigator=false
	
		MomentumTransferScale=0

		// Damage Effects
		MyDamageType=class'KFDT_Explosive_HRGIncendiaryRifle'
		KnockDownStrength=0
		FractureMeshRadius=200.0
		FracturePartVel=500.0
		ExplosionEffects=KFImpactEffectInfo'wep_molotov_arch.Molotov_Explosion'
		ExplosionSound=AkEvent'WW_WEP_EXP_Grenade_Frag.Play_WEP_EXP_Grenade_Frag_Explosion'

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


	// gound fire
	Begin Object Class=KFGameExplosion Name=ExploTemplate1
		Damage=10
		DamageRadius=150
		DamageFalloffExponent=1.f
		DamageDelay=0.f

		bDirectionalExplosion=true

		MomentumTransferScale=1
		
		// Damage Effects
		MyDamageType=class'KFDT_Fire_Ground_HRGIncendiaryRifle'
		KnockDownStrength=0
		FractureMeshRadius=0
		FracturePartVel=500.0
		ExplosionEffects=KFImpactEffectInfo'wep_molotov_arch.Molotov_GroundFire'
		ExplosionSound=AkEvent'WW_WEP_EXP_MOLOTOV.Play_WEP_EXP_Molotov_Explosion'

		// Dynamic Light
		ExploLight=FlamePointLight
		ExploLightStartFadeOutTime=0.4
		ExploLightFadeOutTime=0.2

		// Camera Shake
        CamShake=none

	End Object
	GroundFireExplosionTemplate=ExploTemplate1
}
