//=============================================================================
// KFGameInfo
//=============================================================================
// Base GameInfo for KFGame
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//=============================================================================

class KFGameInfo extends FrameworkGame
	native;

`define GAMEINFO(dummy)
`include(KFGame\KFGameAnalytics.uci);
`undefine(GAMEINFO)
`include(KFGame\KFMatchStats.uci);

/** Scoring */
var const int POINTS_FOR_BOSS_KILL;
var const int POINTS_FOR_WAVE_COMPLETION;
var const int POINTS_PENALTY_FOR_DEATH;

struct native sGameMode
{
	var string FriendlyName;
	var string ClassNameAndPath;
	var bool bSoloPlaySupported;
	var int DifficultyLevels;
	var int Lengths;
	var int LocalizeID; // This corresponds to an element in the localized ModeStrings array in KFCommon_LocalizedStrings
};

var KFGameReplicationInfo   			MyKFGRI;

/************************************************************************************
 * @name		Customization
 ***********************************************************************************/

var class<KFPawn_Customization> CustomizationPawnClass;

/************************************************************************************
 * @name		Team Settings
 ***********************************************************************************/

var	globalconfig	float				FriendlyFireScale;			// scale friendly fire damage by this value
var					KFTeamInfo_Human	Teams[2];

/** True if there was only one active player pawn at last respawn time */
var 	bool 	bOnePlayerAtStart;

/** The number of human deaths this match */
var 	int 	HumanDeaths;

var		bool	bSplitBossDoshReward;

/************************************************************************************
 * @name		User Interface
 ***********************************************************************************/

var class<KFGFxMoviePlayer_Manager>	KFGFxManagerClass;

var	bool							bStartFinalCount;

/************************************************************************************
 * @name		Game Config
 ***********************************************************************************/
var	globalconfig	int				GameLength;					// EGameLength
var	config			int				MinNetPlayers;
var config			bool    		bWaitForNetPlayers;     	// wait until more than MinNetPlayers players have joined before starting match
var	globalconfig	int				ReadyUpDelay;
var	globalconfig	int				GameStartDelay;				// The default amount of time before the match begins
var config 			int				EndOfGameDelay;				// time between maps
var config 			array<sGameMode>GameModes;					// Gamemode definitions, used by menus/filters
var globalconfig 	bool			bDisableKickVote;			// If set, players will be able to vote to kick a person out(if they get VoteKickPercentage of players to vote to kick the same person)
var	globalconfig	float			KickVotePercentage;			// Percentage of players that must vote to kick a person before they are kicked
var globalconfig 	float 			TimeBetweenFailedVotes;		// How much time must pass after a failed vote before another one can be initiated
var	globalconfig	bool			bDisablePublicTextChat;		// Whether or not this server allows Public Text Chat
var	globalconfig	bool			bDisableVOIP;				// Whether or not this server allows VOIP
var	globalconfig	bool			bPartitionSpectators;		// Whether or not Spectators are limited to only Text and VOIP Chatting with other spectators
var	globalconfig	bool			bDisablePickups;			// Whether or not this server allows pickups
var globalconfig 	bool			bDisableMapVote;			// Turn off map voting
var globalconfig	float			MapVotePercentage;			// Percentage of players that must vote for this map
var globalconfig	float			MapVoteDuration;			// time till the map vote ends
var config          bool            bEnableMapObjectives;       // Whether or not maps that support objectives should use them

var globalconfig 	string 			ServerMOTD;			// Message of the day to be displayed on the server welcome screen
var globalconfig 	Color      		ServerMOTDColor;        // The color of the server MOTD text (set in the form ServerMOTDColor=(R=0,G=0,B=0)
var globalconfig 	string 			BannerLink;			// The url to the banner to be loaded from the magical internet
var globalconfig 	string 			WebsiteLink;		// The url to the clan website
var globalconfig 	Color     	 	WebLinkColor;           // The color of the web link text (set in the form WebLinkColor=(R=0,G=0,B=0)
var globalconfig 	string 			ClanMotto;			// The server's motto of the day
var globalconfig 	Color      		ClanMottoColor;         // The color of the clan motto text (set in the form ClanMottoColor=(R=0,G=0,B=0)

/** If set, ignore blocking collision of teammates */
var globalconfig 	bool			bDisableTeamCollision;

var globalconfig bool 				bEnableDeadToVOIP;
var globalconfig bool 				bDisablePublicVOIPChannel;

/** The time a server should stay up when empty before it dies if no one joins. Used for console dedicated servers only */
var const config float ServerExpirationForKillWhenEmpty;

/************************************************************************************
 * @name		Other (non-config) Game Settings
 ***********************************************************************************/
 /** If true we can change our perks at any point in this game mode */
 var const bool bCanPerkAlwaysChange;

/** The time it takes to respawn when we have reconnected to the same server multiple times */
var const int 	ReconnectRespawnTime;

var private const float XPMultiplier;

/************************************************************************************
 * @name		Game Difficulty
 ***********************************************************************************/

/** Difficulty settings are accessible through the DifficultyInfo */
var KFGameDifficultyInfo 		DifficultyInfo;
/** Difficulty class templates */
var class<KFGameDifficultyInfo> DifficultyInfoClass;
var class<KFGameDifficultyInfo> DifficultyInfoConsoleClass;

/** Trader */
var array<KFTraderTrigger>	TraderList;
var transient KFTraderTrigger ScriptedTrader;

/** Pickups */
var	array<KFPickupFactory>	ItemPickups;
var	array<KFPickupFactory>	AmmoPickups;

/** Keep track off all pickup factories so we don't have to use all actors */
var array<KFPickupFactory> 	AllPickupFactories;

/** The max number of pickups we can have on this difficulty mode and map */
var byte					NumWeaponPickups;
var byte					NumAmmoPickups;

/** Dosh Penalty for dying mid wave */
var array<float>			DeathPenaltyModifiers;

/** Dosh Penalty for dying mid wave by difficulty*/
var array<float>			MaxRespawnDosh;
const 						TeamDeathPenaltyPerc	= 0.05f;

/** Maximum value (aka NumDifficulties - 1) for the GameDifficulty */
var int 					MaxGameDifficulty;

/** Minimum value for the GameDifficulty.  Paired with above, allows game type to
 *      clamp difficulty at InitGame time.
 */
var int                     MinGameDifficulty;

/************************************************************************************
 * @name		Game Length
 ***********************************************************************************/

enum EGameLength
{
	GL_Short,
	GL_Normal,
	GL_Long,
};

/** Amount to scale dosh reward based on game length */
var array<float>    GameLengthDoshScale;

/** Available spawn managers (game length) */
var	array< class<KFAISpawnManager> >   	SpawnManagerClasses;

struct native LateArrivalStart
{
	var() array< int > StartingDosh;
};

var array< LateArrivalStart > LateArrivalStarts;

/************************************************************************************
 * @name		Game balance
 ***********************************************************************************/

/** Game conductor which dynamically manages the difficulty and fun of the game */
var KFGameConductor						GameConductor;

/** The class of GameConductor to use for this gametype */
var	class<KFGameConductor>              GameConductorClass;

/************************************************************************************
 * @name		AI
 ***********************************************************************************/
/** Active AI Manager */
var KFAIDirector						AIDirector;
/** Keeps track of healthy AI*/
var int									AIAliveCount;
/** Counter for keeping track of AI spawned */
var	int									NumAISpawnsQueued;
/** Counter for AI spawned, increanses when the zeds are actually spawned */
var int									NumAIFinishedSpawning;

/** Number of zeds remainining before setting their pawns to bAlwaysRelevant=TRUE */
var private const int 					NumAlwaysRelevantZeds;

/** Active spawn manager - None if N/A to this game type */
var	KFAISpawnManager					SpawnManager;

/** Content class references loaded by this game type */
var	protected const array< class<KFPawn_Monster> >	AIClassList;
var protected const array< class<KFPawn_Monster> >  NonSpawnAIClassList;
var	protected const array< class<KFPawn_Monster> >	AIBossClassList;
var protected const array< class<KFPawn_Monster> >  AITestBossClassList; //List of non-rotation bosses that can be forced

var protected int									BossIndex; //Index into boss array, only preload content for the boss we want - PC builds can handle DLO cost much better

/** Class replacements for each zed type */
struct native SpawnReplacement
{
	/** Entry to replace, some form of AT_* */
	var() EAIType SpawnEntry;

	/** Class(es) to use instead of default */
	var() array<class<KFPawn_Monster> > NewClass;

	/** Percent chance that the spawn will be replaced by NewClass */
	var() float PercentChance;

	structdefaultproperties
	{
		PercentChance = 1.f;
	}
};

/** Class replacements for each zed type (same as SpawnReplacement, but with EBossAIType for clarity */
struct native BossSpawnReplacement
{
	/** Entry to replace, some form of AT_* */
	var() EBossAIType SpawnEntry;

	/** Class to use instead of default */
	var() class<KFPawn_Monster> NewClass;

	/** Percent chance that the spawn will be replaced by NewClass */
	var() float PercentChance;

	structdefaultproperties
	{
		PercentChance = 1.f;
	}
};

/************************************************************************************
 * @name		ZEDTime - slomo system
 ***********************************************************************************/

/** What percentage of normal game speed to slow down the game during ZedTime */
var()	float   ZedTimeSlomoScale;
/** How long to blend out zed time dilation for */
var()	float	ZedTimeBlendOutTime;

/** Time left in zed time */
var		float	ZedTimeRemaining;
/** True if zed time blend out has already started */
var		bool    bZedTimeBlendingOut;
/** Number of Zed Time extensions used(Chaining effect for killing other Zeds while Zed Time is active) */
var		int     ZedTimeExtensionsUsed;
/** The last time we had a Zed Time event */
var     float   LastZedTimeEvent;

/************************************************************************************
 * @name		Event Tracking (aka Analytics)
 ***********************************************************************************/

var config		 	bool	bEnableGameAnalytics;
var config			bool	bRecordGameStatsFile;

var	class<KFGameplayEventsWriter>	GameplayEventsWriterClass;
var	transient		KFGameplayEventsWriter	GameplayEventsWriter;

/************************************************************************************
 * @name		Map rotation
 ***********************************************************************************/

/** Whether we should use a Map Cycle List or just continuously reload the same map */
var	globalconfig	bool			bUseMapList;
/** Game Map Cycles, there is a map cycle per game mode */
struct native GameMapCycle
{
	var array<string>	Maps;
//	var array<int>		RoundLimits;
};
var globalconfig array<GameMapCycle>	GameMapCycles;
/** The currently active GameMapCycle */
var	globalconfig int					ActiveMapCycle;
/** index of current map in the cycle */
var globalconfig int 					MapCycleIndex;

/** Maps that are not valid for this game mode. If the array is empty, all are valid
	Make sure to add the map names ALL UPPERCASE in the config*/
var config array<string>                InValidMaps;

/************************************************************************************
 * @name		Dialog
 ***********************************************************************************/
var KFDialogManager 					DialogManager;
var class<KFDialogManager>           	DialogManagerClass;

var class<KFTraderVoiceGroupBase>		TraderVoiceGroupClass;

/************************************************************************************
 * @name		Music
 ***********************************************************************************/
/** Delay between start of "action" phase and action music */
var float 						ActionMusicDelay;

enum EForcedMusicType
{
	EFM_MainMenu,
	EFM_Credits,
	EFM_Boss1,
	EFM_Boss2,
	EFM_Boss3,
	EFM_Boss4,
	EFM_Boss5,
	EFM_WWL
};

/** Tracks that are not selected randomly but rather "forced" by the server (or standalone client) at specific times */
var array< KFMusicTrackInfo >	ForcedMusicTracks;

/************************************************************************************
 * @name		Debugging
 ***********************************************************************************/
var	config	bool	bLogScoring;
var	config	bool	bLogAIDefaults;
var         bool    bLogReservations;
var			bool	bLogAnalytics;
//var config  bool    bLogGameBalance;
var config 	bool 	bLogAICount;
var bool			bForceOutbreakWave;
var bool			bForceSpecialWave;

/** The number of players the game thinks are alive when ForceLivingPlayerCount is called */
var const byte ForcedNumLivingPlayers;

/** The outbreak index if an outbreak wave. */
var int DebugForcedOutbreakIdx;

/** The zed type if there is a forced special wave. */
var int DebugForceSpecialWaveZedType;

/** Event names for game balance logging */
const GBE_Inventory = 'Inventory';
const GBE_TraderOpen = 'TraderOpen';
const GBE_WaveStart = 'WaveStart';
const GBE_Buy = 'Buy';
const GBE_Sell = 'Sell';
const GBE_Pickup = 'Pickup';
const GBE_Respawn = 'Respawn';
const GBE_Kills = 'Kills';
const GBE_Deaths = 'Deaths';

/************************************************************************************
 * @name		Reservations
 ***********************************************************************************/
 struct native KFPlayerReservation
 {
	var UniqueNetId PlayerId;
	var int Timer;
 };

var transient array<KFPlayerReservation> PlayerReservations;
var int ReservationTimeout;

struct native PlayerGroupStruct
{
	var byte Team;
	var array<UniqueNetId> PlayerGroup;

	structdefaultproperties
    {
		Team=128
	}
};
var transient array<PlayerGroupStruct> PlayerGroups;

/************************************************************************************
 * @name		Server type
 ***********************************************************************************/
 /** Whether the current game is a custom game (as opposed to standard) */
var protected const bool	bIsCustomGame;
/** Whether the current game is unranked (as opposed to, you guessed it, ranked) */
var private const bool	bIsUnrankedGame;

/** Whether we should check if this server is out of date and shut it down. Set in native PreBeginPlay */
var const bool bEnableServerVersionCheck;
/** Time since we last checked for updates */
var const float LastUpToDateCheckTime;

/** Tickble object to manage UpToDate webapi */
var transient KFSteamWebUpToDateCheck UpToDateChecker;

/** If this is a versus game */
var bool bIsVersusGame;
var bool bIsEndlessGame;

// NVCHANGE_BEGIN - RLS - Debugging Effects
/************************************************************************************
 * @name		NVIDIA
 ***********************************************************************************/
 /** Debug dramatic kills. */
var bool	bNVAlwaysDramatic;
var bool	bNVBlockDramatic; // rls - has priority
var bool	bNVAlwaysHeadshot;
var bool	bNVDebugDamage;
// NVCHANGE_END - RLS - Debugging Effects

var bool    bLogGroupTeamBalance;

/************************************************************************************
* @name		Outbreak
***********************************************************************************/

/** Zed adjustments used in outbreak events. */
var KFOutbreakEvent OutbreakEvent;

/** Type of outbreak event to be used. */
var class<KFOutbreakEvent> OutbreakEventClass;

/************************************************************************************
* @name		Kismet Monster Properties
***********************************************************************************/

enum EMonsterProperties
{
	EMonsterProperties_Enraged,
	EMonsterProperties_Sprinting
};

var int SpawnedMonsterProperties[EMonsterProperties];

/************************************************************************************
 * @name		Native
 ***********************************************************************************/

cpptext
{
	// static members (doesn't contribute to class size)
	static UBOOL bServerNeedsRestart;

	virtual void PreBeginPlay();
	virtual void TickSpecial( FLOAT DeltaSeconds );

	// -autoupdate commandline
	virtual void CheckGameUpToDate();
	virtual void SendUpToDateCheck();
	virtual void ServerCleanExit();


	virtual UBOOL IsStandardGame();
}

// Returns num of alive AI
native function int GetMonsterAliveCount();
// Returns num of living human team members
native function int GetLivingPlayerCount();
// Force the game to think we have this many players alive
native function ForceLivingPlayerCount( byte NewPlayerNum );
// Set the num of alive AI (after a spawn ect)
native function RefreshMonsterAliveCount();
// Returns the AIDirector
native function KFAIDirector GetAIDirector();
// Skip a single map that is not allowed in the current server settings.
native function bool IsMapAllowedInCycle(string MapName);
// Returns if the server was just restarted
native function bool MapCycleNeedsInit();
// Sets game to ranked/unranked
native final function SetGameUnranked( bool bUnranked );

native protected function bool IsUnrankedGame();

/************************************************************************************
 * @name		Static functions
 ***********************************************************************************/

/**
  * Allows overriding of which gameinfo class to use.
  * Called on the DefaultGameType from the ini, or the one specified on the command line (?game=xxx)
  */
