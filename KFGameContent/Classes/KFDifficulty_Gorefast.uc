//=============================================================================
// KFDifficulty_Gorefast
//=============================================================================
// Per Zed, per difficulty balance settings
//=============================================================================
// Killing Floor 2
// Copyright (C) 2016 Tripwire Interactive LLC
//=============================================================================
class KFDifficulty_Gorefast extends KFMonsterDifficultyInfo
	abstract;

defaultproperties
{
	// Normal difficulty
	Normal={(HealthMod=0.750000,
		HeadHealthMod=0.750000,
		SprintChance=1.000000,
		DamagedSprintChance=1.000000,
		DamageMod=0.4,  //1
		SoloDamageMod=0.4, //0.65
		BlockSettings={(Chance=0.2, Duration=1.0, MaxBlocks=4, Cooldown=1.0, DamagedHealthPctToTrigger=0.01,
							MeleeDamageModifier=0.8, DamageModifier=0.8, AfflictionModifier=0.2, SoloChanceMultiplier=0.2)},
		RallySettings={(bCanRally=false)}
	)}

	// Hard difficulty
	Hard={(SprintChance=1.000000,
		DamagedSprintChance=1.000000,
		DamageMod=0.750000,
		SoloDamageMod=0.800000,
		BlockSettings={(Chance=0.5, Duration=1.0, MaxBlocks=4, Cooldown=1.0, DamagedHealthPctToTrigger=0.01,
							MeleeDamageModifier=0.8, DamageModifier=0.8, AfflictionModifier=0.2, SoloChanceMultiplier=0.3)},
		RallySettings={(bCanRally=false)}
	)}

	// Suicidal difficulty
	Suicidal={(SprintChance=1.000000,
		DamagedSprintChance=1.000000,
		SoloDamageMod=0.6500000,
		BlockSettings={(Chance=0.75, Duration=1.0, MaxBlocks=4, Cooldown=1.0, DamagedHealthPctToTrigger=0.01,
							MeleeDamageModifier=0.8, DamageModifier=0.8, AfflictionModifier=0.2, SoloChanceMultiplier=1.0)},
		RallySettings={(DealtDamageModifier=1.2, TakenDamageModifier=0.9)}
	)}

	// Hell On Earth difficulty
	HellOnEarth={(SprintChance=1.000000,
		DamagedSprintChance=1.000000,
		SoloDamageMod=0.6500000,
		BlockSettings={(Chance=0.85, Duration=1.0, MaxBlocks=5, Cooldown=1.0, DamagedHealthPctToTrigger=0.01,
							MeleeDamageModifier=0.8, DamageModifier=0.8, AfflictionModifier=0.2, SoloChanceMultiplier=1.0)},
		RallySettings={(bCauseSprint=true, DealtDamageModifier=1.2, TakenDamageModifier=0.9)}
	)}

	// Versus Block settings
	BlockSettings_Versus={()}
	BlockSettings_Player_Versus=(DamageModifier=0.01, MeleeDamageModifier=0.25) //(DamageModifier=0.05, MeleeDamageModifier=0.25)

	// Versus Rally settings
	RallySettings_Versus={(bCauseSprint=true)}
	RallySettings_Player_Versus={(DealtDamageModifier=1.2)}

	// Special Gorefast spawn chances
	ChanceToSpawnAsSpecial(`DIFFICULTY_Normal)		=0.10// 0.0
	ChanceToSpawnAsSpecial(`DIFFICULTY_Hard)		=0.25//0.5
	ChanceToSpawnAsSpecial(`DIFFICULTY_Suicidal)	=0.35//  0.15
	ChanceToSpawnAsSpecial(`DIFFICULTY_HellOnEarth)	=0.45
}