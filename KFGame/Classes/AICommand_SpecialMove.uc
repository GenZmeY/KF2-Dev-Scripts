//=============================================================================
// AICommand_SpecialMove
//=============================================================================
// Base AICommand for KFSpecialMove state-related AI handling (based on GOW2-3)
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//=============================================================================

class AICommand_SpecialMove extends AICommand
	within KFAIController
	native(AI);

/** Special move this command is monitoring */
var ESpecialMove	SpecialMove;
/** Starting state override - default is 'Command_SpecialMove' */
var name			DefaultStartState;
/** Time after special move is complete that command should terminate */
var float			TerminationTime;
/** Whether we should check if the special move is valid (CanDoSpecialMove()) */
var bool			bShouldCheckSpecialMove;
/** Should update Pawn's anchor when starting a special move */
var bool			bUpdateStartAnchor;
/** Should update Pawn's anchor when popping after a successful special move */
var bool			bUpdateAnchorOnSuccess;
/** Time in seconds we should wait before considering this special move as timed out **/
var float			TimeOutDelaySeconds;
/** Time we should sleep if the special move fails */
var float			FailureSleepTimeSeconds;
/** Destination special move should end at */
var vector			EndDest;
/** Command will forcibly attempt to begin SpecialMove even if it's not considered to be ready
	after this duration */
var float			FailSafeReadyTime;
/** If true, command will attempt to begin the special move even if it's not considered to be ready */
var bool			bForceReady;
var int				MaxExecuteSMAttemptsBeforeAbort;
var int				ExecuteSMCount;
var bool            bWaitForLanding;

var object Observer;

/*********************************************************************************************
* Push/Pause/Pop
********************************************************************************************* */

function Pushed()
{
	Super.Pushed();
	`AILog( self$" Pushed", 'Command_SpecialMove' );
	LockdownAI();
	if( DefaultStartState != '' )
	{
		GotoState( DefaultStartState );
	}
}

function Resumed( Name OldCommandName )
{
	`AILog( self$" Resumed, previous command: "$OldCommandName, 'Command_SpecialMove' );
	ExecuteSMCount = 0;
	Super.Resumed( OldCommandName );

	LockdownAI();
}

function Paused( GameAICommand NewCommand )
{
	`AILog( self$" Paused by command "$NewCommand, 'Command_SpecialMove' );
	Super.Paused( NewCommand );

	UnlockAI();
}

function Popped()
{
	local int Idx;
	local NavigationPoint NewAnchor;

	Super.Popped();

	`AILog( "Popped()", 'Command_SpecialMove' );

	UnlockAI();
	ClearTimeout();

	if( bUpdateAnchorOnSuccess )
	{
		// If successful
		if( Status == 'Success' )
		{
			NewAnchor = GetUpdatedAnchor();
			if( NewAnchor != None )
			{
				// Update pawn's anchor
				Pawn.SetAnchor( NewAnchor );

				// Remove anything in the route cache up to our new movetarget
				Idx = RouteCache.Find( NewAnchor );
				if( Idx != INDEX_NONE )
				{
					RouteCache_RemoveIndex( 0, Idx + 1 );
				}
			}
		}
	}
}

function ClearTimeout()
{
	ClearTimer( nameof(self.SpecialMoveTimeout), self );	
}

/*********************************************************************************************
* Pathfinding & Movement
********************************************************************************************* */

function NavigationPoint GetStartAnchor()
{
	return None;
}

function NavigationPoint GetUpdatedAnchor()
{
	return None;
}

function LockdownAI()
{
	`AILog( GetFuncName(), 'Command_SpecialMove' );

	bPreparingMove = true;	// Don't move until move done
	AIZeroMovementVariables();
}

function UnlockAI()
{
	`AILog( GetFuncName(), 'Command_SpecialMove' );

	// Turn off flags
	bPreparingMove			= false;
	bPreciseDestination		= false;
	if (Pawn!=none)
	{
		Pawn.LockDesiredRotation(false);
	}
}