static event class<GameInfo> SetGameType(string MapName, string Options, string Portal)
{
	// if we're in the menu level, use the menu gametype
	if ( class'WorldInfo'.static.IsMenuLevel(MapName) )
	{
		return class'KFGameInfo_Entry';
	}

	return Default.class;
}

/**
 * Strips the "play on X" prefixes added to autosaved maps.
 */
static function string StripPlayOnPrefix( String MapName )
{
	if (Left(MapName, 6) ~= "UEDPIE")
	{
		return Right(MapName, Len(MapName) - 6);
	}
	else if ( Left(MapName, 5) ~= "UEDPC" )
	{
		return Right(MapName, Len(MapName) - 5);
	}
	else if (Left(MapName, 6) ~= "UEDPS3")
	{
		return Right(MapName, Len(MapName) - 6);
	}
	else if (Left(MapName, 6) ~= "UED360")
	{
		return Right(MapName, Len(MapName) - 6);
	}
	else if (Left(MapName, 6) ~= "UEDIOS")
	{
		return Right(MapName, Len(MapName) - 6);
	}

	return MapName;
}

/**
 * DLO (by string) content classes specific to this game type
 * - Use when direct ref loading is not possible (e.g. unused GameInfo is loaded)
 * - Class refs can be cached using the supplied GRI
 */
static function PreloadGlobalContentClasses()
{
	local class<KFPawn_Monster> PawnClass;

	class'KFGameEngine'.static.RefreshEventContent();

	foreach default.AIClassList(PawnClass)
	{
		PawnClass.static.PreloadContent();
	}

	//TODO: Revisit this list for better preloading, since it's tied to specific situations
	foreach default.NonSpawnAIClassList(PawnClass)
	{
		PawnClass.static.PreloadContent();
	}
}

/** Various functions used by UI when setting game mode */
static function bool GetShouldShowLength()
{
	return true;
}

static function string GetGameModeFriendlyNameFromNum( int GameModeNum )
{
	return default.GameModes[Max(GameModeNum, 0)].FriendlyName;
}
static function string GetGameModeFriendlyNameFromClass( string GameModeClassString )
{
	return default.GameModes[Max(default.GameModes.Find('ClassNameAndPath', GameModeClassString), 0)].FriendlyName;
}
static function int GetGameModeNumFromClass( string GameModeClassString )
{
	return default.GameModes.Find('ClassNameAndPath', GameModeClassString);
}
static function string GetGameModeClassFromNum( int GameModeNum )
{
	return default.GameModes[Max(GameModeNum, 0)].ClassNameAndPath;
}
static function int GetLocalizeIDFromFriendlyName( string FriendlyNameString )
{
	return default.GameModes[Max( default.GameModes.Find('FriendlyName', FriendlyNameString), 0 )].LocalizeID;
}
static function bool IsGameModeSoloPlayAllowed( int GameModeNum )
{
	return default.GameModes[GameModeNum].bSoloPlaySupported;
}
static function int GetGameModeIndexFromName(string FriendlyName)
{
	local int index;
	local array<string> LocalizedGameModes;

	LocalizedGameModes = class'KFCommon_LocalizedStrings'.static.GetGameModeStringsArray();

	for (index = 0; index < LocalizedGameModes.length; index++)
	{
		if (LocalizedGameModes[index] == FriendlyName)
		{
			return index;
		}
	}

	return INDEX_NONE;
}

function string GetFriendlyNameForCurrentGameMode()
{
	return GetGameModeFriendlyNameFromClass( "KFGameContent."$Class );
}


function int GetGameModeNum()
{
	return GetGameModeNumFromClass( PathName(default.class) );
}


function string GetFullGameModePath()
{
	return GetGameModeClassFromNum( GetGameModeNum() );
}


/**
 * @brief Marks the game as running an out-of-date version of the engine or workshop content. Designed to be callable on default object
 */
native function SetNeedsRestart();

native final function DisableServerTakeover();

/**
 * @brief Marks the game as needing to reload the map. If no one is playing, will reload the map immediately, otherwise will do nothing because the map
 *        will reload when the player win/lose/all leave
 */
native function SetNeedsReload();

native static function StaticSetNeedsRestart();

static native final function bool GameModeSupportsMap(int GameMode, string MapName);

/************************************************************************************
 * @name		InitGame
 ***********************************************************************************/

 /* Initialize the game.
 The GameInfo's InitGame() function is called before any other scripts (including
 PreBeginPlay() ), and is used by the GameInfo to initialize parameters and spawn
 its helper classes.
 Warning: this is called before actors' PreBeginPlay.
*/
event InitGame( string Options, out string ErrorMessage )
{
 	Super.InitGame( Options, ErrorMessage );

	if (UsesModifiedDifficulty())
	{
		SetModifiedGameDifficulty();
	}
	else
	{
		GameDifficulty = Max(0, GetIntOption(Options, "Difficulty", GameDifficulty));
		GameDifficulty = Clamp(GameDifficulty, MinGameDifficulty, MaxGameDifficulty);
	}

	if (UsesModifiedLength())
	{
		SetModifiedGameLength();
	}
	else
	{
		GameLength = Clamp(GetIntOption(Options, "GameLength", GameLength), 0, SpawnManagerClasses.Length - 1);
	}


	if( OnlineSub != none && OnlineSub.GetLobbyInterface() != none )
	{
		OnlineSub.GetLobbyInterface().LobbyJoinGame();
	}

	if( Role == ROLE_Authority )
	{
		if( DialogManagerClass != None )
		{
			DialogManager = Spawn(DialogManagerClass);
		}
	}

	if( ParseOption( Options, "Private" ) ~= "1" )
	{
		GameEngine(class'Engine'.static.GetEngine()).bPrivateServer = true;
		UpdateGameSettings();
	}

	if ( MapCycleNeedsInit() )
	{
		MapCycleIndex = INDEX_NONE;
		SaveConfig();
	}

	GameStartDelay = Clamp( GetIntOption( Options, "GameStartDelay", GameStartDelay ), 0, 60 );
	ReadyUpDelay = Clamp( GetIntOption( Options, "ReadyUpDelay", ReadyUpDelay ), 0, 300 );
	EndOfGameDelay = Clamp( GetIntOption( Options, "EndOfGameDelay", EndOfGameDelay ), 0, 120 );
	FriendlyFireScale = FClamp( GetFloatOption( Options, "FriendlyFireScale", FriendlyFireScale ), 0, 1.f );

	CreateOutbreakEvent();
	CheckForCustomSettings();
	CreateDifficultyInfo(Options);
}

//for difficulty override
function bool UsesModifiedLength()
{
	return false;
}
function SetModifiedGameLength();

function bool UsesModifiedDifficulty()
{
	return false;
}
function SetModifiedGameDifficulty();

/** Called once by InitGame to select DifficultyInfo Class */
function CreateDifficultyInfo(string Options)
{
	if ( DifficultyInfoConsoleClass != None && (WorldInfo.IsConsoleBuild() || WorldInfo.IsConsoleDedicatedServer()
`if(`notdefined(ShippingPC))
		 // ?ConsoleBalance=1 for testing
		 || ParseOption( Options, "ConsoleBalance" ) ~= "1"
`endif
		))
	{
		`log("Using difficulty override class:"@DifficultyInfoConsoleClass);
		DifficultyInfo = new(self) DifficultyInfoConsoleClass;
	}
	else
	{
		DifficultyInfo = new(self) DifficultyInfoClass;
	}

	DifficultyInfo.SetDifficultySettings( GameDifficulty );
}

function CreateOutbreakEvent()
{
	if (OutbreakEventClass != none)
	{
		OutbreakEvent = new(self) OutbreakEventClass;
	}
}

/**
 * @brief Get's a floatfrom the config if available (Nobody tried to grab a float option yet? Only int?)
  *
 * @param Options Passed in optiions
 * @param ParseString The variable we are looking for
 * @param CurrentValue the current value
 * @return float value of the option we are looking for
 */
static function float GetFloatOption( string Options, string ParseString, float CurrentValue )
{
	local string InOpt;

	InOpt = ParseOption( Options, ParseString );
	if ( InOpt != "" )
	{
		return float(InOpt);
	}

	return CurrentValue;
}

/**
 * @brief Checks if certain config settings have been changed or modified that make
 * 		  this a custom server
  * @return true if custom
 */
protected native function CheckForCustomSettings();

event PreBeginPlay()
{
	class'KFGameEngine'.static.ApplyTweaks(WorldInfo.GetMapName());

	super.PreBeginPlay();

	MyKFGRI = KFGameReplicationInfo(GameReplicationInfo);
	InitGRIVariables();

    CreateTeam(0);
    InitGameConductor();
    InitAIDirector();
	InitTraderList();
	ReplicateWelcomeScreen();

	WorldInfo.TWLogsInit();

`if(`notdefined(ShippingPC))
	if ( WorldInfo.NetMode == NM_ListenServer  )
	{
		WorldInfo.AddOnScreenDebugMessage(-1, 60, MakeColor(255,0,0,255), "NM_ListenServer");
	}
