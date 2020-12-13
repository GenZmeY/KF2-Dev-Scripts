//=============================================================================
// AICommand_Pause
//=============================================================================
// Command to pause the AI for <PauseTime> seconds
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//=============================================================================
class AICommand_Pause extends AICommand
	within KFAIController;

/** How long should the pause be active */
var float	PauseTime;
/** Whether or not to stop any current moves */
var bool	bStopMovement;
/** Option to abort any current movement commands */
var bool    bAbortCommands;
/** Don't begin pause until falling pawn has landed */
var bool    bWaitForLanding;

/*********************************************************************************************
* Initialization
********************************************************************************************* */

static function bool Pause( KFAIController AI, float InDuration, optional bool InStopMovement=true, optional bool InAbortCommands=false, optional bool InWaitForLanding=true )
{
	local AICommand_Pause Cmd;

	if( AI != None )
	{
		Cmd = new(AI) Default.Class;
		if( Cmd != None )
		{
			Cmd.PauseTime       = InDuration;
			Cmd.bStopMovement   = InStopMovement;
			Cmd.bAbortCommands  = InAbortCommands;
			Cmd.bWaitForLanding = InWaitForLanding;

			AI.PushCommand(Cmd);
			return TRUE;
		}
	}

	return FALSE;
}

function Pushed()
{
	super.Pushed();
	
	`AILog( "Pausing for "$PauseTime$" second(s)", 'Command_Pause' );
	AIActionStatus = "Pausing for "$PauseTime$" seconds";

	DisableMeleeRangeEventProbing();
	GotoState('Wait');
}

function Popped()
{
	AIActionStatus = "Finished pause";
	super.Popped();

	EnableMeleeRangeEventProbing();
}

function Paused( GameAICommand NewCommand )
{
	// Pausing the pause command can be bad, unless you're sure you want to do this.
	// See CanInterruptPauseCommand()
	//`warn( self$" PAUSED BY "$NewCommand );
}

function bool AllowTransitionTo( class<GameAICommand> AttemptCommand )
{
	local class<AICommand> AIC;

	AIC = class<AICommand>(AttemptCommand);

	if( AIC != none && AIC.static.CanInterruptPauseCommand() )
	{
		return true;
	}
	return super.AllowTransitionTo( AttemptCommand );
}

/** Prevent changing enemy while paused */
function bool CanChangeEnemy( Pawn NewEnemy )
{
	return false;
}

/*********************************************************************************************
* Wait (Paused) state
********************************************************************************************* */

state Wait
{
Begin:
	if( bWaitForLanding &&  MyKFPawn.Physics == PHYS_Falling )
	{
		WaitForLanding();
	}
	if( bStopMovement )
	{
		AIZeroMovementVariables();
		//StopAllLatentMovement(); // Abort move commands, too?
	}
	if( bAbortCommands )
	{
		AbortMovementCommands();
		AbortMovementPlugIns();
	}
	Sleep( PauseTime );
	GotoState( 'DelaySuccess' );
};

DefaultProperties
{
	//bReplaceActiveSameClassInstance=true
	bAllowedToAttack=false
	bIgnoreNotifies=true
	bIgnoreStepAside=true
	PauseTime=10.0f
}