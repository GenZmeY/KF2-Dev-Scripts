//=============================================================================
// KFDifficulty_Fleshpound
//=============================================================================
// Per Zed, per difficulty balance settings
//=============================================================================
// Killing Floor 2
// Copyright (C) 2017 Tripwire Interactive LLC
//=============================================================================
class KFDifficulty_Fleshpound extends KFMonsterDifficultyInfo
	abstract;

defaultproperties
{
	// Normal difficulty
	Normal={(HealthMod=0.750000,
		HeadHealthMod=0.750000,
		SprintChance=0.0,
		DamagedSprintChance=0.0,
		DamageMod=0.310000,
		SoloDamageMod=0.310000, //0.5
		BlockSettings={(Chance=0.0, Duration=1.25, MaxBlocks=2, Cooldown=4.5, DamagedHealthPctToTrigger=0.05,
							MeleeDamageModifier=0.9, DamageModifier=0.9, AfflictionModifier=0.2, SoloChanceMultiplier=0.1)},
		RallySettings={(bCanRally=false)}
	)}

	// Hard difficulty
	Hard={(SprintChance=0.0,
		DamagedSprintChance=0.0,
		DamageMod=0.650000,
		SoloDamageMod=0.500000,
		BlockSettings={(Chance=0.01, Duration=1.25, MaxBlocks=3, Cooldown=4.5, DamagedHealthPctToTrigger=0.05,
							MeleeDamageModifier=0.9, DamageModifier=0.9, AfflictionModifier=0.2, SoloChanceMultiplier=0.1)},
		RallySettings={(bCanRally=false)}
	)}

	// Suicidal difficulty
	Suicidal={(HealthMod=1.100000,
		HeadHealthMod=1.050000,
		SprintChance=0.0,
		DamagedSprintChance=0.0,
		DamageMod=1.125000,
		SoloDamageMod=0.500000,
		BlockSettings={(Chance=0.2, Duration=1.25, MaxBlocks=4, Cooldown=6.5, DamagedHealthPctToTrigger=0.05,
							MeleeDamageModifier=0.9, DamageModifier=0.9, AfflictionModifier=0.2, SoloChanceMultiplier=0.1)},
		RallySettings={(DealtDamageModifier=1.2, TakenDamageModifier=0.9)}
	)}

	// Hell On Earth difficulty
	HellOnEarth={(HealthMod=1.200000,
		HeadHealthMod=1.100000,
		SprintChance=0.0,
		DamagedSprintChance=0.0,
		DamageMod=1.25, //1.487500
		SoloDamageMod=0.650000,
		BlockSettings={(Chance=0.3, Duration=1.25, MaxBlocks=5, Cooldown=6.5, DamagedHealthPctToTrigger=0.05,
							MeleeDamageModifier=0.9, DamageModifier=0.9, AfflictionModifier=0.2, SoloChanceMultiplier=0.2)},
		RallySettings={(DealtDamageModifier=1.2, TakenDamageModifier=0.9)}
	)}

	// Body and head health scale by number of players
	NumPlayersScale_BodyHealth=0.3900000 //0.5 //0.25
	NumPlayersScale_HeadHealth=0.2800000 //0.3 //0.15

	// Versus Block settings
	BlockSettings_Versus={()}
	BlockSettings_Player_Versus=(DamageModifier=0.7, MeleeDamageModifier=0.7)

	// Versus Rally settings
	RallySettings_Versus={(bCauseSprint=false)}
	RallySettings_Player_Versus={(DealtDamageModifier=1.2)}

}
