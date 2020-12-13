//=============================================================================
// AICommand_Base_Crawler
//=============================================================================
// Base controller for the Crawler
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//=============================================================================

class AICommand_Base_Crawler extends AICommand_Base_Zed
	within KFAIController_ZedCrawler;

var KFWallPathNode	LeapTarget;
var bool			bJumpingToWall;
var vector			TempDest;
var vector			OriginalTrans;
var actor			TempMoveGoal;

/*********************************************************************************************
* Initialization
********************************************************************************************* */

function Pushed()
{
	Super.Pushed();
	Originaltrans = Pawn.Mesh.Translation;
	if( OldFloor == vect(0,0,0) )
	{
		OldFloor = vect(0,0,1);
	}
	//EnableSeePlayer();
	GotoState( DefaultStateName );
}

function Paused( GameAICommand NewCommand )
{
	`AILog( self$" "$GetFuncName()$"() Paused for "$NewCommand, 'Crawler' );
	Super.Paused( NewCommand );
}

function BeginMoveToWall()
{
    // Disabled for Early Access 1/14/15 as part of disabling wall walking - Ramm
	//GotoState( 'MoveToWall',, true );
}

function SightCheck();

function Resumed( name OldCommandName )
{
	`AILog( self$" "$GetFuncName()$"() (OldCommandName: "$OldCommandName$")", 'Crawler' );
	Super.Resumed( OldCommandName );
// Untested WIP
// 	DisableSeePlayer();
// 	if( Pawn.Physics == PHYS_Walking || Pawn.Physics == PHYS_Falling )
// 	{
// 		DisableMeleeRangeEventProbing();
// 		GotoState( 'MoveToWall' );
// 	}
// 	else if( GetStateName() != DefaultStateName && Pawn.Physics == PHYS_Spider && CanSee(Enemy) )
// 	{
// 		GotoState( 'MoveToWall', 'Begin' );
// 	}
// 	else
// 		GotoState( DefaultStateName,, true );
}

// Disabled for Early Access 1/14/15 as part of disabling wall walking - Ramm
//state MoveToWall
//{
//	event BeginState( name PreviousStateName )
//	{
//	}
//
//	event EndState( name NextStateName )
//	{
//	}
//
//	function BeginMoveToWall();
//
//	function SightCheck()
//	{
//// 		if( FRand() < 0.33f && Enemy.Controller.CanSee(Pawn) && Pawn.Physics == PHYS_Spider )
//// 		{
//// 			StopAllLatentMovement();
//// 			JumpToTarget();
//// 			return;
//// 		}
//// 		SetTimer( 1.f + FRand() * 2.f, false, nameof(SightCheck), self );
//	}
//
//	function JumpToTarget()
//	{
//		local Vector Suggested;
//		local NavigationPoint ClosestToEnemy, ClosestToMe;
//		local actor Target;
//
//		ClosestToEnemy = class'NavigationPoint'.static.GetNearestNavToActor( Enemy, class'KFPathnode' );
//		DrawDebugSphere( ClosestToEnemy.Location, 32, 8, 255, 0, 0, true );
//		ClosestToMe = class'NavigationPoint'.static.GetNearestNavToActor( Pawn, class'KFPathnode' );
//		DrawDebugSphere( ClosestToMe.Location, 32, 8, 0, 255, 0, true );
//		if( VSize( ClosestToEnemy.Location - Pawn.Location ) < VSize(Enemy.Location - Pawn.Location) )
//		{
//			Target = ClosestToEnemy;
//		}
//		else
//		{
//			Target = ClosestToMe;
//		}
//
//		//class'NavigationPoint'.static.GetAllNavInRadius( Outer, Enemy.Location
//		if( Target != none )// && ActorReachable(Target) && VSize(Target.Location - Pawn.Location) < 750.f )
//		{
//			MyKFPawn.SuggestJumpVelocity( Suggested, Target.Location, Pawn.Location );
//			MyKFPawn.Velocity = Suggested * MyKFPawn.Floor;;
//			MoveTarget = Target;
//			//MyKFPawn.Acceleration = vect( 0,0,0 );
//			MyKFPawn.SetPhysics( PHYS_Falling );
//			Pawn.ResetDesiredRotation();
//			Focus = none;
//			SetFocalPoint(MoveTarget.Location);
//	//		Focus = none;
//
//			//Focus = Enemy;
//		}
//	}
//
//	function SetBestAnchor()
//	{
//		local NavigationPoint BestAnchor;
//		local float Dist;
//
//		BestAnchor = Pawn.GetBestAnchor( Pawn, Pawn.Location, true, false, Dist );
//		if( BestAnchor != none )
//		{
//			Pawn.SetAnchor( BestAnchor );
//		}
//	}
//
//Jumping:
//	if( MyKFPawn.IsPawnMovingTowardMe( Enemy, 250.f ) )
//	{
//		Sleep( 0.1f );
//		Goto( 'Jumping' );
//	}
//
//	Sleep( FRand() );
////	SetFocalPoint(vect(0,0,0) );
////	Focus = Enemy;
//	StopAllLatentMovement();
//	AIZeroMovementVariables();
//	JumpToTarget();
//	WaitForLanding();
//	SetBestAnchor();
//	LastAmbushNode = none;
//	if( Pawn.Physics == PHYS_Walking )
//	{
//		GotoState( DefaultStateName,, true );
//	}
//	else
//	{
//		if( FRand() < 0.22f )
//		{
//			Sleep( 0.5f );
//		}
//		GotoState( DefaultStateName,, true );
//	}
//
//Begin:
//	// do not do this, this is set in the above function do not reset it
//	//MyKFPawn.bIsSprinting = true;
//	MyKFPawn.SetSprinting( true );
//	if( FindAmbushNode(true) )
//	{
//		LastAmbushNode = NavigationPoint( RouteGoal );
//
//		SetMoveGoal(  RouteGoal,, false,, false, true, false, false, true );
//		Goto( 'Jumping' );
//	//	Sleep( 0.f );
//	}
//	GotoState( DefaultStateName,, true );
//Moving:
//	if( Steering != none )
//	{
//		Steering.EnableDefaultAcceleration();
//	}
//	//MyKFPawn.bIsSprinting = true;
//	MyKFPawn.SetSprinting( true );
//	SetTempDest();
//	if( VSize( TempDest - Pawn.Location ) > 96.f  )
//	{
//		//MoveTo( Pawn.Location + TempDest * 512.f );
//		MoveTo( TempDest );
//	}
//	else
//	{
//		Sleep( 0.1f * FRand() );
//	}
//
//	Sleep( 0.f );
//	Goto( 'Begin' );
//}

