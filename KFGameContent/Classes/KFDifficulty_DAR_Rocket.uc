//=============================================================================
// KFDifficulty_DAR_Rocket
//=============================================================================
//
//=============================================================================
// Killing Floor 2
// Copyright (C) 2018 Tripwire Interactive LLC
//=============================================================================
class KFDifficulty_DAR_Rocket extends KFDifficulty_DAR
	dependsOn(KFPawn_ZedDAR_Rocket)
	abstract;

defaultproperties
{
	// Normal difficulty
	Normal={(
		HealthMod=0.750000,
		HeadHealthMod=0.750000,
		DamageMod=0.35,
		SoloDamageMod=0.3500000,
		RallySettings={(bCanRally=false)}
	)}

	// Hard difficulty
	Hard={(
		SoloDamageMod=0.7500000,
		RallySettings={(bCanRally=false)}
	)}

	// Suicidal difficulty
	Suicidal={(
		DamagedSprintChance=0.500000,
		SoloDamageMod=0.7500000,
		RallySettings={(DealtDamageModifier=1.2, TakenDamageModifier=0.9)}
	)}

	// Hell On Earth difficulty
	HellOnEarth={(
		HealthMod=1.300000,
		HeadHealthMod=1.100000,
		SprintChance=0.750000,
		DamagedSprintChance=1.000000,
		DamageMod=1.500000,
		SoloDamageMod=0.7500000,
		RallySettings={(bCauseSprint=true, DealtDamageModifier=1.2, TakenDamageModifier=0.9)}
	)}

	// Versus Rally settings
	RallySettings_Versus={(bCauseSprint=true)}
}
