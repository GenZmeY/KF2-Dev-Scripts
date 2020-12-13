//=============================================================================
// AICommand
//=============================================================================
// Base class for AICommands (based on GOW2-GOW3)
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//=============================================================================

class AICommand extends GameAICommand
	within KFAIController
	native(AI)
	DependsOn(KFPawn)
	dependson(KFAiBehaviorTypes);

/** Reference to the KFAIController using this command */
var KFAIController	AIOwner;
/** When a command is paused, the new command is cached here until the original command resumes */
var AICommand		CachedChildCommand;
/** Can the AI perform an attack when using this command? */
var bool			bAllowedToAttack;
/** When command is active, AILog category from this command will be overridden to this name */
var string			OverrideLogCategory;
/** When true, this command can interrupt the pause AICommand */
var bool			bInterruptPauseCommand;
/** When true, this command can will disable the movement plugin on push and enable on popped*/
var bool 			bDisableMovementPluginOnPushed;

cpptext
{
	virtual void TickCommand(FLOAT DeltaTime);
}

/*********************************************************************************************
* Initialization
********************************************************************************************* */

/** Cache AIOwner */
function PrePushed( GameAIController AI )
{
	AIOwner	= Outer;

	Super.PrePushed( AI );
}

function Pushed()
{
	if( bUsePluginsForMovement && MovementPlugin != none && bDisableMovementPluginOnPushed )
	{
		MovementPlugin.DisablePlugin();
	}
	Super.Pushed();
}

/** Clear AIOwner */
function PostPopped()
{
	AIOwner = none;
	Super.PostPopped();
}

/** Command has been paused by another command */
function Paused(GameAICommand NewCommand)
{
	`AILog( GetFuncName()$" ["$self$"] setting CachedChildCommand to "$NewCommand, 'Command_Base' );
	CachedChildCommand = AICommand( NewCommand );

	Super.Paused(NewCommand);
}

/** Command has resumed execution */
function Resumed( Name OldCommandName )
{
	`AILog( GetFuncName()$" Command resumed, setting CachedChildCommand to none", 'Command_Base' );
	CachedChildCommand = none;

	Super.Resumed( OldCommandName );
}

/** Command is being popped off the stack */
function Popped()
{
	if( bUsePluginsForMovement && MovementPlugin != none && bDisableMovementPluginOnPushed )
	{
		MovementPlugin.EnablePlugin();
	}

	if( MyKFPawn != none && MyKFPawn.IsAliveAndWell() )
	{
		UpdateCommandHistory();
		`AILog( GetFuncName()$" Command Popped, setting CachedChildCommand to none", 'Command_Base' );
	}
	CachedChildCommand = none;

	if( AIOwner != none )
	{
		AIOwner.NotifyCommandFinished( self );
	}

	Super.Popped();
}

/** Called from TickCommand and is used to call special moves and functions ontop of an AI Command */
event HandleAICommandSpecialAction();

/** Can this command be pushed by special moves? */
function bool AllowPushOfDefaultCommandForSpecialMove( ESpecialMove SM )
{
	return true;
}

/** Access the parent AICommand, if any exists */
function AICommandBase GetParentCommand()
{
	local GameAICommand ParentCommand;

	ParentCommand = CommandList;
	while( ParentCommand != none && ParentCommand.ChildCommand != self )
	{
		ParentCommand = ParentCommand.ChildCommand;
	}

	if( ParentCommand != none )
	{
		return ParentCommand;
	}

	return none;
}

/*********************************************************************************************
* Notifications
* Important event notifications are often forwarded from KFAIController to the top level
* AICommand and on to any child commands.
********************************************************************************************* */

function bool NotifyHearNoise( float Loudness, Actor NoiseMaker, optional Name NoiseType )
{
	if( CachedChildCommand != None )
	{
		`AILog( GetFuncName()$"() Loudness: "$Loudness$" NoiseMaker: "$NoiseMaker$" Type: "$NoiseType, 'HearNoise' );
		return CachedChildCommand.NotifyHearNoise( Loudness, NoiseMaker, NoiseType );
	}
	return false;
}

