//=============================================================================
// AICommand_HeadlessWander
//=============================================================================
// Command used by headless Zeds during the last few moments of their lives.
// Unlike most commands, this one should not allow any transitions to other
// commands. If a Zed begins using this command, it should stay active until
// the Zed dies after bleeding out by some other means.
//
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//=============================================================================
class AICommand_HeadlessWander extends AICommand
	within KFAIController;

var Controller	EventInstigator;
var float		RandomMoveDist;
var float		DotCheck;
var float		LastHeadlessAttackTime;
var bool		bDebugWander;
var vector		Dest;

static function bool HeadlessWander( KFAIController AI )
{
	local AICommand_HeadlessWander Cmd;

	if( AI != None )
	{
		Cmd = new(AI) class'AICommand_HeadlessWander';
		if( Cmd != None )
		{
			//Cmd.EventInstigator = Controller(UserActor);
			AI.PushCommand(Cmd);
			return true;
		}
	}

	return false;
}

/** Set things up for the start of the command */
function Pushed()
{
	if( Steering != none )
	{
		Steering.EnableDefaultAcceleration();
	}
	/** Make sure I'm not sprinting anymore */
	MyKFPawn.SetSprinting( false );

	/** Disallow AdjustFromWall() instigated jumps over obstructions */
	MyKFPawn.bCanJumpOverWalls = false;
	/** Slow my Pawn's rotation rate */
	RotationRateMultiplier = 0.33f;
	LastHeadlessAttackTime = WorldInfo.TimeSeconds;
	/** Reset my focus and focalpoint */
	Focus = None;
	SetFocalPoint(vect(0,0,0));
	/** Turn off HeadTracking, if it's currently on */
	MyKFPawn.StopLookingAtPawn();
	/** Allow combat, since I might try to blindly swipe at any Zed/player I happen to bump */
	bAllowCombatTransitions = true;
	/** Don't allow notifications from TickMeleeDecision() about being in attack range */
	DisableMeleeRangeEventProbing();
	/** Stop any latent MoveTo/MoveTowards */
	StopAllLatentMovement();
	/** Zero non-falling accel and velocity */
	AIZeroMovementVariables();
	if( MyKFPawn.IsDoingSpecialMove() )
	{
		/** This is a special case - interrupt any current special move I'm doing */
		MyKFPawn.EndSpecialMove();
	}

	if( MyKFPawn != none && MyKFPawn.bCanCloak && MyKFPawn.bIsCloaking )
	{
		/** Uncloak (Stalker) */
		MyKFPawn.SetCloaked( false );
	}
	GotoState( 'RandomWander' );
}

function Popped()
{
	if( Steering != none )
	{
		Steering.DisableDefaultAcceleration();
	}
	super.Popped();
}

function bool AllowTransitionTo( class<GameAICommand> AttemptCommand )
{
	return false; // One way ticket
}

function bool ShouldRunSomewhereElse()
{
	return FRand() < 0.4f;
}

function vector CalcTurnDirection( rotator Direction, float Spread )
{
	local float Radius, ZDelta, YDelta;
	local vector X, Y, Z, Offset;

	Radius = Tan( Spread / 2.0 * PI / 180.f );
	ZDelta = Radius - ( 2 * Radius * FRand() );
	YDelta = Radius - ( 2 * Radius * FRand() );

	GetAxes( Direction, X, Y, Z );

	Offset = ( ZDelta * Z ) + ( YDelta * Y );

	return vector( Direction ) + Offset;
}

