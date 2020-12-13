//=============================================================================
// KFSeasonalEventStats_Summer2019
//=============================================================================
// Tracks event-specific challenges/accomplishments for Summer 2019
//=============================================================================
// Killing Floor 2
// Copyright (C) 2019 Tripwire Interactive LLC
//=============================================================================
class KFSeasonalEventStats_Summer2019 extends KFSeasonalEventStats;

var transient private const int EndlessWaveRequired;

private event Initialize(string MapName)
{
	local string CapsMapName;
	CapsMapName = Caps(MapName);

	bObjectiveIsValidForMap[0] = 0; // Complete Steam Fortress on Objective Hard or higher difficulty
	bObjectiveIsValidForMap[1] = 0; // Complete the Weekly on Steam Fortress
	bObjectiveIsValidForMap[2] = 0; // Complete Steam Fortress wave 15 on Endless Hard or higher difficulty
	bObjectiveIsValidForMap[3] = 0; // Complete Zed Landing on Objective Hard or higher difficulty
	bObjectiveIsValidForMap[4] = 0; // Complete Outpost on Objective Hard or higher difficulty

	if (CapsMapName == "KF-STEAMFORTRESS")
	{
		bObjectiveIsValidForMap[0] = 1;
		bObjectiveIsValidForMap[1] = 1;
		bObjectiveIsValidForMap[2] = 1;
	}
	else if (CapsMapName == "KF-ZEDLANDING")
	{
		bObjectiveIsValidForMap[3] = 1;
	}
	else if (CapsMapName == "KF-OUTPOST")
	{
		bObjectiveIsValidForMap[4] = 1;
	}
}

private event GrantEventItems()
{
	if (Outer.IsEventObjectiveComplete(0) &&
		Outer.IsEventObjectiveComplete(1) &&
		Outer.IsEventObjectiveComplete(2) &&
		Outer.IsEventObjectiveComplete(3) &&
		Outer.IsEventObjectiveComplete(4))
	{
		GrantEventItem(7439); // Steampunk objective bundle
	}
}

simulated event OnGameWon(class<GameInfo> GameClass, int Difficulty, int GameLength, bool bCoOp)
{
	// steam fortress hard or higher
	if (bObjectiveIsValidForMap[0] != 0)
	{
		if (GameClass == class'KFGameInfo_Objective' && Difficulty >= `DIFFICULTY_HARD)
		{
			FinishedObjective(SEI_Summer, 0);
		}
	}

	// zed landing hard or higher
	if (bObjectiveIsValidForMap[3] != 0)
	{
		if (GameClass == class'KFGameInfo_Objective' && Difficulty >= `DIFFICULTY_HARD)
		{
			FinishedObjective(SEI_Summer, 3);
		}
	}

	// outpost hard or higher
	if (bObjectiveIsValidForMap[4] != 0)
	{
		if (GameClass == class'KFGameInfo_Objective' && Difficulty >= `DIFFICULTY_HARD)
		{
			FinishedObjective(SEI_Summer, 4);
		}
	}

	// steam fortress weekly
	if (bObjectiveIsValidForMap[1] != 0)
	{
		if (GameClass == class'KFGameInfo_WeeklySurvival')
		{
			FinishedObjective(SEI_Summer, 1);
		}
	}
}

simulated event OnWaveCompleted(class<GameInfo> GameClass, int Difficulty, int WaveNum)
{
	// steam fortress endless 15
	if (bObjectiveIsValidForMap[2] != 0)
	{
		if (WaveNum >= EndlessWaveRequired && GameClass == class'KFGameInfo_Endless' && Difficulty >= `DIFFICULTY_HARD)
		{
			FinishedObjective(SEI_Summer, 2);
		}
	}
}

defaultproperties
{
	EndlessWaveRequired=15
}