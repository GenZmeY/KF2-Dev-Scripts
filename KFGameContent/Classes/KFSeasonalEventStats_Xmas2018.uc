//=============================================================================
// KFSeasonalEventStats_Xmas2018
//=============================================================================
// Tracks event-specific challenges/accomplishments for Xmas 2018
//=============================================================================
// Killing Floor 2
// Copyright (C) 2018 Tripwire Interactive LLC
//=============================================================================
class KFSeasonalEventStats_Xmas2018 extends KFSeasonalEventStats;

var transient private const int PerfectEscortsRequired, ZedKillsRequired, BossDeathsRequired;
var transient private int PerfectEscortCount, ZedKillsCount;

private event Initialize(string MapName)
{
	local string CapsMapName;
	CapsMapName = Caps(MapName);

	bObjectiveIsValidForMap[0] = 0; // complete all escorts at full health (Santa's Workshop)
	bObjectiveIsValidForMap[1] = 0; // complete weekly event (Shopping Spree)
	bObjectiveIsValidForMap[2] = 1; // kill zeds (as an individual) (any map)
	bObjectiveIsValidForMap[3] = 1; // kill bosses (as a team) (any map)
	bObjectiveIsValidForMap[4] = 0; // defeat Krampus on Hard (Santa's Workshop)

	if (CapsMapName == "KF-SANTASWORKSHOP")
	{
		bObjectiveIsValidForMap[0] = 1;
		bObjectiveIsValidForMap[4] = 1;
	}
	else if (CapsMapName == "KF-SHOPPINGSPREE")
	{
		bObjectiveIsValidForMap[1] = 1;
	}

	SetSeasonalEventStatsMax(0, 0, ZedKillsRequired, BossDeathsRequired, 0);
}

private event GrantEventItems()
{
	if (Outer.IsEventObjectiveComplete(0) &&
		Outer.IsEventObjectiveComplete(1) &&
		Outer.IsEventObjectiveComplete(2) &&
		Outer.IsEventObjectiveComplete(3) &&
		Outer.IsEventObjectiveComplete(4))
	{
		GrantEventItem(5378);
	}
}

static private event bool AllowEventBossOverrideForMap(string MapName)
{
	local string CapsMapName;
	CapsMapName = Caps(MapName);

	if (CapsMapName == "KF-SANTASWORKSHOP")
	{
		return true;
	}

	return false;
}

simulated function OnMapObjectiveDeactivated(Actor ObjectiveInterfaceActor)
{
	if (bObjectiveIsValidForMap[0] != 0 &&
		KFGameReplicationInfo(Outer.MyKFPC.WorldInfo.GRI).GameDifficulty >= `DIFFICULTY_HARD)
	{
		if (KFMapObjective_EscortPawns(ObjectiveInterfaceActor) != none &&
			KFMapObjective_EscortPawns(ObjectiveInterfaceActor).CompletionPct > 0.99)
		{
			if (++PerfectEscortCount == PerfectEscortsRequired)
			{
				FinishedObjective(SEI_Winter, 0);
			}
		}
	}
}

simulated function OnZedKilled(class<KFPawn_Monster> MonsterClass, int Difficulty, class<DamageType> DT, bool bKiller)
{
	if (bKiller == false)
	{
		return;
	}

	if (bObjectiveIsValidForMap[2] != 0)
	{
		IncrementSeasonalEventStat(2, 1);
		if (Outer.GetSeasonalEventStatValue(2) >= ZedKillsRequired)
		{
			FinishedObjective(SEI_Winter, 2);
		}
	}
}

simulated event OnGameWon(class<GameInfo> GameClass, int Difficulty, int GameLength, bool bCoOp)
{
	if (bObjectiveIsValidForMap[4] != 0)
	{
		if (GameClass == class'KFGameInfo_Survival' && Difficulty >= `DIFFICULTY_HARD)
		{
			FinishedObjective(SEI_Winter, 4);
		}
	}
	else if (bObjectiveIsValidForMap[1] != 0)
	{
		if (GameClass == class'KFGameInfo_WeeklySurvival')
		{
			FinishedObjective(SEI_Winter, 1);
		}
	}
}

simulated function OnBossDied()
{
	if (bObjectiveIsValidForMap[3] != 0)
	{
		IncrementSeasonalEventStat(3, 1);
		if (Outer.GetSeasonalEventStatValue(3) >= BossDeathsRequired)
		{
			FinishedObjective(SEI_Winter, 3);
		}
	}
}

defaultproperties
{
	PerfectEscortsRequired=3
	ZedKillsRequired=2500
	BossDeathsRequired=25
}
