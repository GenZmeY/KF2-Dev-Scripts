//=============================================================================
// KFAISpawnManager
//=============================================================================
// The KFAISpawnManager is created from the KFGameInfo to manage the wave
// based Zed spawning.
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
// - Christian "schneidzekk" Schneider
//=============================================================================

class KFAISpawnManager extends Object
	within KFGameInfo
	config(Game)
	native(AI);

`include(KFGame\KFGameAnalytics.uci);

/** Struct containing difficulty-based wave settings */
struct native DifficultyWaveInfo
{
    /** All the waves*/
    var array<KFAIWaveInfo> Waves;
};

/** Wave settings per difficulty */
var array<DifficultyWaveInfo> DifficultyWaveSettings;

/** The current settings for this difficulty */
var DifficultyWaveInfo WaveSettings;

/** The spawn group setup of a wave */
var array<KFAISpawnSquad>				AvailableSquads;

/** Controls the frequency of the AI spawning sine wave. Used to increase/decrease speed and intensity of AI spawning */
var float								SineWaveFreq;
/** WorldTime at wave start */
var float								WaveStartTime;
/** Total time that combat waves have been active */
var float								TotalWavesActiveTime;
/** The time the next AI group is spaning */
var float								TimeUntilNextSpawn;
/** Total num AI spawned in this wave */
var	int									WaveTotalAI;

struct native PerPlayerMaxMonsters
{
	var array<int> MaxMonsters;
};
var array<PerPlayerMaxMonsters> PerDifficultyMaxMonsters;

/** Used for arrays to modify spawn rate */
struct native SpawnRateModifier
{
    var() array<float> RateModifier;
};

/** How much to modify the spawn rate for solo play by difficulty */
var() SpawnRateModifier 				SoloWaveSpawnRateModifier[4];
/** How much to modify the spawn rate for early waves. Generally used to make early waves more intense */
var() float 						    EarlyWaveSpawnRateModifier[4];
/** Waves below this index will be considered "early waves" waves after this index will be considered "later waves" */
var	int									EarlyWaveIndex;
/** The base SpawnTimeMod to use in early waves based on the number of players playing */
var() float 						    EarlyWavesSpawnTimeModByPlayers[6];
/** The base SpawnTimeMod to use in late waves based on the number of players playing */
var() float 						    LateWavesSpawnTimeModByPlayers[6];

/** The number of zeds we will spawn in a whole wave is so short, the special squad may not spawn. So force it if we need to */
var bool                                bForceRequiredSquad;
/** Recycle the special squad every other time through the squad list */
var bool                                bRecycleSpecialSquad;
/** Whether to recycle the special squad every other time through the squad list, by difficulty */
var() array<bool>                       RecycleSpecialSquad;
/** Limits the number of times we can recycle the special squad */
var int                                 MaxSpecialSquadRecycles;
/** The number of times we've recycled special squads this wave */
var int                                 NumSpecialSquadRecycles;
/** Recycle the special squad every other time through the squad list */
var int                                 NumSpawnListCycles;
/** List of available AI spawn volumes */
var array<KFSpawnVolume>				SpawnVolumes;
/** Last spawn volume used by AI */
var KFSpawnVolume                       LastAISpawnVolume;

var ESquadType							DesiredSquadType;

/** If set, can be used to spawn in place of the KF1 style volume spawns */
var	KFSpawner							ActiveSpawner;

/** IDs into the AIClassList array */
enum EAIType
{
	AT_Clot,
	AT_SlasherClot,
	AT_AlphaClot,
	AT_Crawler,
	AT_GoreFast,
	AT_Stalker,
	AT_Scrake,
	AT_FleshPound,
    AT_FleshpoundMini,
	AT_Bloat,
	AT_Siren,
	AT_Husk,
	AT_BossRandom,
	AT_EliteClot,
	AT_EliteCrawler,
	AT_EliteGoreFast,
	AT_EDAR_EMP,
	AT_EDAR_Laser,
	AT_EDAR_Rocket,
};

/** IDs into the BossAIClassList array */
enum EBossAIType
{
    BAT_Hans,
    BAT_Patriarch,
    BAT_KingFleshpound,
    BAT_KingBloat,
	BAT_Matriarch,
};

/** The list of zeds the spawn manager currently has queued up to spawn*/
var array< class<KFPawn_Monster> >  LeftoverSpawnSquad;

/** The boss minion spawn squad we're currently spawning */
var array<KFAISpawnSquad>           BossMinionsSpawnSquads;
/** Boss minions are currently being summoned */
var bool bSummoningBossMinions;
/** Maximum number of boss minions to have active at one time for this current spawning set */
var int MaxBossMinions;
/** How much to scale the number of boss minions based on the number of players playing */
var() float 						MaxBossMinionScaleByPlayers[6];

/** List of currently connected players. Stored here to save time going through all controllers */
var array <Controller>	RecentSpawnSelectedHumanControllerList;


/* Used to force a specific boss */
var const int ForcedBossNum;

var bool bTemporarilyEndless;


/************************************************************************************
 * Debugging
 ***********************************************************************************/
var config bool bLogAISpawning;
var config bool bLogWaveSpawnTiming;
var config bool bLogRateVolume;

/** Builds a sorted list of spawn volumes based on distance to a specific player */
native function bool SortSpawnVolumes(Controller C, bool bTeleporting, float MinDistSquared);

static function string ZedTypeToString(EAIType AiTypeToConvert)
{
`if(`notdefined(ShippingPC))
	switch(AiTypeToConvert)
	{
	case AT_Clot:
		return "ClotU";
	case AT_SlasherClot:
		return "ClotS";
	case AT_AlphaClot:
		return "ClotA";
	case AT_Crawler:
		return "Crawler";
	case AT_GoreFast:
		return "Gorefast";
	case AT_Stalker:
		return "Stalker";
	case AT_Scrake:
		return "Scrake";
	case AT_FleshPound:
		return "Fleshpound";
    case AT_FleshpoundMini:
        return "FleshpoundMini";
	case AT_Bloat:
		return "Bloat";
	case AT_Siren:
		return "Siren";
	case AT_Husk:
		return "Husk";
	case AT_BossRandom:
		return "Hans";
	}
	return "CLOT";
`endif
	return "";
}

/** Let's get this party started (Called on match start) */
function Initialize()
{
	`log("KFAISpawnManager.Initialize()", bLogAISpawning);

    // Sets the wave settings for this difficulty
    GetWaveSettings( WaveSettings );

	//LoadAIClasses();
	RegisterSpawnVolumes();
}

/** Adds all available spawn volumes to the list */
function RegisterSpawnVolumes()
{
	local KFSpawnVolume MySpawnVolume;

    SpawnVolumes.Remove(0, SpawnVolumes.Length);

	foreach AllActors(class'KFSpawnVolume', MySpawnVolume)
	{
		// bDisabled flag used for debugging to isolate specific volumes
		if( !MySpawnVolume.bDisabled )
		{
			SpawnVolumes.AddItem(MySpawnVolume);
		}
	}

	`log("KFAISpawnManager.RegisterSpawnVolumes() Added" @ SpawnVolumes.Length @ "Volumes" , bLogAISpawning);
}

