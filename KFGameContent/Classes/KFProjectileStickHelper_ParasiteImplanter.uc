//=============================================================================
// KFProjectileStickHelper_ParasiteImplanter
//=============================================================================
//=============================================================================
// Killing Floor 2
// Copyright (C) 2021 Tripwire Interactive LLC
//=============================================================================

class KFProjectileStickHelper_ParasiteImplanter extends KFProjectileStickHelper;

simulated function TryStick(vector HitNormal, optional vector HitLocation, optional Actor HitActor)
{
	if( WorldInfo.NetMode != NM_DedicatedServer )
	{
		`ImpactEffectManager.PlayImpactEffects(HitLocation, Instigator,, KFProj_Bullet_ParasiteImplanterAlt(Outer).ImpactEffects);
	}

	super.TryStick(HitNormal, HitLocation, HitActor);
}

/** Stops movement of projectile and calculates orientation to surface */
simulated function Stick(Actor HitActor, vector HitLocation, vector HitNormal, const out TraceHitInfo HitInfo)
{
	local int BoneIdx;

	local KFPawn_Monster HitMonster;
	local array<ImpactInfo> HitZoneImpactList;
	local vector StartTrace, EndTrace, Direction, ClosestBoneLocation;
	local name BoneName;

	BoneName = HitInfo.BoneName;

	HitMonster = KFPawn_Monster(HitActor);
	if (HitMonster != none)
	{
		// get injury hit zone
		StartTrace = HitLocation;
		Direction = Normal(Velocity);
		EndTrace = StartTrace + Direction * (HitMonster.CylinderComponent.CollisionRadius * 6.0);
		TraceProjHitZones(HitMonster, EndTrace, StartTrace, HitZoneImpactList);

		if (BoneName == '')
		{
			// get the best bone to attach to
			ClosestBoneLocation = HitMonster.Mesh.GetClosestCollidingBoneLocation(HitLocation, true, false);
			BoneName = HitMonster.Mesh.FindClosestBone(ClosestBoneLocation, ClosestBoneLocation);
		}

		// Deleted damage to monster code, we don't want to do damage on sticking
		// Bringed damage back
        if (KFWeapon(Owner) != none)
        {
			HitZoneImpactList[0].RayDir = Normal(EndTrace - StartTrace); // add a raydir here since TraceProjHitZones doesn't fill this out (so certain afflictions apply)
            KFWeapon(Owner).HandleProjectileImpact(WeaponFireMode, HitZoneImpactList[0], PenetrationPower);
        }
	}
	else if (KFPawn_Human(HitActor) != none)
	{
		// When it hits a human, use explosion.
		KFProj_Bullet_ParasiteImplanterAlt(Outer).ExplodeOnHuman(HitLocation, HitNormal, HitActor);
		return;
	}

    if (!IsZero(HitLocation))
    {

    	SetLocation(HitLocation);
    }

	SetStickOrientation(HitNormal);

	BoneIdx = INDEX_NONE;

	if (BoneName != '')
	{
		BoneIdx = GetBoneIndexFromActor(HitActor, BoneName);
	}

    StickToActor(HitActor, HitInfo.HitComponent, BoneIdx, true);

    if (Role < ROLE_Authority)
	{
		Outer.ServerStick(HitActor, BoneIdx, StuckToLocation, StuckToRotation);
	}

	if (WorldInfo.NetMode != NM_DedicatedServer && StickAkEvent != none)
	{
		PlaySoundBase(StickAkEvent);
	}
}

/** Changes the base of the charge to the stick actor and sets its relative loc/rot */
simulated function StickToActor(Actor StickTo, PrimitiveComponent HitComp, int BoneIdx, optional bool bCalculateRelativeLocRot)
{
	local SkeletalMeshComponent SkelMeshComp;
	local Name BoneName;

	local vector RelStuckToLocation;
	local rotator RelStuckToRotation;

	local KFPawn StickToPawn;
	local KFProj_Bullet_ParasiteImplanterAlt ParasiteProj;

	StickToPawn = KFPawn(StickTo);

	if (bCanPin && (StickToPawn == none || StickToPawn.bCanBePinned))
	{
		// if StickTo pawn is dead, pin it and keep flying
		if (Role == ROLE_Authority)
		{
			if (StickToPawn != none && !StickToPawn.IsAliveAndWell())
			{
				if (PinPawn == none)
				{
					Pin(StickTo, BoneIdx);
				}

				return;
			}
		}

		if (WorldInfo.NetMode != NM_DedicatedServer && PinPawn != none)
		{
			if (StickToPawn == none)
			{
				// Pin pinned pawn to StickTo actor
				//PinPawn.Mesh.RetardRBLinearVelocity(vector(Rotation), 0.75);
				PinPawn.Mesh.SetRBPosition(Location, PinBoneName);

				PinConstraint = Spawn(class'RB_ConstraintActorSpawnable',,,Location);
				PinConstraint.InitConstraint(PinPawn, none, PinBoneName, '');
			}

			PinPawn = none;
		}
	}
	else if (StickToPawn != none && !StickToPawn.IsAliveAndWell())
	{
		return;
	}

	SetPhysics(PHYS_None);

	PrevStuckToActor = StuckToActor;
	StuckToActor = StickTo;
	StuckToBoneIdx = BoneIdx;

	// if we found a skel mesh, set our base to it and set relative loc/rot
	if (BoneIdx != INDEX_NONE)
	{
		SkelMeshComp = SkeletalMeshComponent(HitComp);

		BoneName = SkelMeshComp.GetBoneName(BoneIdx);

		if (bCalculateRelativeLocRot)
		{
			StuckToLocation = Location;
			StuckToRotation = Rotation;
		}

		SkelMeshComp.TransformToBoneSpace(BoneName, StuckToLocation, StuckToRotation, RelStuckToLocation, RelStuckToRotation);

		SetBase(StickTo,, SkelMeshComp, BoneName);
		SetRelativeLocation(RelStuckToLocation);
		SetRelativeRotation(RelStuckToRotation);

	}
	// otherwise, just set our base
	else
	{
		if (bCalculateRelativeLocRot)
		{
			// set replicated loc/rot
			StuckToLocation = Location;
			StuckToRotation = Rotation;
		}
		else
		{
			// set loc/rot to replicated loc/rot
			SetLocation(StuckToLocation);
			SetRotation(StuckToRotation);
		}

		SetBase(StickTo);
	}

	ParasiteProj = KFProj_Bullet_ParasiteImplanterAlt(Outer);
	ParasiteProj.OnActorSticked(StickTo);
}

/** Resets physics/collision vars to defaults */
simulated function UnStick()
{
//	local KFPawn_Monster KFPM;

	GravityScale=0.5f;
/*
	KFPM = KFPawn_Monster(StuckToActor);
	if (KFPM != none && KFPM.Health > 0)
	{
		KFPM.ParasiteSeeds.Remove(0, KFPM.ParasiteSeeds.Length - (KFPM.MaxNumSeeds-1));
	}
*/	
	super.UnStick();
}