function CheckWalls()
{
	local KFWallPathNode KFWP, BestKFWP;
	local float BestDist;

// 	if( Pawn.Physics == PHYS_Spider )
// 	{
//		return;
//	}

	DisableSeePlayer(0.f);
	Enemy = none;
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
	LeapTarget = BestKFWP;
	StopAllLatentMovement();
	//GotoState( 'ZedBaseCommand', 'Leaping' );
}

// Disabled for Early Access 1/14/15 as part of disabling wall walking - Ramm
//state ZedBaseCommand
//{
//	event BeginState( name PreviousStateName )
//	{
//		super.BeginState( PreviousStateName );
//		DisableSeePlayer(0.f);
//		//SetTimer( 1.5f, nameof(CheckWalls), true, self );
//	}
//// Leaping:
//// 	bJumpingToWall = true;
//// 	DoWallLeap( LeapTarget );
////  	if( Pawn.Physics == PHYS_Falling )
//// 	{
////  		WaitForLanding();
////  	}
//// 	Goto( 'Begin' );
//}

// Disabled for Early Access 1/14/15 as part of disabling wall walking - Ramm
//function bool NotifyFallingHitWall(vector HitNormal, actor Wall)
//{
//	return NotifyHitWall( HitNormal, Wall );
//}
//
//// 1.31 check bCanStepUpOn below
//function bool NotifyHitWall( vector HitNormal, actor HitActor )
//{
//	local KFDoorActor HitDoor;
//
//	HitDoor = KFDoorActor( HitActor );
//	if( HitDoor != none && MyKFPawn.Physics != PHYS_Spider )
//	{
//		if( HitDoor.WeldIntegrity <= 0 && KFDoorMarker(HitDoor.MyMarker) != none && !HitDoor.IsCompletelyOpen() )
//		{
//			DisableNotifyHitWall(0.25f);
//			WaitForDoor( HitDoor );
//			`AILog( "NotifyHitWall() while in MoveToGoal, Wall: "$HitActor$" Using door and waiting for it to open", 'Doors' );
//			HitDoor.UseDoor(Pawn);
//			return true;
//		}
//		// NOTE: Unless returning true, if the Wall is a closed door, SuggestMovePreparation event will be called on the associated KFDoorMarker
//		`AILog( GetFuncName()$"() Wall: "$HitActor$" HitNormal: "$HitNormal$" ran into a door!", 'Doors' );
//		if( !HitDoor.IsCompletelyOpen() && HitDoor.WeldIntegrity > 0 && (Pawn.Anchor == HitDoor.MyMarker || (DoorEnemy != none && (DoorEnemy == HitDoor || PendingDoor == HitDoor))) )
//		{
//			DisableNotifyHitWall(0.25f);
//			`AILog( GetFuncName()$"() calling NotifyAttackDoor for "$HitDoor, 'Doors' );
//			NotifyAttackDoor( HitDoor );
//			return true;
//			//`AILog( GetFuncName()$"() has door enemy "$DoorEnemy, 'Doors' );
//		}
//	}
//	if( HitActor != none && !HitActor.bCanStepUpon )
//	{
//		`warn( GetFuncName()$"() Wall "$HitActor$" bCanStepUpOn is FALSE" );
//		return false;
//	}
//
//	if( Pawn != none && HitActor != none && Pawn.Physics == PHYS_Falling )
////		if( bJumpingToWall )
//	{
//		`AILog( "*NotifyHitWall setting physics to PHYS_Spider and base to "$HitActor, 'Crawler' );
//		Pawn.SetPhysics( PHYS_Spider );
//		Pawn.SetBase( HitActor, HitNormal );
//		DisableNotifyHitWall(1.f);
//	}
//	return true;
//}

