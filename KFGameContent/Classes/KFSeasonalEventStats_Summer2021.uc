//=============================================================================
// KFSeasonalEventStats_Summer2021
//=============================================================================
// Tracks event-specific challenges/accomplishments for Summer 2021
//=============================================================================
// Killing Floor 2
// Copyright (C) 2021 Tripwire Interactive LLC
//=============================================================================
class KFSeasonalEventStats_Summer2021 extends KFSeasonalEventStats;

var transient private const int ZedsStompRequired, LaserKillsRequired, JumpKillsRequired, EndlessWaveRequired;

private event Initialize(string MapName)
{
	local string CapsMapName;
	CapsMapName = Caps(MapName);

	bObjectiveIsValidForMap[0] = 1; // Stomp on 50 Zeds
	bObjectiveIsValidForMap[1] = 0; // Complete the Weekly on Moonbase
	bObjectiveIsValidForMap[2] = 0; // Use the laser trap to kill 20 Zeds on Moonbase
	bObjectiveIsValidForMap[3] = 0; // Kill 300 Zeds while jumping in the air on Moonbase
	bObjectiveIsValidForMap[4] = 0; // Complete wave 15 on Endless Hard or higher difficulty on Moonbase

	if (CapsMapName == "KF-MOONBASE")
	{
		bObjectiveIsValidForMap[1] = 1;
		bObjectiveIsValidForMap[2] = 1;
		bObjectiveIsValidForMap[3] = 1;
		bObjectiveIsValidForMap[4] = 1;
	}

	SetSeasonalEventStatsMax(ZedsStompRequired, 0, LaserKillsRequired, JumpKillsRequired, 0);
}

private event GrantEventItems()
{
	if (Outer.IsEventObjectiveComplete(0) &&
		Outer.IsEventObjectiveComplete(1) &&
		Outer.IsEventObjectiveComplete(2) &&
		Outer.IsEventObjectiveComplete(3) &&
		Outer.IsEventObjectiveComplete(4))
	{
		// @TODO: Set Proper Reward ID
		// 
		GrantEventItem(8844);
	}
}

simulated event OnGameWon(class<GameInfo> GameClass, int Difficulty, int GameLength, bool bCoOp)
{
	// Moonbase weekly
	if (bObjectiveIsValidForMap[1] != 0)
	{
		if (GameClass == class'KFGameInfo_WeeklySurvival')
		{
			FinishedObjective(SEI_Summer, 1);
		}
	}
}

simulated function OnZedKilled(class<KFPawn_Monster> MonsterClass, int Difficulty, class<DamageType> DT, bool bKiller)
{
	local int ObjIdx;
	local KFPlayerController KFPC;
	local KFPawn_Human KFP;

	if (bKiller == false)
	{
		return;
	}

	// Laser Kills
	ObjIdx = 2;
	if (bObjectiveIsValidForMap[ObjIdx] != 0)
	{
		if (ClassIsChildOf(DT, class'KFDT_EMPTrap'))
		{
			IncrementSeasonalEventStat(ObjIdx, 1);
			if (Outer.GetSeasonalEventStatValue(ObjIdx) >= LaserKillsRequired)
			{
				FinishedObjective(SEI_SUMMER, ObjIdx);
			}
		}
	}

	ObjIdx = 3;
	if (bObjectiveIsValidForMap[ObjIdx] != 0)
	{
		KFPC = Outer.MyKFPC;
		if (KFPC != none)
		{
			KFP = KFPawn_Human(KFPC.Pawn);
			if (KFP != none && KFP.Physics == PHYS_Falling)
			{
				IncrementSeasonalEventStat(ObjIdx, 1);
				if (Outer.GetSeasonalEventStatValue(ObjIdx) >= JumpKillsRequired)
				{
					FinishedObjective(SEI_SUMMER, ObjIdx);
				}	
			}
		}
	}
}

simulated function OnHitGiven(class<DamageType> DT)
{
	local int ObjIdx;
	ObjIdx = 0;

	// Stomps
	if (ClassIsChildOf(DT, class'DmgType_Crushed'))
	{
		IncrementSeasonalEventStat(ObjIdx, 1);
		if (Outer.GetSeasonalEventStatValue(ObjIdx) >= ZedsStompRequired)
		{
			FinishedObjective(SEI_SUMMER, ObjIdx);
		}
	}
}

simulated event OnWaveCompleted(class<GameInfo> GameClass, int Difficulty, int WaveNum)
{
	local int ObjIdx;

	//  Waves in Endless hard
	ObjIdx = 4;
	if (bObjectiveIsValidForMap[ObjIdx] != 0)
	{
		if (WaveNum >= EndlessWaveRequired && GameClass == class'KFGameInfo_Endless' && Difficulty >= `DIFFICULTY_HARD)
		{
			FinishedObjective(SEI_Summer, ObjIdx);
		}
	}
}

defaultproperties
{
	ZedsStompRequired=50
	LaserKillsRequired=20
	JumpKillsRequired=300	
	EndlessWaveRequired=15
}
