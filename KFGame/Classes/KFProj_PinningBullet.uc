//=============================================================================
// KFProj_PinningBullet
//=============================================================================
// Base class for small arms projectiles that can pin zeds or zed body parts
// to walls
// Based loosely on UTProj_StingerShard Copyright 1998-2008 Epic Games, Inc.
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
// John "Ramm-Jaeger" Gibson
//=============================================================================

class KFProj_PinningBullet extends KFProj_RicochetBullet
	abstract;

/** The constraint for this projectile pinning a ragdoll or ragdoll body part to a wall */
var RB_ConstraintActor PinConstraint;

/** This is true if this projectile is currently pinning a victim */
var bool bPinned;

/** Can only create a pin effect if we aren't already being used to pin a dead pawn */
var bool bSpawnedForPin;

/**
 * This function creates the actual pin in the world.  A duplicate pinning projectile is spawned
 * and that projectile is used to pin the pawn.  We use a secondary actor in order to avoid
 * having to wait for replication to occur since this actor is spawned client-side
 */
static function bool CreatePin(KFPawn DeadPawn, vector InitialHitLocation, vector Direction, name HitBoneName)
{
	local KFProj_PinningBullet PinProjectile;
	local vector BoneLoc;
	local class<KFProj_PinningBullet> BulletClass;

	// Do nothing for now until this can be properly implemented
	return false;

	if ( DeadPawn != None && DeadPawn.WorldInfo.GRI.ShouldShowGore() && !DeadPawn.bDeleteMe && DeadPawn.Health <= 0 && DeadPawn.Physics == PHYS_RigidBody
		&& DeadPawn.Mesh != None && DeadPawn.Mesh.PhysicsAssetInstance != None && HitBoneName != '')
	{
		// Spawn a pinning projectile
		BoneLoc  = DeadPawn.Mesh.GetBoneLocation(HitBoneName);
        BulletClass = default.Class;
		PinProjectile = DeadPawn.Spawn(BulletClass,,, BoneLoc, rotator(Direction));

		if (PinProjectile != None)
		{
			// Send the projectile moving
			PinProjectile.bSpawnedForPin = True;
			PinProjectile.Init(Direction);

			// Attach the victim to this projectile
			PinProjectile.PinVictim(DeadPawn,HitBoneName);

			return true;
		}
	}

	return false;
}

/**
 * This function is responsible for creating the constraint between the projectile
 * and the victim.
 */
simulated function PinVictim(KFPawn Victim, name VictimBone)
{
	// give projectile extent so that it collides the same way the pawn does
	// (so we don't get the ragdoll stuck in a blocking volume, etc)
	bSwitchToZeroCollision = false;
	CylinderComponent.SetCylinderSize(1.0, 1.0);
	CylinderComponent.SetActorCollision(true, false);

	// Set the location of the projectile to the bone location to start with
    SetLocation(Victim.Mesh.GetBoneLocation(VictimBone));

    // Spawn the constraint that pins the ragdoll to this projectile
	PinConstraint = Spawn(class'RB_ConstraintActorSpawnable',,,Location);
	PinConstraint.SetBase(self);
	PinConstraint.InitConstraint( self, Victim, '', VictimBone, 2000.f);
	PinConstraint.LifeSpan = 8.0;

	LifeSpan = 8.0;
	bPinned = true;
}

