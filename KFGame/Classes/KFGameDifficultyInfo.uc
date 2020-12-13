//=============================================================================
// KFGameDifficultyInfo
//=============================================================================
// Manages difficulty based gameplay settings
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//=============================================================================

class KFGameDifficultyInfo extends Object
	hidecategories(Object);

/**	The maxiumum number of players we will lerp for */
const OverMaxPlayers_MaxLerpedPlayers = 128.f;
/**	The max multiplier for health if we are playing with more than 6 players*/
const OverMaxPlayers_MaxHealthMod = 20.f;

struct NumPlayerMods
{
	/** Each index relates to the number of players in the game, it's value is the modifier */
	var() float PlayersMod[`KF_MAX_PLAYERS];
	/** If we are over our standard max player count of 6, linearly scale up to ModCap value */
	var() float ModCap;

	structdefaultproperties
	{
    	PlayersMod[0]=1.f;
    	PlayersMod[1]=1.f;
    	PlayersMod[2]=1.f;
    	PlayersMod[3]=1.f;
    	PlayersMod[4]=1.f;
    	PlayersMod[5]=1.f;
    	ModCap=2.f;
	}
};

/** Multiplier for the total zeds in a wave depending on the number of players*/
var(NumPlayers) NumPlayerMods NumPlayers_WaveSize;

/** Multiplier for the AI's movement speed while hidden depending on  the number of players*/
var(NumPlayers) NumPlayerMods NumPlayers_AIHiddenSpeed;

/** Time until a weapon will respawn after being picked up depending on the number of players*/
var(NumPlayers) NumPlayerMods NumPlayers_WeaponPickupRespawnTime;

/** Time until ammo will respawn after being picked up depending on the number of players*/
var(NumPlayers) NumPlayerMods NumPlayers_AmmoPickupRespawnTime;

/** Amount of damage resistance to use (0:Ignore, 1:Full) depending on the number of players */
var(NumPlayers) NumPlayerMods NumPlayers_ZedDamageResistance;

struct MapOverrideInfo
{
	var() string MapName;
	var() int TraderTime<ClampMin=0.0>;
};

struct DifficultySettings
{
	/** How long trader time is */
    var() int TraderTime<ClampMin = 0.0>;
	/** Multiplier for the total health of all zeds */
	var() float GlobalHealthMod<ClampMin = 0.0>;
	/** Multiplier for the movement speed of a zed */
	var() float MovementSpeedMod<ClampMin = 0.0>;
	/** Multiplier for the number of zeds in a wave */
	var() float WaveCountMod<ClampMin = 0.0>;

	/** Multiplier for the dosh awarded upon killing a zed */
	var() float DoshKillMod<ClampMin = 0.0>;
	/** The amount of dosh a player will start with the first time they spawn */
	var() int	StartingDosh<ClampMin = 0.0>;
	/** The amount of dosh a player will start with from respawning after dying */
	var() int   RespawnDosh<ClampMin = 0.0>;

	/** Modify the number of ammo pickups that will be active at once */
	var() float AmmoPickupsMod<ClampMin = 0.0 | ClampMax = 1.0>;
	/** Modify the number of weapon pickups that will be active at once */
	var() float ItemPickupsMod<ClampMin = 0.0 | ClampMax = 1.0>;

	/** The chance that a zed will perform a weak attack at this difficulty level */
	var() float WeakAttackChance<ClampMin = 0.0 | ClampMax = 1.0>;
	/** The chance that a zed will perform a medium attack at this difficulty level */
	var() float MediumAttackChance<ClampMin = 0.0 | ClampMax = 1.0>;
	/** The chance that a zed will perform a hard attack at this difficulty level */
	var() float HardAttackChance<ClampMin = 0.0 | ClampMax = 1.0>;

	/** Modify the damage dealt by self inflicted radial damage (Ex. Grenade) */
	var() float SelfInflictedDamageMod<ClampMin = 0.0 | ClampMax = 1.0>;

	/** Modify the spawn rate of AI for this difficulty */
	var() float SpawnRateModifier<ClampMin = 0.0>;

	/** Override the trader time based on map instead of difficulty. */
	var() array<MapOverrideInfo> TraderTimerMapOverride;

	structdefaultproperties
	{
		TraderTime=60
		GlobalHealthMod=1.f
		MovementSpeedMod=1.f
		WaveCountMod=1.f
		DoshKillMod=1.f
		StartingDosh=250
		RespawnDosh=250
		AmmoPickupsMod=0.5f
		ItemPickupsMod=0.3f

		WeakAttackChance=1.0
		MediumAttackChance=0.0
		HardAttackChance=0.0

		SelfInflictedDamageMod=1
		SpawnRateModifier=1.f
	}
};

/** DifficultySettings struct for Normal difficulty level */
var(Normal) DifficultySettings Normal;
/** DifficultySettings struct for Hard difficulty level */
var(Hard) DifficultySettings Hard;
/** DifficultySettings struct for Suicidal difficulty level */
var(Suicidal) DifficultySettings Suicidal;
/** DifficultySettings struct for HellOnEarth difficulty level */
var(HellOnEarth) DifficultySettings HellOnEarth;

/** A cached version of the DifficultySettings we are currently using */
var protected DifficultySettings CurrentSettings;

/** Cache our current difficulty based on the GameDifficulty */
function SetDifficultySettings( float GameDifficulty )
{
	switch ( GameDifficulty )
	{
	 	case `DIFFICULTY_NORMAL:         CurrentSettings = Normal; break;
	 	case `DIFFICULTY_HARD:           CurrentSettings = Hard; break;
	 	case `DIFFICULTY_SUICIDAL:       CurrentSettings = Suicidal; break;
	 	case `DIFFICULTY_HELLONEARTH:    CurrentSettings = HellOnEarth; break;

	 	default: CurrentSettings = Normal; break;
	}
}

/************************************************************
 * Difficulty settings get functions
 ************************************************************/

/** Scales the health this Zed has by the difficulty level */
function GetAIHealthModifier(KFPawn_Monster P, float GameDifficulty, byte NumLivingPlayers, out float HealthMod, out float HeadHealthMod, optional bool bApplyDifficultyScaling=true)
{
	if ( P != none )
	{
		// Global mod * character mod
		if( bApplyDifficultyScaling )
		{
	    	HealthMod = GetGlobalHealthMod() * GetCharHealthModDifficulty(P, GameDifficulty);
			HeadHealthMod = GetGlobalHealthMod() * GetCharHeadHealthModDifficulty(P, GameDifficulty);
		}

		// invalid scaling?
		if ( HealthMod <= 0 )
		{
			HealthMod = 1.f;
			if( HeadHealthMod <= 0 )
			{
                HeadHealthMod = 1.f;
            }
			return;
		}

	    // Add another multiplier based on the number of players and the zeds character info scalers
		HealthMod *= 1.0 + (GetNumPlayersHealthMod( NumLivingPlayers, P.DifficultySettings.default.NumPlayersScale_BodyHealth ));
		HeadHealthMod *= 1.0 + (GetNumPlayersHealthMod( NumLivingPlayers, P.DifficultySettings.default.NumPlayersScale_HeadHealth ));
	}
}

/** Scales the health this Player (versus mode) Zed has by number of human players */
function GetVersusHealthModifier(KFPawn_Monster P, byte NumLivingPlayers, out float HealthMod, out float HeadHealthMod)
{
	if ( P != none )
	{
		HealthMod = GetGlobalHealthMod();
		HeadHealthMod = GetGlobalHealthMod();

	    // Add another multiplier based on the number of players and the zeds character info scalers
		HealthMod *= 1.0 + (GetNumPlayersHealthMod( NumLivingPlayers, P.DifficultySettings.default.NumPlayersScale_BodyHealth_Versus ));
		HeadHealthMod *= 1.0 + (GetNumPlayersHealthMod( NumLivingPlayers, P.DifficultySettings.default.NumPlayersScale_HeadHealth_Versus ));
	}
}

/** Scale health by the number of players.  This is applied as a bonus (zero is valid) for each player behind one */
function float GetNumPlayersHealthMod( byte NumLivingPlayers, float HealthScale )
{
	local float StartingLerp, LerpRate;

	// Early out if we have no living players
	if( NumLivingPlayers <= 0 )
	{
		return 0;
	}

	/** Scale the body health based on the number of players */
	if ( NumLivingPlayers <= `KF_MAX_PLAYERS )
	{
		return (NumLivingPlayers - 1) * HealthScale;
	}
	/** Slowly scale the additional health health to a max value if we are playing with more than 6 players */
	else
	{
		StartingLerp = HealthScale * `KF_MAX_PLAYERS;
		LerpRate = (NumLivingPlayers - `KF_MAX_PLAYERS) / OverMaxPlayers_MaxLerpedPlayers;
		return Lerp( StartingLerp, OverMaxPlayers_MaxHealthMod, fmin(LerpRate, 1.0f) );
	}
}

