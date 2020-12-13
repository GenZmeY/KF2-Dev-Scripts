//=============================================================================
// KFDifficulty_Matriarch
//=============================================================================
// Per Zed, per difficulty balance settings
//=============================================================================
// Killing Floor 2
// Copyright (C) 2019 Tripwire Interactive LLC
//=============================================================================
class KFDifficulty_Matriarch extends KFMonsterDifficultyInfo
	abstract;

defaultproperties
{
	// Normal difficulty
	Normal={(HealthMod=.7,
		SprintChance=1.000000,
		DamagedSprintChance=1.000000,
		DamageMod=0.6,
		SoloDamageMod=0.37,
		RallySettings={(bCanRally=false)}
	)}

	// Hard difficulty
	Hard={(HealthMod=0.9,
		SprintChance=1.000000,
		DamagedSprintChance=1.000000,
		DamageMod=0.75,
		SoloDamageMod=0.45,
		RallySettings={(bCanRally=false)}
	)}

	// Suicidal difficulty
	Suicidal={(HealthMod=1.0,
		SprintChance=1.000000,
		DamagedSprintChance=1.000000,
		DamageMod=1.15,
		SoloDamageMod=0.4,
		RallySettings={(bCanRally=false)}
	)}

	// Hell On Earth difficulty
	HellOnEarth={(HealthMod=1.2,
		SprintChance=1.000000,
		DamagedSprintChance=1.000000,
		DamageMod=1.45,
		SoloDamageMod=0.5,
		RallySettings={(bCanRally=false)}
	)}

	// Body and head health scale by number of players
	NumPlayersScale_BodyHealth=0.5

	// Versus Body and head health scale by number of player
	NumPlayersScale_BodyHealth_Versus=0.5
}
