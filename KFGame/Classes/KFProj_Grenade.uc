//=============================================================================
// KFProj_Grenade
//=============================================================================
// Base class for grenade projectiles
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
// John "Ramm-Jaeger" Gibson
//=============================================================================

class KFProj_Grenade extends KFProjectile
	abstract
	native;

/** How long to wait until this grenade explodes */
var float FuseTime;

/** Information about grenade bounce effects for this class */
var KFImpactEffectInfo GrenadeBounceEffectInfo;

/** Dampen amount for every bounce */
var() float DampenFactor;

/** Dampen amount for parallel angle to velocity */
var() float DampenFactorParallel;

/** How much to offset the emitter mesh when the grenade has landed so that it doesn't penetrate the ground */
var() vector LandedTranslationOffset;

/** Whether or not we want to prevent this grenade from being tossed during the initial zed grab rotation. If the nade can insta kill the player, set to false */
var(Grab) bool bAllowTossDuringZedGrabRotation;

///** The UI image for this grenade.  Needed so the images have a reference and are cooked into packages. */
var() Texture2D WeaponSelectTexture;

/** Set on the server and replicated to clients. Ensures that even if Instigator isn't relevant, we still have a valid team */
var repnotify byte TeamNum;

/** Should the grenade have the upgrade values of the owning weapon. */
var bool bUpgradable;

replication
{
	if( bNetInitial && !bNetOwner )
		TeamNum;
}

/* epic ===============================================
* ::ReplicatedEvent
*
* Called when a variable with the property flag "RepNotify" is replicated
*
* =====================================================
*/
simulated event ReplicatedEvent( name VarName )
{
	if( VarName == nameOf(TeamNum) )
	{
		EnableGrenadeWarning();
	}
	else
	{
		super.ReplicatedEvent( VarName );
	}
}

event PreBeginPlay()
{
	super.PreBeginPlay();

	if( Instigator != none )
	{
		TeamNum = Instigator.GetTeamNum();
	}
}

/**
 * Set the initial velocity and cook time
 */
simulated event PostBeginPlay()
{
	Super.PostBeginPlay();

	RandSpin(100000);

	if( Role == ROLE_Authority )
	{
	   SetTimer(FuseTime, false, 'ExplodeTimer');
	}

	AdjustCanDisintigrate();
}

/**
 * Spawns any effects needed for the flight of this projectile
 */
simulated function SpawnFlightEffects()
{
	super.SpawnFlightEffects();

	// Enable the warning on listen servers (and standalone technically, but likely not used)
	if( WorldInfo.Role == ROLE_Authority )
	{
		EnableGrenadeWarning();
	}
}

/** Toggles an emitter in the projectile effects particle system to display a warning sprite */
simulated function EnableGrenadeWarning()
{
	local PlayerController LocalPC;

	if( ProjEffects == none || GetTeamNum() != 0 )
	{
		return;
	}

	LocalPC = GetALocalPlayerController();
	if( LocalPC != none && !LocalPC.IsSpectating() && LocalPC.GetTeamNum() != GetTeamNum() )
	{
		ProjEffects.SetFloatParameter( 'Warning' , 0.75f );
	}
}

/** Override so we can grab our replicated TeamNum */
simulated function byte GetTeamNum()
{
	if( !bNetOwner )
	{
		return TeamNum;
	}

	return super.GetTeamNum();
}

/**
 * Explode after a certain amount of time
 */
function ExplodeTimer()
{
    local Actor HitActor;
    local vector HitLocation, HitNormal;

    GetExplodeEffectLocation(HitLocation, HitNormal, HitActor);

    TriggerExplosion(HitLocation, HitNormal, HitActor);
}

simulated function Destroyed()
{
    local Actor HitActor;
    local vector HitLocation, HitNormal;

	// Final Failsafe check for explosion effect
	if (!bHasExploded && !bHasDisintegrated)
	{
		GetExplodeEffectLocation(HitLocation, HitNormal, HitActor);
        TriggerExplosion(HitLocation, HitNormal, HitActor);
	}

	super.Destroyed();
}

/**
 * Trace down and get the location to spawn the explosion effects and decal
 */
simulated function GetExplodeEffectLocation(out vector HitLocation, out vector HitRotation, out Actor HitActor)
{
    local vector EffectStartTrace, EffectEndTrace;
	local TraceHitInfo HitInfo;

	EffectStartTrace = Location + vect(0,0,1) * 4.f;
	EffectEndTrace = EffectStartTrace - vect(0,0,1) * 32.f;

    // Find where to put the decal
	HitActor = Trace(HitLocation, HitRotation, EffectEndTrace, EffectStartTrace, false,, HitInfo, TRACEFLAG_Bullet);

	// If the locations are zero (probably because this exploded in the air) set defaults
    if( IsZero(HitLocation) )
    {
        HitLocation = Location;
    }

	if( IsZero(HitRotation) )
    {
        HitRotation = vect(0,0,1);
    }
}

/**
 * Give a little bounce
 */
simulated event HitWall(vector HitNormal, Actor Wall, PrimitiveComponent WallComp)
{
	// check to make sure we didn't hit a pawn
	if ( Pawn(Wall) != none )
	{
		return;
	}

    Bounce( HitNormal, Wall );

	// if we are moving too slowly stop moving and lay down flat
	// also, don't allow rest on -Z surfaces.
	if ( Speed < 40 && HitNormal.Z > 0 )
	{
		ImpactedActor = Wall;
		GrenadeIsAtRest();
	}
}