function float GetGlobalHealthMod()
{
	return CurrentSettings.GlobalHealthMod;
}

/** note: this returns a pass by value struct */
function float GetCharHealthModDifficulty( KFPawn_Monster P, float GameDifficulty )
{
	if ( GameDifficulty >= `DIFFICULTY_HELLONEARTH )
	{
		return P.DifficultySettings.default.HellOnEarth.HealthMod;
	}
	else if ( GameDifficulty >= `DIFFICULTY_SUICIDAL )
	{
		return P.DifficultySettings.default.Suicidal.HealthMod;
	}
	else if ( GameDifficulty >= `DIFFICULTY_HARD )
	{
		return P.DifficultySettings.default.Hard.HealthMod;
	}
	return P.DifficultySettings.default.Normal.HealthMod;
}

/** note: this returns a pass by value struct */
function float GetCharHeadHealthModDifficulty( KFPawn_Monster P, float GameDifficulty )
{
	if ( GameDifficulty >= `DIFFICULTY_HELLONEARTH )
	{
		return P.DifficultySettings.default.HellOnEarth.HeadHealthMod;
	}
	else if ( GameDifficulty >= `DIFFICULTY_SUICIDAL )
	{
		return P.DifficultySettings.default.Suicidal.HeadHealthMod;
	}
	else if ( GameDifficulty >= `DIFFICULTY_HARD )
	{
		return P.DifficultySettings.default.Hard.HeadHealthMod;
	}
	return P.DifficultySettings.default.Normal.HeadHealthMod;
}

