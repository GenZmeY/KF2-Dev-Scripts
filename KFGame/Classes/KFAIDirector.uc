//=============================================================================
// KFAIDirector
//=============================================================================
// Oversees AI responses to game events
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//=============================================================================
class KFAIDirector extends Object within KFGameInfo
	config(Game)
	native(AI);

/** List of current living Zeds, can be used by Zeds to access other Zeds without iterating through
	all pawns, etc. */
var array <KFAIController>	AIList;
/** Forces clots to initially sprint to perform their first grab - code in KFAIController_ZedClot must
	be uncommented out (ShouldSprint()). */
var config bool				bAISprintToGrabVictim;
/** Global status of NPC debug text rendering - can be used to make sure all newly spawned NPCs begin showing their
	debug text as soon as they possess their pawns */
var config bool				bShowAINames;
/** Forces newly possessing KFAIControllers into debug mode when true */
var config bool				bDebugAllAI;
/** When true, will receive notification when a player is grabbed, allowing nearby Zeds to then target the grabbed player */
var bool					bUseGrabAlerts;
/** Max distance from grabbed player at which to alert Zeds */
var float					GrabAlertMaxZedDistance;
/** Turns on forced frustation mode */
var bool 					bForceFrustration;

/** List of all active bosses. */
var array<KFPawn_Monster> ActiveBossList;

/** A bi-direction graph representation of the connections between doors for long range "Macro" pathing decisions*/
//var KFDoorGraph             DoorGraph;

var vector                  CurrentLocationSortingDoorsFor;

////
///
// Ai Debug Helpers
///
////
var private Font	        AiDebugScreenLargeFont;
var config string           AiDebugScreenLargeFontName;

var private Texture2D	    DebugIsSprintingIcon;
var config string           DebugIsSprintingIconName;

var private Texture2D	    DebugIsWalkingIcon;
var config string           DebugIsWalkingIconName;

var config bool				bLoadDebugPackageResourcesAtStart;

var bool bShowVisualStuckZedDebugInfo;
var bool bShowMovePointsDebugInfo;
var bool bShowHighDetailCombatMovementDebugInfo;

var bool bShowCollisionRadiusForReducedZedOnZedPinchPointCollisionState;

var bool bShowLeapDownDebugArtifacts;
var bool bShowDoorNavigationDebugArtifacts;
var bool bShowDestructibleNavigationDebugArtifacts;



/** Struct that info about each squad member */
struct native ActiveAIInfo
{
	var	Controller	Member;
};
/** Array of all squad members */
var array<ActiveAIInfo>	ActiveZeds;

native function RebuildAIList();
native function LoadAiDebugResources();

/**
 * Initialize
 *
 */
function Initialize()
{
	if( bLoadDebugPackageResourcesAtStart )
	{
		LoadAiDebugResources();
	}

	//SetupDoorGraph();

	bShowVisualStuckZedDebugInfo = class'KFAiController'.default.bConfigShowVisualStuckZedDebugInfo;
	bShowMovePointsDebugInfo = class'KFAiController'.default.bConfigShowMovePointsDebugInfo;
	bShowHighDetailCombatMovementDebugInfo = class'KFAiController'.default.bConfigShowHighDetailCombatMovementDebugInfo;

	bShowCollisionRadiusForReducedZedOnZedPinchPointCollisionState = class'KFAiController'.default.bConfigShowCollisionRadiusForReducedZedOnZedPinchPointCollisionState;

	bShowLeapDownDebugArtifacts = class'KFAiController'.default.bConfigShowLeapDownDebugArtifacts;
	bShowDoorNavigationDebugArtifacts = class'KFAiController'.default.bConfigShowDoorNavigationDebugArtifacts;
	bShowDestructibleNavigationDebugArtifacts = class'KFAiController'.default.bConfigShowDestructibleNavigationDebugArtifacts;
}


/** Toggles debug-mode on/off for all existing Zeds */
function SetAIDebug( bool bOn )
{
	local int i;

	bDebugAllAI = bOn;

	for( i = 0; i < AIList.Length; i++ )
	{
		if( AIList[i].bForceDebugCommand )
		{
			AIList[i].bForceDebugCommand = bOn;
		}

		AIList[i].Pawn.ZeroMovementVariables();
		AIList[i].AbortMovementCommands();
		AIList[i].AbortMovementPlugIns();

		if( !bOn && AIList[i].bHasDebugCommand )
		{
			AIList[i].AbortCommand( None, class'AICommand_Debug' );
			AIList[i].GotoState( 'Action_Idle', 'Begin' );
		}

		if( bOn )
		{
			AIList[i].BeginDebugCommand();
		}
	}
}

/**
 * Returns the engine's default large font
 */
