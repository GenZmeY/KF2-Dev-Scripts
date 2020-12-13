//=============================================================================
// KFDifficulty_Bloat
//=============================================================================
// Per Zed, per difficulty balance settings
//=============================================================================
// Killing Floor 2
// Copyright (C) 2016 Tripwire Interactive LLC
//=============================================================================
class KFDifficulty_Bloat extends KFMonsterDifficultyInfo
	abstract;

/** Number of puke mines to spawn when a bloat dies on a per-difficulty basis */
var array<byte> PukeMinesToSpawnOnDeathByDifficulty;

/** How many puke mines to spawn when an AI bloat dies in versus */
var byte PukeMinesToSpawnOnDeath_Versus;

/** How many puke mines to spawn when a player-controlled bloat dies in versus */
var byte PukeMinesToSpawnOnDeath_Player_Versus;

/** Gets the number of puke mines that the bloat should spawn when dying */
static function byte GetPukeMinesToSpawnOnDeath( KFPawn_ZedBloat BloatPawn, GameInfo GI)
{
	if( BloatPawn.bVersusZed )
	{
		return default.PukeMinesToSpawnOnDeath_Player_Versus;
	}
	if( KFGameInfo_VersusSurvival(GI) != none )
	{
		return default.PukeMinesToSpawnOnDeath_Versus;
	}
	return default.PukeMinesToSpawnOnDeathByDifficulty[GI.GetModifiedGameDifficulty()];
}

defaultproperties
{
	// Normal Difficulty
	Normal={(HealthMod=0.750000,
		HeadHealthMod=0.750000,
		DamageMod=0.4, //0.6
		SoloDamageMod=0.300000, //0.5
		BlockSettings={(Chance=0.0, Duration=1.25, MaxBlocks=3, Cooldown=3.5, DamagedHealthPctToTrigger=0.1,
							MeleeDamageModifier=0.3, DamageModifier=0.3, AfflictionModifier=0.2, SoloChanceMultiplier=0.1)},
		RallySettings={(bCanRally=false)}
	)}

	// Hard difficulty
	Hard={(DamageMod=0.750000,
		SoloDamageMod=0.750000,
		BlockSettings={(Chance=0.1, Duration=1.25, MaxBlocks=4, Cooldown=3.5, DamagedHealthPctToTrigger=0.1,
							MeleeDamageModifier=0.9, DamageModifier=0.9, AfflictionModifier=0.2, SoloChanceMultiplier=0.1)},
		RallySettings={(bCanRally=false)}
	)}

	// Suicidal difficulty
	Suicidal={(HealthMod=1.200000,
		HeadHealthMod=1.050000,
		SprintChance=0.100000,
		DamagedSprintChance=0.100000,
		SoloDamageMod=0.750000,
		BlockSettings={(Chance=0.65, Duration=1.25, MaxBlocks=5, Cooldown=3.5, DamagedHealthPctToTrigger=0.1,
							MeleeDamageModifier=0.9, DamageModifier=0.9, AfflictionModifier=0.2, SoloChanceMultiplier=0.1)},
		RallySettings={(bCauseSprint=true, DealtDamageModifier=1.5, TakenDamageModifier=0.5)} //{(bCauseSprint=true, DealtDamageModifier=1.2, TakenDamageModifier=0.9)}
	)}
	
	// Hell On Earth difficulty
	HellOnEarth={(HealthMod=1.300000,
		HeadHealthMod=1.100000,
   		SprintChance=0.300000,
   		DamagedSprintChance=0.500000,
   		DamageMod=1.500000,
   		SoloDamageMod=0.75,
		BlockSettings={(Chance=0.85, Duration=1.25, MaxBlocks=6, Cooldown=3.5, DamagedHealthPctToTrigger=0.1,
							MeleeDamageModifier=0.9, DamageModifier=0.9, AfflictionModifier=0.2, SoloChanceMultiplier=0.2)},
		RallySettings={(bCauseSprint=true, DealtDamageModifier=1.5, TakenDamageModifier=0.5)}
	)}

	// Versus Block settings
	BlockSettings_Versus={()}
	BlockSettings_Player_Versus=(DamageModifier=0.3, MeleeDamageModifier=0.3)

	// Versus Rally settings
	RallySettings_Versus={(bCauseSprint=true)}
	RallySettings_Player_Versus={(DealtDamageModifier=1.2)}

	// Death Puke Mine numbers -- maximum of 3
	PukeMinesToSpawnOnDeathByDifficulty(`DIFFICULTY_Normal)			=0
	PukeMinesToSpawnOnDeathByDifficulty(`DIFFICULTY_Hard)			=1
	PukeMinesToSpawnOnDeathByDifficulty(`DIFFICULTY_Suicidal)		=3
	PukeMinesToSpawnOnDeathByDifficulty(`DIFFICULTY_HellOnEarth)	=3
	PukeMinesToSpawnOnDeath_Versus									=0
	PukeMinesToSpawnOnDeath_Player_Versus							=3
}