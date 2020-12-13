//=============================================================================
// KFDifficulty_FleshpoundKing
//=============================================================================
// Per Zed, per difficulty balance settings
//=============================================================================
// Killing Floor 2
// Copyright (C) 2017 Tripwire Interactive LLC
//  - Matt 'Squirrlz' Farber
//=============================================================================
class KFDifficulty_FleshpoundKing extends KFMonsterDifficultyInfo
	abstract;

/** Per-difficulty cooldown times for the chest beam */
var const protected array<float> ChestBeamCooldowns;

/** Returns the per-difficulty cooldown time */
static function float GetChestBeamCooldownTime( KFGameReplicationInfo KFGRI )
{
	return default.ChestBeamCooldowns[KFGRI.GetModifiedGameDifficulty()];
}

defaultproperties
{
	// Normal difficulty
	Normal={(HealthMod=0.630000, //0.75 //0.57
		HeadHealthMod=0.630000, //0.75 //0.57
		SprintChance=0.0,
		DamagedSprintChance=0.0,
		DamageMod=0.510000, //0.41
		SoloDamageMod=0.500000,
		BlockSettings={(Chance=0.0, Duration=1.25, MaxBlocks=2, Cooldown=4.5, DamagedHealthPctToTrigger=0.05,
							MeleeDamageModifier=0.9, DamageModifier=0.9, AfflictionModifier=0.2, SoloChanceMultiplier=0.1)},
		RallySettings={(bCanRally=false)}
	)}

	// Hard difficulty
	Hard={(HealthMod=0.830000, //0.75
		HeadHealthMod=0.830000, //0.75
		SprintChance=0.0,
		DamagedSprintChance=0.0,
		DamageMod=0.750000, //0.65 //0.85
		SoloDamageMod=0.500000,
		BlockSettings={(Chance=0.01, Duration=1.25, MaxBlocks=3, Cooldown=4.5, DamagedHealthPctToTrigger=0.05,
							MeleeDamageModifier=0.9, DamageModifier=0.9, AfflictionModifier=0.2, SoloChanceMultiplier=0.1)},
		RallySettings={(bCanRally=false)}
	)}

	// Suicidal difficulty
	Suicidal={(HealthMod=1.00000,
		HeadHealthMod=1.050000,
		//SprintChance=0.0,
		//DamagedSprintChance=0.0,
		DamageMod=1.0, 
		SoloDamageMod=0.500000,
		BlockSettings={(Chance=0.2, Duration=1.25, MaxBlocks=4, Cooldown=6.5, DamagedHealthPctToTrigger=0.05,
							MeleeDamageModifier=0.9, DamageModifier=0.9, AfflictionModifier=0.2, SoloChanceMultiplier=0.1)},
		RallySettings={(DealtDamageModifier=1.2, TakenDamageModifier=0.9)}
	)}
	
	// Hell On Earth difficulty
	HellOnEarth={(HealthMod=1.200000,
		HeadHealthMod=1.00000,
		//SprintChance=0.0,
		//DamagedSprintChance=0.0,
		DamageMod=1.2, //1.487500
		SoloDamageMod=0.650000,
		BlockSettings={(Chance=0.3, Duration=1.25, MaxBlocks=5, Cooldown=6.5, DamagedHealthPctToTrigger=0.05,
							MeleeDamageModifier=0.9, DamageModifier=0.9, AfflictionModifier=0.2, SoloChanceMultiplier=0.2)},
		RallySettings={(DealtDamageModifier=1.2, TakenDamageModifier=0.9)}
	)}

	// Body and head health scale by number of players
	NumPlayersScale_BodyHealth=0.3900000 //0.5 //0.25
	NumPlayersScale_HeadHealth=0.2800000 //0.3 //0.15

	// Chest beam attack settings
	ChestBeamCooldowns=(10.0f, 9.0f, 7.0f, 6.0f) // Normal, Hard, Suicidal, HoE

	// Versus Block settings
	BlockSettings_Versus={()}
	BlockSettings_Player_Versus=(DamageModifier=0.7, MeleeDamageModifier=0.7)

	// Versus Rally settings
	RallySettings_Versus={(bCauseSprint=false)}
	RallySettings_Player_Versus={(DealtDamageModifier=1.2)}
}