final function Font GetAiDebugScreenLargeFont()
{
	if( AiDebugScreenLargeFont == none )
	{
		LoadAiDebugResources();
	}

	return AiDebugScreenLargeFont;
}

/**
 * GetDebugIsSprintingIcon
 */
final function Texture2D GetDebugIsSprintingIcon()
{
	if( DebugIsSprintingIcon == none )
	{
		LoadAiDebugResources();
	}

	return DebugIsSprintingIcon;
}

/**
 * GetDebugIsWalkingIcon
 */
final function Texture2D GetDebugIsWalkingIcon()
{
	if( DebugIsWalkingIcon == none )
	{
		LoadAiDebugResources();
	}

	return DebugIsWalkingIcon;
}


/** Notification that the calling KFAIController has just possessed a new pawn */
function NotifyNewPossess( KFAIController KFAIC )
{
	`AILog_Ext( GetFuncName()$" registering new Possession by "$KFAIC, 'AIDirector', KFAIC );
	RegisterAIMember( KFAIC );
	KFAIC.bForceDebugCommand = bDebugAllAI;

}

final function RegisterAIMember( Controller NewMember )
{
	local int Idx;
	local KFAIController KFAIC;

	if (NewMember != None)
	{
		if (ActiveZeds.Find('Member', NewMember) != INDEX_NONE)
		{
		}
		else
		{
			// make sure they're not already a member
			UnRegisterAIMember( NewMember );

			Idx = ActiveZeds.Length;
			ActiveZeds.Length = Idx + 1;
			ActiveZeds[Idx].Member = NewMember;
			KFAIC = KFAIController(NewMember);
			// if it's an AI
			if( KFAIC != None )
			{
				`AILog_Ext( GetFuncName()$" Adding "$KFAIC$" to AIList", 'AIDirector', KFAIC );
				AIList.AddItem(KFAIC);
			}

			if (NewMember.Pawn != none && KFPawn_Monster(NewMember.Pawn) != none && KFPawn_Monster(NewMember.Pawn).IsABoss())
			{
				ActiveBossList.AddItem(KFPawn_Monster(NewMember.Pawn));
			}
		}
	}
}

