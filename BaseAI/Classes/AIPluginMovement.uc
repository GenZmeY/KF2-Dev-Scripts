//=============================================================================
// AIPluginMovement
//=============================================================================
// A proxy/parent class for all specific movement implementations
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//=============================================================================
class AIPluginMovement extends AITickablePlugin within BaseAIController
	native(Plugin)
	dependson(NavigationPath)
	abstract;

struct native MoveParameters
{
	var EBaseMoveMood MoveMood;	
	var EBaseMoveType MoveType;
//	var EStridePose EndStridePose;
	var Actor RotateAtEndToMatch;
	/** When path is actually for following actor. */
	var Actor FollowingActor;

	/** Movement can be inaccurate. Useful when character ends up around < 2m away and it is not needed for it cover distance. */
	var bool bMovementCanBeInaccurate;
	/** Don't stop at the end of path. Useful for charge attacks etc. when character is not expected to stop at the end of path. Doesn't apply for entering cover. */
	var bool bMoveThroughLastPoint;	
	/** Indicates whether movement needs to start/end with shooting animation. */
	var bool bStartPathFollowingShooting;
	var bool bEndPathFollowingShooting;
	/** makes sure AI will do any move even if destination is close enough */
	var bool bForceAnyMove;
	var bool bAllowedToFire;

	structcpptext
	{
	FMoveParameters()
	{
		Reset();
	}

	void Reset()
	{
		appMemzero(this, sizeof(FMoveParameters));
		// copied from structdefaultproperties
		MoveMood = BMM_Fast;
		MoveType = BMT_Normal;
		bStartPathFollowingShooting = TRUE;
		bEndPathFollowingShooting = FALSE;
	}
	}

	structdefaultproperties
	{
//		BodyStance=NBS_Stand
		MoveMood=BMM_Fast
		MoveType=BMT_Normal
		bStartPathFollowingShooting=true
	}
};

enum EMoveRequestDestinationType
{
	MRDT_Invalid,
	MRDT_Vector,
	MRDT_Actor,
};

struct native MoveRequestDestination
{
	var vector VectorDest;
	var Actor ActorDest;
	var EMoveRequestDestinationType Type; 

	structcpptext
	{
	FMoveRequestDestination()
	{
		appMemzero(this, sizeof(FMoveRequestDestination));
	}

	FMoveRequestDestination(const class FVector& vDestination)
	{
		VectorDest = vDestination;
		Type = MRDT_Vector;
	}

	FMoveRequestDestination(class AActor* Actor) : Type(MRDT_Invalid)
	{
		if(Actor != NULL)
		{
			ActorDest = Actor;
			Type = MRDT_Actor;
		}
	}

	void Reset()
	{
		Type = MRDT_Invalid;
	}
	
	void Set(const class FVector& vDestination)
	{
		VectorDest = vDestination;
		Type = MRDT_Vector;
	}

	void Set(class AActor* Actor)
	{
		if(Actor != NULL)
		{
			ActorDest = Actor;
			Type = MRDT_Actor;
		}
		else
		{
			Type = MRDT_Invalid;
		}
	}

	//void Set(struct FCoverInfo& inCoverInfo)
	//{
	//	if(inCoverInfo.IsSet() == TRUE)
	//	{
	//		CoverInfoDest = inCoverInfo;
	//		Type = MRDT_Cover;
	//	}
	//	else
	//	{
	//		Type = MRDT_Invalid;
	//	}
	//}

	UBOOL IsActor() const
	{
		return Type == MRDT_Actor;
	}

	UBOOL IsVector() const
	{
		return Type == MRDT_Vector;
	}

	//UBOOL IsCover() const
	//{
	//	return Type == MRDT_Cover;
	//}

	class AActor* GetAsActor()
	{
		return Type == MRDT_Actor ? ActorDest : NULL;
	}

	const class AActor* GetAsActor() const
	{
		return Type == MRDT_Actor ? ActorDest : NULL;
	}

	//struct FCoverInfo GetAsCoverInfo() const
	//{
	//	return Type == MRDT_Cover ? CoverInfoDest : FCoverInfo();
	//}

	FVector GetPosition() const
	{
		switch(Type)
		{
		case MRDT_Vector:
			return VectorDest;
			break;
		//case MRDT_Cover:
		//	return CoverInfoDest.Link ? CoverInfoDest.Link->GetSlotLocation(CoverInfoDest.SlotIdx) : FVector(0.f);
		//	break;
		case MRDT_Actor:
			return ActorDest ? ActorDest->Location : FVector(0.f);
			break;
		default: // MRDT_Invalid
			break;
		}
		return FVector(0.0f);
	}
	}
};

