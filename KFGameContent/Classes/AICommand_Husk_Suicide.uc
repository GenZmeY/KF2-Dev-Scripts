//=============================================================================
// AICommand_Husk_Suicide
//=============================================================================
// Command used by husks with low-health who become suicidal, intending to
// blow themselves up.
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//=============================================================================

class AICommand_Husk_Suicide extends AICommand_SpecialMove
	within KFAIController_ZedHusk;

/** Simple constructor that pushes a new instance of the command for the AI */
static function bool Suicide( KFAIController_ZedHusk AI )
{
	local AICommand_Husk_Suicide Cmd;

	if( AI != None )
	{
		Cmd = new(AI) default.class;
		if( Cmd != None )
		{
			AI.PushCommand( Cmd );
			return true;
		}
	}

	return false;
}

/*********************************************************************************************
* Push/Pause/Pop
********************************************************************************************* */

function Pushed()
{
	Super.Pushed();
	
	DisableMeleeRangeEventProbing();
	if( Pawn != none )
	{
		Pawn.ZeroMovementVariables();
	}
	MoveTimer = -1.f;
	StopAllLatentMovement();
	LockdownAI();
	`AILog( self@"Pushed", 'Husk_Suicide' );
	AIActionStatus = "Executing suicide AICommand";
}

function Resumed( Name OldCommandName )
{
	`AILog( self@"Resumed, previous command: "$OldCommandName, 'Husk_Suicide' );
	Super.Resumed( OldCommandName );

	LockdownAI();
}

function Paused( GameAICommand NewCommand )
{
	`AILog( self@"Paused by command"@NewCommand$", WTF!", 'Husk_Suicide' );
	Super.Paused( NewCommand );

	UnlockAI();
}

function Popped()
{
	Super.Popped();

	`AILog( self@"Popped()", 'Husk_Suicide' );
	if( Pawn != none )
	{
		AIActionStatus = "Finished suicide AICommand, health:"$Pawn.Health;
	}
}

function ESpecialMove GetSpecialMove();

state Command_SpecialMove
{
	function ESpecialMove GetSpecialMove()
	{
		return SM_Suicide;
	}
	
	function bool ExecuteSpecialMove()
	{
		local KFAIController KFAIC;
		local bool bExecuted;

		bExecuted = super.ExecuteSpecialMove();
		if( bExecuted )
		{
			foreach WorldInfo.AllControllers( class'KFAIController', KFAIC )
			{
				if( KFAIC != outer && KFAIC.MyKFPawn != none )
				{
					if( KFAIC.CanSee(MyKFPawn) )
					{
						KFAIC.NotifyHuskSuicide( MyKFPawn );
					}
				}
			}
		}
		return bExecuted;
	}
}

defaultproperties
{
	bAllowedToAttack=false
	bIgnoreNotifies=false
}