/** Next wave's basic setup */
function SetupNextWave(byte NextWaveIndex, int TimeToNextWaveBuffer = 0)
{
	local KFGameReplicationInfo KFGRI;

	if( NextWaveIndex < WaveSettings.Waves.Length )
	{
        // Recycle special squads on higher difficulties
    	if( GameDifficulty < RecycleSpecialSquad.Length )
    	{
    	   bRecycleSpecialSquad = RecycleSpecialSquad[GameDifficulty];
    	   //`log("bRecycleSpecialSquad the special squads = "$bRecycleSpecialSquad);
    	}
    	else
    	{
    	   bRecycleSpecialSquad = RecycleSpecialSquad[RecycleSpecialSquad.Length - 1];
    	   //`log("Over array size bRecycleSpecialSquad the special squads = "$bRecycleSpecialSquad);
    	}

		// Clear out any leftover spawn squads from last wave
        LeftoverSpawnSquad.Length = 0;

        // Initialize the spawn list cycles
        NumSpawnListCycles=1;

        // Initialize our recycle number
        NumSpecialSquadRecycles = 0;

		if (MyKFGRI.IsBossWave())
		{
			WaveTotalAI = 1;
		}
		else
		{
			// Scale the number of zeds if the wave can be recycled
			if (WaveSettings.Waves[NextWaveIndex].bRecycleWave)
			{
				WaveTotalAI = WaveSettings.Waves[NextWaveIndex].MaxAI *
					DifficultyInfo.GetPlayerNumMaxAIModifier(GetNumHumanTeamPlayers()) *
					DifficultyInfo.GetDifficultyMaxAIModifier();
			}
			else
			{
				WaveTotalAI = WaveSettings.Waves[NextWaveIndex].MaxAI;
			}
			WaveTotalAI *= GetTotalWaveCountScale();
			WaveTotalAI = Max(1, WaveTotalAI);
		}

        GetAvailableSquads(NextWaveIndex, true);

		WaveStartTime = WorldInfo.TimeSeconds;
		TimeUntilNextSpawn = 5.f + TimeToNextWaveBuffer;

        // Reset the total waves active time on first wave
		if( NextWaveIndex == 0 )
		{
            TotalWavesActiveTime = 0;
        }

    	KFGRI = KFGameReplicationInfo(WorldInfo.GRI);
    	if( KFGRI != none && (KFGRI.bDebugSpawnManager || KFGRI.bGameConductorGraphingEnabled) )
    	{
    		KFGRI.CurrentSineMod = GetSineMod();
    		KFGRI.CurrentNextSpawnTime = TimeUntilNextSpawn;
    		KFGRI.CurrentSineWavFreq = GetSineWaveFreq();
    		KFGRI.CurrentNextSpawnTimeMod = GetNextSpawnTimeMod();
    		KFGRI.CurrentTotalWavesActiveTime = TotalWavesActiveTime;
    		KFGRI.CurrentMaxMonsters = GetMaxMonsters();
    		KFGRI.CurrentTimeTilNextSpawn = TimeUntilNextSpawn;
    	}
	}

    LastAISpawnVolume = none;

	`log("KFAISpawnManager.SetupNextWave() NextWave:" @ NextWaveIndex @ "WaveTotalAI:" @ WaveTotalAI, bLogAISpawning || bLogWaveSpawnTiming);
}

/** Retrieves the wave settings for the current difficulty */
function GetWaveSettings( out DifficultyWaveInfo WaveInfo )
{
    WaveInfo = DifficultyWaveSettings[Min(GameDifficulty, DifficultyWaveSettings.Length-1)];
}

function GetAvailableSquads(byte MyWaveIndex, optional bool bNeedsSpecialSquad=false)
{
	local int i, j, TotalZedsInSquads;

    if( WaveSettings.Waves[MyWaveIndex] != none )
	{
		NumSpawnListCycles++;

        WaveSettings.Waves[MyWaveIndex].GetNewSquadList(AvailableSquads);

		`log("KFAISpawnManager NEW SQUAD LIST for Wave:" @ MyWaveIndex, bLogAISpawning);
		if( bNeedsSpecialSquad )
		{
		 	WaveSettings.Waves[MyWaveIndex].GetSpecialSquad(AvailableSquads);
		 	`log("KFAISpawnManager SPECIAL SQUAD for Wave:" @ MyWaveIndex, bLogAISpawning);

            for( i = 0; i < AvailableSquads.Length; i++ )
        	{
        		for( j = 0; j < AvailableSquads[i].MonsterList.Length; j++ )
        		{
                    TotalZedsInSquads += AvailableSquads[i].MonsterList[j].Num;
        		}
        	}

            //`log("WaveTotalAI :"$WaveTotalAI$" TotalZedsInSquads = "$TotalZedsInSquads);
    	 	if( WaveTotalAI < TotalZedsInSquads )
    	 	{
                bForceRequiredSquad = true;
            }
		}
	}
}

/** Spawns in our remaining reserved zeds */
function SpawnRemainingReservedZeds( optional bool bSpawnAllReservedZeds );

