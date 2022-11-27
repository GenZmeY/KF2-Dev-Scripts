//=============================================================================
// KFSeasonalEventStats_Fall2022
//=============================================================================
// Tracks event-specific challenges/accomplishments for Fall 2022
//=============================================================================
// Killing Floor 2
// Copyright (C) 2021 Tripwire Interactive LLC
//=============================================================================
class KFSeasonalEventStats_Fall2022 extends KFSeasonalEventStats;

var transient private const int BossKillsRequired, ZedsInBonfiresRequired, EndlessWaveRequired;

private event Initialize(string MapName)
{
	local string CapsMapName;
	CapsMapName = Caps(MapName);

	bObjectiveIsValidForMap[0] = 1; // Kill 15 Bosses on any map or mode
	bObjectiveIsValidForMap[1] = 0; // Complete the Weekly on BarmwichTown
	bObjectiveIsValidForMap[2] = 0; // Open the Weapon Room
	bObjectiveIsValidForMap[3] = 0; // Make 50 Zeds to pass through the bonfires of Barmwitch Town
	bObjectiveIsValidForMap[4] = 0; // Complete wave 15 on Endless Hard or higher difficulty on Barmwitch Town
	
	if (CapsMapName == "KF-BARMWICHTOWN")
	{
		bObjectiveIsValidForMap[1] = 1;
		bObjectiveIsValidForMap[2] = 1;
		bObjectiveIsValidForMap[3] = 1;
		bObjectiveIsValidForMap[4] = 1;
	}

	SetSeasonalEventStatsMax(BossKillsRequired, 0, 0, ZedsInBonfiresRequired, EndlessWaveRequired);
}

private event GrantEventItems()
{
	if (Outer.IsEventObjectiveComplete(0) &&
		Outer.IsEventObjectiveComplete(1) &&
		Outer.IsEventObjectiveComplete(2) &&
		Outer.IsEventObjectiveComplete(3) &&
		Outer.IsEventObjectiveComplete(4))
	{
        GrantEventItem(9424); 
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
	local int WeaponRoomIdx, BonfireIdx;
	WeaponRoomIdx = 2;
	BonfireIdx = 3;

	if(EventIndex == SEI_Fall)
	{
		if (ObjectiveIndex == WeaponRoomIdx)
		{
			if (bObjectiveIsValidForMap[ObjectiveIndex] != 0)
			{
				FinishedObjective(SEI_Fall, ObjectiveIndex);
			}
		}
		else if (ObjectiveIndex == BonfireIdx)
		{
			if (bObjectiveIsValidForMap[ObjectiveIndex] != 0)
			{
				IncrementSeasonalEventStat(ObjectiveIndex, 1);
				if (Outer.GetSeasonalEventStatValue(ObjectiveIndex) >= ZedsInBonfiresRequired)
				{
					FinishedObjective(SEI_Fall, ObjectiveIndex);
				}
			}
		}
	}
}

defaultproperties
{
    BossKillsRequired=15
	EndlessWaveRequired=15
    ZedsInBonfiresRequired=50
}
