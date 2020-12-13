//=============================================================================
// AICommand_Debug
//=============================================================================
// Empty (debug) AI command
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//=============================================================================

class AICommand_Debug extends AICommand
	within KFAIController;

var bool	bTestStepAside;
var bool	bNoFocus;
var bool	bOldDebugPostRenderInfo;
var vector	DebugMoveLocation;
var bool	bTempDisableHitWall;
var bool	bStoppedRotationTowardEnemy;
var KFPawn	DebuggingPlayer;
var float	MaxRoamDist;
var float	RoamStartTime;
var float	RoamEnvelopeOuter;
var float	RoamEnvelopeInner;
var float	RoamWaitMin;
var float	RoamWaitMax;
var actor	LastDebugGoal;

//var array<KFJumpSpot> VisitedJumpSpots;

/*********************************************************************************************
* Initialization
**********************************************************************************************/

static function bool Debug( KFAIController AI )
{
	local AICommand_Debug Cmd;

	if( AI != None )
	{
		Cmd = new(AI) Default.Class;
		if( Cmd != None )
		{
			AI.PushCommand(Cmd);
			return true;
		}
	}

	return false;
}

function Pushed()
{
	`AILog( "Entering debug mode", 'Command_Debug' );
	bHasDebugCommand = true;
	
	//Focus = none;

	ClearTimer( nameof(Debug_CheckRecentMoveTime), Outer );
	//SetFocalPoint( Pawn.Location + vector( Pawn.Rotation ) * 512.f );

// 	if( Enemy != none && Enemy.IsHumanControlled() )
// 		Enemy = none;
	bOldDebugPostRenderInfo = bDebug_PostRenderInfo;
// 	bDebug_PostRenderInfo = true;
// 	SetPostRendering( true );
	GotoState( 'Wait' );
}

function Resumed( Name OldCommandName )
{
	DisableMeleeRangeEventProbing();

// 	if( OldCommandName == 'AICommand_StepAside' )
// 	{
// 		bNoFocus = false;
// 	}
	if( OldCommandName == 'AICommand_MoveToGoal' )
	{
		`AILog( "Resuming "$self$" after "$OldCommandName$" ChildStatus: "$ChildStatus$" LastDebugGoal: "$LastDebugGoal );
	}
	if( OldCommandName == 'AICommand_MoveToGoal' && (ChildStatus == 'Aborted' || ChildStatus == 'Failure') && Pawn != none && Pawn.IsAliveAndWell() )
	{
		`AILog( "Resuming from failed MoveToGoal command", 'PathWarning' );
		if( LastDebugGoal != none )
		{
			Pawn.ZeroMovementVariables();
			StopLatentExecution();
			msg( "Debug NPC ["$Pawn$"] retrying path to "$LastDebugGoal$", "$VSize(LastDebugGoal.Location - Pawn.Location)$" units away." );
//			SetMoveGoal( LastDebugGoal, none, false, 0.f, false, true, true );
		}
	}

	super.Resumed( OldCommandName );
}

function GrabTestTimer()
{
	if( VSizeSq( Enemy.Location - Pawn.Location ) < 48400.f ) // 220UU
	{
		bAllowedToAttack = true;
		DoGrabAttack( Enemy );
		bAllowedToAttack = false;
	}
}

function Popped()
{
	bDebug_PostRenderInfo = bOldDebugPostRenderInfo;
	SetPostRendering( bDebug_PostRenderInfo );
	super.Popped();
	bHasDebugCommand = false;
	`AILog( "Exiting Debug Mode", 'Command_Debug' );
}

