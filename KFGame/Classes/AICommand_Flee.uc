//=============================================================================
// AICommand_Flee
//=============================================================================
// Directs the AI away from a target for a specified duration and distance
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//=============================================================================

class AICommand_Flee extends AICommand
	within KFAIController;

/* Tells the command to stop when it reaches the goal */
var bool bStopAtGoal;

/* Actor to flee away from */
var Actor FleeTarget;

/* Dot product of projection between pawn and goal location */
var float Dot;

/** Cached value of the sprinting state before fleeing, to restore upon command pop */
var bool bWasSprinting;

/* How many unsuccessful path attempts have been made since command was pushed */
var int PathAttempts;

/* The maximum duration that the flee command can run */
var float FleeDuration;

/** The desired distance to attempt to flee.
	Note that this is not based on direct projection, but visited weight. */
var float FleeDistance;

/** Returns true if we've gotten a goal and want to continue towards it */
var bool bHaveGoal;

/** A randomized distance outside of the target goal to stop at */
var float GoalOffset;

/*********************************************************************************************
* Initialization
********************************************************************************************* */

static function bool FleeFrom(
	KFAIController AI,
	actor inFleeTarget,
	optional float inFleeDuration,
	optional float inFleeDistance=5000,
	optional bool bShouldStopAtGoal=false )
{
	local AICommand_Flee Cmd;

	if( AI != None )
	{
		Cmd = new(AI) Default.Class;
		if( Cmd != None )
		{
			Cmd.FleeTarget = inFleeTarget;
			Cmd.FleeDistance = inFleeDistance;
			Cmd.FleeDuration = inFleeDuration;
			Cmd.bStopAtGoal = bShouldStopAtGoal;
			AI.PushCommand(Cmd);
			return true;
		}
	}

	return false;
}

function Pushed()
{
	super.Pushed();
	bWasSprinting = MyKFPawn.bIsSprinting;
	DisableMeleeRangeEventProbing();
	MoveTimer = -1.0;
	Pawn.ZeroMovementVariables();
	StopAllLatentMovement();
	RouteGoal = None;
	bHaveGoal = false;
	GoalOffset = Square(384.f + (fRand()*128.f));

	if( FleeDuration > 0.f )
	{
		SetTimer( FleeDuration, false, nameof(Timer_FleeDurationExpired), self );
	}
	StartFleeing();
}

function Timer_FleeDurationExpired()
{
	Status = 'Success';
	NotifyFleeFinished();
	PopCommand( self );
}

function StartFleeing()
{
	GotoState('Fleeing', 'Begin');
}

function Popped()
{
	super.Popped();

	if( MyKFPawn != none )
	{
		MyKFPawn.bIsSprinting = bWasSprinting;
		MyKFPawn.ClearHeadTrackTarget( FleeTarget );
	}

	ClearTimer( nameOf(Timer_FleeDurationExpired), self );
	EnableMeleeRangeEventProbing();
}

/*********************************************************************************************
* Hiding state
********************************************************************************************* */

state Fleeing
{
	event BeginState( name PreviousStateName )
	{
		super.BeginState( PreviousStateName );
		
		Enemy = None;
	}

	function bool CheckRetreat()
	{
		local EPathSearchType OldSearchType;

		if( RouteGoal != none && bHaveGoal )
		{
			AIActionStatus = "Attempting to flee from ["$FleeTarget$"] at ["$RouteGoal$"]";
			return true;
		}
		else
		{
			bHaveGoal = false;
		}

		// Make sure we always have something to flee from
		if( FleeTarget == none )
		{
			Class'NavigationPoint'.static.GetNearestNavToActor( Pawn );			
		}

		// Cache off our previous path search type
		OldSearchType = Pawn.PathSearchType;

		if( FleeTarget != none )
		{
			AIActionStatus = "Searching for navigable path from ["$FleeTarget$"]";

			Pawn.PathSearchType = PST_Constraint;
			class'Path_AlongLine'.static.AlongLine( Pawn, Normal(Pawn.Location - FleeTarget.Location) );
			class'Goal_AwayFromPosition'.static.FleeFrom( Pawn, FleeTarget.Location, FleeDistance );

			if( FindPathToward( Pawn ) != None )
			{
				//Pawn.DrawDebugLine( RouteGoal.Location, Pawn.Location, 255, 80, 80, true );
				//Pawn.DrawDebugSphere( RouteGoal.Location, 128, 4, 255, 80, 80, true );
				bHaveGoal = true;
				AIActionStatus = "Attempting to flee from ["$FleeTarget$"] at ["$RouteGoal$"]";
				Focus = none;
				PathAttempts = 0;

				// Restore previous path search type
				Pawn.PathSearchType = OldSearchType;

				return true;
			}
		}

		// Restore previous path search type
		Pawn.PathSearchType = OldSearchType;

		PathAttempts += 1;
		return false;
	}

Begin:
	// Make sure we have a pawn and it's alive
	if( MyKFPawn == none || !MyKFPawn.IsAliveAndWell() )
	{
		Status = 'Failure';
		`AILog( "No pawn, aborting", 'Command_Flee' );
		NotifyFleeFinished();
		PopCommand( self );
	}
	else
	{
		// Don't try to path when falling
		if( MyKFPawn.Physics == PHYS_Falling )
		{
			AIActionStatus = "Fleeing, waiting for landing...";
			WaitForLanding();
		}

		// Make sure our pawn didn't die from falling!
		if( MyKFPawn == none || !MyKFPawn.IsAliveAndWell() )
		{
			Status = 'Failure';
			`AILog( "No pawn, or pawn died from falling", 'Command_Flee' );
			NotifyFleeFinished();
			PopCommand( self );
		}
		else
		{
			// Keep focus clear
			Focus = None;

			if( CheckRetreat() )
			{
				// Always sprint when fleeing
				MyKFPawn.SetSprinting( true );

				// Continually move us to our goal
				SetMoveGoal( RouteGoal, none, false, 256.f, true, true, true, false, false );

				// Stop at goal if we are close enough
				if( !bStopAtGoal || VSizeSQ(Pawn.Location - RouteGoal.Location) > GoalOffset )
				{
					Sleep( 0.f );
					Goto( 'Begin' );
				}

				// Rotate to direction
				Dot = Normal(Location - FleeTarget.Location) dot vector(FleeTarget.Rotation);
				if( Dot > 0.78f )
				{
					PushState( 'RotateToFocus' );
					Status = 'Success';
					Sleep( 0.f );
					NotifyFleeFinished();
					PopCommand( self );

				}
				else
				{
					Status = 'Success';
					Sleep( 0.f );
					NotifyFleeFinished();
					PopCommand( self );
				}
			}
			else if( PathAttempts > 30 )
			{
				// Don't get stuck, pop the command so the notify triggers
				Status = 'Failure';
				`AILog( "Failed to find flee path from ["$FleeTarget$"] after 30 attempts, aborting...", 'Command_Flee' );
				NotifyFleeFinished();
				PopCommand( self );
			}
			else
			{
				Sleep( 0.f );
				Goto( 'Begin' );
			}
		}
	}

FleeComplete:
	Status = 'Success';
	NotifyFleeFinished();
	PopCommand( self );
}

state RotateToFocus `DEBUGSTATE
{
Begin:
	AIActionStatus = "Rotating to focus";
	SetFocalPoint( vect(0,0,0) );
	Focus = FleeTarget;
	FinishRotation();
	PopState();
}


DefaultProperties
{
	bAllowedToAttack=false
}