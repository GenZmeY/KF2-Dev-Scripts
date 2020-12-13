//=============================================================================
// KFSM_BloatKingSubspawn_Explode
//=============================================================================
// BK poop death explosion.  On animation finish, triggers pawn explosion.
//=============================================================================
// Killing Floor 2
// Copyright (C) 2017 Tripwire Interactive LLC
//=============================================================================
class KFSM_BloatKingSubspawn_Explode extends KFSM_PlaySingleAnim;

var float AnimLength;
var float AnimTicked;

function Tick(float DeltaTime)
{
	local KFPawn_Monster OwnerMonster;

	super.Tick(DeltaTime);

	if (AnimLength > 0)
	{
		AnimTicked += DeltaTime;
		AnimTicked = FClamp(AnimTicked, 0.f, AnimLength);

		OwnerMonster = KFPawn_Monster(KFPOwner);
		if(OwnerMonster != none)
		{
			OwnerMonster.RepInflateMatParams.RepInflateMatParam = Max(OwnerMonster.RepInflateMatParams.RepInflateMatParam, FloatToByte(AnimTicked / AnimLength));
			OwnerMonster.RepInflateMatParams.Count += 1;
			OwnerMonster.HandleDamageInflation();
		}
	}
}

function SpecialMoveStarted(bool bForced, Name PrevMove)
{
	Super.SpecialMoveStarted(bForced, PrevMove);

	AnimLength = KFPOwner.Mesh.GetAnimLength(AnimName);
}

function SpecialMoveEnded(Name PrevMove, Name NextMove)
{
	super.SpecialMoveEnded(PrevMove, NextMove);

	if (KFPawn_ZedBloatKingSubspawn(KFPOwner) != none)
	{
		KFPawn_ZedBloatKingSubspawn(KFPOwner).DelayExplode();
	}
}

defaultproperties
{
	Handle=KFSM_BloatKingSubspawn_Explode
	AnimName=Atk_Explode
	AnimStance=EAS_FullBody
	bDisableSteering=true
    bDisableMovement=true
    bDisableTurnInPlace=true
	bLockPawnRotation=true
    bCanBeInterrupted=false
    CustomRotationRate=(Pitch=0, Yaw=0, Roll=0)
}