`endif
}

event PostBeginPlay()
{
	InitAllPickups();
	InitGameplayEventWriter();
	super.PostBeginPlay();

	// BWJ - 4-11-16 - Dedicated server builds launched by playfab kill themselves when the last player leaves or after x seconds of first person not joining
	if( WasLaunchedByPlayfab() )
	{
		SetTimer( ServerExpirationForKillWhenEmpty, true, nameof(CheckPopulation) );
	}
}

// Creates the GamePlayEventWriter and begins logging all expected information
function InitGameplayEventWriter()
{
	if( bRecordGameStatsFile && GameplayEventsWriterClass != None )
	{
		`log("Recording game events with"@GameplayEventsWriterClass);
    	GameplayEventsWriter = new(self) GameplayEventsWriterClass;
	}
	else
	{
	  `log("Gameplay events will not be recorded.");
	}
}

function ReplicateWelcomeScreen()
{
	local WorldInfo WI;

	WI = class'WorldInfo'.static.GetWorldInfo();

	if(WI.NetMode != NM_DedicatedServer)
	{
		return;
	}

	if(MyKFGRI != none)
	{
		MyKFGRI.ServerAdInfo.BannerLink = BannerLink;
		MyKFGRI.ServerAdInfo.ServerMOTD = Repl(ServerMOTD, "@nl@", Chr(10));
		MyKFGRI.ServerAdInfo.WebsiteLink= WebsiteLink;
		MyKFGRI.ServerAdInfo.ClanMotto = ClanMotto;
	}
}

//
// Accept or reject a player on the server.
// Fails login if you set the Error to a non-empty string.
// NOTE: UniqueId should not be trusted at this stage, it requires authentication
//
// TWI: Overriden from GameInfo.uc so we can use a custom ErrorMessage for bans -MattF
event PreLogin(string Options, string Address, const UniqueNetId UniqueId, bool bSupportsAuth, out string ErrorMessage)
{
	local bool bSpectator;
	local bool bPerfTesting;
	local string DesiredDifficulty, DesiredWaveLength, DesiredGameMode;

	// Check for an arbitrated match in progress and kick if needed
	if (WorldInfo.NetMode != NM_Standalone && bUsingArbitration && bHasArbitratedHandshakeBegun)
	{
		ErrorMessage = PathName(WorldInfo.Game.GameMessageClass) $ ".ArbitrationMessage";
		return;
	}

	// If this player is banned, reject him
	if (AccessControl != none && AccessControl.IsIDBanned(UniqueId))
	{
		`log(Address@"is banned, rejecting...");
		ErrorMessage = "<Strings:KFGame.KFLocalMessage.BannedFromServerString>";
		return;
	}

	// Check against what is expected from the client in the case of quick join/server browser. The server settings can change from the time the server gets the properties from the backend
	// This code is used to avoid collisions. A player may think they are joining a certain server with the options they are expecting, but its possible for the server to change
	// before this happens. ServerTakeover for instance. These options should only be provided when joining from quick match or server browser. They get removed after successfully joining a server
	if( WorldInfo.NetMode == NM_DedicatedServer && !HasOption( Options, "bJoinViaInvite" ) )
	{
		DesiredDifficulty = ParseOption( Options, "Difficulty" );
		if( !bIsVersusGame && GametypeChecksDifficulty() && DesiredDifficulty != "" && int(DesiredDifficulty) != GameDifficulty )
		{
			`log("Got bad difficulty"@DesiredDifficulty@"expected"@GameDifficulty);
			//ErrorMessage = "<Strings:KFGame.KFLocalMessage.ServerNoLongerAvailableString>";
			ErrorMessage = "Server No longer available. Mismatch difficulty.";
			return;
		}

		DesiredWaveLength = ParseOption( Options, "GameLength" );

		if(!bIsEndlessGame && !bIsVersusGame && GametypeChecksWaveLength() && DesiredWaveLength != "" && int(DesiredWaveLength) != GameLength && int(DesiredWaveLength) != 127 && int(DesiredWaveLength) != INDEX_NONE)
		{
			`log("Got bad wave length"@DesiredWaveLength@"expected"@GameLength);
			//ErrorMessage = "<Strings:KFGame.KFLocalMessage.ServerNoLongerAvailableString>";
			ErrorMessage = "Server No longer available. Mismatch GameLength.";
			return;
		}

		DesiredGameMode = ParseOption( Options, "Game" );
		if( DesiredGameMode != "" && !(DesiredGameMode ~= GetFullGameModePath()) )
		{
			`log("Got bad game mode"@DesiredGameMode@"expected"@GetFullGameModePath());
			ErrorMessage = "Server No longer available. Mismatch DesiredGameMode.";
			return;
		}
	}


	bPerfTesting = ( ParseOption( Options, "AutomatedPerfTesting" ) ~= "1" );
	bSpectator = bPerfTesting || ( ParseOption( Options, "SpectatorOnly" ) ~= "1" ) || ( ParseOption( Options, "CauseEvent" ) ~= "FlyThrough" );

	if (AccessControl != None)
	{
		AccessControl.PreLogin(Options, Address, UniqueId, bSupportsAuth, ErrorMessage, bSpectator);
	}
}

static function bool GametypeChecksDifficulty()
{
    return true;
}

static function bool GametypeChecksWaveLength()
{
    return true;
}

event PostLogin( PlayerController NewPlayer )
{
 	local KFPlayerController KFPC;
	local int OldNumSpectators;

	OldNumSpectators = NumSpectators;

 	super.PostLogin( NewPlayer );


	// Delay this by 1.5 seconds so there aren't multiple calls if everyone joins/leaves at the same time
	if( PlayfabInter != None && PlayfabInter.IsRegisteredWithPlayfab() )
	{
		SetTimer( 1.5, false, nameof(UpdateGameSettings) );
	}
	//We need to keep number of spectators as absolutely up-to-date as possible for the server browser
	else if (OldNumSpectators != NumSpectators)
	{
		UpdateGameSettings();
	}

 	KFPC = KFPlayerController(NewPlayer);
	if( KFPC != None )
	{
		KFPC.UpdatePerkOnInit();

		KFPC.InitGameplayPostProcessFX();

		if( KFPC.PlayerReplicationInfo.bOnlySpectator )
		{
			// if we're initially spectating, initialize front-end but skip lobby menu
			KFPC.ClientSetFrontEnd( KFGFxManagerClass, true );
		}
		else if( KFPC.GetTeamNum() == 255 )
		{
			// if we're initially spectating, initialize front-end but skip lobby menu
		 	if( !class'Engine'.static.IsEditor() && !class'KFGameEngine'.static.CheckSkipLobby() )
		 	{
		 		KFPC.CreateCustomizationPawn();
			}
			if( KFPC.Pawn != none && KFPawn_Customization(KFPC.Pawn) != none )
			{
				KFPawn_Customization(KFPC.Pawn).SetServerHidden( true );
				KFPC.SetCameraMode( 'PlayerZedWaiting' );
			}
			KFPC.ClientSetFrontEnd( KFGFxManagerClass, false );
		}
		else
		{
			KFPC.ClientSetFrontEnd( KFGFxManagerClass, false );

			// Only create customization pawns for a real game
		 	if( !class'Engine'.static.IsEditor() && !class'KFGameEngine'.static.CheckSkipLobby() )
		 	{
		 		KFPC.CreateCustomizationPawn();
			}
		}
	}
}

function Logout( Controller Exiting )
{
	local int OldNumSpectators;

	OldNumSpectators = NumSpectators;

	Super.Logout( Exiting );

	// Delay this by 1.5 seconds so there aren't multiple calls if everyone joins/leaves at the same time
	if( PlayfabInter != None && PlayfabInter.IsRegisteredWithPlayfab() )
	{
		SetTimer( 1.5, false, nameof(UpdateGameSettings) );
	}
	else if( OldNumSpectators != NumSpectators )
	{
		UpdateGameSettings();
	}

	if( PlayfabInter != none && PlayfabInter.IsRegisteredWithPlayfab() )
	{
		if( PlayerController(Exiting) != none )
		{
			// Check the current population to see if we need to shut down the next frame
			SetTimer( 0.01, false, nameof(CheckPopulation) );

			// Notify playfab that a player has left
			if( Exiting.PlayerReplicationInfo != None && Exiting.PlayerReplicationInfo.PlayfabPlayerId != "" )
			{
				PlayfabInter.ServerNotifyPlayerLeft( Exiting.PlayerReplicationInfo.PlayfabPlayerId );
			}
		}
	}
}

/* ProcessServerTravel()
 Optional handling of ServerTravel for network games.
*/
function ProcessServerTravel(string URL, optional bool bAbsolute)
{
	super.ProcessServerTravel( URL, bAbsolute );

	// Set the last travel time in our persistent game data
    class'KFMapTravelData'.static.SetLastTravelTime( WorldInfo.RealTimeSeconds );
    class'KFMapTravelData'.static.SetLastGameMap( WorldInfo.GetMapName(true) );

	//@HSL_BEGIN - JRO - 4/28/2016 - Recreate the session after each match
	`log("SESSIONS - Clearing ConsoleGameSessionGuid for a new map"@URL);
	KFGameEngine(Class'Engine'.static.GetEngine()).ConsoleGameSessionGuid = "";
	//@HSL_END
}

function CheckPopulation()
{
	local bool bNeedsShutdown;
	local int i;

	// We check if we need to shut down only if not doing a level transition and the game was launched by playfab services
	if( !bLevelChange && WasLaunchedByPlayfab() )
	{
		bNeedsShutdown = true;

		for( i = 0; i < GameReplicationInfo.PRIArray.Length; i++ )
		{
			if( !GameReplicationInfo.PRIArray[i].bBot )
			{
				bNeedsShutdown = false;
				break;
			}
		}
	}

	if( bNeedsShutdown )
	{
		`log("Server needs shutdown! Exiting now");
		ConsoleCommand("Exit");
	}
}


event InitAIDirector()
{
	AIDirector = new(self) class'KFAIDirector';
	AIDirector.Initialize();
}

/* Initialize the Game Conductor */
function InitGameConductor()
{
	GameConductor = new(self) GameConductorClass;
	GameConductor.Initialize();
}

/* Initialize the GRI varaibles */
function InitGRIVariables()
{
	MyKFGRI.GameDifficulty = GameDifficulty;
	MyKFGRI.GameLength = GameLength;
	MyKFGRI.ReceivedGameLength();
	MyKFGRI.bVersusGame = bIsVersusGame;
	MyKFGRI.MaxHumanCount = MaxPlayers;
	SetBossIndex();
}

//Event or maps-specific override functionality
native function bool UseSpecificBossIndex(out int ForcedIndex);

//Find and preload content for the chosen boss index
function SetBossIndex()
{
	if (!UseSpecificBossIndex(BossIndex))
	{
		BossIndex = Rand(default.AIBossClassList.Length);
	}

	MyKFGRI.CacheSelectedBoss(BossIndex);
}

/**
 * AllowCheats - Allow cheating in single player games and coop games.
 */
function bool AllowCheats(PlayerController P)
{
`if(`notdefined(ShippingPC))
	return true;
`else
	return false; // see KFPlayerController.EnableCheats
`endif
}

/** Adds all available traders to the list */
function InitTraderList()
{
	local KFTraderTrigger MyTrader;

	TraderList.Remove(0, TraderList.Length);
	foreach DynamicActors(class'KFTraderTrigger', MyTrader)
	{
		if (MyTrader.bEnabled)
		{
			TraderList.AddItem(MyTrader);
		}
	}
}

/** Stub, implement in subclasses */
function SetupNextTrader();

/** Sets the number of possible pickups on this difficulty and activates that many around the map */
function InitAllPickups()
{
	if(bDisablePickups || DifficultyInfo == none)
	{
		NumWeaponPickups = 0;
		NumAmmoPickups = 0;
	}
	else
	{
		NumWeaponPickups = ItemPickups.Length * DifficultyInfo.GetItemPickupModifier();
		NumAmmoPickups = AmmoPickups.Length * DifficultyInfo.GetAmmoPickupModifier();
	}

`if(`__TW_SDK_)
	if( BaseMutator != none )
	{
		BaseMutator.ModifyPickupFactories();
	}
`endif

	ResetAllPickups();
}

/** Called to reset all the types of pickups */
function ResetAllPickups()
{
    local int i;

	AllPickupFactories.Remove( 0, AllPickupFactories.Length );
	// Add all the item pickups
 	for ( i = 0; i < ItemPickups.Length; i++ )
 	{
 	 	AllPickupFactories.AddItem( ItemPickups[i] );
 	}
	// Add all the ammo pickups
 	for ( i = 0; i < AmmoPickups.Length; i++ )
 	{
 	 	AllPickupFactories.AddItem( AmmoPickups[i] );
 	}

	ResetPickups( ItemPickups, NumWeaponPickups );

	ResetPickups( AmmoPickups, NumAmmoPickups );
}

/** Pick random pickup items to enable and put all others to sleep */
/** Pick random pickup items to enable and put all others to sleep */
function ResetPickups( array<KFPickupFactory> PickupList, int NumPickups )
{
 	local byte i, ChosenIndex;
 	local array<KFPickupFactory>	PossiblePickups;
	local int NumIterations;
	
	if (PickupList.Length == 0)
		return;

    PossiblePickups = PickupList;

	if (OutbreakEvent != none && OutbreakEvent.ActiveEvent.bUnlimitedWeaponPickups && KFPickupFactory_Item(PickupList[0]) != none)
	{
		NumIterations = Min(NumPickups, PickupList.Length - 1);
	}
	else
	{
		NumIterations = Min(NumPickups, PickupList.Length);
	}

 	for ( i = 0; i < NumIterations; i++ )
 	{
 		ChosenIndex = Rand( PossiblePickups.Length );
 		PossiblePickups[ChosenIndex].Reset();
        PossiblePickups.Remove( ChosenIndex, 1 );
 	}

	// Put any pickup factories that weren't enabled to sleep
 	for ( i = 0; i < PossiblePickups.Length; i++ )
 	{
 	 	PossiblePickups[i].StartSleeping();
 	}
}

/** Find a new item pickup factory to enable after a certain amount of time */
function EnableNewPickup( array<KFPickupFactory> PickupList, float RespawnDelay, KFPickupFactory LastPickup )
{
	local KFPickupFactory ActiveFactory;

	ActiveFactory = DetermineNextPickup( PickupList, LastPickup );

`if(`__TW_SDK_)
	if( BaseMutator != none )
	{
		BaseMutator.ModifyActivatedPickupFactory( ActiveFactory, RespawnDelay );
	}
`endif

	ActivateNextPickup( ActiveFactory, RespawnDelay );

	if (ActiveFactory != LastPickup)
	{
		LastPickup.StartSleeping();
	}
}

/** Pick a new factory from provided list */
function KFPickupFactory DetermineNextPickup( array<KFPickupFactory> PickupList, KFPickupFactory LastPickup )
{
	local byte i;
	local array<KFPickupFactory> PossibleFactories;

	for ( i = 0; i < PickupList.length; i++ )
	{
	 	if ( PickupList[i] != LastPickup && PickupList[i].IsInState('Sleeping') && !PickupList[i].bToBeActivated )
	 	{
	 		PossibleFactories.AddItem( PickupList[i] );
	 	}
	}

  	if ( PossibleFactories.Length > 0 )
	{
		return PossibleFactories[ Rand( PossibleFactories.Length ) ];
	}
	else
	{
	    return LastPickup;
	}
}

/** Activate selected pickup factory */
function ActivateNextPickup( KFPickupFactory NextFactory, int RespawnDelay )
{
	if( NextFactory != none )
	{
		NextFactory.bToBeActivated = true;
		NextFactory.SetTimer( RespawnDelay, , nameof(NextFactory.Reset) );
	}
}

/************************************************************************************
 * @name		Spawning
 ***********************************************************************************/

/** This is called when the generic customization points have been streamed in */
function CustomizationPointsInitialized()
{
	local KFPlayerController KFPC;
	local KFPawn_Customization KFPCustom;

	foreach LocalPlayerControllers(class'KFPlayerController', KFPC)
	{
		if ( KFPC.Pawn != none )
		{
            KFPCustom = KFPawn_Customization( KFPC.Pawn );
            if ( KFPCustom != none && !KFPCustom.bUsingCustomizationPoint )
            {
		     	KFPCustom.MoveToCustomizationPoint();
	     	}
     	}
	}
}

/** Overridden to set bNoCollisionFail in spawn to true */
function Pawn SpawnDefaultPawnFor(Controller NewPlayer, NavigationPoint StartSpot)
{
	local class<Pawn> DefaultPlayerClass;
	local Rotator StartRotation;
	local Pawn ResultPawn;

	DefaultPlayerClass = GetDefaultPlayerClass(NewPlayer);

	// don't allow pawn to be spawned with any pitch or roll
	StartRotation.Yaw = StartSpot.Rotation.Yaw;

	ResultPawn = Spawn(DefaultPlayerClass,,,StartSpot.Location,StartRotation,,true);
	if ( ResultPawn == None )
	{
		`log("Couldn't spawn player of type "$DefaultPlayerClass$" at "$StartSpot);
	}
	return ResultPawn;
}

/** Exists to create a customization pawn rather than the default pawn */
function KFPawn SpawnCustomizationPawn( NavigationPoint StartSpot )
{
	local Rotator StartRotation;
	local KFPawn_Customization ResultPawn;

	// don't allow pawn to be spawned with any pitch or roll
	StartRotation.Yaw = StartSpot.Rotation.Yaw;

	ResultPawn = Spawn(CustomizationPawnClass,,,StartSpot.Location,StartRotation,,true);
	if ( ResultPawn == None )
	{
		`log("Couldn't spawn player of type "$CustomizationPawnClass$" at "$StartSpot);
	}

	// Init location and rotation
	ResultPawn.SetUpdatedMovementData( StartSpot.Location, StartRotation );

	return ResultPawn;
}

/** Overwritten to restart the player even if we are using a customization pawn*/
function StartHumans()
{
	local KFPlayerController KFPC;
	local int NumPlayerPawns;

	foreach WorldInfo.AllControllers( class'KFPlayerController', KFPC )
	{
		if( bGameEnded )
		{
			return; // telefrag ended the game with ridiculous frag limit
		}

		if( KFPC.Pawn == None || KFPawn_Customization(KFPC.Pawn) != none )
		{
			if( KFPC.CanRestartPlayer() && KFPC.GetTeamNum() != 255 )
			{
				RestartPlayer( KFPC );
			}
		}

		if( KFPC.Pawn != None || KFPC.bWaitingForClientPerkData )
		{
			NumPlayerPawns++;
		}
	}

	bOnePlayerAtStart = (NumPlayerPawns == 1);
}

function RestartPlayer(Controller NewPlayer)
{
	local KFPlayerController KFPC;
	local KFPerk MyPerk;
`if(`notdefined(ShippingPC))
	local bool bIsBenchmark;
`endif

	KFPC = KFPlayerController( NewPlayer );

	// Make sure the perk is initialized before spawning in, if not, wait for it
	// @NOTE: We still do this in standalone games because we may need to wait for Steam -MattF
`if(`notdefined(ShippingPC))
	// Benchmark silliness. If we allow this code to run, it takes control away from the benchmark
	// matinee director and the command fails. -MattF
	if( !class'WorldInfo'.Static.IsConsoleBuild()
		&& !class'WorldInfo'.Static.IsConsoleDedicatedServer()
		&& InStr(WorldInfo.GetLocalURL(), "?CAUSEEVENT=BENCHMARK",, true) > -1 )
	{
		bIsBenchmark = true;
	}
    if( KFPC != none && KFPC.GetTeamNum() != 255 && !bIsBenchmark )
`else
	if( KFPC != none && KFPC.GetTeamNum() != 255 )
`endif
    {
    	MyPerk = KFPC.GetPerk();
    	if( MyPerk == none || !MyPerk.bInitialized )
    	{
    		KFPC.WaitForPerkAndRespawn();
    		return;
    	}
    }

	// If we have a customization pawn, destroy it before spawning a new pawn with super.RestartPlayer
    if( NewPlayer.Pawn != none && KFPawn_Customization(NewPlayer.Pawn) != none )
	{
	 	NewPlayer.Pawn.Destroy();
	}

  	super.RestartPlayer( NewPlayer );

  	if( NewPlayer.Pawn != none )
  	{
		if( KFPC != none )
		{
			// Initialize game play post process effects such as damage, low health, etc.
			KFPC.InitGameplayPostProcessFX();

	        // Start fading in the camera
	        KFPC.ClientSetCameraFade( true, MakeColor(255,255,255,255), vect2d(1.f, 0.f), 0.6f, true );
		}
	}
}

/** Returns a low rating if other players are nearby (spawn will fail) */
function float RatePlayerStart(PlayerStart P, byte Team, Controller Player)
{
	local float Rating;

`if(`notdefined(ShippingPC))
	// Random starts are done by disabling starts in kismet.  It's not ideal,
	// but we can assume all disabled starts are disabled this way.
	if ( !P.bEnabled && class'KFGameEngine'.static.CheckNoRandomStart() )
	{
		P.bEnabled = TRUE;
	}
`endif

	Rating = Super.RatePlayerStart(P, Team, Player);

	// If bEnabled (Rating == 5.f), check proximity
	if ( P.bEnabled )
	{
		if ( !CheckSpawnProximity( P, Player, Team ) )
		{
		 	return 5.1f; // Higher than disabled, but lower than default
		}
	}

	return Rating;
}

/** returns whether the given Controller StartSpot property should be used as the spawn location for its Pawn */
function bool ShouldSpawnAtStartSpot(Controller Player)
{
	local PlayerStart StartSpot;

	// Without NM_Standalone (see super) for online predicted spawn location / texture streaming
	if ( Player != None && Player.StartSpot != None &&
	     (IsInitialSpawnPointSelection(WorldInfo) || (Player.PlayerReplicationInfo != None && Player.PlayerReplicationInfo.bWaitingPlayer)) )
	{
		StartSpot = PlayerStart(Player.StartSpot);
		if ( StartSpot == None )
		{
			// Not a PlayerStart class (e.g. Teleporter / Play From Here)
			return true;
		}

		// 5 == disabled, 5.1 == collision, 6 == okay
		return RatePlayerStart(StartSpot, Player.GetTeamNum(), Player) >= 6.0;
	}

	return false;
}

/** Find a predefined spot for PlayerCustomization */
function KFCustomizationPoint FindCustomizationStart( Controller Player )
{
	local KFCustomizationPoint CP;

	ForEach AllActors( class 'KFCustomizationPoint', CP )
	{
		if( CheckSpawnProximity(CP, Player, Player.GetTeamNum(), true) )
		{
			return CP;
		}
	}

	return CP;
}

/** Returns false if this is near another player or in-use spawn point */
static function bool CheckSpawnProximity( NavigationPoint P, Controller Player, byte TeamNum, optional bool bCustomizationPoint )
{
	local PlayerController PC;
	local KFPawn_Customization CPawn;
	local WorldInfo WI;

	WI = class'WorldInfo'.static.GetWorldInfo();
	foreach WI.AllControllers( class'PlayerController', PC )
	{
		if( PC == Player )
		{
			continue;
		}

		// During initial StartSpot selection, before 1st spawn, choose a unique spawn for each player
		if( IsInitialSpawnPointSelection(WI) && !bCustomizationPoint )
		{
			if ( PC.StartSpot == P && PC.GetTeamNum() == TeamNum )
			{
				return false;
			}
		}
		// During gameplay, or using customization starts, ignore StartSpot and use distance
		else if( PC.Pawn != None && !PC.Pawn.bHidden )
		{
			if( bCustomizationPoint )
			{
				// invisible customization pawns are okay
				CPawn = KFPawn_Customization(PC.Pawn);
				if( CPawn != None && CPawn.bServerHidden )
				{
					continue;
				}
			}

			if( VSizeSq(PC.Pawn.Location - P.Location) < Square(2.1 * PC.Pawn.GetCollisionRadius()) )
			{
				return false;
			}
		}
	}
	return true;
}

static function bool IsInitialSpawnPointSelection( WorldInfo WI )
{
	return WI.Game != none ? WI.Game.bWaitingToStartMatch : !WI.GRI.bMatchHasBegun;
}

/* @see GameInfo::SetPlayerDefaults */
function SetPlayerDefaults(Pawn PlayerPawn)
{
	local KFPawn KFP;

	KFP = KFPawn(PlayerPawn);
	if ( KFP != none && KFP.GetPerk() != none )
	{
		if ( KFP.GetPerk() != none )
		{
			KFP.GetPerk().SetPlayerDefaults(KFP);
		}

		KFP.bIgnoreTeamCollision = bDisableTeamCollision;
	}

	if ( BaseMutator != None )
	{
		BaseMutator.ModifyPlayer(PlayerPawn);
	}

	PlayerPawn.PhysicsVolume.ModifyPlayer(PlayerPawn);
}

function ModifyGroundSpeed(KFPawn PlayerPawn, out float GroundSpeed)
{
	if(OutbreakEvent != none)
	{
		OutbreakEvent.ModifyGroundSpeed(PlayerPawn, GroundSpeed);
	}
}

function ModifySprintSpeed(KFPawn PlayerPawn, out float SprintSpeed);

/** Used by wave based game types */
function bool IsWaveActive();

/** Scale to use against WaveTotalAI to determine full wave size */
function float GetTotalWaveCountScale()
{
	//Boss wave, don't scale it.
	if (MyKFGRI.IsBossWave())
	{
		return 1.0f;
	}

	if (OutbreakEvent != none && OutbreakEvent.ActiveEvent.WaveAICountScale.Length > 0)
	{
		return GetLivingPlayerCount() > OutbreakEvent.ActiveEvent.WaveAICountScale.Length ? OutbreakEvent.ActiveEvent.WaveAICountScale[OutbreakEvent.ActiveEvent.WaveAICountScale.Length - 1] : OutbreakEvent.ActiveEvent.WaveAICountScale[GetLivingPlayerCount() - 1];
	}

	return 1.0f;
}

/** Returns NumAlwaysRelevantZeds, the number of remaining zeds before they become bAlwaysRelevant=true */
static function float GetNumAlwaysRelevantZeds()
{
	return default.NumAlwaysRelevantZeds;
}

/** Allow specific game type to override the spawn class.  Default implementation returns from the AI class list. */
function class<KFPawn_Monster> GetAISpawnType(EAIType AIType)
{
    return AIClassList[AIType];
}

/** Allow specific game type to override the boss spawn class.  Default implementation returns from the AI class list. */
function class<KFPawn_Monster> GetBossAISpawnType()
{
	return GetSpecificBossClass(BossIndex, KFMapInfo(WorldInfo.GetMapInfo()));
}

static function class<KFPawn_Monster> GetSpecificBossClass(int Index, KFMapInfo MapInfo = none)
{
	local array< class<KFPawn_Monster> > ClassList;

	ClassList = default.AIBossClassList;

	if (MapInfo != none)
	{
		MapInfo.ModifyGameClassBossAIClassList(ClassList);
	}

	if (Index < 0 || Index >= ClassList.Length)
	{
		return none;
	}

	return ClassList[Index];
}

/** Allow gametype to do any adjustments to the spawned AI pawn */
event PrePossessAdjustments(KFPawn NewSpawn);

/** Allow specific game types to modify the spawn rate at a global level */
function float GetGameInfoSpawnRateMod()
{
	local float SpawnRateMod;

	SpawnRateMod = 1.f;

	if (OutbreakEvent != none)
	{
		SpawnRateMod *= 1.f / OutbreakEvent.ActiveEvent.SpawnRateMultiplier;
	}

	if (MyKFGRI != none)
	{
		SpawnRateMod *= MyKFGRI.GetMapObjectiveSpawnRateMod();
	}

	return SpawnRateMod;
}

/** Whether or not a specific primary weapon is allowed.  Called at player spawn time while setting inventory. */
function bool AllowPrimaryWeapon(string ClassPath)
{
    return true;
}

/** Whether or not a specific secondary weapon is allowed.  Called at player spawn time while setting inventory. */
function bool AllowSecondaryWeapon(string ClassPath)
{
    return true;
}

/** Allows gametype to adjust starting grenade count.  Called at player spawn time from GiveInitialGrenadeCount in the inventory. */
function int AdjustStartingGrenadeCount(int CurrentCount)
{
    return CurrentCount;
}

/** Allows gametype to validate a perk for the current match */
function bool IsPerkAllowed(class<KFPerk> PerkClass)
{
    return true;
}

/************************************************************************************
 * @name		Difficulty Scaling
 ***********************************************************************************/

/** Adjusts AI pawn default settings by game difficulty and player count */
function SetMonsterDefaults( KFPawn_Monster P )
{
	local float HealthMod;
	local float HeadHealthMod;
	local float TotalSpeedMod, StartingSpeedMod;
	local float DamageMod;
	local int LivingPlayerCount;
	local int i;

    LivingPlayerCount = GetLivingPlayerCount();

   	DamageMod = 1.0;
    HealthMod = 1.0;
    HeadHealthMod = 1.0;

    // Scale health and damage by game conductor values for versus zeds
    if( P.bVersusZed )
    {
    	DifficultyInfo.GetVersusHealthModifier(P, LivingPlayerCount, HealthMod, HeadHealthMod);

        HealthMod *= GameConductor.CurrentVersusZedHealthMod;
        HeadHealthMod *= GameConductor.CurrentVersusZedHealthMod;

    	// scale damage
        P.DifficultyDamageMod = DamageMod * GameConductor.CurrentVersusZedDamageMod;

        StartingSpeedMod = 1.f;
		TotalSpeedMod = 1.f;
    }
    else
    {
    	DifficultyInfo.GetAIHealthModifier(P, GameDifficulty, LivingPlayerCount, HealthMod, HeadHealthMod);
		DamageMod = DifficultyInfo.GetAIDamageModifier(P, GameDifficulty,bOnePlayerAtStart);

    	// scale damage
        P.DifficultyDamageMod = DamageMod;

        StartingSpeedMod = DifficultyInfo.GetAISpeedMod(P, GameDifficulty);
		TotalSpeedMod = GameConductor.CurrentAIMovementSpeedMod * StartingSpeedMod;
    }

    //`log("Start P.GroundSpeed = "$P.GroundSpeed$" GroundSpeedMod = "$GroundSpeedMod$" percent of default = "$(P.default.GroundSpeed * GroundSpeedMod)/P.default.GroundSpeed$" RandomSpeedMod= "$RandomSpeedMod);

	// scale movement speed
	P.GroundSpeed = P.default.GroundSpeed * TotalSpeedMod;
	P.SprintSpeed = P.default.SprintSpeed * TotalSpeedMod;

	// Store the difficulty adjusted ground speed to restore if we change it elsewhere
	P.NormalGroundSpeed = P.GroundSpeed;
	P.NormalSprintSpeed = P.SprintSpeed;
	P.InitialGroundSpeedModifier = StartingSpeedMod;

	//`log(P$" GroundSpeed = "$P.GroundSpeed$" P.NormalGroundSpeed = "$P.NormalGroundSpeed);

	// Scale health by difficulty
	P.Health = P.default.Health * HealthMod;
	if( P.default.HealthMax == 0 )
	{
	   	P.HealthMax = P.default.Health * HealthMod;
	}
	else
	{
	   	P.HealthMax = P.default.HealthMax * HealthMod;
	}

	P.ApplySpecialZoneHealthMod(HeadHealthMod);
	P.GameResistancePct = DifficultyInfo.GetDamageResistanceModifier(LivingPlayerCount);

	// look for special monster properties that have been enabled by the kismet node
	for (i = 0; i < ArrayCount(SpawnedMonsterProperties); i++)
	{
		// this property is currently enabled
		if (SpawnedMonsterProperties[i] != 0)
		{
			// do the action associated with that property
			switch (EMonsterProperties(i))
			{
			case EMonsterProperties_Enraged:
				P.SetEnraged(true);
				break;
			case EMonsterProperties_Sprinting:
				P.bSprintOverride=true;
				break;
			}
		}
	}

	if (OutbreakEvent != none)
	{
		OutbreakEvent.AdjustMonsterDefaults(P);
	}

	// debug logging
   	`log("==== SetMonsterDefaults for pawn: " @P @"====",bLogAIDefaults);
	`log("HealthMod: " @HealthMod @ "Original Health: " @P.default.Health @" Final Health = " @P.Health, bLogAIDefaults);
	`log("HeadHealthMod: " @HeadHealthMod @ "Original Head Health: " @P.default.HitZones[HZI_HEAD].GoreHealth @" Final Head Health = " @P.HitZones[HZI_HEAD].GoreHealth, bLogAIDefaults);
	`log("GroundSpeedMod: " @TotalSpeedMod @" Final Ground Speed = " @P.GroundSpeed, bLogAIDefaults);
	//`log("HiddenSpeedMod: " @HiddenSpeedMod @" Final Hidden Speed = " @P.HiddenGroundSpeed, bLogAIDefaults);
	`log("SprintSpeedMod: " @TotalSpeedMod @" Final Sprint Speed = " @P.SprintSpeed, bLogAIDefaults);
	`log("DamageMod: " @DamageMod @" Final Melee Damage = " @P.MeleeAttackHelper.BaseDamage * DamageMod, bLogAIDefaults);
	//`log("bCanSprint: " @P.bCanSprint @ " from SprintChance: " @SprintChance, bLogAIDefaults);
}

/************************************************************************************
 * @name		Team
 ***********************************************************************************/

/** SetTeam()
* Change Other's team to NewTeam.
* @param Other:  the controller which wants to change teams
* @param NewTeam:  the desired team.
* @param bNewTeam:  if true, broadcast team change notification
*/
function SetTeam(Controller Other, KFTeamInfo_Human NewTeam)
{
	if( Other.PlayerReplicationInfo == None || Other.PlayerReplicationInfo.bOnlySpectator || NewTeam == Other.PlayerReplicationInfo.Team )
	{
		return;
	}

	// remove the controller from his old team
	if ( Other.PlayerReplicationInfo.Team != None )
	{
		Other.PlayerReplicationInfo.Team.RemoveFromTeam(Other);
		Other.PlayerReplicationInfo.Team = none;
	}

	if ( NewTeam == None || (NewTeam != none && NewTeam.AddToTeam(Other)) )
	{
		if ( (NewTeam!=None) && ((WorldInfo.NetMode != NM_Standalone) || (PlayerController(Other) == None) || (PlayerController(Other).Player != None)) )
			BroadcastLocalizedMessage( GameMessageClass, 3, Other.PlayerReplicationInfo, None, NewTeam );

        GameConductor.HandlePlayerChangedTeam();
	}

    // Force net update for UI snappyness
    Other.PlayerReplicationInfo.bNetDirty = true;
    Other.PlayerReplicationInfo.bForceNetUpdate = true;
}

/* create a player team, and fill from the team roster
*/
function CreateTeam(int TeamIndex)
{
	Teams[TeamIndex] = spawn(class'KFGame.KFTeamInfo_Human');
	GameReplicationInfo.SetTeam(TeamIndex, Teams[TeamIndex]);
}

/** Called by Gameinfo::Login(), initial team pick */
function byte PickTeam(byte Current, Controller C, const out UniqueNetId PlayerId)
{
	return 0;
}

/** Return whether a team change is allowed. */
function bool ChangeTeam(Controller Other, int N, bool bNewTeam)
{
	// AI
	if( PlayerController(Other) == none )
	{
		SetTeam( Other, Teams[N] );
		return true;
	}

	// Human
    if( Other.PlayerReplicationInfo != none
    	&& !Other.PlayerReplicationInfo.bOnlySpectator
    	&& Other.PlayerReplicationInfo.Team != Teams[0] )
    {
		SetTeam( Other, Teams[0] );
		return true;
	}

	return false;
}

/**
 * Return whether Viewer is allowed to spectate from ViewTarget's PoV.
 *   Used to prevent players from spectating zeds when the DummyPRI is active.
 *
 */
function bool CanSpectate( PlayerController Viewer, PlayerReplicationInfo ViewTarget )
{
	local PlayerController TargetController;

	// Normal PRI's should be replicatable, DummyPRI is not, indicating a zed
	if( ViewTarget.RemoteRole == ROLE_None )
	{
		return false;
	}

	// We only want players with valid pawns
	TargetController = PlayerController( ViewTarget.Owner );
	return TargetController != none && TargetController.Pawn != none && TargetController.Pawn.IsAliveAndWell();
}

/************************************************************************************
 * @name		Damage
 ***********************************************************************************/

/*	Use reduce damage for friendly fire, etc. */
function ReduceDamage(out int Damage, Pawn Injured, Controller InstigatedBy, vector HitLocation, out vector Momentum, class<DamageType> DamageType, Actor DamageCauser, TraceHitInfo HitInfo)
{
	local class<KFDamageType> KFDT;

	KFDT = class<KFDamageType>(DamageType);

    // Don't damage the instigator if the flag is set
    if ( KFDT != None && InstigatedBy != None && InstigatedBy == Injured.Controller )
    {
    	if( KFDT.default.bNoInstigatorDamage )
    	{
			Damage = 0;
    	}
    	else if( !KFDT.default.bIgnoreSelfInflictedScale )
    	{
    		Damage *= DifficultyInfo.GetSelfInflictedDamageMod();
    	}

		// No momentum if no damage
		Momentum = vect(0,0,0);
    }

	if ( Damage > 0 && InstigatedBy != None && InstigatedBy != Injured.Controller )
	{
		// Friendly fire is scaled for all humans
		if ( Injured.IsHumanControlled() && Injured.GetTeamNum() == InstigatedBy.GetTeamNum() )
		{
			if (KFDT.default.bNoFriendlyFire)
			{
				Damage = 0;
			}
			else
			{
				Damage *= FriendlyFireScale;
			}

			// For now, don't apply momentum transfer to friendly pawns
			Momentum = vect(0,0,0);
		}
	}

	// checks neutral zone and god mode and calls mutator hook
	Super.ReduceDamage(Damage, Injured, InstigatedBy, HitLocation, Momentum, DamageType, DamageCauser, HitInfo);

	if (OutbreakEvent != none)
	{
		OutbreakEvent.ReduceDamage(Damage, Injured, InstigatedBy, DamageType, HitInfo);
	}
}

function NotifyTakeHit(KFPawn Pawn, Controller InstigatedBy, vector HitLocation, int Damage,
	class<DamageType> DamageType, vector Momentum, Actor DamageCauser);

function Killed(Controller Killer, Controller KilledPlayer, Pawn KilledPawn, class<DamageType> DT)
{
	local KFPlayerReplicationInfo KilledPRI;
	local KFPlayerController KFPC;
	local int PlayerScoreDelta, TeamPenalty;
	local KFPerk KFPCP;
	local KFPawn_Monster MonsterPawn;
	local string KillerLabel;
	local class<DamageType> LastHitByDamageType;
	local int i;

	if( KilledPlayer != None && KilledPlayer.bIsPlayer )
	{
        // Let the game conductor know a human team player died
        if( KilledPlayer.GetTeamNum() == 0 && Killer != none && Killer.GetTeamNum() == 255 )
        {
            GameConductor.NotifyHumanTeamPlayerDeath();
        }

		KilledPRI = KFPlayerReplicationInfo( KilledPlayer.PlayerReplicationInfo );
		if( KilledPRI != none )
		{
			if ( KilledPlayer == Killer )
			{
				KillerLabel = "self";
			}
			else if( Killer != none )
			{
				if( Killer.Pawn != none )
				{
					KillerLabel = string(Killer.Pawn.Class.Name);
				}
				else
				{
				    KillerLabel = string(Killer.Class.Name); // well SOMETHING killed me (vs), no pawn, log the controller
				}
			}
			else
			{
				KillerLabel = "Player"; // Need to always have some label
			}

			// Dosh penalty on death
        	PlayerScoreDelta = GetAdjustedDeathPenalty( KilledPRI );
        	`log("SCORING: Player" @ KilledPRI.PlayerName @ "next starting dosh =" @ PlayerScoreDelta + KilledPRI.Score, bLogScoring);
        	KilledPRI.AddDosh( PlayerScoreDelta );
        	TeamPenalty = GetAdjustedTeamDeathPenalty( KilledPRI );

        	if( KilledPRI.Team != none )
        	{
	        	KFTeamInfo_Human(KilledPRI.Team).AddScore( -TeamPenalty );
	        	`log("SCORING: Team lost" @ TeamPenalty @ "dosh for a player dying", bLogScoring);
	        }

        	KilledPRI.PlayerHealth = 0;
        	KilledPRI.PlayerHealthPercent = 0;
		}

		KFPC = KFPlayerController( KilledPlayer );
		`log("KFGameInfo - Killed - Current Killed Player is not a valid KFPlayerController. KilledPlayer:" @ KilledPlayer, KFPC == none);
		`AnalyticsLog(("player_death",
					   KilledPRI,
					   KillerLabel,
					   DT.Name,
					   "#"$MyKFGRI.WaveNum,
					   KFPC != none ? KFPC.GetPerk().PerkName : "",
					   KFPC != none ? KFPC.GetPerk().GetLevel() : byte(0),
					   (KilledPawn != none && KilledPawn.InvManager != none) ? KFInventoryManager(KilledPawn.InvManager).DumpInventory() : ""));
	}

	Super.Killed( Killer, KilledPlayer, KilledPawn, DT );

	/* __TW_ANALYTICS_ */
	`RecordKillEvent( NORMAL, Killer, DT, KilledPlayer );

	// Maybe do a DramaticEvent that may trigger Zedtime when someone is killed
	if( Killer != KilledPlayer )
	{
		CheckZedTimeOnKill( Killer, KilledPlayer, KilledPawn, DT );
	}

	// Update pawn counters
	if( KilledPawn != none && KilledPawn.GetTeamNum() == 255 )
	{
		MonsterPawn = KFPawn_Monster(KilledPawn);

		// Add Assists.
		if (MonsterPawn != none)
		{
			for(i = 0; i < MonsterPawn.DamageHistory.length; i++)
			{
				// The killer will receive dosh later.
				if (MonsterPawn.DamageHistory[i].DamagerController == Killer)
				{
					continue;
				}

				if (MonsterPawn.DamageHistory[i].TotalDamage > 0 && MonsterPawn.DamageHistory[i].DamagerController != none && KFPlayerController(MonsterPawn.DamageHistory[i].DamagerController) != none)
				{
					KFPlayerController(MonsterPawn.DamageHistory[i].DamagerController).AddZedAssist(MonsterPawn.class);
				}
			}
		}

		if( Killer != none )
		{
			KFPC = KFPlayerController( Killer );
			if( KFPC != none )
			{
				if( MonsterPawn != none	)
				{
					LastHitByDamageType = GetLastHitByDamageType( DT, MonsterPawn, Killer );

					//Chris: We have to do it earlier here because we need a damage type
					KFPC.AddZedKill( MonsterPawn.class, GameDifficulty, LastHitByDamageType, true );

					KFPCP = KFPC.GetPerk();
					if( KFPCP != none )
					{
						if( KFPCP.CanEarnSmallRadiusKillXP( LastHitByDamageType ) )
						{
							if(KFPCP.GetPerkClass() == class'KFPerk_Berserker'.static.GetPerkClass())
							{
								CheckForSmallRadiusKill( MonsterPawn, KFPC, class'KFPerk_Berserker' );
							}
							else if(KFPCP.GetPerkClass() == class'KFPerk_Survivalist'.static.GetPerkClass())
							{
								CheckForSmallRadiusKill( MonsterPawn, KFPC, class'KFPerk_Survivalist' );
							}
						}

						KFPCP.AddVampireHealth( KFPC, LastHitByDamageType );
					}
				}
			}
		}
		else if (class<KFDamageType>(DT) != none && class<KFDamageType>(DT).default.bIsTrapDamage)
		{
			foreach WorldInfo.AllControllers(class'KFPlayerController', KFPC)
			{
				KFPC.AddZedKill(MonsterPawn.Class, GameDifficulty, DT, false);
			}
		}

		RefreshMonsterAliveCount();

		if( SpawnManager != None && MyKFGRI != none )
		{
			UpdateAIRemaining();

			if( !MyKFGRI.IsEndlessWave() && MyKFGRI.AIRemaining <= class'KFGameInfo'.static.GetNumAlwaysRelevantZeds() )
			{
				//Tell the remaining pawns to set themselves relevant.
				foreach WorldInfo.AllPawns( class'KFPawn_Monster', MonsterPawn )
				{
					MonsterPawn.CheckShouldAlwaysBeRelevant();
				}
			}

			`log("@@@@ ZED COUNT DEBUG: MyKFGRI.AIRemaining =" @ MyKFGRI.AIRemaining, bLogAICount);
			`log("@@@@ ZED COUNT DEBUG: AIAliveCount =" @ AIAliveCount, bLogAICount);
		}
	}
    //Non-neutral kill, send through PC for other tracking
    else if (KilledPawn != none)
    {
        if (Killer != none)
        {
            KFPC = KFPlayerController(Killer);
            if (KFPC != none)
            {
                KFPC.AddNonZedKill(KilledPawn.class, GameDifficulty);
            }
        }
    }
}

event UpdateAIRemaining()
{
	if (Role == ROLE_AUTHORITY)
	{
		if (MyKFGRI != none && SpawnManager != none)
		{
			RefreshMonsterAliveCount();
			MyKFGRI.AIRemaining = Max(0.0f, SpawnManager.WaveTotalAI - NumAIFinishedSpawning) + AIAliveCount;
		}
	}
}
/** Get Last Damage type current monster was hit by, just in case passed in damage has no definition. */
function class<DamageType> GetLastHitByDamageType(class<DamageType> DT, KFPawn_Monster P, Controller Killer)
{
	local class<KFDamageType> RealDT;

	// Null check
	if( DT == none )
	{
		return none;
	}

	RealDT = class<KFDamageType>(DT);

	// Some damage types don't have weapon defs (Bleeding) in this case, give the kill to the last damage type done. Make sure we were the last one to hit them with this weapon.
	if( RealDT != none )
	{
		if( RealDT.default.WeaponDef == none && P.HitFxInfo.DamageType != none && Killer == P.LastHitBy )
		{
			if(!RealDT.default.bAnyPerk && !RealDT.default.bCausedByWorld && RealDT.default.DoT_Type != DOT_Bleeding)
			{
				`warn("Damage Type "@RealDT.Name@" has not had its weapon definition initialized");
			}

			RealDT = P.HitFxInfo.DamageType;
		}
	}
	else
	{
		`warn( "GetLastHitByDamageType() Received non-KFDamageType damagetype:"@DT);
	}

	return RealDT;
}

function BroadCastLastManStanding()
{
	//if multiplayer
	BroadcastLocalized(self, class'KFLocalMessage_Priority', GMT_LastPlayerStanding, none );
}

function BroadcastDeathMessage(Controller Killer, Controller Other, class<DamageType> damageType)
{
	if( Killer == none )
	{
		// If a zed died from no killer, it's very likely that they killed themselves. Skip the death message.
		if( Other.GetTeamNum() != 255 )
		{
			// Probably killed by an AI that no longer exists or a player that left the game
			BroadcastLocalized(self, class'KFLocalMessage_Game', KMT_Killed, none, Other.PlayerReplicationInfo, damageType );
		}
	}
	else if( Killer == Other )
	{
		// Suicide
		BroadcastLocalized( self, class'KFLocalMessage_Game', KMT_Suicide, none, Other.PlayerReplicationInfo );
	}
	else
	{
		// Optimization, try to use IsHumanControlled() before we cast
		if( (Killer.Pawn != none && !Killer.Pawn.IsHumanControlled()) || KFAIController(Killer) != none )
		{
			BroadcastLocalized( self, class'KFLocalMessage_Game', KMT_Killed, none, Other.PlayerReplicationInfo, Killer.Pawn != none ? Killer.Pawn.Class : class'KFPawn_Human' );
		}
		else
		{
			BroadcastLocalized( self, class'KFLocalMessage_PlayerKills', KMT_PlayerKillPlayer, Killer.PlayerReplicationInfo, Other.PlayerReplicationInfo );
		}
	}
	if (Other != none && Other.GetTeamNum() != 255)
	{
		//do timer to double check group didnt get wasted by hans' nade spam or something like that
		SetTimer(1.f, false, nameOf(CheckShouldBroadcastLastManStanding));
	}
}

function CheckShouldBroadcastLastManStanding()
{
	if(WorldInfo.NetMode != NM_Standalone && GetLivingPlayerCount() == 1 && !MyKFGRI.bTraderIsOpen && MyKFGRI.bMatchHasBegun && !MyKFGRI.bMatchIsOver)
	{
		BroadCastLastManStanding();
		`TraderDialogManager.PlayLastManStandingDialog(WorldInfo);
	}
}

