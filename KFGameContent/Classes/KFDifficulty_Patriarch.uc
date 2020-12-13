//=============================================================================
// KFDifficulty_Patriarch
//=============================================================================
// Per Zed, per difficulty balance settings
//=============================================================================
// Killing Floor 2
// Copyright (C) 2016 Tripwire Interactive LLC
//=============================================================================
class KFDifficulty_Patriarch extends KFMonsterDifficultyInfo
	abstract;

defaultproperties
{
	// Normal difficulty
	Normal={(HealthMod=.75000,
		SprintChance=1.000000,
		DamagedSprintChance=1.000000,
		DamageMod=0.670000,
		SoloDamageMod=0.350000,
		RallySettings={(bCanRally=false)}
	)}

	// Hard difficulty
	Hard={(HealthMod=1.000000,
		SprintChance=1.000000,
		DamagedSprintChance=1.000000,
		DamageMod=0.810000,
		SoloDamageMod=0.42000,

		RallySettings={(bCanRally=false)}
	)}

	// Suicidal difficulty
	Suicidal={(HealthMod=1.130000,
		HeadHealthMod=1.130000,
		SprintChance=1.000000,
		DamagedSprintChance=1.000000,
		DamageMod=1.470000,
		SoloDamageMod=0.410000,
		BlockSettings={(Chance=0.85, Duration=1.25, MaxBlocks=5, Cooldown=3.5, DamagedHealthPctToTrigger=0.1,
							MeleeDamageModifier=0.9, DamageModifier=0.9, AfflictionModifier=0.2, SoloChanceMultiplier=1.0)},

		RallySettings={(bCanRally=false)}
	)}

	// Hell On Earth difficulty
	HellOnEarth={(HealthMod=1.39000,
		HeadHealthMod=1.390000,
		SprintChance=1.000000,
		DamagedSprintChance=1.000000,
		DamageMod=1.450000,
		SoloDamageMod=0.520000,
		BlockSettings={(Chance=0.85, Duration=1.25, MaxBlocks=6, Cooldown=3.5, DamagedHealthPctToTrigger=0.1,
							MeleeDamageModifier=0.9, DamageModifier=0.9, AfflictionModifier=0.2, SoloChanceMultiplier=1.0)},

		RallySettings={(bCanRally=false)}
	)}
	
	// Body and head health scale by number of players	
	NumPlayersScale_BodyHealth=0.500000
	NumPlayersScale_HeadHealth=0.300000

	// Versus Body and head health scale by number of player
	NumPlayersScale_BodyHealth_Versus=0.500000
	NumPlayersScale_HeadHealth_Versus=0.300000
}
