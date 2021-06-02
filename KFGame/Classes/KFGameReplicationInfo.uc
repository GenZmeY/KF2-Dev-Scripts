//=============================================================================
// KFGameReplicationInfo
//=============================================================================
// The KF 2 game replication class
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//  - Christian "schneidzekk" Schneider 8/27/2012
//=============================================================================

class KFGameReplicationInfo extends GameReplicationInfo
	native(ReplicationInfo)
	nativereplication;

/*************************************
* Pre game server welcome screen
*************************************/
struct native PreGameServerAdInfo
{
	var string     	BannerLink;             // Link to the banner image
	var string     	ServerMOTD;             // The server message of the day string
	var string 		WebsiteLink;			//url to the website of the server\
	var string 		ClanMotto;
};

var repnotify PreGameServerAdInfo ServerAdInfo;

var int PrimaryXPAccumulator;
var int SecondaryXPAccumulator;

/************************************
*  Traders
************************************/

/** Trader picked by the server and used for distance on HUD */
var		KFTraderTrigger		NextTrader;
/** Trader that is currently open for business */
var     KFTraderTrigger     OpenedTrader;

/** Settings used by Kismet for scripted trader actions */
var 	Volume 				TraderVolume;
var     byte 				TraderVolumeCheckType;

// used for debuging purposes to walk through the traders
var     int                 DebugingNextTraderIndex;

/** The Archtype that holds all of our trader information */
var string TraderItemsPath;
var transient KFGFxObject_TraderItems TraderItems;

/** Allow grenades */
var bool bAllowGrenadePurchase;

/** Trader dialog manager */
var KFTraderDialogManager				TraderDialogManager;
var class<KFTraderDialogManager>		TraderDialogManagerClass;
var class<KFTraderVoiceGroupBase>		TraderVoiceGroupClass;

var repnotify bool bTraderIsOpen;
var repnotify bool bWaveIsActive;
var repnotify bool bWaveStarted;
/** Replicates at beginning and end of waves to change track / track type */
var repnotify byte MusicTrackRepCount;

var repnotify byte RepKickYesVotes;
var repnotify byte RepKickNoVotes;

var repnotify byte RepSkipTraderYesVotes;
var repnotify byte RepSkipTraderNoVotes;

/** whether the current game can use stats */
var private const bool bIsUnrankedGame;

//Stored so that we can tell this on the AAR
var bool bMatchVictory;

//Whether or not traders are enabled
var bool bTradersEnabled;

struct native PerkAvailableData
{
	var bool bPerksAvailableLimited;

	var bool bBerserkerAvailable;
	var bool bCommandoAvailable;
	var bool bSupportAvailable;
	var bool bFieldMedicAvailable;
	var bool bDemolitionistAvailable;
	var bool bFirebugAvailable;
	var bool bGunslingerAvailable;
	var bool bSharpshooterAvailable;
	var bool bSwatAvailable;
	var bool bSurvivalistAvailable;
};

//Wheter or not some perks are not allowed
var repnotify PerkAvailableData PerksAvailableData;

/************************************
* Spawning
************************************/
var					byte						WaveMax;	// The "end" wave
var repnotify		byte						WaveNum; 	// The wave we are currently in
var					bool						bWaveIsEndless;
var					int							AIRemaining;
var					int							WaveTotalAICount;
var					bool						bEndlessMode;
var					bool						bObjectiveMode;

//@HSL_BEGIN - JRO - 3/21/2016 - PS4 Sessions
/************************************
* Console Sessions
************************************/
//console info
var repnotify string ConsoleGameSessionGuid;
var UniqueNetId ConsoleGameSessionHost;
var array<UniqueNetId> ConsoleGameSessionPendingPlayers;
//@HSL_END

/************************************
* Settings
************************************/
var repnotify		byte						GameLength;
var    				byte						GameDifficulty;
var    				byte						GameDifficultyModifier;
var                 byte                        MaxPerkLevel;
var 				bool 						bCustom;
var                 float                       GameAmmoCostScale;

// $$dweiss
//Bandaid memory fix - Don't preload all bosses, cache in a globally recognized spot that
//		the gameinfo and clients both have.  For now, repnotify when the boss index changes and cache
//		the appropriate monster archetype to make sure the content for it stays around for the length
//		of a match.
var repnotify		byte						BossIndex;
var					KFCharacterInfo_Monster		CachedBossArch;

/** Combined from the PRI unlocks, but does not subtract logged out players */
var private const int GameSharedUnlocks;

/************************************
* Wave Debugging
************************************/
var                 float                       CurrentSineMod;
var                 float                       CurrentNextSpawnTime;
var                 float                       CurrentSineWavFreq;
var                 float                       CurrentNextSpawnTimeMod;
var                 int                         CurrentAIAliveCount;
var                 bool                        bCurrentSMFinishedSpawning;
var                 int                         CurrentMaxMonsters;
var                 float                       CurrentTimeTilNextSpawn;
var                 float                       CurrentTotalWavesActiveTime;
/** Spawn Debugging Is Active. */
var                 bool                        bDebugSpawnManager;

/************************************
* Tracking Map
************************************/
/** Tracking Map is Active. */
var                 bool                        bTrackingMapEnabled;

/************************************
* @name 	Map/Kick/Trader vote Collector
************************************/

var KFVoteCollector				VoteCollector;
var class<KFVoteCollector>		VoteCollectorClass;

/** Stores information for replicating recently used spawn volumes for the tracker map. */
struct native SpawnVolumeInfo
{
    var vector  VolumeLocation;
    var float   UsedTime;
    var bool    bPortalSpawn;
    var byte    VolumeAge;
};

/** Recently used spawn volumes for the tracker map. */
var SpawnVolumeInfo SpawnVolumeInfos[16];
/** Index of the last spawn volume added to the array. */
var int LastSpawnVolumeIndex;

/** Track recently failed spawns from spawn volumes and portal spawns. */
var SpawnVolumeInfo FailedSpawnInfos[8];
/** Index of the last spawn volume added to the array. */
var int LastFailedSpawnIndex;

/** Stores information for replicating live zeds for the tracker map. */
struct native ZedInfo
{
    var vector                  ZedLocation;
    var KFPawn_Monster          Zed;
    var class<KFPawn_Monster>   ZedClass;
    var vector                  LastTeleportLocation;
    var bool                    bUsingSuperSpeed;
    var vector                  EnemyLocation;
    var KFPawn                  Enemy;
};

/** List of live zeds for the tracker map. */
var ZedInfo ZedInfos[32];
/** How often to update replicating zeds for the tracker map. */
var float UpdateZedInfoInterval;

/** Stores information for replicating live players for the tracker map. */
struct native HumanInfo
{
    var vector                  HumanLocation;
    var KFPawn                  Human;
    var class<KFPawn>           HumanClass;
};

/** List of live players for the tracker map. */
var HumanInfo HumanInfos[6];
/** How often to update replicating humans for the tracker map. */
var float UpdateHumanInfoInterval;

/** Max player count */
var int MaxHumanCount;

/** Stores information for replicating pickups for the tracker map. */
struct native PickupInfo
{
    var vector                  PickupLocation;
    var int                     PickupType; // 0 = ammo, 1 = weapon, 2 = armor
};

/** List of active pickups for the tracker map. */
var PickupInfo PickupInfos[20];
/** How often to update replicating pickups for the tracker map. */
var float UpdatePickupInfoInterval;

/** When TRUE, the icons that are drawn when a pawn is not visible will be hidden */
var bool bHidePawnIcons;

/************************************
* GameConductor
************************************/

/** Tracking Map is Active. */
var bool            bGameConductorGraphingEnabled;

/** Keep track of the player accuracy over the last 10 secondse */
var float           PlayerAccuracyTracker[10];

/** Keep track of the player headdshot accuracy over the last 10 secondse */
var float           PlayerHeadshotAccuracyTracker[10];

/** Keep track of the aggregate player player skill over the last 10 secondse */
var float           AggregatePlayerSkillTracker[10];

/** Keep track of the zed total average lifespan over time */
var float           TotalZedLifeSpanAverageTracker[10];

/** Keep track of the zed current wave average lifespan over time */
var float           CurrentWaveZedLifeSpanAverageTracker[10];

/** Keep track of the zed average lifespan over the last 10 seconds */
var float           RecentZedLifeSpanAverageTracker[10];

/** Keep track of the players health over the last 10 seconds */
var float           PlayersHealthStatusTracker[10];

/** Keep track of the players ammo over the last 10 seconds */
var float           PlayersAmmoStatusTracker[10];

/** Keep track of the players combined status over the last 10 seconds */
var float           AggregatePlayersStatusTracker[10];

/** The current baseline for how long zeds should live */
var float           CurrentParZedLifeSpan;

/** Keep track of the overall rank and skill modifier the game conductor is using over the last 10 seconds */
var float           OverallRankAndSkillModifierTracker[10];

/** Keep track of the overall rank and skill modifier the game conductor is using over the last 10 seconds */
var float           ZedMovementSpeedModifierTracker[10];

