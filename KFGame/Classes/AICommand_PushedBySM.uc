//=============================================================================
// AICommand_PushedBySM
//=============================================================================
// Class that is pushed by a special move.
// Put AI in a state so he can be controlled by the Special Move. KFSM_Emerge
// is an example using this.  Usually, though, AICommands derived from
// AICommand_SpecialMove handle starting the special move, not vice versa.
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//=============================================================================

class AICommand_PushedBySM extends AICommand_SpecialMove
	within KFAIController;

/** If false, melee combat decisions will not be permitted during this special move */
var bool	bAllowMeleeCombatDecisions;

static function AICommand_PushedBySM PushSpecialMoveCommand( KFAIController AI )
{
	local AICommand_PushedBySM Cmd;

	if( AI != none && AI.MyKFPawn != none )
	{
		Cmd = new(AI) default.class;
		if( Cmd != none )
		{
			Cmd.SpecialMove = AI.MyKFPawn.SpecialMove;
			Cmd.TimeOutDelaySeconds = AI.MyKFPawn.SpecialMoves[AI.MyKFPawn.SpecialMove].AITimeout;
			AI.PushCommand(Cmd);
			return Cmd;
		}
	}

	return none;
}

/** Build debug string */
event String GetDumpString()
{
	return Super.GetDumpString()@"SpecialMove"@SpecialMove;
}

/** Disable transitions */
function bool AllowTransitionTo( class<GameAICommand> AttemptCommand )
{
      return false;
}

function Pushed()
{
	Super.Pushed();

	`AIlog( "Waiting for SM"@SpecialMove@"to finish.", 'Command_PushedBySM' );
	GotoState('WaitForMove');
}

function Popped()
{
	ClearTimer( 'SpecialMoveTimeout', self );
	Super.Popped();
}

function SpecialMoveTimeout()
{
	// Temporarily disabled
	return;

	`AILog( self$" Special move timed out", 'Command_PushedBySM' );

	if (MyKFPawn.SpecialMove == SpecialMove)
	{
		MyKFPawn.EndSpecialMove();
	}

	Status = 'Failure';
	AbortCommand(self);
}

state WaitForMove `DEBUGSTATE
{
	function bool IsSpecialMoveComplete()
	{
		if( !bPreparingMove || MyKFPawn == none || MyKFPawn.SpecialMove != SpecialMove )
		{
			return true;
		}
		return false;
	}
	
Begin:
	SetTimer( TimeOutDelaySeconds, false, nameof(self.SpecialMoveTimeOut), self );
	do
	{
		Sleep(0.1f);
	} until( IsSpecialMoveComplete() );
	
	`AILog( "bPreparingMove:" @ bPreparingMove @ "MyKFPawn:" @ MyKFPawn @ "SpecialMove:" @ MyKFPawn.SpecialMove @ SpecialMove, 'Command_PushedBySM' );
	Status = 'Success';
	PopCommand( self );
}

defaultproperties
{
	bAllowNewSameClassInstance=false
	bAllowMeleeCombatDecisions=false
	//FailSafeReadyTime=5.f
	//DefaultStartState=WaitForMove
}