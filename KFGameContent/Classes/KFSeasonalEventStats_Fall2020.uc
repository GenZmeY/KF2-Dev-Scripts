//=============================================================================
// KFSeasonalEventStats_Fall2020
//=============================================================================
// Tracks event-specific challenges/accomplishments for Fall 2020
//=============================================================================
// Killing Floor 2
// Copyright (C) 2020 Tripwire Interactive LLC
//=============================================================================
class KFSeasonalEventStats_Fall2020 extends KFSeasonalEventStats;

var transient private const int DeathsRequired, DecapitationsRequired, EndlessWaveRequired, PowerUpsRequired, FallEventIndex;

private event Initialize(string MapName)
{
	local string CapsMapName;
	CapsMapName = Caps(MapName);

	bObjectiveIsValidForMap[0] = 1; // Kill 2000 Zeds on any map or mode
	bObjectiveIsValidForMap[1] = 0; // Complete Weekly on Hellmark Station
	bObjectiveIsValidForMap[2] = 0; // Get the Hellish Rage from a Hellmark Station Obelisk 10 times
	bObjectiveIsValidForMap[3] = 0; // Decapitate 600 Zeds on Hellmark Station
	bObjectiveIsValidForMap[4] = 0; // Complete wave 15 on Endless Hard or higher difficulty on Hellmark Station
	
	if (CapsMapName == "KF-HELLMARKSTATION")
	{
		bObjectiveIsValidForMap[1] = 1;
		bObjectiveIsValidForMap[2] = 1;
		bObjectiveIsValidForMap[3] = 1;
		bObjectiveIsValidForMap[4] = 1;
	}

	SetSeasonalEventStatsMax(DeathsRequired, 0, PowerUpsRequired, DecapitationsRequired, 0);
}

private event GrantEventItems()
{
	if (Outer.IsEventObjectiveComplete(0) &&
		Outer.IsEventObjectiveComplete(1) &&
		Outer.IsEventObjectiveComplete(2) &&
		Outer.IsEventObjectiveComplete(3) &&
		Outer.IsEventObjectiveComplete(4))
	{
		GrantEventItem(8461); // Voodoo back pack
	}
}

simulated function OnZedKilled(class<KFPawn_Monster> MonsterClass, int Difficulty, class<DamageType> DT, bool bKiller)
{
	local int ObjIdx;
	
	if (bKiller == false)
	{
		return;
	}

	// Kill 2000 zeds on any map
	ObjIdx = 0;
	if (bObjectiveIsValidForMap[ObjIdx] != 0)
	{
		IncrementSeasonalEventStat(ObjIdx, 1);
		if (Outer.GetSeasonalEventStatValue(ObjIdx) >= DeathsRequired)
		{
			FinishedObjective(FallEventIndex, ObjIdx);
		}
	}
}

simulated event OnGameWon(class<GameInfo> GameClass, int Difficulty, int GameLength, bool bCoOp)
{
	local int ObjIdx;

	// HellMarkStation weekly survival
	ObjIdx = 1;
	if (bObjectiveIsValidForMap[ObjIdx] != 0)
	{
		if (GameClass == class'KFGameInfo_WeeklySurvival')
		{
			FinishedObjective(FallEventIndex, ObjIdx);
		}
	}
}

simulated function OnTryCompleteObjective(int ObjectiveIndex, int EventIndex)
{
	local int ObjIdx;

	// HellMarkStation activate powerup 10 times
	ObjIdx = 2;
	if (bObjectiveIsValidForMap[ObjIdx] != 0 && ObjectiveIndex == ObjIdx && EventIndex == FallEventIndex)
	{
		IncrementSeasonalEventStat(ObjIdx, 1);
		if (Outer.GetSeasonalEventStatValue(ObjIdx) >= PowerUpsRequired)
		{
			FinishedObjective(FallEventIndex, ObjIdx);
		}
	}
}

simulated function OnZedKilledByHeadshot(class<KFPawn_Monster> MonsterClass, int Difficulty, class<DamageType> DT)
{
	local int ObjIdx;
	
	// Hellmark Station decapitate 600 zeds
	ObjIdx = 3;
	if (bObjectiveIsValidForMap[ObjIdx] != 0)
	{
		IncrementSeasonalEventStat(ObjIdx, 1);
		if (Outer.GetSeasonalEventStatValue(ObjIdx) >= DecapitationsRequired)
		{
			FinishedObjective(FallEventIndex, ObjIdx);
		}
	}
}

simulated event OnWaveCompleted(class<GameInfo> GameClass, int Difficulty, int WaveNum)
{
	local int ObjIdx;

	// HellMarkStation endless 15 hard or higher
	ObjIdx = 4;
	if (bObjectiveIsValidForMap[ObjIdx] != 0)
	{
		if (WaveNum >= EndlessWaveRequired && GameClass == class'KFGameInfo_Endless' && Difficulty >= `DIFFICULTY_HARD)
		{
			FinishedObjective(FallEventIndex, ObjIdx);
		}
	}
}

defaultproperties
{
	DeathsRequired=2000
	DecapitationsRequired=600
	EndlessWaveRequired=15
	PowerUpsRequired=10
	FallEventIndex=SEI_Fall
}
