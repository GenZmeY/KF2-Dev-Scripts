//=============================================================================
// KFDifficulty_ClotCyst
//=============================================================================
// Per Zed, per difficulty balance settings
//=============================================================================
// Killing Floor 2
// Copyright (C) 2016 Tripwire Interactive LLC
//=============================================================================
class KFDifficulty_ClotCyst extends KFMonsterDifficultyInfo
	abstract;

defaultproperties
{
	// Normal difficulty
	Normal={(HealthMod=0.750000,
		HeadHealthMod=0.750000,
		RallySettings={(bCanRally=false)}
	)}

	// Hard difficulty
	Hard={(DamagedSprintChance=0.70, //0.01
		RallySettings={(bCanRally=false)}
	)}
	
	// Suicidal difficulty
	Suicidal={(SprintChance=0.5, //0.05
		DamagedSprintChance=1.0,
		RallySettings={(bCauseSprint=true, DealtDamageModifier=2.0, TakenDamageModifier=0.5)} //{(bCauseSprint=true, DealtDamageModifier=1.5, TakenDamageModifier=0.9)}
	)}

	// Hell On Earth difficulty
	HellOnEarth={(SprintChance=0.85, //0.4 
		DamagedSprintChance=1., //0.8
		RallySettings={(bCauseSprint=true, DealtDamageModifier=2.0, TakenDamageModifier=0.5)}
	)}

	// Versus Rally settings
	RallySettings_Versus={(bCauseSprint=true)}
	RallySettings_Player_Versus={(DealtDamageModifier=1.2)}
}