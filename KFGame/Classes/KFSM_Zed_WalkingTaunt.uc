//=============================================================================
// KFSM_Zed_WalkingTaunt
//=============================================================================
// Play a taunt animation sequence
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//=============================================================================

class KFSM_Zed_WalkingTaunt extends KFSM_PlaySingleAnim;

/** The chance that we will perform a walking animation */
var float WalkingTauntChance;

protected function bool InternalCanDoSpecialMove()
{
	if( WalkingTauntChance <= FRand() )
	{
		return super.InternalCanDoSpecialMove();
	}
	return false;
}

// do not call PlaySpecialMoveAnim
function PlayAnimation()
{
	// Using the anim tree instead of playing a special move anim
	// Queue up AnimTree and abort special move.  SM is only used to replicate this action
	KFPawn_Monster(PawnOwner).WalkBlendList.QueueTauntWalk();
	PawnOwner.SetTimer(0.10f, FALSE, nameof(AbortSpecialMove), Self);
}

DefaultProperties
{
	// ---------------------------------------------
	// SpecialMove
	Handle=KFSM_WalkingTaunt
	WalkingTauntChance=0.2
	bDisablesWeaponFiring=true
}
