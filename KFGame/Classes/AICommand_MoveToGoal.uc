//=============================================================================
// AICommand_MoveToGoal
//=============================================================================
// Main movement/navigation AICommand (based on GOW2-GOW3)
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//=============================================================================
class AICommand_MoveToGoal extends AICommand
    within KFAIController
	native(AI);

`include(KFGame\KFGameAnalytics.uci);

/*********************************************************************************************
* Pathfinding
**********************************************************************************************/
/** if false, abort if we need to pathfind (i.e, if the current RouteCache becomes invalid) */
var bool			bCanPathfind;
/** Current RouteCache for controller is valid, no need to path find again */
var bool			bValidRouteCache;
/** Allow any path generation to return best guess */
var bool			bAllowPartialPath;
/** Intermediate move goal used when pathfinding to MoveGoal */
var Actor			IntermediateMoveGoal;
/** Can pawn perform attacks during this move? **/
var bool			bAllowedToAttackDuringMove;
/** IgnoreStepAside is saved in case temporarily overridden */
var bool			bSavedIgnoreStepAside;
/** Cached last goal location if goal is a pawn (and might move) */
var BasedPosition	LastPawnTargetPathLocation;
/** Current actor destination */
var actor			MoveToActor;

/*********************************************************************************************
* Failed move recovery
**********************************************************************************************/
/** counter for handling some cases of pawn getting stuck */
var int				NumTimesGetNextMoveGoalReturnedSameNode;
/** Number of times this oommand has attempted to retry moving after failure */
var int				Retries;
/** counter for handling some cases of pawn getting stuck */
var int				LoopFailSafeCounter;
/** fail-safe vars used to determine when a move has failed and needs to be started over */
var vector			LastMovePoint;
/** Seconds before timing out this move */
var float			TimeOutTime;
/** Actor my pawn should rotate toward before move */
var actor			TurnFocus;
/** Location my pawn should rotate toward before move */
var vector			TurnFocalPoint;
/** Track # of recent collisions with non-pawn obstructions */
var int				WallHitCount;

/*********************************************************************************************
* SkipAhead (evaluate and skip unnecessary nodes in a path)
**********************************************************************************************/
/** The last position we tried to skip ahead in the path from */
var BasedPosition	SkipAheadLastUpdatePos;
/** if we've moved SkipAheadUpdateThreshold units away from SkipAheadlastupdatePos, a new skipahead update will be run */
var float			SkipAheadUpdateThreshold;
/** maximum number of nodes in a path to skip ahead */
var int				SkipAheadMaxNodes;
/** maximum path distance to skip */
var float			SkipAheadMaxDist;
/** distance interval to check for pits when determining if it's safe to skip ahead */
var float			SkipAheadPitCheckInterval;
/** distance downward to trace for pit checks */
var float			SkipAheadPitCheckHeight;
/** disable/enable skipahead */
var bool			bEnableSkipAheadChecks;
/** internal use only, number of pending line check results we're waiting on */
var const int		SkipAheadNumActiveTests;
/** internal use only, whether any of the last batch of tests failed */
var const bool		bSkipAheadFail;
/** internal use only, the index into the route cache of the current node we're testing for skip ahead */
var int				SkipAheadCurrentTestingIndex;
/** indicates that the our current routecache has changed since the last time GetNnextMoveTarget was called */
var bool			bGoalChangedDueToSkipAhead;

/** list of nav points which skipahead testing is not allowed to skip past (e.g. for when we're following a set route) */
var native const transient Map{ANavigationPoint*,UBOOL} NonSkippableWaypoints;

const bUseAsyncRaycastsForSkipAhead = 0;
var bool bGoalSurrounded;

cpptext
{
	UBOOL AreSkipAheadTestsPending();
	void QueueSkipAheadTests(const FVector& Start, ANavigationPoint* NodeToTest, FLOAT CollisionRadius);
	virtual void TickCommand(FLOAT DeltaTime);
	void UpdateSubGoal(FLOAT DeltaTime);
	void SkipToSubGoal(AKFAIController* GAI, INT Index);
};

/** Removes all navpts from the non-skippable waypoint list */
function native ClearNonSkippableWayPoints();
/** Adds a nav point to the non-skippable waypoint list*/
function native AddNonSkippableWayPoint( NavigationPoint Point );

/*********************************************************************************************
* Push/Pause/Pop/Init
********************************************************************************************* */

/** Init the MoveToGoal command - my pawn's goal will be an actor (usually a player) */
static function bool MoveToGoal( KFAIController AI, Actor NewMoveGoal, optional Actor NewMoveFocus, optional float NewMoveOffset,
				optional bool bIsValidCache,
				optional bool bInCanPathfind = true,
				optional bool bInAllowedToAttackDuringMove = true,
				optional bool bInAllowPartialPath = true )
{
    local AICommand_MoveToGoal Cmd;

	if( AI != none && NewMoveGoal != none )
	{
		Cmd = new(AI) class'AICommand_MoveToGoal';
		if( Cmd != none )
		{
			// Never actually want to move to a controller, substitute pawn instead
			if( Controller(NewMoveGoal) != none )
			{
				NewMoveGoal = Controller(NewMoveGoal).Pawn;
			}
			AI.MoveGoal				= NewMoveGoal;
			AI.MoveFocus			= NewMoveFocus;
			AI.MoveOffset			= NewMoveOffset;
			Cmd.MoveToActor			= NewMoveGoal;
			Cmd.bValidRouteCache	= bIsValidCache;
			Cmd.bCanPathfind		= bInCanPathfind;
			Cmd.bAllowedToAttack	= bInAllowedToAttackDuringMove;
			Cmd.bAllowPartialPath	= bInAllowPartialPath;

			AI.SetBasedPosition( AI.MovePosition, vect(0,0,0) );
			AI.PushCommand( Cmd );
			return true;
		}
	}
	return false;
}

/** Init the MoveToGoal command - my pawn's goal will be a location instead of an actor */
static function bool MoveToPoint( KFAIController AI, Vector NewMovePoint, optional Actor NewMoveFocus, optional float NewMoveOffset,
				optional bool bIsValidCache,
				optional bool bInCanPathfind = true,
				optional bool bInAllowedToAttackDuringMove = true,
				optional bool bInAllowPartialPath = true )
{
	local AICommand_MoveToGoal Cmd;

	if( AI != none && NewMovePoint != vect(0,0,0) )
	{
		Cmd = new(AI) class'AICommand_MoveToGoal';
		if( Cmd != none )
		{
			AI.MoveFocus	= NewMoveFocus;
			AI.MoveOffset	= NewMoveOffset;
			AI.MoveGoal		= none;
			Cmd.MoveToActor = none;

			Cmd.bValidRouteCache		   = bIsValidCache;
			Cmd.bCanPathfind			   = bInCanPathfind;
			Cmd.bAllowedToAttackDuringMove = bInAllowedToAttackDuringMove;
			Cmd.bAllowPartialPath		   = bInAllowPartialPath;

			AI.SetBasedPosition( AI.MovePosition, NewMovePoint );

			AI.PushCommand( Cmd );
			return true;
		}
	}

	return false;
}

function Pushed()
{
	if( Steering != none )
	{
	//	Steering.EnableDefaultAcceleration();
	}

	Super.Pushed();

	StartingMovement();
	bSavedIgnoreStepAside = bIgnoreStepAside;
	// Reset flags in the controller
	bMovingToGoal		= true;
	bReachedMoveGoal	= false;
	bReevaluatePath		= false;
	MoveTarget			= none;
	LastMovePoint 		= vect(0,0,0);
	SetDestinationPosition( Pawn.Location, true );
	ClearNonSkippableWayPoints();
	// Start the move
	GotoState( 'MovingToGoal' );
}

function Popped()
{
	if( Steering != none )
	{
		Steering.DisableDefaultAcceleration();
	}
	Super.Popped();

	bDirectMoveToGoal	   = false;
	bMovingToGoal		   = false;
	bReachedMoveGoal	   = (Status == 'Success');
	MoveTarget			   = none;
	Retries				   = 0;
	bIgnoreStepAside	   = bSavedIgnoreStepAside;
	LastNavGoalReached	   = none;
	bReachedLatentMoveGoal = false;

	StoppingMovement();
	// Clear the route cache to make sure any intermediate claims are destroyed
	RouteCache_Empty();
	if( Pawn != none )
	{
		Pawn.ZeroMovementVariables(); //[Just Added 7/15/14]
		Pawn.DestinationOffset = 0.f;
	}
	ClearTimer( nameOf(MoveToGoalTimedOut), self );
	// Make sure that if we are bailing we notify the Controller we're done trying to move
	ReachedMoveGoal();
}

function Paused( GameAICommand NewCommand )
{
    local vector OldVelocity;
    local bool bWasFalling;

	Super.Paused( NewCommand );
	Retries = 0;
	// Pause move timeout timer
	PauseTimer( true, nameOf(MoveToGoalTimedOut), self );
	if( Steering != none )
	{
	//	Steering.DisableDefaultAcceleration();
	}

    if( Pawn != none && Pawn.Physics == PHYS_Falling )
    {
        OldVelocity = Pawn.Velocity;
        bWasFalling = true;
    }

    Pawn.ZeroMovementVariables();

    // Set our old velocity if we zeroed our movement while falling (probably from being pushed by weapon physics)
    if( Pawn != none && bWasFalling )
    {
        Pawn.Velocity = OldVelocity;
    }
}

function Resumed( Name OldCommandName )
{
	`AILog( self$" Resumed (oldCommand: "$OldCommandName$")", 'Command_MoveToGoal' );
	Retries = 0;
	Super.Resumed( OldCommandName );
	if( Steering != none )
	{
	//	Steering.EnableDefaultAcceleration();
	}
	NumTimesGetNextMoveGoalReturnedSameNode=0;
	Retries = 0;

	if( ChildStatus == 'Success' || ( Enemy != none && MyKFPawn.IsPawnMovingAwayFromMe( Enemy ) && MyKFPawn.bIsSprinting ) )
	{
		// Unpause move timeout timer
		PauseTimer( false, nameOf(MoveToGoalTimedOut), self );

		bMovingToGoal = true;
		bReachedMoveGoal = false;
		if( OldCommandName != 'AICommand_Crawler_LeapToWall' )  // (Temp - move to crawler move to goal)
		{
			// reset intermediate move goal so GetMoveGoal doesn't freak out when the current goal hasn't changed
			IntermediateMoveGoal = none;
			//ForceSkipAheadUpdate();
		}
		// Testing
		if( RouteCache.Length > 0 && Enemy != none ) //&& CanDirectlyReach(Enemy) )
		{
			bReevaluatePath = true;
			ReEvaluatePath();
		}
	}
	else
	{
		UpdateHistoryString( "Failure!" );
		// See if this still happens after adding || check above
		Status = 'Failure';
		AbortCommand( self );
	}
}

