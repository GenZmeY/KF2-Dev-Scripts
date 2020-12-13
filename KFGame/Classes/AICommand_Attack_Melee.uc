//=============================================================================
// AICommand_Attack_Melee
//=============================================================================
// AI Action for melee attacks
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//=============================================================================

class AICommand_Attack_Melee extends AICommand_SM_Attack
	within KFAIController
	native(AI);

/** Renders sphere around NPC when aborting attack, stays visible from initial abort time until command is popped */
var bool		bDebugShowAbortSequence;
var vector		StepAheadLocation;
var vector		CircleDistance;
var vector		CirclePoint;
var int			CircleDir;
var bool		bNewEnemyPending;

/*********************************************************************************************
* Initialization
**********************************************************************************************/

/** Simple constructor that pushes a new instance of the command for the AI */
static function bool Melee( KFAIController AI, optional Actor InTarget, optional byte InSMFlags )
{
	local AICommand_Attack_Melee Cmd;

	if( AI != None )
	{
		Cmd = new(AI) default.class;
		if( Cmd != None )
		{
			// Use melee target if set, in case we're not attacking a real enemy (a door, for example)
			if( InTarget != none )
			{
				Cmd.AttackTarget = InTarget;
			}
			else
			{
				Cmd.AttackTarget = AI.Enemy;
			}
			Cmd.SMFlags = InSMFlags;

			//Cmd.bSingleAttack = bInSingleAttack;
			AI.PushCommand( Cmd );
			return true;
		}
	}
	return false;
}

