//=============================================================================
// KFSeasonalEventStats_Spring2019
//=============================================================================
// Tracks event-specific challenges/accomplishments for Spring 2019
//=============================================================================
// Killing Floor 2
// Copyright (C) 2018 Tripwire Interactive LLC
//=============================================================================
class KFSeasonalEventStats_Spring2019 extends KFSeasonalEventStats;

var transient private const int ZedKillsRequired, BossDeathsRequired, EndlessWaveRequired;
var transient private int ZedKillsCount;

private event Initialize(string MapName)
{
	local string CapsMapName;
	CapsMapName = Caps(MapName);

	bObjectiveIsValidForMap[0] = 1; // kill bosses (any map)
	bObjectiveIsValidForMap[1] = 0; // complete weekly event (Spillway)
	bObjectiveIsValidForMap[2] = 1; // kill zeds (as an individual) (any map)
	bObjectiveIsValidForMap[3] = 0; // complete waves on endless hard or higher (Spillway)
	bObjectiveIsValidForMap[4] = 0; // defeat any boss on Survival Hard or higher (Spillway)

	if (CapsMapName == "KF-SPILLWAY")
	{
		bObjectiveIsValidForMap[1] = 1;
		bObjectiveIsValidForMap[3] = 1;
		bObjectiveIsValidForMap[4] = 1;
	}

	SetSeasonalEventStatsMax(BossDeathsRequired, 0, ZedKillsRequired, 0, 0);
}

private event GrantEventItems()
{
	if (Outer.IsEventObjectiveComplete(0) &&
		Outer.IsEventObjectiveComplete(1) &&
		Outer.IsEventObjectiveComplete(2) &&
		Outer.IsEventObjectiveComplete(3) &&
		Outer.IsEventObjectiveComplete(4))
	{
		GrantEventItem(7155);
	}
}

simulated function OnZedKilled(class<KFPawn_Monster> MonsterClass, int Difficulty, class<DamageType> DT, bool bKiller)
{
	if (bKiller == false)
	{
		return;
	}

	if (bObjectiveIsValidForMap[2] != 0)
	{
		IncrementSeasonalEventStat(2, 1);
		if (Outer.GetSeasonalEventStatValue(2) >= ZedKillsRequired)
		{
			FinishedObjective(SEI_Spring, 2);
		}
	}
}

simulated event OnGameWon(class<GameInfo> GameClass, int Difficulty, int GameLength, bool bCoOp)
{
	if (bObjectiveIsValidForMap[4] != 0)
	{
		if (GameClass == class'KFGameInfo_Survival' && Difficulty >= `DIFFICULTY_HARD)
		{
			FinishedObjective(SEI_Spring, 4);
		}
	}

	if (bObjectiveIsValidForMap[1] != 0)
	{
		if (GameClass == class'KFGameInfo_WeeklySurvival')
		{
			FinishedObjective(SEI_Spring, 1);
		}
	}
}

simulated function OnBossDied()
{
	if (bObjectiveIsValidForMap[0] != 0)
	{
		IncrementSeasonalEventStat(0, 1);
		if (Outer.GetSeasonalEventStatValue(0) >= BossDeathsRequired)
		{
			FinishedObjective(SEI_Spring, 0);
		}
	}
}

simulated event OnWaveCompleted(class<GameInfo> GameClass, int Difficulty, int WaveNum)
{
	if (bObjectiveIsValidForMap[3] != 0)
	{
		if (WaveNum >= EndlessWaveRequired && GameClass == class'KFGameInfo_Endless' && Difficulty >= `DIFFICULTY_HARD)
		{
			FinishedObjective(SEI_Spring, 3);
		}
	}
}
defaultproperties
{
	ZedKillsRequired=1500
	BossDeathsRequired=15
	EndlessWaveRequired=15
}