struct native MovementRequest
{
	var native MoveParameters MoveParams;
	var float AcceptableDistance;
	var vector DestOffset;
	var vector MidPointOffset;
	/** a struct type with union inside representing move destination. It seems 
	 *	ok to have a native only access to it - script will only be able to modify means
	 *  of execution, but not destination itself.
	 */
	var native MoveRequestDestination Destination;
	var native NavigationPath PreComputedPath;
	var EActionPriority Priority;
	var const object Observer;
	var bool bStickToNavmesh;
	var bool bStickToActionArea;
	var bool bDynamicDestOffset;	// not used at the moment. Added for consistence
	var bool bDynamicMidPoint;
	var bool bPostProcessPath;
	var int QueryID;

	structcpptext
	{
	FMovementRequest()
	{
		appMemzero(this, sizeof(FMovementRequest));
		Reset();
	}

	FMovementRequest(FMovementRequest* pOther)
	{
		if(pOther != NULL)
		{
			appMemCopy(*this, *pOther);
		}
		else
		{
			appMemzero(this, sizeof(FMovementRequest));
			Reset();
		}
	}

	FString GetDescription() const;	

	void Reset()
	{
		MoveParams.Reset();
		AcceptableDistance=0.0f;
		Destination.Reset();
		PreComputedPath = NULL;
		Priority = AP_Invalid;
		bStickToNavmesh = TRUE;
		bStickToActionArea = FALSE;
		bPostProcessPath = FALSE;
		Observer = NULL;
	}
	}
};

var MovementRequest MoveRequest;
var transient float GoalDistanceSq;

var const public{protected} EActionPriority ActionPriority;

var const public{private} EActionPriority MovementLock;

var const transient bool bObserverNotified;
var const transient bool bDontNotifyObserver;
var transient bool bDontRestartByKismet;

var float MinimumSuccessDistance;

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

	FVector GetDestination(struct FMovementRequest& Request) const
	{
		return Request.Destination.GetPosition();
	}
}

/** overrideable only in native code (no-exported as virtual) */
native function bool MoveToRequest(out MovementRequest Request);
native function bool MoveToPointRequest(vector InDestLocation, EActionPriority CommandPriority, optional object ActionObserver, optional bool bStopAtEnd=true, optional bool bStickToNavmesh = true, optional float AcceptableDistance, optional Actor RotateAtEndToMatch);
native function bool MoveToActorRequest(Actor inPawnGoal, EActionPriority CommandPriority, optional object ActionObserver, optional bool bInAllowedToFire=true, optional float AcceptableDistance, optional vector DestOffset, optional vector MidPointOffset, optional bool bDynamicMidPoint, optional bool bStopAtEnd=true, optional bool bStickToNavmesh=true);
native function bool FollowPlugInsPath(NavigationPath InPath, EActionPriority CommandPriority, optional object ActionObserver, optional bool bStopAtEnd=true, optional Actor RotateAtEndToMatch, optional Float AcceptableDistance);

native function bool AbortMove(bool bNewRequest);

/**
 * @param bNewRequest if set to false (default) then if there was a move 
 *		task paused while lock was being set, then this task will be resumed.
 *		If true, it will not. This param makes sense only for bLock == true
 */
native function SetMovementLock(bool bLock, optional EActionPriority Priority = AP_Logic, optional bool bNewRequest);

native function protected Success();
native function protected Failure();

native function bool RePath();

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
}

state Failing `DEBUGSTATE
{
Begin:
	`AILog("Moving - END:"@GetStateName(), 'Move');
	Failure();
}

/* this state does nothing. It's here to leave other states when move is aborted,
 * and to indicate that it happened */
state Aborting `DEBUGSTATE
{
Begin:
	`AILog("Moving - Aborted", 'Move');
	//AbortMove(false);   
	StopMovement();
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
	MinimumSuccessDistance=160.0f //90 units	
}