/** Keep track of the overall rank and skill modifier the game conductor is using over the last 10 seconds */
var float           ZedSpawnRateModifierTracker[10];

/** Keep track of the overall rank and skill modifier the game conductor is using over the last 10 seconds */
var float           ZedSpawnRateTracker[10];

/** Replicate the current game conductor status */
var byte            CurrentGameConductorStatus;

/** The current baseline for how long zeds should live */
var float           VersusZedHealthMod;

/** The current baseline for how long zeds should live */
var float           VersusZedDamageMod;

/** The current game is a versus game */
var bool            bVersusGame;

/** The current game has global damage*/
var bool			bGlobalDamage;


/************************************
* Team Management
************************************/
var bool bAllowSwitchTeam;

/************************************
* Actor Iterators
************************************/

var array<KFDoorActor> DoorList;

/************************************
* Objectives
************************************/
var repnotify Actor CurrentObjective;
var KFInterface_MapObjective ObjectiveInterface;
var repnotify Actor PreviousObjective;
var repnotify Actor NextObjective;
var bool NextObjectiveIsEndless;
var repnotify int PreviousObjectiveResult;
var repnotify int PreviousObjectiveXPResult;
var repnotify int PreviousObjectiveVoshResult;

/** How long after selecting the objective until we activate it. */
var			  int ObjectiveDelay;

/** If true, then the next objective will start regardless of random chance. */
var			  bool bForceNextObjective;

/************************************
*  Music
************************************/
/** Audio component used for playing music tracks via SeqAct_PlayMusicTrack */
var AkComponent                 MusicComp;
/** Currently playing music track */
var KFMusicTrackInfo            CurrentMusicTrackInfo;
/** Desired music intensity, based on gameplay and replicated by host */
var byte                        MusicIntensity;
/** replicated music track (allows server to force play/sync specific tracks) */
var repnotify KFMusicTrackInfo  ReplicatedMusicTrackInfo;

/************************************
*  debug
************************************/

/************************************
*  Broken Trader Utils
************************************/
var transient bool bIsBrokenTrader;

/************************************
 *  Steam heartbeat
 ************************************/

var private float SteamHeartbeatAccumulator;
native function SendSteamHeartbeat();
native function SendSteamRequestItemDrop();

function native private EndOfWave();


cpptext
{
	INT* GetOptimizedRepList( BYTE* InDefault, FPropertyRetirement* Retire, INT* Ptr, UPackageMap* Map, UActorChannel* Channel );

	virtual void TickAuthoritative( FLOAT DeltaSeconds );
	virtual UBOOL IsUnrankedGame();
	virtual FString GetGameBalanceCol1() { return FString::Printf(TEXT(",%i,"), WaveNum); }
	virtual int GetWaveNum() { return WaveNum; }
	virtual int GetWaveMax() { return WaveMax; }
	virtual UBOOL GetWon() { return bMatchVictory; }
	virtual void TickSpecial(FLOAT DeltaSeconds);
}


/************************************
*  Replication
************************************/
replication
{
	if ( bNetDirty )
		TraderVolume, TraderVolumeCheckType, bTraderIsOpen, NextTrader, WaveNum, bWaveIsEndless, AIRemaining, WaveTotalAICount, bWaveIsActive, MaxHumanCount, bGlobalDamage, 
		CurrentObjective, PreviousObjective, PreviousObjectiveResult, PreviousObjectiveXPResult, PreviousObjectiveVoshResult, MusicIntensity, ReplicatedMusicTrackInfo, MusicTrackRepCount,
		bIsUnrankedGame, GameSharedUnlocks, bHidePawnIcons, ConsoleGameSessionGuid, GameDifficulty, GameDifficultyModifier, BossIndex, bWaveStarted, NextObjective, bIsBrokenTrader; //@HSL - JRO - 3/21/2016 - PS4 Sessions
	if ( bNetInitial )
		GameLength, WaveMax, bCustom, bVersusGame, TraderItems, GameAmmoCostScale, bAllowGrenadePurchase, MaxPerkLevel, bTradersEnabled;
	if ( bNetInitial || bNetDirty )
		PerksAvailableData;
	if ( bNetInitial && Role == ROLE_Authority )
		ServerAdInfo;

	if( bNetDirty && VoteCollector != none && VoteCollector.bIsKickVoteInProgress)
		RepKickNoVotes, RepKickYesVotes;
	if( bNetDirty && VoteCollector != none && VoteCollector.bIsSkipTraderVoteInProgress)
		RepSkipTraderNoVotes, RepSkipTraderYesVotes;

// !SHIPPING_PC_GAME && !FINAL_RELEASE in C++
	if ( bDebugSpawnManager && bNetDirty )
		CurrentSineMod, CurrentNextSpawnTime, CurrentSineWavFreq, CurrentNextSpawnTimeMod,
        CurrentAIAliveCount, bCurrentSMFinishedSpawning, CurrentMaxMonsters, CurrentTimeTilNextSpawn,
        CurrentTotalWavesActiveTime;
    if( bNetDirty )
        bTrackingMapEnabled;
	if ( bTrackingMapEnabled && bNetDirty )
		SpawnVolumeInfos, ZedInfos, HumanInfos, FailedSpawnInfos, PickupInfos;
    if( bNetDirty )
        bGameConductorGraphingEnabled;
	if ( bGameConductorGraphingEnabled && bNetDirty )
		PlayerAccuracyTracker, PlayerHeadshotAccuracyTracker, AggregatePlayerSkillTracker,
        TotalZedLifeSpanAverageTracker, CurrentWaveZedLifeSpanAverageTracker, RecentZedLifeSpanAverageTracker,
        PlayersHealthStatusTracker, PlayersAmmoStatusTracker, AggregatePlayersStatusTracker,
        CurrentParZedLifeSpan, OverallRankAndSkillModifierTracker, ZedMovementSpeedModifierTracker,
        ZedSpawnRateModifierTracker, ZedSpawnRateTracker, CurrentGameConductorStatus;
	if ( bGameConductorGraphingEnabled && bNetDirty && bVersusGame )
		VersusZedHealthMod, VersusZedDamageMod;
// endif
}

