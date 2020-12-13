//=============================================================================
// KFDifficulty_GorefastDualBlade
//=============================================================================
// Per Zed, per difficulty balance settings
//=============================================================================
// Killing Floor 2
// Copyright (C) 2016 Tripwire Interactive LLC
//=============================================================================
class KFDifficulty_GorefastDualBlade extends KFDifficulty_Gorefast
	abstract;

defaultproperties
{
	//defaults
		// Normal difficulty
	Normal={(HealthMod=0.750000,
		HeadHealthMod=0.750000,
		SprintChance=1.000000,
		DamagedSprintChance=1.000000,
		DamageMod=0.4,  //1.0
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
		BlockSettings={(Chance=0.6, Duration=1.0, MaxBlocks=4, Cooldown=1.0, DamagedHealthPctToTrigger=0.01,   //0.75
							MeleeDamageModifier=0.8, DamageModifier=0.8, AfflictionModifier=0.2, SoloChanceMultiplier=1.0)},
		RallySettings={(DealtDamageModifier=1.2, TakenDamageModifier=0.9)}
	)}

	// Hell On Earth difficulty
	HellOnEarth={(SprintChance=1.000000,
		DamagedSprintChance=1.000000,
		SoloDamageMod=0.6500000,
		BlockSettings={(Chance=0.6, Duration=1.0, MaxBlocks=5, Cooldown=1.0, DamagedHealthPctToTrigger=0.01,     //0.85
							MeleeDamageModifier=0.8, DamageModifier=0.8, AfflictionModifier=0.2, SoloChanceMultiplier=1.0)},
		RallySettings={(bCauseSprint=true, DealtDamageModifier=1.2, TakenDamageModifier=0.9)}
	)}
}