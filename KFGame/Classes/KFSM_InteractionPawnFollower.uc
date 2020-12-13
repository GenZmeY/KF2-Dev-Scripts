//=============================================================================
// KFSM_InteractionPawnFollower_Base
//=============================================================================
// Base class for Pawn to Pawn Interactions.
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//=============================================================================
// Based on GSM_InteractionPawnFollower_Base 
// Copyright 1998-2011 Epic Games, Inc. All Rights Reserved.
//=============================================================================

class KFSM_InteractionPawnFollower extends KFSpecialMove
	abstract;

/** Pointer to Leader */
var KFPawn Leader;
/** Keep track of special move leader is doing during this interaction. */
var protected ESpecialMove LeaderSpecialMove;

function SpecialMoveStarted(bool bForced, Name PrevMove)
{
	Super.SpecialMoveStarted(bForced, PrevMove);

	// Keep a simple reference to our Leader.
	Leader = KFPOwner.InteractionPawn;
	// Clear leader interaction special move
	LeaderSpecialMove = SM_None;
}

function OnLeaderLeavingSpecialMove()
{
	if( KFPOwner != none && KFPOwner.Role == ROLE_Authority )
	{
		KFPOwner.EndSpecialMove();
	}
}

function SpecialMoveEnded(Name PrevMove, Name NextMove)
{
	local KFSM_InteractionPawnLeader LeaderSM;

	// If Leader is still around, let him know that follower is leaving his special move
	if( Leader != None && Leader.IsDoingSpecialMove(LeaderSpecialMove) )
	{
		// Let our leader know that we're now ready to be detached from him.
		LeaderSM = KFSM_InteractionPawnLeader(Leader.SpecialMoves[LeaderSpecialMove]);
		if( LeaderSM != none )
		{
			LeaderSM.OnFollowerLeavingSpecialMove();
		}
	}

	// Clear reference to our leader.
	Leader = None;
	LeaderSpecialMove = SM_None;

	Super.SpecialMoveEnded(PrevMove, NextMove);
}

/** Messages sent to this special move */
function bool MessageEvent(Name EventName, Object Sender)
{
	if( EventName == 'InteractionStarted' )
	{
		InteractionStarted();
		return TRUE;
	}

	return Super.MessageEvent(EventName, Sender);
}

function InteractionStarted()
{
	// Keep track of what special move the leader is doing.
	LeaderSpecialMove = Leader != none ? Leader.SpecialMove : KFPOwner.InteractionPawn.SpecialMove;
}

DefaultProperties
{
}