simulated event ReplicatedEvent(name VarName)
{
 	if ( VarName == nameof(bTraderIsOpen) )
	{
		if ( bTraderIsOpen )
		{
			OpenTrader();
		}
        else
        {
            CloseTrader();
        }
	}
    else if ( VarName == nameof(bWaveIsActive))
    {
		if(!bWaveIsActive)
        {
            FadeOutLingeringExplosions();
            EndOfWave();
        }
    }
	else if (VarName == nameof(bWaveStarted))
	{
		if (bWaveStarted)
		{
			NotifyWaveStart();
		}
		else
		{
			NotifyWaveEnded();
		}
	}
    else if( VarName == nameof(ReplicatedMusicTrackInfo) )
    {
        ForceNewMusicTrack( ReplicatedMusicTrackInfo );
    }
    else if( VarName == nameof(MusicTrackRepCount) )
    {
		// don't start music for boss wave, boss will start it at end of monologue
        if( !bWaveIsActive || !IsBossWave() )
        {
            PlayNewMusicTrack(true);
        }
    }
    else if( VarName == nameOf(bIsUnrankedGame) )
    {
    	if( bIsUnrankedGame )
    	{
    		`warn(GetFuncName() @ "Game is UNRANKED!");
    	}
    }
    else if( VarName == nameOf(RepKickYesVotes) || VarName == nameOf(RepKickNoVotes) )
    {
    	VoteCollector.UnPackKickVotes();
    }
    else if( VarName == nameOf(RepSkipTraderYesVotes) || VarName == nameOf(RepSkipTraderNoVotes) )
    {
    	VoteCollector.UnPackSkipTraderVotes();
    }
    else if( VarName == 'ServerAdInfo')
	{
		ShowPreGameServerWelcomeScreen();
	}
	else if( VarName == 'WaveNum')
	{
		UpdateHUDWaveCount();
		TriggerClientWaveStartEvents();
	}
//@HSL_BEGIN - JRO - 3/21/2016 - PS4 Sessions
	else if( VarName == 'ConsoleGameSessionGuid' )
	{
		KFPlayerController(GetALocalPlayerController()).TryJoinGameSession();
	}
//@HSL_END
    else if (VarName == 'CurrentObjective')
    {
        if (CurrentObjective != none)
        {
            ObjectiveInterface = KFInterface_MapObjective(CurrentObjective);
            ObjectiveInterface.ActivateObjective();
        }
        else
        {
			if (GetALocalPlayerController() != none)
			{
				KFPlayerController(GetALocalPlayerController()).SeasonalEventStats_OnMapObjectiveDeactivated(Actor(ObjectiveInterface));
			}

            ObjectiveInterface.DeactivateObjective();
            ObjectiveInterface = none;
        }
    }
	else if (VarName == 'BossIndex')
	{
		CacheSelectedBoss(BossIndex);
	}
	else if (VarName == nameof(NextObjective))
	{
		if (NextObjective != none)
		{
			KFInterface_MapObjective(NextObjective).NotifyObjectiveSelected();
		}
	}
	else if (VarName == nameof(GameLength))
	{
		ReceivedGameLength();
	}
	else if(VarName == nameof(PerksAvailableData))
	{
		UpdatePerksAvailable();
	}
	else
	{
		super.ReplicatedEvent(VarName);
	}
}

simulated event PostBeginPlay()
{
	local KFDoorActor Door;

	VoteCollector = new(Self) VoteCollectorClass;

	Super.PostBeginPlay();

//@HSL_BEGIN - JRO - 3/21/2016 - PS4 Sessions
	ConsoleGameSessionGuid = KFGameEngine(Class'Engine'.static.GetEngine()).ConsoleGameSessionGuid;
//@HSL_END

	// cache list of all doors actors (useful for HUD)
	ForEach DynamicActors(class'KFDoorActor', Door)
	{
		DoorList.AddItem(Door);
	}

	if( WorldInfo.NetMode != NM_DedicatedServer && TraderDialogManagerClass != none )
	{
		TraderDialogManager = Spawn(TraderDialogManagerClass);
	}

	// Override timer at a constant 1s instead of TimeDilation, so that it slows
	// down during zedtime.  Also, removed the SetTimer() call from Timer()
	SetTimer(1.f, true);

	TraderItems = KFGFxObject_TraderItems(DynamicLoadObject(TraderItemsPath, class'KFGFxObject_TraderItems'));
}

simulated function ReceivedGameLength()
{
	ActivateLevelLoadedEvents();
}

simulated function ActivateLevelLoadedEvents()
{
	local Sequence GameSeq;
	local array<SequenceObject> AllSeqEvents;
	local array<int> ActivateIndices;
	local int i;

	GameSeq = WorldInfo.GetGameSequence();
	if (GameSeq != None)
	{
		// find any Level Loaded events that exist
		GameSeq.FindSeqObjectsByClass(class'KFSeqEvent_LevelLoaded', true, AllSeqEvents);
		ActivateIndices = GetKFSeqEventLevelLoadedIndices();

		if (ActivateIndices.Length == 0)
		{
			return;
		}

		// activate them
		for (i = 0; i < AllSeqEvents.Length; i++)
		{
			// We need the GRI to be able to activate the correct index (based on game length / type).
			// If we've been waiting for the GRI, activate.
			if (KFSeqEvent_LevelLoaded(AllSeqEvents[i]).bWaitingForGRI)
			{
				SeqEvent_LevelLoaded(AllSeqEvents[i]).CheckActivate(WorldInfo, None, false, ActivateIndices);
				KFSeqEvent_LevelLoaded(AllSeqEvents[i]).bWaitingForGRI = false;
			}
		}
	}
}

simulated function array<int> GetKFSeqEventLevelLoadedIndices()
{
	local array<int> ActivateIndices;

	switch (GameLength)
	{
	case 0: // short
		ActivateIndices[0] = 3;
		break;

	case 1: // medium
		ActivateIndices[0] = 4;
		break;

	case 2: // long
		ActivateIndices[0] = 5;
		break;
	};

	return ActivateIndices;
}

/** Called when the GameClass property is set (at startup for the server, after the variable has been replicated on clients) */
simulated function ReceivedGameClass()
{
	local class<KFGameInfo> KFGameClass;
	local KFMapInfo KFMI;
	local class<KFTraderVoiceGroupBase> MapVoiceGroupClass;

	KFGameClass = class<KFGameInfo>(GameClass);
	if ( KFGameClass != None )
	{
		// Load/Cache game type specific classes (Network: All)
		KFGameClass.static.PreloadGlobalContentClasses();

		if( TraderDialogManager != none )
		{
			// Priority for trader voice groups:
			// 1. special game mode (e.g. endless)
			// 2. map specific (e.g. Summer Sideshow)
			// 3. purchaseable (for survival game mode)
			// 4. default (for survival game mode)

			TraderDialogManager.TraderVoiceGroupClass = KFGameClass.default.TraderVoiceGroupClass;

			KFMI = KFMapInfo(WorldInfo.GetMapInfo());
			if (KFMI != none)
			{
				if (bEndlessMode)
				{
					if (KFMI.TraderVoiceGroupClassPath_Endless != "")
					{
						MapVoiceGroupClass = class<KFTraderVoiceGroupBase>(DynamicLoadObject(KFMI.TraderVoiceGroupClassPath_Endless, class'Class'));
					}
				}
				else if (bObjectiveMode)
				{
					if (KFMI.TraderVoiceGroupClassPath_Objective != "")
					{
						MapVoiceGroupClass = class<KFTraderVoiceGroupBase>(DynamicLoadObject(KFMI.TraderVoiceGroupClassPath_Objective, class'Class'));
					}
				}
				else
				{
					if (KFMI.TraderVoiceGroupClassPath != "")
					{
						MapVoiceGroupClass = class<KFTraderVoiceGroupBase>(DynamicLoadObject(KFMI.TraderVoiceGroupClassPath, class'Class'));
					}
				}
			}

			if (MapVoiceGroupClass != None)
			{
				TraderDialogManager.TraderVoiceGroupClass = MapVoiceGroupClass;
			}
		}

        if( KFGameClass.static.ShouldPlayMusicAtStart() && MusicComp == None )
        {
            PlayNewMusicTrack(false, true);
        }
	}

	DebugingNextTraderIndex = -1;

	Super.ReceivedGameClass();
}

simulated function CacheSelectedBoss(int NewBossIndex)
{
	local class<KFGameInfo> KFGameClass;
	local class<KFPawn_Monster> KFMonsterClass;

	BossIndex = NewBossIndex;

	KFGameClass = class<KFGameInfo>(GameClass);
	if (KFGameClass != None)
	{
		KFMonsterClass = KFGameClass.static.GetSpecificBossClass(BossIndex, KFMapInfo(WorldInfo.GetMapInfo()));
		if (KFMonsterClass != none)
		{
			SetCachedBossArchetype(KFMonsterClass.default.MonsterArchPath);
		}
	}
}
native function SetCachedBossArchetype(string MonsterArchPath);

simulated function UpdateHUDWaveCount()
{
	local KFPlayerController KFPC;

	if( WorldInfo.NetMode != NM_DedicatedServer )
	{
		KFPC = KFPlayerController(GetALocalPlayerController());
		if( KFPC != none && KFPC.MyGFxHUD != none )
		{
			KFPC.MyGFxHUD.UpdateWaveCount();
		}
	}
}

/** Process wave end event on client */
simulated function NotifyWaveEnded()
{
	local PlayerReplicationInfo PRI;
	local KFPlayerReplicationInfo KFPRI;

	if ( WorldInfo.NetMode != NM_DedicatedServer )
	{
		if( WorldInfo.MyGoreEffectManager != none )
		{
			KFGoreManager(WorldInfo.MyGoreEffectManager).ResetPersistantGore(false);
		}
	}

	bWaveStarted = false;
	bForceNetUpdate = true;

	// Reset all supplier perks
	foreach PRIArray( PRI )
	{
		KFPRI = KFPlayerReplicationInfo( PRI );
		if( KFPRI != none )
		{
			KFPRI.NotifyWaveEnded();
		}
	}
}

/** Process wave end event on client */
simulated function NotifyWaveStart()
{
	local PlayerReplicationInfo PRI;
	local KFPlayerReplicationInfo KFPRI;

	bWaveStarted = true;
	bForceNetUpdate = true;

	// Reset all supplier perks
	foreach PRIArray(PRI)
	{
		KFPRI = KFPlayerReplicationInfo(PRI);
		if (KFPRI != none)
		{
			KFPRI.NotifyWaveStart();
		}
	}
}

/**
 * Called on the server when the match is over
 *
 * Network - Server and Client (Via ReplicatedEvent)
 */

simulated function EndGame()
{
	bMatchHasBegun = false;
	bMatchIsOver = true;

	class'KFGameEngine'.static.RefreshOnlineGameData(false);
}

/* Welcome screen shenanigans */
exec reliable client function ShowPreGameServerWelcomeScreen()
{
	local KFPlayerController KFPC;

	if( WorldInfo.NetMode != NM_DedicatedServer )
	{
		return;
	}

	KFPC = KFPlayerController(GetALocalPlayerController());
	if(KFPC != none && KFPC.MyGFxManager != none)
	{
		KFPC.MyGFxManager.ShowWelcomeScreen();
	}

}

simulated function GetKFPRIArray(out array<KFPlayerReplicationInfo> KFPRIArray, optional bool bGetSpectators, optional bool bGetZedPlayers)
{
    local int i;
    local int Num;

    KFPRIArray.Remove(0, KFPRIArray.Length);
    for ( i = 0; i < PRIArray.Length; i++)
    {
		if ( PRIArray[i] != None && KFPlayerReplicationInfo(PRIArray[i]) != none &&
			 (bGetSpectators || !PRIArray[i].bOnlySpectator) && 
			 (bGetZedPlayers || PRIArray[i].GetTeamNum() != 255))
		{
			KFPRIArray[num++] = KFPlayerReplicationInfo(PRIArray[i]);
		}
    }
}

/** Fades out any lingering explosions in the world, called from ::ReplicatedEvent() */
simulated function FadeOutLingeringExplosions()
{
    local KFExplosionActorLingering LingeringExplosion;

    foreach DynamicActors( class'KFExplosionActorLingering', LingeringExplosion )
    {
        LingeringExplosion.FadeOut();
    }
}

function StartScavengeTime(int time)
{
    RemainingTime = time;
    RemainingMinute = time;
    bStopCountDown = false;
}

simulated function OpenTrader(optional int time)
{
    local KFPlayerController KFPC;
    local array<int> OutputLinksToActivate;
	local array<SequenceObject> AllTraderOpenedEvents;
	local KFSeqEvent_TraderOpened TraderOpenedEvt;
	local Sequence GameSeq;
	local int i;

	if( OpenedTrader != none )
	{
		return;
	}

	if( time > 0 && Role == ROLE_Authority )
	{
		bStopCountDown = false;
        RemainingTime = time;
		RemainingMinute = time;
	}

	OpenedTrader = NextTrader;

	if( OpenedTrader != none )
	{
		OpenedTrader.OpenTrader();

		`TraderDialogManager.PlayOpenTraderDialog( WaveNum, WaveMax, GetALocalPlayerController() );

		KFPC = KFPlayerController(GetALocalPlayerController());
		if( KFPC != none )
		{
			if( KFPC.MyGFxManager != none )
			{
				KFPC.MyGFxManager.OnTraderTimeStart();
			}
			if( KFPC.MyGFxHUD != none )
			{
				KFPC.MyGFxHUD.UpdateWaveCount();
			}
		}
	}

	if( WorldInfo.NetMode == NM_Client )
	{
		// Get the gameplay sequence.
		GameSeq = WorldInfo.GetGameSequence();
		if( GameSeq != none )
		{
			GameSeq.FindSeqObjectsByClass( class'KFSeqEvent_TraderOpened', true, AllTraderOpenedEvents );
			for( i = 0; i < AllTraderOpenedEvents.Length; ++i )
			{
				TraderOpenedEvt = KFSeqEvent_TraderOpened( AllTraderOpenedEvents[i] );
				if( TraderOpenedEvt != none && TraderOpenedEvt.bClientSideOnly )
				{
					TraderOpenedEvt.Reset();
					TraderOpenedEvt.SetWaveNum( WaveNum, WaveMax );
					if( IsFinalWave() && TraderOpenedEvt.OutputLinks.Length > 1 )
					{
						OutputLinksToActivate.AddItem( 1 );
					}
					else
					{
						OutputLinksToActivate.AddItem( 0 );
					}
					TraderOpenedEvt.CheckActivate( self, self,, OutputLinksToActivate );
				}
			}
		}
	}
}

/** Cheat/Debugging */
simulated function OpenTraderNext(optional int time)
{
	local KFGameInfo kfGameInfo;

	kfGameInfo = KFGameInfo(WorldInfo.Game);

	if( kfGameInfo == none )
	{
		return;
	}

	if( time > 0 && Role == ROLE_Authority )
	{
		bStopCountDown = false;
        RemainingTime = time;
		RemainingMinute = time;
	}

	// See if we have a scripted trader to assign first
	if( kfGameInfo.ScriptedTrader != none )
	{
		NextTrader = kfGameInfo.ScriptedTrader;
		kfGameInfo.ScriptedTrader = none;
	}
	else if( kfGameInfo.TraderList.Length > 0 )
	{
		if( DebugingNextTraderIndex == -1 && OpenedTrader != none )
		{
			// lets add the current trader to the end of list so it can be used again
			kfGameInfo.TraderList.AddItem(OpenedTrader);
		}

		if( DebugingNextTraderIndex + 1 >= kfGameInfo.TraderList.Length )
		{
			DebugingNextTraderIndex= -1;
		}

		DebugingNextTraderIndex = DebugingNextTraderIndex + 1;
		NextTrader = kfGameInfo.TraderList[ DebugingNextTraderIndex ];
		//kfGameInfo.TraderList.Remove( kfGameInfo.NextTraderIndex, 1 );
	}

	OpenedTrader = NextTrader;
	OpenedTrader.OpenTrader();

	`TraderDialogManager.PlayOpenTraderDialog( WaveNum, WaveMax, GetALocalPlayerController() );
}

simulated function CloseTrader()
{
    local KFPlayerController KFPC;
    local PlayerController LocalPC;
	local KFSeqEvent_TraderClosed TraderClosedEvt;
	local array<SequenceObject> AllTraderClosedEvents;
	local Sequence GameSeq;
	local int i;

    LocalPC = GetALocalPlayerController();

	if (OpenedTrader != none)
	{
		bStopCountDown = true;
		OpenedTrader.CloseTrader();
		OpenedTrader = none;

		`TraderDialogManager.PlayCloseTraderDialog( LocalPC );

		if (WorldInfo.NetMode == NM_Client)
		{
			GameSeq = WorldInfo.GetGameSequence();
			if (GameSeq != none)
			{
				GameSeq.FindSeqObjectsByClass(class'KFSeqEvent_TraderClosed', true, AllTraderClosedEvents);
				for (i = 0; i < AllTraderClosedEvents.Length; ++i)
				{
					TraderClosedEvt = KFSeqEvent_TraderClosed(AllTraderClosedEvents[i]);
					if (TraderClosedEvt != none && TraderClosedEvt.bClientSideOnly)
					{
						TraderClosedEvt.Reset();
						TraderClosedEvt.SetWaveNum(WaveNum, WaveMax);
						TraderClosedEvt.CheckActivate(self, self);
					}
				}
			}
		}
	}

    //KFPC.bPlayerUsedUpdatePerk should always be set to false here
    KFPC = KFPlayerController(LocalPC);
    if(KFPC != none)
    {
        KFPC.SetHaveUpdatePerk(false);
    }
}