/** When we recycle a squad/have a leftover squad, make sure it knows what size
*   Volume it can spawn in. If for instance a larger zed has been removed from
*   the list, now the rest of the zeds may be able to spawn elsewhere. That or
*   the DesiredSquadType might have been initialized for a different size of
*   Zed groups, and be completely invalid and unset for this leftover group
*/
function ESquadType GetDesiredSquadTypeForZedList( array< class<KFPawn_Monster> >  NewSquad )
{
    local int i;
    local ESquadType LargestMonsterSquadType;

    // Start with the smallest size, and the crank it up if the squad is larger
    LargestMonsterSquadType = EST_Crawler;

    for ( i = 0; i < NewSquad.Length; i++ )
    {
        `log(GetFuncName()$" LeftOverSquad "$NewSquad[i]$" MinSquadType:"$ GetEnum(enum'ESquadType',NewSquad[i].default.MinSpawnSquadSizeType),bLogAISpawning);
        if( NewSquad[i].default.MinSpawnSquadSizeType < LargestMonsterSquadType )
        {
            LargestMonsterSquadType = NewSquad[i].default.MinSpawnSquadSizeType;
        }
    }

    return LargestMonsterSquadType;
}

function SetDesiredSquadTypeForZedList( array< class<KFPawn_Monster> >  NewSquad )
{
    DesiredSquadType = GetDesiredSquadTypeForZedList( NewSquad );
    `log(GetFuncName()$" adjusted largest squad for squad leftover squad to "$GetEnum(enum'ESquadType',DesiredSquadType),bLogAISpawning);
}

/** generate a list of classes to spawn for a given squad */
function GetSpawnListFromSquad(byte SquadIdx, out array< KFAISpawnSquad > SquadsList, out array< class<KFPawn_Monster> >  AISpawnList)
{
	local KFAISpawnSquad Squad;
	local EAIType AIType;
	local int i, j, RandNum;
	local ESquadType LargestMonsterSquadType;
    local array<class<KFPawn_Monster> > TempSpawnList;
	local class<KFPawn_Monster> ForcedPawnClass;

	Squad = SquadsList[SquadIdx];

	// Start with the smallest size, and the crank it up if the squad is larger
	LargestMonsterSquadType = EST_Crawler;

	for ( i = 0; i < Squad.MonsterList.Length; i++ )
	{
		for ( j = 0; j < Squad.MonsterList[i].Num; j++ )
		{
			if( Squad.MonsterList[i].CustomClass != None )
			{
				TempSpawnList.AddItem(Squad.MonsterList[i].CustomClass);
			}
			else
			{
				AIType = Squad.MonsterList[i].Type;
				if( AIType == AT_BossRandom )
				{
`if(`notdefined(ShippingPC))
                    if( ForcedBossNum >= 0 )
                    {
                        if (ForcedBossNum < AIBossClassList.Length)
                        {
							ForcedPawnClass = AIBossClassList[ForcedBossNum];
                        }
                        else if ((ForcedBossNum - AIBossClassList.Length) < AITestBossClassList.Length)
                        {
							ForcedPawnClass = AITestBossClassList[ForcedBossNum - AIBossClassList.Length];
                        }

						//If we've forced the class we don't greatly care about the memory results, preload content now
						ForcedPawnClass.static.PreloadContent();
						TempSpawnList.AddItem(ForcedPawnClass);
                    }
                    else
`endif
                    //Always have the squad type be a boss if we're spawning one in case of override
					TempSpawnList.AddItem(GetBossAISpawnType());
                    LargestMonsterSquadType = EST_Boss;
				}
				else
				{
					TempSpawnList.AddItem(GetAISpawnType(AIType));
				}
			}

			if( TempSpawnList[TempSpawnList.Length - 1].default.MinSpawnSquadSizeType < LargestMonsterSquadType )
            {
                LargestMonsterSquadType = TempSpawnList[TempSpawnList.Length - 1].default.MinSpawnSquadSizeType;
            }
		}
	}
	if( TempSpawnList.Length > 0 )
	{
        // Shuffle spawn list
        while( TempSpawnList.Length > 0 )
        {
            RandNum = Rand( TempSpawnList.Length );
            AISpawnList.AddItem( TempSpawnList[RandNum] );
            TempSpawnList.Remove( RandNum, 1 );
        }

		DesiredSquadType = Squad.MinVolumeType;

		if( LargestMonsterSquadType < DesiredSquadType )
        {
            DesiredSquadType = LargestMonsterSquadType;
            //`log("adjusted largest squad for squad "$Squad$" to "$GetEnum(enum'ESquadType',DesiredSquadType));
        }
	}
}

/** Returns a random AIGroup from the "waiting" list */
function array< class<KFPawn_Monster> > GetNextSpawnList()
{
	local array< class<KFPawn_Monster> >  NewSquad, RequiredSquad;
	local int RandNum, AINeeded;

	if( LeftoverSpawnSquad.Length > 0 )
    {
        if( bLogAISpawning )
        {
			`log("KFAISpawnManager.GetNextSpawnList - LeftoverSpawnSquad.Length > 0", bLogAISpawning);
            LogMonsterList(LeftoverSpawnSquad, "Leftover LeftoverSpawnSquad");
        }
        NewSquad = LeftoverSpawnSquad;

        // Make sure we properly initialize the DesiredSquadType for the leftover squads, otherwise they will just use whatever size data was left in the system
        SetDesiredSquadTypeForZedList( NewSquad );
    }
    else
    {
    	// Get a new monster list
		if( !IsAISquadAvailable() )
		{
			`log("KFAISpawnManager.GetNextSpawnList - No AI Squad available - bSummoningBossMinions:" @ bSummoningBossMinions, bLogAISpawning);

			if( !bSummoningBossMinions )
			{
	            // WaveNum Displays 1 - Length, Squads are ordered 0 - (Length - 1)
	            if( bRecycleSpecialSquad && NumSpawnListCycles % 2 == 1 && (MaxSpecialSquadRecycles == -1 || NumSpecialSquadRecycles < MaxSpecialSquadRecycles) )
	            {
	                //`log("Recycling special squad!!! NumSpawnListCycles: "$NumSpawnListCycles);
	                GetAvailableSquads(MyKFGRI.WaveNum - 1, true);
	                ++NumSpecialSquadRecycles;
	            }
	            else
	            {
	                //`log("Not recycling special squad!!! NumSpawnListCycles: "$NumSpawnListCycles);
	                GetAvailableSquads(MyKFGRI.WaveNum - 1);
	            }
	        }
	        else
	        {
	            // Replace the regular squads with boss minions
	            AvailableSquads = BossMinionsSpawnSquads;
	        }
		}

		// select a random squad from the list
		RandNum = Rand(AvailableSquads.Length);

		// If we're forcing the required squad, and it already got picked, clear the flag
		if( bForceRequiredSquad && RandNum == (AvailableSquads.Length - 1) )
		{
	       //`log("We spawned the required squad!");
		   bForceRequiredSquad=false;
		}

	    if( bLogAISpawning )
	    {
	        LogAvailableSquads();
	    }

		`log("KFAISpawnManager.GetNextAIGroup() Wave:" @ MyKFGRI.WaveNum @ "Squad:" @ AvailableSquads[RandNum] @ "Index:" @ RandNum, bLogAISpawning);

		// generate list of classes to spawn
		GetSpawnListFromSquad(RandNum, AvailableSquads, NewSquad);

		// Grab the required squad (special squad) which will be the last squad in the array,
		// if we're about to run out of zeds we can spawn, and the special squad hasn't spawned yet
		if( bForceRequiredSquad )
		{
	    	// generate list of classes to spawn
	    	GetSpawnListFromSquad((AvailableSquads.Length - 1), AvailableSquads, RequiredSquad);

	        if( (NumAISpawnsQueued + NewSquad.Length + RequiredSquad.Length) > WaveTotalAI )
	        {
	            NewSquad = RequiredSquad;
	            RandNum = (AvailableSquads.Length - 1);
	            //LogMonsterList(NewSquad, "RequiredSquad");
	            //`log("Spawning required squad NumAISpawnsQueued: "$NumAISpawnsQueued$" NewSquad.Length: "$NewSquad.Length$" RequiredSquad.Length: "$RequiredSquad.Length$" WaveTotalAI: "$WaveTotalAI);
	            bForceRequiredSquad=false;
	        }
		}

		// remove selected squad from the list of available squads
		AvailableSquads.Remove(RandNum, 1);

	    if( bLogAISpawning )
	    {
	        LogAvailableSquads();
	    }
	}

	// Clamp list by NumAINeeded()
	AINeeded = GetNumAINeeded();
	if( AINeeded < NewSquad.Length )
	{
		LeftoverSpawnSquad = NewSquad;
		// Clear out the monsters we're about to spawn from the leftover list
        LeftoverSpawnSquad.Remove( 0, AINeeded );

        // Cut off the leftovers from the new monster list
        NewSquad.Length = AINeeded;
	}
	else
	{
        // If we're spawning all the monsters in the list, there are no leftovers
        LeftoverSpawnSquad.Length = 0;
	}

    if( bLogAISpawning )
    {
    	LogMonsterList( NewSquad, "NewSquad" );
    	LogMonsterList( LeftoverSpawnSquad, "LeftoverSpawnSquad" );
    }

	return NewSquad;
}