function float GetCharSprintChanceByDifficulty( KFPawn_Monster P, float GameDifficulty )
{
	if ( GameDifficulty >= `DIFFICULTY_HELLONEARTH )
	{
		return P.DifficultySettings.default.HellOnEarth.SprintChance;
	}
	else if ( GameDifficulty >= `DIFFICULTY_SUICIDAL )
	{
		return P.DifficultySettings.default.Suicidal.SprintChance;
	}
	else if ( GameDifficulty >= `DIFFICULTY_HARD )
	{
		return P.DifficultySettings.default.Hard.SprintChance;
	}
	return P.DifficultySettings.default.Normal.SprintChance;
}

function float GetCharSprintWhenDamagedChanceByDifficulty( KFPawn_Monster P, float GameDifficulty )
{
	if ( GameDifficulty >= `DIFFICULTY_HELLONEARTH )
	{
		return P.DifficultySettings.default.HellOnEarth.DamagedSprintChance;
	}
	else if ( GameDifficulty >= `DIFFICULTY_SUICIDAL )
	{
		return P.DifficultySettings.default.Suicidal.DamagedSprintChance;
	}
	else if ( GameDifficulty >= `DIFFICULTY_HARD )
	{
		return P.DifficultySettings.default.Hard.DamagedSprintChance;
	}
	return P.DifficultySettings.default.Normal.DamagedSprintChance;
}

/**	Get the trader time by the difficulty level */
function float GetTraderTimeByDifficulty()
{
	return CurrentSettings.TraderTime;
}

/** Get the trader time if the current map overrides it */
function float GetTraderTimeByMap(string MapName)
{
	local MapOverrideInfo It;

	if (CurrentSettings.TraderTimerMapOverride.length > 0)
	{
		foreach CurrentSettings.TraderTimerMapOverride(It)
		{
			if (It.MapName ~= MapName)
			{
				return It.TraderTime;
			}
		}
	}

	return -1.f;
}