function bool NotifyCombatBehaviorChange( name BehaviorName, bool bEnabled )
{
	if( CachedChildCommand != None )
	{
		`AILog( GetFuncName()$"() BehaviorName: "$BehaviorName$" bEnabled: "$bEnabled );
		return CachedChildCommand.NotifyCombatBehaviorChange( BehaviorName, bEnabled );
	}
	return false;
}

/** Allows AICommands to reject switching enemy to NewEnemy */
function bool CanChangeEnemy( Pawn NewEnemy )
{
	if( CachedChildCommand != None )
	{
		return CachedChildCommand.CanChangeEnemy( NewEnemy );
	}
	return true;
}

/** Notification from controller that enemy has changed. Sends OldEnemy to support movement goal re-evaluations. */
function NotifyEnemyChanged( optional Pawn OldEnemy )
{
	if( CachedChildCommand != None )
	{
		CachedChildCommand.NotifyEnemyChanged( OldEnemy );
	}
}

/** Notification that a pending door is now open */
function NotifyDoorOpened()
{
	if( CachedChildCommand != None )
	{
		`AILog( GetFuncName()$"() notifying "$CachedChildCommand$" and letting it handle the event.", 'NotifyDoorOpened' );
		CachedChildCommand.NotifyDoorOpened();
	}
}

/** Notification from controller that enemy has become visible */
function bool NotifyPlayerBecameVisible( Pawn VisiblePlayer )
{
	if( CachedChildCommand != None )
	{
		`AILog( GetFuncName()$"() Seen: "$VisiblePlayer$" notifying "$CachedChildCommand$" and letting it handle the event.", 'SeePlayer' );
		return CachedChildCommand.NotifyPlayerBecameVisible( VisiblePlayer );
	}
	return false;
}

/** Notification from controller that enemy is no longer visible */
function bool NotifyEnemyNotVisible()
{
	if( CachedChildCommand != None )
	{
		`AILog( GetFuncName()$"() notifying "$CachedChildCommand$" and letting it handle the event.", 'EnemyNotVisible' );
		return CachedChildCommand.NotifyEnemyNotVisible();
	}
	return false;
}

/** Notification from controller that my pawn's base has changed */
function bool NotifyBaseChange( actor NewBase, vector NewFloor )
{
	if( CachedChildCommand != None )
	{
		//`AILog( GetFuncName()$"() notifying "$CachedChildCommand$" and letting it handle the event.", 'HitWall' );
		if( CachedChildCommand.NotifyBaseChange( NewBase, NewFloor ) )
		{
			return true;
		}
	}
	return false;
}

/** Notification from controller that my pawn has landed */
function bool NotifyLanded( vector HitNormal, actor FloorActor )
{
	if( CachedChildCommand != None )
	{
		`AILog( GetFuncName()$"() HitNormal:"$HitNormal$" FloorActor:"$FloorActor$" notifying "$CachedChildCommand$" and letting it handle the event.", 'PathWarning' );
		return CachedChildCommand.NotifyLanded( HitNormal, FloorActor );
	}
	return false;
}

/** Notification that my current enemy is surrounded by other NPCs */
function bool EnemyIsSurrounded()
{
	if( CachedChildCommand != None )
	{
		`AILog( GetFuncName()$"() notifying "$CachedChildCommand$" and letting it handle the event.", 'PathWarning' );
		return CachedChildCommand.EnemyIsSurrounded();
	}
	return false;
}

/** Notification from controller that my pawn has collided with an obstruction (during a latent move) */
function bool NotifyHitWall( vector HitNormal, actor Wall )
{
	if( CachedChildCommand != None )
	{
		`AILog( GetFuncName()$"() notifying "$CachedChildCommand$" and letting it handle the event.", 'HitWall' );
		return CachedChildCommand.NotifyHitWall( HitNormal, Wall );
	}
	return false;
}

/** Notification from controller that my pawn has collided with an obstruction while falling (during a latent move) */
function bool NotifyFallingHitWall( vector HitNormal, actor Wall )
{
	if( CachedChildCommand != None )
	{
		`AILog( GetFuncName()$"() notifying "$CachedChildCommand$" and letting it handle the event.", 'HitWall' );
		return CachedChildCommand.NotifyFallingHitWall( HitNormal, Wall );
	}
	return false;
}