/*********************************************************************************************
* Movement and Pathfinding
********************************************************************************************* */

event bool EnemyIsSurrounded()
{
// 	local KFAIDirector KFAID;
// 	local KFPawn NewEnemy;
// 	local bool bReachable, bCanSee;
//
// 	bReachable = ActorReachable( Enemy );
// 	bCanSee = CanSee( Enemy );
// 	`AILog( MyKFPawn$" EnemyIsSurrounded() - Reachable: "$bReachable$" Dist: "$VSize(Enemy.Location - Location)$" LOS? "$bCanSee$" $bDirectMoveToGoal: "$bDirectMoveToGoal, 'PathWarning' );
// 	KFAID = KFGameInfo(WorldInfo.Game).GetAIDirector();
// 	if( KFAID != none )
// 	{
// 		NewEnemy = KFPawn( KFAID.FindEnemyFor( Outer ) );
// 		if( NewEnemy != none )
// 		{
// 			if( SetEnemy (NewEnemy ) )
// 			{
// 				`AIlog( MyKFPawn$" EnemyIsSurrounded() - Set new enemy to "$NewEnemy, 'PathWarning' );
// 				return true;
// 			}
// 		}
// 	}
	return false;
}

function ReEvaluatePath()
{
	local NavigationPoint	BestAnchor;
	local float				Dist;

	`AILog( GetFuncName()$"() bReEvaluatePath: "$bReevaluatePath, 'Command_MoveToGoal' );
	WallHitCount = 0;
	LastHitWall = none;
	// TODO: Skip below if goal is directly reachable?
	if( bReevaluatePath && Pawn != none && (MoveGoalIsValid() || MovePointIsValid()) )
	{
		`AILog( self$" "$GetFuncName()$"() ... Goal"@MoveGoal@"Anchor"@Pawn.Anchor, 'Command_MoveToGoal' );
		RouteCache_Empty(); //[NEW]
		if( !Pawn.ValidAnchor() && !bDirectMoveToGoal )
		{
			BestAnchor = Pawn.GetBestAnchor( Pawn, Pawn.Location, true, false, Dist );
			`AILog( GetFuncName()$"- ValidAnchor() returned false, new anchor:"@BestAnchor, 'Command_MoveToGoal' );
			if( BestAnchor == none )
			{
				// this is baaad, teleport to the nearest node
				BestAnchor = class'NavigationPoint'.static.GetNearestNavToActor( MyKFPawn );
				`AILog( "-dd teleport anchor:"@BestAnchor, 'Command_MoveToGoal' );
				if( BestAnchor != none && BestAnchor.IsUsableAnchorFor(MyKFPawn) )
				{
					// Only teleport if the anchor is really usable
					Pawn.SetLocation(BestAnchor.Location);
				}
			}
			if( BestAnchor != none )
			{
				Pawn.SetAnchor(BestAnchor);
			}
		}

		RouteCache_Empty();
		`AILog( GetFuncName()@"disabling bReevaluatePath and restarting the move", 'Command_MoveToGoal' );
		bReevaluatePath = false;
		bValidRouteCache = false;

		// Restart the movement state
		GotoState( 'MovingToGoal', 'Begin' );
	}
	else if( HasReachedMoveGoal() )
	{
		Status = 'Success';
		PopCommand( self );
	}
}

/** wrapper for Controller::FindPathToward() that sets the appopriate path search type first */
function Actor FindPathToward( Actor anActor )
{
	local EPathSearchType OldSearchType;
	local Actor Result;
	local int i;

	//if( PendingJumpSpot != none )
	//{
	//	if( PendingJumpSpot.bNotifyWhenClear )
	//	{
	//		PendingJumpSpot.NotifyClear();
	//		PendingJumpSpot = none;
	//	}
	//}

// 	if (!bCanPathfind)
// 	{
// 		`AILog( "Not allowed to pathfind - aborting move", 'Command_MoveToGoal' );
// 		//msg( "Not allowed to pathfind - aborting move" );
// 		UpdateHistoryString( "bPathFind was false, need to repath" );
// 		Status = 'Failure';
// 		AbortCommand(self);
// 	}
// 	else
// 	{
		OldSearchType = Pawn.PathSearchType;
		Pawn.PathSearchType = PST_Constraint;
		`AILog( "Generating path toward "$anActor$" Partial allowed? "$bAllowPartialPath, 'Command_MoveToGoal' );
		for( i = 0; i < BlockedPathList.Length; i++ )
		{
			if( (BlockedPathList[i].BlockedTime > 0.f) && `TimeSince(BlockedPathList[i].BlockedTime) > MaxBlockedPathDuration )
			{
				BlockedPathList.RemoveItem(BlockedPathList[i]);
			}
			else
			{
				NavigationPoint( BlockedPathList[i].BlockedReachSpec.End.Actor ).bBlocked = true;
			}
		}
		Result = GeneratePathTo( anActor,, bAllowPartialPath );
		for( i = 0; i < BlockedPathList.Length; i++ )
		{
			NavigationPoint( BlockedPathList[i].BlockedReachSpec.End.Actor ).bBlocked = false;
		}

		Pawn.PathSearchType = OldSearchType;
//	}
	if( Result == none )
	{
		AIActionStatus = "Failed Path toward "$anActor;
		CurrentMovementPhase = MOVEMENT_PHASE_TYPE_PATHNODE_FAILED_MOVE;
		`AILog( "** FAILED TO BUILD PATH TO "$AnActor, 'PathWarning' );
		if( Pawn.Anchor != none )
		{
			`RecordAIPathFailure( Outer, Pawn.Anchor, MoveGoal, "MoveToGoal" );
		}
		else
		{
			`RecordAIPathFailure( Outer, none, MoveGoal, "MoveToGoal" );
		}
	}
	else if( bDebug_DrawPath )
	{
		KFDebug_DrawMyPath();
	}

// 	if( BlockedPath != none )
// 	{
// 		BlockedPath.bBlocked = false;
// 		BlockedPath = none;
// 	}
	return Result;
}
/** Wrapper for Controller::FindPathTo() that sets the appopriate path search type first */
function Actor FindPathTo(vector aPoint)
{
	local EPathSearchType OldSearchType;
	local Actor Result;

	if( !bCanPathfind )
	{
		`AILog( "Not allowed to pathfind - aborting move", 'Command_MoveToGoal' );
		Status = 'Failure';
		UpdateHistoryString( "Failure- !bCanPathfind" );
		AbortCommand( self );
	}
	else
	{
		OldSearchType		= Pawn.PathSearchType;
		Pawn.PathSearchType	= PST_NewBestPathTo;
		Result				= Outer.FindPathTo(aPoint);
		Pawn.PathSearchType	= OldSearchType;

		`AILog( "Finding path to location "$aPoint$" Partial allowed? "$bAllowPartialPath, 'Command_MoveToGoal' );
	}
	if( Result == none )
	{
		AIActionStatus = "Failed Path to "$aPoint;
	}
// 	if( BlockedPath != none )
// 	{
// 		BlockedPath.bBlocked = false;
// 		BlockedPath = none;
// 	}
	return Result;
}

function RouteCache_RemoveIndex( int Idx )
{
	//`AILog( GetFuncName()@" -- Resetting skipahead index!", 'Command_MoveToGoal' );
	SkipAheadCurrentTestingIndex = 0;
	outer.RouteCache_RemoveIndex( Idx );
}

