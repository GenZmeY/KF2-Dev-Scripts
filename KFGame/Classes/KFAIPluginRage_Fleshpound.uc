//=============================================================================
// KFAIPluginRage_Fleshpound
//=============================================================================
// AICommand executing while Fleshpound is enraged
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//=============================================================================
class KFAIPluginRage_Fleshpound extends AITickablePlugin
	within KFAIController_ZedFleshpound
	native(AI)
	config(AI);

`include(KFGame\KFGameAnalytics.uci);

var vector	StartLocation;

/** Track damage taken over the past AccumulatedDOTDuration seconds */
var int				AccumulatedDOT;
/**	The time when we found an enemy */
var float			RageFrustrationStartTime;
/**	The max time we can stay in rage mode*/
var float	MaxEnemyNotVisibleRageTime;
/**	The base time to wait before becoming frustrated and raging anyways */
var float	RageFrustrationBaseTime;
/** The (randomized) final time to wait before becoming frustrated */
var float 	RageFrustrationTime;
/**	The amount of damage we need to accumulate before entering rage */
var float	RageDamageThreshold;

var bool bIsEnraged;

/** Ticked to determine when we should start and end rage mode */
event TickRage()
{
	if( bIsEnraged && !bEnemyIsVisible && `TimeSince(LastEnemySightedTime) > MaxEnemyNotVisibleRageTime )
	{
		EndRage();
	}
	else if( CanDoRage() )
	{
		AIActionStatus = "Enraged!";
		GotoState( 'Enraged' );
	}
}

function DoSpawnRage()
{
	AIActionStatus = "Enraged!";
	GotoState( 'Enraged' );
}

/** Checks if it's possible to enter rage */
function bool CanDoRage()
{
	if( bIsEnraged || !MyKFPawn.IsCombatCapable() )
	{
		return false;
	}

	// If it's been longer than RageFrustrationTime since we've had an enemy, rage anyways
	if( Enemy != none && RageFrustrationStartTime > 0 && `TimeSince(RageFrustrationStartTime) > RageFrustrationTime )
	{
		return true;
	}

	// If we've taken more than the RageDamageThreshold in damage, begin rage
	if( AccumulatedDOT >= RageDamageThreshold )
	{
		return true;
	}

	return false;
}

/** Begins the timer until the FleshPound can rage */
function StartRageTimer(optional bool bJustSawEnemy)
{
	// Already raging!
	if( bIsEnraged )
	{
		return;		
	}

	RageFrustrationStartTime = WorldInfo.TimeSeconds;
	SetRageTime();

	// If the FP hasn't seen its enemy for a long time, rage (almost) immediately
	if( bJustSawEnemy && `TimeSince(LastEnemySightedTime) > MaxEnemyNotVisibleRageTime )
	{
		RageFrustrationStartTime += RageFrustrationTime - 0.5f;
	}
}

/** Sets our rage timer (RageFrustrationBaseTime + RandRange(1,5)) */
function SetRageTime()
{
	RageFrustrationTime = RageFrustrationBaseTime + RandRange(1.f,5.f);
}

/** Leave Rage Mode */
function EndRage()
{
	// Any time we end call end rage, we are no longer frustrated
	if( bIsEnraged )
	{
		GotoState( InitialState );	
		StartRageTimer();
	}
}

/*********************************************************************************************
* Enraged state
********************************************************************************************* */

state Enraged
{
	function BeginState( name PreviousStateName )
	{
		bIsEnraged = true;
		MyKFPawn.SetEnraged( true );

		`AILog( GetStateName()$" "$GetFuncName()$"() Prev: "$PreviousStateName, 'Charging' );
		SetFocalPoint(vect(0,0,0));
		Focus = none;
		//bAdjustFromWalls = false;   // Experimenting **NOTE this prevented FP from jumping when raging - Matt
		AIZeroMovementVariables();

		/** Rotate to enemy - state code will resume execution after RotateToFocus is popped */
		PushState( 'RotateToFocus' );
		/** Finished rotating - see if I need to taunt first */

		if( !MyKFPawn.IsDoingSpecialMove() )
 		{
			// Start the rage-taunt command - no more state code will execute below until the taunt is finished
			DoRageTauntAt( KFPawn(Enemy) );
			// Finished taunting 
			LastTauntTime = WorldInfo.TimeSeconds;
		}
	}

	function EndState( name NextStateName )
	{	
		bIsEnraged = false;
		MyKFPawn.SetEnraged( false );
		
		AccumulatedDOT = 0;

		if( Enemy == none || VSize(Enemy.Location - Pawn.Location) > 1024.f || !CanSee(Enemy) )
		{
			SetEnemy(GetClosestEnemy());
		}
		AIActionStatus = "No longer engraged";
		EnableMeleeRangeEventProbing();

		MyKFPawn.bForceMaxAccel	= false;
		bPreciseDestination		= false;
		//bAdjustFromWalls		= true;
	}

	function ContinuedState()
	{
		AIActionStatus = "Enraged, and preparing to charge";
	}

Finished:
	UnlockPawnRotation();
	AIZeroMovementVariables();
	SetDestinationPosition( Pawn.Location );
	Pawn.ResetDesiredRotation();
	RotationRateMultiplier = 1.f;
	PushState( 'RotateToFocus' );
}

/*********************************************************************************************
* RotateToFocus state
********************************************************************************************* */

state RotateToFocus `DEBUGSTATE
{
Begin:
	AIActionStatus = "Rotating to focus";
	SetFocalPoint( vect(0,0,0) );
	Focus = Enemy;
	FinishRotation();
	PopState();
}

/*********************************************************************************************
* Debugging
********************************************************************************************* */


DefaultProperties
{
	// ---------------------------------------------
	// Settings
	RageFrustrationBaseTime=9
	RageDamageThreshold=276
	MaxEnemyNotVisibleRageTime=30
}