/** Print out a list of monsters */
function LogMonsterList(array< class<KFPawn_Monster> >  MonsterList, String ListName)
{
    local int i;

	`log("Monster List "$ListName$" Length = "$MonsterList.Length);
    for( i = 0; i < MonsterList.Length; i++ )
	{
        `log( "MonsterList "$ListName$" element "$i$" is "$MonsterList[i] );
	}
}

/** Print out the available squad list */
function LogAvailableSquads()
{
    local int i, j;

	`log("Current Loaded Wave Setup");
    for( i = 0; i < AvailableSquads.Length; i++ )
	{
		for( j = 0; j < AvailableSquads[i].MonsterList.Length; j++ )
		{
            `log( "AvailableSquads "$i$" MonsterList "$j$" is "$GetEnum(enum'EAIType',SpawnManager.AvailableSquads[i].MonsterList[j].Type)$" Num: "$SpawnManager.AvailableSquads[i].MonsterList[j].Num$" SquadName: "$AvailableSquads[i] );
		}
	}
}

/** Another spawn group avaiblale */
function bool IsAISquadAvailable()
{
	`log("KFAISpawnManager.IsAISquadAvailable()" @ string(AvailableSquads.Length > 0), bLogAISpawning);
	return ( AvailableSquads.Length > 0 );
}

/** Any AI left for this wave */
function bool IsFinishedSpawning()
{
    if( ActiveSpawner != none && ActiveSpawner.bIsSpawning && ActiveSpawner.PendingSpawns.Length > 0 )
    {
        `log("KFAISpawnManager.IsFinishedSpawning() ActiveSpawner Still Spawning " @ string(ActiveSpawner != none && ActiveSpawner.bIsSpawning && ActiveSpawner.PendingSpawns.Length > 0), bLogAISpawning);
        return false;
    }

    // Keep spawning the boss minions until we tell it to stop!
    if( bSummoningBossMinions )
    {
		`log("KFAISpawnManager.IsFinishedSpawning() Summoning Boss Minions.", bLogAISpawning);
        return false;
    }

	if (bTemporarilyEndless)
	{
		`log("KFAISpawnManager.IsFinishedSpawning() Temporarily Endless", bLogAISpawning);
		return false;
	}

	if( NumAISpawnsQueued >= WaveTotalAI )
	{
		`log("KFAISpawnManager.IsFinishedSpawning()" @ string(NumAISpawnsQueued >= WaveTotalAI), bLogAISpawning);
		return true;
	}

	return false;
}

/**
* Returns the next AI spawn time
*/
function float CalcNextGroupSpawnTime()
{
	local float NextSpawnDelay, SineMod;
	local KFMapInfo KFMI;
	local KFGameReplicationInfo KFGRI;

	// Any leftover zeds from a group that didn't spawn, spawn them right away!
    if( LeftoverSpawnSquad.Length > 0 )
	{
        return 0;
	}
	else
	{
    	KFMI = KFMapInfo(WorldInfo.GetMapInfo());
    	SineMod = GetSineMod();

    	NextSpawnDelay = KFMI != none ? KFMI.WaveSpawnPeriod : class'KFMapInfo'.default.WaveSpawnPeriod;
    	NextSpawnDelay *= GetNextSpawnTimeMod();
    	NextSpawnDelay += SineMod * (NextSpawnDelay * 2);

    	KFGRI = KFGameReplicationInfo(WorldInfo.GRI);
    	if( KFGRI != none && (KFGRI.bDebugSpawnManager || KFGRI.bGameConductorGraphingEnabled) )
    	{
    		KFGRI.CurrentSineMod = SineMod;
    		KFGRI.CurrentNextSpawnTime = NextSpawnDelay;
    		KFGRI.CurrentSineWavFreq = GetSineWaveFreq();
    		KFGRI.CurrentNextSpawnTimeMod = GetNextSpawnTimeMod();
    	}
	}

	`log(GetFuncName()$" NextSpawnTime:" @ WorldInfo.TimeSeconds + NextSpawnDelay @"NextSpawnDelay:"@NextSpawnDelay$" SineMod: "$SineMod$" WaveSpawnPeriod: "$(KFMI != none ? KFMI.WaveSpawnPeriod : class'KFMapInfo'.default.WaveSpawnPeriod)$" GetNextSpawnTimeMod(): "$GetNextSpawnTimeMod(), bLogAISpawning || bLogWaveSpawnTiming);

	return NextSpawnDelay;
}

