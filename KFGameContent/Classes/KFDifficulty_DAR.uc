//=============================================================================
// KFDifficulty_DAR
//=============================================================================
//
//=============================================================================
// Killing Floor 2
// Copyright (C) 2018 Tripwire Interactive LLC
//=============================================================================
class KFDifficulty_DAR extends KFMonsterDifficultyInfo
	dependsOn(KFPawn_ZedDAR)
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
		MovementSpeedMod=1.1,
		EvadeOnDamageSettings={(Chance=1.0, DamagedHealthPctToTrigger=0.01)},
		RallySettings={(DealtDamageModifier=1.2, TakenDamageModifier=0.9)}
	)}

	// Hell On Earth difficulty
	HellOnEarth={(SprintChance=1.0,
		DamagedSprintChance=1.0,
		MovementSpeedMod=1.2,
		EvadeOnDamageSettings={(Chance=1.0, DamagedHealthPctToTrigger=0.01)},
		RallySettings={(bCauseSprint=true, DealtDamageModifier=1.2, TakenDamageModifier=0.9)}
	)}


}
