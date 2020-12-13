//=============================================================================
// KFDifficulty_BloatKing
//=============================================================================
// Bloat King variant of the Bloat difficulty settings
//=============================================================================
// Killing Floor 2
// Copyright (C) 2017 Tripwire Interactive LLC
//=============================================================================
class KFDifficulty_BloatKing extends KFDifficulty_Bloat
    abstract;


defaultproperties
{
	// Normal Difficulty
	Normal={(HealthMod=.6500, //0.7
		SprintChance=1.000000,
		DamagedSprintChance=1.000000,
		DamageMod=0.70000,
		SoloDamageMod=0.350000,
		BlockSettings={(Chance=0.0, Duration=1.25, MaxBlocks=3, Cooldown=3.5, DamagedHealthPctToTrigger=0.1,
							MeleeDamageModifier=0.3, DamageModifier=0.3, AfflictionModifier=0.2, SoloChanceMultiplier=0.1)},
		RallySettings={(bCanRally=false)}
	)}

	// Hard difficulty
	Hard={(HealthMod=0.8,
		SprintChance=1.000000,
		DamagedSprintChance=1.000000,
		DamageMod=0.850000,
		SoloDamageMod=0.42000,
		BlockSettings={(Chance=0.1, Duration=1.25, MaxBlocks=4, Cooldown=3.5, DamagedHealthPctToTrigger=0.1,
							MeleeDamageModifier=0.9, DamageModifier=0.9, AfflictionModifier=0.2, SoloChanceMultiplier=0.1)},
		RallySettings={(bCanRally=false)}
	)}

	// Suicidal difficulty
	Suicidal={(HealthMod=0.9,
		HeadHealthMod=1.00000,
		SprintChance=1.000000,
		DamagedSprintChance=1.000000,
		DamageMod=1.150000,
		SoloDamageMod=0.410000,
		BlockSettings={(Chance=0.85, Duration=1.25, MaxBlocks=5, Cooldown=3.5, DamagedHealthPctToTrigger=0.1,
							MeleeDamageModifier=0.9, DamageModifier=0.9, AfflictionModifier=0.2, SoloChanceMultiplier=1.0)},
		RallySettings={(bCauseSprint=true, DealtDamageModifier=1.1, TakenDamageModifier=0.5)} //{(bCauseSprint=true, DealtDamageModifier=1.2, TakenDamageModifier=0.9)}
	)}
	
	// Hell On Earth difficulty
	HellOnEarth={(HealthMod=1.05000,
		HeadHealthMod=1.050000,
		SprintChance=1.000000,
		DamagedSprintChance=1.000000,
		DamageMod=1.2000,
		SoloDamageMod=0.520000,
		BlockSettings={(Chance=0.85, Duration=1.25, MaxBlocks=6, Cooldown=3.5, DamagedHealthPctToTrigger=0.1,
							MeleeDamageModifier=0.9, DamageModifier=0.9, AfflictionModifier=0.2, SoloChanceMultiplier=1.0)},
		RallySettings={(bCauseSprint=true, DealtDamageModifier=1.2, TakenDamageModifier=0.5)}
	)}

		// Body and head health scale by number of players	
	NumPlayersScale_BodyHealth=0.400000 //0.5 20% reduction
	NumPlayersScale_HeadHealth=0.240000 //0.3 20% reduction

}