//=============================================================================
// KFDifficulty_ClotSlasher
//=============================================================================
// Per Zed, per difficulty balance settings
//=============================================================================
// Killing Floor 2
// Copyright (C) 2016 Tripwire Interactive LLC
//=============================================================================
class KFDifficulty_ClotSlasher extends KFMonsterDifficultyInfo
	abstract;

defaultproperties
{
	// Normal difficulty
	Normal={(HealthMod=0.750000,
		HeadHealthMod=0.750000,
		ZedTimeSpeedScale=0.0,
		EvadeOnDamageSettings={(Chance=0.1, DamagedHealthPctToTrigger=0.01)},
		RallySettings={(bCanRally=false)}
	)}

	// Hard difficulty
	Hard={(DamagedSprintChance=1.000000,
		ZedTimeSpeedScale=0.0,
		EvadeOnDamageSettings={(Chance=0.4, DamagedHealthPctToTrigger=0.01)},
		RallySettings={(bCanRally=false)}
	)}
	
	// Suicidal difficulty
	Suicidal={(SprintChance=0.850000, //0.5
		DamagedSprintChance=1.000000,
		MovementSpeedMod=1.2, //1.1
		ZedTimeSpeedScale=0.0,
		EvadeOnDamageSettings={(Chance=1.0, DamagedHealthPctToTrigger=0.01)},
		RallySettings={(bCauseSprint=true, DealtDamageModifier=2.0, TakenDamageModifier=0.5)}//{(bCauseSprint=true, DealtDamageModifier=1.5, TakenDamageModifier=0.9)}
	)}

	// Hell On Earth difficulty
	HellOnEarth={(SprintChance=0.95000, //0.7
		DamagedSprintChance=1.000000,
		MovementSpeedMod=1.3, //1.2
		ZedTimeSpeedScale=0.0,
		EvadeOnDamageSettings={(Chance=1.0, DamagedHealthPctToTrigger=0.01)},
		RallySettings={(bCauseSprint=true, DealtDamageModifier=2.0, TakenDamageModifier=0.5)} //{(bCauseSprint=true, DealtDamageModifier=1.5, TakenDamageModifier=0.9)}
	)}

	// Versus Rally settings
	RallySettings_Versus={(bCauseSprint=true)}
	RallySettings_Player_Versus={(DealtDamageModifier=1.2)}

	// Versus Zed Time speed scales
	// normal zed time speed scale = 0.20
	ZedTimeSpeedScale_Versus=0.25
	ZedTimeSpeedScale_Player_Versus=0.75
}