/*********************************************************************************************
* SpecialMove events
********************************************************************************************* */

/** The SpecialMove has timed out - handle specifics in child classes */
function SpecialMoveTimeout();

/** Return the number of seconds to wait before forcibly attempting to start the special move */
function float GetFailSafeReadyTime()
{
	return FailSafeReadyTime;
}

/** If the SpecialMove hasn't been started after FailSafeReadyTime seconds, this timer forces the command
	to attempt to do the SpecialMove. */
function Timer_FailSafeReadyTriggered()
{
	`AILog( self$" Failsafe triggered for special move action", 'Command_SpecialMove' );
	bForceReady = true;
}

/*********************************************************************************************
* Special Move & State
********************************************************************************************* */

state Command_SpecialMove `DEBUGSTATE
{
	/** Overridden in child states */
	function bool SetupSpecialMove() { return true; }
	function FinishedSpecialMove();
	function ESpecialMove GetSpecialMove();
	function float GetPostSpecialMoveSleepTime();
	function float GetPreSpecialMoveSleepTime();
	function bool IsReady() { return true; }
	function bool SetupMoveToEndDest();
	function bool ShouldFinishRotation();
	function bool ShouldFinishPostRotation();
	function KFPawn	GetInteractionPawn();
	
	/** Optionally replace the Pawn's anchor navigation point */
	event BeginState( Name PreviousStateName )
	{
		if( bUpdateStartAnchor )
		{
			Pawn.SetAnchor( GetStartAnchor() );
		}
	}
	
	function byte GetSpecialMoveFlags( ESpecialMove InSpecialMove )
	{
		if( MyKFPawn != none && MyKFPawn.CanDoSpecialMove(InSpecialMove) )
		{
			return MyKFPawn.SpecialMoves[InSpecialMove].PackFlagsBase(MyKFPawn);
		}
		return 255;
	}

	/** Can this command be pushed by special moves? */
	function bool AllowPushOfDefaultCommandForSpecialMove( ESpecialMove SM )
	{
		// if we're handling this special move, then NO!
		return ( SM != GetSpecialMove() );
	}
 
	/** Begin executing the special move */
	function bool ExecuteSpecialMove()
	{
		SpecialMove = GetSpecialMove();

		`AILog( GetFuncName()$"()"@SpecialMove, 'Command_SpecialMove' );

		/** Warning! if bShouldCheckSpecialMove is false and InternalCanDoSpecialMove returns false, the special move will begin!
			This is old code, so I'm not changing it for the moment. @TODO: FIX! */
		if( SpecialMove != SM_None && (!bShouldCheckSpecialMove || MyKFPawn.CanDoSpecialMove( SpecialMove )) )
		{
			MyKFPawn.DoSpecialMove(SpecialMove, true, GetInteractionPawn(), GetSpecialMoveFlags(SpecialMove));
			AIActionStatus = "SpecialMove: "$MyKFPawn.SpecialMoves[SpecialMove];
			return true;
		}
		else
		{
			return false;
		}
	}

	/** Checks circumstances in which to consider special move completed */
	function bool IsSpecialMoveComplete()
	{
		if( !bPreparingMove || MyKFPawn == None || MyKFPawn.SpecialMove == SM_None )
		{
			return true;
		}
		return false;
	}

	/** Special move has timed out, fail the command and end it */
	function SpecialMoveTimeout()
	{
		`AILog( GetFuncName()$" Special move timed out - failing and aborting", 'Command_SpecialMove' );

		if( MyKFPawn.SpecialMove == SpecialMove )
		{
			MyKFPawn.EndSpecialMove();
		}
		UpdateHistoryString( "[F] SM TimedOut" );
		Status = 'Failure';
		AbortCommand( self );
	}

	/** Notification that special move execution failed */
	function OnFailedToDoSpecialMove()
	{
		`AILog( self$" Failed to do special move", 'Command_SpecialMove' );
		UpdateHistoryString( "[F] SM Aborted" );
	}

Begin:
	`AILog( self$" --"@GetStateName()$":"$class@"-- BEGIN LABEL", 'Command_SpecialMove' );
	if( bWaitForLanding && MyKFPawn.Physics == PHYS_Falling )
	{
		/** Don't execute any more state code until I've landed */
		WaitForLanding();
	}
	if( !SetupSpecialMove() )
	{
		`AILog( self$" Setup Special Move failed", 'Command_SpecialMove' );
		Goto( 'Abort' );
	}

	if( ShouldFinishRotation() && !Pawn.ReachedDesiredRotation() )
	{
		/** Rotate to desired rotation (optional) and don't execute more state code until finished */
		FinishRotation();
	}

	/** Handle optional delay prior to starting special move and don't execute more state code until the delay is over */
	if( GetPreSpecialMoveSleepTime() > 0 )
	{
		Sleep( GetPreSpecialMoveSleepTime() );
	}

	/** Optionally wait until IsReady() returns true (it does by default) */
	bForceReady = false;
	
	SetTimer( GetFailSafeReadyTime(), false, nameof(Timer_FailSafeReadyTriggered), self );
	while( !IsReady() && !bForceReady )
	{
		`AILog( self$" Waiting for ready", 'Command_SpecialMove' );
		Sleep(0.1f);
	}
	ClearTimer( nameof(Timer_FailSafeReadyTriggered), self );

	/** Try to start the special move */
	if( ExecuteSpecialMove() )
	{
		/** Handle optional timeout in case the special move takes too long, gets stuck, etc. */
		SetTimer( TimeOutDelaySeconds, false, nameof(self.SpecialMoveTimeOut), self );
		/** Check to see if special move is finished every 0.1 seconds */
		do
		{
			`AILog( self$" Waiting for SM to end TimeOutDelaySeconds: "$TimeoutDelaySeconds, 'Command_SpecialMove' );
			Sleep( 0.1f );
		} until( IsSpecialMoveComplete() );

		/** Optionally wait until finished rotating after special move is done */
		if( ShouldFinishPostRotation() )
		{
			FinishRotation();
		}

		/** Haven't used this, but not ruling it out - optional move after special move is done */
		if( SetupMoveToEndDest() )
		{
			/** Latent move to EndDest, won't execute more state code until move is complete/interrupted/fails */
			MoveTo( EndDest );
		}
		UpdateHistoryString( "SM Ended at "$WorldInfo.TimeSeconds );
		FinishedSpecialMove();
		
		/** Handle optional delay after special move is completed */
		TerminationTime = WorldInfo.TimeSeconds + GetPostSpecialMoveSleepTime();
		while( TerminationTime > WorldInfo.TimeSeconds )
		{
			Sleep( 0.1f );
		}
		/** Done! */
		Status = 'Success';
	}
	/** Handle optional retries after a failure */
	else if( MaxExecuteSMAttemptsBeforeAbort > 0 && MaxExecuteSMAttemptsBeforeAbort >= ExecuteSMCount )
	{
		FinishRotation();
		Sleep( 0.1f );
		ExecuteSMCount++;
		Goto( 'Begin' );
	}
	else
	{
Abort:
		`AILog( "Abort label", 'Command_SpecialMove' );
		OnFailedToDoSpecialMove();
		Status = 'Failure';
		/** Handle optional delay after failure, won't execute more state code until delay is finished */
		Sleep( FailureSleepTimeSeconds );
	}

	/** Exit the command */
	`AILog( "Calling PopCommand() at bottom of state code", 'Command_SpecialMove' );
	PopCommand( self );
}

defaultproperties
{
	DefaultStartState=Command_SpecialMove
	bWaitForLanding=true
	bAllowedToAttack=false
	bIgnoreStepAside=true
	TimeOutDelaySeconds=10.0f
	FailureSleepTimeSeconds=0.5f
	MaxExecuteSMAttemptsBeforeAbort=5
	FailSafeReadyTime=5.f
}