/** Adjusts movement/physics of projectile.
  * Returns true if projectile actually bounced / was allowed to bounce */
simulated function bool Bounce( vector HitNormal, Actor BouncedOff )
{
	local vector VNorm;

	if ( WorldInfo.NetMode != NM_DedicatedServer )
    {
        // do the impact effects
    	`ImpactEffectManager.PlayImpactEffects(Location, Instigator, HitNormal, GrenadeBounceEffectInfo, true );
    }

    // Reflect off BouncedOff w/damping
    VNorm = (Velocity dot HitNormal) * HitNormal;
    Velocity = -VNorm * DampenFactor + (Velocity - VNorm) * DampenFactorParallel;
    Speed = VSize(Velocity);

	// also done from ProcessDestructibleTouchOnBounce. update LastBounced to solve problem with bouncing rapidly between world/non-world geometry
	LastBounced.Actor = BouncedOff;
	LastBounced.Time = WorldInfo.TimeSeconds;

	return true;
}

/** Called once the grenade has finished moving */
simulated event GrenadeIsAtRest()
{
    local rotator NewRotation;
	SetPhysics(PHYS_None);

	if( ProjEffects != none )
	{
        ProjEffects.SetTranslation(LandedTranslationOffset);
    }

	RotationRate.Yaw = 0;
	RotationRate.Pitch = 0;
	RotationRate.Roll = 0;
	NewRotation.Pitch=16384;
	SetRotation(NewRotation);
}

/** Overriding so that the grenade doesn't take on the  */
simulated protected function PrepareExplosionTemplate()
{
	local Weapon OwnerWeapon;
	local KFPawn_Human OwnerPawn;

	if (bUpgradable)
	{
		super.PrepareExplosionTemplate();
	}
	else
	{
		GetRadialDamageValues(ExplosionTemplate.Damage, ExplosionTemplate.DamageRadius, ExplosionTemplate.DamageFalloffExponent);

		OwnerWeapon = Weapon(Owner);
		if (OwnerWeapon != none)
		{
			OwnerPawn = KFPawn_Human(OwnerWeapon.Owner);
			if (OwnerPawn != none)
			{
				ExplosionTemplate.DamageRadius *= OwnerPawn.GetPerk().GetAoERadiusModifier();
			}
		}
	}
}

//==============
// Touching
simulated function ProcessTouch(Actor Other, Vector HitLocation, Vector HitNormal)
{
	if ( Other != none && Other != Instigator && (!Other.bWorldGeometry || !Other.bStatic) )
	{
		if ( Pawn(other) != None )
		{
            // For opposing team, make the grenade stop and just start falling
			if( Pawn(Other).GetTeamNum() != GetTeamNum() )
			{
				// Setting SetCollision makes the grenade undetectable by the Siren's scream, so instead
				// disable Touch & HitWall event notifications. If there's a problem with using execDisable, we
				// can add a new flag instead, like "bStopBounce" to exit ProcessTouch & HitWall early if true.
				// Events with indices between NAME_PROBEMIN and NAME_PROBEMAX can be enabled/disabled.
				Disable( 'Touch' );

				Velocity = Vect(0,0,0);
			}
		}
		else if ( !Other.bCanBeDamaged && Other.bBlockActors )
		{
			// Not a destructible... treat as if it's bWorldGeometry=TRUE
			// e.g. SkeletalMeshActor
			if ( !CheckRepeatingTouch(Other) )
			{
				HitWall(HitNormal, Other, LastTouchComponent);
			}
		}
		else
		{
			ProcessDestructibleTouchOnBounce( Other, HitLocation, HitNormal );
		}
	}
}

defaultproperties
{
	Physics=PHYS_Falling
	Speed=2500
	MaxSpeed=2500
	TossZ=250
	bBounce=true
    DampenFactor=0.250000
    DampenFactorParallel=0.400000
    LandedTranslationOffset=(X=2)

	bCollideComplex=TRUE	// Ignore simple collision on StaticMeshes, and collide per poly

    TeamNum=128 // Set to a value none of our teams use

	// CollideActors=true allows detection via OverlappingActors or CollidingActors (for Siren scream)
	Begin Object Name=CollisionCylinder
		CollisionRadius=10.f
		CollisionHeight=10.f
		BlockNonZeroExtent=false
		CollideActors=true
	End Object

    GrenadeBounceEffectInfo=KFImpactEffectInfo'FX_Impacts_ARCH.DefaultGrenadeImpacts'

	// Grenade explosion light
	Begin Object Class=PointLightComponent Name=ExplosionPointLight
	    LightColor=(R=252,G=218,B=171,A=255)
		Brightness=4.f
		Radius=2000.f
		FalloffExponent=10.f
		CastShadows=False
		CastStaticShadows=FALSE
		CastDynamicShadows=False
		bEnabled=FALSE
		LightingChannels=(Indoor=TRUE,Outdoor=TRUE,bInitialized=TRUE)
	End Object

	// network
	bNetTemporary=False
	bAlwaysReplicateExplosion=true
	bAlwaysReplicateDisintegration=true
	AlwaysRelevantDistanceSquared=6250000 // 25m

	// gameplay
	FuseTime=2.0
	bBlockedByInstigator=false
	bCanDisintegrate=true
	TouchTimeThreshhold=0.15
	GlassShatterType=FMGS_ShatterAll
	bAllowTossDuringZedGrabRotation=false

	bUpgradable=false
}

