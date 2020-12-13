//=============================================================================
// KFAISpawnManager_Endless
//=============================================================================
// The AI Spawn Manager for the Endless Mode
//=============================================================================
// Killing Floor 2
// Copyright (C) 2017 Tripwire Interactive LLC
//=============================================================================

class KFAISpawnManager_Endless extends KFAISpawnManager
	within KFGameInfo_Endless;

struct MacroDifficultyWaveInfo
{
	var array<DifficultyWaveInfo> MacroDifficultyWaveSettings;
};

var array<MacroDifficultyWaveInfo> DifficultyWaves;

function SetupNextWave(byte NextWaveIndex, int TimeToNextWaveBuffer = 0)
{
	Super.SetupNextWave(NextWaveIndex % WaveSettings.Waves.length, TimeToNextWaveBuffer);
}

function GetAvailableSquads(byte MyWaveIndex, optional bool bNeedsSpecialSquad = false)
{
	Super.GetAvailableSquads(MyWaveIndex % WaveSettings.Waves.length, bNeedsSpecialSquad);
}

function GetWaveSettings(out DifficultyWaveInfo WaveInfo)
{
	local int AdjustedGameDifficulty;
	AdjustedGameDifficulty = EndlessDifficulty.GetCurrentDifficultyIndex();
	WaveInfo = DifficultyWaves[GameDifficulty].MacroDifficultyWaveSettings[AdjustedGameDifficulty]; //UPDATE DIFFICULTY HERE
	`log("KFAISpawnManager_Endless - Setting WaveInfo to Base Game Difficulty:" @ GameDifficulty @ "AdjustedGameDifficulty:" @ AdjustedGameDifficulty);
}

function OnDifficultyUpdated()
{
	GetWaveSettings(WaveSettings);
}

function OnBossDied()
{
	BossMinionsSpawnSquads.length = 0;
	AvailableSquads.length = 0;
}

function float GetNextSpawnTimeMod()
{
	local float SpawnTimeMod, SpawnTimeModMin;
	local int TempModIdx;

	SpawnTimeMod = super.GetNextSpawnTimeMod();

	if (MyKFGRI.IsSpecialWave(TempModIdx))
	{
		SpawnTimeModMin = EndlessDifficulty.GetSpecialWaveSpawnTimeModMin(SpecialWaveType);
		SpawnTimeMod = Max(SpawnTimeMod, SpawnTimeModMin);
	}

	return SpawnTimeMod;
}

defaultproperties
{
	// Normal
	DifficultyWaves(0) = {(
		// Normal
		MacroDifficultyWaveSettings[0] = {(
			Waves[0] = KFAIWaveInfo'GP_Spawning_ARCH.Endless.Norm.ZED_Wave1_Endless_Norm',
			Waves[1] = KFAIWaveInfo'GP_Spawning_ARCH.Endless.Norm.ZED_Wave2_Endless_Norm',
			Waves[2] = KFAIWaveInfo'GP_Spawning_ARCH.Endless.Norm.ZED_Wave3_Endless_Norm',
			Waves[3] = KFAIWaveInfo'GP_Spawning_ARCH.Endless.Norm.ZED_Wave4_Endless_Norm',
			Waves[4] = KFAIWaveInfo'GP_Spawning_ARCH.Endless.Norm.ZED_Boss_Endless_Norm'
		)},
		// Hard
		MacroDifficultyWaveSettings[1] = {(
			Waves[0] = KFAIWaveInfo'GP_Spawning_ARCH.Endless.Hard.ZED_Wave5_Endless_Hard',
			Waves[1] = KFAIWaveInfo'GP_Spawning_ARCH.Endless.Hard.ZED_Wave6_Endless_Hard',
			Waves[2] = KFAIWaveInfo'GP_Spawning_ARCH.Endless.Hard.ZED_Wave7_Endless_Hard',
			Waves[3] = KFAIWaveInfo'GP_Spawning_ARCH.Endless.Hard.ZED_Wave8_Endless_Hard',
			Waves[4] = KFAIWaveInfo'GP_Spawning_ARCH.Endless.Hard.ZED_Boss_Endless_Hard'
		)},
		// Suicidal
		MacroDifficultyWaveSettings[2] = {(
			Waves[0] = KFAIWaveInfo'GP_Spawning_ARCH.Endless.Suicidal.ZED_Wave9_Endless_SUI',
			Waves[1] = KFAIWaveInfo'GP_Spawning_ARCH.Endless.Suicidal.ZED_Wave10_Endless_SUI',
			Waves[2] = KFAIWaveInfo'GP_Spawning_ARCH.Endless.Suicidal.ZED_Wave10_Endless_SUI',
			Waves[3] = KFAIWaveInfo'GP_Spawning_ARCH.Endless.Suicidal.ZED_Wave10_Endless_SUI',
			Waves[4] = KFAIWaveInfo'GP_Spawning_ARCH.Endless.Suicidal.ZED_Boss_Endless_SUI'
		)},
		// Hell on Earth
		MacroDifficultyWaveSettings[3] = {(
			Waves[0] = KFAIWaveInfo'GP_Spawning_ARCH.Endless.HOE.ZED_Wave10_Endless_HOE',
			Waves[1] = KFAIWaveInfo'GP_Spawning_ARCH.Endless.HOE.ZED_Wave10_Endless_HOE',
			Waves[2] = KFAIWaveInfo'GP_Spawning_ARCH.Endless.HOE.ZED_Wave10_Endless_HOE',
			Waves[3] = KFAIWaveInfo'GP_Spawning_ARCH.Endless.HOE.ZED_Wave10_Endless_HOE',
			Waves[4] = KFAIWaveInfo'GP_Spawning_ARCH.Endless.HOE.ZED_Boss_Endless_HOE'
		)},
		// Hell on Earth Plus
		MacroDifficultyWaveSettings[4] = {(
			Waves[0] = KFAIWaveInfo'GP_Spawning_ARCH.Endless.HOE.ZED_Wave10_Endless_HOE',
			Waves[1] = KFAIWaveInfo'GP_Spawning_ARCH.Endless.HOE.ZED_Wave10_Endless_HOE',
			Waves[2] = KFAIWaveInfo'GP_Spawning_ARCH.Endless.HOE.ZED_Wave10_Endless_HOE',
			Waves[3] = KFAIWaveInfo'GP_Spawning_ARCH.Endless.HOE.ZED_Wave10_Endless_HOE',
			Waves[4] = KFAIWaveInfo'GP_Spawning_ARCH.Endless.HOE.ZED_Boss_Endless_HOE'
		)}
	)}

	// Hard
	DifficultyWaves(1)={(
		// Normal
		MacroDifficultyWaveSettings[0] = {(
			Waves[0] = KFAIWaveInfo'GP_Spawning_ARCH.Endless.Norm.ZED_Wave1_Endless_Norm',
			Waves[1] = KFAIWaveInfo'GP_Spawning_ARCH.Endless.Norm.ZED_Wave2_Endless_Norm',
			Waves[2] = KFAIWaveInfo'GP_Spawning_ARCH.Endless.Norm.ZED_Wave3_Endless_Norm',
			Waves[3] = KFAIWaveInfo'GP_Spawning_ARCH.Endless.Norm.ZED_Wave4_Endless_Norm',
			Waves[4] = KFAIWaveInfo'GP_Spawning_ARCH.Endless.Norm.ZED_Boss_Endless_Norm'
		)},
		// Hard
		MacroDifficultyWaveSettings[1] = {(
			Waves[0] = KFAIWaveInfo'GP_Spawning_ARCH.Endless.Hard.ZED_Wave5_Endless_Hard',
			Waves[1] = KFAIWaveInfo'GP_Spawning_ARCH.Endless.Hard.ZED_Wave6_Endless_Hard',
			Waves[2] = KFAIWaveInfo'GP_Spawning_ARCH.Endless.Hard.ZED_Wave7_Endless_Hard',
			Waves[3] = KFAIWaveInfo'GP_Spawning_ARCH.Endless.Hard.ZED_Wave8_Endless_Hard',
			Waves[4] = KFAIWaveInfo'GP_Spawning_ARCH.Endless.Hard.ZED_Boss_Endless_Hard'
		)},
		// Suicidal
		MacroDifficultyWaveSettings[2] = {(
			Waves[0] = KFAIWaveInfo'GP_Spawning_ARCH.Endless.Suicidal.ZED_Wave9_Endless_SUI',
			Waves[1] = KFAIWaveInfo'GP_Spawning_ARCH.Endless.Suicidal.ZED_Wave10_Endless_SUI',
			Waves[2] = KFAIWaveInfo'GP_Spawning_ARCH.Endless.Suicidal.ZED_Wave10_Endless_SUI',
			Waves[3] = KFAIWaveInfo'GP_Spawning_ARCH.Endless.Suicidal.ZED_Wave10_Endless_SUI',
			Waves[4] = KFAIWaveInfo'GP_Spawning_ARCH.Endless.Suicidal.ZED_Boss_Endless_SUI'
		)},
		// Hell on Earth
		MacroDifficultyWaveSettings[3] = {(
			Waves[0] = KFAIWaveInfo'GP_Spawning_ARCH.Endless.HOE.ZED_Wave10_Endless_HOE',
			Waves[1] = KFAIWaveInfo'GP_Spawning_ARCH.Endless.HOE.ZED_Wave10_Endless_HOE',
			Waves[2] = KFAIWaveInfo'GP_Spawning_ARCH.Endless.HOE.ZED_Wave10_Endless_HOE',
			Waves[3] = KFAIWaveInfo'GP_Spawning_ARCH.Endless.HOE.ZED_Wave10_Endless_HOE',
			Waves[4] = KFAIWaveInfo'GP_Spawning_ARCH.Endless.HOE.ZED_Boss_Endless_HOE'
		)},
		// Hell on Earth Plus
		MacroDifficultyWaveSettings[4] = {(
			Waves[0] = KFAIWaveInfo'GP_Spawning_ARCH.Endless.HOE.ZED_Wave10_Endless_HOE',
			Waves[1] = KFAIWaveInfo'GP_Spawning_ARCH.Endless.HOE.ZED_Wave10_Endless_HOE',
			Waves[2] = KFAIWaveInfo'GP_Spawning_ARCH.Endless.HOE.ZED_Wave10_Endless_HOE',
			Waves[3] = KFAIWaveInfo'GP_Spawning_ARCH.Endless.HOE.ZED_Wave10_Endless_HOE',
			Waves[4] = KFAIWaveInfo'GP_Spawning_ARCH.Endless.HOE.ZED_Boss_Endless_HOE'
		)}
	)}

	// Suicidal
	DifficultyWaves(2)={(
		// Normal
		MacroDifficultyWaveSettings[0] = {(
			Waves[0] = KFAIWaveInfo'GP_Spawning_ARCH.Endless.Norm.ZED_Wave1_Endless_Norm',
			Waves[1] = KFAIWaveInfo'GP_Spawning_ARCH.Endless.Norm.ZED_Wave2_Endless_Norm',
			Waves[2] = KFAIWaveInfo'GP_Spawning_ARCH.Endless.Norm.ZED_Wave3_Endless_Norm',
			Waves[3] = KFAIWaveInfo'GP_Spawning_ARCH.Endless.Norm.ZED_Wave4_Endless_Norm',
			Waves[4] = KFAIWaveInfo'GP_Spawning_ARCH.Endless.Norm.ZED_Boss_Endless_Norm'
		)},
		// Hard
		MacroDifficultyWaveSettings[1] = {(
			Waves[0] = KFAIWaveInfo'GP_Spawning_ARCH.Endless.Hard.ZED_Wave5_Endless_Hard',
			Waves[1] = KFAIWaveInfo'GP_Spawning_ARCH.Endless.Hard.ZED_Wave6_Endless_Hard',
			Waves[2] = KFAIWaveInfo'GP_Spawning_ARCH.Endless.Hard.ZED_Wave7_Endless_Hard',
			Waves[3] = KFAIWaveInfo'GP_Spawning_ARCH.Endless.Hard.ZED_Wave8_Endless_Hard',
			Waves[4] = KFAIWaveInfo'GP_Spawning_ARCH.Endless.Hard.ZED_Boss_Endless_Hard'
		)},
		// Suicidal
		MacroDifficultyWaveSettings[2] = {(
			Waves[0] = KFAIWaveInfo'GP_Spawning_ARCH.Endless.Suicidal.ZED_Wave9_Endless_SUI',
			Waves[1] = KFAIWaveInfo'GP_Spawning_ARCH.Endless.Suicidal.ZED_Wave10_Endless_SUI',
			Waves[2] = KFAIWaveInfo'GP_Spawning_ARCH.Endless.Suicidal.ZED_Wave10_Endless_SUI',
			Waves[3] = KFAIWaveInfo'GP_Spawning_ARCH.Endless.Suicidal.ZED_Wave10_Endless_SUI',
			Waves[4] = KFAIWaveInfo'GP_Spawning_ARCH.Endless.Suicidal.ZED_Boss_Endless_SUI'
		)},
		// Hell on Earth
		MacroDifficultyWaveSettings[3] = {(
			Waves[0] = KFAIWaveInfo'GP_Spawning_ARCH.Endless.HOE.ZED_Wave10_Endless_HOE',
			Waves[1] = KFAIWaveInfo'GP_Spawning_ARCH.Endless.HOE.ZED_Wave10_Endless_HOE',
			Waves[2] = KFAIWaveInfo'GP_Spawning_ARCH.Endless.HOE.ZED_Wave10_Endless_HOE',
			Waves[3] = KFAIWaveInfo'GP_Spawning_ARCH.Endless.HOE.ZED_Wave10_Endless_HOE',
			Waves[4] = KFAIWaveInfo'GP_Spawning_ARCH.Endless.HOE.ZED_Boss_Endless_HOE'
		)},
		// Hell on Earth Plus
		MacroDifficultyWaveSettings[4] = {(
			Waves[0] = KFAIWaveInfo'GP_Spawning_ARCH.Endless.HOE.ZED_Wave10_Endless_HOE',
			Waves[1] = KFAIWaveInfo'GP_Spawning_ARCH.Endless.HOE.ZED_Wave10_Endless_HOE',
			Waves[2] = KFAIWaveInfo'GP_Spawning_ARCH.Endless.HOE.ZED_Wave10_Endless_HOE',
			Waves[3] = KFAIWaveInfo'GP_Spawning_ARCH.Endless.HOE.ZED_Wave10_Endless_HOE',
			Waves[4] = KFAIWaveInfo'GP_Spawning_ARCH.Endless.HOE.ZED_Boss_Endless_HOE'
		)}
	)}

	// Hell On Earth
	DifficultyWaves(3)={(
		// Normal
		MacroDifficultyWaveSettings[0] = {(
			Waves[0] = KFAIWaveInfo'GP_Spawning_ARCH.Endless.HOE.ZED_Wave2_Endless_HOE',
			Waves[1] = KFAIWaveInfo'GP_Spawning_ARCH.Endless.HOE.ZED_Wave3_Endless_HOE',
			Waves[2] = KFAIWaveInfo'GP_Spawning_ARCH.Endless.HOE.ZED_Wave4_Endless_HOE',
			Waves[3] = KFAIWaveInfo'GP_Spawning_ARCH.Endless.HOE.ZED_Wave5_Endless_HOE',
			Waves[4] = KFAIWaveInfo'GP_Spawning_ARCH.Endless.HOE.ZED_Boss_Endless_HOE'
		)},
		// Hard
		MacroDifficultyWaveSettings[1] = {(
			Waves[0] = KFAIWaveInfo'GP_Spawning_ARCH.Endless.HOE.ZED_Wave6_Endless_HOE',
			Waves[1] = KFAIWaveInfo'GP_Spawning_ARCH.Endless.HOE.ZED_Wave7_Endless_HOE',
			Waves[2] = KFAIWaveInfo'GP_Spawning_ARCH.Endless.HOE.ZED_Wave8_Endless_HOE',
			Waves[3] = KFAIWaveInfo'GP_Spawning_ARCH.Endless.HOE.ZED_Wave9_Endless_HOE',
			Waves[4] = KFAIWaveInfo'GP_Spawning_ARCH.Endless.HOE.ZED_Boss_Endless_HOE'
		)},
		// Suicidal
		MacroDifficultyWaveSettings[2] = {(
			Waves[0] = KFAIWaveInfo'GP_Spawning_ARCH.Endless.HOE.ZED_Wave10_Endless_HOE',
			Waves[1] = KFAIWaveInfo'GP_Spawning_ARCH.Endless.HOE.ZED_Wave10_Endless_HOE',
			Waves[2] = KFAIWaveInfo'GP_Spawning_ARCH.Endless.HOE.ZED_Wave10_Endless_HOE',
			Waves[3] = KFAIWaveInfo'GP_Spawning_ARCH.Endless.HOE.ZED_Wave10_Endless_HOE',
			Waves[4] = KFAIWaveInfo'GP_Spawning_ARCH.Endless.HOE.ZED_Boss_Endless_HOE'
		)},
		// Hell on Earth
		MacroDifficultyWaveSettings[3] = {(
			Waves[0] = KFAIWaveInfo'GP_Spawning_ARCH.Endless.HOE.ZED_Wave10_Endless_HOE',
			Waves[1] = KFAIWaveInfo'GP_Spawning_ARCH.Endless.HOE.ZED_Wave10_Endless_HOE',
			Waves[2] = KFAIWaveInfo'GP_Spawning_ARCH.Endless.HOE.ZED_Wave10_Endless_HOE',
			Waves[3] = KFAIWaveInfo'GP_Spawning_ARCH.Endless.HOE.ZED_Wave10_Endless_HOE',
			Waves[4] = KFAIWaveInfo'GP_Spawning_ARCH.Endless.HOE.ZED_Boss_Endless_HOE'
		)},
		// Hell on Earth Plus
		MacroDifficultyWaveSettings[4] = {(
			Waves[0] = KFAIWaveInfo'GP_Spawning_ARCH.Endless.HOE.ZED_Wave10_Endless_HOE',
			Waves[1] = KFAIWaveInfo'GP_Spawning_ARCH.Endless.HOE.ZED_Wave10_Endless_HOE',
			Waves[2] = KFAIWaveInfo'GP_Spawning_ARCH.Endless.HOE.ZED_Wave10_Endless_HOE',
			Waves[3] = KFAIWaveInfo'GP_Spawning_ARCH.Endless.HOE.ZED_Wave10_Endless_HOE',
			Waves[4] = KFAIWaveInfo'GP_Spawning_ARCH.Endless.HOE.ZED_Boss_Endless_HOE'
		)}
	)}
}
