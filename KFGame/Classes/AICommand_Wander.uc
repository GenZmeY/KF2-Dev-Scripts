//=============================================================================
// AICommand_Wander
//=============================================================================
// Wander AICommand - originally had options to wander within the confines
// of a specified volume, but that part has been stripped out.
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//=============================================================================
class AICommand_Wander extends AICommand
	within KFAIController;

var vector	WanderDestination;
var float	MaxWanderDist;
/** Number of seconds to wander (-1 no time limit) */
var float	WanderDuration;
var float	RandomCoef;
var float	WanderEnvelopeInner;
/** Min/Max delay time after reaching each wander point */
var float	WanderWaitMin;
var float	WanderWaitMax;
/** Goal to wander toward or to wander around */
var actor	WanderGoal;
/** Wanders around the goal, not straying too far */
var bool	bWanderAroundGoal;
/** Whether or not partial paths are acceptible while wandering */
var bool	bCanUsePartialPath;
/** Cached enemy */
/** Cached bIsSprinting */
var bool	bWasSprinting;

static function bool BeginWander( KFAIController AI, optional float InWanderDuration, optional actor InWanderGoal, optional bool inWanderAroundGoal, optional float InMaxWanderDist=10000.f )
{
	local AICommand_Wander Cmd;

	if( AI != None )
	{
		Cmd = new(AI) Default.Class;
		if( Cmd != None )
		{
			Cmd.WanderDuration		= InWanderDuration;
			Cmd.MaxWanderDist		= InMaxWanderDist;
			Cmd.bWanderAroundGoal	= inWanderAroundGoal;
			Cmd.WanderGoal			= InWanderGoal;
			AI.PushCommand(Cmd);
			return true;
		}
	}

	return false;
}

function Pushed()
{
	Super.Pushed();
	bWasSprinting = MyKFPawn.bIsSprinting;
	MyKFPawn.bIsSprinting = false;
	MyKFPawn.bCanUseHiddenSpeed = false;

	if( WanderDuration > 0.f )
	{
		SetTimer( WanderDuration, false, nameof(Timer_WanderDurationExpired), self );
	}

	Enemy = none;
	GotoState( 'Wandering' );
}

function Paused( GameAICommand NewCommand )
{
	super.Paused( NewCommand );
	AIZeroMovementVariables( true );
	StopAllLatentMovement();
	MyKFPawn.bCanUseHiddenSpeed = MyKFPawn.default.bCanUseHiddenSpeed;
}

function Resumed( name OldCommandName )
{
	MyKFPawn.bIsSprinting = bWasSprinting;
	super.Resumed( OldCommandName );
	MyKFPawn.bCanUseHiddenSpeed = false;
}

function Popped()
{
	super.Popped();
	ClearTimer( nameof(Timer_WanderDurationExpired), self );
	AIZeroMovementVariables( true );
	StopAllLatentMovement();

	if( MyKFPawn != none )
	{
		MyKFPawn.bCanUseHiddenSpeed = MyKFPawn.default.bCanUseHiddenSpeed;
	}
}

function Timer_WanderDurationExpired()
{
	Status = 'Success';
	AIZeroMovementVariables( true );
	StopAllLatentMovement();
	Status = 'Success';
	PopCommand( self );
}

function Vector GetMoveDir()
{
	return ( (vector(Pawn.Rotation)/RandomCoef) + (RandomCoef * VRand()) );
}

state Wandering
{
	function Actor GenerateWanderPath( Actor Goal, optional bool bAllowPartialPath )
	{
		local float DistToGoal;
		local Actor Ret;

		bCanUsePartialPath = bAllowPartialPath;

		if( Goal == none )
		{
			return none;
		}

		DistToGoal = VSize( Pawn.Location - Goal.Location );

		if( bWanderAroundGoal && VSize(Goal.Location - Pawn.Location) < MaxWanderDist )
		{
			class'Path_AlongLine'.static.AlongLine( Pawn, -Normal(Goal.Location - Pawn.Location));
			class'Path_WithinTraversalDist'.static.DontExceedMaxDist( Pawn, MaxWanderDist, false );
			class'Goal_Random'.static.FindRandom( Pawn, 1024.f, -1 );
		}
		else
		{
			class'Path_TowardGoal'.static.TowardGoal( Pawn, Goal );
			class'Path_WithinTraversalDist'.static.DontExceedMaxDist( Pawn, MaxWanderDist, false );
			class'Path_WithinDistanceEnvelope'.static.StayWithinEnvelopeToLoc(Pawn, Goal.Location, MaxWanderDist, Min(DistToGoal,WanderEnvelopeInner),FALSE,,TRUE);
			class'Goal_Null'.static.GoUntilBust( Pawn, 1024 );
		}

		Ret = FindPathToward( Goal,,, bAllowPartialPath );

		Pawn.ClearConstraints();
		return Ret;
	}

	function bool Wander()
	{
		local actor Path;

		RouteGoal = none;
		Path = none;

		Path = GenerateWanderPath( WanderGoal, true );
		if( Path != none )
		{
			return true;
		}

		return false;
	}
Begin:
	if( WanderGoal == none  )
	{
		if( SuggestNewWanderPoint(WanderDestination, GetMoveDir(), MaxWanderDist) )
		{
			SetMovePoint( WanderDestination,, false, 128.f, false );
		}
		Sleep( 1.f + (2*FRand()) );
		Goto( 'Begin' );
	}

	`AILog("Wandering toward enemy...");
	if(  !Wander() )
	{
		`AILog("Failed to find Wander location for "$Enemy);
		Sleep( 1.5f );
		Goto( 'Begin' );
	}
	else if( RouteGoal != none )
	{
		SetMoveGoal( RouteGoal,, false, 128.f, true,,,, bCanUsePartialPath );
		Sleep( RandRange( WanderWaitMin, WanderWaitMax ) );
		Goto( 'FinishedMove' );
	}
	Sleep( 0.f );
	Goto( 'Begin' );

FinishedMove:
	`AILog("Done Wandering");

	// if we can't see our enemy from here, Wander again!
// 	if( !bWanderAwayFromGoal && !IsPawnVisibleViaTrace(Enemy) )
// 	{
// 		`AILog("Enemy wasn't visible, reacquiring");
// 		GotoState('Reacquire');
// 	}

	`AILog("Enemy was visible, rotating toward him");

	`AILog("Finished rotating, waiting a bit to let our driver pwn his arse");
	Sleep( RandRange(WanderWaitMin, WanderWaitMax) );
	Goto( 'Begin' );
}

function bool IsPawnVisibleViaTrace( Pawn PawnToCheck )
{
	local Vector TestLocation;
	local Rotator Rot;

	Rot = Pawn.Rotation;
	TestLocation = PawnToCheck.GetPawnViewLocation();
	Rot = Rotator(PawnToCheck.Location - Pawn.Location);

	return CanSeePawn(PawnToCheck) && CanSeeByPoints( Pawn.Location, TestLocation, Rot );
}

function bool CanSeePawn( Pawn Seen )
{
	return true;
}

DefaultProperties
{
	MaxWanderDist=10000.f
	WanderEnvelopeInner=1500.f
	WanderWaitMin=0.25f
	WanderWaitMax=1.33f
	RandomCoef=1.05f
}