simulated function int GetTraderTimeRemaining()
{
	return max(0, RemainingTime);
}

/** Triggers all client-side wave start events */
simulated function TriggerClientWaveStartEvents()
{
	local array<SequenceObject> AllWaveStartEvents;
	local array<int> OutputLinksToActivate;
	local KFSeqEvent_WaveStart WaveStartEvt;
	local Sequence GameSeq;
	local int i;

	if( WorldInfo.NetMode == NM_Client )
	{
		// Get the gameplay sequence.
		GameSeq = WorldInfo.GetGameSequence();
		if( GameSeq != none )
		{
			GameSeq.FindSeqObjectsByClass( class'KFSeqEvent_WaveStart', true, AllWaveStartEvents );
			for( i = 0; i < AllWaveStartEvents.Length; ++i )
			{
				WaveStartEvt = KFSeqEvent_WaveStart( AllWaveStartEvents[i] );
				if( WaveStartEvt != none && WaveStartEvt.bClientSideOnly )
				{
					WaveStartEvt.Reset();
					WaveStartEvt.SetWaveNum( WaveNum, WaveMax );
					if( IsBossWave() && WaveStartEvt.OutputLinks.Length > 1 )
					{
						OutputLinksToActivate.AddItem( 1 );
					}
					else
					{
						OutputLinksToActivate.AddItem( 0 );
					}
					WaveStartEvt.CheckActivate( self, self,, OutputLinksToActivate );
				}
			}
		}
	}
}

function float GetHeartbeatAccumulatorAmount()
{
	return SteamHeartbeatAccumulator;
}


//After action report
simulated function OnOpenAfterActionReport(optional float time)
{
	if( time > 0 && Role == ROLE_Authority )
	{
		bStopCountDown = false;
        RemainingTime = time;
		RemainingMinute = time;
	}
}