function MoveToGoalTimedOut()
{
	`AILog( GetFuncName(), 'Command_MoveToGoal' );
	AIActionStatus = "MoveToGoal TimedOut";
	if( Enemy != none && Enemy.IsAliveAndWell() )
	{
		if( NumberOfZedsTargetingPawn(Enemy, true, 350.f ) > 2 && CanSee(Enemy) )
		{
			Status='Success';
			PopCommand(self);
			return;
		}

		`AILog( GetFuncName()@self$" Timing out, but since my enemy is still alive I'm assuming I should keep trying? Anchor: "$Pawn.Anchor$" MoveGoal: "$MoveGoal, 'Command_MoveToGoal' );
		return;
	}
	else
	{
        `AILog( GetFuncName()$"() Anchor: "$Pawn.Anchor$" MoveGoal: "$MoveGoal, 'Command_MoveToGoal' );
		Pawn.SetAnchor( GetFallbackAnchor() );
		AbortCommand( self );
	}
}

/** Check if given goal is valid */
function bool MoveGoalIsValid( optional Actor Goal )
{
	if( Goal == none )
	{
		Goal = MoveGoal;
	}
    return (Goal != none);
}

/** Check if given point is valid */
function bool MovePointIsValid( optional Vector Point )
{
	if( Point == vect(0,0,0) )
	{
		Point = GetBasedPosition( MovePosition );
	}
	return (Point != vect(0,0,0));
}

/** Check if AI has successfully reached the given goal */
function bool HasReachedMoveGoal( optional Actor Goal )
{
	local bool bReached;
	local float TempDist;
	local bool bEnemyCheck;

//	Retries = 0;
	if( Pawn == none )
	{
		return true;
	}

	if( KFPawn(Goal) != none && KFPawn(Goal) == Enemy )
	{
		`AILog( GetFuncName()$"() for ENEMY goal, current distance: "$VSize(Enemy.Location - Pawn.Location)$" MoveOffset: "$MoveOffset, 'Command_MoveToGoal' );
		bEnemyCheck = true;
	}

	if( Goal == none )
	{
		Goal = MoveGoal;
	}

	Pawn.DestinationOffset = MoveOffset;
	if( MoveGoalIsValid( Goal ) )
	{
		if( Pawn.Anchor == Goal )
		{
			return true;
		}
		if( DynamicAnchor(Pawn.Anchor) != none )
		{
			// don't allow dynamic anchors to be valid for reach tests
			return false;
		}


		bReached = (bReachedLatentMoveGoal &&  (NavigationPoint(Goal) != none && LastNavGoalReached == NavigationPoint(Goal))) || Pawn.ReachedDestination( Goal );
		`AIlog( self$" HasReachedMoveGoal for goal: "$Goal$" Dist: "$VSize(Goal.Location - pawn.Location)$" bReachedLatentMoveGoal: "$bReachedLatentMoveGoal$" LastNavGoalReached: "$LastNavGoalReached, 'Command_MoveToGoal' );

		TempDist = VSize( Goal.Location - Pawn.Location );
		if( !bReached )
		{
			`AILog( "NOT REACHED "$Goal$" (Dist: "$TempDist$")", 'Command_MoveToGoal' );
		}
		return bReached;
	}
	else if( GetBasedPosition( MovePosition ) != vect(0,0,0) )
	{
		if( bEnemyCheck )
		{
			`AILog( GetFuncName()$"() "$VSize(GetBasedPosition(MovePosition)-Pawn.Location)$" versus MoveOffset "$MoveOffset, 'Command_MoveToGoal' );
		}
		if( VSize(GetBasedPosition(MovePosition)-Pawn.Location) < MoveOffset )
		{
			if( bEnemyCheck )
			{
				`AILog( GetFuncName()$"() Returning TRUE, position < MoveOffset", 'Command_MoveToGoal' );
			}
			return true;
		}
		bReached = Pawn.ReachedPoint( GetBasedPosition(MovePosition), none );
		if( bEnemyCheck )
		{
			`AILog( GetFuncName()$"() ReachedPoint reaturned "$bReached, 'Command_MoveToGoal' );
		}
		if( bReached )
		{
			return true;
		}

		return bReached;
	}
	if( bEnemyCheck )
	{
		`AILog( GetFuncName()$"() Returning false", 'Command_MoveToGoal' );
	}
    return false;
}

function bool MoveUnreachable( Vector AttemptedDest, Actor AttemptedTarget )
{
	if( AttemptedTarget != none )
	{
		`RecordAIMoveFailure( Outer, Pawn.Location, Pawn.Rotation, AttemptedTarget, "2 MoveUnreachable to "$AttemptedTarget);
		`AILog( self$" MoveUnreachable() while moving to goal! Target: "$AttemptedTarget$" Dest: "$AttemptedDest, 'Command_MoveToGoal' );
	}
	else
	{
		`RecordAIMoveFailure( Outer, Pawn.Location, Pawn.Rotation, MoveTarget, "3 MoveUnreachable to "$MoveTarget);
		`AILog( self$" MoveUnreachable() while moving to goal! Dest: "$AttemptedDest, 'Command_MoveToGoal' );
	}
	UpdateHistoryString( "[F] MoveUnreachable "$Pawn.Location );
	Status = 'Failure';
	if( AttemptedTarget == none )
	{
		AIActionStatus = "Move Unreachable: "$AttemptedDest;
	}
	else
	{
		AIActionStatus = "Move Unreachable: "$AttemptedTarget;
	}
	bValidRouteCache = false;
	bReevaluatePath = true;
	NotifyNeedRepath();
	return true;
}

/** Called from movetogoal when we arrive at our destination */
function ReachedMoveGoal()
{
	if( MoveGoal != none && Pawn != none )
	{
		AIActionStatus = "Reached MoveGoal Dist: "$VSize( MoveGoal.Location - Pawn.Location )$" MoveGoal: "$MoveGoal;
		`AILog( self$" Reached MoveGoal: "$MoveGoal$" Dist: "$VSize( MoveGoal.Location - Pawn.Location ), 'Command_MoveToGoal' );
	}
}

function ReachedIntermediateMoveGoal()
{
	local KFDoorMarker DM;

    if( !bUseNavMesh )
    {
    	//Retries = 0;
    	AIActionStatus = "Reached Intermediate Goal "$IntermediateMoveGoal;
    	`AILog( self$" ReachedIntermediateMoveGoal: "$IntermediateMoveGoal, 'PathWarning' );

    	DM = KFDoorMarker(IntermediateMoveGoal);

    	if( DM != none && DM.MyKFDoor != none && !DM.MyKFDoor.IsCompletelyOpen() )
    	{
    		// Allow pawn to handle door bump events first
    		if( MyKFPawn.HandleAIDoorBump(DM.MyKFDoor) )
    		{
    			return;
    		}

    		`AILog( GetFuncName()$" Reached IntermediateMoveGoal DoorMarker "$DM$" for closed door Dist: "$VSize(DM.Location - Pawn.Location), 'Doors' );
    		if( DM.MyKFDoor.WeldIntegrity <= 0 )
    		{
    			AIActionStatus = "Waiting for "$DM.MyKFDoor$" to open";
    			`AILog( GetFuncName()$" Calling WaitForDoor and UseDoor", 'Doors' );
    			// Stop, open the door, and wait for notification from it once it's open.
    			WaitForDoor( DM.MyKFDoor );
    			DM.MyKFDoor.UseDoor( Pawn );
    			return;
    		}
    		else
    		{
    			`AILog( GetFuncName()$" calling NotifyAttackDoor for "$DM.MyKFDoor$" with weld integrity "$DM.MyKFDoor.WeldIntegrity, 'Doors' );
    			AIActionStatus = "Wants to attack door "$DM.MyKFDoor;
    			NotifyAttackDoor( DM.MyKFDoor );
    			return;
    		}
    	}
	}

	// See if there's a better enemy blocking the path to our current one
	CheckForIntermediateEnemies();

	// Tell the AI controller we've arrived
	NotifyReachedLatentMoveGoal();
}

/** Attempts to find a better enemy than our current one */
function CheckForIntermediateEnemies()
{
	local Pawn EnemyBlocker;

	// See if we can find a better enemy
	if( MyKFPawn != none && Enemy != none && !MyKFPawn.IsDoingSpecialMove() && VSizeSQ(Enemy.Location - MyKFPawn.Location) > 490000.f )
	{
		EnemyBlocker = GetPawnBlockingPathTo( Enemy, true, true );
		if( EnemyBlocker != none && EnemyBlocker.CanAITargetThisPawn(Outer) )
		{
			ChangeEnemy( EnemyBlocker );
		}
	}	
}

/** Called when blocked by bBlocksNavigation actors (see ShouldIgnoreNavigationBlockingFor) */
function bool HandlePathObstruction( Actor BlockedBy )
{
	local Pawn BlockPawn;

	AIActionStatus = "Path obstructed by "$BlockedBy;
	`AILog( GetFuncName()$" - Blocked by : "$BlockedBy$" Time since previous obstruction: "$`TimeSince(LastObstructionTime), 'HandlePathObstruction' );

	LastObstructionTime = WorldInfo.TimeSeconds;
	BlockPawn = Pawn(BlockedBy);
	if( BlockPawn != none )
	{
		`AILog("- blocked anchor:"@BlockPawn.Anchor@BlockPawn.ReachedDestination(MoveGoal));

		// if they're touching our goal
		if( BlockPawn.ReachedDestination( MoveGoal ) )
		{
			`AILog( "- they're touching my goal, finishing the move", 'HandlePathObstruction' );

			// then just pretend we made it
			bReachedMoveGoal = true;


			Status = 'Success';
			PopCommand( self );
			return true;
		}
	}
	else if( KFDestructibleActor(BlockedBy) != none )
	{
		bValidRouteCache = false;
		bReevaluatePath = true;
		StopAllLatentMovement();
		`AILog( GetFuncName()$"() calling ZeroMovementVariables", 'HandlePathObstruction' );
		Pawn.ZeroMovementVariables();

		if( NavigationPoint(IntermediateMoveGoal) != none )
		{
			// Path is failing - if I just ran into a non-pawn obstruction, temporarily block IntermediateMoveGoal to let me
			// generate another path that doesn't require it.
			if( CreateTemporaryBlockedPath(NavigationPoint(IntermediateMoveGoal)) )
			{
				//`RecordAIRedirectedPath( Outer, IntermediateMoveGoal, "[HPO]Path:"$IntermediateMoveGoal$" and "$RouteCache[1] );
			}
		}
		Obstruction_Repath( BlockedBy );

		NotifyNeedRepath();
		return false;
	}
	Obstruction_Fail( BlockedBy );
	return false;
}

function Obstruction_Repath( actor Obstruction )
{
	`RecordAIPathObstruction( `StatID(AI_PATHOBSTRUCTION_REPATH), Outer, Obstruction, "MoveTarget:"$MoveTarget );
}

function Obstruction_Fail( actor Obstruction )
{
	`RecordAIPathObstruction( `StatID(AI_PATHOBSTRUCTION_FAIL), Outer, Obstruction, "MoveTarget:"$MoveTarget );
}

/** Called after the type of move has been determined. */
function StartingMove( bool bDirectMove, float Distance, int PathLength, Actor Dest)
{
	if( MyKFPawn.IsDoingMeleeAttack() )
	{
		StopAllLatentMovement();
		GotoState( 'MovingToGoal', 'ReachedGoal' );
		return;
	}
	if( (Enemy != none && Dest != none && Enemy == Dest) )
	{
		if( VSize( Dest.Location - Pawn.Location ) <= Pawn.MeleeRange ) // TODO: Use MyKFPawn.PawnAnimInfo.DesiredMeleeRange() instead?
		{
			StopAllLatentMovement();
			GotoState( 'MovingToGoal', 'ReachedGoal' );
			return;
		}
	}
	if( bDirectMove )
	{
		`AILog( self$" Starting *DIRECT* move, Distance: "$Distance$" PathLength: "$PathLength$" Dest: "$Dest, 'Command_MoveToGoal' );
		bDirectMoveToGoal = true;
		RouteCache_Empty();
	}
	else
	{
		`AILog( self$" Starting *PATHFINDING* move, Distance: "$Distance$" PathLength: "$PathLength$" Dest: "$Dest, 'Command_MoveToGoal' );
		bDirectMoveToGoal = false;
	}
}

/*********************************************************************************************
* Combat related
********************************************************************************************* */

function bool NotifyPlayerBecameVisible( Pawn VisiblePlayer )
{
	`AILog( GetFuncName()$" "$VisiblePlayer, 'SeePlayer' );

	if( Enemy != none && bMovingToGoal && !bDirectMoveToGoal && InLatentExecution( LATENT_MOVETOWARD )) //&& (VisiblePlayer == MoveGoal || VisiblePlayer == IntermediateMoveGoal) )
	{
		// This player happens to be my next movetarget, so break off of path if directly reachable
		if( VisiblePlayer == MoveGoal || VisiblePlayer == IntermediateMoveGoal )
		{
			if( ActorReachable( VisiblePlayer) )
			{
				`AILog( GetFuncName()$" My MoveGoal ("$MoveGoal$") is visible and reachable - calling stop latent execution and re-evaluate path", 'Move_DirectPath' );
				bReEvaluatePath = true;
				bDirectMoveToGoal = true;
				SetDestinationPosition( Enemy.Location );
				ReEvaluatePath();
				StopLatentExecution();
				return true;
			}
		}
	}
	return false;
}