// Disabled for Early Access 1/14/15 as part of disabling wall walking - Ramm
//state RotateToFocus
//{
//	function PushedState()
//	{
//		super.PushedState();
//		AIActionStatus = "In RotateToFocus state";
//	}
//
//Begin:
//// 	SetFocalPoint( vect(0,0,0) );
//// 	Focus = LeapTarget;
//// 	FinishRotation();
//// 	SetFocalPoint(Vect(0,0,0));
//// 	Focus = none;
//// 	Pawn.ResetDesiredRotation();
//	PopState();
//}

function SetTempDest()
{
	local vector V, ProjFocus, X, EnemyLoc;
	local float Distance;

	if( Enemy == none )
	{
		Enemy = GetALocalPlayerController().Pawn;
	}

	EnemyLoc = Enemy.Location;
	EnemyLoc.Z = Pawn.Location.Z + RandRange( -64, 64 );
	v = EnemyLoc - Pawn.Location;
	Distance = (V dot Pawn.Floor);
	ProjFocus = EnemyLoc - Distance * Pawn.Floor;
	X = normal(ProjFocus - Pawn.Location);
	//vector v = Focus - Pawn->Location
	if( X != vect(0,0,0) )
	{
		TempDest = ProjFocus;
		//	return true;
	}
	else
	{
		//	return false;
	}
}

// Disabled for Early Access 1/14/15 as part of disabling wall walking - Ramm
//function bool NotifyBaseChange( actor NewBase, vector NewFloor )
//{
////	if( NewFloor != OldFloor && Pawn.Physics == PHYS_Spider && NewBase != none /*&& bPreciseDestination*/ )
////	{
////		GotoState( GetStateName(), 'HandleNewFloor' );
////
////
////	}
////	else
//
//	if( NewFloor != OldFloor )
//	{
//		if( NewFloor.Z > 0.7f ) // 2.9.2014 was 		if( NewFloor == vect(0,0,1) )
//		{
//			if( Pawn.Physics == PHYS_Spider )
//			{
//				`AILog( GetFuncName()$"() NewFloor is upright, physics is spider - setting physics back to walking!", 'Crawler' );
//				Pawn.SetPhysics(PHYS_Walking);
//			}
//		}
//		else if( Pawn.Physics == PHYS_Walking )
//		{
//			Pawn.SetPhysics( PHYS_Spider );
//		}
//	}
//
//	 `AILog( GetFuncName()$" in "$self$" NewBase: "$NewBase$" NewFloor: "$NewFloor$" Pawn Floor: "$Pawn.Floor$" OldFloor: "$OldFloor$" Physics: "$Pawn.GetPhysicsName(), 'Crawler' );
//	if( NewFloor != OldFloor &&  Pawn != none && Pawn.Physics == PHYS_Spider && NewBase != none && !NewBase.IsA('Pawn') && NewBase.bWorldGeometry )
//	{
//		if( IsDoingLatentMove() )
//		{
//// 			StopAllLatentMovement();
//// 			Pawn.ZeroMovementVariables();
//// 			MoveTimer = -1.f;
//		}
//		//`AILog( "NOTIFYBASECHANGE: "$NewBase$" New floor: "$NewFloor$" Old floor: "$OldFloor$" Floor set yet? "$Pawn.Floor );
//		//GotoState( GetStateName(), 'HandleNewFloor' );
//	}
//
//	return false;
//}
//
//function bool NotifyLanded(vector HitNormal, Actor FloorActor )
//{
//	`AILog( "**** NotifyLanded **** HitNormal: "$HitNormal$" FloorActor: "$FloorActor$" Floor is currently "$Pawn.Floor );
//
//	bJumpingToWall = false;
//	if( Pawn.Floor.Z == 1.f && (Pawn.Physics == PHYS_Walking || Pawn.Physics == PHYS_Falling) )
//	{
//		Pawn.SetPhysics( PHYS_Walking );
//		return true;
//	}
//
//
//	bJumpingToWall = false;
//	`AILog( GetFuncName()$" setting physics to PHYS_Spider, FloorActor: "$FloorActor, 'Crawler');
//	Pawn.SetPhysics(PHYS_Spider);
//	return true;
//}