simulated function ProcessChanceDrop()
{
	`if (`__TW_NETWORKING_)
	SendSteamHeartbeat(); // be sure no time is lost at the end of match
	SendSteamRequestItemDrop(); // see if we've accumulated enough time
	`endif
}

simulated event SendPlayfabGameTimeUpdate( optional bool bGameEnd )
{
	local JsonObject Parms;

	Parms = new class'JsonObject';
	Parms.SetIntValue("UpdateTime", SteamHeartbeatAccumulator);
	Parms.SetBoolValue("bGameEnd", bGameEnd);
	class'GameEngine'.static.GetPlayfabInterface().ExecuteCloudScript("UpdatePlayRewards", Parms);
}

simulated function int GetNextMapTimeRemaining()
{
	return max(0, RemainingTime);
}

/** Called from the GameInfo when the trader pod should be activated */
function SetWaveActive(bool bWaveActive, optional byte NewMusicIntensity)
{
    // set up music intensity for this wave
    MusicIntensity = NewMusicIntensity;
	bTraderIsOpen = !bWaveActive && bMatchHasBegun && bTradersEnabled;
    bWaveIsActive = bWaveActive;
	bForceNetUpdate = true;

    //  replicate track change
    MusicTrackRepCount++;

    if( !(IsBossWaveNext() && bWaveActive) && WorldInfo.NetMode != NM_DedicatedServer )
    {
        PlayNewMusicTrack( true );
    }
}

simulated function bool IsFinalWave()
{
	return (WaveNum == WaveMax - 1);
}

simulated function bool IsBossWave()
{
	return WaveNum == WaveMax;
}

simulated function bool IsInfiniteWave()
{
	return true;
}

simulated function bool IsBossWaveNext()
{
	return WaveNum == WaveMax - 1;
}

simulated function bool IsSpecialWave(out int ModIndex)
{
	return false;
}

simulated function bool IsWeeklyWave(out int ModIndex)
{
	return false;
}

simulated function bool IsEndlessWave()
{
	return bWaveIsEndless;
}

// Called once a second
simulated event Timer()
{
    local KFGameInfo MyKFGameInfo;

	// Override super RemainingTime handling
	if( WorldInfo.Game == None || WorldInfo.Game.MatchIsInProgress() )
	{
		ElapsedTime++;
	}

    if( Role == ROLE_Authority && bDebugSpawnManager )
    {
        MyKFGameInfo = KFGameInfo(WorldInfo.Game);
        if( MyKFGameInfo != none )
        {
            CurrentAIAliveCount = KFGameInfo(WorldInfo.Game).AIAliveCount;
            if( MyKFGameInfo.SpawnManager != none )
            {
                bCurrentSMFinishedSpawning = MyKFGameInfo.SpawnManager.IsFinishedSpawning();
                CurrentMaxMonsters = MyKFGameInfo.SpawnManager.GetMaxMonsters();
                CurrentTimeTilNextSpawn = MyKFGameInfo.SpawnManager.TimeUntilNextSpawn;
                CurrentTotalWavesActiveTime = MyKFGameInfo.SpawnManager.TotalWavesActiveTime;
                CurrentSineMod = MyKFGameInfo.SpawnManager.GetSineMod();
            }
            else
            {
                bCurrentSMFinishedSpawning = true;
                CurrentMaxMonsters = 0;
                CurrentTimeTilNextSpawn = 0;
                CurrentTotalWavesActiveTime = 0;
            }
        }
    }

	if( WorldInfo.NetMode == NM_Client )
	{
		if( RemainingMinute != 0 )
		{
			RemainingTime = RemainingMinute;
			RemainingMinute = 0;
		}
	}

	if( RemainingTime > 0 && !bStopCountDown )
	{
		RemainingTime--;
		if( WorldInfo.NetMode != NM_Client )
		{
			// Sync the time every 5 seconds, like we did in RO2
			// Unreal's time get's out of sync rather fast
			if( RemainingTime % 5 == 0 )
			{
				RemainingMinute = RemainingTime;
			}
		}
	}
	// End super

	if( WorldInfo.NetMode != NM_DedicatedServer && OpenedTrader != none && RemainingTime > 0 )
	{
		`TraderDialogManager.PlayTraderTickDialog( RemainingTime, GetALocalPlayerController(), WorldInfo );
	}

    // set in native AK callback (ExitCueCallback)
    if( bPendingMusicTrackChange )
    {
        bPendingMusicTrackChange = false;
        PlayNewMusicTrack();
    }
    // fallback in case something goes wrong and we have no music playing
    else if( MusicComp != none && !MusicComp.IsPlaying() )
    {
        PlayNewMusictrack();
    }
}

//@HSL_BEGIN - JRO - 8/24/2016 - Make sure the session guid gets reset when everyone has left.
simulated function RemovePRI(PlayerReplicationInfo PRI)
{
	local UniqueNetId NullId;

	Super.RemovePRI(PRI);

	if(WorldInfo.IsConsoleDedicatedServer())
	{
		if(PRIArray.Length == 0)
		{
			ConsoleGameSessionGuid = "";
			ConsoleGameSessionHost = NullId;
		}
	}

	if (!bMatchHasBegun)
	{
		UpdateSharedUnlocks();
	}
}
//@HSL_END

native private simulated function UpdateSharedUnlocks();

/** Called by the menu system to determine if perk changes are allowed */
simulated event bool CanChangePerks()
{
	return bTraderIsOpen;
}

/* DisplayDebug()
list important controller attributes on canvas
*/
simulated function DisplayDebug(HUD HUD, out float YL, out float YPos)
{
    local int TotalClots, NumSlashers, NumUnders, NumAlphas;
    //local KFPawn_ZedClot_Slasher KFPS;
    //local KFPawn_ZedClot_Alpha KFPA;
    //local KFPawn_ZedClot_Cyst KFPC;
    local KFPawn_Monster KFPM;
	local Canvas Canvas;

	Canvas = HUD.Canvas;

    Super.DisplayDebug(HUD, YL, YPos);

	//Canvas.SetDrawColor(0,255,255);

    if (HUD.ShouldDisplayDebug('gamestate'))
    {
        Canvas.SetPos(4,YPos);
    	Canvas.DrawText("---------- KFGameInfo GameState Info ----------");
    	YPos += YL;


    	foreach DynamicActors( class'KFPawn_Monster', KFPM )
    	{
    		if( KFPM.IsAliveAndWell() )
    		{
                if( KFPM.IsA('KFPawn_ZedClot_Slasher') )
                {
                    TotalClots++;
                    NumSlashers++;
                }
                else if( KFPM.IsA('KFPawn_ZedClot_Alpha') )
                {
                    TotalClots++;
                    NumAlphas++;
                }
                else if( KFPM.IsA('KFPawn_ZedClot_Cyst') )
                {
                    TotalClots++;
                    NumUnders++;
                }
    		}
    	}

    	if( TotalClots > 0 )
    	{
            Canvas.DrawText("TotalClots:" @ TotalClots @ ", Alpha%:" @ (Float(NumAlphas)/Float(TotalClots))*100 @ ", Slasher%:" @ (Float(NumSlashers)/Float(TotalClots))*100 @ ", UnderDev%:" @ (Float(NumUnders)/Float(TotalClots))*100, FALSE);
        	YPos += YL;
        	Canvas.SetPos(4,YPos);
    	}
    	else
    	{
        	Canvas.DrawText("TotalClots: 0", FALSE);
        	YPos += YL;
        	Canvas.SetPos(4,YPos);
    	}

    	Canvas.DrawText("CurrentSineMod:" @ CurrentSineMod @ ", CurrentNextSpawnTime:" @ CurrentNextSpawnTime, FALSE);
    	YPos += YL;
    	Canvas.SetPos(4,YPos);
	}

    if (HUD.ShouldDisplayDebug('gamespeed'))
    {
        Canvas.SetPos(4,YPos);
    	Canvas.DrawText("---------- GameSpeed Info ----------");
    	YPos += YL;

        Canvas.DrawText("GameSpeed:" @ WorldInfo.TimeDilation);
    	YPos += YL;
    	Canvas.SetPos(4,YPos);
	}
}

simulated function int GetNumPlayers() //dead or alive
{
	local array< KFPlayerReplicationInfo > PRIs;

	GetKFPRIArray(PRIs);

	return PRIs.length;
}

simulated function int GetNumPlayersAlive()
{
    local int i, NumPlayersAlive;
    local array< KFPlayerReplicationInfo > PRIs;

    GetKFPRIArray(PRIs);

    for ( i = 0; i < PRIs.Length; i++ )
    {
        if( PRIs[i].PlayerHealth > 0 )
        {
            NumPlayersAlive++;
        }
    }

    return NumPlayersAlive;
}

simulated function bool AnyPlayersAlive()
{
    return GetNumPlayersAlive() > 0;
}

/** Add recently used spawn volumes to the array for the tracker map */
function AddRecentSpawnVolume( vector VolumeLocation, optional bool bPortalSpawn )
{
    LastSpawnVolumeIndex++;

    if( LastSpawnVolumeIndex > (ArrayCount(SpawnVolumeInfos) - 1) )
    {
        LastSpawnVolumeIndex = 0;
    }

    SpawnVolumeInfos[LastSpawnVolumeIndex].VolumeLocation = VolumeLocation;
    SpawnVolumeInfos[LastSpawnVolumeIndex].UsedTime = WorldInfo.TimeSeconds;
    SpawnVolumeInfos[LastSpawnVolumeIndex].bPortalSpawn = bPortalSpawn;
    SpawnVolumeInfos[LastSpawnVolumeIndex].VolumeAge = 255;
    bNetDirty = true;
}

/** Add recently used spawn volumes to the array for the tracker map */
function AddFailedSpawn( vector SpawnLocation, optional bool bPortalSpawn )
{
    LastFailedSpawnIndex++;

    if( LastFailedSpawnIndex > (ArrayCount(FailedSpawnInfos) - 1) )
    {
        LastFailedSpawnIndex = 0;
    }

    FailedSpawnInfos[LastFailedSpawnIndex].VolumeLocation = SpawnLocation;
    FailedSpawnInfos[LastFailedSpawnIndex].UsedTime = WorldInfo.TimeSeconds;
    FailedSpawnInfos[LastFailedSpawnIndex].bPortalSpawn = bPortalSpawn;
    bNetDirty = true;
}

