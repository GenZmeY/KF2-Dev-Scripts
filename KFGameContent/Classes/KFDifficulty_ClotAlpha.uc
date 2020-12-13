//=============================================================================
// KFDifficulty_ClotAlpha
//=============================================================================
// Per Zed, per difficulty balance settings
//=============================================================================
// Killing Floor 2
// Copyright (C) 2016 Tripwire Interactive LLC
//=============================================================================
class KFDifficulty_ClotAlpha extends KFMonsterDifficultyInfo
	abstract;

defaultproperties
{
	// Normal difficulty
	Normal={(HealthMod=0.75,
		HeadHealthMod=0.75,
		RallySettings={(bCanRally=false)}
	)}

	// Hard difficulty
	Hard={(DamagedSprintChance=0.70, //0.05
		RallySettings={(bCanRally=false)}
	)}

	// Suicidal difficulty
	Suicidal={(SprintChance=0.50, //0.05
		DamagedSprintChance=1.0,
		RallySettings={(bCauseSprint=true, DealtDamageModifier=2.0, TakenDamageModifier=0.5)} // 1.2
	)}

	// Hell On Earth difficulty
	HellOnEarth={(SprintChance=0.85, //0.75
		DamagedSprintChance=1.0,
		RallySettings={(bCauseSprint=true, DealtDamageModifier=2.0, TakenDamageModifier=0.5)} //{(bCauseSprint=true, DealtDamageModifier=1.5, TakenDamageModifier=0.9)}
	)}

	// Versus Rally settings
	RallySettings_Versus={(bCauseSprint=true)}
	RallySettings_Player_Versus={(DealtDamageModifier=1.5)} //1.2

	// Special Alpha spawn chances
	ChanceToSpawnAsSpecial(`DIFFICULTY_Normal)		=0.0
	ChanceToSpawnAsSpecial(`DIFFICULTY_Hard)		=0.0
	ChanceToSpawnAsSpecial(`DIFFICULTY_Suicidal)	=0.25
	ChanceToSpawnAsSpecial(`DIFFICULTY_HellOnEarth)	=0.35
}