// // Disabled for Early Access 1/14/15 as part of disabling wall walking - Ramm P.S. also doesn't seem to be called anywhere
//state Debug_InCombat
//{
//	function bool NotifyLanded(vector HitNormal, Actor FloorActor )
//    {
//		`AILog( GetFuncName()$" 2 setting physics to PHYS_Spider, FloorActor: "$FloorActor, 'Crawler' );
//		bJumpingToWall = false;
//        Pawn.SetPhysics(PHYS_Spider);
//        return true;
//    }
//
//	function Tick( float DeltaTime )
//	{
////		local vector CeilingTrans;
//
//// 		if( Pawn.Floor.Z == -1 )
//// 		{
//// 			CeilingTrans = OriginalTrans;
//// 			CeilingTrans.X = 36;
//// 			Pawn.Mesh.SetTranslation( CeilingTrans );
//// 		}
//// 		else
//// 		{
//// 			Pawn.Mesh.SetTranslation( vect(0,0,-36) );
//// 		}
//		super.Tick( DeltaTime );
//	}
//
//	event BeginState( name PreviousStateName )
//	{
//		local KFWallPathNode KFWP, BestKFWP;
//		local float BestDist;
//
//		DisableSeePlayer(0.f);
//		Enemy = none;
//		foreach WorldInfo.AllNavigationPoints( class'KFWallPathNode', KFWP )
//		{
//			if( BestKFWP == None || VSize(KFWP.Location - Pawn.Location) < BestDist )
//			{
//					BestDist = VSize(KFWP.Location - Pawn.Location);
//					BestKFWP = KFWP;
//			}
//		}
//		LeapTarget = BestKFWP;
//		//GetAxes(Pawn.Rotation,ViewX,ViewY,ViewZ);
//	}
//
//	function bool NotifyHitWall(vector HitNormal, actor HitActor)
//	{
//		if( !HitActor.bCanStepUpon )
//		{
//			`warn( GetFuncName()$"() Wall "$HitActor$" bCanStepUpOn is FALSE" );
//		}
//
//		if( bJumpingToWall )
//		{
//			`AILog( GetFuncName()$" 3 setting physics to PHYS_Spider, HitActor: "$HitActor, 'Crawler' );
//			Pawn.SetPhysics( PHYS_Spider );
//			Pawn.SetBase( HitActor, HitNormal );
//		}
//	 	return true;
// 	}
//
//	function SetTempDest()
//	{
//		local vector V, ProjFocus, X, EnemyLoc;
//		local float Distance;
//
//		if( Enemy == none )
//		{
//			Enemy = GetALocalPlayerController().Pawn;
//		}
//
//		EnemyLoc = Enemy.Location;
//		EnemyLoc.Z = Pawn.Location.Z + RandRange( -72, 72 );
//		v = EnemyLoc - Pawn.Location;
//		Distance = (V dot Pawn.Floor);
//		ProjFocus = EnemyLoc - Distance * Pawn.Floor;
//		X = normal(ProjFocus - Pawn.Location);
//		if( X != vect(0,0,0) )
//		{
//			TempDest = ProjFocus;
//		}
//	}
//
//Begin:
//	if( Physics == PHYS_Falling )
//	{
//		WaitForLanding();
//	}
//	Pawn.SetPhysics(Phys_Walking);
//	if( LeapTarget != none )
//	{
//		PushState( 'RotateToFocus' );
//	}
//
// //	Focus = none;
//	Sleep( 1.f );
//	bJumpingToWall = true;
//	//DoWallLeap( LeapTarget );
// 	if( Pawn.Physics == PHYS_Falling )
//	{
// 		WaitForLanding();
// 	}
//
////	Enemy = GetALocalPlayerController().Pawn;
//	Sleep( 5.f );
//	Pawn.SetAnchor( LeapTarget );
//	SetMoveGoal( TempMoveGoal,, false,, false, true,,, true );
//Moving:
//	MyKFPawn.SetSprinting( true );
//	if( VSize( TempDest - Pawn.Location ) > 350.f )
//	{
//		//MoveTo( Pawn.Location + TempDest * 512.f );
//		MoveTo( TempDest );
//	}
//	else
//	{
//		Sleep( 2.f * FRand() );
//	}
//	Goto( 'Moving' );
//
//HandleNewFloor:
//	if( Pawn != none && Pawn.IsAliveAndWell() )
//	{
//		AIZeroMovementVariables();
//		StopAllLatentMovement( true );
//		Sleep( 0.1f );
//		Goto( 'Moving' );
//	}
//}

DefaultProperties
{
}
