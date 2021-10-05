//=============================================================================
// KFSeasonalEventStats_Fall2021
//=============================================================================
// Tracks event-specific challenges/accomplishments for Fall 2021
//=============================================================================
// Killing Floor 2
// Copyright (C) 2021 Tripwire Interactive LLC
//=============================================================================
class KFSeasonalEventStats_Fall2021 extends KFSeasonalEventStats;

var transient private const int BossKillsRequired, EndlessWaveRequired;

private event Initialize(string MapName)
{
	local string CapsMapName;
	CapsMapName = Caps(MapName);

	bObjectiveIsValidForMap[0] = 1; // Kill 15 Bosses on any map or mode
	bObjectiveIsValidForMap[1] = 0; // Complete the Weekly on Netherhold
	bObjectiveIsValidForMap[2] = 0; // Find the nether heart
	bObjectiveIsValidForMap[3] = 0; // Unlock the chapel and the dining hall doors
	bObjectiveIsValidForMap[4] = 0; // Complete wave 15 on Endless Hard or higher difficulty on Netherhold
	
	if (CapsMapName == "KF-NETHERHOLD")
	{
		bObjectiveIsValidForMap[1] = 1;
		bObjectiveIsValidForMap[2] = 1;
		bObjectiveIsValidForMap[3] = 1;
		bObjectiveIsValidForMap[4] = 1;
	}

	SetSeasonalEventStatsMax(BossKillsRequired, 0, 0, 0, 0);
}

private event GrantEventItems()
{
	if (Outer.IsEventObjectiveComplete(0) &&
		Outer.IsEventObjectiveComplete(1) &&
		Outer.IsEventObjectiveComplete(2) &&
		Outer.IsEventObjectiveComplete(3) &&
		Outer.IsEventObjectiveComplete(4))
	{
        // TODO: Uncomment me and set the proper item ID
		GrantEventItem(8990); 
	}
}

// Kill 15 Bosses on any map or mode
simulated function OnBossDied()
{
	local int ObjIdx;
	ObjIdx = 0;

	// Boss kills in any map
	if (bObjectiveIsValidForMap[ObjIdx] != 0)
	{
		IncrementSeasonalEventStat(ObjIdx, 1);
		if (Outer.GetSeasonalEventStatValue(ObjIdx) >= BossKillsRequired)
		{
			FinishedObjective(SEI_Fall, ObjIdx);
		}
	}
}

// Complete the Weekly on Netherhold
simulated event OnGameWon(class<GameInfo> GameClass, int Difficulty, int GameLength, bool bCoOp)
{
	local int ObjIdx;
    ObjIdx = 1;
	
    if (bObjectiveIsValidForMap[ObjIdx] != 0)
	{
		if (GameClass == class'KFGameInfo_WeeklySurvival')
		{
			FinishedObjective(SEI_Fall, ObjIdx);
		}
	}
}

// Complete wave 15 on Endless Hard or higher difficulty on Netherhold
simulated event OnWaveCompleted(class<GameInfo> GameClass, int Difficulty, int WaveNum)
{
	local int ObjIdx;
	ObjIdx = 4;

	if (bObjectiveIsValidForMap[ObjIdx] != 0)
	{
		if (WaveNum >= EndlessWaveRequired && GameClass == class'KFGameInfo_Endless' && Difficulty >= `DIFFICULTY_HARD)
		{
			FinishedObjective(SEI_Fall, ObjIdx);
		}
	}
}

simulated function OnTryCompleteObjective(int ObjectiveIndex, int EventIndex)
{
	local int NetherHeartIdx, ChapelIdx;
	NetherHeartIdx = 2;
	ChapelIdx = 3;

	if(EventIndex == SEI_Fall)
	{
		if (ObjectiveIndex == NetherHeartIdx || ObjectiveIndex == ChapelIdx)
		{
			if (bObjectiveIsValidForMap[ObjectiveIndex] != 0)
			{
				FinishedObjective(SEI_Fall, ObjectiveIndex);
			}
		}
	}
}

defaultproperties
{
    BossKillsRequired=15
	EndlessWaveRequired=15
}