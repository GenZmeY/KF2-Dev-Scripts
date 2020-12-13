//=============================================================================
// AnimationProxy
//=============================================================================
//
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//=============================================================================

class BaseAISquad extends Info
	native;

/** Controller for leader of the squad */
var() editconst Controller Leader;
var() editconst Actor FormationCenter;

/** whether this squad has a human controlled player in it */
var bool bPlayerSquad;

var bool bIsMP;

var transient bool bSquadInCombat;

var transient float NextEnemySelectionTimestamp;
/** Call UpdateEnemySelection every X seconds*/
var float EnemySelectionInterval;

cpptext
{
	virtual void TickSpecial(FLOAT DeltaSeconds);
}

/** Called immediately after gameplay begins. */
event PostBeginPlay()
{
	super.PostBeginPlay();

	class'BaseAISubsystem'.static.RegisterSquad(self);

	bIsMP = WorldInfo.GRI.IsMultiplayerGame();
}

event Destroyed()
{
	class'BaseAISubsystem'.static.UnRegisterSquad(self);
	
	super.Destroyed();
}

/**
 * Called by BaseAISubsystem to update enemy info
 * @return true if given pawn was on squad's enemy list, false otherwise
 */
native function bool NotifyKilled(Controller Killer, Controller Killed, Pawn KilledPawn, class<DamageType> damageType);

/**
* Called by PluginSquad 
*/
final native function EnemyPerceivedBy(Controller Member, EWSPerceptionMode PerceptionType, Pawn Enemy);

native function UpdateLeader(Controller inLeader);

native function int GetSquadMemberCount() const;
native function bool GetSquadMembers(out array<BaseAIPawn> Members);
/** Returns FormationCenter when not in combat, and Leader pawn if in combat. 
 * @note could add a flag toggling this behavior. No need for it at the moment
 */
native final function BaseAIPawn GetSquadCenterPawn();

/** picks target/enemy for all squad members with BaseAIController.bSquadBasedEnemySelection == true 
 * @return TRUE if any work has been done, and there is a point in re-calling this in some time
 */
native function bool UpdateEnemySelection();

defaultproperties
{
	EnemySelectionInterval=0.4f
	bIsMP=false
}