// final function ForceSkipAheadUpdate()
// {
// 	//`AILog( GetFuncName()$"() Pawn Location: "$Pawn.Location$" SkipAheadLastUpdatePos: "$SkipAheadLastUpdatePos.Position$" "$Pawn.Location + vect(1.f,0,0) * 2.f * SkipAheadUpdateThreshold, 'Command_MoveToGoal' );
//
// 	//SetBasedPosition( SkipAheadLastUpdatePos, Pawn.Location + vect(1.f,0,0) * 2.0f * SkipAheadUpdateThreshold );
// 	//DrawDebugSphere( GetBasedPosition(SkipAheadLastupdatepos), 32, 8, 0, 255, 0, TRUE );
// }

/*********************************************************************************************
* Debugging
********************************************************************************************* */

/** Build debug string */
event String GetDumpString()
{
	if( GetBasedPosition( MovePosition ) != vect(0,0,0) )
	{
		return Super.GetDumpString()@"Point:"@GetBasedPosition(MovePosition)@"MoveFocus:"@MoveFocus@"Offset:"@MoveOffset@"IMG:"@IntermediateMoveGoal@"Focus:"@Focus@"MoveTarget:"@MoveTarget@"MySpeed:"@VSize(Pawn.Velocity);
	}
	else
	{
		return Super.GetDumpString()@"Destination:"@MoveGoal@"MoveFocus:"@MoveFocus@"Offset:"@MoveOffset@"IMG:"@IntermediateMoveGoal@"Focus:"@Focus@"MoveTarget:"@MoveTarget@"MySpeed:"@VSize(Pawn.Velocity);
	}
}

