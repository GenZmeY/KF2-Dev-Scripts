//=============================================================================
// KFSeasonalEventStats
//=============================================================================
// Tracks event-specific challenges/accomplishments
//=============================================================================
// Killing Floor 2
// Copyright (C) 2018 Tripwire Interactive LLC
//=============================================================================
class KFSeasonalEventStats extends Object
	within KFOnlineStatsWrite
	native
	abstract;

var protected int bObjectiveIsValidForMap[5];

/*****************************************************************************************************
 * @name Native
 ****************************************************************************************************/

// whether this seasonal stats object is the stats object that is being tracked right now
final native function bool IsValid();
final protected native function IncrementSeasonalEventStat(int StatIdx, int Inc);
final protected native function SetSeasonalEventStatsMax(int StatMax1, int StatMax2, int StatMax3, int StatMax4, int StatMax5);
final protected native function GrantEventItem(int ItemId);

/*****************************************************************************************************
 * @name Script
 ****************************************************************************************************/

private event Initialize(string MapName);
static private event bool AllowEventBossOverrideForMap(string MapName);
private event GrantEventItems();

final protected simulated function FinishedObjective(int EventIndex, int ObjectiveIndex)
{
	local KFPlayerController KFPC;
	local int year, month, dayofweek, day, hour, minute, second, msec;

	if (!IsValid())
	{
		return;
	}

	KFPC = Outer.MyKFPC;
	if (KFPC.WorldInfo.NetMode != NM_DedicatedServer && KFPC.IsLocalPlayerController() &&
		!KFPC.PlayerReplicationInfo.bOnlySpectator && !Outer.HasCheated() &&
		!Outer.IsEventObjectiveComplete(ObjectiveIndex))
	{
		GetSystemTime(year, month, dayofweek, day, hour, minute, second, msec);
		Outer.UpdateSpecialEvent(EventIndex, ObjectiveIndex, year, month);

		if (KFPC.MyGFxHUD != none && KFPC.MyGFxHUD.LevelUpNotificationWidget != none &&
			((class'KFGameEngine'.static.GetSeasonalEventID() % 10) == EventIndex))
		{
			KFPC.MyGFxHUD.LevelUpNotificationWidget.FinishedSpecialEvent(EventIndex, ObjectiveIndex);
		}
		if (KFPC.MyGFxManager != none && KFPC.MyGFxManager.StartMenu != none &&
			KFPC.MyGFxManager.StartMenu.MissionObjectiveContainer != none)
		{
			KFPC.MyGFxManager.StartMenu.MissionObjectiveContainer.Refresh();
		}
	}
}

simulated function OnMapObjectiveDeactivated(Actor ObjectiveInterfaceActor);
simulated function OnZedKilled(class<KFPawn_Monster> MonsterClass, int Difficulty, class<DamageType> DT);
simulated function OnZedKilledByHeadshot(class<KFPawn_Monster> MonsterClass, int Difficulty, class<DamageType> DT);
simulated function OnMapCollectibleFound(PlayerReplicationInfo FinderPRI, int CollectibleID);
simulated event OnGameWon(class<GameInfo> GameClass, int Difficulty, int GameLength, bool bCoOp);
simulated event OnGameEnd(class<GameInfo> GameClass);
simulated function OnBossDied();
simulated event OnWaveCompleted(class<GameInfo> GameClass, int Difficulty, int WaveNum);
simulated event OnTriggerUsed(class<Trigger_PawnsOnly> TriggerClass);
simulated event OnTryCompleteObjective(int ObjectiveIndex, int EventIndex);
simulated function OnHitTaken();
simulated function OnHitGiven(class<DamageType> DT);