/**
* Returns a modifer based on wave and player number
* to adjust the next spawn time
*/
function float GetNextSpawnTimeMod()
{
	local byte NumLivingPlayers;
	local float SpawnTimeMod;
	local float UsedEarlyWaveRateMod;
	local float UsedSoloWaveRateMod;

	NumLivingPlayers = GetLivingPlayerCount();
	SpawnTimeMod = 1.0;
	UsedSoloWaveRateMod = 1.0;

    // Scale solo spawning rate by wave and difficulty
    if( bOnePlayerAtStart && NumLivingPlayers <= 1 )
    {
    	if( GameDifficulty < ArrayCount(SoloWaveSpawnRateModifier) )
    	{
            if( MyKFGRI.WaveNum <= SoloWaveSpawnRateModifier[GameDifficulty].RateModifier.Length )
            {
                UsedSoloWaveRateMod = SoloWaveSpawnRateModifier[GameDifficulty].RateModifier[MyKFGRI.WaveNum - 1];
            }
            else
            {
                UsedSoloWaveRateMod = SoloWaveSpawnRateModifier[GameDifficulty].RateModifier[SoloWaveSpawnRateModifier[GameDifficulty].RateModifier.Length -1];
            }
    	}
    	else
    	{
            if( MyKFGRI.WaveNum <= SoloWaveSpawnRateModifier[GameDifficulty].RateModifier.Length )
            {
                UsedSoloWaveRateMod = SoloWaveSpawnRateModifier[ArrayCount(SoloWaveSpawnRateModifier) - 1].RateModifier[MyKFGRI.WaveNum - 1];
            }
            else
            {
                UsedSoloWaveRateMod = SoloWaveSpawnRateModifier[ArrayCount(SoloWaveSpawnRateModifier) - 1].RateModifier[SoloWaveSpawnRateModifier[GameDifficulty].RateModifier.Length -1];
            }
    	}
    }

	if ( MyKFGRI.WaveNum < EarlyWaveIndex )
	{
        // Set the base SpawnTimeMod for early waves based on the number of living players
    	if( NumLivingPlayers <= ArrayCount(EarlyWavesSpawnTimeModByPlayers) )
    	{
            if( NumLivingPlayers == 0 )
            {
                SpawnTimeMod = EarlyWavesSpawnTimeModByPlayers[NumLivingPlayers];
            }
            else
            {
                SpawnTimeMod = EarlyWavesSpawnTimeModByPlayers[NumLivingPlayers - 1];
            }
    	}
    	else
    	{
    	   SpawnTimeMod = EarlyWavesSpawnTimeModByPlayers[ArrayCount(EarlyWavesSpawnTimeModByPlayers) - 1];
    	}

        `log("Early Waves SpawnTimeMod = "$SpawnTimeMod$" NumLivingPlayers = "$NumLivingPlayers$" UsedSoloWaveRateMod = "$UsedSoloWaveRateMod, bLogAISpawning);

        // Scale the spawning rate of early waves by difficulty (generally to make them more intense)
    	if( GameDifficulty < ArrayCount(EarlyWaveSpawnRateModifier) )
    	{
    	   UsedEarlyWaveRateMod = EarlyWaveSpawnRateModifier[GameDifficulty];
    	}
    	else
    	{
    	   UsedEarlyWaveRateMod = EarlyWaveSpawnRateModifier[ArrayCount(EarlyWaveSpawnRateModifier) - 1];
    	}

        SpawnTimeMod *= UsedEarlyWaveRateMod;
        SpawnTimeMod *= UsedSoloWaveRateMod;

        `log("Early waves final SpawnTimeMod = "$SpawnTimeMod, bLogAISpawning);
	}
	// Give a slightly bigger breather in the later waves
	else
	{
        // Set the base SpawnTimeMod for late waves based on the number of living players
        if( NumLivingPlayers <= ArrayCount(LateWavesSpawnTimeModByPlayers) )
    	{
            if( NumLivingPlayers == 0 )
            {
                SpawnTimeMod = LateWavesSpawnTimeModByPlayers[NumLivingPlayers];
            }
            else
            {
                SpawnTimeMod = LateWavesSpawnTimeModByPlayers[NumLivingPlayers - 1];
            }
    	}
    	else
    	{
    	   SpawnTimeMod = LateWavesSpawnTimeModByPlayers[ArrayCount(LateWavesSpawnTimeModByPlayers) - 1];
    	}

        `log("Late waves SpawnTimeMod = "$SpawnTimeMod$" NumLivingPlayers = "$NumLivingPlayers$" UsedSoloWaveRateMod = "$UsedSoloWaveRateMod, bLogAISpawning);

        SpawnTimeMod *= UsedSoloWaveRateMod;

        `log("Late waves final  SpawnTimeMod = "$SpawnTimeMod, bLogAISpawning);
	}

    // Apply difficulty based modifier
    if ( DifficultyInfo != None )
    {
        SpawnTimeMod *= DifficultyInfo.GetSpawnRateModifier();
        `log("Spawn rate modifier (difficulty):" @ DifficultyInfo.GetSpawnRateModifier(), bLogAISpawning);
    }

    //Apply global game mode spawn rate modifier
    SpawnTimeMod *= GetGameInfoSpawnRateMod() * GameConductor.CurrentSpawnRateModification;

	return Max(SpawnTimeMod, 0.f);
}

/** Modify the next spawn time based on a sine wave value */
function float GetSineMod()
{
	return 1.0 - Abs(sin( TotalWavesActiveTime * GetSineWaveFreq() ));
}

/** Returns the current spawn intensity */
function float GetSineWaveFreq()
{
	return SineWaveFreq;
}

/** Objectives can change the spawn intensity */
function SetSineWaveFreq(float NewFreq)
{
	SineWaveFreq = NewFreq;
}

/** special spawning for boss summon ability */
function SummonBossMinions( array<KFAISpawnSquad> NewMinionSquad, int NewMaxBossMinions, optional bool bUseLivingPlayerScale = true )
{
	local int NumLivePlayers;
	local float UsedMaxBossMinionsScale;

    // Clear out the previous boss minion spawning before adding new minions
    if( bSummoningBossMinions )
    {
        StopSummoningBossMinions();
    }

    bSummoningBossMinions=true;

    // Store the squad that were spawning with the boss
    BossMinionsSpawnSquads = NewMinionSquad;
    AvailableSquads = BossMinionsSpawnSquads;

    // Calculate how many minions to spawn basedoff the base
	MaxBossMinions = NewMaxBossMinions;
    NumLivePlayers = GetLivingPlayerCount();

    // Scale boss minions numbers by player count
    if (bUseLivingPlayerScale)
    {
        if (NumLivePlayers <= ArrayCount(MaxBossMinionScaleByPlayers))
        {
            if (NumLivePlayers == 0)
            {
                UsedMaxBossMinionsScale = MaxBossMinionScaleByPlayers[NumLivePlayers];
            }
            else
            {
                UsedMaxBossMinionsScale = MaxBossMinionScaleByPlayers[NumLivePlayers - 1];
            }
        }
        else
        {
            UsedMaxBossMinionsScale = MaxBossMinionScaleByPlayers[ArrayCount(MaxBossMinionScaleByPlayers) - 1];
        }
    }
    else
    {
        UsedMaxBossMinionsScale = 1.f;
    }

	MaxBossMinions *= UsedMaxBossMinionsScale;

    // Don't let us get more Boss minions than we allow total monsters
    MaxBossMinions = Min(MaxBossMinions, GetMaxMonsters());

    `log(self@GetFuncName()$" MaxBossMinions:"$MaxBossMinions, bLogAISpawning);
}

/** Stop spawning boss minions */
function StopSummoningBossMinions()
{
    bSummoningBossMinions=false;
    // Clear out the boss minions we added to the AvailableSquads
    AvailableSquads.Length=0;
}

/** Find best spawn location and spawn a squad there */
function int SpawnSquad( out array< class<KFPawn_Monster> > AIToSpawn, optional bool bSkipHumanZedSpawning=false )
{
	local KFSpawnVolume KFSV;
	local int SpawnerAmount, VolumeAmount, FinalAmount, i;
    local bool bCanSpawnPlayerBoss;

`if(`notdefined(ShippingPC))
	local KFGameReplicationInfo KFGRI;
	local vector VolumeLocation;
`endif

    // Since this is called from multiple locations, early out if we're not in a wave
    if( !IsWaveActive() )
    {
        return 0;
    }

	// first check scripted spawners
	if( ActiveSpawner != None && ActiveSpawner.CanSpawnHere(DesiredSquadType) )
	{
		SpawnerAmount = ActiveSpawner.SpawnSquad(AIToSpawn);

		`log("KFAISpawnManager.SpawnAI() Using Spawner AIs spawned:" @ SpawnerAmount @ "in Spawner:" @ ActiveSpawner, bLogAISpawning);
	}
	// otherwise use default spawn volume selection
	if( AIToSpawn.Length > 0 )
	{
		KFSV = GetBestSpawnVolume(AIToSpawn);

		if( KFSV != None )
		{
`if(`notdefined(ShippingPC))
			VolumeLocation=KFSV.Location;
`endif

            KFSV.VolumeChosenCount++;

            if( bLogAISpawning )
            {
    			LogMonsterList(AIToSpawn, "SpawnSquad Pre Spawning");
            }

            bCanSpawnPlayerBoss = (bIsVersusGame && MyKFGRI.WaveNum == MyKFGRI.WaveMax) ? CanSpawnPlayerBoss() : false;

            if( !bIsVersusGame || MyKFGRI.WaveNum < MyKFGRI.WaveMax || !bCanSpawnPlayerBoss )
            {
    			VolumeAmount = KFSV.SpawnWave(AIToSpawn, true);
                LastAISpawnVolume = KFSV;
            }

            if( bIsVersusGame && !bSkipHumanZedSpawning && MyKFGRI.WaveNum == MyKFGRI.WaveMax )
            {
                AIToSpawn.Length = 0;
            }

		    `log("KFAISpawnManager.SpawnAI() AIs spawned:" @ VolumeAmount @ "in Volume:" @ KFSV, bLogAISpawning);

            if( bLogAISpawning )
            {
                LogMonsterList(AIToSpawn, "SpawnSquad Post Spawning");
            }

`if(`notdefined(ShippingPC))
        	// Let the GRI know that a spawn volume was just used
        	KFGRI = KFGameReplicationInfo(WorldInfo.GRI);
        	if( KFGRI != none && KFGRI.bTrackingMapEnabled )
        	{
        		KFGRI.AddRecentSpawnVolume(KFSV.Location);
        	}
