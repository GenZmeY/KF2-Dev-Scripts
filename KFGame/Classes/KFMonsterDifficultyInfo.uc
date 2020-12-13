//=============================================================================
// KFMonsterDifficultyInfo
//=============================================================================
// Per Zed, per difficulty balance settings
//=============================================================================
// Killing Floor 2
// Copyright (C) 2016 Tripwire Interactive LLC
//=============================================================================
class KFMonsterDifficultyInfo extends Object
	abstract;

/** Zed difficulty settings per difficulty level */
struct native ZedDifficultySettings
{
	/** The individual health modifier for this zed type */
	var() float HealthMod;
	/** The individual head health modifier for this zed type */
	var() float HeadHealthMod;
	/** The chance that a zed can use sprinting at a specific difficulty */
	var() float SprintChance;
	/** The chance that a zed will start sprinting when damaged */
	var() float DamagedSprintChance;
	/** A per zed damage mod configurable by difficulty */
	var() float DamageMod;
	/** A per zed damage mod configurable by difficulty when playing solo/offline */
	var() float SoloDamageMod;
	/** Per-zed zed time speed scale. 0 = disabled */
	var() float ZedTimeSpeedScale;
	/** Movement speed modifier for each difficulty */
	var() float MovementSpeedMod;
	/** Per-zed evade on damage settings. Triggers evades based on damage taken as a percentage of max health */
	var() sEvadeOnDamageInfo EvadeOnDamageSettings;
	/** Per-zed block settings */
	var() sBlockInfo BlockSettings;
	/** Per-zed rally settings */
	var() sRallyInfo RallySettings;

 	structdefaultproperties
	{
		HealthMod=1.0f;
		HeadHealthMod=1.0f;
	    SprintChance=0.f;
	    DamagedSprintChance=0.f;
	    DamageMod=1.f;
	    SoloDamageMod=1.f;
	    ZedTimeSpeedScale=0.f;
	    MovementSpeedMod=1.f
	}
};

/** ZedDifficultySettings struct for Normal difficulty level */
var const ZedDifficultySettings Normal;
/** ZedDifficultySettings struct for Hard difficulty level */
var const ZedDifficultySettings Hard;
/** ZedDifficultySettings struct for Suicidal difficulty level */
var const ZedDifficultySettings Suicidal;
/** ZedDifficultySettings struct for HellOnEarth difficulty level */
var const ZedDifficultySettings HellOnEarth;

/** Add an additional percentage of body health per player beyond 1 player. */
var const float NumPlayersScale_BodyHealth;
/** Add an additional percentage of head health per player beyond 1 player. */
var const float NumPlayersScale_HeadHealth;

/** Alterantive health scaling for player controlled zeds (versus mode */
var const float NumPlayersScale_BodyHealth_Versus;
var const float NumPlayersScale_HeadHealth_Versus;

/** Versus-specific evade settings */
var const sEvadeOnDamageInfo EvadeOnDamageSettings_Versus;

/** Versus-specific block settings */
var const sBlockInfo BlockSettings_Versus;
var const sBlockInfo BlockSettings_Player_Versus;

/** Versus-specific rally settings */
var const sRallyInfo RallySettings_Versus;
var const sRallyInfo RallySettings_Player_Versus;

/** Versus-specific zed time speed scales */
var const float ZedTimeSpeedScale_Versus;
var const float ZedTimeSpeedScale_Player_Versus;
`if(`notdefined(ShippingPC))
var bool bForceSpecialSpawn;
`endif

/** Chances, by difficulty, to spawn as an elite variant*/
var array<float> ChanceToSpawnAsSpecial;

/** If pawn can spawn as elite variant in versus mode */
var bool bVersusCanSpawnAsSpecial;

static function sEvadeOnDamageInfo GetEvadeOnDamageSettings( KFPawn_Monster MonsterPawn, KFGameReplicationInfo KFGRI )
{
	local byte Difficulty;
	local sEvadeOnDamageInfo DefaultEvadeSettings;

	// Check for versus settings first
	if( KFGRI.bVersusGame )
	{
		if( !MonsterPawn.bVersusZed )
		{
			return default.EvadeOnDamageSettings_Versus;
		}
		else
		{
			DefaultEvadeSettings.Chance = 0.f;
			return DefaultEvadeSettings;
		}
	}

	Difficulty = KFGRI.GetModifiedGameDifficulty();
	if( Difficulty >= `DIFFICULTY_HELLONEARTH )
	{
		return default.HellOnEarth.EvadeOnDamageSettings;
	}
	else if( Difficulty >= `DIFFICULTY_SUICIDAL )
	{
		return default.Suicidal.EvadeOnDamageSettings;
	}
	else if( Difficulty >= `DIFFICULTY_HARD )
	{
		return default.Hard.EvadeOnDamageSettings;
	}
	return default.Normal.EvadeOnDamageSettings;
}

