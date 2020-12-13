//=============================================================================
// KFSM_RangedAttack
//=============================================================================
//
//=============================================================================
// Killing Floor 2
// Copyright (C) 2018 Tripwire Interactive LLC
//=============================================================================
class KFSM_RangedAttack extends KFSM_PlaySingleAnim
	abstract;

var array<Name> AnimNames;

/** Offsets for firing fireballs. */
var array<vector> FireOffsets;

/** Set once each time move is invoked */
var transient protected vector FireOffset;

static function byte PackFlagsBase(KFPawn P)
{
	return Rand(default.AnimNames.Length);
}

protected function bool InternalCanDoSpecialMove()
{
	// Case for player-controlled Husk
	if (KFPOwner.IsHumanControlled())
	{
		return KFPOwner.IsCombatCapable();
	}

	if (AIOwner == none || AIOwner.MyKFPawn == none || AIOwner.Enemy == none)
	{
		return false;
	}

	if (!KFPOwner.IsCombatCapable())
	{
		return false;
	}

	// Make sure we have line of sight
	if (!AIOwner.DirectProjectileFireBehavior.IsThereClearDirectFireAttackLaneFromGivenLoc(PawnOwner.Location, AIOwner.Enemy))
	{
		return false;
	}

	return super.InternalCanDoSpecialMove();
}

function vector GetFireOffset()
{
	return FireOffset;
}

function SpecialMoveStarted(bool bForced, name PrevMove)
{
	super.SpecialMoveStarted(bForced, PrevMove);

	SetLockPawnRotation(false);

	if (AIOwner != none)
	{
		AIOwner.AIZeroMovementVariables();
	}
}

function PlayAnimation()
{
	local int AnimNum;

	AnimNum = Clamp(KFPOwner.SpecialMoveFlags, 0, AnimNames.Length);
	AnimName = AnimNames[AnimNum];
	FireOffset = FireOffsets[AnimNum];

	super.PlayAnimation();
}

function SpecialMoveEnded(Name PrevMove, Name NextMove)
{
	super.SpecialMoveEnded(PrevMove, NextMove);

	SetLockPawnRotation(false);
}

defaultproperties
{
	bDisableSteering=false
	bDisableMovement=true
   	bCanBeInterrupted=true
}
