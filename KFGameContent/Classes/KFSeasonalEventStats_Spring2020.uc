//=============================================================================
// KFSeasonalEventStats_Spring2020
//=============================================================================
// Tracks event-specific challenges/accomplishments for Spring 2020
//=============================================================================
// Killing Floor 2
// Copyright (C) 2020 Tripwire Interactive LLC
//=============================================================================
class KFSeasonalEventStats_Spring2020 extends KFSeasonalEventStats;

var transient private const int ZedKillsRequired, BloodBlenderKillsRequired, TrapDoorKillsRequired;

private event Initialize(string MapName)
{
	local string CapsMapName;
	CapsMapName = Caps(MapName);

	bObjectiveIsValidForMap[0] = 1; // Kill 1500 zeds on any map
	bObjectiveIsValidForMap[1] = 0; // Complete the weekly on Biolapse
	bObjectiveIsValidForMap[2] = 0; // Use the blood blender to kill 20 zeds on Biolapse
	bObjectiveIsValidForMap[3] = 0; // Use the trap doors to kill 20 zeds on Biolapse
	bObjectiveIsValidForMap[4] = 0; // Defeat any boss on Survival Hard or higher difficulty on Biolapse

	if (CapsMapName == "KF-BIOLAPSE")
	{
		bObjectiveIsValidForMap[1] = 1;
		bObjectiveIsValidForMap[2] = 1;
		bObjectiveIsValidForMap[3] = 1;
		bObjectiveIsValidForMap[4] = 1;
	}

	SetSeasonalEventStatsMax(ZedKillsRequired, 0, BloodBlenderKillsRequired, TrapDoorKillsRequired, 0);
}

private event GrantEventItems()
{
	if (Outer.IsEventObjectiveComplete(0) &&
		Outer.IsEventObjectiveComplete(1) &&
		Outer.IsEventObjectiveComplete(2) &&
		Outer.IsEventObjectiveComplete(3) &&
		Outer.IsEventObjectiveComplete(4))
	{
		GrantEventItem(8150);
	}
}

simulated event OnGameWon(class<GameInfo> GameClass, int Difficulty, int GameLength, bool bCoOp)
{
	local int ObjIdx;

	// Biolapse weekly survival
	ObjIdx = 1;
	if (bObjectiveIsValidForMap[ObjIdx] != 0)
	{
		if (GameClass == class'KFGameInfo_WeeklySurvival')
		{
			FinishedObjective(SEI_Spring, ObjIdx);
		}
	}

	// Biolapse survival hard or higher
	ObjIdx = 4;
	if (bObjectiveIsValidForMap[ObjIdx] != 0)
	{
		if (GameClass == class'KFGameInfo_Survival' && Difficulty >= `DIFFICULTY_HARD)
		{
			FinishedObjective(SEI_Spring, ObjIdx);
		}
	}
}

simulated function OnZedKilled(class<KFPawn_Monster> MonsterClass, int Difficulty, class<DamageType> DT)
{
	local int ObjIdx;

	ObjIdx = 0;
	if (bObjectiveIsValidForMap[ObjIdx] != 0)
	{
		IncrementSeasonalEventStat(ObjIdx, 1);
		if (Outer.GetSeasonalEventStatValue(ObjIdx) >= ZedKillsRequired)
		{
			FinishedObjective(SEI_Spring, ObjIdx);
		}
	}

	ObjIdx = 2;
	if (bObjectiveIsValidForMap[ObjIdx] != 0)
	{
		if (DT == class'KFDT_Trap_BiolapseBloodBlender')
		{
			IncrementSeasonalEventStat(ObjIdx, 1);
			if (Outer.GetSeasonalEventStatValue(ObjIdx) >= BloodBlenderKillsRequired)
			{
				FinishedObjective(SEI_Spring, ObjIdx);
			}
		}
	}

	ObjIdx = 3;
	if (bObjectiveIsValidForMap[ObjIdx] != 0)
	{
		if (DT == class'KFDT_Trap_BiolapseTrapDoor')
		{
			IncrementSeasonalEventStat(ObjIdx, 1);
			if (Outer.GetSeasonalEventStatValue(ObjIdx) >= TrapDoorKillsRequired)
			{
				FinishedObjective(SEI_Spring, ObjIdx);
			}
		}
	}
}

defaultproperties
{
	ZedKillsRequired=1500
	BloodBlenderKillsRequired=20
	TrapDoorKillsRequired=20
}