/**
 * @brief Calculates the dosh penalty or minimum dosh spawning amount
 *
 * @param KilledPlayerPRI The killed player's PRI
 * @param bLateJoiner If true, give late joiners money without penalty
 * @return Rounded amount of dosh
 */
function int GetAdjustedDeathPenalty( KFPlayerReplicationInfo KilledPlayerPRI, optional bool bLateJoiner=false );

/**
 * @brief Calculates the dosh penalty for the team's jackpot
 *
 * @param KilledPlayerPRI The killed player's PRI
 * @return Rounded amount of dosh to be substracted
 */
function int GetAdjustedTeamDeathPenalty( KFPlayerReplicationInfo KilledPlayerPRI )
{
	return Round( KilledPlayerPRI.Score * GameDifficulty * TeamDeathPenaltyPerc );
}

function BossDied(Controller Killer, optional bool bCheckWaveEnded = true)
{
	local KFPlayerController KFPC;
	foreach WorldInfo.AllControllers(class'KFPlayerController', KFPC)
	{
		if (KFPC != none)
		{
			KFPC.ClientOnBossDied();
		}
	}
}

/************************************************************************************
 * @name		Scoring/DO$H
 ***********************************************************************************/

static function int GetBossKillScore()
{
	return default.POINTS_FOR_BOSS_KILL;
}

