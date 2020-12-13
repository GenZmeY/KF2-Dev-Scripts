//=============================================================================
// KFProj_MolotovSplash
//=============================================================================
// Projectile class for molotov "splash" residual flames. This projectile's explosion
// is smaller and dimmer than KFProj_MolotoveGrenade, but it lingers.
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
// - Jeff Robinson
//=============================================================================

class KFProj_MolotovSplash extends KFProjectile;

/** Blow up on impact */
simulated event HitWall(vector HitNormal, Actor Wall, PrimitiveComponent WallComp)
{
	if( StaticMeshComponent(WallComp) != none && StaticMeshComponent(WallComp).CanBecomeDynamic() )
	{
		// pass through meshes that can move
		return;
	}

	Explode( Location, HitNormal );
}

/** Blow up on impact */
simulated function ProcessTouch( Actor Other, Vector HitLocation, Vector HitNormal )
{
	if( Other.bBlockActors )
	{
		// don't hit pawns because we don't want to see floating flames when the victim pawn dies
		if ( Pawn(Other) != None )
		{
           return;
		}

		// don't hit client-side destructible actors
		// @todo: maybe don't hit any destructibles for the same reason we don't hit pawns (floating flames when destroyed)?
		if( KFDestructibleActor(Other) != none && KFDestructibleActor(Other).ReplicationMode == RT_ClientSide )
		{
			return;
		}

		Explode( Location, HitNormal );
	}
}

/** Overridden to adjust particle system for different surface orientations (wall, ceiling)
  * and nudge location
  */
simulated protected function PrepareExplosionActor(GameExplosionActor GEA)
{
	local KFExplosion_Molotov KFEM;
	local vector ExplosionDir;

	super.PrepareExplosionActor( GEA );

	// KFProjectile::Explode gives GEA a "nudged" location of 32 units, but it's too much, so use a smaller nudge
	GEA.SetLocation( Location + vector(GEA.Rotation) * 10 );

	KFEM = KFExplosion_Molotov( GEA );
	if( KFEM != none )
	{
		ExplosionDir = vector( KFEM.Rotation );

		if( ExplosionDir.Z < -0.95 )
		{
			// ceiling
			KFEM.LoopingParticleEffect = KFEM.default.LoopingParticleEffectCeiling;
		}
		else if( ExplosionDir.Z < 0.05 )
		{
			// wall
			KFEM.LoopingParticleEffect = KFEM.default.LoopingParticleEffectWall;
		}
		// else floor
	}
}

/** 
* Use alternative explosion effects when Ground Fire Perk is active
*/
simulated function PostBeginPlay()
{
	local KFPlayerReplicationInfo InstigatorPRI;

	if( AltExploEffects != none && Instigator != none )
	{
		InstigatorPRI = KFPlayerReplicationInfo(Instigator.PlayerReplicationInfo);
		if( InstigatorPRI != none )
		{
			bAltExploEffects = InstigatorPRI.bSplashActive;
		}
	}
	else
	{
		bAltExploEffects = false;
	}

	super.PostBeginPlay();
}

/**
 * Force the fire not to burn the instigator, since setting it in the default props is not working for some reason - Ramm
 * Use the alternative FX for the Ground Fire Perk Skill - Tulio
 */
simulated protected function PrepareExplosionTemplate()
{
	ExplosionTemplate.bIgnoreInstigator=true;
    super.PrepareExplosionTemplate();
	
	if( bAltExploEffects )
	{
		ExplosionTemplate.ExplosionEffects = AltExploEffects;
	}
}

defaultproperties
{
	Physics=PHYS_Falling

	bCollideComplex=TRUE	// Ignore simple collision on StaticMeshes, and collide per poly

	// network
	bNetTemporary=False
	bAlwaysReplicateExplosion=true
	AlwaysRelevantDistanceSquared=6250000 // 25m

	// gameplay
	bBlockedByInstigator=false
	GlassShatterType=FMGS_ShatterNone

	// audio
	bStopAmbientSoundOnExplode=false
    bAutoStartAmbientSound=true
    bAmbientSoundZedTimeOnly=false

    AmbientSoundPlayEvent=AkEvent'WW_WEP_SA_Flamethrower.Play_WEP_SA_Flamethrower_Residual_Fire_Loop'
    AmbientSoundStopEvent=AkEvent'WW_WEP_SA_Flamethrower.Stop_WEP_SA_Flamethrower_Residual_Fire_Loop'

    Begin Object Class=AkComponent name=AmbientAkSoundComponent
    	bStopWhenOwnerDestroyed=true
    	bForceOcclusionUpdateInterval=true
        OcclusionUpdateInterval=0.25;
    End Object
    AmbientComponent=AmbientAkSoundComponent
    Components.Add(AmbientAkSoundComponent)

    // light
	Begin Object Class=PointLightComponent Name=FlamePointLight
	    LightColor=(R=245,G=190,B=140,A=255)
		Brightness=2.f
		Radius=300.f
		FalloffExponent=10.f
		CastShadows=False
		CastStaticShadows=FALSE
		CastDynamicShadows=FALSE
		bCastPerObjectShadows=false
		bEnabled=FALSE
		LightingChannels=(Indoor=TRUE,Outdoor=TRUE,bInitialized=TRUE)
	End Object

	// explosion
	Begin Object Class=KFGameExplosion Name=ExploTemplate0
		Damage=10
		DamageRadius=150
		DamageFalloffExponent=1.f
		DamageDelay=0.f
		// Don't burn the guy that tossed it, it's just too much damage with multiple fires, its almost guaranteed to kill the guy that tossed it
        bIgnoreInstigator=true

		MomentumTransferScale=1

		// Damage Effects
		MyDamageType=class'KFDT_Fire_Ground_MolotovGrenade'
		KnockDownStrength=0
		FractureMeshRadius=0
		ExplosionEffects=KFImpactEffectInfo'wep_molotov_arch.Molotov_GroundFire'

		bDirectionalExplosion=true

		// Camera Shake
		CamShake=none

		// Dynamic Light
        ExploLight=FlamePointLight
        ExploLightStartFadeOutTime=4.2
        ExploLightFadeOutTime=0.3
	End Object
	ExplosionTemplate=ExploTemplate0

	ProjFlightTemplate=ParticleSystem'WEP_3P_Molotov_EMIT.FX_Molotov_Grenade_Spread_01'
	ExplosionActorClass=class'KFExplosion_Molotov'

	AssociatedPerkClass=class'KFPerk_Firebug'

	// Ground Fire Perk Skill Alternative FX
    AltExploEffects=KFImpactEffectInfo'WEP_Flamethrower_ARCH.GroundFire_Splash_Impacts'
}
