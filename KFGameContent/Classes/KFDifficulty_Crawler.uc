//=============================================================================
// KFDifficulty_Crawler
//=============================================================================
// Per Zed, per difficulty balance settings
//=============================================================================
// Killing Floor 2
// Copyright (C) 2016 Tripwire Interactive LLC
//=============================================================================
class KFDifficulty_Crawler extends KFMonsterDifficultyInfo
	abstract;

defaultproperties
{
	// Normal difficulty
	Normal={(HealthMod=0.750000,
		HeadHealthMod=0.750000,
		EvadeOnDamageSettings={(Chance=0.1, DamagedHealthPctToTrigger=0.01)},
		RallySettings={(bCanRally=false)}
	)}

	// Hard difficulty
	Hard={(DamagedSprintChance=0.010000,
		DamageMod=0.750000,
		EvadeOnDamageSettings={(Chance=0.4, DamagedHealthPctToTrigger=0.01)},
		RallySettings={(bCanRally=false)}
	)}

	// Suicidal difficulty
	Suicidal={(SprintChance=0.85,  //0.5
		DamagedSprintChance=1.000000,
		MovementSpeedMod=1.3,
		EvadeOnDamageSettings={(Chance=1.0, DamagedHealthPctToTrigger=0.01)},
		RallySettings={(DealtDamageModifier=1.2, TakenDamageModifier=0.9)}
	)}

	// Hell On Earth difficulty
	HellOnEarth={(SprintChance=1.0,
		DamagedSprintChance=1.0,
		MovementSpeedMod=1.4,
		EvadeOnDamageSettings={(Chance=1.0, DamagedHealthPctToTrigger=0.01)},
		RallySettings={(bCauseSprint=true, DealtDamageModifier=1.2, TakenDamageModifier=0.9)}
	)}

	// Versus Rally settings
	RallySettings_Versus={(bCauseSprint=true)}
	RallySettings_Player_Versus={(DealtDamageModifier=1.2)}

	// Special Crawler spawn chances
	ChanceToSpawnAsSpecial(`DIFFICULTY_Normal)		=0.0
	ChanceToSpawnAsSpecial(`DIFFICULTY_Hard)		=0.01
	ChanceToSpawnAsSpecial(`DIFFICULTY_Suicidal)	=0.15
	ChanceToSpawnAsSpecial(`DIFFICULTY_HellOnEarth)	=0.2 //0.3
}