function ScoreDamage( int DamageAmount, int HealthBeforeDamage, Controller InstigatedBy, Pawn DamagedPawn, class<DamageType> damageType )
{
	if( InstigatedBy == none
		|| InstigatedBy.PlayerReplicationInfo == none
		|| InstigatedBy.GetTeamNum() == DamagedPawn.GetTeamNum() )
	{
		return;
	}

	if (InstigatedBy.bIsPlayer)
	{
		DamageAmount = Min(DamageAmount, HealthBeforeDamage);
		KFPlayerReplicationInfo(InstigatedBy.PlayerReplicationInfo).DamageDealtOnTeam += DamageAmount;
		if (InstigatedBy.Pawn != none)
		{
			KFPlayerController(InstigatedBy).AddTrackedDamage(DamageAmount, damageType, InstigatedBy.Pawn.Class, DamagedPawn.Class);
		}
	}


	if (OutbreakEvent != none)
	{
		OutbreakEvent.AdjustScoreDamage(InstigatedBy, DamagedPawn, damageType);
	}
}

function ScoreHeal(int HealAmount, int HealthBeforeHeal, Controller InstigatedBy, Pawn HealedPawn, class<DamageType> DamageType)
{
	super.ScoreHeal(HealAmount, HealthBeforeHeal, InstigatedBy, HealedPawn, DamageType);

	if (OutbreakEvent != none && OutbreakEvent.ActiveEvent.bScaleOnHealth)
	{
		OutbreakEvent.AdjustPawnScale(HealedPawn);
	}
}

function PassiveHeal(int HealAmount, int HealthBeforeHeal, Controller InstigatedBy, Pawn HealedPawn)
{
	if (OutbreakEvent != none && OutbreakEvent.ActiveEvent.bScaleOnHealth)
	{
		OutbreakEvent.AdjustPawnScale(HealedPawn);
	}
}

function ScoreKill(Controller Killer, Controller Other)
{
	if ( Killer != none && Killer.PlayerReplicationInfo != None && Killer != Other )
	{
		Killer.PlayerReplicationInfo.Kills++;
		Killer.bForceNetUpdate = TRUE;

		if ( Other.Pawn.IsA('KFPawn_Monster') )
		{
			ScoreMonsterKill(Killer, Other, KFPawn_Monster(Other.Pawn));
		}
	}

	if( Killer != none && Other != none && Killer == Other && Other.Pawn.IsA('KFPawn_Monster') )
	{
		ScoreMonsterKill(Killer, Other, KFPawn_Monster(Other.Pawn));
	}

	ModifyScoreKill(Killer, Other);

	if ( Killer != None || MaxLives > 0 )
	{
		CheckScore(Killer.PlayerReplicationInfo);
	}

	if (OutbreakEvent != none && Role == ROLE_Authority && Other != none && Other.Pawn != none)
	{
		OutbreakEvent.OnScoreKill(Other.Pawn);
	}
}