/**	Scales the damage this Zed deals by the difficulty level */
function float GetAIDamageModifier(KFPawn_Monster P, float GameDifficulty, bool bSoloPlay)
{
    local float PerZedDamageMod, SoloPlayDamageMod;

    // default if no InMonsterInfo
    PerZedDamageMod = 1.0;
    SoloPlayDamageMod = 1.0;

    if( P.DifficultySettings != none )
    {
    	if ( GameDifficulty >= `DIFFICULTY_HELLONEARTH )
    	{
    		PerZedDamageMod = P.DifficultySettings.default.HellOnEarth.DamageMod;
    		if( bSoloPlay )
    		{
                SoloPlayDamageMod = P.DifficultySettings.default.HellOnEarth.SoloDamageMod;
    		}
    	}
    	else if ( GameDifficulty >= `DIFFICULTY_SUICIDAL )
    	{
    		PerZedDamageMod = P.DifficultySettings.default.Suicidal.DamageMod;
    		if( bSoloPlay )
    		{
                SoloPlayDamageMod = P.DifficultySettings.default.Suicidal.SoloDamageMod;
    		}
    	}
    	else if ( GameDifficulty >= `DIFFICULTY_HARD )
    	{
    		PerZedDamageMod = P.DifficultySettings.default.Hard.DamageMod;
    		if( bSoloPlay )
    		{
                SoloPlayDamageMod = P.DifficultySettings.default.Hard.SoloDamageMod;
    		}
    	}
    	else
    	{
            PerZedDamageMod = P.DifficultySettings.default.Normal.DamageMod;
    		if( bSoloPlay )
    		{
                SoloPlayDamageMod = P.DifficultySettings.default.Normal.SoloDamageMod;
    		}
    	}
	}

	//`log("DamageMod: "$PerZedDamageMod * SoloPlayDamageMod$" Per Zed Difficulty DamageMod "$PerZedDamageMod$" bSoloPlay = "$bSoloPlay$" SoloPlayDamageMod = "$SoloPlayDamageMod/*, bLogAIDefaults*/);

	return PerZedDamageMod * SoloPlayDamageMod;
}

/** Gives the random range of AI speed modification */
function float GetAISpeedMod(KFPawn_Monster P, float GameDifficulty)
{
	// randomize by +/- 10%
	return P.DifficultySettings.static.GetMovementSpeedMod(P, GameDifficulty) * RandRange(0.9f, 1.1f);
}

/** Scales the movement speed of this Zed by the difficulty level */
function float GetAIGroundSpeedMod()
{
	return CurrentSettings.MovementSpeedMod;
}

/** Returns adjusted total num AI modifier for this wave's difficulty */
function float GetDifficultyMaxAIModifier()
{
	return CurrentSettings.WaveCountMod;
}

/* Get the starting money value adjusted by difficulty */
function float GetKillCashModifier()
{
	return CurrentSettings.DoshKillMod;
}

/* Get the starting money value adjusted by difficulty */
function int GetAdjustedStartingCash()
{
	return CurrentSettings.StartingDosh;
}

/* Get the money value adjusted by difficulty if you've died */
function int GetAdjustedRespawnCash()
{
	return CurrentSettings.RespawnDosh;
}

/* Get the modifier for the number of active weapon pickups in a map */
function float GetItemPickupModifier()
{
	return CurrentSettings.ItemPickupsMod;
}

/* Get the modifier for the number of active item pickups in a map */
function float GetAmmoPickupModifier()
{
	return CurrentSettings.AmmoPickupsMod;
}

function float GetWeakAttackChance()
{
 	return CurrentSettings.WeakAttackChance;
}

function float GetMediumAttackChance()
{
 	return CurrentSettings.MediumAttackChance;
}

function float GetHardAttackChance()
{
 	return CurrentSettings.HardAttackChance;
}

function float GetSelfInflictedDamageMod()
{
 	return CurrentSettings.SelfInflictedDamageMod;
}

function float GetSpawnRateModifier()
{
	return CurrentSettings.SpawnRateModifier;
}

/************************************************************
 * NumPlayers Modifiers
 ************************************************************/

/** If we have a standard number of players, use the PlayersMod value.
*	Otherwise, lerp to the ModCap value so the modifiers level out at untested player numbers */
function float GetNumPlayersModifier( const out NumPlayerMods PlayerSetting, byte NumLivingPlayers )
{
	local float StartingLerp, LerpRate;

	if ( `KF_MAX_PLAYERS > NumLivingPlayers )
	{
	 	return PlayerSetting.PlayersMod[Max(NumLivingPlayers - 1, 0)];
	}

	// Begin the lerp at the last value of PlayersMod
    StartingLerp = PlayerSetting.PlayersMod[ `KF_MAX_PLAYERS - 1 ];
    // Increase the mod value by scaling from 6 to 32;
	LerpRate = (NumLivingPlayers - `KF_MAX_PLAYERS) / (32.f - `KF_MAX_PLAYERS);
	return Lerp( StartingLerp, PlayerSetting.ModCap, LerpRate );
}

// Scale the hidden movement speed of this Zed by the difficulty level
function float GetAIHiddenSpeedModifier( int NumLivingPlayers )
{
	return GetNumPlayersModifier( NumPlayers_AIHiddenSpeed, NumLivingPlayers );
}

/** Returns adjusted total num AI modifier for this wave's player num */
function float GetPlayerNumMaxAIModifier( byte NumLivingPlayers )
{
	return GetNumPlayersModifier( NumPlayers_WaveSize, NumLivingPlayers );
}

/** Return the time it takes to respawn an ammo pickup */
function float GetAmmoPickupInterval( byte NumLivingPlayers )
{
	return GetNumPlayersModifier( NumPlayers_AmmoPickupRespawnTime, NumLivingPlayers );
}

/** Return the time it takes to respawn an weapon pickup */
function float GetWeaponPickupInterval( byte NumLivingPlayers )
{
	return GetNumPlayersModifier( NumPlayers_WeaponPickupRespawnTime, NumLivingPlayers );
}

/** Return the damage resistance modifier */
function float GetDamageResistanceModifier( byte NumLivingPlayers )
{
	return GetNumPlayersModifier( NumPlayers_ZedDamageResistance, NumLivingPlayers );
}

// return the value of a difficulty level
static function float GetDifficultyValue( byte DifficultyIndex )
{
	switch ( DifficultyIndex )
	{
	 	case 0:	return `DIFFICULTY_NORMAL;
	 	case 1:	return `DIFFICULTY_HARD;
	 	case 2:	return `DIFFICULTY_SUICIDAL;
	 	case 3:	return `DIFFICULTY_HELLONEARTH;
	 	default: return `DIFFICULTY_NORMAL;
	}
}

static function byte GetDifficultyIndex( float GameDifficulty )
{
 	switch ( GameDifficulty )
	{
	 	case `DIFFICULTY_NORMAL:		return 0;
	 	case `DIFFICULTY_HARD:   		return 1;
	 	case `DIFFICULTY_SUICIDAL:		return 2;
	 	case `DIFFICULTY_HELLONEARTH:	return 3;

	 	default: return 99;
	}
}

defaultproperties
{
	NumPlayers_WaveSize={(PlayersMod[1]=2.000000,
		PlayersMod[2]=2.750000,
		PlayersMod[3]=3.500000,
		PlayersMod[4]=4.000000,
		PlayersMod[5]=4.500000,
		ModCap=10.000000)}

	NumPlayers_AIHiddenSpeed={(PlayersMod[3]=1.300000,
		PlayersMod[4]=1.300000,
		PlayersMod[5]=1.650000)}

	NumPlayers_WeaponPickupRespawnTime={(PlayersMod[0]=30.000000,
		PlayersMod[1]=15.000000,
		PlayersMod[2]=10.000000,
		PlayersMod[3]=7.500000,
		PlayersMod[4]=6.000000,
		PlayersMod[5]=5.000000,
		ModCap=1.000000)}

	NumPlayers_AmmoPickupRespawnTime={(PlayersMod[0]=30.000000,
		PlayersMod[1]=15.000000,
		PlayersMod[2]=10.000000,
		PlayersMod[3]=7.500000,
		PlayersMod[4]=6.000000,
		PlayersMod[5]=5.000000,
		ModCap=1.000000)}

//resistance
	NumPlayers_ZedDamageResistance={(PlayersMod[0]=0.75,
		PlayersMod[1]=1.0,
		PlayersMod[2]=1.0,
		PlayersMod[3]=1.0,
		PlayersMod[4]=1.0,
		PlayersMod[5]=1.0,
		ModCap=1.000000)}
}