static function sRallyInfo GetRallySettings( KFPawn_Monster MonsterPawn, KFGameReplicationInfo KFGRI )
{
	local byte Difficulty;

	// Check for versus settings first
	if( KFGRI.bVersusGame )
	{
		if( MonsterPawn.bVersusZed )
		{
			return default.RallySettings_Player_Versus;
		}
		else
		{
			return default.RallySettings_Versus;
		}
	}

	Difficulty = KFGRI.GetModifiedGameDifficulty();
	if( Difficulty >= `DIFFICULTY_HELLONEARTH )
	{
		return default.HellOnEarth.RallySettings;
	}
	else if( Difficulty >= `DIFFICULTY_SUICIDAL )
	{
		return default.Suicidal.RallySettings;
	}
	else if( Difficulty >= `DIFFICULTY_HARD )
	{
		return default.Hard.RallySettings;
	}
	return default.Normal.RallySettings;
}

static function sBlockInfo GetBlockSettings( KFPawn_Monster MonsterPawn, KFGameReplicationInfo KFGRI )
{
	local byte Difficulty;

	// Check for versus settings first
	if( KFGRI.bVersusGame )
	{
		if( MonsterPawn.bVersusZed )
		{
			return default.BlockSettings_Player_Versus;
		}
		else
		{
			return default.BlockSettings_Versus;
		}
	}

	Difficulty = KFGRI.GetModifiedGameDifficulty();
	if( Difficulty >= `DIFFICULTY_HELLONEARTH )
	{
		return default.HellOnEarth.BlockSettings;
	}
	else if( Difficulty >= `DIFFICULTY_SUICIDAL )
	{
		return default.Suicidal.BlockSettings;
	}
	else if( Difficulty >= `DIFFICULTY_HARD )
	{
		return default.Hard.BlockSettings;
	}
	return default.Normal.BlockSettings;
}

static function float GetZedTimeSpeedScale( KFPawn_Monster MonsterPawn, KFGameReplicationInfo KFGRI )
{
	local byte Difficulty;

	// Check for versus settings first
	if( KFGRI.bVersusGame )
	{
		if( MonsterPawn.bVersusZed )
		{
			return default.ZedTimeSpeedScale_Player_Versus;
		}
		else
		{
			return default.ZedTimeSpeedScale_Versus;
		}
	}

	Difficulty = KFGRI.GetModifiedGameDifficulty();
	if( Difficulty >= `DIFFICULTY_HELLONEARTH )
	{
		return default.HellOnEarth.ZedTimeSpeedScale;
	}
	else if( Difficulty >= `DIFFICULTY_SUICIDAL )
	{
		return default.Suicidal.ZedTimeSpeedScale;
	}
	else if( Difficulty >= `DIFFICULTY_HARD )
	{
		return default.Hard.ZedTimeSpeedScale;
	}
	return default.Normal.ZedTimeSpeedScale;
}

static function float GetMovementSpeedMod( KFPawn_Monster P, float GameDifficulty )
{
	if ( GameDifficulty >= `DIFFICULTY_HELLONEARTH )
	{
		return default.HellOnEarth.MovementSpeedMod;
	}
	else if ( GameDifficulty >= `DIFFICULTY_SUICIDAL )
	{
		return default.Suicidal.MovementSpeedMod;
	}
	else if ( GameDifficulty >= `DIFFICULTY_HARD )
	{
		return default.Hard.MovementSpeedMod;
	}
	return default.Normal.MovementSpeedMod;
}

static function float GetSpecialSpawnChance(KFGameReplicationInfo KFGRI)
{
	if (default.ChanceToSpawnAsSpecial.length == 0)
	{
		return 0.f;
	}

	if (!default.bVersusCanSpawnAsSpecial && KFGRI.bVersusGame)
	{
		return 0.f;
	}

	`if(`notdefined(ShippingPC))
	if (default.bForceSpecialSpawn)
		return 1.f;
	else
	`endif
		return default.ChanceToSpawnAsSpecial[Clamp(KFGRI.GetModifiedGameDifficulty(), 0, default.ChanceToSpawnAsSpecial.length-1)];
}

defaultproperties
{
	Normal=(DamageMod=0.5)
	Hard=(DamageMod=1.0)
	Suicidal=(DamageMod=1.25)
	HellOnEarth=(DamageMod=1.75)

	ZedTimeSpeedScale_Versus=0.f
	ZedTimeSpeedScale_Player_Versus=0.f

	bVersusCanSpawnAsSpecial=false
}