`endif
		}

		if( VolumeAmount == 0 )
		{
		  // `warn(self@GetFuncName()$" No spawn volume with a positive rating, no AI will spawn!!!");
		}
	}

	FinalAmount = VolumeAmount + SpawnerAmount;
	NumAIFinishedSpawning += VolumeAmount; // volume zeds get spawned right away, so add this here

   	RefreshMonsterAliveCount();

	if( AIToSpawn.Length > 0 )
	{
        //`warn(self@GetFuncName()$" Didn't spawn the whole list of AI!!!");

`if(`notdefined(ShippingPC))
    	// Let the GRI know that a spawn volume failed to spawn some AI
    	if( !IsZero(VolumeLocation) )
    	{
        	KFGRI = KFGameReplicationInfo(WorldInfo.GRI);
        	if( KFGRI != none && KFGRI.bTrackingMapEnabled )
        	{
        		KFGRI.AddFailedSpawn(VolumeLocation);
        	}
    	}
`endif

        if( bLogAISpawning )
        {
            LogMonsterList(AIToSpawn, "SpawnSquad Incomplete Spawn Remaining");
            LogMonsterList(LeftoverSpawnSquad, "Failed Spawn Before Adding To Leftovers");
        }
    	// Add any failed spawns back into the LeftoverSpawnSquad to rapidly spawn somewhere else
        for ( i = 0; i < AIToSpawn.Length; i++ )
    	{
            LeftoverSpawnSquad[LeftoverSpawnSquad.Length] = AIToSpawn[i];
    	}

        if( bLogAISpawning )
        {
    	   LogMonsterList(LeftoverSpawnSquad, "Failed Spawn After Adding To Leftovers");
    	}
	}

    /* __TW_ANALYTICS_ */
	if( bEnableGameAnalytics )
    	RecordSpawnInformation( KFSV, FinalAmount );

    return FinalAmount;
}

/**
 * Records AI debugging and tuning info for spawning
 */
/* __TW_ANALYTICS_ */
function RecordSpawnInformation( KFSpawnVolume BestSpawnVolume, int ZedsSpawned )
{
 	local KFPlayerController KFPC;
 	local vector ViewLoc;
 	local rotator ViewRot;

	foreach WorldInfo.AllControllers(class'KFPlayerController', KFPC)
	{
		if( KFPC.Pawn == none || !KFPC.Pawn.IsAliveAndWell() )
		{
			continue;
		}

        ViewLoc = KFPC.Pawn.GetPawnViewLocation();
        ViewRot = KFPC.Pawn.GetViewRotation();

    	`RecordPlayersAtSpawn( KFPC, ViewLoc, ViewRot );
	}
	`RecordBestSpawnVolume( BestSpawnVolume, MyKFGRI.WaveNum, ZedsSpawned );
}

/** "Timer" */
function Update()
{
	local array<class<KFPawn_Monster> > SpawnList;

	if( IsWaveActive() )
	{
   		TotalWavesActiveTime += 1.0;
		TimeUntilNextSpawn -= 1.f;

        if( ShouldAddAI() )
        {
        	SpawnList = GetNextSpawnList();
			NumAISpawnsQueued += SpawnSquad( SpawnList );
            TimeUntilNextSpawn = CalcNextGroupSpawnTime();
			UpdateAIRemaining();
        }
	}
}

/** Should we? */
function bool ShouldAddAI()
{
	//`log("KFAISpawnManager.ShouldAddAI()" @ string( (TimeUntilNextSpawn <= 0s && IsAIAvailable()) && (GetMaxMonsters() > AIAliveCount) ), bLogAISpawning);

	// If it is time to spawn the next squad, or there are any leftovers from the last batch spawn them
	if( (LeftoverSpawnSquad.Length > 0 || TimeUntilNextSpawn <= 0) && !IsFinishedSpawning() )
	{
        return GetNumAINeeded() > 0;
	}

	return false;
}