function bool NotifyPlayerBecameVisible( Pawn VisiblePlayer )
{
	if( CachedChildCommand != None )
	{
		`AILog( GetFuncName()$"() Seen: "$VisiblePlayer$" notifying "$CachedChildCommand$" and letting it handle the event.", 'Command_Debug' );
		return CachedChildCommand.NotifyPlayerBecameVisible( VisiblePlayer );
	}
	`AILog( GetFuncName()$" "$VisiblePlayer$" ignoring this event", 'Command_Debug' );
	return true;
}

function Debug_Charge();
function Debug_MoveForward();
function Debug_Vision( Pawn P );
function Debug_Flank();
function Debug_Hide();
function Debug_Enemy( Pawn P );
function Debug_StepAside( optional bool bOn = true );
function Debug_Steering();
function Debug_Wander( optional float WanderDuraion=-1.f );
function Debug_DebugLines();
function Debug_Leap();
function Debug_DebugNodes();
function Debug_CrawlerAttack();
function Debug_LOS();

/*********************************************************************************************
* Debugging State (abstract base state)
********************************************************************************************* */

state Debugging
{
	event BeginState( name PreviousStateName )
	{
		`AILog( GetFuncName()$"() in "$GetStateName()$" Previous: "$PreviousStateName, 'Command_Debug' );
	}

	function InitState()
	{
		`AILog( GetFuncName()$"() in "$GetStateName(), 'Command_Debug' );
// 		Focus = none;
// 		SetFocalPoint( vector(Pawn.Rotation) * 300 );
// 		DisableSeePlayer();
		AIActionStatus = "Awaiting debug command";
	}

	event EndState( name NextStateName )
	{
		`AILog( GetFuncName()$"() in "$GetStateName()$" Next: "$NextStateName, 'Command_Debug' );
	}

	function PushedState()
	{
		`AILog( GetFuncName()$"() in "$GetStateName(), 'Command_Debug' );
	}

	function PausedState()
	{
		`AILog( GetFuncName()$"() in "$GetStateName(), 'Command_Debug' );
	}

	function ContinuedState()
	{
		`AILog( GetFuncName()$"() in "$GetStateName(), 'Command_Debug' );
	}

	function PoppedState()
	{
		`AILog( GetFuncName()$"() in "$GetStateName(), 'Command_Debug' );
	}

	function Debug_CrawlerAttack()
	{
		local PlayerController P;

		foreach WorldInfo.AllActors( class'PlayerController', P )
		{
			if( P.Pawn != None )
			{
				Enemy = P.Pawn;
			}
		}

		if( Enemy != none )
		{
			bAllowedToAttack = true;
		}
		EnableMeleeRangeEventProbing();
		Pawn.SetPhysics( PHYS_Walking );
		ReadyToMelee();
	}
}

state MoveToRandomDebugNodes
{
	function Debug_DebugNodes()
	{
		StopAllLatentMovement();
		PopState();
	}

	function GetGoal()
	{
//		local KFPathnode KFPN;
//		local array<KFPathNode> NavGoals;
//		foreach allactors( class'KFPathnode', KFPN )
//		{
//			if( KFPN.DebugTag != '' && VSize(KFPN.Location - Pawn.Location) > 750.f )
//			{
////				NavGoals.AddItem(KFPN);
//			}
//		}
//		SetMoveGoal( NavGoals[ Rand(NavGoals.Length) ] );
	}
Begin:
	WaitForLanding();
	GetGoal();
	Sleep( RandRange(3,8) );
	Goto( 'Begin' );
}

/*********************************************************************************************
* DebugLOS state
**********************************************************************************************/

state DebugLOS
{
	function BeginState( name PreviousStateName )
	{
		StartLOSTimer();
	}

	function PushedState()
	{
		StartLOSTimer();
	}

	function StartLOSTimer()
	{
		Disable( 'SeePlayer' );
		Disable( 'HearNoise' );
		SetTimer( 0.5f, true, nameof(CheckLOS), self );
	}

	function EndState( name NextStateName )
	{
		ClearTimer( nameof(CheckLOS), self );
	}

	function PoppedState()
	{
		ClearTimer( nameof(CheckLOS), self );
	}

	function CheckLOS()
	{
		local KFPlayerController KFPC;

		foreach WorldInfo.AllControllers( class'KFPlayerController', KFPC )
		{
			if( KFPC.Pawn != none && CanSee( KFPC.Pawn ) && Pawn.LineOfSightTo( KFPC.Pawn ) )
			{
				msg( self$" CAN SEE "$KFPC.Pawn );
			}
			else
			{
				msg( self$" CANNOT SEE "$KFPC.Pawn );
			}
		}
	}
}

/*********************************************************************************************
* Wait state (auto state)
********************************************************************************************* */

auto state Wait extends Debugging
{
	function BeginState( name PreviousStateName )
	{
		super.BeginState( PreviousStateName );
		//Steering.EnableDefaultAcceleration();
		InitState();
	}

	function ContinuedState()
	{
		super.ContinuedState();
		InitState();
	}
	
	/** Called from cheat manager */
	function Debug_MoveForward()
	{
		PushState( 'DebugMoveForward', 'Ready' );
	}

	/** Called from cheat manager */
	function Debug_Hide()
	{
		PushState( 'DebugHiding' );
	}

	/** Called from cheat manager */
	function Debug_Vision( Pawn P )
	{
		DebuggingPlayer = KFPawn(P);
		PushState( 'DebugVision' );
	}

	/** Called from cheat manager */
	function Debug_Enemy( Pawn P )
	{
		DebuggingPlayer = KFPawn(P);
		PushState( 'DebugEnemy' );
	}

	function Debug_Leap()
	{
		PushState( 'DebugLeap' );
	}

	function Debug_LOS()
	{
		PushState( 'DebugLOS' );
	}

	function Debug_DebugNodes()
	{
		PushState( 'MoveToRandomDebugNodes' );
	}

	/** Called from cheat manager */
	function Debug_StepAside( optional bool bOn = true )
	{
		if( !bOn )
		{
			msg( Outer$" : StepAside debugging is already turned off." );
		}
		else
		{
			PushState( 'DebugStepAside' );
		}
	}

	/** Called from cheat manager */
	function Debug_Steering()
	{
		PushState( 'DebugSteering' );
	}

	/** Called from cheat manager */
	function Debug_Wander( optional float WanderDuraion=-1.f )
	{
		class'AICommand_Wander'.static.BeginWander( outer, WanderDuraion, GetALocalPlayerController().Pawn, false );
	}

	/** Called from cheat manager */
	function Debug_DebugLines()
	{
		PushState( 'DebugDebugLines' );
	}
}

// DebugTurn state
state DebugTurn
{
	event HandleAICommandSpecialAction()
	{
		if( GetFocalPoint() != vect(0,0,0) )
		{
			DrawDebugLine( Pawn.Location, Pawn.Location + normal( GetFocalPoint() - Pawn.Location ) * 1024.f, 0, 255, 0, false );
		}
	}

	function PushedState()
	{
		SetFocalPoint(vect(0,0,0) );
		Focus = none;
	}
}

/*********************************************************************************************
* DebugLeap state
**********************************************************************************************/
state DebugLeap
{
	function PushedState()
	{
		local KFWallPathNode KFWP, BestKFWP;
		local float BestDist;

		foreach WorldInfo.AllNavigationPoints( class'KFWallPathNode', KFWP )
		{
			if( BestKFWP == None || VSize(KFWP.Location - Pawn.Location) < BestDist )
			{
				if( KFWP.Location.Z > 350.f )
				{
					BestDist = VSize(KFWP.Location - Pawn.Location);
					BestKFWP = KFWP;
				}
			}
		}
		MoveTarget = BestKFWP;
	//	OldFloor = vect(0,0,1);
		//GetAxes(Pawn.Rotation,ViewX,ViewY,ViewZ);
		//GroundPitch = 0;
		Pawn.bCrawler = true;
	}

	function bool NotifyHitWall( vector HitNormal, actor Wall )
	{
		Pawn.SetPhysics( PHYS_Spider );
		Pawn.SetBase( Wall, HitNormal );
		return false;
	}

// 	function DoWallLeap()
// 	{
// 		//LeapTarget = BestKFWP;
//
// 		OldFloor = vect(0,0,1);
// 		GetAxes(Pawn.Rotation,ViewX,ViewY,ViewZ);
// 		//GroundPitch = 0;
// 		Pawn.bCrawler = true;
// 		//KFAIController_ZedCrawler(Outer).DoWallLeap( BestKFWP );
// 		//Pawn.SetCollisionSize(Pawn.Default.CollisionHeight,Pawn.Default.CollisionHeight);
// 	}

Begin:
	if(Pawn.Physics == PHYS_Falling )
	{
		WaitForLanding();
	}
	Pawn.SetPhysics(PHYS_Walking);

	PushState( 'RotateToMoveTarget' );
	Focus = none;
	SetFocalPoint(vect(0,0,0));
	Sleep( 1.f );
	//KFAIController_ZedCrawler(Outer).DoWallLeap( MoveTarget );
	Sleep( 0.1f );
	if( Pawn.Physics == PHYS_Falling )
	{
		WaitForLanding();
	}
}

/*********************************************************************************************
* DebugSteering state - draws separation steering forces, etc.
********************************************************************************************* */

state DebugSteering extends Debugging
{
	function PushedState()
	{
		super.PushedState();
		AIActionStatus = "In DebugSteering state";
		bDebug_DrawSeparationSteering = true;
	}

	function Debug_Steering()
	{
		PopState();
	}

	function PoppedState()
	{
		bDebug_DrawSeparationSteering = false;
		super.PoppedState();
	}
}

/*********************************************************************************************
* DebugStepAside state - NPC will step aside when bumped or on AIDebugStepSide command
********************************************************************************************* */

state DebugStepAside extends Debugging
{
	function PushedState()
	{
		super.PushedState();
		AIActionStatus = "In DebugStepAside state";
		msg( Outer$" in DebugStepAside state. Forcing NPC collision will invoke StepAside command, or type AIDEBUGSTEPASIDE again to force NPC to step aside with no collision." );
		bIgnoreStepAside = false;
	}

	function Debug_StepAside( optional bool bOn = true )
	{
		if( !bOn )
		{
			msg( Outer$" : Turning off StepAside debugging" );
			PopState();
		}
		else if( CachedChildCommand == none )
		{
			msg( Outer$" : random step aside" );
		}
	}

	function bool NotifyBump( Actor Other, vector HitNormal )
	{
		local bool bPrevIgnoreStepAside;
		local bool bResult;

		`AILog( GetFuncName()$" bumped into "$Other, 'Command_Debug' );
		if( Pawn(Other) != none )
		{
			`AILog( GetFuncName()$" bumped into "$Other$", starting StepAside command", 'Command_Debug' );
			bPrevIgnoreStepAside = Outer.bIgnoreStepAside;
			Outer.bIgnoreStepAside = false;
			StepAsideFor( Pawn(Other),HitNormal );
			Outer.bIgnoreStepAside = bPrevIgnoreStepAside;
			bResult = true;
		}
		DisableBump( 1.f );

		return bResult;
	}
}

/*********************************************************************************************
* DebugJumpPoints state - move to and attempt to use any KFJumpPoints in the level
********************************************************************************************* */

//state DebugJumpPoints extends Debugging
//{
//	function PushedState()
//	{
//		super.PushedState();
//		AIActionStatus = "In DebugJumpPoints state";
//		DisableSeePlayer();
//	}

//	function KFPathnode PickJumpDest()
//	{
//		local KFJumpSpot KFJS;
//		local KFJumpSpot ClosestKFJS;
//		local float BestDist;

//		foreach WorldInfo.AllNavigationPoints( class'KFJumpSpot', KFJS )
//		{
//			if( !KFJS.bDebug_Visited )
//			{
//				if( BestDist == 0 || VSize(KFJS.Location - Pawn.Location) < BestDist )
//				{
//					BestDist = VSize(KFJS.Location - Pawn.Location);
//					ClosestKFJS = KFJS;
//				}
//			}
//		}

//		return KFPathnode(ClosestKFJS.JumpTarget);
//	}

//Begin:
//	if( Pawn.Physics == PHYS_Falling )
//	{
//		WaitForLanding();
//	}
//	Pawn.SetPhysics( PHYS_Walking );
//	SetMoveGoal( PickJumpDest(), none, false, 0, false, true, true, false, false );
//	if( ChildStatus == 'Failure' )
//	{
//		PopState();
//	}
//	PopState();
//}

/*********************************************************************************************
* DebugEnemy state - Testing NPC threat evaluations and enemy changes
********************************************************************************************* */

function EvaluateThreats();

state DebugEnemy extends Debugging
{
	function PushedState()
	{
		super.PushedState();
		EnableSeePlayer();
		AIActionStatus = "In DebugEnemy state";
		SetTimer( 1.f, true, nameof(EvaluateThreats), self );
	}

	function EvaluateThreats()
	{
		local KFPlayerController KFPC;

		foreach WorldInfo.AllControllers( class'KFPlayerController', KFPC )
		{
			EvaluateThreatFrom( KFPC.Pawn );
		}
	}

// 	function bool NotifyPlayerBecameVisible( Pawn VisiblePlayer )
// 	{
// 		if( Enemy == none )
// 		{
// 			ChangeEnemy(VisiblePlayer);
// 			Focus = Enemy;
// 			PushState('RotateToFocus');
// 			return true;
// 		}
//
// 		if( Enemy == VisiblePlayer )
// 		{
// 			return false;
// 		}
//
// 		if( EvaluateThreatFrom(Enemy) < EvaluateThreatFrom(VisiblePlayer) )
// 		{
// 			msg( "CHANGING TO "$VisiblePlayer );
// 			ChangeEnemy(VisiblePlayer);
// 			Focus = Enemy;
// 			PushState('RotateToFocus');
// 		}
//
// 		return false;
// 	}

	simulated function DrawDebug( HUD HUD, name Category )
	{
		if( DebuggingPlayer != none )
		{
			DrawDebugText( HUD, "LOS: "$LineOfSightTo(DebuggingPlayer)$" CanSee: "$CanSee(DebuggingPlayer) );
			DrawDebugText( HUD, "VISIBLE BY TRACE: "$IsPawnVisibleViaTrace(DebuggingPlayer) );
		}
	}
}

/*********************************************************************************************
* DebugHiding state - Hide from player who issued command!
********************************************************************************************* */

state DebugHiding extends Debugging
{
	function PushedState()
	{
		super.PushedState();

		MyKFPawn.SetSprinting(true);
		AIActionStatus = "In DebugHiding state";
		if( Enemy == none )
		{
			Enemy = GetClosestEnemy();
		}
	}

	function Debug_Hide()
	{
		PopState();
	}

	function bool CheckRetreat()
	{
		local Pawn ClosestEnemy;

		ClosestEnemy = GetClosestEnemy();

		if( ClosestEnemy != none && CanSee( ClosestEnemy ) )
		{
			class'Path_AlongLine'.static.AlongLine(Pawn, -Normal(ClosestEnemy.Location - Pawn.Location));
			class'Goal_AwayFromPosition'.static.FleeFrom(Pawn, ClosestEnemy.Location, 4000);
			if( FindPathToward(ClosestEnemy) != None )
			{
				AIActionStatus = "Hiding from "$ClosestEnemy$" at "$RouteGoal;
//				SetMoveGoal( RouteGoal,, false,128.f, true, true );
				return true;
			}
		}
		return false;
	}

Begin:
	if( Pawn.Physics == PHYS_Falling )
	{
		WaitForLanding();
	}

	if( CheckRetreat() )
	{
		Sleep( 0.25f );
		Goto( 'Begin' );
	}
	MyKFPawn.SetSprinting(false);
	PopState();
}

function CheckVision();

/*********************************************************************************************
* DebugVision state (renders pawn view cone, etc.)
********************************************************************************************* */

state DebugVision extends Debugging
{
	function PushedState()
	{
		super.PushedState();
		msg( "Debugging "$MyKFPawn$" vision, current PeripheralVision: "$MyKFPawn.PeripheralVision$" Current SightRadius: "$MyKFPawn.SightRadius$" Checking LOS every 0.5 seconds" );
		SetTimer( 2.f, true, nameof(CheckVision), self );
		AIActionStatus = "In DebugVision state";
		EnableSeePlayer();
	}

	function bool NotifyEnemyBecameVisible( Pawn VisiblePlayer )
	{
		msg( "YOU ARE VISIBLE : "$normal( Enemy.Location - Pawn.Location ) dot vector(Pawn.Rotation) );
		Outer.Enable( 'EnemyNotVisible' );
		Outer.Disable( 'SeePlayer' );
		return true;
	}

	function bool NotifyEnemyNotVisible()
	{
		msg( "YOU ARE NO LONGER VISIBLE"$normal( Enemy.Location - Pawn.Location ) dot vector(Pawn.Rotation) );
		Outer.Enable( 'SeePlayer' );
		Outer.Disable( 'EnemyNotVisible' );
		return true;
	}

	function CheckVision()
	{
	}

	/** Called from cheat manager */
	function Debug_Vision( Pawn P )
	{
		ClearTimer( nameof(CheckVision) );
		PopState();
	}
}

function bool NotifyHitWall( vector HitNormal, actor Wall )
{
	if( CachedChildCommand != None )
	{
		`AILog( GetFuncName()$"() notifying "$CachedChildCommand$" and letting it handle the event.", 'HitWall' );
		return CachedChildCommand.NotifyHitWall( HitNormal, Wall );
	}
	return false;
// 	else if( KFDoorActor(Wall) != none )
// 	{
// 		if( KFDoorActor(Wall).WeldIntegrity <= 0 && KFDoorMarker(KFDoorActor(Wall).MyMarker) != none && !KFDoorActor(Wall).IsCompletelyOpen() )
// 		{
// 			DisableNotifyHitWall(0.25f);
// 			WaitForDoor( KFDoorActor(Wall) );
// 			`AILog( "NotifyHitWall() while in MoveToGoal, Wall: "$Wall$" Using door and waiting for it to open", 'Doors' );
// 			KFDoorActor(Wall).UseDoor(Pawn);
// 			return false;
// 		}
// 		// NOTE: Unless returning true, if the Wall is a closed door, SuggestMovePreparation event will be called on the associated KFDoorMarker
// 		`AILog( GetFuncName()$"() Wall: "$Wall$" HitNormal: "$HitNormal$" ran into a door!", 'Doors' );
// 		if( !KFDoorActor(Wall).IsCompletelyOpen() && KFDoorActor(Wall).WeldIntegrity > 0 && (Pawn.Anchor == KFDoorActor(Wall).MyMarker || (DoorEnemy != none && (DoorEnemy == KFDoorActor(Wall) || PendingDoor == KFDoorActor(Wall)))) )
// 		{
// 			`AILog( GetFuncName()$"() calling NotifyAttackDoor for "$Wall, 'Doors' );
// 			NotifyAttackDoor( KFDoorActor(Wall) );
// 			return false;
// 			//`AILog( GetFuncName()$"() has door enemy "$DoorEnemy, 'Doors' );
// 		}
// 	}
// 	return false;
}

function EnableNotifyHitWall()
{
	bTempDisableHitWall = false;
}

function bool ReadyToCharge()
{
	return false;
}

/*********************************************************************************************
* Debug Move Forward - send pawn into latent move forward in direction pawn is facing
********************************************************************************************* */

state DebugMoveForward extends Debugging
{
	function PushedState()
	{
		super.PushedState();
		AIActionStatus = "In DebugMoveForward state";
	}

Ready:
	Steering.EnableDefaultAcceleration();
	MoveTo( Pawn.Location + (vector(Pawn.Rotation) * 1024) );
	Steering.DisableDefaultAcceleration();
	PopState();
}

/*********************************************************************************************
* RotateToFocus state
********************************************************************************************* */

state RotateToFocus extends Debugging
{
	function PushedState()
	{
		super.PushedState();
		AIActionStatus = "In RotateToFocus state";
	}

Begin:
	SetFocalPoint( vect(0,0,0) );
	Focus = Enemy;

//	Pawn.DesiredRotation = Normalize(Rotator( (Focus == None ? GetFocalPoint() : Focus.Location) - Pawn.Location ));
//	DesiredRotation = Pawn.DesiredRotation;

	FinishRotation();
	SetFocalPoint(Vect(0,0,0));
	Pawn.ResetDesiredRotation();
	Focus = none;
	PopState();
}

state RotateToMoveTarget extends Debugging
{
	function PushedState()
	{
		super.PushedState();
		AIActionStatus = "In RotateToFocus state";
	}

Begin:
	SetFocalPoint( vect(0,0,0) );
	Focus = MoveTarget;

//	Pawn.DesiredRotation = Normalize(Rotator( (Focus == None ? GetFocalPoint() : Focus.Location) - Pawn.Location ));
//	DesiredRotation = Pawn.DesiredRotation;

	FinishRotation();
	SetFocalPoint(Vect(0,0,0));
	Pawn.ResetDesiredRotation();
	Focus = none;
	PopState();
}

/*********************************************************************************************
* DebugRoaming state - NPC will roam to locations within envelope distance of player
********************************************************************************************* */

state DebugRoaming extends Debugging
{
	function PushedState()
	{
		super.PushedState();
		if( Enemy == none )
		{
			Enemy = GetClosestEnemy();
		}
		AIActionStatus = "In DebugRoaming state";
		RoamStartTime = WorldInfo.TimeSeconds;
	}

	function Debug_Wander( optional float WanderDuraion=-1.f )
	{
		PopState();
	}

	function Actor GenerateRoamPath( Actor Goal, optional float Distance, optional bool bAllowPartialPath )
	{
		local Actor NewGoal;

		class'Path_TowardGoal'.static.TowardGoal( Pawn, Goal );
		class'Path_WithinTraversalDist'.static.DontExceedMaxDist( Pawn, MaxRoamDist, false );

		// real one with soft distances
		class'Path_WithinDistanceEnvelope'.static.StayWithinEnvelopeToLoc( Pawn, Goal.Location, RoamEnvelopeOuter, RoamEnvelopeInner,false,, true );

		// don't go somewhere we can't get out of
		class'Path_AvoidInEscapableNodes'.static.DontGetStuck( Pawn );
		class'Goal_Null'.static.GoUntilBust( Pawn, 1024 );

		NewGoal = FindPathToward( Goal );
		Pawn.ClearConstraints();
		return NewGoal;
	}

	function bool RoamTowardEnemy()
	{
		local actor Path;
		Path = GenerateRoamPath( Enemy, 100.f, true );
		if( Path != none )
		{
//			SetMoveGoal(  RouteGoal,,,,true);
			return true;
		}

		return false;
	}

	simulated function DrawDebug( HUD HUD, name Category )
	{
		DrawDebugText( KFHUDBase(HUD), "MaxRoamDist: "$MaxRoamDist$" RoamWaitMin: "$RoamWaitMin$" RoamWaitMax: "$RoamWaitMax );
		DrawDebugText( KFHUDBase(HUD), "RoamEnvelopeInner: "$RoamEnvelopeInner$" RoamEnvelopeOuter: "$RoamEnvelopeOuter );
	}

Begin:
	AIActionStatus = "Roaming toward enemy ("$Enemy$")";
	if( Enemy == none || !RoamTowardEnemy() )
	{
		AIActionStatus = "Failed to find roam location for "$Enemy;
		Sleep(1.5f);
		Goto('Begin');
	}

	// if we can't see our enemy from here, roam again!
	if( !IsPawnVisibleViaTrace(Enemy) )
	{
		`AILog( "Enemy wasn't visible, reacquiring", 'Command_Debug' );
		Sleep( 0.f );
		Goto( 'Begin' );
	}

	AIActionStatus = "Rotating toward enemy";
	Focus = Enemy;
	SetFocalPoint( vect(0,0,0) );
	Focus = MoveFocus;
	FinishRotation();
	Sleep( RandRange(RoamWaitMin, RoamWaitMax) );
	Goto( 'Begin' );
}

function bool CanSeePawn( Pawn Seen )
{
	return true;
}

/*********************************************************************************************
* Debugging
********************************************************************************************* */

simulated function DrawDebug( HUD HUD, name Category )
{
	//DrawDebugText( KFHUDBase(HUD), "Testing output from debug command" );
}

defaultproperties
{
	bAllowedToAttack=true
	bIgnoreNotifies=false
	bIgnoreStepAside=false
	MaxRoamDist=4096.f
	RoamEnvelopeOuter=1800.f
	RoamEnvelopeInner=750.f
	RoamWaitMin=0.5f
	RoamWaitMax=3.5f
}
