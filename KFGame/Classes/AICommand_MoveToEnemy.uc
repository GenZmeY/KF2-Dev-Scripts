//=============================================================================
// AICommand_MoveToEnemy
//=============================================================================
// Base command for moving to enemy - will build path and call MoveToGoal
// command to start the movement.
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//=============================================================================

class AICommand_MoveToEnemy extends AICommand
	within KFAIController;

var Actor			Path, Find;
var float			Radius;
/** Number of times remaining we can fail the MoveToGoal before we give up */
var int				MoveTriesRemaining;
/** If this is true, we will move all the way to the enemy instead of just to the first goal */
var bool			bCompleteMove;
/** How close to get to the enemy (only valid of bCompleteMove is true) */
var float			GoalDistance;
/** If enemy gets this far from us we should abandon the move */
var float			AbandonDistance;
/** Last location of enemy... if they've moved too much, redo pathing */
var BasedPosition	LastEnemyLocation;
/** Are we allowed to fire during this move? */
var bool			bAllowedToAttackDuringMove;
/** If the enemy moves more than this distance away from where it was when we pathed, repath */
var float			RepathDistance;
/** override for movement focus */
var Actor			OverrideFocus;

/*********************************************************************************************
* Push/Pause/Pop/Init
********************************************************************************************* */

/** Simple constructor that pushes a new instance of the command for the AI */
static function bool MoveToEnemy( KFAIController AI, bool bInCompleteMove, float InGoalDistance, float InAbandonDistance, optional bool bInAllowedToAttackDuringMove=true, optional actor InFocusOverride=none )
{
	local AICommand_MoveToEnemy Cmd;

	if( AI != None && AI.Pawn != None )
	{
		Cmd = new(AI) class'AICommand_MoveToEnemy';
		if( Cmd != None )
		{
			Cmd.bCompleteMove				= bInCompleteMove;
			Cmd.GoalDistance				= InGoalDistance;
			Cmd.AbandonDistance				= InAbandonDistance;
			Cmd.bAllowedToAttackDuringMove	= bInAllowedToAttackDuringMove;
			Cmd.OverrideFocus				= InFocusOverride;
			AI.PushCommand( Cmd );
			return true;
		}
	}

	return false;
}

function Pushed()
{
	`AILog( self@GetFuncName()$"() current dist to enemy: "$VSize(Enemy.Location - Pawn.Location), 'Command_MoveToEnemy' );
	Super.Pushed();
	bMovingToEnemy = true;
	SprintTimer();
	SetTimer( 1.5f + FRand(), false, nameof( SprintTimer ), self );
	GotoState( 'Moving' );
}

function Popped()
{
	if( Pawn != none && Enemy != none )
	{
		`AILog( self@GetFuncName()$"() current dist to enemy: "$VSize(Enemy.Location - Pawn.Location), 'Command_MoveToEnemy' );
	}
	Super.Popped();
	`AILog( self@GetFuncName()$"()", 'Command_MoveToEnemy' );
	ClearTimer( 'CheckReachedEnemy', self );
	ClearTimer( nameof(CheckEnemyMoved), self );
	ClearTimer( nameof(self.DirectMoveTimeout),self );

	bFailedToMoveToEnemy = ( Status != 'Success' );
	bMovingToEnemy = false;
 	if( bFailedToMoveToEnemy )
 	{
 		if( Pawn != none )
  			UpdateHistoryString( "Popped but failed to move to enemy at "$Pawn.Location$" Time: "$WorldInfo.TimeSeconds );
 	}
}

function Paused( GameAICommand NewCommand )
{
	Super.Paused( NewCommand );
	if( Enemy != none )
	{
		`AILog( GetFuncName()$" "$self$" Paused, replaced by "$NewCommand$" [and dist to enemy: "$VSize(Enemy.Location - Pawn.Location)$"]", 'Command_MoveToEnemy' );
	}
	PauseTimer( true, 'CheckReachedEnemy', self );
	PauseTimer( true, nameof(CheckEnemyMoved), self );
	PauseTimer( true, nameof(self.DirectMoveTimeout),self );
}

function Resumed( name OldCommandName )
{
	Super.Resumed( OldCommandName );
	if( Enemy != none )
	{
		`AILog( GetFuncName()$" "$self$" Resumed, OldCommand: "$OldCommandName$" [and dist to enemy: "$VSize(Enemy.Location - Pawn.Location)$"]", 'Command_MoveToEnemy' );
	}
	PauseTimer( false, 'CheckReachedEnemy', self );
	PauseTimer( false, nameof(CheckEnemyMoved), self );
	PauseTimer( false, nameof(self.DirectMoveTimeout),self );

	if( !bCompleteMove )
	{
		`AILog( GetFuncName()$"() popping command because !bCompleteMove on resume", 'Command_MoveToEnemy' );
		Status = ChildStatus;
		PopCommand( self );
	}
}