/* A Zed got killed, let's distribute its money money money value */
protected function ScoreMonsterKill( Controller Killer, Controller Monster, KFPawn_Monster MonsterPawn )
{
	if( MonsterPawn != none )
	{
		if( MonsterPawn.DamageHistory.Length > 0 )
		{
			DistributeMoneyAndXP( MonsterPawn.class, MonsterPawn.DamageHistory, Killer );

			if( MonsterPawn.IsStalkerClass() &&
			 	MonsterPawn.LastStoredCC != none &&
			 	MonsterPawn.bIsCloakingSpottedByTeam )
			{
				AddPlayerXP(MonsterPawn.LastStoredCC, MonsterPawn.static.GetXPValue(GameDifficulty), class'KFPerk_Commando');
			}
		}
	}

	if( WorldInfo.NetMode == NM_DedicatedServer && Killer.GetTeamNum() == 0 )
	{
		`RecordAARZedKill(KFPlayerController(Killer), MonsterPawn.Class, None );
	}
}

/** Called from pawn when a rally occurs.  Allows gametype to do any global behavior based on this. */
function NotifyRally(KFPawn RalliedPawn)
{
	if (OutbreakEvent != none && OutbreakEvent.ActiveEvent.bUseBeefcakeRules)
	{
		OutbreakEvent.AdjustForBeefcakeRules(RalliedPawn, EBT_Rally);
	}
}

/** Called from explosion actor when a scream occurs on an ignored pawn.  Allows gametype to do any global behavior based on this. */
function NotifyIgnoredScream(KFPawn ScreamPawn)
{
	if (OutbreakEvent != none && OutbreakEvent.ActiveEvent.bUseBeefcakeRules)
	{
		OutbreakEvent.AdjustForBeefcakeRules(ScreamPawn, EBT_Scream);
	}
}

function CheckForSmallRadiusKill(KFPawn_Monster MonsterPawn, KFPlayerController KFPC, class<KFPerk> PerkClass)
{
	local KFPawn_Human KFPH;

	if( KFPC == none )
	{
		return;
	}

	foreach WorldInfo.Allpawns( class'KFPawn_Human', KFPH)
	{
		if( KFPH != none && KFPH.IsAliveAndWell() && KFPH.Controller != KFPC )
		{
			if( VSizeSq( KFPH.Location - MonsterPawn.Location ) <= class'KFPerk_Berserker'.static.GetSmallRadiusKillDistanceSQ() )
			{
				KFPC.AddSmallRadiusKill( GameDifficulty, PerkClass );
				break;
			}
		}
	}
}

/**
 * @brief Adjusts the dosh you get based on difficulty and player count
 *
 * @param MonsterClass pawn class of thge killed zed
 * @return Adjusted dosh amount
 */
function float GetAdjustedAIDoshValue( class<KFPawn_Monster> MonsterClass )
{
	local float TempValue;

	if(!ShouldOverrideDoshOnKill(MonsterClass, TempValue))
	{
		TempValue = MonsterClass.static.GetDoshValue();
	}
	TempValue *= DifficultyInfo.GetKillCashModifier();
	ModifyAIDoshValueForPlayerCount( TempValue );
	TempValue *= GameLengthDoshScale[GameLength];

	KFMapInfo(WorldInfo.GetMapInfo()).ModifyAIDoshValue(TempValue);

	return TempValue;
}

/**
 * @brief Adjust monster's dosh value by player count
 *
 * @param ModifiedValue the amount modified
 */
function ModifyAIDoshValueForPlayerCount( out float ModifiedValue )
{
	local float DoshMod;

	// Scale dosh by the same rate we scale the zed spawning so we end up
	// with the same amount of dosh per player in the world whether it's
	// 1 player or 6;
    DoshMod = GetNumPlayers() /  DifficultyInfo.GetPlayerNumMaxAIModifier(GetNumPlayers());

    //`log("Starting Dosh Bounty: "$ModifiedValue$" DoshMod: "$DoshMod);
	ModifiedValue *= DoshMod;
	//`log("Modified Dosh Bounty: "$ModifiedValue);
}

function int GetNumPlayers()
{
`if(`notdefined(ShippingPC))
	if ( ForcedNumLivingPlayers != 0 )
	{
		return ForcedNumLivingPlayers;
	}
`endif

    return Super.GetNumPlayers();
}

/** Returns the number of human/mercenary players */
function int GetNumHumanTeamPlayers()
{
    local Controller C;
    local int HumanTeamPlayers;

    foreach WorldInfo.AllControllers( class'Controller', C )
    {
        if( C.bIsPlayer
        	&& C.PlayerReplicationInfo != none
        	&& C.PlayerReplicationInfo.bReadyToPlay
        	&& !C.PlayerReplicationInfo.bOnlySpectator
        	&& C.GetTeamNum() == 0 )
        {
            ++HumanTeamPlayers;
        }
    }

    return HumanTeamPlayers;
}

/* Who needs some do$h? Give players money after a Zed was killed based on the percentage of damage they dealt*/
protected function DistributeMoneyAndXP(class<KFPawn_Monster> MonsterClass, const out array<DamageInfo> DamageHistory, Controller Killer)
{
	local int i, j, TotalDamage, EarnedDosh;
	local float AdjustedAIValue, ScoreDenominator, XP;
	local KFPlayerController KFPC;
	local KFPlayerReplicationInfo DamagerKFPRI;
	local KFPerk InstigatorPerk;
	local bool bIsBossKill;

	for ( i = 0; i < DamageHistory.Length; i++ )
	{
		TotalDamage += DamageHistory[i].TotalDamage;
	}

	if ( TotalDamage <= 0 )
	{
		`warn("Total damage given to this zed is less or equal zero! This should never happen");
		return;
	}

	bIsBossKill = MonsterClass.static.IsABoss();

	// Scale value (via GameInfo) by difficulty and length & player count;
	AdjustedAIValue = GetAdjustedAIDoshValue( MonsterClass );
	ScoreDenominator = AdjustedAIValue / TotalDamage;

	for ( i = 0; i < DamageHistory.Length; i++ )
	{
		if( DamageHistory[i].DamagerController != none
			&& DamageHistory[i].DamagerController.bIsPlayer
			&& DamageHistory[i].DamagerPRI.GetTeamNum() == 0
			&& DamageHistory[i].DamagerPRI != none )
		{
			EarnedDosh = Round( DamageHistory[i].TotalDamage * ScoreDenominator );
			//`log("SCORING: Player" @ DamageHistory[i].DamagerPRI.PlayerName @ "received" @ EarnedDosh @ "dosh for killing a" @ MonsterClass, bLogScoring);
			DamagerKFPRI = KFPlayerReplicationInfo(DamageHistory[i].DamagerPRI);
			if( DamagerKFPRI != none )
			{
				//Killer cannot receive assists.
				if( Killer.PlayerReplicationInfo != DamagerKFPRI )
				{
					DamagerKFPRI.Assists++;

					if( DamageHistory[i].DamagePerks.Length == 1 )
					{
						DamageHistory[i].DamagePerks[0].static.ModifyAssistDosh( EarnedDosh );
					}
				}
				if (bIsBossKill && !bSplitBossDoshReward)
				{
					DamagerKFPRI.AddDosh(GetAdjustedAIDoshValue(MonsterClass), true);
				}
				else
				{
					DamagerKFPRI.AddDosh(EarnedDosh, true);
				}


				if( DamagerKFPRI.Team != none )
				{
					//Dosh
					if (bIsBossKill && !bSplitBossDoshReward)
					{
						KFTeamInfo_Human(DamagerKFPRI.Team).AddScore(GetAdjustedAIDoshValue(MonsterClass));
					}
					else
					{
						KFTeamInfo_Human(DamagerKFPRI.Team).AddScore(EarnedDosh);
					}

					if( DamageHistory[i].DamagePerks.Length <= 0 )
					{
						continue;
					}

					if (!ValidateForXP(MonsterClass, DamageHistory[i].DamageCausers, DamageHistory[i].DamageTypes))
					{
						continue;
					}

					// Distribute experience points
					KFPC = KFPlayerController(DamagerKFPRI.Owner);
					if( KFPC != none )
					{
						InstigatorPerk = KFPC.GetPerk();
						if( InstigatorPerk.ShouldGetAllTheXP() )
						{
							AddPlayerXP(KFPC, MonsterClass.static.GetXPValue(GameDifficulty), InstigatorPerk.Class, true);
							continue;
						}

						XP = MonsterClass.static.GetXPValue(GameDifficulty) / DamageHistory[i].DamagePerks.Length;

						for( j = 0; j < DamageHistory[i].DamagePerks.Length; j++ )
						{
							AddPlayerXP(KFPC, FCeil(XP), DamageHistory[i].DamagePerks[j], true);
						}
					}
				}
			}
		}
	}
}

/** Gives us a chance to validate things before calling AddPlayerXP */
native private final function bool ValidateForXP(class<KFPawn_Monster> MonsterClass,
	const out array<class<Actor> > DamageCausers, const out array<class<KFDamageType> > DamageTypes);

/** Grant xp rewards */
native private function AddPlayerXP(KFPlayerController PC, INT XP, class<KFPerk> PerkClass, bool bApplyPrestigeBonus = false);

/************************************************************************************
 * @name		Zed time
 ***********************************************************************************/

// Called when a dramatic event happens that might cause slomo
// ZedTimeChance - the attempted probability of doing a slomo event
function DramaticEvent(float ZedTimeChance, optional float Duration=3.f)
{
    //local float RandChance;
    local float TimeSinceLastEvent;
    local KFPlayerController KFPC;

// NVCHANGE_BEGIN - RLS - Debugging Effects & Performance
	if (bNVBlockDramatic)
		return;
// NVCHANGE_END - RLS - Debugging Effects & Performance

    TimeSinceLastEvent = `TimeSince(LastZedTimeEvent);

`if(`__TW_SDK_)
    if( BaseMutator != none )
    {
    	BaseMutator.ModifyZedTime( TimeSinceLastEvent, ZedTimeChance, Duration );
    }
`endif

    // Don't go in slomo if we were just IN slomo
    if( TimeSinceLastEvent < 10.0 && ZedTimeChance < 1.0 )
    {
        return;
    }

    // Increase the chance of zed time if it has been a while
    if( TimeSinceLastEvent > 60 )
    {
        ZedTimeChance *= 4.0;
    }
    else if( TimeSinceLastEvent > 30 )
    {
        ZedTimeChance *= 2.0;
    }

    // Cause zed time if we pass the random chance check
    if( FRand() <= ZedTimeChance && Duration > ZedTimeRemaining )
    {
		ZedTimeRemaining = Duration;
        bZedTimeBlendingOut = false;
		LastZedTimeEvent = WorldInfo.TimeSeconds;

        SetZedTimeDilation(ZedTimeSlomoScale);

        foreach WorldInfo.AllControllers(class'KFPlayerController', KFPC)
        {
            if (KFPC != none)
            {
                KFPC.EnterZedTime();
            }
        }
    }
}

function Tick( float DeltaTime )
{
    // Handle interpolating back from zed time
    if( ZedTimeRemaining > 0.f )
    {
		TickZedTime(DeltaTime);
    }
}

/** While zedtime is active, tick duration down */
function TickZedTime( float DeltaTime )
{
	local float TrueTimeFactor;
    local KFPlayerController KFPC;

	// Get real world DeltaTime (undo zed time dilation)
    TrueTimeFactor = 1.0 / (CustomTimeDilation * WorldInfo.TimeDilation);
    ZedTimeRemaining -= DeltaTime * TrueTimeFactor;

    // Reset zed time when this current zed time period ends
    if( ZedTimeRemaining <= 0 )
    {
        bZedTimeBlendingOut = false;
        SetZedTimeDilation(1.0);
        ZedTimeExtensionsUsed = 0;

		foreach WorldInfo.AllControllers(class'KFPlayerController', KFPC)
		{
			if (KFPC != none)
			{
				KFPC.CompleteZedTime();
			}
		}
    }
	// Interpolate back from zed time if its almost done
	else if ( ZedTimeRemaining < ZedTimeBlendOutTime )
	{
        if( !bZedTimeBlendingOut )
        {
            bZedTimeBlendingOut = true;

            foreach WorldInfo.AllControllers(class'KFPlayerController', KFPC)
            {
                if (KFPC != none)
                {
                    KFPC.FadeOutZedTime();
                }
            }
        }

        SetZedTimeDilation(Lerp(1.0, ZedTimeSlomoScale, ZedTimeRemaining/ZEDTimeBlendOutTime));
    }
}

/** Returns true if zed-time is currently active */
function bool IsZedTimeActive()
{
	return ZedTimeRemaining > 0.f;
}

/** Changes the current TimeDilation value for zed-time */
function SetZedTimeDilation(float NewTimeDilation)
{
	// Change this to swap between global/local zedtime systems
	SetGameSpeed(NewTimeDilation);
}

/** Trigger DramaticEvent/ZedTime when pawn is killed */
function CheckZedTimeOnKill(Controller Killer, Controller KilledPlayer, Pawn KilledPawn, class<DamageType> DamageType)
{
	local bool bIsHuman;
	local KFPlayerController KFPC;
	local KFPerk KillersPerk;
	local class<KFDamageType> KFDT;

	// Skip if the damagetype is (or can apply) damage over time
	KFDT = class<KFDamageType>(DamageType);
	if ( KFDT != None && KFDT.default.DoT_Type != DOT_None )
	{
		return;
	}

	// If already in zed time, check for zed time extensions
	if ( IsZedTimeActive() )
	{
		KFPC = KFPlayerController(Killer);
		if ( KFPC != none )
		{
			KillersPerk = KFPC.GetPerk();
			// Handle if someone has a perk with zed time extensions
			if ( ZedTimeRemaining > 0.f && KillersPerk != none && KillersPerk.GetZedTimeExtension( KFPC.GetLevel() ) > ZedTimeExtensionsUsed )
			{
				// Force Zed Time extension for every kill as long as the Player's Perk has Extensions left
				DramaticEvent(1.0);
				ZedTimeExtensionsUsed++;
			}
		}
	}
	else
	{
// NVCHANGE_BEGIN - RLS - Debugging Effects
		if (bNVAlwaysDramatic)
			DramaticEvent(1.0);
// NVCHANGE_END - RLS - Debugging Effects

		// Handle human kills
		bIsHuman = KilledPawn.IsA('KFPawn_Human');
		if ( bIsHuman )
		{
			DramaticEvent(0.05f);
			return;
		}

		if( KilledPawn.Controller == none )
		{
			// don't trigger dramatic event for brain-dead zeds
			return;
		}

		// Handle monster/zed kills - increased probability if closer to the player
		if( Killer != none && Killer.Pawn != none && VSizeSq(Killer.Pawn.Location - KilledPawn.Location) < 90000 ) // 3 meters
		{
			if(OutbreakEvent != none && Role == ROLE_Authority && OutbreakEvent.ActiveEvent.bModifyZedTimeOnANearZedKill)
			{
				DramaticEvent(OutbreakEvent.ActiveEvent.ZedTimeOnANearZedKill);
			}
			else
			{
				DramaticEvent(0.05);
			}
		}
		else
		{
			DramaticEvent(0.025);
		}
	}
}

/** Called when pawn is killed by headshot */
function NotifyHeadshotKill(Controller Killer, Pawn KilledPawn)
{
// NVCHANGE_BEGIN - RLS - Debugging Effects
	if (bNVAlwaysDramatic)
		DramaticEvent(1.0);
// NVCHANGE_END - RLS - Debugging Effects

	// increased chance for long range kills
	if(Killer != none && Killer.Pawn != none && VSizeSq(Killer.Pawn.Location - KilledPawn.Location) > Square(2500)) // 25 meters
	{
		DramaticEvent(0.05);
	}
	else
	{
		DramaticEvent(0.03);
	}
}

/** notification when a NavigationPoint becomes blocked or unblocked */
function NotifyNavigationChanged( NavigationPoint N )
{
	local KFAIController AI;
	local int	 Idx;

	if( N.bBlocked )
	{
		foreach WorldInfo.AllControllers( class'KFAIController', AI )
		{
			`AILog_Ext( GetFuncName()$"() Notifying "$AI$" that navigation has changed for "$N, 'PathWarning', AI );
			if( !AI.bMovingToGoal )
			{
				`AILog_Ext( GetFuncName()$"() ** Skipping notification for "$AI$" because bMovingToGoal was false. bPreparingMove? : "$AI.bPreparingMove, 'PathWarning', AI );
				continue;
			}
			Idx = AI.RouteCache.Find( N );
			if( Idx >= 0 )
			{
				`AILog_Ext( GetFuncName()$"() setting bReEvaluatePath to true for "$AI$" thanks to "$N, 'PathWarning', AI );
				AI.bReevaluatePath = true;
				AI.MoveTimer = -1.f;
				AI.ForcePauseAndRepath();
			}
			else
			{
				`AILog_Ext( "** WARNING ** "$GetFuncName()$" for "$N$" not telling "$AI$" to reevaluate path because I couldn't find "$N$" in the routecache! bPreparingMove: "$AI.bPreparingMove, 'PathWarning', AI );
			}
		}
	}
}

/************************************************************************************
 * @name		Music
 ***********************************************************************************/

/** Generally how intense the game is currently (MAX RETURN VALUE: 10, in line with TWMusicTrackStruct::MinGameIntensityLevel ClampMax) */
function byte GetGameIntensityForMusic();

/** Whether an action or ambient track should be played */
static function bool ShouldPlayActionMusicTrack(KFGameReplicationInfo GRI);

/** Whether this game mode should play music from the get-go */
static function bool ShouldPlayMusicAtStart();

simulated function ForceMenuMusicTrack()
{
    MyKFGRI.ForceNewMusicTrack( default.ForcedMusicTracks[EFM_MainMenu] );
}

simulated function ForceCreditsMusicTrack()
{
    MyKFGRI.ForceNewMusicTrack( default.ForcedMusicTracks[EFM_Credits] );
}

simulated function ForceHansMusicTrack()
{
    MyKFGRI.ForceNewMusicTrack( default.ForcedMusicTracks[EFM_Boss1] );
}

simulated function ForcePatriarchMusicTrack()
{
    MyKFGRI.ForceNewMusicTrack( default.ForcedMusicTracks[EFM_Boss2] );
}

simulated function ForceMatriarchMusicTrack()
{
    MyKFGRI.ForceNewMusicTrack( default.ForcedMusicTracks[EFM_Boss3] );
}

simulated function ForceKingFPMusicTrack()
{
    MyKFGRI.ForceNewMusicTrack( default.ForcedMusicTracks[EFM_Boss4] );
}

simulated function ForceAbominationMusicTrack()
{
    MyKFGRI.ForceNewMusicTrack( default.ForcedMusicTracks[EFM_Boss5] );
}

simulated function ForceWWLMusicTrack()
{
	MyKFGRI.ForceNewMusicTrack( default.ForcedMusicTracks[EFM_WWL] );
}

/*********************************************************************************************
 * @name		Map rotation
 *********************************************************************************************/

/**
 * Returns the next map to play.
 */
