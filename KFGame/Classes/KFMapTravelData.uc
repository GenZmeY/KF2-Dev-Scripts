//=============================================================================
// KFMapTravelData
//=============================================================================
// Keeps persistent data between map changes. Does not need a script instance,
// all properties are managed by the default object in native.
//=============================================================================
// Killing Floor 2
// Copyright (C) 2016 Tripwire Interactive LLC
// - Matt "Squirrlz" Farber
//=============================================================================
class KFMapTravelData extends Object
	native
	abstract;

/** Contains persistent player data to be carried over map changes */
struct native sPersistentPlayerData
{
	var UniqueNetId PlayerID;
	var int TeamIndex;
	var int Dosh;
	var int Kills;
	var int Deaths;
	var int DamageDealt;

	structdefaultproperties
	{
		TeamIndex=-1
		Dosh=-1
		Kills=-1
		Deaths=-1
		DamageDealt=-1
	}
};

/** The map that was in use during the last game */
var private string LastGameMap;

/** Last time we map traveled */
var private float LastTravelTime;

/** Array of persistent player data */
var private array<sPersistentPlayerData> PlayerData;

/** Persistent team scores */
var private array<int> TeamScores;

/** Which round this match is in */
var private int RoundCount;

/** How many times the survivors died in the previous round */
var private int SurvivorDeaths;

/** How much damage was done to the boss in the previous round */
var private int BossDamageDone;

/** How much total damage survivors took in the boss round */
var private int BossSurvivorDamageTaken;

/** Last game map accessor functions */
static native final function SetLastGameMap( string MapName );
static native final function string GetLastGameMap() const;

/** Last map travel time accessors */
static native final function SetLastTravelTime( float Time );
static native final function float GetLastTravelTime() const;

/** Player data accessor functions */
static native final function AddPlayer( UniqueNetId PlayerNetID,
										optional int TeamIndex,
										optional int Dosh=-1,
										optional int Kills=-1,
										optional int Deaths=-1,
										optional int DamageDealt=-1 );
static native final function RemovePlayer( UniqueNetId PlayerNetID );
static native final function sPersistentPlayerData GetPlayer( UniqueNetId PlayerNetID ) const;
static native final function ClearPlayerData();

/** Team score accessor functions */
static native final function SetTeamScore( int TeamIndex, int TeamScore );
static native final function int GetTeamScore( int TeamIndex ) const;

/** Accessors for round count */
static native final function SetRoundCount( int RoundNum );
static native final function int GetRoundCount() const;

/** Accessors for last round survivor deaths */
static native final function SetSurvivorDeaths( int Deaths );
static native final function int GetSurvivorDeaths() const;

/** Accessors for last round boss damage taken */
static native final function SetBossDamageDone( int Dmg );
static native final function int GetBossDamageDone() const;

/** Accessors for last round boss survivor damage taken */
static native final function SetBossSurvivorDamageTaken( int Dmg );
static native final function int GetBossSurvivorDamageTaken() const;

/** Clears all persistent data in the class. Can be subclassed to include new properties */
static native function ClearAllMapTravelData();

defaultproperties
{
	SurvivorDeaths=-1
	BossDamageDone=-1
	BossSurvivorDamageTaken=-1
	RoundCount=0
}