/** Notification that a nearby Husk has become suicidal */
function bool NotifyHuskSuicide( KFPawn_Monster Husk )
{
	return false;

	if( CachedAICommandList != none )
	{
		if( CachedAICommandList.NotifyHuskSuicide( Husk ) )
		{
			return true;
		}
	}
	return false;
}

/** Notification that my pawn has bumped into something - usually another NPC */
function bool NotifyBump( actor Other, vector HitNormal )
{
	if( CachedChildCommand != None )
	{
		`AILog( GetFuncName()$"() notifying "$CachedChildCommand$" and letting it handle the event.", 'BumpEvent' );
		if( CachedChildCommand.NotifyBump( Other, HitNormal ) )
		{
			return true;
		}
	}
	return false;
}

function bool NotifyLatentPostPhysWalking()
{
	if( CachedChildCommand != None )
	{
		`AILog( GetFuncName()$"() notifying "$CachedChildCommand$" and letting it handle the event.", 'PostPhysWalking' );
		if( CachedChildCommand.NotifyLatentPostPhysWalking() )
		{
			return true;
		}
	}
	return false;	
}

function bool NotifyTouch(Actor Other, PrimitiveComponent OtherComp, vector HitLocation, vector HitNormal)
{
	if( CachedChildCommand != None )
	{
		`AILog( GetFuncName()$"() notifying "$CachedChildCommand$" and letting it handle the event.", 'TouchEvent' );
		if( CachedChildCommand.NotifyTouch( Other, OtherComp, HitLocation, HitNormal ) )
		{
			return true;
		}
	}
	return false;
}

function bool NotifyMovingOnToDestructibleEdge( KFDestructibleActor TheDestructiblePathObject, out KFNavMeshMovementStepData EdgeData, out Vector outMove2Point )
{
	if( CachedChildCommand != None )
	{
		`AILog( GetFuncName()$"() notifying "$CachedChildCommand$" and letting it handle the event.", 'NotifyZedStuck' );
		if( CachedChildCommand.NotifyMovingOnToDestructibleEdge( TheDestructiblePathObject, EdgeData, outMove2Point ) )
		{
			return true;
		}
	}
	return false;
}


function bool NotifyNpcTerminallyStuck()
{
	if( CachedChildCommand != None )
	{
		`AILog( GetFuncName()$"() notifying "$CachedChildCommand$" and letting it handle the event.", 'NotifyNpcTerminallyStuck' );
		if( CachedChildCommand.NotifyNpcTerminallyStuck() )
		{
			return true;
		}
	}
	return false;
}

function bool NotifyNpcInGrannyMode()
{
	if( CachedChildCommand != None )
	{
		`AILog( GetFuncName()$"() notifying "$CachedChildCommand$" and letting it handle the event.", 'NotifyNpcInGrannyMode' );
		if( CachedChildCommand.NotifyNpcInGrannyMode() )
		{
			return true;
		}
	}
	return false;
}

/** Ignore timer transitions to other commands? */
function bool ShouldIgnoreTimeTransitions()
{
	local bool bShouldIgnore;

	if(CachedChildCommand != none)
	{
		bShouldIgnore = CachedChildCommand.ShouldIgnoreTimeTransitions();
	}

	if( bShouldIgnore )
	{
		`AILog( GetFuncName()$"() returning TRUE - ignoring time transitions", 'CombatTransitions' );
	}
	return bShouldIgnore;
}

/** Checks to see if we're allowed to fire our weapon in this command, passing through to children until blocked. */
function bool IsAllowedToAttack()
{
	local bool bCanAttack;

	bCanAttack = ( bAllowedToAttack && (CachedChildCommand == None || CachedChildCommand.IsAllowedToAttack()) );

	if( !bCanAttack )
	{
		`AILog( GetFuncName()$"() returning false because !bAllowedToAttack" );
	}

	return bCanAttack;
}

/** Checks if Pawn P exists and is still alive */
function bool IsPawnAlive( Pawn P )
{
	if( P == none )
	{
		return false;
	}

	if( P.Controller == none || !P.IsAliveAndWell() )
	{
		return false;
	}

	return true;
}