function string GetNextMap()
{
	local array<string> MapList;
	local int i;

		if ( bUseMapList && GameMapCycles.Length > 0 )
		{
			if ( MapCycleIndex == INDEX_NONE )
			{
				MapList = GameMapCycles[ActiveMapCycle].Maps;
				MapCycleIndex = GetCurrentMapCycleIndex(MapList);
				if ( MapCycleIndex == INDEX_NONE )
				{
					// Assume current map is actually zero
					MapCycleIndex = 0;
				}
			}

			for (i = 0; i < GameMapCycles[ActiveMapCycle].Maps.length; ++i)
			{
				MapCycleIndex = MapCycleIndex + 1 < GameMapCycles[ActiveMapCycle].Maps.length ? (MapCycleIndex + 1) : 0;

				if ((class'KFGameEngine'.static.GetWeeklyEventIndexMod() == 11 || OutbreakEvent.ActiveEvent == OutbreakEvent.SetEvents[11])
				      && MyKFGRI.IsA('KFGameReplicationInfo_WeeklySurvival'))
				{
					if (GameMapCycles[ActiveMapCycle].Maps[MapCycleIndex] == "KF-Biolapse"          || 
						GameMapCycles[ActiveMapCycle].Maps[MapCycleIndex] == "KF-Nightmare"         ||
						GameMapCycles[ActiveMapCycle].Maps[MapCycleIndex] == "KF-PowerCore_Holdout" ||
						GameMapCycles[ActiveMapCycle].Maps[MapCycleIndex] == "KF-TheDescent"        ||
						GameMapCycles[ActiveMapCycle].Maps[MapCycleIndex] == "KF-KrampusLair")
					{
							continue;
					}
				}
				

				if ( IsMapAllowedInCycle(GameMapCycles[ActiveMapCycle].Maps[MapCycleIndex]) )
				{
					SaveConfig();
					return GameMapCycles[ActiveMapCycle].Maps[MapCycleIndex];
				}
			}

			return string(WorldInfo.GetPackageName());
		}
		else
		{
			return string(WorldInfo.GetPackageName());
		}

	return "";
}

/** @return the index of the current map in the given list (used when starting up a server to start counting at the current map) */
function int GetCurrentMapCycleIndex(const out array<string> MapList)
{
	return MapList.Find(string(WorldInfo.GetPackageName()));
}

/*********************************************************************************************
 * @name Exec
 *********************************************************************************************/
exec function SetFriendlyFireScale(float FFScale)
{
	FriendlyFireScale = FClamp(FFScale, 0, 1.f);
	SaveConfig();
}

exec function FindCollectibles();


exec function MaintenanceRestart()
{
	SetNeedsRestart();
}

// Save player's stats on leave
function UnregisterPlayer(PlayerController PC)
{
	local KFPlayerController KFPC;

	KFPC = KFPlayerController(PC);
	if( KFPC != none )
	{
		`AnalyticsLog(("player_disconnected",
					   KFPC.PlayerReplicationInfo,
					   "#"$MyKFGRI.WaveNum));

		KFPC.ClientWriteAndFlushStats();
	}

	super.UnregisterPlayer(PC);
}

/** AddInactivePRI()
* Add PRI to the inactive list, remove from the active list
* Overrideen to include the time we quit
*/
function AddInactivePRI(PlayerReplicationInfo PRI, PlayerController PC)
{
	local KFPlayerReplicationInfo NewKFPRI;

	// don't store if it's an old PRI from the previous level or if it's a spectator
	if (!PRI.bFromPreviousLevel && !PRI.bOnlySpectator)
	{
		NewKFPRI = KFPlayerReplicationInfo(PRI);
		NewKFPRI.LastQuitTime = WorldInfo.TimeSeconds;
	}

	super.AddInactivePRI(PRI, PC);
}

/** FindInactivePRI()
* returns the PRI associated with this re-entering player
* Overrideen to increment the number of times we've reconnected to a server
*/
function bool FindInactivePRI(PlayerController PC)
{
	local KFPlayerReplicationInfo NewKFPRI;

	if( super.FindInactivePRI(PC) )
	{
		NewKFPRI = KFPlayerReplicationInfo(PC.PlayerReplicationInfo);
		NewKFPRI.NumTimesReconnected++;
		return true;
	}
	return false;
}

/************************************************************************************
 * @name		Reservations
 ***********************************************************************************/

function bool UniqueIdPresent(out array<UniqueNetId> PlayerIDs, UniqueNetId PlayerID)
{
	local UniqueNetId i;

	//array Find() won't work, for stupid Unrealscript reasons
	foreach PlayerIDs(i)
	{
		if (i == PlayerID)
		{
			return true;
		}
	}
	return false;
}

function bool ReservationPresent(UniqueNetId PlayerID)
{
	local KFPlayerReservation i;
	foreach PlayerReservations(i)
	{
		if (i.PlayerId == PlayerID)
		{
			return true;
		}
	}
	return false;
}

function UniqueIdAdd(out array<UniqueNetId> PlayerIDs, UniqueNetId PlayerID)
{
	if (!UniqueIdPresent(PlayerIDs, PlayerID))
	{
		PlayerIDs.AddItem(PlayerID);
	}
}

function bool AtCapacity(bool bSpectator, optional const UniqueNetId PlayerID)
{
	if (bSpectator)
	{
		return super.AtCapacity(bSpectator);
	}
	if ( GetAvailableReservations() <= 0 )
	{
		return !ReservationPresent(PlayerID);
	}
	return super.AtCapacity(bSpectator);
}

event MakeReservations(const string URLOptions, const UniqueNetId PlayerId, out string OutError)
{
	local array<UniqueNetId> Reservations;

	`log("KFGameInfo.MakeReservations", bLogReservations);
	ReadReservations(URLOptions, PlayerId, Reservations);
	if (Reservations.length > 0)
	{
		if (!AddPlayerReservations(Reservations))
		{
			`log("KFGameInfo.MakeReservations failed", bLogReservations);
			OutError = "<Strings:"$PathName(WorldInfo.Game.GameMessageClass)$".MaxedOutMessage>";
		}
	}
}

event PlayerController Login(string Portal, string Options, const UniqueNetID UniqueID, out string ErrorMessage)
{
	local PlayerController SpawnedPC;
	local string PlayerfabPlayerId;

	SeatPlayer(UniqueID);
	SpawnedPC = super.Login(Portal, Options, UniqueID, ErrorMessage);

	if( PlayfabInter != none && PlayfabInter.IsRegisteredWithPlayfab() && SpawnedPC != None )
	{
		`log("Player login with options"@Options);
		PlayerfabPlayerId = ParseOption( Options, "PlayfabPlayerId" );

		SpawnedPC.PlayerReplicationInfo.PlayfabPlayerId = PlayerfabPlayerId;

		if( PlayerfabPlayerId != "")
		{
			PlayfabInter.ServerNotifyPlayerJoined(PlayerfabPlayerId);
		}
	}

	return SpawnedPC;
}

/** Broadcast message when server needs restart/update.  Called with commandline -autoupdate. */
event SendServerMaintenanceMessage()
{
	BroadcastLocalizedMessage(class'KFLocalMessage', LMT_ServerMaintenance);
}

function UniqueReservationAdd(UniqueNetId PlayerID)
{
	local KFPlayerReservation i;
	local KFPlayerReservation Reservation;
	local bool bFound;

	`log("KFGameInfo.UniqueReservationAdd" @ class'OnlineSubsystem'.static.UniqueNetIdToString(PlayerID), bLogReservations);
	bFound = false;
	foreach PlayerReservations(i)
	{
		if (i.PlayerId == PlayerID)
		{
			bFound = true;
			break;
		}
	}
	if (!bFound)
	{
		`log("KFGameInfo.UniqueReservationAdd adding" @ class'OnlineSubsystem'.static.UniqueNetIdToString(PlayerID), bLogReservations);
		Reservation.PlayerId = PlayerID;
		Reservation.Timer = 0;
		PlayerReservations.AddItem(Reservation);
	}
}

function RemoveDuplicates(out array<UniqueNetId> PlayerIDs)
{
	local int i;
	i = 0;
	while ( i < PlayerIDs.length )
	{
		if ( ReservationPresent(PlayerIDs[i]) )
		{
			PlayerIDs.Remove(i, 1);
		}
		else
		{
			++i;
		}
	}
}

function StripFromMatchmakingGroups(const out UniqueNetId PlayerID)
{
	local int GroupIndex, MemberIndex;

	`log("StripFromMatchmakingGroups: Checking if player" @ class'OnlineSubsystem'.static.UniqueNetIdToString(PlayerID) @ "is already in a group", bLogGroupTeamBalance);
	for (GroupIndex = PlayerGroups.length-1; GroupIndex >= 0; --GroupIndex)
	{
		for (MemberIndex = PlayerGroups[GroupIndex].PlayerGroup.length-1; MemberIndex >= 0; --MemberIndex)
		{
			if (PlayerGroups[GroupIndex].PlayerGroup[MemberIndex] == PlayerID)
			{
				`log("StripFromMatchmakingGroups: Removing player" @ class'OnlineSubsystem'.static.UniqueNetIdToString(PlayerID) @ "from group" @ GroupIndex, bLogGroupTeamBalance);
				PlayerGroups[GroupIndex].PlayerGroup.Remove(MemberIndex, 1);
			}
		}
		if (PlayerGroups[GroupIndex].PlayerGroup.length == 0)
		{
			`log("StripFromMatchmakingGroups: Removing empty group" @ GroupIndex @ "from group list", bLogGroupTeamBalance);
			PlayerGroups.Remove(GroupIndex, 1);
		}
	}
}

function AddPlayerMatchmakingGroup(const out array<UniqueNetId> PlayerIDs)
{
	local UniqueNetId i;
	local PlayerGroupStruct TempPlayerGroup;
	local int LogIndex;
	local UniqueNetId StupidUnrealscriptBS;

	if (PlayerIDs.length < 2)
	{
		`log("AddPlayerMatchmakingGroup: Not creating a group for a single player.");
		return;
	}

	foreach PlayerIDs(i)
	{
		StripFromMatchmakingGroups(i);
	}

	TempPlayerGroup.PlayerGroup = PlayerIDs;

	PlayerGroups.Add(1);
	PlayerGroups[PlayerGroups.length-1] = TempPlayerGroup;
	if (bLogGroupTeamBalance)
	{
		`log("AddPlayerMatchmakingGroup: Adding new matchmaking group at position" @ PlayerGroups.length-1 @ "with members:");
		for (LogIndex = 0; LogIndex < PlayerGroups[PlayerGroups.length-1].PlayerGroup.length; ++LogIndex)
		{
			StupidUnrealscriptBS = PlayerGroups[PlayerGroups.length-1].PlayerGroup[LogIndex];
			`log("	"$class'OnlineSubsystem'.static.UniqueNetIdToString(StupidUnrealscriptBS));
		}
	}


}

function bool AddPlayerReservations(out array<UniqueNetId> PlayerIDs)
{
	local UniqueNetId PlayerID;
	local int OldCount;

	RemoveDuplicates(PlayerIDs);
	if (PlayerIDs.length == 0)
	{
		return true;
	}
	if (PlayerIDs.length > GetAvailableReservations())
	{
		return false;
	}

	AddPlayerMatchmakingGroup(PlayerIDs);

	OldCount = PlayerReservations.length;
	foreach PlayerIDs(PlayerID)
	{
		UniqueReservationAdd(PlayerID);
	}
	if (OldCount == 0 && PlayerReservations.length > 0)
	{
		SetTimer( 1.f, true, nameOf(TimeReservations) );
	}
	return true;
}