state RandomWander
{
	function vector GetRandomMovePoint()
	{
		local float Dot;
		local vector TryPt, RandTryPoint;
		local vector TryDir;
		local int i;
		//TryDir = VRand();
		TryDir = CalcTurnDirection( Pawn.Rotation, 65.f );
		TryDir.Z = 0.f;
		TryDir = Normal(TryDir);
		TryPt = Pawn.Location + TryDir * RandomMoveDist;
		if( bDebugWander )
		{
			PauseAndShowMsg( "WAITING" );
			`log( "Initial TryDir:"$TryDir$" TryPt: "$TryPt );
			DrawDebugSphere( TryPt, 32, 8, 0, 255, 0, TRUE );
		}
		for( i = 0; i < 15; i++ )
		{
			if( bDebugWander )
			{
				PauseAndShowMsg( "WAITING : "$i );
			}
			TryDir = CalcTurnDirection( Pawn.Rotation, RandRange(60,120) ); //VRand();
			TryDir.Z = 0.f;
			TryDir = Normal(TryDir);
			RandTryPoint = Pawn.Location + TryDir * RandomMoveDist;
			Dot = normal( RandTryPoint - Pawn.Location ) dot vector(Pawn.Rotation);
			if( Dot < DotCheck )
			{
				if( bDebugWander )
				{
					`log( "Fail i: "$i$" FAILED DOT CHECK (Dot:"$Dot$" versus DotCheck:"$DotCheck$")" );
					DrawDebugSphere( RandTryPoint, 24, 8, 255, 0, 0, TRUE );
				}
 				continue;
			}
			else if( bDebugWander )
			{
				`log( "Success i: "$i$" DOT: "$Dot$" TryDir: "$TryDir$" RandTryPoint: "$RandTryPoint );
				DrawDebugSphere( RandTryPoint, 24, 8, 0, 0, 255, TRUE );
				DrawDebugLine( Pawn.Location, RandTryPoint, 0, 0, 255, TRUE );
			}

			TryPt = Pawn.Location + TryDir * RandomMoveDist;
			if( PointReachable( TryPt ) )
			{
				//DrawDebugLine( Pawn.Location, Pawn.Location + TryDir * RandomMoveDist, 0, 255, 0, TRUE );
				return TryPt;
			}
		}
		return TryPt;
	}
Begin:
	GetRandomMovePoint();
	if( bDebugWander )
	{
		Sleep(0.f);
		PauseAndShowMsg( "WAITING" );
		Sleep(0.f);
		Goto( 'Begin' );
	}
	//SetMovePoint( GetRandomMovePoint(), none );
	MoveTo( GetRandomMovePoint(), none );
 	if( ShouldRunSomewhereElse() )
 	{
 		GotoState( 'RunSomewhere' );
 	}
// 	if( FRand() < 0.23f )
// 	{
// 		Sleep( RandRange( 0.1f, 0.5f ) );
// 	}
	Goto('Begin');
}

function bool NotifyHearNoise( float Loudness, Actor NoiseMaker, optional Name NoiseType )
{
	`AILog( "HearNoise: "$Loudness$" NoiseMaker: "$NoiseMaker$" Type: "$NoiseType, 'HeadlessWander' );
	return false;
}

state RunSomewhere
{
	function bool RunToDest()
	{
		local Pawn CurEnemy;
		local float CurDistSq, BestDistSq;
		local Pawn BestEnemy;
		local bool bRunToPlayer;

		BestDistSq = MAXINT;
		foreach WorldInfo.AllPawns( class'Pawn', CurEnemy )
		{
			CurDistSq = VSizeSq( CurEnemy.Location - Pawn.Location );
			if( BestEnemy == none || CanSee(CurEnemy) ) 
			{
				if( CurDistSq < BestDistSq )
				{
					BestEnemy = CurEnemy;
					BestDistSq = CurDistSq;
				}
			}
		}

		bRunToPlayer = FRand() < 0.55f;

		BestDistSq = MAXINT;
		foreach WorldInfo.AllPawns( class'Pawn', CurEnemy )
		{
			CurDistSq = VSizeSq( CurEnemy.Location - Pawn.Location );
			if( BestEnemy == none || 
				(bRunToPlayer == Pawn.IsHumanControlled() 
				&& CurDistSq < BestDistSq 
				&& (!bIsPlayer || CanSee(CurEnemy)) ) ) 
			{
				BestEnemy = CurEnemy;
				BestDistSq = CurDistSq;
			}
		}


 		if( BestEnemy != none )
 		{
			Dest = BestEnemy.Location;
			return true;
		}
		return false;
	}
Begin:
	if( RunToDest() )
	{
		MoveTo( Dest );
		Dest = vect(0,0,0);
		GotoState( 'RandomWander' );
	}
	else
	{
		AbortCommand( self );
	}
}

DefaultProperties
{
	bIgnoreNotifies=true
	bIgnoreStepAside=true
	RandomMoveDist=232.f
	DotCheck=0.86f
	bDebugWander=false
}


