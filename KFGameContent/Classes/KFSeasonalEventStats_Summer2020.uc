//=============================================================================
// KFSeasonalEventStats_Summer2020
//=============================================================================
// Tracks event-specific challenges/accomplishments for Summer 2020
//=============================================================================
// Killing Floor 2
// Copyright (C) 2020 Tripwire Interactive LLC
//=============================================================================
class KFSeasonalEventStats_Summer2020 extends KFSeasonalEventStats;

var transient private const int BossDeathsRequired, DoshEarnRequired, EndlessWaveRequired, SummerEventIndex;

private event Initialize(string MapName)
{
	local string CapsMapName;
	CapsMapName = Caps(MapName);

	bObjectiveIsValidForMap[0] = 1; // Kill 15 Bosses on any map or mode
	bObjectiveIsValidForMap[1] = 0; // Complete the weekly on Desolation
	bObjectiveIsValidForMap[2] = 0; // Activate the power generator on Desolation
	bObjectiveIsValidForMap[3] = 0; // Earn 75,000 Dosh through kills, rewards and healing on Desolation
	bObjectiveIsValidForMap[4] = 0; // Complete wave 15 on Endless Hard or higher difficulty on Desolation
	
	if (CapsMapName == "KF-DESOLATION")
	{
		bObjectiveIsValidForMap[1] = 1;
		bObjectiveIsValidForMap[2] = 1;
		bObjectiveIsValidForMap[3] = 1;
		bObjectiveIsValidForMap[4] = 1;
	}

	SetSeasonalEventStatsMax(BossDeathsRequired, 0, 0, DoshEarnRequired, 0);
}

private event GrantEventItems()
{
	if (Outer.IsEventObjectiveComplete(0) &&
		Outer.IsEventObjectiveComplete(1) &&
		Outer.IsEventObjectiveComplete(2) &&
		Outer.IsEventObjectiveComplete(3) &&
		Outer.IsEventObjectiveComplete(4))
	{
		GrantEventItem(8292); // Space Pirate Monkey backpack
	}
}

simulated event OnGameWon(class<GameInfo> GameClass, int Difficulty, int GameLength, bool bCoOp)
{
	local int ObjIdx;

	// Desolation weekly survival
	ObjIdx = 1;
	if (bObjectiveIsValidForMap[ObjIdx] != 0)
	{
		if (GameClass == class'KFGameInfo_WeeklySurvival')
		{
			FinishedObjective(SummerEventIndex, ObjIdx);
		}
	}
}

simulated event OnGameEnd(class<GameInfo> GameClass)
{
	local int ObjIdx;
	local int TotalDoshEarned;
	
	// Desolation earn 75,000 dosh
	ObjIdx = 3;
	if (bObjectiveIsValidForMap[ObjIdx] != 0)
	{
		TotalDoshEarned = Outer.MyKFPC.MatchStats.TotalDoshEarned + Outer.MyKFPC.MatchStats.GetDoshEarnedInWave();
		if(TotalDoshEarned > 0)
		{
			IncrementSeasonalEventStat(ObjIdx, TotalDoshEarned);
			if (Outer.GetSeasonalEventStatValue(ObjIdx) >= DoshEarnRequired)
			{
				FinishedObjective(SummerEventIndex, ObjIdx);
			}
		}
	}
}

simulated function OnBossDied()
{
	local int ObjIdx;
	
	// Kill 15 bosses 
	ObjIdx = 0;
	if (bObjectiveIsValidForMap[ObjIdx] != 0)
	{
		IncrementSeasonalEventStat(ObjIdx, 1);
		if (Outer.GetSeasonalEventStatValue(ObjIdx) >= BossDeathsRequired)
		{
			FinishedObjective(SummerEventIndex, ObjIdx);
		}
	}
}

simulated event OnWaveCompleted(class<GameInfo> GameClass, int Difficulty, int WaveNum)
{
	local int ObjIdx;

	// Desolation endless 15 hard or higher
	ObjIdx = 4;
	if (bObjectiveIsValidForMap[ObjIdx] != 0)
	{
		if (WaveNum >= EndlessWaveRequired && GameClass == class'KFGameInfo_Endless' && Difficulty >= `DIFFICULTY_HARD)
		{
			FinishedObjective(SummerEventIndex, ObjIdx);
		}
	}
}

//simulated function OnTriggerUsed(class<Trigger_PawnsOnly> TriggerClass)
//{
//	local int ObjIdx;
//
//	// Desolation activate generator
//	ObjIdx = 2;
//	if (bObjectiveIsValidForMap[ObjIdx] != 0)
//	{
//		if (TriggerClass == class'KFTrigger_MinigameGenerator')
//		{
//			FinishedObjective(SummerEventIndex, ObjIdx);
//		}
//	}
//}

simulated function OnTryCompleteObjective(int ObjectiveIndex, int EventIndex)
{
	local int ObjIdx;

	// Desolation activate generator
	ObjIdx = 2;
	if (bObjectiveIsValidForMap[ObjIdx] != 0 && ObjectiveIndex == ObjIdx && EventIndex == SummerEventIndex)
	{
		FinishedObjective(EventIndex, ObjectiveIndex);
	}
}

defaultproperties
{
	BossDeathsRequired=15
	DoshEarnRequired=75000
	EndlessWaveRequired=15
	SummerEventIndex=SEI_Summer
}