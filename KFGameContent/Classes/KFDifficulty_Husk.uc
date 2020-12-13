//=============================================================================
// KFDifficulty_Husk
//=============================================================================
// Per Zed, per difficulty balance settings
//=============================================================================
// Killing Floor 2
// Copyright (C) 2016 Tripwire Interactive LLC
//=============================================================================
class KFDifficulty_Husk extends KFMonsterDifficultyInfo
	dependsOn(KFPawn_ZedHusk)
	abstract;

/** Difficulty-based fireball settings */
var array<sHuskFireballSettings> FireballSettings;

/** Versus AI Husk fireball settings */
var sHuskFireballSettings FireballSettings_Versus;

static function sHuskFireballSettings GetFireballSettings( KFPawn_ZedHusk HuskPawn, KFGameReplicationInfo KFGRI )
{
	local sHuskFireballSettings DefaultFireballSettings;

	// Check for versus settings first
	if( KFGRI.bVersusGame )
	{
		if( !HuskPawn.bVersusZed )
		{
			return default.FireballSettings_Versus;
		}
		else
		{
			DefaultFireballSettings.bSpawnGroundFire = true;
			return DefaultFireballSettings;
		}
	}

	return default.FireballSettings[Clamp(KFGRI.GetModifiedGameDifficulty(), 0, default.FireballSettings.length-1)];
}

defaultproperties
{
	// Normal difficulty
	Normal={(HealthMod=0.750000,
		HeadHealthMod=0.750000,
		DamageMod=0.35,
		SoloDamageMod=0.3500000,
		RallySettings={(bCanRally=false)}
	)}

	// Hard difficulty
	Hard={(SoloDamageMod=0.7500000,
		RallySettings={(bCanRally=false)}
	)}

	// Suicidal difficulty
	Suicidal={(DamagedSprintChance=0.500000,
		SoloDamageMod=0.7500000,
		RallySettings={(DealtDamageModifier=1.2, TakenDamageModifier=0.9)}
	)}

	// Hell On Earth difficulty
	HellOnEarth={(HealthMod=1.300000,
		HeadHealthMod=1.100000,
		SprintChance=0.750000,
		DamagedSprintChance=1.000000,
		DamageMod=1.500000,
		SoloDamageMod=0.7500000,
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

	// Fireball settings by difficulty
	FireballSettings(`DIFFICULTY_Normal)		={(bSpawnGroundFire=false, ExplosionMomentum=50000.f)}
	FireballSettings(`DIFFICULTY_Hard)			={(bSpawnGroundFire=false, ExplosionMomentum=55000.f)}
	FireballSettings(`DIFFICULTY_Suicidal)		={(bSpawnGroundFire=true, ExplosionMomentum=60000.f)}
	FireballSettings(`DIFFICULTY_HellOnEarth)	={(bSpawnGroundFire=true, ExplosionMomentum=65000.f)}
	FireballSettings_Versus						={(bSpawnGroundFire=false, ExplosionMomentum=50000.f)}
}