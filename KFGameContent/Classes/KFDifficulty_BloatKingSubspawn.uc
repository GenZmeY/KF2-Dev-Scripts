//=============================================================================
// KFDifficulty_BloatKingSubspawn
//=============================================================================
// Poop monster difficulty
//=============================================================================
// Killing Floor 2
// Copyright (C) 2017 Tripwire Interactive LLC
//=============================================================================
class KFDifficulty_BloatKingSubspawn extends KFMonsterDifficultyInfo
	abstract;

defaultproperties
{
	// Normal difficulty
	Normal={(HealthMod=0.35000, //0.76 //0.2
		HeadHealthMod=0.50000, //0.85
		DamageMod=0.20000, //0.65
		EvadeOnDamageSettings={(Chance=0.0, DamagedHealthPctToTrigger=0.01)},
		RallySettings={(bCanRally=false)}
	)}

	// Hard difficulty
	Hard={(DamagedSprintChance=0.010000,
		HealthMod=0.95,
		DamageMod=0.750000,
		MovementSpeedMod=1.1,
		EvadeOnDamageSettings={(Chance=0.0, DamagedHealthPctToTrigger=0.01)},
		RallySettings={(bCanRally=false)}
	)}
	
	// Suicidal difficulty
	Suicidal={(SprintChance=0.85,  //0.5
		DamagedSprintChance=1.000000,
		MovementSpeedMod=1.25,
		EvadeOnDamageSettings={(Chance=0.0, DamagedHealthPctToTrigger=0.01)},
		RallySettings={(DealtDamageModifier=1.2, TakenDamageModifier=0.9)}
	)}

	// Hell On Earth difficulty
	HellOnEarth={(SprintChance=1.0,
		HealthMod=1.0,
		DamagedSprintChance=1.0,
		MovementSpeedMod=1.25,
		EvadeOnDamageSettings={(Chance=0.0, DamagedHealthPctToTrigger=0.01)},
		RallySettings={(bCauseSprint=true, DealtDamageModifier=1.2, TakenDamageModifier=0.9)}
	)}

	// Versus Rally settings
	RallySettings_Versus={(bCauseSprint=true)}
	RallySettings_Player_Versus={(DealtDamageModifier=1.2)}
}