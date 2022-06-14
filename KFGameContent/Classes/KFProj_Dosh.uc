//=============================================================================
// KFProj_Dosh
//=============================================================================
// Projectile for the doshinegun
//=============================================================================
// Killing Floor 2
// Copyright (C) 2021 Tripwire Interactive LLC
//=============================================================================

class KFProj_Dosh extends KFProj_RicochetBullet
	hidedropdown;

`define KFPROJ_DOSH_CACHED_LOCATION 20

var PrimitiveComponent DroppedPickupMesh;

/** Dampen amount for every bounce */
var() float DampenFactor;

/** Dampen amount for parallel angle to velocity */
var() float DampenFactorParallel;

var transient Vector PreviousLocations [`KFPROJ_DOSH_CACHED_LOCATION];
var transient rotator PreviousRotations [`KFPROJ_DOSH_CACHED_LOCATION];
var transient Vector Ceiling;

// Make sure that last location always exists.
simulated event PostBeginPlay()
{
    Super.PostBeginPlay();
}

event Tick( float DeltaTime )
{
	local int i;
	for (i = `KFPROJ_DOSH_CACHED_LOCATION - 1; i > 0; --i)
	{
		PreviousLocations[i] = PreviousLocations[i-1];
		PreviousRotations[i] = PreviousRotations[i-1];
	}

	if (`KFPROJ_DOSH_CACHED_LOCATION > 0)
	{
		PreviousLocations[0] = Location;
		PreviousRotations[0] = Rotation; 
	}
}

/**
 * Give a little bounce
 */
simulated event HitWall(vector HitNormal, Actor Wall, PrimitiveComponent WallComp)
{
	local TraceHitInfo HitInfo;

	// check to make sure we didn't hit a pawn
	if( Pawn(Wall) == none )
	{
		if (!Wall.bStatic && Wall.bCanBeDamaged && (DamageRadius == 0 || bDamageDestructiblesOnTouch) && !CheckRepeatingTouch(Wall) )
		{
			HitInfo.HitComponent = WallComp;
			HitInfo.Item = INDEX_None;
			Wall.TakeDamage( Damage, InstigatorController, Location, MomentumTransfer * Normal(Velocity), MyDamageType, HitInfo, self);
		}
	}

    Bounce( HitNormal, Wall );
}

/** Adjusts movement/physics of projectile.
  * Returns true if projectile actually bounced / was allowed to bounce */
simulated function bool Bounce( vector HitNormal, Actor BouncedOff)
{
	Velocity = DampingFactor * (Velocity - 2.0*HitNormal*(Velocity dot HitNormal));
	if( WorldInfo.NetMode != NM_DedicatedServer )
	{
		// do the impact effects
		`ImpactEffectManager.PlayImpactEffects(Location, Instigator, HitNormal, ImpactEffects );
	}

	// also done from ProcessDestructibleTouchOnBounce. update LastBounced to solve problem with bouncing rapidly between world/non-world geometry
	LastBounced.Actor = BouncedOff;
	LastBounced.Time = WorldInfo.TimeSeconds;

	SpawnDosh(BouncedOff);
	Destroy();

	return true;
}

