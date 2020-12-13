//=============================================================================
// KFProjectileStickHelper_HRGScorcher
//=============================================================================
// Manages projectile sticking and pinning functionality for HRG Scorcher primary fire.
// Overriding stick functionality to not do any damage
//=============================================================================
// Killing Floor 2
// Copyright (C) 2020 Tripwire Interactive LLC
//=============================================================================

class KFProjectileStickHelper_HRGScorcher extends KFProjectileStickHelper;

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

		//Deleted damage to monster code, we don't want to do damage on sticking
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

simulated function bool GetImpactResult(Actor HitActor, PrimitiveComponent HitComp)
{
	local KFPawn_Human KFP;
	local KFDestructibleActor D;
	local StaticMeshComponent StaticMeshComp;

	if (HitActor == none)
	{

		return true;
	}


	if (HitActor.RemoteRole == ROLE_None && !HitActor.bWorldGeometry && InterpActor(HitActor) == None)//Added InterpActor to be able to stick to those actors (KII-51625)
	{
		return false;
	}

	// if we've already been dislodged from an actor, don't keep trying to stick to it while falling
	if (HitActor.bTearOff || HitActor.bDeleteMe || HitActor.bPendingDelete || HitActor == PrevStuckToActor)
	{
		return false;
	}

	StaticMeshComp = StaticMeshComponent(HitComp);
	if (StaticMeshComp != none)
	{
		// NOTE: Door actors fall into this category!

		// pass through meshes that can move
		return !StaticMeshComp.CanBecomeDynamic();
	}

	KFP = KFPawn_Human(HitActor);
	if (KFP != none)
	{
		// bounce off of player pawns, stick to other pawns
		return false;
	}

	D = KFDestructibleActor(HitActor);

	if (D != none)
	{

		// don't react to client-side-only destructibles, stick to others
		return D.ReplicationMode != RT_ClientSide;
	}


	return true;
}