function TimeReservations()
{
	local int i;
	local UniqueNetId stupid;

	i = 0;
	while ( i < PlayerReservations.length )
	{
		stupid=PlayerReservations[i].PlayerId;
		//`log("KFGameInfo.TimeReservations" @ i @ class'OnlineSubsystem'.static.UniqueNetIdToString(stupid) @ "timer is" @ PlayerReservations[i].Timer, bLogReservations);

		if (PlayerReservations[i].Timer > ReservationTimeout)
		{
			`log("KFGameInfo.TimeReservations expiring player" @ i @ class'OnlineSubsystem'.static.UniqueNetIdToString(stupid), bLogReservations);
			PlayerReservations.Remove(i, 1);
			`log("TimeReservations: expiring player" @ class'OnlineSubsystem'.static.UniqueNetIdToString(stupid), bLogGroupTeamBalance);
			StripFromMatchmakingGroups(stupid);
		}
		else
		{
			if (PlayerReservations[i].Timer >= 0)
			{
				++PlayerReservations[i].Timer;
				if (bLogReservations)
				{
					`log("KFGameInfo.TimeReservations player" @ i @ class'OnlineSubsystem'.static.UniqueNetIdToString(stupid)@"="@string(PlayerReservations[i].Timer), bLogReservations);
				}
			}
			++i;
		}
	}
	if (PlayerReservations.length == 0)
	{
		ClearTimer( nameOf(TimeReservations) );
	}
}

function ReadReservations(const string URLOptions, const UniqueNetId PlayerId, out array<UniqueNetId> Reservations)
{
	local string OptionsCopy, Option, Key, Value;
	local UniqueNetId Id;

	`log("KFGameInfo.ReadReservations reading reservations from"@URLOptions, bLogReservations);

	OptionsCopy = URLOptions;
	Reservations.Remove(0, Reservations.length);
	while ( GrabOption(OptionsCopy, Option) && Reservations.length < 5 )
	{
		GetKeyValue(Option, Key, Value);
		if ( Len(Key) == 6 && Left(Key,5) ~= "party")
		{
			if ( class'OnlineSubsystem'.static.StringToUniqueNetId(Value, Id) )
			{
				`log("KFGameInfo.ReadReservations for player" @ Key, bLogReservations);
				UniqueIdAdd(Reservations, Id);
			}
		}
		else if (Key ~= "SpectatorOnly" && Value ~= "1")
		{
			//Make no reservation if we're spectating
			`log("KFGameInfo.ReadReservations found" @ Key $ "=" $ Value @"in URL, making no reservations", bLogReservations);
			Reservations.Remove(0, Reservations.length);
			return;
		}
	}
	`log("KFGameInfo.ReadReservations for player" @ class'OnlineSubsystem'.static.UniqueNetIdToString(PlayerId), bLogReservations);
	UniqueIdAdd(Reservations, PlayerId);
}

event bool ConfirmReservation(const UniqueNetId PlayerID)
{
	local KFPlayerReservation i;
	local UniqueNetId stupid;
	local int index;
	`log("KFGameInfo.ConfirmReservation", bLogReservations);
	foreach PlayerReservations(i, index)
	{
		if (i.PlayerId == PlayerID)
		{
			stupid=i.PlayerId;
			if (bLogReservations)
			{
				`log("KFGameInfo.ConfirmReservation for player"@ index @ class'OnlineSubsystem'.static.UniqueNetIdToString(stupid), bLogReservations);
			}
			PlayerReservations[index].Timer = -1;
			`log("KFGameInfo.TimeReservations" @ index @ class'OnlineSubsystem'.static.UniqueNetIdToString(stupid) @ "timer is" @ string(PlayerReservations[index].Timer), bLogReservations);
			return true;
		}
	}
	return false;
}

event bool SeatPlayer(const UniqueNetId SeatedPlayerID)
{
	local int i;
	local UniqueNetId stupid;

	`log("KFGameInfo.SeatPlayer", bLogReservations);
	for (i = 0; i < PlayerReservations.length; ++i )
	{
		if (PlayerReservations[i].PlayerId == SeatedPlayerID)
		{
			if (bLogReservations)
			{
				stupid=PlayerReservations[i].PlayerId;
				`log("KFGameInfo.SeatPlayer for player" @ i @ class'OnlineSubsystem'.static.UniqueNetIdToString(stupid), bLogReservations);
			}
			PlayerReservations.Remove(i, 1);
			return true;
		}
	}
	return false;
}

function int GetAvailableReservations()
{
	return Maxplayers - GetNumPlayers() - PlayerReservations.length;
}

/*********************************************************************************************
 * @name 	Debugging
 *********************************************************************************************/

static native function bool AllowBalanceLogging();
static native function bool AllowAnalyticsLogging();

/** logs what each player is carrying */
function LogPlayersInventory()
{
	local PlayerController PC;
	local Inventory Item;
	local string InvString;

	if ( !AllowBalanceLogging() )
	{
		return;
	}

	ForEach WorldInfo.AllControllers(class'PlayerController', PC)
	{
		if ( PC.Pawn != None && PC.Pawn.InvManager != None )
		{
			InvString = "";
			for (Item = PC.Pawn.InvManager.InventoryChain; Item != None; Item = Item.Inventory)
			{
				InvString $= Item.Class.Name $ ",";
			}
			`BalanceLog(GBE_Inventory, PC.PlayerReplicationInfo, InvString);
			// @note: for `AnalyticsLog see "pc_wave_start"
		}
	}
}

/** logs how much dosh each player is carrying */
function LogPlayersDosh(name EventName)
{
	local KFPlayerController PC;

	if ( !AllowBalanceLogging() )
	{
		return;
	}

	ForEach WorldInfo.AllControllers(class'KFPlayerController', PC)
	{
		if ( PC.PlayerReplicationInfo != None && !PC.PlayerReplicationInfo.bIsSpectator )
		{
			`BalanceLog(EventName, PC.PlayerReplicationInfo, "$"$PC.PlayerReplicationInfo.Score$","$PC.GetPerk());
			// @note: for `AnalyticsLog see "pc_wave_start"
		}
	}
}

/** logs how many total kills and deaths each player has at end of match */
function LogPlayersKillCount()
{
	local KFPlayerController PC;
	local PlayerReplicationInfo PRI;

	if ( !AllowBalanceLogging() )
	{
		return;
	}

	ForEach WorldInfo.AllControllers(class'KFPlayerController', PC)
	{
		PRI = PC.PlayerReplicationInfo;
		if ( PRI != None && !PRI.bIsSpectator )
		{
			`BalanceLog(GBE_Kills, PRI, PRI.Kills$","$PC.GetPerk());
			`BalanceLog(GBE_Deaths, PRI, PRI.Deaths$","$PC.GetPerk());
			// @note: for `AnalyticsLog see "player_death" and "pc_wave_end"
		}
	}
}

/*********************************************************************************************
 * state PendingMatch
 * This is the initial state for a kf game type.
 *********************************************************************************************/

auto State PendingMatch
{
	// REMOVEMESOON
	function BeginState(Name PreviousStateName)
	{
		if (WorldInfo.NetMode == NM_DedicatedServer)
		{
			//`REMOVEMESOON_ZombieServerLog("KFGameInfo:PendingMatch.BeginState - PreviousStateName: "$PreviousStateName);
		}
	}
	// END REMOVEMESOON

	event Timer()
	{
		global.Timer();
 		if (bDelayedStart)
		{
		 	if (ShouldStartMatch())
			{
				if (!IsTimerActive(nameof(LobbyCountdownComplete)))
				{
					if (CheckAllPlayersReady())
					{
						// Everyone is ready, start the final countdown
						SetCountdown(true, GameStartDelay);
					}
					else if (MajorityPlayersReady())
					{
						// Majority of players are ready, start the lobby countdown
						MyKFGRI.RemainingTime = ReadyUpDelay;
						MyKFGRI.bStopCountDown = false;
						SetCountdown(false, MyKFGRI.RemainingTime);
					}
				}
				else
				{
					if (!MajorityPlayersReady())
					{
						// No more majority, stop the lobby countdown
						ClearTimer(nameof(LobbyCountdownComplete));
						MyKFGRI.bStopCountDown = true;
						ResetCountDown();
					}
					else
					{
						if (MyKFGRI.RemainingTime <= GameStartDelay)
						{
							if (!bStartFinalCount)
							{
								// Lobby countdown is almost up, start the final countdown.
								// Nothing can stop us now.
								SetCountdown(true, GameStartDelay);
							}
						}
						else
						{
							if (CheckAllPlayersReady())
							{
								if (!bStartFinalCount)
								{
									// Everyone is ready, start the final countdown
									SetCountdown(true, GameStartDelay);
								}
							}
							else
							{
								if (bStartFinalCount)
								{
									// Not everyone is ready, resume lobby countdown
									// (unless the lobby countdown is almost up)
									SetCountdown(false, MyKFGRI.RemainingTime);
								}
							}
						}
					}
				}
			}
			else
			{
				if (IsTimerActive(nameof(LobbyCountdownComplete)))
				{
					ClearTimer(nameof(LobbyCountdownComplete));
					MyKFGRI.bStopCountDown = true;
					bStartFinalCount = false;
				}
			}

            // If this is a dedicated server locked for use by players,
			// check if anyone is connected after ready-up time expires,
			// and unlock the server if no one is has connected
			if (!IsTimerActive(nameof(CheckServerUnlock)))
			{
				SetTimer(ReadyUpDelay, false, nameof(CheckServerUnlock));
			}
		}
	}
}

function SetCountdown(bool bFinalCountdown, byte CountdownTime)
{
	local KFPlayerController PC;
	local byte TeamNum;

	bStartFinalCount = bFinalCountdown;
	SetTimer(CountdownTime, false, nameof(LobbyCountdownComplete));

	foreach WorldInfo.AllControllers(class'KFPlayerController', PC)
	{
		if ( bFinalCountdown )
		{
			// If spawn as been invalidated (e.g. kismet, team swap) choose again now,
			// so that the client can stream textures at the correct location
			TeamNum = PC.GetTeamNum();
			if ( TeamNum == 0 && !ShouldSpawnAtStartSpot(PC) )
			{
				// clear old StartSpot so it's not re-evaluated by FindPlayerStart()
				PC.StartSpot = None;
				PC.StartSpot = FindPlayerStart(PC, TeamNum);
			}

			PC.ClientSetCountdown(bFinalCountdown, CountdownTime, PC.StartSpot);
		}
		else
		{
			PC.ClientSetCountdown(bFinalCountdown, CountdownTime);
		}
	}
}

/**
 * @brief Stops the countdown when no player is readied up anymore
  */
function ResetCountDown()
{
	local KFPlayerController KFPC;

	foreach WorldInfo.AllControllers(class'KFPlayerController', KFPC)
	{
		KFPC.ClientResetCountdown();
	}
}

function LobbyCountdownComplete()
{
	local KFPlayerController KFPC;
	foreach WorldInfo.AllControllers(class'KFPlayerController', KFPC)
	{
		KFPC.PlayerReplicationInfo.bReadyToPlay = true;
	}

	StartMatch();
}

private function CheckServerUnlock()
{
	local bool bWasAvailableForTakeover;
	local KFGameEngine KFEngine;
    local PlayfabInterface Playfab;

	if (WorldInfo.NetMode == NM_DedicatedServer)
	{
		//`REMOVEMESOON_ServerTakeoverLog("KFGameInfo.CheckServerUnlock 1 - GetNumPlayers(): "$GetNumPlayers());
	}

	if ( GetNumPlayers() == 0 )
	{
        KFEngine = KFGameEngine(class'Engine'.static.GetEngine());
        Playfab = KFEngine.GetPlayfabInterface();

		if (WorldInfo.NetMode == NM_DedicatedServer)
		{
			//`REMOVEMESOON_ServerTakeoverLog("KFGameInfo.CheckServerUnlock 2 - Playfab: "$Playfab);
		}

        if( Playfab != none )
	    {
		    Playfab.ServerDeallocate();
	    }

		if (WorldInfo.NetMode == NM_DedicatedServer)
		{
			//`REMOVEMESOON_ServerTakeoverLog("KFGameInfo.CheckServerUnlock 3 - IsLockedServer(): "$KFEngine.IsLockedServer()$" (bUsedForTakeover: "$KFEngine.bUsedForTakeover$", bAvailableForTakeover: "$KFEngine.bAvailableForTakeover$")");
		}

		// Won't unlock a server that's not lockable
        if( KFEngine.IsLockedServer() )
        {
            bWasAvailableForTakeover = KFEngine.bAvailableForTakeover;
            KFEngine.UnlockServer();

			if (WorldInfo.NetMode == NM_DedicatedServer)
			{
				//`REMOVEMESOON_ServerTakeoverLog("KFGameInfo.CheckServerUnlock 4 - bWasAvailableForTakeover: "$bWasAvailableForTakeover$"; bAvailableForTakeover: "$KFEngine.bAvailableForTakeover);
			}

            if (!bWasAvailableForTakeover && KFEngine.bAvailableForTakeover)
            {
                AccessControl.SetGamePassword("");
                StripPasswordFromLastURL(KFEngine);
            }
            // If the status changed, update game settings immediately
            if( bWasAvailableForTakeover != KFEngine.bAvailableForTakeover )
            {
                UpdateGameSettings();
            }
        }

	}
}

private native final function StripPasswordFromLastURL(KFGameEngine Engine);

function StartMatch()
{
	// Clear bWaitingToStartMatch before super -- see CheckSpawnProximity
	bWaitingToStartMatch = false;

	super.StartMatch();
	bDelayedStart = false;
	MyKFGRI.RemainingTime = 0;
	MyKFGRI.bStopCountDown = true;
	ClearTimer(nameof(StartMatch));
	ClearTimer(nameof(LobbyCountdownComplete));
	if ( GameplayEventsWriter != None )
	{
		GameplayEventsWriter.StartLogging(0.0f);
	}
}

function bool ShouldStartMatch()
{
	if ( bWaitForNetPlayers && WorldInfo.NetMode != NM_Standalone )
	{
		return 	NumPlayers >= MinNetPlayers;
	}
	return true;
}

function bool CheckAllPlayersReady()
{
	local int i;
	local array<KFPlayerReplicationInfo> KFPRIArray;

	MyKFGRI.GetKFPRIArray(KFPRIArray);
	for ( i = 0; i < KFPRIArray.Length; i++ )
	{
		if ( !IsPlayerReady( KFPRIArray[i] ) )
		{
			return false;
		}
	}

	return true;
}

/**
 * @brief Checks if majority of players readied up yet
 * @return true if a majority of the players have readied up
 */
function bool MajorityPlayersReady()
{
	local int i, readyPlayers;
	local array<KFPlayerReplicationInfo> KFPRIArray;
	local float readyPercent;

	MyKFGRI.GetKFPRIArray(KFPRIArray);

	if( KFPRIArray.Length == 0 )
	{
		return false;
	}

	for( i = 0; i < KFPRIArray.Length; i++ )
	{
		if ( IsPlayerReady( KFPRIArray[i] ) )
		{
			readyPlayers++;
		}
	}

	if( readyPlayers == 0 )
	{
		return false;
	}

	readyPercent = float(readyPlayers) / float(KFPRIArray.length);

	return readyPercent >= 0.5f;
}

/**
 * @brief Checks if any player has readied up yet
 * @return true if at least one player has readied up
 */
function bool AnyPlayerReady()
{
	local int i;
	local array<KFPlayerReplicationInfo> KFPRIArray;

	MyKFGRI.GetKFPRIArray(KFPRIArray);
	for( i = 0; i < KFPRIArray.Length; i++ )
	{
		if ( IsPlayerReady( KFPRIArray[i] ) )
		{
			return true;
		}
	}

	return false;
}

function bool IsPlayerReady( KFPlayerReplicationInfo PRI )
{
	return PRI.bReadyToPlay;
}

function UpdateCurrentMapVoteTime(byte NewTime, optional bool bStartTime);

function float GetTraderTime()
{
	local float MapOverride;

	MapOverride = DifficultyInfo.GetTraderTimeByMap(WorldInfo.GetMapName(true));
	if (MapOverride > 0.f)
	{
		return MapOverride;
	}

	return DifficultyInfo.GetTraderTimeByDifficulty();
}


function SkipTrader(int TimeAfterSkipTrader);

function bool ShouldOverrideDoshOnKill(class<KFPawn_Monster> KilledPawn, out float DoshGiven)
{
	return false;
}

/**
  * Checks if the next map exists.
  * Network: Dedicated Server Only
  * @param NextMap The map name to check
  * @return NextMap if it exists, a default map name otherwise.
  */
native function string CheckNextMap(string NextMap);

/*********************************************************************************************
 * @name AI
 *********************************************************************************************/

function OnAIChangeEnemy( BaseAIController AI, Pawn Enemy )
{
`if(`__TW_SDK_)
	if( BaseMutator != none )
	{
		BaseMutator.ModifyAIEnemy( AI, Enemy );
	}
`endif
}

/************************************************************************************
 * @name		Objectives
 ***********************************************************************************/

function OnEndlessSpawningObjectiveDeactivated();

static function bool HasCustomTraderVoiceGroup()
{
	return false;
}

/***********************************************
 * @name        Initial loadout modifier
 **********************************************/

simulated function AddWeaponsFromSpawnList(KFPawn P);

simulated function OverrideHumanDefaults(KFPawn_Human P);

/***********************************************
 * @name        Damage Modifier for Event
 **********************************************/
simulated function ModifyDamageGiven(out int InDamage, optional Actor DamageCauser, optional KFPawn_Monster MyKFPM, optional KFPlayerController DamageInstigator, optional class<KFDamageType> DamageType, optional int HitZoneIdx );

defaultproperties
{
	/** Scoring */
    POINTS_FOR_BOSS_KILL=10000
    POINTS_FOR_WAVE_COMPLETION=1000
    POINTS_PENALTY_FOR_DEATH=100

	bTeamGame=true
	bCanPerkAlwaysChange=true
    bRequiresPushToTalk=true
    bPauseable=false

    ZedTimeSlomoScale=0.2
	ZedTimeBlendOutTime=0.5

	BossIndex=-1

    DeathPenaltyModifiers(0)=0.05
    DeathPenaltyModifiers(1)=0.1f
    DeathPenaltyModifiers(2)=0.2f
    DeathPenaltyModifiers(3)=0.25

    GameLengthDoshScale(0)=1.75 // Short
    GameLengthDoshScale(1)=1.0  // Medium
    GameLengthDoshScale(2)=0.8  // Long

    XPMultiplier=1.0

    AccessControlClass=class'KFGame.KFAccessControl'
	OnlineGameSettingsClass=class'KFGame.KFOnlineGameSettings'
	PlayerControllerClass=class'KFGame.KFPlayerController'
	PlayerReplicationInfoClass=class'KFGame.KFPlayerReplicationInfo'
	GameReplicationInfoClass=class'KFGame.KFGameReplicationInfo'
	DefaultPawnClass=class'KFGame.KFPawn_Human'
	CustomizationPawnClass=class'KFGame.KFPawn_Customization'
	PopulationManagerClass=class'GameFramework.GameCrowdPopulationManager'
	DialogManagerClass=class'KFGame.KFDialogManager'
	HUDType=class'KFGame.KFGFXHudWrapper'
	KFGFxManagerClass=class'KFGame.KFGFxMoviePlayer_Manager'
	GameConductorClass=class'KFGame.KFGameConductor'
	DifficultyInfoClass=class'KFGameDifficultyInfo'

	bRestartLevel=false
	bWaitingToStartMatch=true
	bDelayedStart=true

	ActionMusicDelay=5.0
    ForcedMusicTracks(0)=KFMusicTrackInfo'WW_MMNU_Login.TrackInfo' // menu
    ForcedMusicTracks(1)=KFMusicTrackInfo'WW_MMNU_Login.TrackInfo' // credits
    ForcedMusicTracks(2)=KFMusicTrackInfo'WW_MACT_Default.TI_SH_Boss_DieVolter' // hans
    ForcedMusicTracks(3)=KFMusicTrackInfo'WW_MACT_Default.TI_Boss_Patriarch' // patriarch
    ForcedMusicTracks(4)=KFMusicTrackInfo'WW_MACT_Default.TI_Boss_Matriarch' // matriarch
    ForcedMusicTracks(5)=KFMusicTrackInfo'WW_MACT_Default.TI_RG_KingFP' // king fp
    ForcedMusicTracks(6)=KFMusicTrackInfo'WW_MACT_Default.TI_RG_Abomination' // abomination
    ForcedMusicTracks(7)=KFMusicTrackInfo'WW_MACT_Default.TI_WWL' // WWL Weekly

	ReservationTimeout=32
	bLogReservations=true

	MaxPlayersAllowed=`KF_MAX_PLAYERS

	NumAlwaysRelevantZeds=3

	ReconnectRespawnTime=30

	bLogAnalytics=false
	bLogGroupTeamBalance=true

// NVCHANGE_BEGIN - RLS - Debugging Effects
	bNVAlwaysDramatic=false
	bNVBlockDramatic=false
	bNVAlwaysHeadshot=false
	bNVDebugDamage=false
// NVCHANGE_END - RLS - Debugging Effects

	bSplitBossDoshReward=true

	DebugForcedOutbreakIdx=INDEX_NONE
	DebugForceSpecialWaveZedType=INDEX_NONE
}
