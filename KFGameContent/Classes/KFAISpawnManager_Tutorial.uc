//=============================================================================
// KFAISpawnManager_Tutorial
//=============================================================================
// The KFAISpawnManager for a tutorial game
//=============================================================================
// Killing Floor 2
// Copyright (C) 2016 Tripwire Interactive LLC
//=============================================================================
class KFAISpawnManager_Tutorial extends KFAISpawnManager;

DefaultProperties
{
    EarlyWaveIndex=2

	// ---------------------------------------------
	// Wave settings
    DifficultyWaveSettings(0)={(Waves[0]=KFAIWaveInfo'GP_Spawning_ARCH.Short.ZED_Wave1',
							    Waves[1]=KFAIWaveInfo'GP_Spawning_ARCH.Short.ZED_Wave2',
							    // Dummy entry because survival assumes we have a boss wave for the HUD wave counter
						    	Waves[2]=None)}



    // Normal
    SoloWaveSpawnRateModifier(0)={(RateModifier[0]=1.5,     // Wave 1
                                   RateModifier[1]=1.5)}    // Wave 2
}
