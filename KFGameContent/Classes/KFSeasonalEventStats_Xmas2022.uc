//=============================================================================
// KFSeasonalEventStats_Xmas2022
//=============================================================================
// Tracks event-specific challenges/accomplishments for Xmas 2022
//=============================================================================
// Killing Floor 2
// Copyright (C) 2022 Tripwire Interactive LLC
//=============================================================================
class KFSeasonalEventStats_Xmas2022 extends KFSeasonalEventStats;

/** 
    Required impacts of the same projectile to count for the objective. I.e. 3 means
    that a ballistic bouncer projectile needs to make 3 impacts to count for the objective
*/
var private const byte HRGBBProjectilImpactsRequired;

var transient private const int FrozenZedsRequired, ShotgunJumpsRequired, BallisticBouncerImpactsRequired, EndlessWaveRequired, XmasEventIndex;

var transient int ShotgunJumpsIdx;

private event Initialize(string MapName)
{
	local string CapsMapName;
	CapsMapName = Caps(MapName);

	bObjectiveIsValidForMap[0] = 1; // Freeze 500 Zeds using ice arsenal
	bObjectiveIsValidForMap[1] = 0; // Complete the Weekly on Crash
	bObjectiveIsValidForMap[2] = 0; // Use 4 Boomstick Jumps in a same match on Crash
	bObjectiveIsValidForMap[3] = 1; // Hit 2 Zeds with a shot of HRG Ballistic Bouncer (30 times)
	bObjectiveIsValidForMap[4] = 0; // Complete wave 15 on Endless Hard or higher difficulty on Crash
	
	if (CapsMapName == "KF-CRASH")
	{
		bObjectiveIsValidForMap[1] = 1;
		bObjectiveIsValidForMap[2] = 1;
		bObjectiveIsValidForMap[4] = 1;
	}

	SetSeasonalEventStatsMax(FrozenZedsRequired, 0, ShotgunJumpsRequired, BallisticBouncerImpactsRequired, 0);
}

simulated event OnStatsInitialized()
{
    super.OnStatsInitialized();

	CheckRestartObjective(ShotgunJumpsIdx, ShotgunJumpsRequired);
}

private event GrantEventItems()
{
	if (Outer.IsEventObjectiveComplete(0) &&
		Outer.IsEventObjectiveComplete(1) &&
		Outer.IsEventObjectiveComplete(2) &&
		Outer.IsEventObjectiveComplete(3) &&
		Outer.IsEventObjectiveComplete(4))
	{
		GrantEventItem(9568);
	}
}

simulated event OnGameWon(class<GameInfo> GameClass, int Difficulty, int GameLength, bool bCoOp)
{
	local int ObjIdx;
	ObjIdx = 1;
	
	// Crash weekly
	if (bObjectiveIsValidForMap[ObjIdx] != 0)
	{
		if (GameClass == class'KFGameInfo_WeeklySurvival')
		{
			FinishedObjective(XmasEventIndex, ObjIdx);
		}
	}

	CheckRestartObjective(ShotgunJumpsIdx, ShotgunJumpsRequired);
}

simulated event OnGameEnd(class<GameInfo> GameClass)
{
	CheckRestartObjective(ShotgunJumpsIdx, ShotgunJumpsRequired);
}

simulated function CheckRestartObjective(int ObjectiveIndex, int ObjectiveLimit)
{
	local int StatValue;

	StatValue = Outer.GetSeasonalEventStatValue(ObjectiveIndex);

	if (StatValue != 0 && StatValue < ObjectiveLimit)
	{
		ResetSeasonalEventStat(ObjectiveIndex);
	}
}

simulated function OnTryCompleteObjective(int ObjectiveIndex, int EventIndex)
{
	local int FrozenZedsIdx, BallisticBouncerImpactsIdx, ObjectiveLimit;
	local bool bValidIdx;

	FrozenZedsIdx = 0;
	BallisticBouncerImpactsIdx = 3;
	bValidIdx = false;

	if(EventIndex == XmasEventIndex)
	{
		if (ObjectiveIndex == FrozenZedsIdx)
		{
			ObjectiveLimit = FrozenZedsRequired;
			bValidIdx = true;
		}
		else if (ObjectiveIndex == ShotgunJumpsIdx)
		{
			ObjectiveLimit = ShotgunJumpsRequired;
			bValidIdx = true;
		}
		else if (ObjectiveIndex == BallisticBouncerImpactsIdx)
		{
			ObjectiveLimit = BallisticBouncerImpactsRequired;
			bValidIdx = true;
		}
		
		if (bValidIdx && bObjectiveIsValidForMap[ObjectiveIndex] != 0)
		{
			IncrementSeasonalEventStat(ObjectiveIndex, 1);
			if (Outer.GetSeasonalEventStatValue(ObjectiveIndex) >= ObjectiveLimit)
			{
				FinishedObjective(XmasEventIndex, ObjectiveIndex);
			}
		}
	}
}

simulated event OnWaveCompleted(class<GameInfo> GameClass, int Difficulty, int WaveNum)
{
	local int ObjIdx;

	// Complete wave 15 on Endless Hard or higher difficulty on Crash
	ObjIdx = 4;
	if (bObjectiveIsValidForMap[ObjIdx] != 0)
	{
		if (WaveNum >= EndlessWaveRequired && GameClass == class'KFGameInfo_Endless' && Difficulty >= `DIFFICULTY_HARD)
		{
			FinishedObjective(XmasEventIndex, ObjIdx);
		}
	}
}

simulated function OnAfflictionCaused(EAfflictionType Type)
{
	local int ObjIdx;

	ObjIdx = 0;

	if (bObjectiveIsValidForMap[ObjIdx] != 0)
	{
		if (Type == AF_Freeze)
		{
			IncrementSeasonalEventStat(ObjIdx, 1);
			if (Outer.GetSeasonalEventStatValue(ObjIdx) >= FrozenZedsRequired)
			{
				FinishedObjective(XmasEventIndex, ObjIdx);
			}
		}
	}
}

static function byte GetMaxBallisticBouncerImpacts()
{
	return default.HRGBBProjectilImpactsRequired;
}

defaultproperties
{
	ShotgunJumpsIdx=2

	FrozenZedsRequired=500
	ShotgunJumpsRequired=4
	BallisticBouncerImpactsRequired=30
	EndlessWaveRequired=15
	XmasEventIndex=SEI_Winter

	HRGBBProjectilImpactsRequired=2
}