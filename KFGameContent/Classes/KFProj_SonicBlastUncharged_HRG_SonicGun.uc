//=============================================================================
// KFProj_SonicBlastUncharged_HRG_SonicGun
//=============================================================================
// HRG Sonic Gun sonic projectile for default fire
//=============================================================================
// Killing Floor 2
// Copyright (C) 2020 Tripwire Interactive LLC
//=============================================================================
class KFProj_SonicBlastUncharged_HRG_SonicGun extends KFProj_Bullet;

`define SONICBLASTUNCHARGED_COLLISION 45.0

var bool bDebugShowProjectile;
var bool bDebugPersistentLines;

/**
 * Initialize the Projectile
 */
function Init(vector Direction)
{
    super(KFProjectile).Init( Direction );
}

simulated function SpawnFlightEffects()
{
	super.SpawnFlightEffects();
	//TODO: Remove. Temporal to see change in FX
	ProjEffects.SetScale( 3.5 ); //5.0
}

simulated event Tick(float DeltaTime)
{
	//cylinders debug
	//local vector A, B;
	//A = Location;
	//B.X = `SONICBLASTUNCHARGED_COLLISION;
	//B.Y = `SONICBLASTUNCHARGED_COLLISION;
	//B.Z = `SONICBLASTUNCHARGED_COLLISION;
	//DrawDebugBox( A, B, 255, 255, 0, bDebugPersistentLines); // SLOW! Use for debugging only!
}

simulated function ProcessTouch(Actor Other, Vector HitLocation, Vector HitNormal)
{
	super.ProcessTouch(Other, HitLocation, HitNormal);
	if (PenetrationPower <= 0)
	{
		Shutdown();
	}
}

defaultproperties
{
	bDebugShowProjectile=true
	bDebugPersistentLines=false
	ProjFlightTemplate = ParticleSystem'WEP_HRG_SonicGun_EMIT.FX_Projectile'
	ProjFlightTemplateZedTime = ParticleSystem'WEP_HRG_SonicGun_EMIT.FX_Projectile'
	ImpactEffects = KFImpactEffectInfo'WEP_HRG_SonicGun_ARCH.HRG_SonicGun_Projectile_Impacts'

	bWarnAIWhenFired=true

    Lifespan=1.3 //1.5 //1.25
	TouchTimeThreshhold=0.4

	MaxSpeed=2000.0 //1400.0
	Speed=2000.0 //1400.0
	TerminalVelocity=1800

	Physics=PHYS_Projectile

    GravityScale=0.0//0.7

	GlassShatterType=FMGS_ShatterAll

	bCollideComplex=false
	bCollideActors=true
	
	bBlockedByInstigator=false
	bAlwaysReplicateExplosion=true

	bNetTemporary=false
	NetPriority=5
	NetUpdateFrequency=200

	bNoReplicationToInstigator=false
	bUseClientSideHitDetection=true
	bUpdateSimulatedPosition=true
	bSyncToOriginalLocation=true
	bSyncToThirdPersonMuzzleLocation=true

	PinBoneIdx=INDEX_None

	bCanBeDamaged=false
	bCanDisintegrate=false
	bIgnoreFoliageTouch=true
	Begin Object Name=CollisionCylinder
		CollisionRadius=0.f
		CollisionHeight=0.f
		BlockNonZeroExtent=false
		BlockZeroExtent=true
		// for siren scream
		CollideActors=true
	End Object
  	// Since we're still using an extent cylinder, we need a line at 0
	ExtraLineCollisionOffsets.Add(())
  	ExtraLineCollisionOffsets.Add((Y = -`SONICBLASTUNCHARGED_COLLISION))
	ExtraLineCollisionOffsets.Add((Y = `SONICBLASTUNCHARGED_COLLISION))
	ExtraLineCollisionOffsets.Add((Z = `SONICBLASTUNCHARGED_COLLISION))
	ExtraLineCollisionOffsets.Add((Z = -`SONICBLASTUNCHARGED_COLLISION))
	ExtraLineCollisionOffsets.Add((Y = `SONICBLASTUNCHARGED_COLLISION, Z = `SONICBLASTUNCHARGED_COLLISION))
	ExtraLineCollisionOffsets.Add((Y = -`SONICBLASTUNCHARGED_COLLISION, Z = `SONICBLASTUNCHARGED_COLLISION))
	ExtraLineCollisionOffsets.Add((Y = `SONICBLASTUNCHARGED_COLLISION, Z = -`SONICBLASTUNCHARGED_COLLISION))
	ExtraLineCollisionOffsets.Add((Y = -`SONICBLASTUNCHARGED_COLLISION, Z = -`SONICBLASTUNCHARGED_COLLISION))

	ProjDisintegrateTemplate=ParticleSystem'ZED_Siren_EMIT.FX_Siren_grenade_disable_01'

	AssociatedPerkClass=class'KFPerk_Sharpshooter'
}