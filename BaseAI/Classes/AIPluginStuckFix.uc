//=============================================================================
// AIPluginStuckFix
//=============================================================================
// A proxy/parent class for all specific Stuck implementations
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//=============================================================================
class AIPluginStuckFix extends AITickablePlugin within BaseAIController
	native(Plugin)
	dependson(NavigationPath, AIPluginMovement)
	abstract;

struct native FixStuckRequest
{
	var native MoveParameters MoveParams;
	var float AcceptableDistance;
	var vector DestOffset;
	//var vector MidPointOffset;
	/** a struct type with union inside representing move destination. It seems 
	 *	ok to have a native only access to it - script will only be able to modify means
	 *  of execution, but not destination itself.
	 */
	var native MoveRequestDestination Destination;
	//var native NavigationPath PreComputedPath;
	var EActionPriority Priority;
	var const object Observer;
	var bool bFinalApproach;
	var int QueryID;

	structcpptext
	{
	FFixStuckRequest()
	{
		appMemzero(this, sizeof(FFixStuckRequest));
		Reset();
	}

	FFixStuckRequest(FFixStuckRequest* pOther)
	{
		if(pOther != NULL)
		{
			appMemCopy(*this, *pOther);
		}
		else
		{
			appMemzero(this, sizeof(FFixStuckRequest));
			Reset();
		}
	}

	FString GetDescription() const;	

	void Reset()
	{
		MoveParams.Reset();
		AcceptableDistance=0.0f;
		Destination.Reset();
		Priority = AP_Invalid;
		bFinalApproach = FALSE;
		Observer = NULL;
	}
	}
};


var FixStuckRequest MoveRequest;
var const public{protected} EActionPriority ActionPriority;

var const public{private} EActionPriority MovementLock;

var const transient bool bObserverNotified;
var const transient bool bDontNotifyObserver;
var transient bool bDontRestartByKismet;

cpptext
{
	UBOOL IsMovementLocked(const EActionPriority Priority = AP_Logic) const // AP_Locic, i.e. AP_Invalid + 1. 
	{
		return MovementLock >= Priority;
	}

	EActionPriority GetMovementLock() const
	{
		return (EActionPriority)MovementLock;
	}

	UBOOL CanAcceptNewMoveRequest(EActionPriority NewRequestPriority) const
	{
		return NewRequestPriority >= ActionPriority;
	}

	FORCEINLINE EActionPriority GetActionPriority() const
	{
		return (EActionPriority)ActionPriority;
	}

	FVector GetDestination(struct FFixStuckRequest& Request) const
	{
		return Request.Destination.GetPosition();
	}
}

/** overrideable only in native code (no-exported as virtual) */
function bool StuckFixToPointRequest(vector InDestLocation, EActionPriority CommandPriority, optional object ActionObserver, optional bool bStopAtEnd=true, optional bool bStickToNavmesh = true, optional float AcceptableDistance, optional Actor RotateAtEndToMatch);
function bool StuckFixToActorRequest(Actor inPawnGoal, EActionPriority CommandPriority, optional object ActionObserver, optional bool bInAllowedToFire=true, optional float AcceptableDistance, optional vector DestOffset, optional vector MidPointOffset, optional bool bDynamicMidPoint, optional bool bStopAtEnd=true, optional bool bStickToNavmesh=true);

event bool AbortMove(bool bNewRequest);

/**
 * @param bNewRequest if set to false (default) then if there was a move 
 *		task paused while lock was being set, then this task will be resumed.
 *		If true, it will not. This param makes sense only for bLock == true
 */
function SetMovementLock(bool bLock, optional EActionPriority Priority = AP_Logic, optional bool bNewRequest);

function protected Success();
function protected Failure();


/** Script interface to get location of destination point from given MovementRequest. 
 *	no-exported to make inline. */
final native noexport function vector GetDestination(out MovementRequest Request) const;

final function EMoveRequestDestinationType GetDestinationType()
{
	return MoveRequest.Destination.Type;
}

function StopMovement()
{
	//@todo fill it!
}

/** Called from native code during latent movement when current move is considered unreachable */
function bool MoveUnreachable( Vector AttemptedDest, Actor AttemptedTarget )
{
	if( AttemptedTarget != none )
	{
		`AILog( GetFuncName()$" AttemptedTarget: "$AttemptedTarget, 'PathWarning' );
	}
		
	return false;
}

state Succeeding `DEBUGSTATE
{
Begin:
	`AILog("Moving - END:"@GetStateName(), 'Move');
	Success();

	GotoState( 'Idling' );
}

state Failing `DEBUGSTATE
{
Begin:
	`AILog("Moving - END:"@GetStateName(), 'Move');
	Failure();

	GotoState( 'Idling' );
}

/* this state does nothing. It's here to leave other states when move is aborted,
 * and to indicate that it happened */
state Aborting `DEBUGSTATE
{
Begin:
	`AILog("Moving - Aborted", 'Move');
	//AbortMove(false);   
	StopMovement();

	GotoState( 'Idling' );
}

/* this state does nothing. It's here to leave other states when move is aborted,
* and to indicate that it happened */
state Idling `DEBUGSTATE
{
Begin:
	`AILog("Idling", 'Move');
	StopMovement();
}

defaultproperties
{
	// mz> this change is a little bit hacky and will need further changes. AnimSys accepts path success if destination to cover < 150.0f;
	//MinimumSuccessDistance=8100.0f //90 units	
	//MinimumSuccessDistance=160.0f //90 units	
}
