//=============================================================================
// AICommand_SM_Attack
//=============================================================================
// Base AICommand for NPC attack commands linked to special moves
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//=============================================================================

class AICommand_SM_Attack extends AICommand_SpecialMove
	within KFAIController
	abstract
	native(AI);

/** Special move type to use for this attack */
var ESpecialMove	AttackSpecialMove;
/** If none, NPC's enemy will be used. Allows using temporary non-pawn targets, such as doors */
var actor			AttackTarget;
/** Pop this command when attack is finished - don't repeat the attack from within this command. */
var bool			bSingleAttack;
/** Extra latent time slept through when special move has completed */
var float			PostSpecialMoveSleepTime;
/** Extra latent time slept through when special move has been aborted (in case extra time is needed for blending)
 *  PostSpecialMoveSleepTime will be used if this value is 0 */
var float			PostSpecialMoveAbortedSleepTime;
/** Can this attack be aborted? */
var bool			bCanBeAborted;
/** Set to true if attack aborted, since command does not end immediately when interrupted */
var bool			bAttackAborted;
/** Time that has passed since command started, used to determine if enough time has passed
 * to allow the attack to be interrupted */
var protected float	TimePlayed;
/** Prevent NPC movement during this attack? */
var bool			bLockDownAI;
/** Zero pawn's acceleration when this command is popped */
var bool			bZeroPawnAccelWhenPopped;
/** Set when getting a valid attack anim from animgroup, and passed on to associated special move */
var byte			SMFlags;
var bool			bFinishRotationBeforeAttack;

/*********************************************************************************************
* Initialization/Resume/Pause
**********************************************************************************************/

function Pushed()
{
	Super.Pushed();
	
	if( bLockDownAI )
	{
		// Prevent latent AI movement (bPreparing move is set to true, etc.)
		LockdownAI();
	}

	// Disable incoming "in attack range" events
	DisableMeleeRangeEventProbing();

	// Do attack immediately
	GotoState( DefaultStartState );
}

/** Attack paused - currently, this should not happen! */
function Paused( GameAICommand NewCommand )
{
	//`warn( "Warning! Paused() for "$self$" - paused by "$NewCommand );

	Super( AICommand ).Paused( NewCommand );
}

function Popped()
{
	// Turn off "in range" notifications for new attacks
	if( !Outer.bHasDebugCommand )
	{
		ResetProbingMeleeRangeEvents();
	}

	if( bLockDownAI )
	{
		UnlockAI();
	}
	if( bZeroPawnAccelWhenPopped && MyKFPawn != none )
	{
		MyKFPawn.Acceleration = vect(0,0,0);
	}

	Super.Popped();
}

/*********************************************************************************************
* Action Transitions
**********************************************************************************************/

function bool AllowTransitionTo( class<GameAICommand> AttemptCommand )
{
	`AILog( self$" AllowTransitionTo: "$AttemptCommand$" called", 'Command_Attack' );

	// Let the child command, if any, make the decision
	if( ChildCommand != none )
	{
		return ChildCommand.AllowTransitionTo( AttemptCommand );
	}

	return IsSpecialMoveComplete();

}

/*********************************************************************************************
* Timers
**********************************************************************************************/

function bool ShouldSelectTarget()
{
	`AILog( self$" "$GetFuncName()$"() returning false", 'Command_Attack' );
	return false;
}

function bool ShouldIgnoreTimeTransitions()
{
	`AILog( GetFuncName()$" returning TRUE - ignoring time transitions", 'Command_Attack' );
	return true;
}

/*********************************************************************************************
* Default state related code
**********************************************************************************************/

function ESpecialMove GetSpecialMove()
{
	return AttackSpecialMove;
}

/** Return true if it's outside the Command_SpecialMove state */
function bool IsSpecialMoveComplete()
{
	return true;
}

state Command_SpecialMove
{
	function BeginState( Name PreviousStateName )
	{
		Super.BeginState( PreviousStateName );

		if( !bHasDebugCommand )
		{
			// Rotate to AttackTarget
 			if( AttackTarget != None && AttackTarget != Pawn )
 			{
				Focus = AttackTarget;
				SetDesiredRotation( Rotator(AttackTarget.Location - Pawn.Location) );
 			}
			else if( Enemy != none )
			{
				Focus = Enemy;
			}
		}
		// Reset time played in case this isn't a single attack
		TimePlayed = 0.f;
	}

	function bool ShouldFinishRotation()
	{
		return bFinishRotationBeforeAttack;
	}

	function ESpecialMove GetSpecialMove()
	{
		return AttackSpecialMove;
	}

	/** Delay between time special move finishes and AICommand is popped */
	function float GetPostSpecialMoveSleepTime()
	{
		// In case extra blend out time is needed if attack special move was aborted
		if( bAttackAborted )
		{
			return PostSpecialMoveAbortedSleepTime;
		}
		else
		{
			return PostSpecialMoveSleepTime;
		}
	}

	function bool IsSpecialMoveComplete()
	{
		if( MyKFPawn == none || !MyKFPawn.IsAliveAndWell() || !MyKFPawn.IsDoingSpecialMove( GetSpecialMove() ) )
		{
			return true;
		}

		return Super.IsSpecialMoveComplete();
	}

	function FinishedSpecialMove()
	{
		Status = 'Success';
		Super.FinishedSpecialMove();
	}
}


DefaultProperties
{
	bSingleAttack=true
	DefaultStartState=Command_SpecialMove
	bIgnoreNotifies=true
	bIgnoreStepAside=true
	bShouldCheckSpecialMove=false
	bLockDownAI=true
	AttackSpecialMove=SM_MeleeAttack
}