/** Notification that I should stop moving and build a new path to my goal */
function NotifyNeedRepath()
{
	`AILog( GetFuncName()$"() MoveTarget: "$(MoveTarget!=none?string(MoveTarget):"none")$" Dist: "$(MoveTarget!=none?VSize(MoveTarget.Location-Pawn.Location):0.f), 'PathWarning' );
	bReEvaluatePath = true;
	StopLatentExecution();
	ReEvaluatePath();
}

function CheckForStuckPath()
{
	local NavigationPoint NavPoint;

	// Failed to find a valid next move target
	if( IntermediateMoveGoal == none || (NumTimesGetNextMoveGoalReturnedSameNode > 20 && VSizeSQ(MyKFPawn.Velocity) < 600.f) )
	{
		`AILog("Failed to get valid movetarget, Got Same result "$NumTimesGetNextMoveGoalReturnedSameNode$" time(s). has reached move goal? "@HasReachedMoveGoal(), 'PathWarning');
		//`RecordAIGetNextMoveGoalFailure( Outer,Pawn.Location,Pawn.Rotation,MoveGoal,"GNML Fail, Int. = "$IntermediateMoveGoal );

		bValidRouteCache = false;
		bReevaluatePath = true;
		NumTimesGetNextMoveGoalReturnedSameNode = 0;

		// Path is failing - if I just ran into a non-pawn obstruction, temporarily block IntermediateMoveGoal to let me
		// generate another path that doesn't require it.
		if( Pawn.Anchor != none && (LastHitWall != none && !LastHitWall.IsA('Pawn')) )
		{
			NavPoint = NavigationPoint( IntermediateMoveGoal );
			if( CurrentPath != none && CreateTemporaryBlockedReach(NavPoint, CurrentPath) )
			{
				//`RecordAIRedirectedPath( Outer, IntermediateMoveGoal, "[HPO]Path:"$IntermediateMoveGoal$" and "$RouteCache[1] );
			}
			else if( NavPoint != none && CreateTemporaryBlockedPath(NavPoint) )
			{
				//`RecordAIGetNextMoveGoalFailure( Outer,Pawn.Location,Pawn.Rotation,MoveGoal,"GNML Fail, Int. = "$IntermediateMoveGoal );
			}
		}

		UpdateHistoryString( "[F] [GNM] "$IntermediateMoveGoal$" "$Pawn.Location );
		GotoState( 'MovingToGoal', 'FailedMove' );
		IntermediateMoveGoal = none;
	}
	else
	{
		`AILog( "NextMoveTarget"@IntermediateMoveGoal@"MoveGoal:"@MoveGoal, 'Move_Path' );
	}
}

/*********************************************************************************************
* Base movement state
********************************************************************************************* */
state MovingToGoal
{
	function bool NotifyHitWall( vector HitNormal, actor Wall )
	{
		local KFDoorActor Door;

		DisableNotifyHitWall( 0.2f );
		`AILog( "NotifyHitWall() while in MoveToGoal, HitNormal: "$HitNormal$" Wall: "$Wall$" LastHitWall: "$LastHitWall$" WallHitCount: "$WallHitCount$" MoveTarget: "$MoveTarget, 'PathWarning' );
		AIActionStatus = "Received NotifyHitWall event";

		if( !Wall.bStatic )
		{
			Door = KFDoorActor( Wall );
			if( Door == none )
			{
				`AILog( GetFuncName()$"() Wall: "$Wall$" HitNormal: "$HitNormal, 'HitWall' );
			}
			else
			{
				// Allow pawn to handle door bump events first
				if( MyKFPawn.HandleAIDoorBump(Door) )
				{
					return true;
				}

				if( Door.WeldIntegrity <= 0 && KFDoorMarker(Door.MyMarker) != none && !Door.IsCompletelyOpen() )
				{
					DisableNotifyHitWall(0.25f);
					WaitForDoor( Door );
					`AILog( "NotifyHitWall() while in MoveToGoal, Wall: "$Wall$" Using door and waiting for it to open", 'Doors' );
					Door.UseDoor( Pawn );

					return true;
				}
				// NOTE: Unless returning true, if the Wall is a closed door, SuggestMovePreparation event will be called on the associated KFDoorMarker
				`AILog( GetFuncName()$"() Wall: "$Wall$" HitNormal: "$HitNormal$" ran into a door!", 'Doors' );
				if( !Door.IsCompletelyOpen() && Door.WeldIntegrity > 0 && (Pawn.Anchor == Door.MyMarker || (DoorEnemy != none && (DoorEnemy == Door || PendingDoor == Door))) )
				{
					DisableNotifyHitWall(0.25f);
					`AILog( GetFuncName()$"() calling NotifyAttackDoor for "$Wall, 'Doors' );
					NotifyAttackDoor( Door );

					return true;
				}
			}
			if( Pawn.Physics == PHYS_Falling )
			{
				return true;
			}
		}

		if( LastHitWall != none && Wall != LastHitWall )
		{
			LastHitWall = none;
			WallHitCount = 0;
		}
		LastHitWall = Wall;
		//WallHitCount++; // TODO: ENABLE
		if( WallHitCount > 26 ) //26
		{
			if( IntermediateMoveGoal.IsA( 'KFPathnode' ) )
			{
				//UNCOMMENT	//NumTimesGetNextMoveGoalReturnedSameNode = 0; // new
				`AILog( GetFuncName()$"() Wall: "$Wall$" WallHitCount: "$WallHitCount$" Hit Wall > 3 times, setting "$IntermediateMoveGoal$" to be a blocked path and forcing a repath!", 'PathWarning' );
				WallHitCount++;
				LastHitWall = Wall;
				`RecordAIWall( `StatID(AI_FAILEDADJUSTFROMWALL), outer, Pawn.Location, Pawn.Rotation, Wall, "SuperSpeed: "$MyKFPawn.IsUsingSuperSpeed() );
				ForcePauseAndRepath(Wall);
				WallHitCount = 0;
				DisableNotifyHitWall(3.f);
				return true;
			}
		}
		return false;
	}

	function bool ShouldDelayMove()
	{
		//local NavigationPoint Nav;
		//local bool			  bResult;
		//local KFAIDirector KFAID;
		//
		if( bPreparingMove || MyKFPawn.IsDoingMeleeAttack() )
		{
			bGoalSurrounded = false;
			`AILog( "ShouldDelayMove returning TRUE because bPreparingMove", 'Command_MoveToGoal' );
			AIActionStatus = "Delaying Move";
			return true;
		}

// 		if( KFPawn(Enemy) != none && DoorEnemy == none && (Pawn.Anchor == none || !Pawn.Anchor.IsA('KFDoorActor')) )
// 		{
// 			if( KFPawn(Enemy).IsSurrounded( false, 4, 350.f ) && VSize(Enemy.Location - Pawn.Location) < 700.f )
// 			{
// 				`AILog( "Delaying move because "$Enemy$" is currently surrounded! Reachable? "$ActorReachable(Enemy), 'PathWarning' );
// 				if( WorldInfo.Game.GetNumPlayers() > 1 )
// 				{
// 					KFAID = KFGameInfo( WorldInfo.Game ).GetAIDirector();
// 					KFAID.FindEnemyFor( Outer, true );
// 				}
// 				AIActionStatus = "Delaying move because enemy surrounded";
// 				bGoalSurrounded = true;
// 				return true;
// 			}
// 		}
	//	bGoalSurrounded = false;
		return false;
	}

	/** Notification from controller that my enemy has changed (Enemy = my new enemy, OldEnemy = previous) */
	function NotifyEnemyChanged( optional Pawn OldEnemy )
	{
		// Notify child command first.
		if( CachedChildCommand != none )
		{
			CachedChildCommand.NotifyEnemyChanged( OldEnemy );
		}

		// If I'm pathfinding to my previous enemy, change my movegoal to the new enemy and build a new path
		if( MoveGoal != none && OldEnemy == MoveGoal || (IntermediateMoveGoal == none && IntermediateMoveGoal == OldEnemy) )
		{
			`AILog( GetFuncName()$"() Stopping latent execution, resetting destination position to new enemy location, and calling ReEvaluatePath()", 'SetEnemy' );
			MoveGoal = Enemy;
			StopLatentExecution();
			SetDestinationPosition( Enemy.Location );
			ReEvaluatePath();
		}
	}

	function NotifyDoorOpened()
	{
		// Notify child command first.
		if( CachedChildCommand != none )
		{
			CachedChildCommand.NotifyDoorOpened();
		}

		// Only allow movement if we're not in a special move that disables movement
		if( !MyKFPawn.IsDoingSpecialMove() || !MyKFPawn.SpecialMoves[MyKFPawn.SpecialMove].bDisableMovement )
		{
			bPreparingMove = false;
		}
	}

	/** Checks to see if my pawn can directly move to my enemy (directly reachable), rather than pathfinding */
	function FindDirectPath()
	{
		if( Enemy != none && !bDirectMoveToGoal && Pawn.Physics != PHYS_Spider )
		{
			`AILog( GetFuncName()$" event received, checking for direct reachability to enemy "$Enemy, 'Move_DirectPath' );
			// TODO: Look into not requiring enemy in this check, changing to MoveGoal should be safe
			if( InLatentExecution( LATENT_MOVETOWARD ) && MyKFPawn.Physics != PHYS_Falling /*&& MoveGoal == Enemy && Outer.MoveTarget != none*/ && ActorReachable( Enemy ) )
			{
				`AILog( GetFuncName()$" can directly reach enemy, stopping and resetting MoveTimer and resetting my move", 'Move_DirectPath' );
				// Stop pathfinding and move directly to my goal
				bDirectMoveToGoal = true;
				bReEvaluatePath = true;
				StopLatentExecution();
				SetDestinationPosition( Enemy.Location );
				ReEvaluatePath();
			}
		}
	}

	/** Returns the next valid MoveTarget (usually a NavigationPoint) in my path */
	final protected function bool GetNextMoveTarget( out Actor CurrentMoveTarget )
	{
		local bool bDone, bReachedDynamicAnchor;
		local Actor OldMoveTarget;

		`AILog(GetFuncName()@"current movetarget:"@CurrentMoveTarget@"routecache length:"@RouteCache.Length@"anchor"@Pawn.Anchor, 'Command_MoveToGoal');
		bGoalChangedDueToSkipAhead = false;
		OldMoveTarget = CurrentMoveTarget;
		while( !bDone && RouteCache.Length > 0 && RouteCache[0] != none )
		{
			/*
				[7/6/14]
				Need to check the date of this comment in source control history to see how long this code has been in use, but it's been awhile and I haven't
				seen the issue since that time. Prior to adding "LastNavGoalReached" related code, the most frequent movement failure was caused by this function
				returning the same MoveTarget repeatedly in some situations. The cause is detailed in the old comment below. It might be worth another look to
				make sure te ReachedDestination() result conflict described below isn't causing any other problems. The fix seems to have worked, however it's
				not fixing the root of the problem. I know there was/is an almost identical NavMesh issue with GetNextMoveLocation() returning the same destination
				repeatedly, if so it's either coincidental or the cause is probably in whatever reached checks are shared by the 2 systems.
				https://udn.unrealengine.com/questions/120379/navmesh-path-advancement-issues.html
				--------------------
				APawn::MoveToward (used by Crawler) and most likely KFPawn::MoveToward (used by non-crawlers) can sometimes consider a nav destination reached,
				while GetNextMoveTarget() considers it not reached. MoveToward calls the overloaded ReachedDestination, while script calls the native function which
				only accepts an actor rather than a position. When this happens, they are using slightly different destination positions to check for. Somewhere along
				the way from the start of the move, Dest becomes modified (probably from a call to SetDestinationPosition()) and used in MoveToward's ReachDestination()
				check while GetNextMoveTarget() most likely uses the node's location. Whatever the case, the 2 vectors are different and lead to MoveToward()
				considering the IntermediateMoveGoal to be reached, and GetNextMoveTarget() considering it not reached and attempting to use it again - then, 5 attempts later,
				the command fails. Need to make sure that MoveToward is really correct. So far it has been for the Crawler, but the Crawler's not a typical Pawn.

				Search for bReachedLatentMoveGoal and LastNavGoalReached for the code involved in fixing this.

				Good way to reproduce in KF-BurningParis:
				BugItGo -3518.6257 2585.0835 -551.9000 0 -213344 0
				SpawnDebugAI Crawler
				AIPathTo MetroTop3 (currently KFPathNode_298 - the problem occurs when Crawler is moving up wall to KFPathnode_267.. right before transition to ceiling, crawler stops due to
				GetNextMoveTarget() failure.
			*/
			if( (bReachedLatentMoveGoal && LastNavGoalReached == RouteCache[0]) || Pawn.ReachedDestination( RouteCache[0] ) )
			{
				bReachedLatentMoveGoal = false;
				`AILog( "Pawn has Reached route cache 0:"@RouteCache[0]$" DIST: "$VSize(RouteCache[0].Location - Pawn.Location), 'Command_MoveToGoal' );
				// If our move goal has been reached
				if( RouteCache[0] == MoveGoal )
				{
					// Clear move target and exit
					bDone			  = true;
					CurrentMoveTarget = none;
				}

				// MAKE SURE ANCHOR IS UPDATED -- this is cause of NO CURRENT PATH bug
				`AILog( "Setting anchor to RouteCache 0 ("$RouteCache[0]$")", 'Command_MoveToGoal' );
				Pawn.SetAnchor( RouteCache[0] );
				// If we reached a dynamic anchor, return true so we don't abort the move
				bReachedDynamicAnchor = ( DynamicAnchor(RouteCache[0]) != none );
				`AILog( "Remove from route:"@RouteCache[0]@bReachedDynamicAnchor, 'Command_MoveToGoal' );
				RouteCache_RemoveIndex( 0 );
			}
			else
			{
				`AILog( "I Did NOT reach route cache 0:"@RouteCache[0]$" Dist: "$VSize(RouteCache[0].Location - Pawn.Location), 'Command_MoveToGoal' );
				break;
			}
		}

		if( !bDone )
		{
			LastNavGoalReached = none;
			bReachedLatentMoveGoal = false;

			if( RouteCache.Length > 0 )
			{
				CurrentMoveTarget = RouteCache[0];
				`AILog( GetFuncName()$" setting CurrentMoveTarget to "$CurrentMoveTarget$" (RouteCache[0] ) OldMoveTarget was "$OldMoveTarget, 'Command_MoveToGoal' );
			}
			// Otherwise, if not moving directly to movegoal and movegoal is not a nav point, try moving directly to it
			else if( MoveGoal != none && CurrentMoveTarget != MoveGoal && NavigationPoint(MoveGoal) == none && ActorReachable(MoveGoal) )
			{
				CurrentMoveTarget = MoveGoal;
				`AILog( GetFuncName()$" Set CurrentMoveTarget to MoveGoal "$MoveGoal$" because move goal is now directly reachable. OldMoveTarget was "$OldMoveTarget, 'Command_MoveToGoal' );
			}
			else
			{
				`AILog( GetFuncName()$" setting CurrentMoveTarget to none!", 'Command_MoveToGoal' );
				CurrentMoveTarget = none;
			}
		}
		return bReachedDynamicAnchor || (OldMoveTarget != CurrentMoveTarget);
	}

	/** True if my pawn should rotate to face position */
	function bool ShouldTurnToGoal( vector TurnToLocation )
	{
		if( Pawn == none || !Pawn.IsAliveAndWell() )
		{
			return false;
		}

		return Pawn.NeedToTurn( TurnToLocation );
	}

	function bool CanDirectlyReach( actor Goal )
	{
		return ActorReachable( Goal );
	}

	function SetBestAnchor()
	{
// 		local NavigationPoint BestAnchor;
// 		local float Dist;
//
// 		BestAnchor = Pawn.GetBestAnchor( Pawn, Pawn.Location, true, false, Dist );
// 		if( BestAnchor != none )
// 		{
// 			Pawn.SetAnchor( BestAnchor );
// 		}
	}

/** Execution is often sent to CheckMove label to confirm goal is reached and finish command if so */
CheckMove:
	ClearTimer( 'MoveToGoalTimedOut', self );
	if( HasReachedMoveGoal() )
	{
		`AILog( "CheckMove label, I've reached my goal ", 'Command_MoveToGoal' );
		Goto( 'ReachedGoal' );
	}

/** Initial label when state begins */
Begin:
	Sleep(0.f);
	CurrentMovementPhase = MOVEMENT_PHASE_TYPE_NONE;

	if( MyKFPawn.Physics == PHYS_Falling )
	{
		/** My Pawn is falling, so stop executing state code until the pawn lands */
		WaitForLanding();
	}
	/** Reset for upcoming move */
	bReachedLatentMoveGoal = false;
	if( IsTimerActive(nameof(Timer_DelayMoveTimeOut), self) )
	{
		ClearTimer( nameof(Timer_DelayMoveTimeOut), self );
	}
	/** Abort move commands if Pawn's invalid or dead */
	if( Pawn == none || Pawn.Health <= 0 )
	{
		Status = 'Aborted';
		//AbortCommand();
		AbortMovementCommands( true, "Dead!" );
		AbortMovementPlugIns(true, "Dead" );
		/* Stop executing any more state code */
		Stop;
	}

	`AILog( "Attempting move to goal "$MoveGoal$" Valid? "$MoveGoalIsValid()$" MovePosition: "$MovePosition.Position$" BasedPosition: "$GetBasedPosition( MovePosition )$" MovePointIsValid? "$MovePointIsvalid()$" bValidRouteCache? "$bValidRouteCache, 'Command_MoveToGoal' );
	if( MoveGoalIsValid() )
	{
		/*********************************************************************************************
		* Moving toward an Actor (command was started with MoveToGoal())
		********************************************************************************************* */
		if( !bValidRouteCache && CanDirectlyReach(MoveGoal) && (!Pawn.bCrawler || (Abs(Pawn.Location.Z - MoveGoal.Location.Z) < 700.f)) )  // 6.6.14 Move crawler check to CanDirectlyReach()
		{
DirectMoveToActor:
            CurrentMovementPhase = MOVEMENT_PHASE_TYPE_EMT_LOS_MOVE_TOWARDS;
			AIActionStatus = "Moving Direct Path to "$MoveGoal;
			// MoveGoal is directly reachable, so start moving.
			StartingMove( true, VSize(Pawn.Location - MoveGoal.Location), 0, MoveGoal );
			// Estimate a reasonable TimeOut based on move distance
			TimeOutTime = GetMoveTimeOutDuration( MoveGoal.GetDestination(outer), false );
			SetTimer( TimeOutTime, false, nameof(self.MoveToGoalTimedOut), self );

			// This while loop helps catch cases interruption when a state is pushed
			LoopFailSafeCounter = 0;
			do
			{
				`AILog( "Moving directly to move goal:"@MoveGoal@"from"@Pawn.Anchor@"Focus"@MoveFocus@"Offset"@MoveOffset@CurrentPath, 'Move_DirectPath' );
				IntermediateMoveGoal = MoveGoal;
				/** Optionally make Pawn rotate to my IntermediateMoveGoal prior to moving */
				if( Pawn.Physics != PHYS_Falling && !bMovingToGoal && !IsDoingLatentMove() && MoveGoal != none )
				{
					/** ...Only if enough time has passed since my last move (LastMoveFinishTime is set by AKFPawn::moveToward() when dest is reached */
					if( `TimeSince(LastMoveFinishTime) > 5.f && ShouldTurnToGoal(IntermediateMoveGoal.Location) )
					{
						TurnFocus = IntermediateMoveGoal;
						/** Push the RotateToFocus state, which will rotate my pawn and return here after my pawn is finished rotating */
						PushState( 'RotateToFocus' );
					}
				}
			//	bPreciseDestination = true;
				AIActionStatus = "Moving directly toward "$IntermediateMoveGoal;
				/** Begin latent move, state code execution will resume after the move is finished/interrupted/etc. */
				MoveToward( IntermediateMoveGoal, MoveFocus, MoveOffset, false, false );
				if( (bReachedLatentMoveGoal && LastNavGoalReached == IntermediateMoveGoal ) || Pawn.ReachedDestination( IntermediateMoveGoal ) )
				{
					ReachedIntermediateMoveGoal();
				}
				/** Move finished, wait until my pawn has landed if the move managed to make it fall */
				if( MyKFPawn.Physics == PHYS_Falling )
				{
					WaitForLanding();
				}
			} until( HasReachedMoveGoal() || !ActorReachable(MoveGoal) || LoopFailSafeCounter++ > 50 );
			CurrentMovementPhase = MOVEMENT_PHASE_TYPE_NONE;
			// Go to the CheckMove label which will decide what to do next.
			Goto( 'CheckMove' );
		}
		else if( bValidRouteCache && RouteCache.Length > 0 )
		{
			// I can't directly reach MoveGoal, and I already have a valid path, so skip generating a new path.
			IntermediateMoveGoal = (RouteCache.Length > 0) ? RouteCache[0] : none;
			bValidRouteCache = false;
		}
		else
		{
			// I can't directly reach MoveGoal, and I need to generate a new path to it.
			bValidRouteCache = false;
			IntermediateMoveGoal = FindPathToward( MoveGoal );
			// Invalidate anchor if path generation fails
			if( IntermediateMoveGoal == none )
			{
				InvalidateAnchor( Pawn.Anchor );
			}
		}
	}
	else if( MovePointIsValid() )
	{
		/*********************************************************************************************
		* Moving to a location (command was started with MoveToPoint())
		********************************************************************************************* */

		if( PointReachable(GetBasedPosition(MovePosition)) )
		{
DirectMoveToPosition:
			CurrentMovementPhase = MOVEMENT_PHASE_TYPE_PATHNODE_POINT_MOVE_TO;
            // MovePosition is a directly reachable location, no need to pathfind
			StartingMove( true, VSize(Pawn.Location - GetBasedPosition(MovePosition)), 0, none );

			// Move directly to it (this while loop helps catch cases interruption when a state is pushed)
			TimeOutTime = GetMoveTimeOutDuration( GetBasedPosition(MovePosition), false );
			SetTimer( TimeOutTime, false, nameof(self.MoveToGoalTimedOut), self );
			do
			{
				`AILog( "Moving directly to move point:"@GetBasedPosition( MovePosition )@"from"@Pawn.Anchor@"Focus"@MoveFocus@Pawn.Location, 'Move_Path' );
				EnableSeePlayer();
				if( `TimeSince(LastMoveFinishTime) > 5.f && ShouldTurnToGoal(GetBasedPosition( MovePosition )) )
				{
					TurnFocalPoint = GetBasedPosition( MovePosition );
					PushState( 'RotateToFocus' );
				}
				/** Begin latent movement and stop executing state code until move completes */
				MoveTo( GetBasedPosition( MovePosition ), MoveFocus,, false );
				/** Move finished, wait until my pawn has landed if the move managed to make it fall */
				if( MyKFPawn.Physics == PHYS_Falling )
				{
					WaitForLanding();
				}
			} until( HasReachedMoveGoal() || !PointReachable(GetBasedPosition(MovePosition)) );
			CurrentMovementPhase = MOVEMENT_PHASE_TYPE_NONE;
			// Go to the CheckMove label which will decide what to do next.
			Goto( 'CheckMove' );
		}
		else if( bValidRouteCache )
		{
			// I can't directly reach MovePosition, and I already have a valid path, so skip generating a new path.
			IntermediateMoveGoal = (RouteCache.Length > 0) ? RouteCache[0] : none;
			bValidRouteCache = false;
		}
		else
		{
			// I can't directly reach MovePosition, and I need to generate a new path to it.
			IntermediateMoveGoal = FindPathTo( GetBasedPosition( MovePosition ) );
			if( IntermediateMoveGoal == none )
			{
				`AILog( self$" IntermediateMoveGoal is null, so calling InvalidateAnchor for nav "$Pawn.Anchor, 'PathWarning' );
				InvalidateAnchor( Pawn.Anchor );
			}
		}
	}
FollowingPath:
	if( IntermediateMoveGoal != none )
	{
        if( MoveGoal != none ) { `AILog("Following path to move goal:"@MoveGoal@"from"@Pawn.Anchor, 'Move_Path' );	}
		else				   { `AILog("Following path to move point:"@GetBasedPosition(MovePosition)@"from"@Pawn.Anchor, 'Move_Path' );	}

		GetNextMoveTarget( IntermediateMoveGoal );
		// If first navigation point is my pawn's anchor, and the next navigation point is directly reachable...
		if( IntermediateMoveGoal == Pawn.Anchor && RouteCache.Length > 1 && ActorReachable(RouteCache[1]) )
		{
			`AILog( "Already at anchor, move to next..."@Pawn.Anchor@RouteCache[1], 'Move_Path' );
			// Remove the anchor from my route and try to use the next navigation point
			RouteCache_RemoveIndex( 0 );
			GetNextMoveTarget( IntermediateMoveGoal );
		}
		if( IntermediateMoveGoal == none )
		{
			`AILog( "Failed to acquire move target, sleeping for 0.5 seconds and going to CheckMove label", 'Move_Path' );
			Sleep( 0.5f );
			// Go to the CheckMove label which will decide what to do next.
			Goto( 'CheckMove' );
		}
	//	Retries = 0;  // New, check!
		ClearTimer( 'MoveToGoalTimedOut', self );
		while( IntermediateMoveGoal != none )
		{
			`AILog( "Still moving to"@IntermediateMoveGoal$" which is "$VSize( Pawn.Location - IntermediateMoveGoal.Location )$" units away", 'Move_Path' );
			// Check for any global interrupts (enemy with melee range)
			CheckInterruptCombatTransitions();
			// If Pawn cannot strafe, then face destination before moving
			if( !Pawn.bCanStrafe )
			{
				`AILog( "Pushing RotateToFocus state", 'Move_Path' );
				PushState( 'RotateToFocus' );
			}

			// Check if we should delay our move a little
			LastDetourCheckTime = WorldInfo.TimeSeconds;
			if( ShouldDelayMove() )
			{
				SetTimer( 20.f, false, nameof(Timer_DelayMoveTimeOut), self );
			}
DelayMove:
			while( ShouldDelayMove() )
			{
				CurrentMovementPhase = MOVEMENT_PHASE_TYPE_PATHNODE_DELAY_MOVE;
                AIActionStatus = "Delaying move";
				bDirectMoveToGoal = false;
				`AILog( "Delaying move, LastDetourCheckTime: "$`TimeSince(LastDetourCheckTime), 'Move_Path' );
				AIZeroMovementVariables();
				// If it's been a while since our last detour check
				if( `TimeSince( LastDetourCheckTime ) > 5.0f )
				{
					`AILog( "Attempting to restart move after delaying", 'Move_Path' );
					// Restart the move
					LastDetourCheckTime = WorldInfo.TimeSeconds;
					bValidRouteCache = false;
					// Go to the CheckMove label which will decide what to do next.
					Goto( 'CheckMove' );
				}
				if( Pawn != none && Pawn.Physics != PHYS_Spider )
				{
					Focus = IntermediateMoveGoal;
				}
				if( PendingDoor != none && bPreparingMove && PendingDoor.WeldIntegrity > 0 && !PendingDoor.IsCompletelyOpen() )
				{
					if( `FastTracePhysX(PendingDoor.Location, Pawn.Location) )
					{
						AIActionStatus = "Wants to attack door "$PendingDoor;
						NotifyAttackDoor( PendingDoor );
					}
				}
				Sleep( 0.1f );
			}
			CurrentMovementPhase = MOVEMENT_PHASE_TYPE_NONE;
PathingTowardActor:
            CurrentMovementPhase = MOVEMENT_PHASE_TYPE_PATHNODE_NORMAL_MOVE_TO;
			ClearTimer( nameof(Timer_DelayMoveTimeOut), self );
			// Setup the next move
			StartingMove( false, GetRouteCacheDistance(), RouteCache.Length, IntermediateMoveGoal);
			// if the goal has been changed in between that last time we called getnextmovegoal and now, we need to go to the new goal!
			if( bGoalChangedDueToSkipAhead )
			{
				`AILog( "RouteCache changed out from under us.. calling GetNextMoveTarget again!", 'Move_Path' );
				if( !GetNextMoveTarget(IntermediateMoveGoal) )
				{
					`AILog( "GetNextMoveTarget FAILED after skipahead changed the route cache.. Aborting move", 'PathWarning' );
					// issue with movetarget not changing
					IntermediateMoveGoal = none;
					break;
				}
			}
			Outer.SetDirectPathCheckTime();
			EnableSeePlayer();
			if( Pawn.Physics != PHYS_Falling && !bMovingToGoal && !IsDoingLatentMove() && MoveGoal != none )
			{
				if( `TimeSince(LastMoveFinishTime) > 5.f && ShouldTurnToGoal(IntermediateMoveGoal.Location) )
				{
					TurnFocus = IntermediateMoveGoal;
					PushState( 'RotateToFocus' );
				}
			}

		//	bPreciseDestination = true;
			AIActionStatus = "Moving toward "$IntermediateMoveGoal;
			/** Begin latent movement and stop executing state code until move completes */
			MoveToward( IntermediateMoveGoal, MoveFocus, (IntermediateMoveGoal == MoveGoal) ? MoveOffset : 0.f, false, false );
			AIActionStatus = "Finished moving toward "$IntermediateMoveGoal;
			CurrentMovementPhase = MOVEMENT_PHASE_TYPE_NONE;
			if( (bReachedLatentMoveGoal && LastNavGoalReached == IntermediateMoveGoal) || Pawn.ReachedDestination(IntermediateMoveGoal) )
			{
				`AILog( "MoveToward finished and I reached my intermediate goal ("$IntermediateMoveGoal$") which is "$VSize(IntermediateMoveGoal.Location - Pawn.Location)$" units away", 'Move_Path' );
				ReachedIntermediateMoveGoal();
			}
			/** Move finished, wait until my pawn has landed if the move managed to make it fall */
			if( MyKFPawn.Physics == PHYS_Falling )
			{
				WaitForLanding();
				bReevaluatePath = true;
			}
			if( bReevaluatePath )
			{
				ReEvaluatePath();
			}
			else if( bGoalChangedDueToSkipAhead )
			{
				`AILog( "path was changed during movetoward", 'Move_Path' );
				IntermediateMoveGoal = none;
			}

			/** If we are moving towards a Pawn, repath every time we successfully reach the next node as that Pawn's movement
				may cause the best path to change */
			if( Pawn(MoveGoal) != none && Pawn.ReachedDestination(IntermediateMoveGoal)
				&& VSizeSq(MoveGoal.Location - GetBasedPosition(LastPawnTargetPathLocation)) > 589824.f )
			{
				ReachedIntermediateMoveGoal();
				SetBasedPosition( LastPawnTargetPathLocation, MoveGoal.Location );
				`AILog( "Repathing because MoveGoal is a Pawn:"@MoveGoal, 'Command_MoveToGoal' );
				// Go to the CheckMove label which will decide what to do next.
				Goto( 'CheckMove' );
			}
			else if( IntermediateMoveGoal == MoveGoal && HasReachedMoveGoal() )
			{
				// Reached my MoveGoal, go to the CheckMove label which will decide what to do next.
				Goto( 'CheckMove' );
			}
			else
			{
				if( GetNextMoveTarget(IntermediateMoveGoal) )
				{
					// Reset counter if I've gotten a valid next move target
					NumTimesGetNextMoveGoalReturnedSameNode = 0;
				}
				else
				{
					// GetNextMoveTarget()'s result wasn't valid, so count it, reset my pawn's anchor, and delay.
					NumTimesGetNextMoveGoalReturnedSameNode++;
					SetBestAnchor();
					Sleep( 0.1f );
				}

				CheckForStuckPath();
			}
		}

		if( GetBasedPosition(MovePosition) != vect(0,0,0) )
		{
			/*********************************************************************************************
			* Moving to a location (command was started with MoveToPoint())
			********************************************************************************************* */
DirectMoveToPositionTwo:
			while( !HasReachedMoveGoal() )
			{
                CurrentMovementPhase = MOVEMENT_PHASE_TYPE_PATHNODE_POINT_MOVE_TO;
				if( !PointReachable( GetBasedPosition(MovePosition)) )
				{
					UpdateHistoryString( "[F] [!POINTREACHABLE] "$Pawn.Location );
					Sleep( 0.25f );
					/** Give up and go to the FailedMove label */
					Goto( 'FailedMove' );
				 }

				// Finish up direct move
				`AILog( "Finishing direct move, calling MoveTo "$GetBasedPosition(MovePosition), 'Move_DirectPath' );
				if( `TimeSince(LastMoveFinishTime) > 5.f && ShouldTurnToGoal(GetBasedPosition(MovePosition)) )
				{
					TurnFocalPoint = GetBasedPosition( MovePosition );
					PushState( 'RotateToFocus' );
				}
				/** Begin latent movement and stop executing state code until move completes */
				MoveTo( GetBasedPosition(MovePosition), MoveFocus,, false );
				CurrentMovementPhase = MOVEMENT_PHASE_TYPE_NONE;
				/** Move finished, wait until my pawn has landed if the move managed to make it fall */
				if( MyKFPawn.Physics == PHYS_Falling )
				{
					WaitForLanding();
				}
			}
		}
	}
	else if( !HasReachedMoveGoal() ) 	// Otherwise, if haven't reached move goal
	{
		UpdateHistoryString( "[F] [NO PATH TO "$MOVEGOAL$"] "$Pawn.Location );
		if( MoveGoal != none ) { `AILog( "Failed to find path to:"@MoveGoal, 'Command_MoveToGoal'  ); }
		else				   { `AILog( "Failed to find path to:"@GetBasedPosition(MovePosition), 'PathWarning' ); }

		Sleep( 0.25f );
		 /** Give up and go to the FailedMove label */
		Goto( 'FailedMove' );
	}
	/** Go to the CheckMove label which will decide what to do next */
	Goto( 'CheckMove' );

FailedMove:
	`AILog( "FailedMove Label", 'PathWarning' );
	UpdateHistoryString( "Failure - FailedMove Label" );
	if( Pawn.bCrawler && Pawn.Floor != vect(0,0,1) && Pawn.Physics == PHYS_Spider )
	{
// 		if( Retries < 5 && IntermediateMoveGoal != none && CurrentPath != none && WallReachSpec(CurrentPath) != none && WallReachSpec(CurrentPath).IsWallToCeiling() )
// 		{
// 			bValidRouteCache = false;
// 			if( bPreparingMove && PendingDoor == none )
// 			{
// 				bPreparingMove = false;
// 			}
// 			bReevaluatePath = true;
// 			Sleep( 0.f );
// 			IntermediateMoveGoal = none;
// 			Retries++;
// 		//	SetBestAnchor();
// 			ReEvaluatePath();
// 		}
// 		else
 		if( Retries < 5 )
		{
			Pawn.SetPhysics( PHYS_Falling );
			WaitForLanding();
			bValidRouteCache = false;
			if( bPreparingMove && PendingDoor == none && (!MyKFPawn.IsDoingSpecialMove() || !MyKFPawn.SpecialMoves[MyKFPawn.SpecialMove].bDisableMovement) )
			{
				bPreparingMove = false;
			}
			bReevaluatePath = true;
			Sleep( 0.f );
			IntermediateMoveGoal = none;
			Retries++;
		//	SetBestAnchor();
			ReEvaluatePath();
		}
	}
	else if( Retries < 5 )
	{
		bValidRouteCache = false;
		if( bPreparingMove && PendingDoor == none && (!MyKFPawn.IsDoingSpecialMove() || !MyKFPawn.SpecialMoves[MyKFPawn.SpecialMove].bDisableMovement) )
		{
			bPreparingMove = false;
		}
		bReevaluatePath = true;
		Sleep( 0.f );
		IntermediateMoveGoal = none;
		Retries++;
	//	SetBestAnchor();
		ReEvaluatePath();
		Sleep( 0.f );
	}
	else if( Retries >= 5 && Retries < 10 )
	{
		bValidRouteCache = false;
		if( bPreparingMove && PendingDoor == none && (!MyKFPawn.IsDoingSpecialMove() || !MyKFPawn.SpecialMoves[MyKFPawn.SpecialMove].bDisableMovement) )
		{
			bPreparingMove = false;
		}
		bReevaluatePath = true;
		Sleep( 0.f );
		if( IntermediateMoveGoal != none && NavigationPoint(IntermediateMoveGoal) != none )
		{
			// Path is failing - if I just ran into a non-pawn obstruction, temporarily block IntermediateMoveGoal to let me
			// generate another path that doesn't require it.
			if( CreateTemporaryBlockedReach(NavigationPoint(IntermediateMoveGoal), CurrentPath) )
			{
				IntermediateMoveGoal = none;
				Retries++;
		//		SetBestAnchor();
				ReEvaluatePath();
				Sleep( 0.f );
			}
			else
			{
				Retries = 0;
				Status = 'Failure';
				GotoState('DelayFailure');
				Stop;
			}
		}
	}
	else
	{
		Retries = 0;
		Status = 'Failure';
		GotoState('DelayFailure');
		Stop;
	}

ReachedGoal:
	if( MoveGoal != none ) { `AILog("Reached move goal:"@MoveGoal@VSize(Pawn.Location-MoveGoal.Location), 'Command_MoveToGoal'); }
	else				   { `AILog("Reached move point:"@GetBasedPosition(MovePosition)@VSize(Pawn.Location-GetBasedPosition(MovePosition)), 'Command_MoveToGoal'); }

	Status = 'Success';
	PopCommand( self );
}

/**
 *	Command has failed but delay pop to avoid infinite recursion
 */
state DelayFailure
{
Begin:
    CurrentMovementPhase = MOVEMENT_PHASE_TYPE_PATHNODE_FAILED_MOVE;
	Sleep( 0.5f );

	Status = 'Failure';
	CurrentMovementPhase = MOVEMENT_PHASE_TYPE_NONE;
	PopCommand( self );
}

state RotateToFocus
{
Begin:
	CurrentMovementPhase = MOVEMENT_PHASE_TYPE_PATHNODE_ROTATE_TO_FOCUS;
	if( Pawn.Physics == PHYS_Falling )
	{
		WaitForLanding();
	}

	if( TurnFocalPoint != vect(0,0,0) )
	{
		Focus = none;
		SetFocalPoint( TurnFocalPoint );
	}
	else
	{
		SetFocalPoint( vect(0,0,0) );
		Focus = TurnFocus;
	}
	FinishRotation();
	MyKFPawn.ResetDesiredRotation();
	TurnFocalPoint = vect(0,0,0);
	CurrentMovementPhase = MOVEMENT_PHASE_TYPE_NONE;
	PopState();
}

function Timer_DelayMoveTimeOut()
{
	if( MyKFPawn != none && MyKFPawn.IsAliveAndWell() )
	{
		`AILog( "************* "$MyKFPawn$" DELAYING MOVE FOR OVER 20 SECONDS" );
	}
}

native function bool AdjustAround( Actor Other, vector HitNormal );

function bool NotifyBump( Actor Other, Vector HitNormal )
{
	local KFPawn KFP;
	//local KFAIController OtherKFAIC;

	if( IsDoingLatentMove() && MyKFPawn.Physics == PHYS_Walking )
	{
		KFP = KFPawn(Other);

		if( KFP != none )
		{
			`AILog( "NotifyBump in MoveToGoal, Other: "$Other$" HitNormal: "$HitNormal, 'BumpEvent' );
			DisableBump( 0.12f );
			if ( (!KFP.IsAliveAndWell() || !Pawn.IsSameTeam( KFP )) )  //|| (P.Controller == none)
			{
				return false;
			}
			if( KFDoorMarker(MoveTarget) != none )
			{
				if( PendingDoor == none && !KFDoorMarker(MoveTarget).MyKFDoor.IsCompletelyOpen() && VSizeSQ(MoveTarget.Location - MyKFPawn.Location) < 122500.f )
				{
					WaitForDoor( KFDoorMarker(MoveTarget).MyKFDoor );
					return true;
				}
			}
			// Skip if closer than 400uu to enemy and bumped Zed's enemy matches mine
 			if( KFP.MyKFAIC != none && KFP.MyKFAIC.Enemy != none && Enemy != none && KFP.MyKFAIC.Enemy == Enemy
                && KFP.MyKFAIC.IsDoingLatentMove() && VSizeSQ(Enemy.Location - KFP.Location) < 160000.f )
			{
				return false;
			}
		}

		// Don't adjust around a non-walking pawn, causes odd results
		if( Other.Physics == PHYS_Walking )
		{
			AdjustAround( Other, HitNormal );
		}
		return true;
	}
	return false;
}

function bool NotifyLatentPostPhysWalking()
{
	if( !bPreparingMove && MoveTimer > 1.f && Pawn.Velocity == vect(0,0,0) && Pawn.Acceleration != vect(0,0,0) )
	{
		++NumFailedLatentWalkMoves;
		if( NumFailedLatentWalkMoves > 3 )
		{
			MoveTimer = -1;
			NumFailedLatentWalkMoves = 0;
			return true;
		}
	}
	else
	{
		NumFailedLatentWalkMoves = 0;
	}

	return false;
}

defaultproperties
{
	SkipAheadUpdateThreshold=500.f
	SkipAheadMaxNodes=15
	SkipAheadMaxDist=4096.f
	SkipAheadPitCheckInterval=300.f
	SkipAheadPitCheckHeight=250.f
	SkipAheadCurrentTestingIndex=0
	bCanPathfind=true
	bEnableSkipAheadChecks=false
}
