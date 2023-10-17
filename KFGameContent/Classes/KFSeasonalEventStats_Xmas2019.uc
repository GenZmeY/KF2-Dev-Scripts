//=============================================================================
// KFSeasonalEventStats_Xmas2019
//=============================================================================
// Tracks event-specific challenges/accomplishments for Xmas 2019
//=============================================================================
// Killing Floor 2
// Copyright (C) 2019 Tripwire Interactive LLC
//=============================================================================
class KFSeasonalEventStats_Xmas2019 extends KFSeasonalEventStats;

var transient private const int TentacleTrapKillsRequired, SuctionTrapKillsRequired, MatriarchKillsRequired;

private event Initialize(string MapName)
{
	local string CapsMapName;
	CapsMapName = Caps(MapName);

	bObjectiveIsValidForMap[0] = 0; // Defeat any boss on Survival Hard or higher difficulty on Sanitarium
	bObjectiveIsValidForMap[1] = 0; // Use Tentacle Whip trap to kill 20 zeds on Sanitarium
	bObjectiveIsValidForMap[2] = 0; // Use Suction Trap to kill 20 zeds on Sanitarium
	bObjectiveIsValidForMap[3] = 0; // Kill the Matriarch 10 times on any map or mode
	bObjectiveIsValidForMap[4] = 0; // Complete Biotics Lab on Objective Hard or higher difficulty

	if (CapsMapName == "KF-SANITARIUM")
	{
		bObjectiveIsValidForMap[0] = 1;
		bObjectiveIsValidForMap[1] = 1;
		bObjectiveIsValidForMap[2] = 1;
	}
	else if (CapsMapName == "KF-BIOTICSLAB")
	{
		bObjectiveIsValidForMap[4] = 1;
	}

	SetSeasonalEventStatsMax(0, TentacleTrapKillsRequired, SuctionTrapKillsRequired, MatriarchKillsRequired, 0);
}

private event GrantEventItems()
{
	if (Outer.IsEventObjectiveComplete(0) &&
		Outer.IsEventObjectiveComplete(1) &&
		Outer.IsEventObjectiveComplete(2) &&
		Outer.IsEventObjectiveComplete(3) &&
		Outer.IsEventObjectiveComplete(4))
	{
		GrantEventItem(7831);
	}
}

simulated event OnGameWon(class<GameInfo> GameClass, int Difficulty, int GameLength, bool bCoOp)
{
	// sanitarium survival hard or higher
	if (bObjectiveIsValidForMap[0] != 0)
	{
		if (GameClass == class'KFGameInfo_Survival' && Difficulty >= `DIFFICULTY_HARD)
		{
			FinishedObjective(SEI_Winter, 0);
		}
	}

	// biotics lab objective hard or higher
	if (bObjectiveIsValidForMap[4] != 0)
	{
		if (GameClass == class'KFGameInfo_Objective' && Difficulty >= `DIFFICULTY_HARD)
		{
			FinishedObjective(SEI_Winter, 4);
		}
	}
}

simulated function OnZedKilled(class<KFPawn_Monster> MonsterClass, int Difficulty, class<DamageType> DT, bool bKiller)
{
	if (bKiller == false)
	{
		return;
	}

	if (bObjectiveIsValidForMap[1] != 0)
	{
		if (DT == class'KFDT_Trap_SanitariumTentacle')
		{
			IncrementSeasonalEventStat(1, 1);
			if (Outer.GetSeasonalEventStatValue(1) >= TentacleTrapKillsRequired)
			{
				FinishedObjective(SEI_Winter, 1);
			}
		}
	}

	if (bObjectiveIsValidForMap[2] != 0)
	{
		if (DT == class'KFDT_Trap_SanitariumSuction')
		{
			IncrementSeasonalEventStat(2, 1);
			if (Outer.GetSeasonalEventStatValue(2) >= SuctionTrapKillsRequired)
			{
				FinishedObjective(SEI_Winter, 2);
			}
		}
	}

	// kill Matriarch 10 times on any map, in any mode
	if (MonsterClass == class'KFPawn_ZedMatriarch')
	{
		IncrementSeasonalEventStat(3, 1);
		if (Outer.GetSeasonalEventStatValue(3) >= MatriarchKillsRequired)
		{
			FinishedObjective(SEI_Winter, 3);
		}
	}
}

defaultproperties
{
	TentacleTrapKillsRequired=20
	SuctionTrapKillsRequired=20
	MatriarchKillsRequired=10
}
