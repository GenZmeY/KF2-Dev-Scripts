//=============================================================================
// KFSeasonalEventStats_Fall2023
//=============================================================================
// Tracks event-specific challenges/accomplishments for Fall 2023
//=============================================================================
// Killing Floor 2
// Copyright (C) 2021 Tripwire Interactive LLC
//=============================================================================
class KFSeasonalEventStats_Fall2023 extends KFSeasonalEventStats;

var transient private const int HansVolterKillsRequired, CollectiblesLimit, EndlessWaveRequired;
var transient string SavedMapName;

private event Initialize(string MapName)
{
	local string CapsMapName;

	CapsMapName = Caps(MapName);

	SavedMapName = CapsMapName;

	bObjectiveIsValidForMap[0] = 1; // Kill Hans Volter in 5 different maps
	bObjectiveIsValidForMap[1] = 0; // Complete the Weekly on Castle Volter
	bObjectiveIsValidForMap[2] = 0; // Find ten Castle Volter's Collectibles
	bObjectiveIsValidForMap[3] = 0; // Unlock the Castle Volter's trophy room
	bObjectiveIsValidForMap[4] = 0; // Complete wave 15 on Endless Hard or higher difficulty on Castle Volter
	
	if (CapsMapName == "KF-CASTLEVOLTER")
	{
		bObjectiveIsValidForMap[1] = 1;
		bObjectiveIsValidForMap[2] = 1;
		bObjectiveIsValidForMap[3] = 1;
		bObjectiveIsValidForMap[4] = 1;
	}

	SetSeasonalEventStatsMax(HansVolterKillsRequired, 0, CollectiblesLimit, 0, EndlessWaveRequired);
}

simulated event OnStatsInitialized()
{
    super.OnStatsInitialized();

	CheckRestartObjective(2, CollectiblesLimit);
}

private event GrantEventItems()
{
	if (Outer.IsEventObjectiveComplete(0) &&
		Outer.IsEventObjectiveComplete(1) &&
		Outer.IsEventObjectiveComplete(2) &&
		Outer.IsEventObjectiveComplete(3) &&
		Outer.IsEventObjectiveComplete(4))
	{
        GrantEventItem(9754);
	}
}

// Complete the Weekly on Castle Volter
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

	CheckRestartObjective(2, CollectiblesLimit);
}

simulated event OnGameEnd(class<GameInfo> GameClass)
{
	CheckRestartObjective(2, CollectiblesLimit);
}

// Complete wave 15 on Endless Hard or higher difficulty on Castle Volter
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
	local int ObjIdx;

	ObjIdx=3;
	if (bObjectiveIsValidForMap[ObjIdx] != 0 && EventIndex == SEI_Fall && ObjectiveIndex == ObjIdx)
	{
		FinishedObjective(EventIndex, ObjectiveIndex);
	}
}

// Kill Hans Volter in 5 different maps
simulated function OnZedKilled(class<KFPawn_Monster> MonsterClass, int Difficulty, class<DamageType> DT, bool bKiller)
{
	local int ObjIdx;
	local KFProfileSettings Profile;

	ObjIdx = 0;

	if (bObjectiveIsValidForMap[ObjIdx] != 0)
	{
		if (MonsterClass == class'KFPawn_ZedHansBase'
			|| MonsterClass == class'KFPawn_ZedHans')
		{
			// This event can be heard no matter is bKiller true | false, we count for every player on the objective

			if (Outer.GetSeasonalEventStatValue(ObjIdx) < HansVolterKillsRequired) // If we still didn't reach the limit..
			{
				Profile = KFProfileSettings(Outer.MyKFPC.OnlineSub.PlayerInterface.GetProfileSettings(Outer.MyKFPC.StoredLocalUserNum));
				if(Profile != none)
				{
					if (Profile.AddHansVolterKilledInMap(SavedMapName))
					{
						//`Log("AddHansVolterKilledInMap : " $SavedMapName);

						IncrementSeasonalEventStat(ObjIdx, 1);

						if (Outer.GetSeasonalEventStatValue(ObjIdx) >= HansVolterKillsRequired)
						{
							FinishedObjective(SEI_Fall, ObjIdx);
						}
					}
				}
			}
		}
	}
}

// Find ten Castle Volter's Collectibles
simulated function OnCollectibleFound(int Limit)
{
	local int ObjIdx;

	ObjIdx = 2;

	if (bObjectiveIsValidForMap[ObjIdx] != 0)
	{
		IncrementSeasonalEventStat(ObjIdx, 1);

		if (Outer.GetSeasonalEventStatValue(ObjIdx) >= CollectiblesLimit)
		{
			FinishedObjective(SEI_Fall, ObjIdx);
		}
	}	
}

defaultproperties
{
    HansVolterKillsRequired=5
	CollectiblesLimit=10
	EndlessWaveRequired=15
}
