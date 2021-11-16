//=============================================================================
// KFSeasonalEventStats_Xmas2021
//=============================================================================
// Tracks event-specific challenges/accomplishments for Xmas 2020
//=============================================================================
// Killing Floor 2
// Copyright (C) 2021 Tripwire Interactive LLC
//=============================================================================
class KFSeasonalEventStats_Xmas2021 extends KFSeasonalEventStats;

var private int WeaponRequiredPrice;
var transient private const int DecapitationsRequired, DoshRequired, WeaponsRequired, EndlessWaveRequired;

private event Initialize(string MapName)
{
	local string CapsMapName;
	CapsMapName = Caps(MapName);

	bObjectiveIsValidForMap[0] = 1; // Decapitate 1000 Zeds on any map or mode
	bObjectiveIsValidForMap[1] = 0; // Complete the Weekly on Carillon Hamlet
	bObjectiveIsValidForMap[2] = 0; // Earn 75,000 Dosh through kills, rewards and healing on Carillon Hamlet
	bObjectiveIsValidForMap[3] = 0; // Use the trader to purchase a total of 20 weapons that cost 1500 Dosh or more on Carrion Hamlet.
	bObjectiveIsValidForMap[4] = 0; // Complete wave 15 on Endless Hard or higher difficulty on Carillon Hamlet

	if (CapsMapName == "KF-CARILLONHAMLET")
	{
		bObjectiveIsValidForMap[1] = 1;
		bObjectiveIsValidForMap[2] = 1;
		bObjectiveIsValidForMap[3] = 1;
		bObjectiveIsValidForMap[4] = 1;
	}

	SetSeasonalEventStatsMax(DecapitationsRequired, 0, DoshRequired, WeaponsRequired, 0);
}

private event GrantEventItems()
{
	if (Outer.IsEventObjectiveComplete(0) &&
		Outer.IsEventObjectiveComplete(1) &&
		Outer.IsEventObjectiveComplete(2) &&
		Outer.IsEventObjectiveComplete(3) &&
		Outer.IsEventObjectiveComplete(4))
	{
		//@TODO: Update me
		GrantEventItem(9177);
	}
}

simulated function OnZedKilledByHeadshot(class<KFPawn_Monster> MonsterClass, int Difficulty, class<DamageType> DT)
{
	local int ObjIdx;
	
	// Hellmark Station decapitate 600 zeds
	ObjIdx = 0;
	if (bObjectiveIsValidForMap[ObjIdx] != 0)
	{
		IncrementSeasonalEventStat(ObjIdx, 1);
		if (Outer.GetSeasonalEventStatValue(ObjIdx) >= DecapitationsRequired)
		{
			FinishedObjective(SEI_Winter, ObjIdx);
		}
	}
}

simulated event OnGameWon(class<GameInfo> GameClass, int Difficulty, int GameLength, bool bCoOp)
{
	local int ObjIdx;
	ObjIdx = 1;
	
	// Carillon weekly
	if (bObjectiveIsValidForMap[ObjIdx] != 0)
	{
		if (GameClass == class'KFGameInfo_WeeklySurvival')
		{
			FinishedObjective(SEI_Winter, ObjIdx);
		}
	}
}

simulated event OnGameEnd(class<GameInfo> GameClass)
{
	local int ObjIdx;
	local int TotalDoshEarned;
	
	// Earn 75,000 Dosh through kills, rewards and healing on Carillon Hamlet
	ObjIdx = 2;
	if (bObjectiveIsValidForMap[ObjIdx] != 0)
	{
		TotalDoshEarned = Outer.MyKFPC.MatchStats.TotalDoshEarned + Outer.MyKFPC.MatchStats.GetDoshEarnedInWave();
		if(TotalDoshEarned > 0)
		{
			IncrementSeasonalEventStat(ObjIdx, TotalDoshEarned);
			if (Outer.GetSeasonalEventStatValue(ObjIdx) >= DoshRequired)
			{
				FinishedObjective(SEI_Winter, ObjIdx);
			}
		}
	}
}

simulated event OnWeaponPurchased(class<KFWeaponDefinition> WeaponDef, int Price)
{
	local int ObjIdx;

	// Purchase weapons with a price >= 1500 
	ObjIdx = 3;
	if (bObjectiveIsValidForMap[ObjIdx] != 0 && Price >= WeaponRequiredPrice)
	{
		IncrementSeasonalEventStat(ObjIdx, 1);
		if (Outer.GetSeasonalEventStatValue(ObjIdx) >= WeaponsRequired)
		{
			FinishedObjective(SEI_Winter, ObjIdx);
		}
	}
}

simulated event OnWaveCompleted(class<GameInfo> GameClass, int Difficulty, int WaveNum)
{
	local int ObjIdx;

	// Complete wave 15 on Endless Hard or higher difficulty on Carillon
	ObjIdx = 4;
	if (bObjectiveIsValidForMap[ObjIdx] != 0)
	{
		if (WaveNum >= EndlessWaveRequired && GameClass == class'KFGameInfo_Endless' && Difficulty >= `DIFFICULTY_HARD)
		{
			FinishedObjective(SEI_Winter, ObjIdx);
		}
	}
}

defaultproperties
{ 
	DecapitationsRequired=1000
	DoshRequired=75000
	WeaponsRequired=20
	EndlessWaveRequired=15

	WeaponRequiredPrice=1500
}