/** Remove squad member from this squad and clean up */
final function UnRegisterAIMember( Controller OldMember )
{
	local KFAIController	KFAIC;
	//local GearPRI	PRI;
	local int		Idx;

	if (OldMember != None)
	{
		Idx = ActiveZeds.Find( 'Member', OldMember );
		if( Idx >= 0 )
		{
			KFAIC = KFAIController(OldMember);

			ActiveZeds.Remove( Idx, 1 );

			// if it's an AI
			if (KFAIC != None)
			{
				`AILog_Ext( GetFuncName()$" Removing "$KFAIC$" from AIList", 'AIDirector', KFAIC );
				AIList.RemoveItem(KFAIC);
			}

			if (OldMember.Pawn != none && KFPawn_Monster(OldMember.Pawn) != none && KFPawn_Monster(OldMember.Pawn).IsABoss())
			{
				ActiveBossList.RemoveItem(KFPawn_Monster(OldMember.Pawn));
			}
		}
	}
}

/** Can be used to let the KFAIDirector find a valid enemy for a KFAIController, optionally not taking
	the KFAIC's current enemy into consideration */
function Actor FindEnemyFor( KFAIController RequestingAI, optional bool bSkipCurrentEnemy=true )
{
	local Pawn P;
	local float DistToPlayer, DistToEnemy;

	if( RequestingAI.Pawn == none || !RequestingAI.Pawn.IsAliveAndWell() || RequestingAI.DoorEnemy != none )
	{
		return none;
	}

	if( RequestingAI.MyKFPawn.IsDoingSpecialMove(SM_GrappleAttack) )
	{
		return RequestingAI.Enemy;
	}

	if( RequestingAI.Enemy == none || !RequestingAI.Enemy.IsAliveAndWell() )
	{
		return RequestingAI.GetClosestEnemy();
	}

	for( P = WorldInfo.PawnList; P != none; P = P.NextPawn )
	{
		if( !RequestingAI.Pawn.IsSameTeam(P) && P.IsAliveAndWell() && P != RequestingAI.Enemy )
		{
			DistToPlayer = VSize(P.Location - RequestingAI.Pawn.Location);
			DistToEnemy = VSize(RequestingAI.Enemy.Location - RequestingAI.Pawn.Location);

			if( bSkipCurrentEnemy )
			{
				if( RequestingAI.ActorReachable(P) )
				{
					return P;
				}
			}
			else if( (DistToPlayer < DistToEnemy && FRand() < 0.9f) || (KFPawn(P).IsDoingSpecialMove(SM_GrappleVictim) && (DistToPlayer < 1200.f) && RequestingAI.CanSee(P) && FRand() < 0.85f)
				|| (RequestingAI.Pawn.Health < (0.33f * RequestingAI.Pawn.Default.Health) && FRand() < 0.65f) )
			{
				return P;
			}
		}
	}
	return none;
}

// Make nearby zeds more aggressive to the newly grabbed player
// TODO: Maybe only alert zeds with LOS to the victim if they seem too omniscient - for now it's just checking distance
function NotifyPawnGrabbed( KFPawn Victim, KFPawn Attacker )
{
	local KFPawn KFP;

	`AILog_Ext( GetFuncName()$" NotifyPawnGrabbed - victim, "$Victim$" attacker "$Attacker, 'AIDirector', Attacker.MyKFAIC );
	foreach WorldInfo.AllPawns( class'KFPawn', KFP )
	{
		if( (Attacker != none && KFP == Attacker) || KFP.IsSameTeam(Victim) || KFP.MyKFAIC == none || !KFP.IsAliveAndWell()
			|| Victim == none || !Victim.IsAliveAndWell() )
		{
			continue;
		}

		if( VSizeSq( KFP.Location - Victim.Location ) < GrabAlertMaxZedDistance * GrabAlertMaxZedDistance )
		{
			if( KFP.MyKFAIC.Enemy == none || (KFP.MyKFAIC.Enemy != none && KFP.MyKFAIC.Enemy != Victim) )
			{
				//TODO: Make this configurable
				if( KFP.MyKFAIC.Enemy == none || FRand() < 0.85f )
				{
					KFP.MyKFAIC.SetEnemy( Victim );
				}
			}
		}

		if( bAISprintToGrabVictim && KFP.MyKFAIC.Enemy == Victim && FRand() < 0.5f )
		{
			KFP.SetSprinting(true);
		}
	}
}

/**
 * FindDoorsWithInRange
 *
 */
function array<KFDoorActor> FindDoorsWithInRange( float RangeToBeLessThan, vector Loc2TestFrom )
{
	local KFDoorActor curDoorActor;
	local KFGameReplicationInfo kfGRI;
	local array<KFDoorActor> doorsInRange;
	local int doorIndex;
	local vector displacement2Door;
	local float distance2Door;

	kfGRI = KFGameReplicationInfo(WorldInfo.GRI);


	for( doorIndex = 0; doorIndex < kfGRI.DoorList.Length; doorIndex++ )
	{
		curDoorActor = kfGRI.DoorList[doorIndex];

		displacement2Door = curDoorActor.Location - Loc2TestFrom;

		distance2Door = VSize( displacement2Door );

		if( distance2Door <= RangeToBeLessThan )
		{
			doorsInRange.AddItem(curDoorActor);
		}
	}

	return doorsInRange;

}

delegate int ClosestDoorSort( KFDoorActor A, KFDoorActor B)
{
	local float distSqToDoorA;
	local float distSqToDoorB;

	distSqToDoorA = VSizeSq( CurrentLocationSortingDoorsFor - A.Location );
	distSqToDoorB = VSizeSq( CurrentLocationSortingDoorsFor - B.Location );

	return distSqToDoorA > distSqToDoorB ? -1 : 0;
}

/**
 * FindDoorsWithInRange
 *
 */
function array<KFDoorActor> FindClosedDoorsWithInRange( float RangeToBeLessThan, vector Loc2TestFrom )
{
	local KFDoorActor curDoorActor;
	//local KFGameReplicationInfo kfGRI;
	local array<KFDoorActor> doorsInRange;
	local array<KFDoorActor> closedDoorsInRange;
	local int doorIndex;
	//local vector displacement2Door;
	//local float distance2Door;

//	kfGRI = KFGameReplicationInfo(WorldInfo.GRI);


	doorsInRange = FindDoorsWithInRange( RangeToBeLessThan, Loc2TestFrom );


	for( doorIndex = 0; doorIndex < doorsInRange.Length; doorIndex++ )
	{
		curDoorActor = doorsInRange[doorIndex];

		if( !curDoorActor.IsCompletelyOpen() )
		{
			closedDoorsInRange.AddItem( curDoorActor );
		}
	}

	CurrentLocationSortingDoorsFor = Loc2TestFrom;

	closedDoorsInRange.Sort( ClosestDoorSort );

	return closedDoorsInRange;
}

function KFPawn_Monster GetActiveBoss()
{
	if (ActiveBossList.length > 0)
	{
		return ActiveBossList[0];
	}

	return none;
}

DefaultProperties
{
	GrabAlertMaxZedDistance=2700.f
	bForceFrustration = false;
}