function SpawnDosh(Actor BouncedOff)
{
	local KFDroppedPickup_Cash P;
	local int i;
	local Vector Pos;
	local rotator Rot;

	if ( WorldInfo.NetMode == NM_Client )
		return;

	if (Pawn(BouncedOff) == none)
	{
		Pos = Location;
		Rot = Rotation;
		P = Spawn(class'KFDroppedPickup_Cash',,, Pos, Rot,, false);

		if (P == none)
		{
			for (i = 0; i < `KFPROJ_DOSH_CACHED_LOCATION; ++i)
			{
				Pos = PreviousLocations[i];
				Rot = PreviousRotations[i];
				P = Spawn(class'KFDroppedPickup_Cash',,, Pos, Rot,, false);
				if (P != none)
				{
					break;
				}
			}
		}

		// DrawDebugSphere( Pos, 20, 8, 0, 255, 255, true );
		if (P != none && RelocateFromCeiling(Pos))
		{
			P.Destroy();
			if(Ceiling.Z > -10000)
			{
				// DrawDebugSphere( Ceiling, 22, 8, 255, 255, 0, true );
				P = Spawn(class'KFDroppedPickup_Cash',,, Ceiling, Rot,, false);
				Velocity = vect(0,0,0);
			}
		}
	}
	else
	{
		P = Spawn(class'KFDroppedPickup_Cash',,, Location, Rotation,, true);
	}

	if( P == None )
	{
		Destroy();
	}
	else
	{
		P.SetPhysics(PHYS_Falling);
		P.InventoryClass = class'KFInventory_Money';
		P.Inventory = Instigator.CreateInventory(P.InventoryClass);
		P.Velocity = Velocity;
		P.Instigator = Instigator;
		P.SetPickupMesh(DroppedPickupMesh);
		P.SetPickupParticles(none);
		P.CashAmount = class'KFWeap_AssaultRifle_Doshinegun'.default.DoshCost;
	}

}

//==============
// Touching
// Overridden to get bouncing off of destructible meshes
simulated function ProcessTouch(Actor Other, Vector HitLocation, Vector HitNormal)
{
	local KFPawn KFP;
	local KFPawn_Human KFPH;
	local KFPlayerReplicationInfo KFPRI;
	local TraceHitInfo HitInfo;

	KFPH = KFPawn_Human(Other); 
	if ( KFPH != none && KFPH != Instigator)
	{
		KFPRI = KFPlayerReplicationInfo(KFPH.PlayerReplicationInfo);
		if (KFPRI != none)
		{
			KFPRI.AddDosh(class'KFWeap_AssaultRifle_Doshinegun'.default.DoshCost);
			Destroy();
			return;
		}
	}
	else if ( Other != Instigator && Other.bCanBeDamaged )
	{
		KFP = KFPawn( Other );
		if ( KFP != None )
		{
			// check/ignore repeat touch events
			if( CheckRepeatingTouch(Other) )
			{
				return;
			}

			ProcessBulletTouch(Other, HitLocation, HitNormal);

			Bounce(HitNormal, Other);
			return;
		}
		else
		{
	  		HitInfo.HitComponent = LastTouchComponent;
			HitInfo.Item = INDEX_None;	// force TraceComponent on fractured meshes
		    Other.TakeDamage(Damage, InstigatorController, HitLocation, MomentumTransfer * Normal(Velocity), MyDamageType, HitInfo, self);// special cases for types of destructibles, bShouldBreakSolidGlassOnBounce 
			return;
		}
	}

	super.ProcessTouch(Other, HitLocation, HitNormal);
}

simulated function SyncOriginalLocation()
{
	local Actor HitActor;
	local vector HitLocation, HitNormal;
	local TraceHitInfo HitInfo;

	if (Role < ROLE_Authority && Instigator != none && Instigator.IsLocallyControlled())
	{
		HitActor = Trace(HitLocation, HitNormal, OriginalLocation, Location,,, HitInfo, TRACEFLAG_Bullet);
		if (HitActor != none)
		{
			Bounce(HitNormal, HitActor);
		}
	}

    Super.SyncOriginalLocation();
}

simulated function bool RelocateFromCeiling(Vector Pos)
{
	local Actor HitActorVolume, HitActorWorld, HitActorVolumeBack;
	local Vector HitLocationVolume, HitLocationWorld;
	local Vector HitNormalUnused;
	
	HitActorWorld  = Owner.Trace(HitLocationWorld, HitNormalUnused, Pos - vect(0,0,10000), Pos, false,,,TRACEFLAG_Bullet);
	if(HitActorWorld != none)
	{
		HitActorVolume = KFWeapon(Owner).DoTraceNative(HitLocationVolume, Pos, Pos - vect(0,0,10000));
		if (HitActorVolume == none  || (HitLocationWorld.Z + 80) > HitLocationVolume.Z || IsZero(HitLocationVolume-Pos))
		{
			return false;
		}

		// DrawDebugSphere( HitLocationWorld , 32, 8, 0, 255, 0, true );
		// DrawDebugSphere( HitLocationVolume, 30, 8, 255, 0, 0, true );

		HitLocationWorld += vect(0,0,1);
		HitActorVolumeBack = KFWeapon(Owner).DoTraceNative(HitLocationVolume, HitLocationWorld, HitLocationWorld + vect(0,0,10000));
		if (HitActorVolumeBack != none && !IsZero(HitLocationVolume-HitLocationWorld))
		{
			// DrawDebugSphere( HitLocationVolume, 28, 8, 255, 255, 0, true );
			Ceiling = HitLocationVolume - vect(0,0,10);
			return true;
		}
	}
	Ceiling = Vect(0,0,-10000);
	return true;
}


defaultproperties
{
	MaxSpeed=7500.0 //5000.0
	Speed=7500.0 //5000.0
	GravityScale=0.57 //0.4

	Physics=PHYS_Falling
	TossZ=100 //150
	MomentumTransfer=50000.0

	DamageRadius=0

	bWarnAIWhenFired=true

    BouncesLeft=1
    DampingFactor=0.1

    DampenFactor=0.250000
    DampenFactorParallel=0.400000
    LifeSpan=120 //8

	bNetTemporary=False
	NetPriority=5
	NetUpdateFrequency=200

	ProjFlightTemplate=ParticleSystem'WEP_Doshinegun_EMIT.PS_Trail'
	ProjFlightTemplateZedTime=ParticleSystem'WEP_Doshinegun_EMIT.PS_Trail'

	ImpactEffects=KFImpactEffectInfo'WEP_Doshinegun_ARCH.Dosh_Impact'

	Begin Object Class=SkeletalMeshComponent Name=PickupMesh0
		SkeletalMesh=SkeletalMesh'GP_Mesh.dosh_SM'
		PhysicsAsset=PhysicsAsset'GP_Mesh.dosh_SM_Physics'
		BlockNonZeroExtent=false
		CastShadow=false
    End Object
    DroppedPickupMesh=PickupMesh0
}
