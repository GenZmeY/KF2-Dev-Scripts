//=============================================================================
// AIPluginLeap
//=============================================================================
//
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//=============================================================================
class AIPluginLeap extends AITickablePlugin within BaseAIController
	native(Plugin)
	dependson(NavigationPath)
	abstract
	config(AI);


//var KFJumpDownNavPoint TheJumpDownNavPointPathObject;

//var Actor BaseForLeaping;

//var KFJumpDownNavPoint TheJumpDownNavPointPathObject;
//var int LandSpotIndex;

var Actor BaseForLanding;
//var KFJumpDownLandNavPoint LandNavPoint;

/** Start and End for the leap */
var Vector LeapDirection;
var transient Vector LocationAtStartOfLeap;
var transient Vector ClosestLocOnEdge;

var transient Vector ExpectedLandingLoc;

var const public{protected} EActionPriority ActionPriority;

var const transient bool bObserverNotified;
var const transient bool bDontNotifyObserver;
var transient bool bDontRestartByKismet;


var float ConfigFactorToIncreaseCalcedLeapVolBy;
var float ConfigFactorToIncreasePlottedLeapVolBy;
var float ConfigFactorToReduceLeapProjectionSizeBy;

var float ConfigDistanceOutFromDropEdgeToCalcDropLoc;

//var transient float DropHeight;

var float PercentageOfLeapImmuneFromCollision;
var float ConfigPercentageOfLeapImmuneFromCollision;

var bool bCollisionOffPhase;

var float ConfigDesiredLeapSpeed;
var float ConfigMinSpeedAllowed;
var float ConfigMaxSpeedAllowed;
var float ConfigBaseLeapZ;
var float ConfigDesiredZPct;
var bool bConfigOnlyTraceUp;

struct native LeapRequest
{
	//var native MoveParameters MoveParams;
	var Actor TheJumpDownNavPointPathObject;
	var int LandSpotIndex;
	var float EdgesDropHeight;

	var EActionPriority Priority;
	var const object Observer;

	var int QueryID;

	structcpptext
	{
		FLeapRequest()
		{
			appMemzero(this, sizeof(FLeapRequest));
			Reset();
		}

		FLeapRequest(FLeapRequest* pOther)
		{
			if(pOther != NULL)
			{
				appMemCopy(*this, *pOther);
			}
			else
			{
				appMemzero(this, sizeof(FLeapRequest));
				Reset();
			}
		}

		FString GetDescription() const;	

		void Reset()
		{
			Priority = AP_Invalid;
			TheJumpDownNavPointPathObject = NULL;
			Observer = NULL;
			LandSpotIndex = -1;
		}
	}
};

var LeapRequest MyLeapRequest;

var bool bWantTotalMovementControl;

cpptext
{
	void ClearMoveInfo();
}


/** Simple constructor that pushes a new instance of the command for the AI */
function bool Leap( const out LeapRequest InLeapRequest ) // AIController AI, Actor InTheJumpDownNavPointPathObject, int InLandSpotIndex, float InDropHeight )
{
	//DropHeight = InDropHeight;
	//LandSpotIndex = InLandSpotIndex;
	//BaseForLeaping = InTheJumpDownNavPointPathObject;

	MyLeapRequest = InLeapRequest;

	ScriptCommonMovePreparation( AP_Logic );

	GotoState( 'Command_SpecialMove' );

	return true;

}

/** Build debug string */
event String GetDumpString()
{
	return "LeapDirection:"@LeapDirection;
}

//function Pushed()
event bool ScriptCommonMovePreparation(EActionPriority Priority)
{
	bCollisionOffPhase = false;

	//Super.Pushed();

	//GotoState( 'Command_SpecialMove' );

	return true;
}

