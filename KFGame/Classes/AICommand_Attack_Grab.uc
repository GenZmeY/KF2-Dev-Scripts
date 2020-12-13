//=============================================================================
// AICommand_Attack_Grab
//=============================================================================
// AI Command for clot grab attack
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//=============================================================================

class AICommand_Attack_Grab extends AICommand_SM_Attack
	within KFAIController_Monster;

/*********************************************************************************************
* Push/Pause/Pop/Init
********************************************************************************************* */

/** Simple constructor that pushes a new instance of the command for the AI */
static function bool Grab( KFAIController_Monster AI, optional float InPostSpecialMoveSleepTime=0.f )
{
	local AICommand_Attack_Grab OtherCmd, Cmd;

	if (AI != None && AI.Pawn != None )
	{
		OtherCmd = AI.FindCommandOfClass(class'AICommand_Attack_Grab');
		if (OtherCmd == None )
		{
			Cmd = new(AI) default.Class;
			if( InPostSpecialMoveSleepTime > 0.f )
			{
				Cmd.PostSpecialMoveSleepTime = InPostSpecialMoveSleepTime;
			}
			AI.PushCommand(Cmd);
			return true;
		}
	}
	return false;
}

/** Build debug string */
event String GetDumpString()
{
	return Super.GetDumpString()@"Grab Target:"@Enemy;
}

function Pushed()
{
	Super.Pushed();

	DisableMeleeRangeEventProbing();
	`AILog( self$" ... Enemy"@Enemy, 'Command_Attack_Grab' );
}

function Resumed(name OldCommandName)
{
	Super.Resumed(OldCommandName);

	// Otherwise, didn't get there so fail the command
	Status = 'Failure';
	PopCommand(self);
}

function Paused(GameAICommand NewCommand)
{
	//`warn( "Warning! Paused() for "$self$" - paused by "$NewCommand );
	if( Outer.IsDead() || Outer.MyKFPawn == none || !Outer.MyKFPawn.IsAliveAndwell() )
	{
		AbortCommand( self );
	}
	super.Paused(NewCommand);
}

function Popped()
{
	LastAttackTime_Grab = WorldInfo.TimeSeconds;
	LastAttackTime_Melee = LastAttackTime_Grab;
	Super.Popped();
	EnableMeleeRangeEventProbing();
}

/*********************************************************************************************
* Special Move & State
********************************************************************************************* */

state Command_SpecialMove
{
	function BeginState(name PreviousStateName)
	{
		super.BeginState(PreviousStateName);
		MyKFPawn.bForceMaxAccel = false;
		bIgnoreNotifies = true;

		// Need to face the target
		SetDesiredRotation( rotator(Enemy.Location - Pawn.Location) );
	}

	function EndState(name NextStateName)
	{
		local KFPawn GP;

		Super.EndState( NextStateName );

		// Clear the interaction pawn once execution is done
		GP = KFPawn( AIOwner.Pawn );
		if( GP != None )
		{
			GP.InteractionPawn = None;
		}
	}

	function SpecialMoveTimeout()
	{
		`AILog( self$" Special move timed out", 'Command_Attack_Grab' );

		if( MyKFPawn.SpecialMove == SpecialMove || MyKFPawn.SpecialMove == SM_GrappleAttack )
		{
			MyKFPawn.EndSpecialMove();
		}

		Status = 'Failure';
		AbortCommand( self );
	}

	// Turn to face the target before doing the special move
	function bool ShouldFinishRotation() { return true; }

	function KFPawn GetInteractionPawn()
	{
		return KFPawn( Enemy );
	}

	function ESpecialMove GetSpecialMove()
	{
		return SM_GrappleAttack;
	}

	function bool ExecuteSpecialMove()
	{
		AIZeroMovementVariables();
		//SetInteractionPawn();
		StopLatentExecution();
		return (Super.ExecuteSpecialMove());
	}

	function bool IsSpecialMoveComplete()
	{
		return (MyKFPawn == None || (!MyKFPawn.IsDoingSpecialMove(SM_GrappleAttack)) && Super.IsSpecialMoveComplete());
	}

	function FinishedSpecialMove()
	{
		UpdateLastMeleeTime();
		EndOfMeleeAttackNotification();
	}
}

/** Overridden to break grabs on enemy changed */
function NotifyEnemyChanged( optional Pawn OldEnemy )
{
	if( MyKFPawn != none && MyKFPawn.IsDoingSpecialMove(SM_GrappleAttack) )
	{
		MyKFPawn.EndSpecialMove();
	}

	super.NotifyEnemyChanged( OldEnemy );
}

function UpdateLastMeleeTime()
{
	//Outer.UpdateLastMeleeTime();
	LastAttackTime_Grab = WorldInfo.TimeSeconds;
	LastAttackTime_Melee = LastAttackTime_Grab;
}

DefaultProperties
{
	bShouldCheckSpecialMove=false
	TimeOutDelaySeconds=50.f
}