/** Network: Server */
event Tick(float DeltaTime)
{
	super.Tick( DeltaTime );

`if(`notdefined(ShippingPC))
	// If the tracker map is enabled update the various elements for replication
	if( bTrackingMapEnabled )
	{
        UpdateSpawnVolumes();

        if( UpdateZedInfoInterval <= 0 )
        {
            UpdateZedList();
            UpdateZedInfoInterval = default.UpdateZedInfoInterval;
        }
        else
        {
            UpdateZedInfoInterval -= DeltaTime;
        }

        if( UpdateHumanInfoInterval <= 0 )
        {
            UpdateHumanList();
            UpdateHumanInfoInterval = default.UpdateHumanInfoInterval;
        }
        else
        {
            UpdateHumanInfoInterval -= DeltaTime;
        }

        if( UpdatePickupInfoInterval <= 0 )
        {
            UpdatePickupList();
            UpdatePickupInfoInterval = default.UpdatePickupInfoInterval;
        }
        else
        {
            UpdatePickupInfoInterval -= DeltaTime;
        }
    }
`endif
}

/** Update the pickup array for the tracker map */
function UpdatePickupList()
{
    local int i, j;
	local KFGameInfo KFGameInfo;

	KFGameInfo = KFGameInfo(WorldInfo.Game);

	if( KFGameInfo == none )
	{
		return;
	}

    i=0;

    for (j = 0; j < KFGameInfo.AllPickupFactories.Length; j++)
    {
        if( i < ArrayCount(PickupInfos) )
        {
            if( KFGameInfo.AllPickupFactories[j] != none && !KFGameInfo.AllPickupFactories[j].bPickupHidden )
            {
                PickupInfos[i].PickupLocation = KFGameInfo.AllPickupFactories[j].Location;
                if( KFGameInfo.AllPickupFactories[j].CurrentPickupIsAmmo() )
                {
                    PickupInfos[i].PickupType = 0;
                }
                else if( KFGameInfo.AllPickupFactories[j].CurrentPickupIsWeapon() )
                {
                    PickupInfos[i].PickupType = 1;
                }
                else if( KFGameInfo.AllPickupFactories[j].CurrentPickupIsArmor() )
                {
                    PickupInfos[i].PickupType = 2;
                }
                else
                {
                    PickupInfos[i].PickupType = -1;
                }
                bNetDirty = true;
                i++;
            }
        }
    }

    // Zero out the rest
    for (i=i; i < ArrayCount(PickupInfos); i++)
    {
        PickupInfos[i].PickupLocation = vect(0,0,0);
        PickupInfos[i].PickupType = -1;
        bNetDirty = true;
    }
}

/** Update the spawn volumes array for the tracker map */
function UpdateSpawnVolumes()
{
    local int i;

	for (i = 0; i < ArrayCount(SpawnVolumeInfos); i++)
	{
        if( !IsZero(SpawnVolumeInfos[i].VolumeLocation) )
        {
            // Clear out older spawn volumes
            if( SpawnVolumeInfos[i].bPortalSpawn && `TimeSince(SpawnVolumeInfos[i].UsedTime) > 5.0 )
            {
                SpawnVolumeInfos[i].VolumeLocation = vect(0,0,0);
                bNetDirty = true;
            }
            else if( `TimeSince(SpawnVolumeInfos[i].UsedTime) > 30.0 )
            {
                SpawnVolumeInfos[i].VolumeLocation = vect(0,0,0);
                bNetDirty = true;
            }
            else
            {
                if( SpawnVolumeInfos[i].bPortalSpawn )
                {
                    SpawnVolumeInfos[i].VolumeAge = ((5 - `TimeSince(SpawnVolumeInfos[i].UsedTime))/5) * 255;
                }
                else
                {
                    SpawnVolumeInfos[i].VolumeAge = ((30 - `TimeSince(SpawnVolumeInfos[i].UsedTime))/30) * 255;
                }
            }
        }
	}

	for (i = 0; i < ArrayCount(FailedSpawnInfos); i++)
	{
        if( !IsZero(FailedSpawnInfos[i].VolumeLocation) )
        {
            // Clear out older failed spawns
            if( `TimeSince(FailedSpawnInfos[i].UsedTime) > 10.0 )
            {
                FailedSpawnInfos[i].VolumeLocation = vect(0,0,0);
                bNetDirty = true;
            }
        }
	}
}

/** Update the zed array for the tracker map */
function UpdateZedList()
{
	local KFPawn_Monster KFPM;
    local int i;
    local bool bFoundZed;

	// Clear out dead or destroyed zeds
    for (i = 0; i < ArrayCount(ZedInfos); i++)
	{
        if( (ZedInfos[i].Zed == none && !IsZero(ZedInfos[i].ZedLocation))
            || (ZedInfos[i].Zed != none && !ZedInfos[i].Zed.IsAliveAndWell()) )
        {
            ZedInfos[i].ZedLocation = vect(0,0,0);
            ZedInfos[i].Zed = none;
            ZedInfos[i].ZedClass = none;
            ZedInfos[i].bUsingSuperSpeed = false;
            ZedInfos[i].Enemy = None;
            ZedInfos[i].EnemyLocation = vect(0,0,0);
            ZedInfos[i].LastTeleportLocation = vect(0,0,0);
            bNetDirty = true;
        }
	}

	foreach WorldInfo.Allpawns(class'KFPawn_Monster', KFPM)
	{
		if ( KFPM.IsAliveAndWell() )
		{
            bFoundZed = false;

        	// See if this zed is already in the array, and update it
            for (i = 0; i < ArrayCount(ZedInfos); i++)
        	{
                if( ZedInfos[i].Zed == KFPM )
                {
                    ZedInfos[i].ZedLocation = KFPM.Location;
                    ZedInfos[i].bUsingSuperSpeed = KFPM.bUseHiddenSpeed;

                    if( KFPM.Controller != none && KFAIController(KFPM.Controller) != none
                        && `TimeSince(KFAIController(KFPM.Controller).LastTeleportTime) < 5.0 )
                    {
                        ZedInfos[i].LastTeleportLocation = KFAIController(KFPM.Controller).LastTeleportLocation;
                    }
                    else
                    {
                        ZedInfos[i].LastTeleportLocation = vect(0,0,0);
                    }

                    if( KFPM.Controller != none && KFPM.Controller.Enemy != none )
                    {
                        ZedInfos[i].Enemy = KFPawn(KFPM.Controller.Enemy);
                        ZedInfos[i].EnemyLocation = KFPM.Controller.Enemy.Location;
                    }
                    else
                    {
                        ZedInfos[i].Enemy = None;
                        ZedInfos[i].EnemyLocation = vect(0,0,0);
                    }
                    bFoundZed = true;
                    bNetDirty = true;
                    break;
                }
        	}

            if( !bFoundZed )
            {
            	// Add this zed to an empty slot
                for (i = 0; i < ArrayCount(ZedInfos); i++)
            	{
                    if( ZedInfos[i].Zed == none )
                    {
                        ZedInfos[i].ZedLocation = KFPM.Location;
                        ZedInfos[i].Zed = KFPM;
                        ZedInfos[i].ZedClass = KFPM.class;
                        ZedInfos[i].bUsingSuperSpeed = KFPM.bUseHiddenSpeed;
                        if( KFPM.Controller != none && KFPM.Controller.Enemy != none )
                        {
                            ZedInfos[i].Enemy = KFPawn(KFPM.Controller.Enemy);
                            ZedInfos[i].EnemyLocation = KFPM.Controller.Enemy.Location;
                        }
                        else
                        {
                            ZedInfos[i].Enemy = None;
                            ZedInfos[i].EnemyLocation = vect(0,0,0);
                        }
                        if( KFPM.Controller != none && KFAIController(KFPM.Controller) != none
                            && `TimeSince(KFAIController(KFPM.Controller).LastTeleportTime) < 5.0 )
                        {
                            ZedInfos[i].LastTeleportLocation = KFAIController(KFPM.Controller).LastTeleportLocation;
                        }
                        else
                        {
                            ZedInfos[i].LastTeleportLocation = vect(0,0,0);
                        }
                        bNetDirty = true;
                        break;
                    }
            	}
        	}
		}
	}
}