/*********************************************************************************************
* Combat related
********************************************************************************************* */

function bool NotifyPlayerBecameVisible( Pawn VisiblePlayer )
{
	if( CachedChildCommand != None )
	{
		`AILog( GetFuncName()$"() Seen: "$VisiblePlayer$" notifying "$CachedChildCommand$" and letting it handle the event.", 'SeePlayer' );
		return CachedChildCommand.NotifyPlayerBecameVisible( VisiblePlayer );
	}
	`AILog( GetFuncName()$" "$VisiblePlayer$" ignoring this event", 'SeePlayer' );
	return false;
}

/*********************************************************************************************
* Movement & Pathfinding
********************************************************************************************* */

function SprintTimer()
{
	if( MyKFPawn != none && MyKFPawn.IsAliveAndWell() && Enemy != none )
	{
		if( VSize( Pawn.Velocity ) > 0.f )
		{
			UpdateSprintFrustration();
			if( ShouldSprint() || MyKFPawn.bSprintOverride)
			{
				MyKFPawn.SetSprinting( true );
			}
			else
			{
				MyKFPawn.SetSprinting( false );
			}
		}
	}

	SetTimer( 1.5f + FRand(), false, nameof( SprintTimer ), self ); // ToDo: Disable
}

function CheckReachedEnemy()
{
	local float DistToEnemySq;

	// only abort if we don't have a child, or our child is a move command.. otherwise let it slide
	if( ChildCommand == none || (ChildCommand.IsA('AICommand_MoveToGoal') && ChildCommand.ChildCommand == none) )
	{
		if( Enemy != None || !Enemy.IsAliveAndWell() )
		{
			DistToEnemySq = VSizeSq(Enemy.Location-Pawn.Location);
			`AIlog( GetFuncName()$"() Dist: "$VSize(Enemy.Location-Pawn.Location)$" GoalDistance: "$GoalDistance$" checking IsWithinAttackRange()", 'ReachedEnemy');

			if( IsDoingAttackSpecialMove() )
			{
				`AILog( GetFuncName()$"() IsWithinAttackRange(): I've reached enemy (Dist:"$Sqrt(DistToEnemySq)$") calling AbortCommand", 'ReachedEnemy' );
// 				if( !MyKFPawn.IsPawnMovingAwayFromMe( Enemy ) )
// 				{
 					AbortCommand( self );
// 				}
			}
			else if( AbandonDistance > 0.f && DistToEnemySq >= AbandonDistance*AbandonDistance )
			{
				`AILog( self$" Move took us outside abandon dist...", 'ReachedEnemy' );
				AbortCommand( self );
			}
		}
		else
		{
			`AILog( "Enemy is no longer valid, aborting command", 'ReachedEnemy' );
			AbortCommand( self );
		}
	}
	else
	{
		if( ChildCommand == none )
		{
			`AILog( GetFuncName()$"() skipping reached evaluation because ChildCommand is NONE", 'ReachedEnemy' );
		}
		else if( ChildCommand.IsA('AICommand_MoveToGoal') && ChildCommand.ChildCommand == none )
		{
			`AILog( GetFuncName()$"() skipping reached evaluation because ChildCommand is a MoveToGoal command and has no child of its own", 'ReachedEnemy' );
		}
	}
}

function CheckEnemyMoved()
{
	local float DistSq;

	`AILog( GetFuncName(), 'Command_MoveToEnemy' );
	if(Find != none)
	{
		DistSq = VSizeSq( Find.Location - BP2Vect(LastEnemyLocation) );
		if( DistSq > RepathDistance*RepathDistance && !IsValidDirectMoveGoal(Find) )
		{
			if(ChildCommand!=none)
			{
// 				if( !MyKFPawn.IsPawnMovingAwayFromMe( Enemy ) )
// 				{
// 					MoveTriesRemaining=default.MoveTriesRemaining+1;
// 					AbortCommand(ChildCommand);
// 				}
			}
		}
	}
}

function DirectMoveTimeout()
{
	`AILog( GetFuncName()$"() - not doing anything, though.", 'Command_MoveToEnemy' );
// 	if( !MyKFPawn.IsPawnMovingAwayFromMe( Enemy ) )
// 	{
// 		`AILog("Was moving directly to enemy, but it took too long and we were bCompleteMove=false, aborting");
// 		AbortCommand(self);
// 	}
}

/*********************************************************************************************
* Debug
********************************************************************************************* */

/** Build debug string */
event String GetDumpString()
{
	return Super.GetDumpString()@Enemy@GoalDistance@bCompleteMove;
}

/*********************************************************************************************
* Moving to Enemy State
********************************************************************************************* */

function JumpToTarget()
{
	local Vector Suggested;

	if( Enemy != none )
	{
		MyKFPawn.SuggestJumpVelocity( Suggested, Enemy.Location, Pawn.Location );
		MyKFPawn.Velocity = Suggested;
		MoveTarget = Enemy;
		//MyKFPawn.Acceleration = vect( 0,0,0 );
		MyKFPawn.SetPhysics( PHYS_Falling );
	}
}

state Moving `DEBUGSTATE
{
Begin:
	if( MyKFPawn.Physics == PHYS_Falling )
	{
		WaitForLanding();
	}

	`AILog( "[Begin Label]"@GetSTatename(), 'Command_MoveToEnemy');
	// UnMark failure to move
	bFailedToMoveToEnemy = false;

	if( Enemy == None )
	{
		SelectEnemy();
	}

	if( Enemy != none && !IsDoingAttackSpecialMove() && MoveIsInterruptable() )
	{
		`AILog( "Found valid enemy: "$Enemy, 'Command_MoveToEnemy' );
		bReachedMoveGoal = false;

		Radius = Pawn.GetCollisionRadius() + Enemy.GetCollisionRadius() + Pawn.MeleeRange + 1.0;
		//[NEW] Commented out 10/10
		Radius = FMax( 0.f, GoalDistance - Radius ); // subtract because collision radius already considered by ReachedDestination()
		Find = Enemy;
Loop:
		// If enemy directly reachable
		`AILog( "Loop Label "$find, 'Command_MoveToEnemy' );
		SetBasedPosition( LastEnemyLocation, Find.Location );
		// Is Pawn closer than maximum 'basic' attack tag range?
		if( IsDoingAttackSpecialMove() )
		{
			`AIlog( self$" [Cleaning up and returning Success status] IsWithinAttackRange returned TRUE DIST: "$VSize( Enemy.Location - Pawn.Location )$" <= MeleeAttackHelper range ("$MyKFPawn.MeleeAttackHelper.GetMeleeRange()$")", 'Command_MoveToEnemy' );
			ClearTimer( 'CheckReachedEnemy', self );
			ClearTimer( nameof(self.DirectMoveTimeout ),self);
			ClearTimer( nameof(CheckEnemyMoved ), self);
			Status = 'Success';
			PopCommand( self );
			Stop;
		}
		else if( IsValidDirectMoveGoal( Find ) )
		{
			// WIP - Disabled until ready
/*
			if( Pawn.bCrawler )
			{
				MyKFPawn.SetSprinting( true );
				MyKFPawn.bIsSprinting = true;
			}
			if( Pawn.Physics == PHYS_Spider )
			{
				JumpToTarget();
				if( Pawn.Physics == PHYS_Falling )
				{
					WaitForLanding();
					Goto( 'Begin' );
				}
			}
*/
			`AILog( "Enemy "$Find$" - IsValidDirectMoveGoal() returned true, trying direct move...", 'Command_MoveToEnemy' );
			SetTimer( 0.1f, true, nameof(CheckEnemyMoved), self);
			SetTimer( 0.1f, true, nameof(self.CheckReachedEnemy), self );

            if( !bUseNavMesh || !bUsePluginsForMovement )
            {
    			`AILog( self$" Calling SetMoveGoal() for enemy, using offset "$Radius$", with bCanPathFind = false", 'Command_MoveToEnemy' );
    			SetMoveGoal( Find,, true, Radius,, false,, bAllowedToAttackDuringMove );
			}
			if( Enemy != none )
			{
				`AILog( self$" Done moving to goal, distance is now "$VSize(Enemy.Location - Pawn.Location), 'Command_MoveToEnemy' );
			}
			if( ChildStatus != 'Success' )
			{
				if( Enemy != none )
				{
 					`AILog( "Child status was not successful, MoveTriesRemaining: "$MoveTriesRemaining$" Enemy Dist: "$VSize(Enemy.Location - Pawn.Location) );
 				}
				if( --MoveTriesRemaining <= 0)
				{
					`AILog( "Child failed or aborted, and we're out of move tries.. failing", 'Command_MoveToEnemy' );
					UpdateHistoryString( "Child failed or aborted, and we're out of move tries at "$WorldInfo.TimeSeconds$"]" );
					GotoState( 'DelayFailure' );
				}
				else
				{
					Goto( 'Loop' );
				}
			}

			ClearTimer( 'CheckReachedEnemy', self );
			ClearTimer( nameof(self.DirectMoveTimeout ),self );
			ClearTimer( nameof(CheckEnemyMoved), self );
			`AILog( "Finished moving to enemy", 'Command_MoveToEnemy' );
			Status = 'Success';
			Sleep(0.f);
			PopCommand( self );
		}
		else
		{
			if( Enemy != none )
			{
				`AILog( "Trying to build path to enemy who is currently "$VSize( Enemy.Location - Pawn.Location )$" units away", 'Command_MoveToEnemy' );
			}
			if( Pawn.Anchor == none )
			{
				SetBestAnchor();
			}
			// Try to find path to enemy
			Path = GeneratePathTo( Find,, true );
			// If no path available
			if( Path == None )
			{
				`AILog( "Attempt to build path failed, going to DelayFailure state and calling SetFailedPathToEnemy()", 'PathWarning' );
				if( MyKFPawn.bCrawler && MyKFPawn.Physics == PHYS_Spider )
				{
					MyKFPawn.SetPhysics(PHYS_Falling);
					WaitForLanding();
				}
				// Update failed path time
				SetFailedPathToEnemy( Enemy );
				GotoState( 'DelayFailure' );
			}
			else
			{
				if( VSize(Find.Location - Pawn.Location) <= StrikeRange )
				{
					GotoState( 'DelayFailure' );
				}
				else if( !bCompleteMove )
				{
					`AILog( "Built path to enemy, bComplete move was false.. Pawn.Anchor: "$Pawn.Anchor$" Path: "$Path$" AnchorDist: "$VSize(Pawn.Location - Pawn.Anchor.Location), 'Command_MoveToEnemy' );
					//if( RouteCache.Length > 0 )
					//{
					//	`log( "Pawn.RouteCache[0]: "$RouteCache[0] );
					//	`log( "Pawn.RouteCache[1]: "$RouteCache[1] );
					//	`log( "Pawn.RouteCache[2]: "$RouteCache[2] );
					//}
					// Move to first path...
					// will research for new path when reached first one
					// make sure we don't try to move to our anchor
					if( Path == Pawn.Anchor )
					{
						`AILog( "Preventing myself from moving to my anchor ("$Pawn.Anchor$") as my first path goal", 'Command_MoveToEnemy' );
						Path = RouteCache[1];

						// clip off the end of the routecache
						if(RouteCache.length > 2)
						{
							RouteCache_RemoveIndex(2,RouteCache.length-2);
						}
					}
					else
					{
						if(RouteCache.length > 1)
						{
							RouteCache_RemoveIndex(1,RouteCache.length-1);
						}
					}
				}
				else
				{
					Path = Find;
				}
				SetTimer( 0.5, true, nameof(CheckEnemyMoved), self );
				SetTimer( 0.5f, true, nameof(CheckReachedEnemy), self );
                if( !bUseNavMesh || !bUsePluginsForMovement )
                {
    				// Have bValidCache true first time, but false after that
    				`AILog( "Starting move to goal "$Path$" which is currently "$VSize( Path.Location - Pawn.Location )$" units away", 'Command_MoveToEnemy' );
    				SetMoveGoal( Path,, true,, true,,,bAllowedToAttackDuringMove );
    			}
				// (untested) SetMoveGoal( Path,, true, StrikeRange, true,,,bAllowedToAttackDuringMove );
				`AILog( "Finished move to goal "$Path$" which is now "$VSize( Path.Location - Pawn.Location )$" units away", 'Command_MoveToEnemy' );

				ClearTimer( 'CheckReachedEnemy', self );
				ClearTimer( 'CheckEnemyMoved', self );

				if( ChildStatus != 'Success' && --MoveTriesRemaining <= 0 )
				{
					`AILog( "Going to DelayedFailure state because ChildStatus is failed and MoveTriesRemaining: "$MoveTriesRemaining, 'Command_MoveToENemy' );
					GotoState( 'DelayFailure' );
				}
				Sleep(0.0);
				if( Enemy == none )
				{
					`AILog( "Lost enemy or enemy became invalid, aborting", 'Command_MoveToEnemy' );
					AbortCommand( self );
				}
				Goto( 'Loop' );
			}
		}
	}
	else
	{
		`AILog( "No valid enemy, or not allowed to move.. bailing ValidEnemy?:"@Enemy@"Allowed to move?"@AllowedToMove()@"Move Interruptable?"@MoveIsInterruptable(), 'Command_MoveToEnemy' );
		GotoState( 'DelayFailure' );
	}
}

defaultproperties
{
	MoveTriesRemaining=3
	bAllowedToAttack=false
	RepathDistance=1224.f
}
