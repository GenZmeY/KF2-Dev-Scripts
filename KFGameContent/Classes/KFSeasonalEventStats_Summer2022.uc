//=============================================================================
// KFSeasonalEventStats_Summer2022
//=============================================================================
// Tracks event-specific challenges/accomplishments for Summer 2022
//=============================================================================
// Killing Floor 2
// Copyright (C) 2021 Tripwire Interactive LLC
//=============================================================================
class KFSeasonalEventStats_Summer2022 extends KFSeasonalEventStats;

var transient private const int ZedsKillRequired;
var transient private const int WavesRequired;
var transient private const int ZedsThrowSeaRequired;
var transient private const int EndlessWaveRequired;

var transient int LastWaveFinished;

private event Initialize(string MapName)
{
	local string CapsMapName;
	CapsMapName = Caps(MapName);

	bObjectiveIsValidForMap[0] = 1; // Kill 1500 Zeds on any map or mode
	bObjectiveIsValidForMap[1] = 0; // Complete the Weekly on Rig
	bObjectiveIsValidForMap[2] = 0; // Complete 100 waves on Rig
	bObjectiveIsValidForMap[3] = 0; // Throw 50 Zeds to the sea on Rig
	bObjectiveIsValidForMap[4] = 0; // Complete wave 15 on Endless Hard or higher difficulty on Rig

	if (CapsMapName == "KF-RIG")
	{
		bObjectiveIsValidForMap[1] = 1;
		bObjectiveIsValidForMap[2] = 1;
		bObjectiveIsValidForMap[3] = 1;
		bObjectiveIsValidForMap[4] = 1;
	}

	SetSeasonalEventStatsMax(ZedsKillRequired, 0, WavesRequired, ZedsThrowSeaRequired, EndlessWaveRequired);
}

private event GrantEventItems()
{
	if (Outer.IsEventObjectiveComplete(0) &&
		Outer.IsEventObjectiveComplete(1) &&
		Outer.IsEventObjectiveComplete(2) &&
		Outer.IsEventObjectiveComplete(3) &&
		Outer.IsEventObjectiveComplete(4))
	{
		GrantEventItem(9334);
	}
}

simulated event OnGameWon(class<GameInfo> GameClass, int Difficulty, int GameLength, bool bCoOp)
{
	// Rig weekly
	if (bObjectiveIsValidForMap[1] != 0)
	{
		if (GameClass == class'KFGameInfo_WeeklySurvival')
		{
			FinishedObjective(SEI_Summer, 1);
		}
	}
}

simulated function OnZedKilled(class<KFPawn_Monster> MonsterClass, int Difficulty, class<DamageType> DT, bool bKiller)
{
	local int ObjIdx;

	if (bKiller == false)
	{
		return;
	}

	// Kill 1500 Zeds on any map or mode
	ObjIdx = 0;
	if (bObjectiveIsValidForMap[ObjIdx] != 0)
	{
		IncrementSeasonalEventStat(ObjIdx, 1);
		if (Outer.GetSeasonalEventStatValue(ObjIdx) >= ZedsKillRequired)
		{
			FinishedObjective(SEI_SUMMER, ObjIdx);
		}
	}
}

simulated function OnTriggerUsed(class<Trigger_PawnsOnly> TriggerClass)
{
	local int ObjIdx;

	// Throw 50 Zeds to the sea on Rig
	ObjIdx = 3;
	if (bObjectiveIsValidForMap[ObjIdx] != 0)
	{
		if (TriggerClass == class'KFSeaTrigger')
		{
			IncrementSeasonalEventStat(ObjIdx, 1);
			if (Outer.GetSeasonalEventStatValue(ObjIdx) >= ZedsThrowSeaRequired)
			{
				FinishedObjective(SEI_SUMMER, ObjIdx);
			}
		}
	}
}

simulated event OnWaveCompleted(class<GameInfo> GameClass, int Difficulty, int WaveNum)
{
	local int ObjIdx;
	local bool canIncreaseWave;

	canIncreaseWave = false;

	// Complete 100 waves on Rig
	ObjIdx = 2;
	if (bObjectiveIsValidForMap[ObjIdx] != 0)
	{
		if (GameClass == class'KFGameInfo_Endless')
		{
			if (LastWaveFinished != WaveNum)
			{
				canIncreaseWave = true;
				LastWaveFinished = WaveNum;
			}
		}
		else
		{
			canIncreaseWave = true;
		}

		if (canIncreaseWave)
		{
			IncrementSeasonalEventStat(ObjIdx, 1);
		}

		if (Outer.GetSeasonalEventStatValue(ObjIdx) >= WavesRequired)
		{
			FinishedObjective(SEI_SUMMER, ObjIdx);
		}
	}

	// Complete wave 15 on Endless Hard or higher difficulty on Rig
	ObjIdx = 4;
	if (bObjectiveIsValidForMap[ObjIdx] != 0)
	{
		if (WaveNum >= EndlessWaveRequired && GameClass == class'KFGameInfo_Endless' && Difficulty >= `DIFFICULTY_HARD)
		{
			FinishedObjective(SEI_Summer, ObjIdx);
		}
	}
}

defaultproperties
{
	ZedsKillRequired=1500
	WavesRequired=100
	ZedsThrowSeaRequired=50
	EndlessWaveRequired=15
	LastWaveFinished=-1
}