function int GetMaxMonsters()
{
	local int LivingPlayerCount;
	local int Difficulty;

	LivingPlayerCount = Clamp(GetLivingPlayerCount() - 1, 0, 5);
	Difficulty = Clamp(GameDifficulty, 0, 3);
	return PerDifficultyMaxMonsters[Difficulty].MaxMonsters[LivingPlayerCount];
}

/** Max currently wanted AI num */
function int GetNumAINeeded()
{
	local int AINeeded;
	local int UsedMaxMonsters;
	local KFPawn_Monster ActiveBoss;

	if (bSummoningBossMinions)
	{
		if (AIDirector != none)
		{
			ActiveBoss = AIDirector.GetActiveBoss();
			if (ActiveBoss == none || ActiveBoss.bPlayedDeath)
			{
				return 0; // Boss is dead, don't spawn any more minions.
			}
		}

	   UsedMaxMonsters = MaxBossMinions + 1; // Add 1 to include the Boss himself
	}
	else if (bTemporarilyEndless)
	{
		UsedMaxMonsters =  GetMaxMonsters();
	}
	else
	{
		if (WaveTotalAI - NumAISpawnsQueued <= 0)
		{
			return 0;
		}

	   UsedMaxMonsters =  GetMaxMonsters();
	}

    if( ActiveSpawner != none && ActiveSpawner.bIsSpawning && ActiveSpawner.PendingSpawns.Length > 0 )
    {
        // Don't add extra AI if we've queued up AI to spawn at a spawner
        AINeeded = (UsedMaxMonsters - ActiveSpawner.PendingSpawns.Length) - AIAliveCount;
        `log("KFAISpawnManager.GetNumAINeeded() ActiveSpawner.PendingSpawns.Length:" @ ActiveSpawner.PendingSpawns.Length, bLogAISpawning);
    }
    else
    {
        AINeeded = UsedMaxMonsters - GetAIAliveCount();
    }

    if( !bSummoningBossMinions && !bTemporarilyEndless )
    {
    	if( AINeeded > WaveTotalAI )
    	{
    		AINeeded = WaveTotalAI;
    	}

    	if( AINeeded > WaveTotalAI - NumAISpawnsQueued )
    	{
    		AINeeded = WaveTotalAI - NumAISpawnsQueued;
    	}
	}

    `log("KFAISpawnManager.GetNumAINeeded() WaveTotalAI:" @ WaveTotalAI @ "AIAliveCount:" @ AIAliveCount @ "NumAISpawnsQueued:" @ NumAISpawnsQueued @ "AINeeded:" @ AINeeded, bLogAISpawning);

	return AINeeded;
}

/** Returns the number of alive AI */
function int GetAIAliveCount()
{
    return AIAliveCount;
}


/** Initialize the list of Human team Controllers to use for spawn selection*/
function InitControllerList()
{
    local int i;
    local Controller C;

	// Validate the existing list
    for( i = RecentSpawnSelectedHumanControllerList.Length - 1; i >= 0; i-- )
    {
        // Must not be null, have a pawn, be alive, and be on the right team
        if( RecentSpawnSelectedHumanControllerList[i] == none || RecentSpawnSelectedHumanControllerList[i].Pawn == none
            || !RecentSpawnSelectedHumanControllerList[i].Pawn.IsAliveAndWell()
            || RecentSpawnSelectedHumanControllerList[i].GetTeamNum() != 0 )
        {

            if( RecentSpawnSelectedHumanControllerList[i] != none && RecentSpawnSelectedHumanControllerList[i].PlayerReplicationInfo != none )
            {
                `Log( GetFuncName()$" Removing "$RecentSpawnSelectedHumanControllerList[i].PlayerReplicationInfo.PlayerName$" From HumanPRIList", bLogAISpawning );
            }
            else
            {
                `Log( GetFuncName()$" Removing empty Controller From HumanPRIList", bLogAISpawning );
            }

            RecentSpawnSelectedHumanControllerList.Remove( i, 1 );
        }
    }

    if( MyKFGRI != none )
    {
        if( RecentSpawnSelectedHumanControllerList.Length == 0 )
        {
        	for ( i = 0; i < MyKFGRI.PriArray.Length; i++ )
        	{
        		C = Controller(MyKFGRI.PriArray[i].Owner);

                // If not a valid controller, on to the next one
                if( C == none || C.Pawn == none || !C.Pawn.IsAliveAndWell() || C.GetTeamNum() != 0 )
                {
                    continue;
                }

                RecentSpawnSelectedHumanControllerList[RecentSpawnSelectedHumanControllerList.Length] = C;
                `Log( GetFuncName()$" Adding "$RecentSpawnSelectedHumanControllerList[RecentSpawnSelectedHumanControllerList.Length - 1].PlayerReplicationInfo.PlayerName$" to RecentSpawnSelectedHumanControllerList", bLogAISpawning );
            }
        }
    }
}

function KFSpawnVolume GetBestSpawnVolume( optional array< class<KFPawn_Monster> > AIToSpawn, optional Controller OverrideController, optional Controller OtherController, optional bool bTeleporting, optional float MinDistSquared )
{
	local int VolumeIndex, ControllerIndex;
	local Controller RateController;

    if( OverrideController != none )
    {
        RateController = OverrideController;
    }
    else
    {
        // Get the Controller list ready for spawn selection
        InitControllerList();

        if( RecentSpawnSelectedHumanControllerList.Length > 0 )
        {
            // Randomly grab a Human PRI from the list to use for rating zed spawning
            ControllerIndex = Rand(RecentSpawnSelectedHumanControllerList.Length);
            RateController = RecentSpawnSelectedHumanControllerList[ControllerIndex];
            RecentSpawnSelectedHumanControllerList.Remove( ControllerIndex, 1 );
            `Log( GetFuncName()$" Rating with Controller "$RateController.PlayerReplicationInfo.PlayerName$" From RecentSpawnSelectedHumanControllerList", bLogAISpawning );
        }
    }

    // If there were no controllers to rate against, return none
    if( RateController == none )
    {
        `warn( GetFuncName()$" no controllers to rate spawning with!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!", bLogAISpawning);
        return none;
    }

    if( (OtherController == none || !OtherController.bIsPlayer) && NeedPlayerSpawnVolume() )
    {
    	// Grab the first player controller
    	foreach WorldInfo.AllControllers( class'Controller', OtherController )
    	{
    		if( OtherController.bIsPlayer )
    		{
		    	break;
		    }
	    }
    }

    // pre-sort the list to reduce the number of line checks performed by IsValidForSpawn
	SortSpawnVolumes(RateController, bTeleporting, MinDistSquared);

	for ( VolumeIndex = 0; VolumeIndex < SpawnVolumes.Length; VolumeIndex++ )
	{
		if ( SpawnVolumes[VolumeIndex].IsValidForSpawn(DesiredSquadType, OtherController)
			&& SpawnVolumes[VolumeIndex].CurrentRating > 0 )
		{
			`log(GetFuncName()@"returning chosen spawn volume"@SpawnVolumes[VolumeIndex]@"with a rating of"@SpawnVolumes[VolumeIndex].CurrentRating, bLogAISpawning);
			return SpawnVolumes[VolumeIndex];
		}
	}

   //`warn(GetFuncName()$" No spawn volume with a positive rating!!!");
   return none;
}

function bool NeedPlayerSpawnVolume();

function UpdateSpawnCurveIntensity(float NewSineFreq)
{
	if( NewSineFreq != 0 )
	{
		SetSineWaveFreq(NewSineFreq);
	}
}

function ResetSpawnCurveIntensity()
{
	SetSineWaveFreq(default.SineWaveFreq);
}

/** Determines whether we can spawn a player boss or not */
protected function bool CanSpawnPlayerBoss();

/** Can be called to reset values within the spawn manager, without using explicit outer */
function ResetSpawnManager();

defaultproperties
{
    ForcedBossNum=-1
	SineWaveFreq=0.04

    EarlyWaveIndex=7

	//This is a list of per-player count per-difficulty max monsters, starting with
	//Normal
	PerDifficultyMaxMonsters[0]={(
			MaxMonsters[0]=10,
			MaxMonsters[1]=14,
			MaxMonsters[2]=32,
			MaxMonsters[3]=32,
			MaxMonsters[4]=32,
			MaxMonsters[5]=32
		)}

	//Hard
	PerDifficultyMaxMonsters[1]={(
			MaxMonsters[0]=11,
			MaxMonsters[1]=18,
			MaxMonsters[2]=32,
			MaxMonsters[3]=32,
			MaxMonsters[4]=32,
			MaxMonsters[5]=32
		)}

	//Suicidial
	PerDifficultyMaxMonsters[2]={(
			MaxMonsters[0]=12,
			MaxMonsters[1]=18,
			MaxMonsters[2]=32,
			MaxMonsters[3]=32,
			MaxMonsters[4]=32,
			MaxMonsters[5]=32
		)}

	//Hell on Earth
	PerDifficultyMaxMonsters[3]={(
			MaxMonsters[0]=12, //16
			MaxMonsters[1]=18,
			MaxMonsters[2]=32,  //22
			MaxMonsters[3]=32,  //26
			MaxMonsters[4]=32,  //30
			MaxMonsters[5]=32
		)}

	// Normal
    SoloWaveSpawnRateModifier(0)={(RateModifier[0]=1.0,     // Wave 1
                                   RateModifier[1]=1.0,     // Wave 2
                                   RateModifier[2]=1.0,     // Wave 3
                                   RateModifier[3]=1.0)}    // Wave 4

	// Hard
    SoloWaveSpawnRateModifier(1)={(RateModifier[0]=1.0,     // Wave 1
                                   RateModifier[1]=1.0,     // Wave 2
                                   RateModifier[2]=1.0,     // Wave 3
                                   RateModifier[3]=1.0)}    // Wave 4

	// Suicidal
    SoloWaveSpawnRateModifier(2)={(RateModifier[0]=1.0,     // Wave 1
                                   RateModifier[1]=1.0,     // Wave 2
                                   RateModifier[2]=1.0,     // Wave 3
                                   RateModifier[3]=1.0)}    // Wave 4

	// Hell On Earth
    SoloWaveSpawnRateModifier(3)={(RateModifier[0]=1.0,     // Wave 1
                                   RateModifier[1]=1.0,     // Wave 2
                                   RateModifier[2]=1.0,     // Wave 3
                                   RateModifier[3]=1.0)}    // Wave 4

	EarlyWavesSpawnTimeModByPlayers(0)=1.0     // 1 player
	EarlyWavesSpawnTimeModByPlayers(1)=1.3     // 2 players  //1.0 //1.38  //1.0--Aug15th
	EarlyWavesSpawnTimeModByPlayers(2)=0.9    // 3 players  //1.0  //1.11
	EarlyWavesSpawnTimeModByPlayers(3)=0.7    // 4 players  //0.85 //0.84
	EarlyWavesSpawnTimeModByPlayers(4)=0.4     // 5 players //0.65  //0.57 //0.5--Aug15th
	EarlyWavesSpawnTimeModByPlayers(5)=0.3     // 6 players

	LateWavesSpawnTimeModByPlayers(0)=1.1      // 1 player   //1.1
	LateWavesSpawnTimeModByPlayers(1)=1.45     // 2 players  //1.1  //1.2--Aug15th 1.35
	LateWavesSpawnTimeModByPlayers(2)=0.9      // 3 players  //1.1
	LateWavesSpawnTimeModByPlayers(3)=0.8      // 4 players  //1.0
	LateWavesSpawnTimeModByPlayers(4)=0.7     // 5 players  //0.75
	LateWavesSpawnTimeModByPlayers(5)=0.6      // 6 players  //0.6

	EarlyWaveSpawnRateModifier(0)=0.8 // Normal //1.0 //0.6
	EarlyWaveSpawnRateModifier(1)=0.6 // Hard
	EarlyWaveSpawnRateModifier(2)=0.5 // Suicidal   //0.8
	EarlyWaveSpawnRateModifier(3)=0.5 // Hell on Earth  //0.7  //!!!!!0.5!!!!!! change back

	//LateWaveSpawnRateModifier(0)=1.0 // Normal
	//LateWaveSpawnRateModifier(1)=0.8 // Hard
	//LateWaveSpawnRateModifier(2)=0.8 // Suicidal
	//LateWaveSpawnRateModifier(3)=0.7 // Hell on Earth

	RecycleSpecialSquad(0)=false   // Normal
	RecycleSpecialSquad(1)=false   // Hard
	RecycleSpecialSquad(2)=true    // Suicidal
	RecycleSpecialSquad(3)=true    // Hell on Earth

    MaxSpecialSquadRecycles=-1

	MaxBossMinionScaleByPlayers(0)=1.0      // 1 player
	MaxBossMinionScaleByPlayers(1)=1.5      // 2 players
	MaxBossMinionScaleByPlayers(2)=1.5      // 3 players
	MaxBossMinionScaleByPlayers(3)=1.875    // 4 players
	MaxBossMinionScaleByPlayers(4)=1.875    // 5 players
	MaxBossMinionScaleByPlayers(5)=2.0      // 6 players

	bForceRequiredSquad=false
}

