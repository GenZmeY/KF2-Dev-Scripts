//=============================================================================
// KFDifficulty_Hans
//=============================================================================
// Per Zed, per difficulty balance settings
//=============================================================================
// Killing Floor 2
// Copyright (C) 2016 Tripwire Interactive LLC
//=============================================================================
class KFDifficulty_Hans extends KFMonsterDifficultyInfo
	abstract;

defaultproperties
{
	// Normal difficulty
	Normal={(HealthMod=0.71,
		SprintChance=1.000000,
		DamagedSprintChance=1.000000,
		DamageMod=0.540000,
		SoloDamageMod=0.400000,
		EvadeOnDamageSettings={(Chance=0.05, DamagedHealthPctToTrigger=0.01, ForcedEvadeChance=(FL=0.6, FR=0.6))},
		RallySettings={(bCanRally=false)}
	)}

	// Hard difficulty
	Hard={(HealthMod=.82,
		SprintChance=1.000000,
		DamagedSprintChance=1.000000,
		DamageMod=0.730000,
		SoloDamageMod=0.50000,
		EvadeOnDamageSettings={(Chance=0.10, DamagedHealthPctToTrigger=0.01, ForcedEvadeChance=(FL=0.6, FR=0.6))},
		RallySettings={(bCanRally=false)}		
	)}

	// Suicidal difficulty
	Suicidal={(HealthMod=.85,
		HeadHealthMod=.850000,
		SprintChance=1.000000,
		DamagedSprintChance=1.0,
		DamageMod=1.15, //1.15
		SoloDamageMod=0.40000, //0.6
		EvadeOnDamageSettings={(Chance=0.1, DamagedHealthPctToTrigger=0.01, ForcedEvadeChance=(FL=0.6, FR=0.6))},  //0.6 //0.1 try lowering evade   0.40
		BlockSettings={(Chance=0.3, Duration=1.0, MaxBlocks=5, Cooldown=7.0, DamagedHealthPctToTrigger=0.1,  //Cooldown=3.5  
							MeleeDamageModifier=0.7, DamageModifier=0.7, AfflictionModifier=0.2, SoloChanceMultiplier=1.0)},
		RallySettings={(bCanRally=false)}
	)}

	// Hell On Earth difficulty
	HellOnEarth={(HealthMod=0.91,  //1.08
		//HeadHealthMod=1.080000,
		SprintChance=1.000000,
		DamagedSprintChance=1.000000,
		DamageMod=1.18000, //1.25 4percent reduction
		SoloDamageMod=0.510000, //0.61
		EvadeOnDamageSettings={(Chance=0.1, DamagedHealthPctToTrigger=0.01, ForcedEvadeChance=(FL=0.6f, FR=0.6f))},
		BlockSettings={(Chance=0.3, Duration=1.0, MaxBlocks=6, Cooldown=6.5, DamagedHealthPctToTrigger=0.1,
							MeleeDamageModifier=0.7, DamageModifier=0.7, AfflictionModifier=0.2, SoloChanceMultiplier=1.0)},
		RallySettings={(bCanRally=false)}
	)}
	
	// Body and head health scale by number of players
	NumPlayersScale_BodyHealth=0.750000
	NumPlayersScale_BodyHealth_Versus=0.750000
}