//=============================================================================
// KFDoorMarker
//=============================================================================
// Base KF2 NavigationPoint used to mark door locations
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//=============================================================================
class KFDoorMarker extends DoorMarker
	native(Waypoint)
	hidecategories(DoorMarker);

var(KF2) KFDoorActor	MyKFDoor;

/** Optionally override the distance at which my door will be considered reached by NPCs */
var(KF2) float			AdjustedReachThreshold;

/** The computed cost when this door is welded */
var transient int 		ExtraCostWhenWelded;

cpptext
{
	virtual UClass* GetReachSpecClass( ANavigationPoint* Nav, UClass* DefaultReachSpecClass );

	// Overriding because DoorMarker returns MyKFDoor which is an InterpActor
	virtual AActor* AssociatedLevelGeometry();
	virtual UBOOL HasAssociatedLevelGeometry(AActor *Other);

#if WITH_EDITOR
	virtual UBOOL IsNecessaryForPath()
	{
		return true;
	}
	virtual UBOOL CanConnectTo(ANavigationPoint* Nav, UBOOL bCheckDistance);
#endif
	virtual void PrePath();
	virtual void PostPath();
	virtual void FindBase();
#if WITH_EDITOR
	virtual void CheckForErrors();
#endif
}

event bool SuggestMovePreparation( Pawn Other )
{
	local KFPawn_Monster KFPM;
	local int count;

	`AILog_Ext( GetFuncName()$"() "$self$" called for "$Other$" Dist: "$VSize(Location - Other.Location), 'Doors', KFPawn(Other).MyKFAIC );

	if( MyKFDoor != none && !MyKFDoor.IsCompletelyOpen() && MyKFDoor.WeldIntegrity > 0 )
	{
		// @Todo We might want to make this check from the position of the marker without the visible check
		foreach VisibleCollidingActors( class'KFPawn_Monster', KFPM, 220.f, Other.Location,,, true  )
		{
			// Stop trying to attack the door if another zed's attacking it, as this event call was probably from adjust around code caused by bumping into the door
			if( KFPM != Other && KFPM.IsAliveAndWell() && VSizeSq2D(KFPM.Location - Location) < VSizeSq2D(Other.Location - Location) &&
				KFPM.MyKFAIC.DoorEnemy != none && KFPM.MyKFAIC.DoorEnemy == MyKFDoor )
			{
				Count++;
			}
		}

		// Only allow up to 5 attackers
		if( Count > 5 )
		{
			`AILog_Ext( GetFuncName()$"() "$self$" - telling "$Other$" to wait for "$MyKFDoor$" to open", 'Doors', KFPawn(Other).MyKFAIC );
			Other.ZeroMovementVariables();
			//DrawDebugSphere( Other.Location, 32, 8, 255, 0, 0, true );
			KFPawn_Monster(Other).MyKFAIC.WaitForDoor( MyKFDoor );
			return true;
		}
	}

	return false;
}

function MoverOpened()
{
	bBlocked = (!bInitiallyClosed && bBlockedWhenClosed);
	bDoorOpen = bInitiallyClosed;
	WorldInfo.Game.NotifyNavigationChanged(self);
}

function MoverClosed()
{
	bBlocked = (bInitiallyClosed && bBlockedWhenClosed);
	bDoorOpen = !bInitiallyClosed;
	WorldInfo.Game.NotifyNavigationChanged(self);
}

/** Updates the pathing cost based on weld integrity, number of attackers and number queued */
function UpdatePathingCost( int AttackerCount, int QueuedCount )
{
	local float IntegrityPct;

	if( MyKFDoor.WeldIntegrity > 0 )
	{
		IntegrityPct = float(MyKFDoor.WeldIntegrity) / float(MyKFDoor.MaxWeldIntegrity);

		// If there are simply too many AI waiting on this door, and it's heavily welded, just skip it
		if( IntegrityPct > 0.75f && AttackerCount + QueuedCount > 10 )
		{
			ExtraCostWhenWelded = 100000;
			return;
		}

		// Initialize at 1000
		ExtraCostWhenWelded = 1000;

		// Add cost based on the strength of the weld (10-1000)
		ExtraCostWhenWelded += int( IntegrityPct * 100.f ) * 10;

		// Add cost based on the number of attackers (0-500)
		ExtraCostWhenWelded += Min( AttackerCount * 100, 500 );

		// Add cost based on the number of queued AI (0-1000)
		ExtraCostWhenWelded += Min( QueuedCount * 100, 1000 );
	}
	else
	{
		// Reset to base cost
		ExtraCostWhenWelded = 1000;
	}

	//`log("updating door pathing cost:"@extracostwhenwelded);
}

function bool ProceedWithMove(Pawn Other)
{
	local KFAIController KFAIC;

`if(`__TW_PATHFINDING_)
		if( KFPawn(Other) != none && !KFPawn(Other).IsHumanControlled() )
		{
			`AILog_Ext( GetFuncName()$" "$self$" for "$Other, 'Doors',  KFPawn(Other).MyKFAIC );
		}
`endif

	KFAIC = KFAIController( Other.Controller );

	if( KFAIC != none && KFAIC.PendingDoor != none && (bWaitUntilCompletelyOpened && KFAIC.PendingDoor.IsCompletelyOpen()) ||
        (!bWaitUntilCompletelyOpened && (KFAIC.PendingDoor.bIsDoorOpen || KFAIC.PendingDoor.bIsDestroyed)) )
	{
		return true;
	}

	if( MyKFDoor != none && (bWaitUntilCompletelyOpened && MyKFDoor.IsCompletelyOpen()) ||
        (!bWaitUntilCompletelyOpened && (MyKFDoor.bIsDoorOpen || MyKFDoor.bIsDestroyed)) )
	{
		return true;
	}

	if( Other.Controller != none && KFAIController( Other.Controller ) != none &&
        bWaitUntilCompletelyOpened && MyKFDoor != none )
	{
		KFAIController( Other.Controller ).WaitForDoor( MyKFDoor );
	}

	return false;
}

event Actor SpecialHandling( Pawn Other )
{
	`AILog_Ext( GetFuncName()$"() "$self$" SpecialHandling event called for "$Other, 'Doors', KFPawn(Other).MyKFAIC );
	if ( MyKFDoor == None || MyKFDoor.IsCompletelyOpen() /*|| VSize( Location - Other.Location ) > 200.f*/ )
	{
		return self;
	}

	if( KFPawn(Other) != none && !KFPawn(Other).IsHumanControlled() )
	{
		`AILog_Ext( GetFuncName()$" "$self$" calling for "$Other, 'Doors',  KFPawn(Other).MyKFAIC );
	}

	return self; // Added 1.24.14

// Disabled 1.24.14, replaced with MoveToGoal command door handling (see ReachedIntermediateGoal)
// Door is welded shut
// 	if( MyKFDoor.WeldIntegrity > 0 )
// 	{
// 		KFAIController( Other.Controller ).WaitForDoor( MyKFDoor );
// 		KFAIController( Other.Controller ).NotifyAttackDoor( MyKFDoor );
// 		return self;
// 	}
// 	else
// 	{
// 		KFAIController( Other.Controller ).WaitForDoor( MyKFDoor );
// 		MyKFDoor.UseDoor( Other );
// 		return self;
// 	}
}


DefaultProperties
{
	AdjustedReachThreshold=72.f
	bBuildLongPaths=false
}