/** Update the human array for the tracker map */
function UpdateHumanList()
{
	local KFPawn_Human KFPH;
    local int i;
    local bool bFoundHuman;

	// Clear out dead or destroyed humans
    for (i = 0; i < ArrayCount(HumanInfos); i++)
	{
        if( (HumanInfos[i].Human == none && !IsZero(HumanInfos[i].HumanLocation))
            || (HumanInfos[i].Human != none && !HumanInfos[i].Human.IsAliveAndWell()) )
        {
            HumanInfos[i].HumanLocation = vect(0,0,0);
            HumanInfos[i].Human = none;
            HumanInfos[i].HumanClass = none;
            bNetDirty = true;
        }
	}

	foreach WorldInfo.Allpawns(class'KFPawn_Human', KFPH)
	{
		if ( KFPH.IsAliveAndWell() )
		{
            bFoundHuman = false;

        	// See if this human is already in the array, and update it
            for (i = 0; i < ArrayCount(HumanInfos); i++)
        	{
                if( HumanInfos[i].Human == KFPH )
                {
                    HumanInfos[i].HumanLocation = KFPH.Location;
                    bFoundHuman = true;
                    bNetDirty = true;
                    break;
                }
        	}

            if( !bFoundHuman )
            {
            	// Add this zed to an empty slot
                for (i = 0; i < ArrayCount(HumanInfos); i++)
            	{
                    if( HumanInfos[i].Human == none )
                    {
                        HumanInfos[i].HumanLocation = KFPH.Location;
                        HumanInfos[i].Human = KFPH;
                        HumanInfos[i].HumanClass = KFPH.class;
                        bNetDirty = true;
                        break;
                    }
            	}
        	}
		}
	}
}

native function UpdateMusicTrack( KFMusicTrackInfo NextMusicTrackInfo, bool bPlayStandardTrack );

simulated function PlayNewMusicTrack( optional bool bGameStateChanged, optional bool bForceAmbient )
{
    local KFMapInfo             KFMI;
    local class<KFGameInfo>     KFGameClass;
    local KFMusicTrackInfo      NextMusicTrackInfo;
    local bool                  bLoop;
	local bool					bPlayActionTrack;

    if ( class'KFGameEngine'.static.CheckNoMusic() )
    {
        return;
    }

	KFGameClass = class<KFGameInfo>(GameClass);
	if ( KFGameClass == None )
	{
		return;
	}

	// @todo: consider using music intensity (255?) for ambient music to simplify this logic
	bPlayActionTrack = (!bForceAmbient && KFGameClass.static.ShouldPlayActionMusicTrack(self));

    // if we've just transitioned into the "action" phase of the game,
    // check if we need to delay the action music
    if( bGameStateChanged )
    {
        if( bPlayActionTrack )
        {
            if( KFGameClass.default.ActionMusicDelay > 0 )
            {
                SetTimer( KFGameClass.default.ActionMusicDelay, false, nameof(PlayNewMusicTrack) );
                return;
            }
        }
    }
    else if( CurrentMusicTrackInfo != none )
    {
        bLoop = CurrentMusicTrackInfo.bLoop;
    }

    // loop if we're designated to loop or this is the boss wave
    if( bLoop || (!bEndlessMode && IsBossWave()))
    {
        NextMusicTrackInfo = CurrentMusicTrackInfo;
    }
    else
    {
        KFMI = KFMapInfo(WorldInfo.GetMapInfo());
        if ( KFMI != none )
        {
            NextMusicTrackInfo = KFMI.GetNextMusicTrackByGameIntensity(bPlayActionTrack, MusicIntensity);
        }
        else
        {
            // Some maps might not be setup correctly, let's just grab a random default song
            NextMusicTrackInfo = class'KFMapInfo'.static.StaticGetRandomTrack(bPlayActionTrack);
        }
    }

    UpdateMusicTrack( NextMusicTrackInfo, KFGameEngine(Class'Engine'.static.GetEngine()).bMusicVocalsEnabled );
}

simulated function ForceNewMusicTrack( KFMusicTrackInfo ForcedTrackInfo )
{
    if( Role == ROLE_Authority )
    {
        ReplicatedMusicTrackInfo = ForcedTrackInfo;
    }

    UpdateMusicTrack( ForcedTrackInfo, KFGameEngine(Class'Engine'.static.GetEngine()).bMusicVocalsEnabled );
}

/***********************************************************
@name Voting
************************************************************/

function ServerStartVoteKick(PlayerReplicationInfo PRI_Kickee, PlayerReplicationInfo PRI_Kicker)
{
	if(VoteCollector != none)
	{
		VoteCollector.ServerStartVoteKick(PRI_Kickee, PRI_Kicker);
	}
}

reliable server function RecieveVoteKick(PlayerReplicationInfo PRI, bool bKick)
{
	if(VoteCollector != none)
	{
		VoteCollector.RecieveVoteKick(PRI, bKick);
	}
}

function ServerStartVoteSkipTrader(PlayerReplicationInfo PRI)
{
	if(VoteCollector != none)
	{
		VoteCollector.ServerStartVoteSkipTrader(PRI);
	}
}

reliable server function RecieveVoteSkipTrader(PlayerReplicationInfo PRI, bool bSkipTrader)
{
	if(VoteCollector != none)
	{
		VoteCollector.RecieveVoteSkipTrader(PRI, bSkipTrader);
	}
}

reliable server function ReceiveVoteMap(PlayerReplicationInfo PRI, int MapIndex)
{
	if(VoteCollector != none)
	{
		VoteCollector.ReceiveVoteMap( PRI, MapIndex);
	}
}

/***********************************************************
@name Ranking
************************************************************/

final private event NotifyGameUnranked()
{
	if( WorldInfo.Game != none )
	{
		WorldInfo.Game.UpdateGameSettings();
	}
}

/***********************************************************
@name Post Round Info
************************************************************/

function int GetCurrentRoundNumber();

/***********************************************************
@name Team management
************************************************************/
simulated function bool AreTeamsOutOfBalanced();


//@HSL_BEGIN - AGM - 7-16-15 - Support for checking for valid stats session
/***********************************************************
@name Stats management
************************************************************/
simulated event bool IsStatsSessionValid()
{
	return true;
}
//@HSL_END

//*****************************************************************************
//  Objectives
//*****************************************************************************
function ChooseNextObjective(int NextWaveNum)
{
    local KFMapInfo KFMI;

	// reset/default to no objective chosen
	NextObjective = none;
	NextObjectiveIsEndless = false;

    KFMI = KFMapInfo(WorldInfo.GetMapInfo());
	if (KFMI != none && NextWaveNum != WaveMax)
    {
		if (KFMI.bUsePresetObjectives && NextWaveNum <= GetPresetObjectiveLength(KFMI))
        {
			ChooseNextPresetObjective(KFMI, NextWaveNum);
			return;
        }

        if (KFMI.bUseRandomObjectives)
        {
			ChooseNextRandomObjective(KFMI, NextWaveNum);
			return;
        }
    }
}

function bool ChooseNextPresetObjective(KFMapInfo KFMI, int NextWaveNum)
{
    local array<KFInterface_MapObjective> PossibleObjectives;
	local bool bUseEndlessSpawning;

	if (KFMI == none)
	{
		return false;
	}

    //Grab appropriate list of possible objectives based on wave and game length
    switch(GameLength)
    {
    case GL_Short:
		if (KFMI.PresetWaveObjectives.ShortObjectives[NextWaveNum - 1].PossibleObjectives.Length > 0)
        {
			PossibleObjectives = KFMI.PresetWaveObjectives.ShortObjectives[NextWaveNum - 1].PossibleObjectives;
			bUseEndlessSpawning = KFMI.PresetWaveObjectives.ShortObjectives[NextWaveNum - 1].bUseEndlessSpawning;
        }
        break;
    case GL_Normal:
		if (KFMI.PresetWaveObjectives.MediumObjectives[NextWaveNum - 1].PossibleObjectives.Length > 0)
        {
			PossibleObjectives = KFMI.PresetWaveObjectives.MediumObjectives[NextWaveNum - 1].PossibleObjectives;
			bUseEndlessSpawning = KFMI.PresetWaveObjectives.MediumObjectives[NextWaveNum - 1].bUseEndlessSpawning;
        }
        break;
    case GL_Long:
		if (KFMI.PresetWaveObjectives.LongObjectives[NextWaveNum - 1].PossibleObjectives.Length > 0)
        {
			PossibleObjectives = KFMI.PresetWaveObjectives.LongObjectives[NextWaveNum - 1].PossibleObjectives;
			bUseEndlessSpawning = KFMI.PresetWaveObjectives.LongObjectives[NextWaveNum - 1].bUseEndlessSpawning;
        }
        break;
    default: //Disable for mods with weird counts
        break;
    }

	return SetNextObjective(PossibleObjectives, bUseEndlessSpawning) != INDEX_NONE;
}

function int GetPresetObjectiveLength(KFMapInfo KFMI)
{
	if (KFMI == none)
	{
		return 0;
	}

	switch (GameLength)
	{
	case GL_Short:
		return ArrayCount(KFMI.PresetWaveObjectives.ShortObjectives);
	case GL_Normal:
		return ArrayCount(KFMI.PresetWaveObjectives.MediumObjectives);
	case GL_Long:
		return ArrayCount(KFMI.PresetWaveObjectives.LongObjectives);
	default:
		return 0;
	}
}