/** Checks if Controller C exists, its pawn exists and is still alive */
function bool IsControllerAlive( Controller C )
{
	if( C == none )
	{
		return false;
	}

	if( C.Pawn == none || !C.Pawn.IsAliveAndWell() )
	{
		return false;
	}

	return true;
}

/** Should the AI re-evaluate their current target and possibly choose a different one? */
function bool ShouldSelectTarget()
{
	if( CachedChildCommand != None )
	{
		return CachedChildCommand.ShouldSelectTarget();
	}
	return true;
}

function AdjustEnemyRating(out float out_Rating, Pawn EnemyPawn)
{
	if (CachedChildCommand != None)
	{
		CachedChildCommand.AdjustEnemyRating(out_Rating, EnemyPawn);
	}
}

/*********************************************************************************************
* Pathfinding & Movement
********************************************************************************************* */

/** Called from native code during latent movement, gives NPC a chance to find direct path to goal */
function FindDirectPath()
{
	`AILog( GetFuncName(), 'Move_DirectPath' );

	if (CachedChildCommand != None)
	{
		`AILog( GetFuncName()$"(), [I am "$self$"] letting "$CachedChildCommand$" decide what to do about it.", 'Move_DirectPath' );
		CachedChildCommand.FindDirectPath();
	}
}

/** Called from native code during latent movement when current move is considered unreachable */
function bool MoveUnreachable( Vector AttemptedDest, Actor AttemptedTarget )
{
	if( AttemptedTarget != none )
	{
		`AILog( GetFuncName()$" AttemptedTarget: "$AttemptedTarget, 'PathWarning' );
	}

	if( CachedChildCommand != None )
	{
		`AILog( GetFuncName()$"() letting "$CachedChildCommand$" decide what to do about it.", 'PathWarning' );
		return CachedChildCommand.MoveUnreachable( AttemptedDest, AttemptedTarget );
	}
	return false;
}

/** Notification that NPC's path needs to be updated */
function NotifyNeedRepath()
{
	if(CachedChildCommand != none)
	{
		`AILog( GetFuncName()$"() "$self$" called, letting "$CachedChildCommand$" decide what to do about it.", 'PathWarning' );
		CachedChildCommand.NotifyNeedRepath();
	}
	else
	{
		`AILog( GetFuncName()$"() "$self$" called.", 'PathWarning' );
	}
}

/*********************************************************************************************
* Debugging
********************************************************************************************* */

/** Update command history (debugging) */
function UpdateCommandHistory()
{
	local int i;

	if( Outer.Pawn != none )
	{
		for( i = 0; i < KFAICommandHistory.Length; i++ )
		{
			if( KFAICommandHistory[i].CmdName != "" && KFAICommandHistory[i].CmdName == string( Name ) )
			{
				if( Status == 'Aborted' )
				{
					KFAICommandHistory[i].bAborted = true;
				}
				if( Status == 'Failure')
				{
					KFAICommandHistory[i].bFailure = true;
				}
				if( Status == 'Success')
				{
					KFAICommandHistory[i].bSuccess = true;
				}

				UpdateHistoryString( "Status: "$Status );
				//HistoryString = "Status: "$Status;
				KFAICommandHistory[i].Duration = `TimeSince(KFAICommandHistory[i].TimeStamp);
				KFAICommandHistory[i].VerboseString = HistoryString;
			}
		}
	}
}

/** Update the command's HistoryString, which is output when DumpCommandHistory() is called */
function UpdateHistoryString( string AddString )
{
	if( Outer.Pawn != none )
	{
		if( CommandHistoryNum > 0 )
		{
			HistoryString = HistoryString$" "$AddString;
		}
	}
}

/** Debug event to draw command-specific text to HUD */
simulated event DrawDebug( HUD H, Name Category )
{
	if( ChildCommand != None )
	{
		ChildCommand.DrawDebug( H,Category );
	}
}

/** Used when dumping command history to log file */
event string GetDebugVerboseText()
{
	return HistoryString;
}

/** Is this AICommand permitted to interrupt an active AICommand_Pause? */
static function bool CanInterruptPauseCommand()
{
	return default.bInterruptPauseCommand;
}

DefaultProperties
{
	bAllowedToAttack=true
	bInterruptPauseCommand=false
	bDisableMovementPluginOnPushed=true
}
