//=============================================================================
// KFSeasonalEventStats_Xmas2020
//=============================================================================
// Tracks event-specific challenges/accomplishments for Xmas 2020
//=============================================================================
// Killing Floor 2
// Copyright (C) 2020 Tripwire Interactive LLC
//=============================================================================
class KFSeasonalEventStats_Xmas2020 extends KFSeasonalEventStats;

var transient private const int RosesRequired, TomesRequired, EndlessWaveRequired, XmasEventIndex;

private event Initialize(string MapName)
{
	local string CapsMapName;
	CapsMapName = Caps(MapName);

	bObjectiveIsValidForMap[0] = 0; // Collect 3 roses in Elysium
	bObjectiveIsValidForMap[1] = 0; // Collect 4 tomes in Elysium
	bObjectiveIsValidForMap[2] = 0; // Complete one wave in Elysium's Botanica arena
	bObjectiveIsValidForMap[3] = 0; // Complete one wave in Elysium's Loremaster Sanctum arena
	bObjectiveIsValidForMap[4] = 0; // Complete wave 15 on Endless Hard or higher difficulty on Elysium
	
	if (CapsMapName == "KF-ELYSIUM")
	{
        bObjectiveIsValidForMap[0] = 1;
		bObjectiveIsValidForMap[1] = 1;
		bObjectiveIsValidForMap[2] = 1;
		bObjectiveIsValidForMap[3] = 1;
		bObjectiveIsValidForMap[4] = 1;
	}

	SetSeasonalEventStatsMax(RosesRequired, TomesRequired, 0, 0, 0);
}

private event GrantEventItems()
{
	if (Outer.IsEventObjectiveComplete(0) &&
		Outer.IsEventObjectiveComplete(1) &&
		Outer.IsEventObjectiveComplete(2) &&
		Outer.IsEventObjectiveComplete(3) &&
		Outer.IsEventObjectiveComplete(4))
	{
		GrantEventItem(8608);
	}
}

simulated function OnTryCompleteObjective(int ObjectiveIndex, int EventIndex)
{
	local int ObjIdx;

    // Collect 3 roses in Elysium
	ObjIdx = 0;
	if (bObjectiveIsValidForMap[ObjIdx] != 0 && ObjectiveIndex == ObjIdx && EventIndex == XmasEventIndex)
	{
        IncrementSeasonalEventStat(ObjIdx, 1);
		if (Outer.GetSeasonalEventStatValue(ObjIdx) >= RosesRequired)
		{
			FinishedObjective(XmasEventIndex, ObjIdx);
		}
	}

    // Collect 4 tomes in Elysium
	ObjIdx = 1;
    if (bObjectiveIsValidForMap[ObjIdx] != 0 && ObjectiveIndex == ObjIdx && EventIndex == XmasEventIndex)
	{
        IncrementSeasonalEventStat(ObjIdx, 1);
		if (Outer.GetSeasonalEventStatValue(ObjIdx) >= TomesRequired)
		{
			FinishedObjective(XmasEventIndex, ObjIdx);
		}
	}

    // Complete one wave in Elysium's Botanica arena
	ObjIdx = 2;
    if (bObjectiveIsValidForMap[ObjIdx] != 0 && ObjectiveIndex == ObjIdx && EventIndex == XmasEventIndex)
	{
		FinishedObjective(XmasEventIndex, ObjIdx);
	}

    // Complete one wave in Elysium's Loremaster Sanctum arena
	ObjIdx = 3;
    if (bObjectiveIsValidForMap[ObjIdx] != 0 && ObjectiveIndex == ObjIdx && EventIndex == XmasEventIndex)
	{
		FinishedObjective(XmasEventIndex, ObjIdx);
	}
}

simulated event OnWaveCompleted(class<GameInfo> GameClass, int Difficulty, int WaveNum)
{
	local int ObjIdx;

	// Complete wave 15 on Endless Hard or higher difficulty on Elysium
	ObjIdx = 4;
	if (bObjectiveIsValidForMap[ObjIdx] != 0)
	{
		if (WaveNum >= EndlessWaveRequired && GameClass == class'KFGameInfo_Endless' && Difficulty >= `DIFFICULTY_HARD)
		{
			FinishedObjective(XmasEventIndex, ObjIdx);
		}
	}
}

defaultproperties
{
	RosesRequired=3
	TomesRequired=4
	EndlessWaveRequired=15
	XmasEventIndex=SEI_Winter
}