function bool ChooseNextRandomObjective(KFMapInfo KFMI, int NextWaveNum)
{
    local int Idx;
	Idx = INDEX_NONE;
    //Start a random objective if we have any set
	if (KFMI.RandomWaveObjectives.Length > 0 && KFMI.RandomObjectiveWavesToDisable.Find(NextWaveNum) == INDEX_NONE)
    {
        //Attempt to reset if we've run out
        if (KFMI.CurrentAvailableRandomWaveObjectives.Length == 0)
        {
            KFMI.CurrentAvailableRandomWaveObjectives = KFMI.RandomWaveObjectives;
        }

		Idx = SetNextObjective(KFMI.CurrentAvailableRandomWaveObjectives);
        if (Idx >= 0)
        {
            KFMI.CurrentAvailableRandomWaveObjectives.Remove(Idx, 1);
        }
    }

	return Idx != INDEX_NONE;
}

function int SetNextObjective(array<KFInterface_MapObjective> PossibleObjectives, bool bUseEndlessSpawning = false, bool bActivateImmediately = false)
{
    local int RandID;
	local float DieRoll, PctChanceToActivate;

	DieRoll = FRand();
    //Loop through list of possible ones to find a random valid one.  If we never call activate, nothing was valid
    while (PossibleObjectives.Length > 0)
    {
        RandID = Rand(PossibleObjectives.Length);
		PctChanceToActivate = PossibleObjectives[RandID].GetActivationPctChance();
        if (bForceNextObjective || (PossibleObjectives[RandID].CanActivateObjective() && PreviousObjective != PossibleObjectives[RandID] && (PctChanceToActivate >= 1.f || DieRoll <= PctChanceToActivate)))
        {
			if (bActivateImmediately)
			{
				ActivateObjective(PossibleObjectives[RandID], bUseEndlessSpawning);
			}
			else
			{
				NextObjective = Actor(PossibleObjectives[RandID]);
				NextObjectiveIsEndless = bUseEndlessSpawning;
				KFInterface_MapObjective(NextObjective).NotifyObjectiveSelected();
			}
            return RandID;
        }

        PossibleObjectives.Remove(RandID, 1);
    }

    return -1;
}

function bool StartNextObjective()
{
	if (NextObjective != none)
	{
		ActivateObjective(NextObjective, NextObjectiveIsEndless);
		return true;
	}

	return false;
}

function ActivateObjective(KFInterface_MapObjective NewObjective, bool bUseEndlessSpawning = false)
{
	local KFGameInfo KFGI;

    if (NewObjective != none)
    {
        CurrentObjective = Actor(NewObjective);
		ClearPreviousObjective();
        ObjectiveInterface = NewObjective;

		if(ObjectiveDelay > 0)
		{
			SetTimer(ObjectiveDelay,, 'Timer_ActivateObjective');
		}
		else
		{
			Timer_ActivateObjective();
		}

		if (Role == ROLE_Authority && bUseEndlessSpawning)
		{
			KFGI = KFGameInfo(WorldInfo.Game);
			if (KFGI != none && KFGI.SpawnManager != none)
			{
				KFGI.SpawnManager.bTemporarilyEndless = true;
				bWaveIsEndless = true;
			}
		}
    }
}

function DeactivateObjective()
{
	local KFGameInfo KFGI;
	local KFPawn_Monster KFPM;

    if (CurrentObjective != None)
    {
		PreviousObjective = CurrentObjective;
		PreviousObjectiveResult = ObjectiveInterface.GetDoshReward();
		PreviousObjectiveVoshResult = ObjectiveInterface.GetVoshReward();
		PreviousObjectiveXPResult = ObjectiveInterface.GetXPReward();

		if (GetALocalPlayerController() != none)
		{
			KFPlayerController(GetALocalPlayerController()).SeasonalEventStats_OnMapObjectiveDeactivated(Actor(ObjectiveInterface));
		}

        ObjectiveInterface.DeactivateObjective();
        CurrentObjective = none;
        ObjectiveInterface = none;

		if (Role == ROLE_Authority)
		{
			KFGI = KFGameInfo(WorldInfo.Game);
			if (KFGI != none && KFGI.SpawnManager != none && KFGI.SpawnManager.bTemporarilyEndless)
			{
				KFGI.SpawnManager.bTemporarilyEndless = false;
				bWaveIsEndless = false;

				// when the wave switches off endless, remove all pending spawns
				// so that the user doesn't see an increasing zed count as these zeds trickle in
				KFGI.SpawnManager.ActiveSpawner.PendingSpawns.Length = 0;
				AIRemaining = KFGI.SpawnManager.GetAIAliveCount() + Max(0, KFGI.SpawnManager.WaveTotalAI - KFGI.NumAISpawnsQueued);

				if( AIRemaining <= class'KFGameInfo'.static.GetNumAlwaysRelevantZeds() )
				{
					//Tell the remaining pawns to set themselves relevant.
					foreach WorldInfo.AllPawns( class'KFPawn_Monster', KFPM )
					{
						KFPM.CheckShouldAlwaysBeRelevant();
					}
				}

				KFGI.OnEndlessSpawningObjectiveDeactivated();
			}
		}
    }

	// find the next objective (if it exists)
	// so that the area can be showed early, during trader time (if needed)
	ChooseNextObjective(WaveNum + 1);
}

function ClearPreviousObjective()
{
	PreviousObjective = none;
	PreviousObjectiveResult = INDEX_NONE;
	PreviousObjectiveVoshResult = INDEX_NONE;
	PreviousObjectiveXPResult = INDEX_NONE;
}

function Timer_ActivateObjective()
{
	if (ObjectiveInterface != none)
	{
		ObjectiveInterface.ActivateObjective();
	}
}

function float GetMapObjectiveSpawnRateMod()
{
	if (ObjectiveInterface != none)
	{
		return ObjectiveInterface.GetSpawnRateMod();
	}

	return 1.f;
}

simulated event byte GetModifiedGameDifficulty()
{
	return GameDifficulty + GameDifficultyModifier;
}

simulated event SetModifiedGameDifficulty(byte NewDifficultyMod)
{
	GameDifficultyModifier = NewDifficultyMod;
	bNetDirty = true;
}

simulated function bool ShouldSetBossCamOnBossSpawn()
{
	return true;
}

simulated function bool ShouldSetBossCamOnBossDeath()
{
	return true;
}

simulated function int GetFinalWaveNum()
{
	return WaveMax - 1;
}

simulated function bool IsObjectiveMode()
{
	return false;
}

function SetGlobalDamage(bool bEnable)
{
	bGlobalDamage = bEnable;
}

simulated function bool IsGlobalDamage()
{
	return bGlobalDamage;
}

simulated function bool IsPerkAllowed(class<KFPerk> PerkClass)
{
	if(PerksAvailableData.bPerksAvailableLimited)
	{
		if(PerkClass == class'KFPerk_Berserker')			return PerksAvailableData.bBerserkerAvailable;
		else if(PerkClass == class'KFPerk_Commando')		return PerksAvailableData.bCommandoAvailable;
		else if(PerkClass == class'KFPerk_Support')			return PerksAvailableData.bSupportAvailable;
		else if(PerkClass == class'KFPerk_FieldMedic')		return PerksAvailableData.bFieldMedicAvailable;
		else if(PerkClass == class'KFPerk_Demolitionist')	return PerksAvailableData.bDemolitionistAvailable;
		else if(PerkClass == class'KFPerk_Firebug')			return PerksAvailableData.bFirebugAvailable;
		else if(PerkClass == class'KFPerk_Gunslinger')		return PerksAvailableData.bGunslingerAvailable;
		else if(PerkClass == class'KFPerk_Sharpshooter')	return PerksAvailableData.bSharpshooterAvailable;
		else if(PerkClass == class'KFPerk_Swat')			return PerksAvailableData.bSwatAvailable;
		else if(PerkClass == class'KFPerk_Survivalist')		return PerksAvailableData.bSurvivalistAvailable;
	}
    return true;
}

simulated function UpdatePerksAvailable()
{
	KFPlayerController(GetALocalPlayerController()).UpdatePerkOnInit();
}

simulated function NotifyBrokenTrader()
{
	bIsBrokenTrader = true;
	bNetDirty = true;
}

defaultproperties
{
	TraderItemsPath="GP_Trader_ARCH.DefaultTraderItems"
	TraderDialogManagerClass=class'KFGame.KFTraderDialogManager'
    bTradersEnabled=true
	VoteCollectorClass=class'KFGame.KFVoteCollector'
	UpdateZedInfoInterval=0.5
	UpdateHumanInfoInterval=0.5
	UpdatePickupInfoInterval=1.0
	WaveMax=255
	bAllowSwitchTeam=false
    GameAmmoCostScale=1.0
    bAllowGrenadePurchase = true
    MaxPerkLevel=4
	BossIndex=255
	PreviousObjectiveResult=-1
	PreviousObjectiveVoshResult=-1
	PreviousObjectiveXPResult=-1
	bIsBrokenTrader=false
}