function Pushed()
{
	super.Pushed();
	if( IsDoingLatentMove() )
	{
		`warn( MyKFPawn@"STILL DOING LATENT MOVE "$MoveTimer );
	}
	AIZeroMovementVariables();
//	Focus = none; // Temp!
//	MyKFPawn.bBlocksNavigation = true;
	MeleeTarget = (KFPawn(AttackTarget)!=none?KFPawn(AttackTarget):KFPawn(Enemy));
	bFinishRotationBeforeAttack = bUseDesiredRotationForMelee;
	AIActionStatus = "Attempting to attack "$AttackTarget;
}

function Popped()
{
	AIActionStatus = "Finished melee attack";
	super.Popped();
//	MyKFPawn.bBlocksNavigation = false;
	NotifyMeleeAttackFinished();
	MeleeTarget = none;
	AIActionStatus = "Finished attack "$MeleeTarget;

	if( Pawn != none )
	{
		Pawn.ZeroMovementVariables();
	}
}

event bool NotifyBump( Actor Other, vector HitNormal )
{
	`AILog( GetFuncName()$" IN MELEE ATTACK", 'PathWarning' );
	DisableBump( 0.25f );
	return true;
}

function Paused( GameAICommand NewCommand )
{
	`AILog( self$" PAUSED BY "$NewCommand, 'Warning');
	super.Paused( NewCommand );
}

function Resumed( name OldCommandName )
{
	`AILog( self$" Resumed, OldCommand: "$OldCommandName );
	// Added 11/19 due to hit reactions pausing Melee command
	super.Resumed( OldCommandName );
	if( OldCommandName == 'AICommand_Pause' )
	{
// 		Status = 'Failure';
// 		PopCommand( self );
		GotoState( 'DelayFailure' );
	}
}


/*********************************************************************************************
* Notifications
**********************************************************************************************/

/** Prevent switching enemies during attacks */
function bool CanChangeEnemy( Pawn NewEnemy )
{
// 	if( CachedChildCommand != None )
// 	{
// 		return CachedChildCommand.CanChangeEnemy( NewEnemy );
// 	}

	return false;
}

// function bool NotifyPlayerBecameVisible( Pawn VisiblePlayer )
// {
// 	`AILog( GetFuncName()$"() Seen: "$VisiblePlayer$" ignoring event.", 'SeePlayer' );
// 	DisableSeePlayer();
// 	return false;
// }

/** Notification from controller that enemy has become visible */
function bool NotifyPlayerBecameVisible( Pawn VisiblePlayer )
{
	if( VisiblePlayer.IsAliveAndWell() && AttackTarget != none && !AttackTarget.IsA('Pawn') )
	{
		if( ActorReachable(VisiblePlayer) && SetEnemy(VisiblePlayer) )
		{
			bNewEnemyPending = true;
			return false;
		}
	}
	return true;
}

/*********************************************************************************************
* Debug
**********************************************************************************************/

event String GetDumpString()
{
	if( Enemy != none )
	{
		return Super.GetDumpString()@"AttackTarget:"@AttackTarget$" Enemy: "$Enemy$" Dist: "$VSize( Enemy.Location - Pawn.Location);
	}

	return Super.GetDumpString()@"No enemy! AttackTarget:"@AttackTarget;
}

function float GetAbortAttackDistanceSq()
{
	local vector2D AttackRange;
	local int AttackIdx;

	if( MyKFPawn != none && MyKFPawn.PawnAnimInfo != none && SMFlags != 255 )
	{
		AttackIdx = SMFlags & 15;
		AttackRange = MyKFPawn.PawnAnimInfo.GetAttackRangeByName( MyKFPawn.PawnAnimInfo.Attacks[AttackIdx].Tag );
		return AttackRange.Y * AttackRange.Y;
	}

	return 57600.f; // (240UU, old default value)
}

/*********************************************************************************************
* Special Move State
********************************************************************************************* */

state Command_SpecialMove
{
	function BeginState( name PreviousStateName )
	{
		//local float DistFromTargetSq, RangeToCheck;
		if( KFDoorActor(AttackTarget) != none && !KFDoorActor(AttackTarget).IsCompletelyOpen() &&
			MyKFPawn.CanDoSpecialMove(SM_MeleeAttackDoor) && MyKFPawn.PawnAnimInfo != none && MyKFPawn.PawnAnimInfo.DoorAttacks.Length > 0 )
		{
			AttackSpecialMove = SM_MeleeAttackDoor;
		}

		if( MyKFPawn.MeleeAttackHelper == none )
		{
			return;
		}

		// Move ahead a little if enemy isn't a Pawn
		if( AttackTarget != none && !AttackTarget.IsA('Pawn') )
		{
			EnableSeePlayer();

		}
	}

	function ContinuedState()
	{
		GotoState( DefaultStartState,, true );
	}

	function bool ExecuteSpecialMove()
	{
	//	local vector DirToEnemy;
	//	local vector SocketLocation;

	//	local KFSM_MeleeAttack AttackSM;

		if( MyKFPawn == None || !MyKFPawn.IsAliveAndWell() || AttackTarget == none || (Pawn(AttackTarget) != none &&
			!Pawn(AttackTarget).IsAliveAndWell()) || (AttackTarget.IsA('KFDoorActor') && KFDoorActor(AttackTarget).IsCompletelyOpen()) )
		{
			`AILog( self$" ExecuteSpecialMove() returning early "$AttackTarget, 'Command_Attack_Melee' );
			return false;
		}

		`AILog( self$" ExecuteSpecialMove() AttackTarget: "$AttackTarget, 'Command_Attack_Melee' );

		// Keep rotating toward melee target
 		if( AttackTarget != None && Pawn != none && !Pawn.bCrawler )
  		{
 			SetDesiredRotation( rotator(AttackTarget.Location - Pawn.Location) ); // 5.14 (lock it too?)
  		}


		// Start the special move after rotating
		if( (Pawn.bCrawler || Pawn.ReachedDesiredRotation()) && AttackTarget != none )
		{
			`AILog( self$" Target in melee range (Dist: "$VSize(AttackTarget.Location - Pawn.Location)$"... do attack", 'Command_Attack_Melee' );
			MyKFPawn.DoSpecialMove( GetSpecialMove(),,, SMFlags );
			return MyKFPawn.SpecialMove == AttackSpecialMove;
		}
		`AILog( self$" ExecuteSpecialMove returning false because ReachedDesiredRotation isn't done?  AttackTarget: "$AttackTarget, 'Command_Attack_Melee' );
		return false;
	}

	/** Melee attack is complete if... */
	function bool IsSpecialMoveComplete()
	{
		local bool bInvalidTarget;

		//`AILog(GetFuncname()@MyKFPawn@MyKFPawn.bDoingMeleeAttack@MyKFPawn.IsDoingMeleeAttack()@MeleeTarget@isValidMeleeTarget(KFPawn(MeleeTarget)));

		if ( MyKFPawn == None || AttackTarget == None || AttackTarget.bDeleteMe || (KFDoorActor(AttackTarget) != none ||
			(KFPawn(AttackTarget) != None && (!IsValidAttackTarget((MeleeTarget)) || VSize(AttackTarget.Location - MyKFPawn.Location) > MyKFPawn.MeleeRange))) ||
			(AttackTarget.IsA('KFDoorActor') && KFDoorActor(AttackTarget).IsCompletelyOpen()) )
		{
			bInvalidTarget = true;
			// don't return here as that will cause us to slide if we're in the middle of a finishing move
		}

		if( MyKFPawn != None )
		{
			if( MyKFPawn.IsDoingMeleeAttack() )
			{
				return false;
			}
			if( !MyKFPawn.IsDoingSpecialMove( GetSpecialMove() ) )
			{
				return true;
			}
		}

		if( bInvalidTarget )
		{
			//`AILog( GetFuncName()@"check #2 returning true, MyKFPawn:" @ MyKFPawn@MyKFPawn.IsDoingMeleeAttack()@IsValidMeleeTarget(KFPawn(Enemy)), 'Command_Attack_Melee' );
			return true;
		}
		return false;
	}

	event HandleAICommandSpecialAction()
	{
		//local vector SocketLocation, DirToEnemy;

		// If not using root motion...
		if( Pawn.Mesh.RootMotionMode != RMM_Accel && Enemy != none && MyKFPawn != None )
		{
			// Keep rotating toward the AttackTarget
			if( bUseDesiredRotationForMelee && AttackTarget != none )
			{
				SetDesiredRotation( rotator(AttackTarget.Location - Pawn.Location) );
			}
			else
			{
				Focus = AttackTarget;
			}

			//MyKFPawn.Mesh.GetSocketWorldLocationAndRotation( 'FireballSocket', SocketLocation );
			//DirToEnemy = ( CalcAimLocToHit(Enemy.Location, SocketLocation, 1800, 1800, Enemy.Velocity) - SocketLocation);
			//SetDesiredRotation( rotator(DirToEnemy) );

			// Abort the attack if it's played for at least one second and the target has since moved out of range
			//if( bCanBeAborted && !bAttackAborted && !InMeleeRange(AttackTarget.Location) && !AttackTarget.IsA('KFDoorActor') && TimePlayed > 1.f )
			// (jc) Changed distance check to use AttackTarget instead of enemy 7/15/14
			if( bCanBeAborted && !bAttackAborted && (VSizeSq(Pawn.Location - AttackTarget.Location) > GetAbortAttackDistanceSq()) && !AttackTarget.IsA('KFDoorActor') )
			{
				`AILog( self$" 1 Aborting attack.. AttackTarget: "$AttackTarget$" Dist: "$VSize( AttackTarget.Location - Pawn.Location )$" Speed: "$VSize( Pawn.Velocity ), 'Command_Attack_Melee' );
				if( MyKFPawn.IsDoingSpecialMove( GetSpecialMove() ) )
				{
					if( bDebugShowAbortSequence )
					{
						DrawDebugSphere( Pawn.Location, 32, 16, 255, 255, 0, false );
					}
					UpdateHistoryString( "attack aborted (out of range)" );
					bAttackAborted = true;
					KFSM_MeleeAttack( MyKFPawn.SpecialMoves[ GetSpecialMove() ] ).AbortedByAICommand();
				}
			}
			if( bCanBeAborted && AttackTarget != none && AttackTarget.IsA('KFDoorActor') )
			{
				if( KFDoorActor( AttackTarget ).WeldIntegrity <= 0 || KFDoorActor( AttackTarget ).IsCompletelyOpen() )
				{
					`AILog( self$" 2 Aborting attack.. AttackTarget: "$AttackTarget$" Dist: "$VSize( AttackTarget.Location - Pawn.Location )$" Speed: "$VSize( Pawn.Velocity ), 'Command_Attack_Melee' );
					if( MyKFPawn.IsDoingSpecialMove( GetSpecialMove() ) )
					{
						bAttackAborted = true;
						KFSM_MeleeAttack( MyKFPawn.SpecialMoves[ GetSpecialMove() ] ).AbortedByAICommand();
					}
				}
			}
		}
	}

	function bool HandleSpecialMoveEnded()
	{
// 		if( MyKFPawn.PawnAnimInfo != none )
// 		{
// 			if( SMFlags <= MyKFPawn.PawnAnimInfo.Attacks.Length && MyKFPawn.PawnAnimInfo.Attacks[SMFlags].Tag == 'Projectile' && FRand() < 0.24f )
// 			{
// 				GotoState( GetStateName(), 'TauntEnemy' );
// 				return true;
// 			}
// 		}
		return false;
	}

	function FinishedSpecialMove()
	{
		`AILog( GetFuncName(), 'Command_Attack_Melee' );
		UpdateLastMeleeTime( EAS_FullBody );
		Status = 'Success';

		if( HandleSpecialMoveEnded() )
		{
			return;
		}
		if( bSingleAttack )
		{
			EndOfMeleeAttackNotification();
		}
	}

TauntEnemy:
	if( IsTimerActive(nameof(SpecialMoveTimeout), self) )
	{
		SetTimer( 15.f, false, nameof(SpecialMoveTimeout), self );
	}
	bCanBeAborted = false;
	Pawn.ZeroMovementVariables();
	MoveTimer = -1.f;
	StopAllLatentMovement();
	class'AICommand_TauntEnemy'.static.Taunt( Outer, KFPawn(Enemy), TAUNT_Standard );
	RouteCache_Empty();
	Sleep( 0.33f );
	Status = 'Success';
	PopCommand( self );
}

function NotifyEnemyChanged( optional Pawn OldEnemy )
{
	bNewEnemyPending = true;
}

state TestMove
{
Begin:
	StepAheadLocation = GetStepAheadLocation();
	MoveTo( GetStepAheadLocation(), AttackTarget,, Pawn.bIsWalking );
	Sleep( 0.f );
	PopState();
}

function CircleTimer ();

state Circle
{
	function PushedState ()
	{
		MyKFPawn.bAllowAccelSmoothing = false;
		super.PushedState ();
	}

	function PoppedState ()
	{
		super.PoppedState ();
		//MyKFPawn.bAllowAccelSmoothing = true;
		if( Pawn != None )
		{
			Pawn.ZeroMovementVariables();
		}
	}

	function bool GetCirclePoint()
	{
		local bool bResult;
		local Vector EnemyToPawn;
		local float Dist;

		EnemyToPawn = Pawn .Location - Enemy.Location ;
		Dist = VSize (EnemyToPawn);
		if( Dist < CircleDistance.X )
		{
			EnemyToPawn *= (CircleDistance .X / Dist);
		}
		if( Dist > CircleDistance. Y )
		{
			EnemyToPawn *= (CircleDistance .Y / Dist);
		}

		CirclePoint = Enemy .Location + ( EnemyToPawn >> (rot (0,8192,0) * CircleDir));

		bResult = PointReachable ( CirclePoint );

		`AILog( GetFuncName()@CirclePoint @Dist@ bResult, 'Command_Attack_Melee' );

		return bResult ;
	}

Begin:
	//debug
	`AILog( self$" BEGIN TAG" @GetStateName(), 'Command_Attack_Melee' );

	SetTimer( 1.25f + (FRand () * 1.25f), false, nameof( self.CircleTimer ), self );
	while( IsTimerActive( 'CircleTimer', self ) )
	{
		if( GetCirclePoint() )
		{
			SetFocalPoint( Enemy.Location, true );
			MoveTo( CirclePoint, Enemy,, false);
		}
		else
		{
			break;
		}
	}

	if( FRand () < 0.6f && normal( Pawn.Location - Enemy. Location ) dot vector ( Enemy.Rotation ) < 0.94f )
	{
		Goto( 'Begin' );
	}

	PopCommand( self );
}


/**
* Returns a location that Best moves out of the way of StepAsideGoal.
*/
function vector GetStepAheadLocation()
{
	local vector X;
	local float StepDist;
	local vector CheckLocation, HitLocation, HitNormal;
	local float DistFromTarget, RangeToCheck;

	DistFromTarget = VSize( AttackTarget.Location - Pawn.Location );
	RangeToCheck = MyKFPawn.MeleeAttackHelper.GetMeleeRange();

	StepDist = DistFromTarget - RangeToCheck;

	//X = Vector(Pawn.Rotation);
	X = (AttackTarget.Location - Pawn.Location);

	// Ignore vertical component
	X.Z = 0;
	X	= Normal(X);
	CheckLocation = Pawn.Location + X * StepDist;

	StepDist = MaxStepAsideDist;

	if( PointReachable(CheckLocation) &&
		(Trace(HitLocation, HitNormal, CheckLocation, Pawn.Location, true) == None || VSize(HitLocation - Pawn.Location) > StepDist * 0.5) )
	{
		return CheckLocation;
	}

	return vect(0,0,0);
}

DefaultProperties
{
	bSingleAttack=true
	DefaultStartState=Command_SpecialMove
	bIgnoreNotifies=true
	bIgnoreStepAside=true
	bShouldCheckSpecialMove=false // Newest
	PostSpecialMoveSleepTime=0.0f
	PostSpecialMoveAbortedSleepTime=0.3f
	AttackSpecialMove=SM_MeleeAttack
	bZeroPawnAccelWhenPopped=true
	bCanBeAborted=true
	bDebugShowAbortSequence=false
	bAllowedToAttack=false
	CircleDistance=(X=128.f,Y=256.f)
}
