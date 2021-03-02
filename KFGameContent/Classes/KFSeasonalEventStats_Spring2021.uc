//=============================================================================
// KFSeasonalEventStats_Spring2021
//=============================================================================
// Tracks event-specific challenges/accomplishments for Spring 2021
//=============================================================================
// Killing Floor 2
// Copyright (C) 2020 Tripwire Interactive LLC
//=============================================================================
class KFSeasonalEventStats_Spring2021 extends KFSeasonalEventStats;

var transient private const int BossKillsRequired, EDARKillsRequired, WavesWithoutDamageRequired, EndlessWaveRequired;
var transient bool bHitTakenThisWave;

private event Initialize(string MapName)
{
	local string CapsMapName;
	CapsMapName = Caps(MapName);

	bObjectiveIsValidForMap[0] = 1; // Kill 15 Bosses on any map or mode
	bObjectiveIsValidForMap[1] = 0; // Complete the Weekly on Dystopia 2029
	bObjectiveIsValidForMap[2] = 0; // Kill 100 E.D.A.R.s on Dystopia 2029
	bObjectiveIsValidForMap[3] = 0; // Complete a wave without taking any damage 10 times on Dystopia 2029
	bObjectiveIsValidForMap[4] = 0; // Complete wave 15 on Endless Hard or higher difficulty on Dystopia 2029

	if (CapsMapName == "KF-DYSTOPIA2029")
	{

		bObjectiveIsValidForMap[1] = 1;
		bObjectiveIsValidForMap[2] = 1;
		bObjectiveIsValidForMap[3] = 1;
		bObjectiveIsValidForMap[4] = 1;
	}

	SetSeasonalEventStatsMax(BossKillsRequired, 0, EDARKillsRequired, WavesWithoutDamageRequired, 0);
}

private event GrantEventItems()
{
	if (Outer.IsEventObjectiveComplete(0) &&
		Outer.IsEventObjectiveComplete(1) &&
		Outer.IsEventObjectiveComplete(2) &&
		Outer.IsEventObjectiveComplete(3) &&
		Outer.IsEventObjectiveComplete(4))
	{
		// "Cyborg | Companion Backpack | Precious"
		GrantEventItem(8716);
	}
}

simulated event OnGameWon(class<GameInfo> GameClass, int Difficulty, int GameLength, bool bCoOp)
{
	// Dystopia weekly
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
	local int ObjIdx;

	// Boss kills in any map
	ObjIdx = 0;
	if (bObjectiveIsValidForMap[ObjIdx] != 0)
	{
		IncrementSeasonalEventStat(ObjIdx, 1);
		if (Outer.GetSeasonalEventStatValue(ObjIdx) >= BossKillsRequired)
		{
			FinishedObjective(SEI_Spring, ObjIdx);
		}
	}
}

simulated function OnZedKilled(class<KFPawn_Monster> MonsterClass, int Difficulty, class<DamageType> DT)
{
	local int ObjIdx;

	// E.D.A.R kills
	ObjIdx = 2;
	if (bObjectiveIsValidForMap[ObjIdx] != 0)
	{
		if (ClassIsChildOf(MonsterClass, class'KFPawn_ZedDAR'))
		{
			IncrementSeasonalEventStat(ObjIdx, 1);
			if (Outer.GetSeasonalEventStatValue(ObjIdx) >= EDARKillsRequired)
			{
				FinishedObjective(SEI_Spring, ObjIdx);
			}
		}
	}
}

simulated function OnHitTaken()
{
	bHitTakenThisWave=true;
}

simulated event OnWaveCompleted(class<GameInfo> GameClass, int Difficulty, int WaveNum)
{
	local int ObjIdx;

	// No damage wave completed
	ObjIdx = 3;
	if (bObjectiveIsValidForMap[ObjIdx] != 0)
	{
		if (!bHitTakenThisWave)
		{
			IncrementSeasonalEventStat(ObjIdx, 1);
			if (Outer.GetSeasonalEventStatValue(ObjIdx) >= WavesWithoutDamageRequired)
			{
				FinishedObjective(SEI_Spring, ObjIdx);
			}
		}
		bHitTakenThisWave = false;
	}

	//  Wavesin Endless hard
	ObjIdx = 4;
	if (bObjectiveIsValidForMap[ObjIdx] != 0)
	{
		if (WaveNum >= EndlessWaveRequired && GameClass == class'KFGameInfo_Endless' && Difficulty >= `DIFFICULTY_HARD)
		{
			FinishedObjective(SEI_Spring, ObjIdx);
		}
	}
}

defaultproperties
{
	BossKillsRequired=15
	EDARKillsRequired=50
	WavesWithoutDamageRequired=10
	EndlessWaveRequired=15

	bHitTakenThisWave=false
}
