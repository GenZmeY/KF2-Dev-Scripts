//=============================================================================
// KFDifficulty_Stalker
//=============================================================================
// Per Zed, per difficulty balance settings
//=============================================================================
// Killing Floor 2
// Copyright (C) 2016 Tripwire Interactive LLC
//=============================================================================
class KFDifficulty_Stalker extends KFMonsterDifficultyInfo
	abstract;

defaultproperties
{
	// Normal difficulty
	Normal={(HealthMod=0.750000,
		HeadHealthMod=0.750000,
		DamageMod=0.5,  //1
		SoloDamageMod=0.5,
		EvadeOnDamageSettings={(Chance=0.1, DamagedHealthPctToTrigger=0.01)},
		RallySettings={(bCanRally=false)}
	)}

	// Hard difficulty
	Hard={(DamagedSprintChance=0.050000,
		DamageMod=0.750000,
		EvadeOnDamageSettings={(Chance=0.4, DamagedHealthPctToTrigger=0.01)},
		RallySettings={(bCanRally=false)}
	)}

	// Suicidal difficulty
	Suicidal={(SprintChance=0.600000, //0.3
		DamagedSprintChance=1.0, //0.5
		MovementSpeedMod=1.3, //1.5
		EvadeOnDamageSettings={(Chance=1.0, DamagedHealthPctToTrigger=0.01)},
		RallySettings={(DealtDamageModifier=1.2, TakenDamageModifier=0.9)}
	)}

	// Hell On Earth difficulty
	HellOnEarth={(SprintChance=0.750000,
		DamagedSprintChance=1.000000,
		MovementSpeedMod=1.4, //1.6
		EvadeOnDamageSettings={(Chance=1.0, DamagedHealthPctToTrigger=0.01)},
		RallySettings={(bCauseSprint=true, DealtDamageModifier=1.2, TakenDamageModifier=0.9)}
	)}

	// Versus Rally settings
	RallySettings_Versus={(bCauseSprint=true)}
	RallySettings_Player_Versus={(DealtDamageModifier=1.2)}

	// Evil DAR spawn chances
	ChanceToSpawnAsSpecial(`DIFFICULTY_Normal)=0.08// 0.10
	ChanceToSpawnAsSpecial(`DIFFICULTY_Hard)=0.1//0.12
	ChanceToSpawnAsSpecial(`DIFFICULTY_Suicidal)=0.15//  0.18
	ChanceToSpawnAsSpecial(`DIFFICULTY_HellOnEarth)	=0.21 //0.25
}