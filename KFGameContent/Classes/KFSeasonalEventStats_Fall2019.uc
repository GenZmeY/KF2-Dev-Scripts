//=============================================================================
// KFSeasonalEventStats_Fall2019
//=============================================================================
// Tracks event-specific challenges/accomplishments for Fall 2019
//=============================================================================
// Killing Floor 2
// Copyright (C) 2019 Tripwire Interactive LLC
//=============================================================================
class KFSeasonalEventStats_Fall2019 extends KFSeasonalEventStats;

var transient private const int EndlessWaveRequired, ZedKillsRequired;

private event Initialize(string MapName)
{
	local string CapsMapName;
	CapsMapName = Caps(MapName);

	bObjectiveIsValidForMap[0] = 0; // Defeat any boss on Survival Hard or higher difficulty on Asylum
	bObjectiveIsValidForMap[1] = 0; // Complete wave 15 on Endless Hard or higher difficulty on Asylum
	bObjectiveIsValidForMap[2] = 0; // Complete the Weekly on Asylum
	bObjectiveIsValidForMap[3] = 0; // Kill 1500 Zeds on Asylum
	bObjectiveIsValidForMap[4] = 0; // Complete Nuked on Objective Hard or higher difficulty

	if (CapsMapName == "KF-ASHWOODASYLUM")
	{
		bObjectiveIsValidForMap[0] = 1;
		bObjectiveIsValidForMap[1] = 1;
		bObjectiveIsValidForMap[2] = 1;
		bObjectiveIsValidForMap[3] = 1;
	}
	else if (CapsMapName == "KF-NUKED")
	{
		bObjectiveIsValidForMap[4] = 1;
	}

	SetSeasonalEventStatsMax(0, 0, 0, ZedKillsRequired, 0);
}

private event GrantEventItems()
{
	if (Outer.IsEventObjectiveComplete(0) &&
		Outer.IsEventObjectiveComplete(1) &&
		Outer.IsEventObjectiveComplete(2) &&
		Outer.IsEventObjectiveComplete(3) &&
		Outer.IsEventObjectiveComplete(4))
	{
		GrantEventItem(7481);
	}
}

simulated event OnGameWon(class<GameInfo> GameClass, int Difficulty, int GameLength, bool bCoOp)
{
	// asylum survival hard or higher
	if (bObjectiveIsValidForMap[0] != 0)
	{
		if (GameClass == class'KFGameInfo_Survival' && Difficulty >= `DIFFICULTY_HARD)
		{
			FinishedObjective(SEI_Fall, 0);
		}
	}

	// asylum weekly
	if (bObjectiveIsValidForMap[2] != 0)
	{
		if (GameClass == class'KFGameInfo_WeeklySurvival')
		{
			FinishedObjective(SEI_Fall, 2);
		}
	}

	// nuked objective hard or higher
	if (bObjectiveIsValidForMap[4] != 0)
	{
		if (GameClass == class'KFGameInfo_Objective' && Difficulty >= `DIFFICULTY_HARD)
		{
			FinishedObjective(SEI_Fall, 4);
		}
	}
}

simulated function OnZedKilled(class<KFPawn_Monster> MonsterClass, int Difficulty, class<DamageType> DT)
{
	// kill 1500 zeds on asylum
	if (bObjectiveIsValidForMap[3] != 0)
	{
		IncrementSeasonalEventStat(3, 1);
		if (Outer.GetSeasonalEventStatValue(3) >= ZedKillsRequired)
		{
			FinishedObjective(SEI_Fall, 3);
		}
	}
}

simulated event OnWaveCompleted(class<GameInfo> GameClass, int Difficulty, int WaveNum)
{
	// asylum endless 15 hard or higher
	if (bObjectiveIsValidForMap[1] != 0)
	{
		if (WaveNum >= EndlessWaveRequired && GameClass == class'KFGameInfo_Endless' && Difficulty >= `DIFFICULTY_HARD)
		{
			FinishedObjective(SEI_Fall, 1);
		}
	}
}

defaultproperties
{
	EndlessWaveRequired=15
	ZedKillsRequired=1500
}