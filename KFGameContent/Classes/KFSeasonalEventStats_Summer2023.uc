//=============================================================================
// KFSeasonalEventStats_Summer2023
//=============================================================================
// Tracks event-specific challenges/accomplishments for Summer 2023
//=============================================================================
// Killing Floor 2
// Copyright (C) 2022 Tripwire Interactive LLC
//=============================================================================
class KFSeasonalEventStats_Summer2023 extends KFSeasonalEventStats;

var transient private const int HRGBombardierZedsRequired, EMPRequired, StandYourGroundRequired, EndlessWaveRequired, SummerEventIndex;

private event Initialize(string MapName)
{
	local string CapsMapName;
	CapsMapName = Caps(MapName);

	bObjectiveIsValidForMap[0] = 1; // Kill 1500 Zeds with HRG Bombardier
	bObjectiveIsValidForMap[1] = 0; // Complete the Weekly on Subduction
	bObjectiveIsValidForMap[2] = 1; // Stun 2500 Zeds with EMP affliction
	bObjectiveIsValidForMap[3] = 1; // Complete 25 Stand your Ground objectives
	bObjectiveIsValidForMap[4] = 0; // Complete wave 15 on Endless Hard or higher difficulty on Subduction
	
	if (CapsMapName == "KF-SUBDUCTION")
	{
		bObjectiveIsValidForMap[1] = 1;
		bObjectiveIsValidForMap[4] = 1;
	}

	SetSeasonalEventStatsMax(HRGBombardierZedsRequired, 0, EMPRequired, StandYourGroundRequired, 0);
}

private event GrantEventItems()
{
	if (Outer.IsEventObjectiveComplete(0) &&
		Outer.IsEventObjectiveComplete(1) &&
		Outer.IsEventObjectiveComplete(2) &&
		Outer.IsEventObjectiveComplete(3) &&
		Outer.IsEventObjectiveComplete(4))
	{
		// TODO
		GrantEventItem(9672);
	}
}

simulated event OnGameWon(class<GameInfo> GameClass, int Difficulty, int GameLength, bool bCoOp)
{
	local int ObjIdx;
	
	// Complete the Weekly on Subduction
	ObjIdx = 1;
	
	if (bObjectiveIsValidForMap[ObjIdx] != 0)
	{
		if (GameClass == class'KFGameInfo_WeeklySurvival')
		{
			FinishedObjective(SummerEventIndex, ObjIdx);
		}
	}
}

simulated function OnTryCompleteObjective(int ObjectiveIndex, int EventIndex)
{
	local int HRGBombardierIdx, EMPIdx, StandYourGroundIdx, ObjectiveLimit;
	local bool bValidIdx;

	HRGBombardierIdx = 0;
	EMPIdx = 2;
	StandYourGroundIdx = 3;

	bValidIdx = false;

	if (EventIndex == SummerEventIndex)
	{
		if (ObjectiveIndex == HRGBombardierIdx)
		{
			ObjectiveLimit = HRGBombardierZedsRequired;
			bValidIdx = true;
		}
		else if (ObjectiveIndex == EMPIdx)
		{
			ObjectiveLimit = EMPRequired;
			bValidIdx = true;
		}
		else if (ObjectiveIndex == StandYourGroundIdx)
		{
			ObjectiveLimit = StandYourGroundRequired;
			bValidIdx = true;
		}
		
		if (bValidIdx && bObjectiveIsValidForMap[ObjectiveIndex] != 0)
		{
			IncrementSeasonalEventStat(ObjectiveIndex, 1);

			if (Outer.GetSeasonalEventStatValue(ObjectiveIndex) >= ObjectiveLimit)
			{
				FinishedObjective(SummerEventIndex, ObjectiveIndex);
			}
		}
	}
}

simulated event OnWaveCompleted(class<GameInfo> GameClass, int Difficulty, int WaveNum)
{
	local int ObjIdx;

	// Complete wave 15 on Endless Hard or higher difficulty on Subduction
	ObjIdx = 4;

	if (bObjectiveIsValidForMap[ObjIdx] != 0)
	{
		if (WaveNum >= EndlessWaveRequired && GameClass == class'KFGameInfo_Endless' && Difficulty >= `DIFFICULTY_HARD)
		{
			FinishedObjective(SummerEventIndex, ObjIdx);
		}
	}
}

simulated function OnAfflictionCaused(EAfflictionType Type)
{
	local int ObjIdx;

	// Stun 2500 Zeds with EMP affliction
	ObjIdx = 2;

	if (bObjectiveIsValidForMap[ObjIdx] != 0)
	{
		if (Type == AF_EMP)
		{
			IncrementSeasonalEventStat(ObjIdx, 1);

			if (Outer.GetSeasonalEventStatValue(ObjIdx) >= EMPRequired)
			{
				FinishedObjective(SummerEventIndex, ObjIdx);
			}
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

	// Kill 1500 Zeds with HRG Bombardier
	ObjIdx = 0;
	if (bObjectiveIsValidForMap[ObjIdx] != 0)
	{
		if (DT == class'KFDT_Explosive_HRG_Warthog' || 
		    DT == class'KFDT_Explosive_HRG_Warthog_HighExplosive' ||
			DT == class'KFDT_Ballistic_HRG_Warthog')
		{
			IncrementSeasonalEventStat(ObjIdx, 1);

			if (Outer.GetSeasonalEventStatValue(ObjIdx) >= HRGBombardierZedsRequired)
			{
				FinishedObjective(SummerEventIndex, ObjIdx);
			}
		}
	}
}


defaultproperties
{
	HRGBombardierZedsRequired=1500
	EMPRequired=2500
	StandYourGroundRequired=25
	EndlessWaveRequired=15
	SummerEventIndex=SEI_Summer
}