//function Popped()
event ScriptCleanUp()
{
	//Super.Popped();
	Outer.MyBaseAIPawn.bLeaping = false;
	//bReevaluatePath = TRUE;
	`AILog( GetFuncName() @ " Turning me on because ScriptCleanUp: " );
	TurnMeOn();
}

native function protected Success();
native function protected Failure();

native function bool AbortMove(bool bNewRequest);

state Succeeding `DEBUGSTATE
{
Begin:
	`AILog("Leaping - END:"@GetStateName(), 'Leap');
	Success();
}

state Failing `DEBUGSTATE
{
Begin:
	`AILog("Leaping - END:"@GetStateName(), 'Leap');
	Failure();
}

/* this state does nothing. It's here to leave other states when move is aborted,
 * and to indicate that it happened */
state Aborting `DEBUGSTATE
{
Begin:
	`AILog("Leaping - Aborted", 'Leap');
	//AbortMove(false);   
	StopMovement();
}

/* this state does nothing. It's here to leave other states when move is aborted,
* and to indicate that it happened */
state Idling `DEBUGSTATE
{
Begin:
	`AILog("Leaping - Idling so doing nothing", 'Leap');
	//StopMovement();
}


function TestForTimeToTurnCollisionBackOn()
{
	local float timeDelta;

	if( bCollisionOffPhase )
	{
		if( HasPercentOfZDiffBeenCovered() )
		{
			`AILog( GetFuncName() @ " Turning me on because HasPercentOfZDiffBeenCovered: " );
			TurnMeOn();
		}
		else
		{
			timeDelta = WorldInfo.TimeSeconds - Outer.MyBaseAIPawn.TimeStartedLeap;

			if( timeDelta > Outer.MyBaseAIPawn.TimeImmuneWhileLeaping )
			{
				`AILog( GetFuncName() @ " Turning me on because of time in leap of: " @ timeDelta );

				TurnMeOn();
			}
		}

	}
}

function bool HasPercentOfZDiffBeenCovered();


function TurnMeOn()
{
	Outer.MyBaseAIPawn.SetCollision( true, true );

	Outer.MyBaseAIPawn.bCollideWorld = true;

	Outer.MyBaseAIPawn.SetPushesRigidBodies(true);

	bCollisionOffPhase = false;
}

function vector GetJumpVelForDropEdge( out float TimeToReachLandLoc );

function vector GetJumpVelForUsingJumpDownNavPointPathObject( out float TimeToReachLandLoc );


state Command_SpecialMove
{
	function BeginState( Name PreviousStateName )
	{
		Super.BeginState( PreviousStateName );

		if( MyLeapRequest.TheJumpDownNavPointPathObject != none )
		{
			SetDesiredDirectionForJumpDoenNavPointEdge();
		}
		else
		{
			SetDesiredDirectionForDropEdge();
		}

		bWantTotalMovementControl = true;
	}

	function Bool IfShowLeapDownDebugArtifacts()
	{
		return false;
	}

	function vector GetCurrentJumpEdgeDirectionOfLeap()
	{
		return Vector(MyLeapRequest.TheJumpDownNavPointPathObject.Rotation);
	}

	function float GetDistanceDownRangeToFocusForDropEdgeLeap()
	{
		return 500.0;
	}

	//function SetDesiredDirectionForDropEdge()
	//{
	//	local Vector newFocalPoint;
	//	local float edgesDropHeight;

	//	LeapDirection = MyKFNavigationHandle.GetCurrentJumpEdgeDirectionOfLeap( Outer, edgesDropHeight, ClosestLocOnEdge );

	//	Focus = none;

	//	newFocalPoint = Outer.Pawn.Location + LeapDirection * Outer.DistanceDownRangeToFocusForDropEdgeLeap;

	//	SetFocalPoint( newFocalPoint );

	//	if( Outer.bShowLeapDownDebugArtifacts )
	//	{
	//		DrawDebugStar( newFocalPoint, 30, 255, 165, 0, true);
	//	}

	//	SetDesiredRotation(rotator(LeapDirection));
	//}

	function SetDesiredDirectionForDropEdge()
	{
		local Vector newFocalPoint;
		//local float edgesDropHeight;

		LeapDirection = GetCurrentJumpEdgeDirectionOfLeap();

		Focus = none;

		newFocalPoint = Outer.Pawn.Location + LeapDirection * GetDistanceDownRangeToFocusForDropEdgeLeap();

		SetFocalPoint( newFocalPoint );

		if( IfShowLeapDownDebugArtifacts() ) // Outer.bShowLeapDownDebugArtifacts )
		{
			DrawDebugStar( newFocalPoint, 300, 255, 165, 0, true);
		}

		SetDesiredRotation(rotator(LeapDirection));
	}

	//function SetDesiredDirectionForJumpDoenNavPointEdge()
	//{
	//	local Vector newFocalPoint;

	//	LeapDirection = BaseForLanding.Location - Outer.Pawn.Location;

	//	Focus = none;

	//	newFocalPoint = BaseForLanding.Location;// Outer.Pawn.Location + LeapDirection * Outer.DistanceDownRangeToFocusForDropEdgeLeap;

	//	SetFocalPoint( newFocalPoint );

	//	if( Outer.bShowLeapDownDebugArtifacts )
	//	{
	//		DrawDebugStar( newFocalPoint, 30, 255, 165, 0, true);
	//	}

	//	SetDesiredRotation(rotator(LeapDirection));
	//}

	function SetDesiredDirectionForJumpDoenNavPointEdge()
	{
		local Vector newFocalPoint;

		if( BaseForLanding == none )
		{
			return;
		}

		LeapDirection = BaseForLanding.Location - Outer.Pawn.Location;

		Focus = none;

		newFocalPoint = BaseForLanding.Location;// Outer.Pawn.Location + LeapDirection * Outer.DistanceDownRangeToFocusForDropEdgeLeap;

		SetFocalPoint( newFocalPoint );

		if( IfShowLeapDownDebugArtifacts() )
		{
			DrawDebugStar( newFocalPoint, 300, 255, 165, 0, true);
		}

		SetDesiredRotation(rotator(LeapDirection));
	}

	function bool DoLeap()
	{
		return false;
	}

	function LeapLoopPreSleepDataUpdate()
	{
		//Outer.LeapBehavior.ProjMeshLocations.AddItem(MyKfPawn.Location);
	}

Begin:
	
	while( !Pawn.ReachedDesiredRotation() )
	{
		Sleep(0.03);
	}

	if( DoLeap() )
	{
		do
		{
			LeapLoopPreSleepDataUpdate();
			Sleep( 0.0f );
			TestForTimeToTurnCollisionBackOn();

		} until( Pawn.Physics != PHYS_Falling );

		`AILog( GetFuncName() @ " Pawn.Physics != PHYS_Falling, so landed" );

		// CGH this is where i am an trying to get the pawn told about the leap.
		Outer.MyBaseAIPawn.bLeaping = false;
		Outer.MyBaseAIPawn.SetCollision( true, true, true );

//		Status = 'Success';
		Focus = Enemy;
		//PopCommand( self );
		//Stop;

		NotifyLanded();
	}
	bWantTotalMovementControl = false;
	
	GotoState( 'Succeeding' );
}

function NotifyLanded();

defaultproperties
{
}