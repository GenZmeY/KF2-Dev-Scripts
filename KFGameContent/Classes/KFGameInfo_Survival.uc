//=============================================================================
// KFGameInfo_Survival
//=============================================================================
// Classic Killing Floor wave based game type
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//  - Christian "schneidzekk" Schneider
//=============================================================================
class KFGameInfo_Survival extends KFGameInfo;

`include(KFGame\KFGameAnalytics.uci);
`include(KFGame\KFMatchStats.uci);

enum EWaveEndCondition
{
	WEC_WaveWon,
	WEC_TeamWipedOut,
	WEC_GameWon
};

/************************************************************************************
 * Game Config
 ***********************************************************************************/
/** Trader */
var int									TimeBetweenWaves;

var const float							EndCinematicDelay;		// time between the game ending, and the final camera change activating

/************************************************************************************
 * AAR
 ***********************************************************************************/
var const float							AARDisplayDelay;

var Array<AARAWard> TeamAwardList;

/************************************************************************************
 * Waves
 ***********************************************************************************/
var	byte								WaveMax;	// The "end" wave
var	int									WaveNum;	// The wave we are currently in
var bool                                bHumanDeathsLastWave; //Track this separate from player count in case someone dies and leaves
var int									ObjectiveSpawnDelay; // How long should the first wave be delayed if there is an active objective.

// The boss waves spams the WaveEnd functions, adding this to prevent it (was affecting seasonal events).
var protected transient bool    		bWaveStarted;

// When this is true next wave will be last
var protected bool						bGunGamePlayerOnLastGun;

var transient array<KFBarmwichBonfireVolume> BonfireVolumes;

// Trader Time modifier for Castle Volter map in the last round
var float CastleVolterTraderModifier;

/** Whether this game mode should play music from the get-go (lobby) */
static function bool ShouldPlayMusicAtStart()
{
	return true;
}

/** Whether an action or ambient track should be played */
static function bool ShouldPlayActionMusicTrack(KFGameReplicationInfo GRI)
{
	return GRI.bMatchHasBegun && !GRI.bTraderIsOpen;
}

event PreBeginPlay()
{
	super.PreBeginPlay();

	InitSpawnManager();
	UpdateGameSettings();
}

event PostBeginPlay()
{
	super.PostBeginPlay();

	TimeBetweenWaves = GetTraderTime();

	bGunGamePlayerOnLastGun = false;

	UpdateBonfires();
}

/** Set up the spawning */
function InitSpawnManager()
{
	SpawnManager = new(self) SpawnManagerClasses[GameLength];
	SpawnManager.Initialize();
	WaveMax = SpawnManager.WaveSettings.Waves.Length;
	MyKFGRI.WaveMax = WaveMax;
}

/* StartMatch()
Start the game - inform all actors that the match is starting, and spawn player pawns
*/
function StartMatch()
{
    local KFPlayerController KFPC;
	WaveNum = 0;

	super.StartMatch();

	if( class'KFGameEngine'.static.CheckNoAutoStart() || class'KFGameEngine'.static.IsEditor() )
	{
		GotoState('DebugSuspendWave');
	}
	else
	{
		GotoState('PlayingWave');
	}

    foreach WorldInfo.AllControllers(class'KFPlayerController', KFPC)
    {
        KFPC.ClientMatchStarted();
    }
}

function PlayWaveStartDialog()
{
	if (OutbreakEvent != none && OutbreakEvent.ActiveEvent.bBossRushMode)
		return;
	
	`DialogManager.PlayWaveStartDialog(MyKFGRI.IsBossWave());
	if (WaveNum == 1)
	{
		class'KFTraderDialogManager'.static.PlayFirstWaveStartDialog(WorldInfo);
	}
}

/** Custom logic to determine what the game's current intensity is */
function byte GetGameIntensityForMusic()
{
	switch( GameLength )
	{
	case GL_Short:
		if( WaveNum <= 0 )
			return 1;
		else if( WaveNum <= 1 )
			return 4;
		else if( WaveNum <= 2 )
			return 7;
		else
			return 10;
	case GL_Normal:
		if( WaveNum <= 1 )
			return 1;
		else if( WaveNum <= 3 )
			return 4;
		else if( WaveNum <= 5 )
			return 7;
		else
			return 10;
	case GL_Long:
		if( WaveNum <= 2 )
			return 1;
		else if( WaveNum <= 5 )
			return 4;
		else if( WaveNum <= 8 )
			return 7;
		else
			return 10;
	};

	return 255;
}

function bool IsPlayerReady( KFPlayerReplicationInfo PRI )
{
	local KFPlayerController KFPC;

	// Spawn our player even if we don't have a perk while using the editor or skip lobby
	if (class'KFGameEngine'.static.CheckSkipLobby() || class'Engine'.static.IsEditor())
 	{
 		return true;
 	}

	if( super.IsPlayerReady(PRI) )
	{
		KFPC = KFPlayerController(PRI.Owner);
		if ( WorldInfo.NetMode == NM_StandAlone && KFPC != None && (KFPC.CurrentPerk == None || !KFPC.CurrentPerk.bInitialized) )
		{
			// HSL - BWJ - 3-16-16 - console doesn't read stats yet, so no perk support. Adding this hack in for now so we can spawn in
			if( WorldInfo.IsConsoleDedicatedServer() || WorldInfo.IsConsoleBuild() )
			{
				`warn("TODO: Need perk support for console");
				return true;
			}
			else
			{
				`log("ERROR: Failed to load perk for:"@KFPC@KFPC.CurrentPerk);
				//ForceKickPlayer(KFPC, "Failed to find perk");
				return false; // critical error
			}
		}

		return true;
	}

	return false;
}

function bool PlayerCanRestart( PlayerController aPlayer )
{
	return (!IsWaveActive() && MyKFGRI.bMatchHasBegun);
}

function RestartPlayer(Controller NewPlayer)
{
	local KFPlayerController KFPC;
	local KFPlayerReplicationInfo KFPRI;
	local bool bWasWaitingForClientPerkData;

	KFPC = KFPlayerController(NewPlayer);
	KFPRI = KFPlayerReplicationInfo(NewPlayer.PlayerReplicationInfo);

	if( KFPC != None && KFPRI != None )
	{
		if( IsPlayerReady( KFPRI ) )
		{
			bWasWaitingForClientPerkData = KFPC.bWaitingForClientPerkData;

			/** If we have rejoined the match more than once, delay our respawn by some amount of time */
			if( MyKFGRI.bMatchHasBegun && KFPRI.NumTimesReconnected > 1 && `TimeSince(KFPRI.LastQuitTime) < ReconnectRespawnTime )
			{
				KFPC.StartSpectate();
				KFPC.SetTimer(ReconnectRespawnTime - `TimeSince(KFPRI.LastQuitTime), false, nameof(KFPC.SpawnReconnectedPlayer));
			}
			//If a wave is active, we spectate until the end of the wave
			else if( IsWaveActive() && !bWasWaitingForClientPerkData )
			{
				KFPC.StartSpectate();
			}
			else
			{
				Super.RestartPlayer(NewPlayer);

				// Already gone through one RestartPlayer() cycle, don't process again
				if( bWasWaitingForClientPerkData )
				{
					return;
				}

				if( KFPRI.Deaths == 0 )
				{
					if( WaveNum < 1 )
					{
						KFPRI.Score = DifficultyInfo.GetAdjustedStartingCash();
					}
					else
					{
						KFPRI.Score = GetAdjustedDeathPenalty( KFPRI, true );
					}
					`log("SCORING: Player" @ KFPRI.PlayerName @ "received" @ KFPRI.Score @ "starting cash", bLogScoring);
				}
			}

			`BalanceLog(GBE_Respawn, KFPRI, "$"$KFPRI.Score);

			`AnalyticsLog(("player_respawn",
						   KFPRI,
						   "#"$MyKFGRI.WaveNum,
						   "#"$KFPRI.Score ));
		}
	}
}

function ResetGunGame(KFPlayerController_WeeklySurvival KFPC_WS)
{
	super.ResetGunGame(KFPC_WS);
}

function RestartGunGamePlayerWeapon(KFPlayerController_WeeklySurvival KFPC_WS, byte WaveToUse)
{
	super.RestartGunGamePlayerWeapon(KFPC_WS, WaveToUse);
}

function Killed(Controller Killer, Controller KilledPlayer, Pawn KilledPawn, class<DamageType> damageType)
{
	local Sequence GameSeq;
	local array<SequenceObject> AllWaveProgressEvents;
	local KFSeqEvent_WaveProgress WaveProgressEvt;
	local int i;
	local KFInterface_MapObjective MapObj;

	super.Killed(Killer, KilledPlayer, KilledPawn, damageType);

	// tell objectives (ie dosh hold and exterminate) when something dies
	if (KilledPawn.IsA('KFPawn_Monster'))
	{
		MapObj = KFInterface_MapObjective(MyKFGRI.CurrentObjective);
		if (MapObj != none)
		{
			MapObj.NotifyZedKilled(Killer, KilledPawn, KFInterface_MonsterBoss(KilledPawn) != none);
		}
	}

	// if not boss wave or endless wave, play progress update trader dialog
	if( !MyKFGRI.IsBossWave() && !MyKFGRI.IsEndlessWave() && KilledPawn.IsA('KFPawn_Monster') )
    {
    	// no KFTraderDialogManager object on dedicated server, so use static function
    	class'KFTraderDialogManager'.static.PlayGlobalWaveProgressDialog( MyKFGRI.AIRemaining, MyKFGRI.WaveTotalAICount, WorldInfo );

		// Get the gameplay sequence.
		GameSeq = WorldInfo.GetGameSequence();

		if (GameSeq != none)
		{
			GameSeq.FindSeqObjectsByClass(class'KFSeqEvent_WaveProgress', TRUE, AllWaveProgressEvents);

			for (i = 0; i < AllWaveProgressEvents.Length; i++)
			{
				WaveProgressEvt = KFSeqEvent_WaveProgress(AllWaveProgressEvents[i]);

				if (WaveProgressEvt != None)
				{
					WaveProgressEvt.SetWaveProgress(MyKFGRI.AIRemaining, MyKFGRI.WaveTotalAICount, self);
				}
			}
		}
	}

    //If a human died to a non-suicide
    if (KilledPawn.IsA('KFPawn_Human') && DamageType != class'DmgType_Suicided')
    {
        bHumanDeathsLastWave = true;
    }

	// BossDied will handle the end of wave.
	if(!(KFPawn_Monster(KilledPawn) != none && KFPawn_Monster(KilledPawn).IsABoss()))
	{
		CheckWaveEnd();
	}
}

/*	Use reduce damage for friendly fire, etc. */
function ReduceDamage(out int Damage, Pawn Injured, Controller InstigatedBy, vector HitLocation, out vector Momentum, class<DamageType> DamageType, Actor DamageCauser, TraceHitInfo HitInfo)
{
	if( Injured.Controller != none && Injured.Controller.bIsPlayer && !MyKFGRI.bMatchHasBegun )
	{
		Damage = 0;
		Momentum = vect(0,0,0);
	}

	Super.ReduceDamage(Damage, Injured, InstigatedBy, HitLocation, Momentum, DamageType, DamageCauser, HitInfo);
}

function BossDied(Controller Killer, optional bool bCheckWaveEnded = true)
{
	local KFPawn_Monster AIP;
	local KFGameReplicationInfo KFGRI;
	local KFPlayerController KFPC;

	super.BossDied(Killer, bCheckWaveEnded);

	KFPC = KFPlayerController(Killer);

	`RecordBossMurderer(KFPC);

	KFGRI = KFGameReplicationInfo(WorldInfo.GRI);
	if( KFGRI != none && !KFGRI.IsBossWave() )
	{
		return;
	}

 	// Extended zed time for an extra dramatic event
 	DramaticEvent( 1, 6.f );

	// Kill all zeds active zeds when the game ends
	foreach WorldInfo.AllPawns(class'KFPawn_Monster', AIP)
	{
		if( AIP.Health > 0 )
		{
			AIP.Died(none , none, AIP.Location);
		}
	}
	if(bCheckWaveEnded)
	{
		CheckWaveEnd( true );
	}
}

function UpdateGameSettings()
{
	local name SessionName;
	local KFOnlineGameSettings KFGameSettings;
	local int NumHumanPlayers, i;
	local KFGameEngine KFEngine;

	super.UpdateGameSettings();

	if (WorldInfo.NetMode == NM_DedicatedServer || WorldInfo.NetMode == NM_ListenServer)
	{
		//`REMOVEMESOON_ServerTakeoverLog("KFGameInfo_Survival.UpdateGameSettings 1 - GameInterface: "$GameInterface);
		if (GameInterface != None)
		{
			KFEngine = KFGameEngine(class'Engine'.static.GetEngine());

			SessionName = PlayerReplicationInfoClass.default.SessionName;

			if( PlayfabInter != none && PlayfabInter.GetGameSettings() != none )
			{
				KFGameSettings = KFOnlineGameSettings(PlayfabInter.GetGameSettings());
				KFGameSettings.bAvailableForTakeover = KFEngine.bAvailableForTakeover;
			}
			else
			{
				KFGameSettings = KFOnlineGameSettings(GameInterface.GetGameSettings(SessionName));
			}
			//Ensure bug-for-bug compatibility with KF1

			//`REMOVEMESOON_ServerTakeoverLog("KFGameInfo_Survival.UpdateGameSettings 2 - KFGameSettings: "$KFGameSettings);

			if (KFGameSettings != None)
			{
				//`REMOVEMESOON_ServerTakeoverLog("KFGameInfo_Survival.UpdateGameSettings 3 - KFGameSettings.bAvailableForTakeover: "$KFGameSettings.bAvailableForTakeover);

				KFGameSettings.Mode = GetGameModeNum();
				KFGameSettings.Difficulty = GameDifficulty;
				//Ensure bug-for-bug compatibility with KF1
				if (WaveNum == 0)
				{
					KFGameSettings.bInProgress = false;
					KFGameSettings.CurrentWave = 1;
				}
				else
				{
					KFGameSettings.bInProgress = true;
					KFGameSettings.CurrentWave = WaveNum;
				}
				//Also from KF1
				if(MyKFGRI != none)
				{
					KFGameSettings.NumWaves = MyKFGRI.GetFinalWaveNum();
				}
				else
				{
					KFGameSettings.NumWaves = WaveMax - 1;
				}
				KFGameSettings.OwningPlayerName = class'GameReplicationInfo'.default.ServerName;

				KFGameSettings.NumPublicConnections = MaxPlayersAllowed;
				KFGameSettings.bRequiresPassword = RequiresPassword();
				KFGameSettings.bCustom = bIsCustomGame;
				KFGameSettings.bUsesStats = !IsUnrankedGame();
				KFGameSettings.NumSpectators = NumSpectators;
				if(MyKFGRI != none)
				{
					MyKFGRI.bCustom = bIsCustomGame;
				}

				// Set the map name
				//@SABER_EGS IsEOSDedicatedServer() case added
				if( WorldInfo.IsConsoleDedicatedServer() || WorldInfo.IsEOSDedicatedServer() )
				{
					KFGameSettings.MapName = WorldInfo.GetMapName(true);
					if( GameReplicationInfo != none )
					{
						for( i = 0; i < GameReplicationInfo.PRIArray.Length; i++ )
						{
							if (!GameReplicationInfo.PRIArray[i].bBot && !GameReplicationInfo.PRIArray[i].bOnlySpectator && PlayerController(GameReplicationInfo.PRIArray[i].Owner) != none)
							{
								NumHumanPlayers++;
							}
						}
					}

					KFGameSettings.NumOpenPublicConnections = KFGameSettings.NumPublicConnections - NumHumanPlayers;
				}

				//`REMOVEMESOON_ServerTakeoverLog("KFGameInfo_Survival.UpdateGameSettings 4 - PlayfabInter: "$PlayfabInter);
				if (PlayfabInter != none)
				{
					//`REMOVEMESOON_ServerTakeoverLog("KFGameInfo_Survival.UpdateGameSettings 4.1 - IsRegisteredWithPlayfab: "$PlayfabInter.IsRegisteredWithPlayfab());
				}

				if( PlayfabInter != none && PlayfabInter.IsRegisteredWithPlayfab() )
				{
					PlayfabInter.ServerUpdateOnlineGame();
					//@SABER_EGS_BEGIN Crossplay support
					if (WorldInfo.IsEOSDedicatedServer()) {
						GameInterface.UpdateOnlineGame(SessionName, KFGameSettings, true);
					}
					//@SABER_EGS_END
				}
				else
				{
					//Trigger re-broadcast of game settings
					GameInterface.UpdateOnlineGame(SessionName, KFGameSettings, true);
				}
			}
		}
	}
}

function OnServerTitleDataRead()
{
	super.OnServerTitleDataRead();
	class'KFGameEngine'.static.RefreshEventContent();
	//set boss index again here - this fixes the case of seasonal events like christmas setting krampus the only boss
	//to spawn on krampuses lair
	SetBossIndex();
}

/**
 * Return whether Viewer is allowed to spectate from ViewTarget's PoV.
 *   Used to prevent players from spectating zeds when the DummyPRI is active.
 *
 */
function bool CanSpectate( PlayerController Viewer, PlayerReplicationInfo ViewTarget )
{
    // Normal PRI's should be replicatable, DummyPRI is not, indicating a zed
    return ( super.CanSpectate(Viewer, ViewTarget)
    		&& (Viewer.PlayerReplicationInfo.bOnlySpectator || Viewer.GetTeamNum() == ViewTarget.GetTeamNum() || MyKFGRI.bTraderIsOpen) );
}


/************************************************************************************
 * Timers
 ***********************************************************************************/

/** Default timer, called from native */
event Timer()
{
	super.Timer();

	if( SpawnManager != none )
	{
		SpawnManager.Update();
	}

	if( GameConductor != none )
	{
		GameConductor.TimerUpdate();
	}
}

/**
 * @brief Checks if we are playing coop online with other people
 *
 * @return true if hosting and more than 1 player
 */
function byte IsMultiplayerGame()
{
	return (WorldInfo.NetMode != NM_Standalone && GetNumPlayers()  > 1) ? 1 : 0;
}

function UpdateWaveEndDialogInfo()
{
	local int PlayersAlive, PlayersTotal, MostZedsKilled, MostDoshEarned, BestTeammateScore;
	local KFPlayerController KFPC, KilledMostZeds, EarnedMostDosh, BestTeammate;

	foreach WorldInfo.AllControllers(class'KFPlayerController', KFPC)
	{
		if( KFPC.bDemoOwner )
		{
			// don't count demorecspectator
			continue;
		}

		PlayersTotal++;

		if( KFPC.Pawn != none && KFPC.Pawn.IsAliveAndWell() )
		{
    	 	PlayersAlive++;
		}

		if( KFPC.MatchStats.ZedsKilledLastWave > MostZedsKilled )
		{
			KilledMostZeds = KFPC;
			MostZedsKilled = KFPC.MatchStats.ZedsKilledLastWave;
		}

		if( KFPC.MatchStats.GetDoshEarnedInWave() > MostDoshEarned )
		{
			EarnedMostDosh = KFPC;
			MostDoshEarned = KFPC.MatchStats.GetDoshEarnedInWave();
		}

		if( KFPC.MatchStats.ZedsKilledLastWave + KFPC.MatchStats.GetDoshEarnedInWave() > BestTeammateScore )
		{
			BestTeammate = KFPC;
			BestTeammateScore = KFPC.MatchStats.ZedsKilledLastWave + KFPC.MatchStats.GetDoshEarnedInWave();
		}
	}

	if( PlayersTotal > 1 )
	{
		foreach WorldInfo.AllControllers(class'KFPlayerController', KFPC)
		{
			if( KFPC.Pawn != none && KFPC.Pawn.IsAliveAndWell() )
			{
				if( !bHumanDeathsLastWave )
				{
					// no teammates died
					KFPC.PWRI.bAllSurvivedLastWave = true;
				}
				else if( PlayersAlive == 1 )
				{
					// only survivor
					KFPC.PWRI.bOneSurvivedLastWave = true;
				}
				else
				{
					// more than one teammate died
					KFPC.PWRI.bSomeSurvivedLastWave = true;
				}
			}
		}
	}

	if( KilledMostZeds != none )
	{
		KilledMostZeds.PWRI.bKilledMostZeds = true;
	}

	if( EarnedMostDosh != none )
	{
		EarnedMostDosh.PWRI.bEarnedMostDosh = true;
	}

	if( BestTeammate != none )
	{
		BestTeammate.PWRI.bBestTeammate = true;
	}

    bHumanDeathsLastWave = false;
}

/************************************************************************************
 * Do$h
 ***********************************************************************************/

/* Add up the team's earned money and give it to the surviving players */
function RewardSurvivingPlayers()
{
	local int PlayerCut;
	local int PlayerCount;
	local KFPlayerController KFPC;
	Local KFTeamInfo_Human T;

	foreach WorldInfo.AllControllers(class'KFPlayerController', KFPC)
	{
		if( KFPC.Pawn != none && KFPC.Pawn.IsAliveAndWell() )
		{
    	 	PlayerCount++;

    	 	// Find the player's team
            if( T == none && KFPC.PlayerReplicationInfo != none && KFPC.PlayerReplicationInfo.Team != none )
    	 	{
                T = KFTeamInfo_Human(KFPC.PlayerReplicationInfo.Team);
            }
		}
	}

    // No dosh to distribute if there is no team or score
    if( T == none || T.Score <= 0 )
    {
        return;
    }

 	PlayerCut = Round(T.Score / PlayerCount);

   `log("SCORING: Team dosh earned this round:" @ T.Score, bLogScoring);
   `log("SCORING: Number of surviving players:" @ PlayerCount, bLogScoring);
   `log("SCORING: Dosh/survivng player:" @ PlayerCut, bLogScoring);

	foreach WorldInfo.AllControllers(class'KFPlayerController', KFPC)
	{
		if( KFPC.Pawn != none && KFPC.Pawn.IsAliveAndWell() )
		{
			KFPlayerReplicationInfo(KFPC.PlayerReplicationInfo).AddDosh(PlayerCut, true);
			T.AddScore( -PlayerCut );

			`log("Player" @ KFPC.PlayerReplicationInfo.PlayerName @ "got" @ PlayerCut @ "for surviving the wave", bLogScoring);
		}
	}

	// Reset team score afte the wave ends
	T.AddScore( 0, true );
}

function int CalculateMinimumRespawnDosh(float UsedMaxRespawnDosh)
{
	return Round(UsedMaxRespawnDosh * (float(WaveNum) / float(MyKFGRI.GetFinalWaveNum())));
}

/**
 * @brief Calculates the dosh penalty or minimum dosh spawning amount
 *
 * @param KilledPlayerPRI The killed player's PRI
 * @param bLateJoiner If true, give late joiners money without penalty
 * @return Rounded amount of dosh
 */
function int GetAdjustedDeathPenalty( KFPlayerReplicationInfo KilledPlayerPRI, optional bool bLateJoiner=false )
{
	local float MinimumRespawnDosh, PlayerRespawnDosh;
	local float UsedMaxRespawnDosh;

	//pointless to give respawn money in the last wave
	if( WaveNum >= WaveMax )
	{
		return 0;
	}

	if( GameDifficulty < MaxRespawnDosh.Length )
	{
	   UsedMaxRespawnDosh = MaxRespawnDosh[GameDifficulty];
	}
	else
	{
	   UsedMaxRespawnDosh = MaxRespawnDosh[MaxRespawnDosh.Length - 1];
	}

	MinimumRespawnDosh = CalculateMinimumRespawnDosh(UsedMaxRespawnDosh);

	if( bLateJoiner )
	{
		return CalculateLateJoinerStartingDosh(MinimumRespawnDosh);
	}

	`log( "SCORING: Player" @ KilledPlayerPRI.PlayerName @ "predicted minimum respawn dosh:" @ MinimumRespawnDosh, bLogScoring );
	PlayerRespawnDosh = KilledPlayerPRI.Score - (KilledPlayerPRI.Score * DeathPenaltyModifiers[GameDifficulty]);
	`log( "SCORING: Player" @ KilledPlayerPRI.PlayerName @ "current respawn dosh:" @ PlayerRespawnDosh, bLogScoring );

	if( MinimumRespawnDosh > PlayerRespawnDosh )
	{
		`log( "SCORING: Player" @ KilledPlayerPRI.PlayerName @ "MinimumRespawnDosh > PlayerRespawnDosh, returning MinimumRespawnDosh - KilledPlayerPRI.Score =" @ MinimumRespawnDosh - KilledPlayerPRI.Score, bLogScoring );
		return MinimumRespawnDosh - KilledPlayerPRI.Score;
	}

	`log( "SCORING: Player" @ KilledPlayerPRI.PlayerName @ "PlayerRespawnDosh > MinimumRespawnDosh, returning KilledPlayerPRI.Score * DeathPenaltyModifiers[GameDifficulty] =" @ -Round( KilledPlayerPRI.Score * DeathPenaltyModifiers[GameDifficulty] ), bLogScoring );
	return -Round( KilledPlayerPRI.Score * DeathPenaltyModifiers[GameDifficulty] );
}

function int CalculateLateJoinerStartingDosh(int MinimumRespawnDosh)
{
	if (default.LateArrivalStarts.Length > 0 && GameLength >= 0 && GameLength < default.LateArrivalStarts.Length)
	{
		if (default.LateArrivalStarts[GameLength].StartingDosh.Length > 0 && WaveNum - 1 >= 0 && WaveNum - 1 < default.LateArrivalStarts[GameLength].StartingDosh.Length)
		{
			`log("SCORING: Late joiner received" @ LateArrivalStarts[GameLength].StartingDosh[WaveNum - 1]);
			return default.LateArrivalStarts[GameLength].StartingDosh[WaveNum - 1];
		}
	}

	`log("SCORING: Late joiner - invalid parameters to properly award late joiner dosh. Will instead receive Minimum Respawn Dosh of" @ MinimumRespawnDosh, bLogScoring);
	return MinimumRespawnDosh;
}

/************************************************************************************
 * Wave Mode Cheats
 ***********************************************************************************/
function bool AllowWaveCheats()
{
`if(`notdefined(ShippingPC))
	return true;
`else
	return class'KFGameEngine'.static.IsEditor();
`endif
}

function FindCollectibles()
{
	`if(`notdefined(ShippingPC))
	local KFPlayerController KFPC;
	local KFCollectibleActor Collectible;
	local Vector EmptyVector;

	foreach WorldInfo.AllControllers(class'KFPlayerController', KFPC)
	{
		if (KFPC.IsLocalPlayerController())
		{
			foreach WorldInfo.AllActors(class'KFCollectibleActor', Collectible)
			{
				Collectible.TakeDamage(100, KFPC, EmptyVector, EmptyVector, class'KFDT_Fire_Mac10');
			}
		}
	}
	`endif
}

exec function ToggleSpawning( optional string ZedTypeString )
{
	if( AllowWaveCheats() && GameReplicationInfo.bMatchHasBegun )
	{
		if( ZedTypeString != "" )
		{
             //OverrideZedSpawnList( ZedTypeString );
		}

		if( GetStateName() == 'DebugSuspendWave' )
		{
			GotoState('PlayingWave');
		}
		else
		{
			GotoState('DebugSuspendWave');
		}
	}
}

exec function EndCurrentWave ( )
{
	if( AllowWaveCheats() )
	{
		DebugKillZeds();
		WaveEnded(WEC_WaveWon);
	}
}

exec function SetWave( byte NewWaveNum )
{
	if( AllowWaveCheats() )
	{
		if( NewWaveNum <= WaveMax )
		{
			WaveNum = NewWaveNum - 1;

			// stop, then restart
			GotoState('DebugSuspendWave');
			GotoState('PlayingWave');

			ResetAllPickups();
		}
		else
		{
			`log("SetWave: new wave num must be <= "$WaveMax);
		}
	}
}

exec function WinMatch()
{
	if( AllowWaveCheats() )
	{
		WaveNum = SpawnManager.WaveSettings.Waves.Length;
		WaveEnded(WEC_WaveWon);
	}
}

/*********************************************************************************************
 * state PlayingWave
 *********************************************************************************************/

/** Returns true if wave gameplay is active */
function bool IsWaveActive();

State PlayingWave
{
	function BeginState( Name PreviousStateName )
	{
		MyKFGRI.SetWaveActive(TRUE, GetGameIntensityForMusic());
		MyKFGRI.VoteCollector.ResetSkipTraderVote();

		StartWave();
		if ( AllowBalanceLogging() )
		{
			LogPlayersDosh(GBE_WaveStart);
		}
	}

	function bool IsWaveActive()
	{
		return true;
	}
}

/** Starts a new Wave */
function StartWave()
{
	local int WaveBuffer;
	local KFPlayerController KFPC;

	//closes trader on server
	if (MyKFGRI.OpenedTrader != none)
	{
		MyKFGRI.CloseTrader();
		NotifyTraderClosed();
	}

	WaveBuffer = 0;
	WaveNum++;
	MyKFGRI.WaveNum = WaveNum;

	if (MyKFGRI.IsContaminationMode())
	{
		if (WaveNum == 1) // Only on first wave..
		{
			MyKFGRI.ChooseNextObjective(WaveNum);
		}

		MyKFGRI.ClearPreviousObjective();
		
		if (WaveNum != WaveMax)
		{
			if (MyKFGRI.StartNextObjective())
			{
				WaveBuffer = ObjectiveSpawnDelay;
			}
		}
	}
	else
	{
		if (IsMapObjectiveEnabled())
		{
			MyKFGRI.ClearPreviousObjective();

			if (MyKFGRI.StartNextObjective())
			{
				WaveBuffer = ObjectiveSpawnDelay;
			}
		}
	}

    SetupNextWave(WaveBuffer);

	NumAIFinishedSpawning = 0;
	NumAISpawnsQueued = 0;
	AIAliveCount = 0;
	MyKFGRI.bForceNextObjective = false;

	if( WorldInfo.NetMode != NM_DedicatedServer && Role == ROLE_Authority )
	{
		MyKFGRI.UpdateHUDWaveCount();
	}

	WaveStarted();
	MyKFGRI.NotifyWaveStart();

	MyKFGRI.AIRemaining = SpawnManager.WaveTotalAI;
	MyKFGRI.WaveTotalAICount = SpawnManager.WaveTotalAI;

	BroadcastLocalizedMessage(class'KFLocalMessage_Priority', GetWaveStartMessage());

    SetupNextTrader();

	ResetAllPickups();

	`DialogManager.SetTraderTime( false );

	// first spawn and music are delayed 5 seconds (KFAISpawnManager.TimeUntilNextSpawn == 5 initially), so line up dialog with them;
	// fixes problem of clients not being ready to receive dialog at the instant the match starts;
	SetTimer( 5.f, false, nameof(PlayWaveStartDialog) );


	//Reset Supplier perks here
	ForEach WorldInfo.AllControllers(class'KFPlayerController', KFPC)
	{
		if (KFPC.GetPerk() != none)
		{
			KFPC.GetPerk().OnWaveStart();
		}
	}
}

function SetupNextWave(int WaveBuffer)
{
	SpawnManager.SetupNextWave(WaveNum-1, WaveBuffer);
}

function byte GetWaveStartMessage()
{
	if (MyKFGRI.IsBossWave())
	{
		return GMT_WaveSBoss;
	}

	return GMT_WaveStart;
}

/** Called to reset all the types of pickups */
function ResetAllPickups()
{
 	// for the boss wave request all ammo pickups
 	if (MyKFGRI.IsBossWave())
 	{
 		// -1, so that we always have a different pickup to activate
 		NumAmmoPickups = Max(AmmoPickups.Length - 1, 0);
 	}

 	Super.ResetAllPickups();
}

/** Overridden to scale the number of active pickups by wave */
function ResetPickups( array<KFPickupFactory> PickupList, int NumPickups )
{
	NumPickups *= (float(WaveNum) / float(WaveMax));
	
	// make sure to have at least 1 ammo pickup in the level, and if it's wave 2 or later make sure there's
	// at least one weapon pickup. Also, we need to ensure if OverrideItemPickupModifier is set to 0 we really
	// don't want any item pickups.
	if( NumPickups == 0 && PickupList.Length > 0
		&& (WaveNum > 1 
			|| KFPickupFactory_Ammo(PickupList[0]) != none
			|| (KFPickupFactory_Item(PickupList[0]) != none && (OutbreakEvent == none || OutbreakEvent.ActiveEvent.OverrideItemPickupModifier != 0))
			)
	)
	{
		NumPickups = 1;
	}
	super.ResetPickups( PickupList, NumPickups );
}

/** Sets NextTrader and re-inits trader list if necessary */
function SetupNextTrader()
{
	local byte NextTraderIndex;

	// Try to set the scripted trader first
	if( ScriptedTrader != none )
	{
		MyKFGRI.NextTrader = ScriptedTrader;
		return;
	}

	if( TraderList.Length > 0 )
	{
		NextTraderIndex = DetermineNextTraderIndex();
		if( NextTraderIndex >= 0 && NextTraderIndex < TraderList.Length )
		{
			MyKFGRI.NextTrader = TraderList[ NextTraderIndex ];
			TraderList.Remove( NextTraderIndex, 1 );
		}
	}

	if( TraderList.Length <= 0 )
	{
	 	InitTraderList();
	}
}

/** Picks next trader index and allows for mutator hook */
function byte DetermineNextTraderIndex()
{
	local byte NextTraderIndex;

	NextTraderIndex = Rand( TraderList.Length );

`if(`__TW_SDK_)
	if( BaseMutator != none )
	{
		BaseMutator.ModifyNextTraderIndex( NextTraderIndex );
	}
`endif

	return NextTraderIndex;
}

function WaveStarted()
{
	local array<SequenceObject> AllWaveStartEvents, AllWaveProgressEvents;
	local array<int> OutputLinksToActivate;
	local KFSeqEvent_WaveStart WaveStartEvt;
	local KFSeqEvent_WaveProgress WaveProgressEvt;
	local Sequence GameSeq;
	local int i;
	local KFPlayerController KFPC;

	`AnalyticsLog(("wave_start",
				   None,
				   "#"$WaveNum,
				   "#"$GetLivingPlayerCount()));

    GameConductor.ResetWaveStats();

	ForEach WorldInfo.AllControllers(class'KFPlayerController', KFPC)
	{
		if( !KFPC.bDemoOwner )
		{
			`AnalyticsLog(("pc_wave_start",
						   KFPC.PlayerReplicationInfo,
						   "#"$WaveNum,
						   KFPC.GetPerk().Class.Name,
						   KFPC.GetPerk().GetLevel(),
						   "#"$KFPC.PlayerReplicationInfo.Score,
						   KFPC.Pawn != none ? KFInventoryManager(KFPC.Pawn.InvManager).DumpInventory() : "",
						   KFPC.GetPerk().DumpPerkLoadout(),
						   KFPC.PlayerReplicationInfo.GetTeamNum()
						  ));
		}

		`QALog("Player Name:" @ KFPC.PlayerReplicationInfo.PlayerName @ "Dosh" @ KFPC.PlayerReplicationInfo.Score, bLogScoring);
	}


	// Get the gameplay sequence.
	GameSeq = WorldInfo.GetGameSequence();

	if( GameSeq != none )
	{
		GameSeq.FindSeqObjectsByClass(class'KFSeqEvent_WaveStart', TRUE, AllWaveStartEvents);

		for( i = 0; i < AllWaveStartEvents.Length; i++ )
		{
			WaveStartEvt = KFSeqEvent_WaveStart(AllWaveStartEvents[i]);

			if( WaveStartEvt != None  )
			{
				WaveStartEvt.Reset();
				WaveStartEvt.SetWaveNum( WaveNum, WaveMax );
				if( MyKFGRI.IsBossWave() && WaveStartEvt.OutputLinks.Length > 1 )
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

		GameSeq.FindSeqObjectsByClass(class'KFSeqEvent_WaveProgress', TRUE, AllWaveProgressEvents);

		for( i = 0; i < AllWaveProgressEvents.Length; i++ )
		{
			WaveProgressEvt = KFSeqEvent_WaveProgress(AllWaveProgressEvents[i]);

			if( WaveProgressEvt != None  )
			{
				WaveProgressEvt.Reset();
			}
		}
	}

	//So the server browser can have our new wave information
	UpdateGameSettings();

	bWaveStarted = true;
}

/** Do something when there are no AIs left */
function CheckWaveEnd( optional bool bForceWaveEnd = false )
{
	if (WorldInfo.NetMode == NM_DedicatedServer)
	{
		//`REMOVEMESOON_ZombieServerLog("KFGameInfo_Survival.CheckWaveEnd - bForceWaveEnd: "$bForceWaveEnd$"; bMatchHasBegun: "$MyKFGRI.bMatchHasBegun$"; GetLivingPlayerCount(): "$GetLivingPlayerCount()$"; AIAliveCount: "$AIAliveCount$"; IsWaveActive(): "$IsWaveActive()$"; IsFinishedSpawning(): "$SpawnManager.IsFinishedSpawning());
	}

    if( !MyKFGRI.bMatchHasBegun )
    {
		`log("KFGameInfo - CheckWaveEnd - Cannot check if wave has ended since match has not begun. ");
    	return;
    }

    `log("KFGameInfo.CheckWaveEnd() AIAliveCount:" @ AIAliveCount, SpawnManager.bLogAISpawning);

    if( GetLivingPlayerCount() <= 0 )
	{
//		`log("KFGameInfo.CheckWaveEnd() - Call Wave Ended - WEC_TeamWipedOut");
		WaveEnded(WEC_TeamWipedOut);
	}
	else if( (AIAliveCount <= 0 && IsWaveActive() && SpawnManager.IsFinishedSpawning()) || bForceWaveEnd )
	{
		//`log("KFGameInfo.CheckWaveEnd() - Call Wave Ended - WEC_WaveWon");
		WaveEnded(WEC_WaveWon);
	}
}

/** The wave ended */
function WaveEnded(EWaveEndCondition WinCondition)
{
	local array<SequenceObject> AllWaveEndEvents;
	local array<int> OutputLinksToActivate;
	local KFSeqEvent_WaveEnd WaveEndEvt;
	local Sequence GameSeq;
	local int i;
	local KFPlayerController KFPC;

	if(!bWaveStarted && !MyKFGRI.bTraderIsOpen && WinCondition != WEC_TeamWipedOut)
	{
		return;
	}

	ClearAllActorsFromBonfire();

	if (WorldInfo.NetMode == NM_DedicatedServer)
	{
		scripttrace();
		//`REMOVEMESOON_ZombieServerLog("KFGameInfo_Survival.WaveEnded - WinCondition: "$WinCondition$"; WaveNum: "$WaveNum$"; WaveMax: "$WaveMax);
	}

	// Get the gameplay sequence.
	GameSeq = WorldInfo.GetGameSequence();

	if( GameSeq != none )
	{
		GameSeq.FindSeqObjectsByClass( class'KFSeqEvent_WaveEnd', TRUE, AllWaveEndEvents );
		for( i = 0; i < AllWaveEndEvents.Length; ++i )
		{
			WaveEndEvt = KFSeqEvent_WaveEnd( AllWaveEndEvents[i] );

			if( WaveEndEvt != None  )
			{
				WaveEndEvt.Reset();
				WaveEndEvt.SetWaveNum( WaveNum, WaveMax );
				if( MyKFGRI.IsBossWave() && WaveEndEvt.OutputLinks.Length > 1 )
				{
					OutputLinksToActivate.AddItem( 1 );
				}
				else
				{
					OutputLinksToActivate.AddItem( 0 );
				}
				WaveEndEvt.CheckActivate( self, self,, OutputLinksToActivate );
			}
		}
	}
	BroadcastLocalizedMessage(class'KFLocalMessage_Priority', GMT_WaveEnd);
    MyKFGRI.DeactivateObjective();
	MyKFGRI.NotifyWaveEnded();
	`DialogManager.SetTraderTime( !MyKFGRI.IsBossWave() );

    `AnalyticsLog(("wave_end", None, "#"$WaveNum, GetEnum(enum'EWaveEndCondition',WinCondition), "#"$GameConductor.CurrentWaveZedVisibleAverageLifeSpan));

	// IsPlayInEditor check was added to fix a scaleform crash that would call an actionscript function
	// as scaleform was being destroyed. This issue only occurs when playing in the editor
	if( WinCondition == WEC_TeamWipedOut && !class'WorldInfo'.static.IsPlayInEditor())
	{
		EndOfMatch(false);
	}
	else if( WinCondition == WEC_WaveWon )
	{
		RewardSurvivingPlayers();
		UpdateWaveEndDialogInfo();

		foreach WorldInfo.AllControllers(class'KFPlayerController', KFPC)
		{
			if (KFPC != none)
			{
				KFPC.OnWaveComplete(WaveNum);
			}
		}

		if (OutbreakEvent != none)
		{
			OnOutbreakWaveWon();
		}

		if (WaveNum < WaveMax)
		{
			GotoState( 'TraderOpen', 'Begin' );
		}
		else
		{
			EndOfMatch(true);
		}
	}

	// To allow any statistics that are recorded on the very last zed killed at the end of the wave,
	// wait a single frame to allow them to finalize.
	SetTimer( WorldInfo.DeltaSeconds, false, nameOf(Timer_FinalizeEndOfWaveStats) );
	bWaveStarted=false;
}

/** All stats should be finalized here */
function Timer_FinalizeEndOfWaveStats()
{
	local bool bOpeningTrader;
	local KFPlayerController KFPC;

	bOpeningTrader = MyKFGRI.bTraderIsOpen && !IsInState( 'MatchEnded' ) && !IsInState( 'RoundEnded ');
	foreach WorldInfo.AllControllers( class'KFPlayerController', KFPC )
	{
		// submit online player analytics
		LogWaveEndAnalyticsFor( KFPC );

		// submit aar/dialog stats
		KFPC.SubmitPostWaveStats( bOpeningTrader );

		`QALog( "Player Name:" @ KFPC.PlayerReplicationInfo.PlayerName @ "Dosh" @ KFPC.PlayerReplicationInfo.Score, bLogScoring );
	}
}

/** Game Analytics */
function LogWaveEndAnalyticsFor(KFPlayerController KFPC)
{
	local int i;
	local array<WeaponDamage> Weapons;

	if( KFPC.bDemoOwner )
	{
		return;
	}

	`AnalyticsLog(("pc_wave_stats",
				   KFPC.PlayerReplicationInfo,
				   "#"$WaveNum,
				   "#"$KFPC.MatchStats.GetHealGivenInWave(),
				   "#"$KFPC.MatchStats.GetHeadShotsInWave(),
				   "#"$KFPC.MatchStats.GetDoshEarnedInWave(),
				   "#"$KFPC.MatchStats.GetDamageTakenInWave(),
				   "#"$KFPC.MatchStats.GetDamageDealtInWave(),
				   "#"$KFPC.ShotsFired,
				   "#"$KFPC.ShotsHit,
				   "#"$KFPC.ShotsHitHeadshot ));

	`AnalyticsLog(("pc_wave_end",
				   KFPC.PlayerReplicationInfo,
				   "#"$WaveNum,
				   KFPC.GetPerk().Class.Name,
				   "#"$KFPC.GetPerk().GetLevel(),
				   "#"$KFPC.PlayerReplicationInfo.Score,
				   "#"$KFPC.PlayerReplicationInfo.Kills,
				   (KFPC.Pawn != none && KFPC.Pawn.InvManager != none) ? KFInventoryManager(KFPC.Pawn.InvManager).DumpInventory() : ""));

	KFPC.MatchStats.GetTopWeapons( 3, Weapons );

	for ( i = 0; i < Weapons.Length; ++i )
	{
		`AnalyticsLog(("pc_weapon_stats",
					   KFPC.PlayerReplicationInfo,
					   "#"$WaveNum,
					   Weapons[i].WeaponDef.Name,
					   "#"$Weapons[i].DamageAmount,
					   "#"$Weapons[i].HeadShots, // really head kills
					   "#"$Weapons[i].LargeZedKills ));
	}
}

/** Allow specific map to override the spawn class.  Default implementation returns from the AI class list. */
function class<KFPawn_Monster> GetAISpawnType(EAIType AIType)
{
	local KFMapInfo KFMI;
	local KFGameReplicationInfo KFGRI;
	local array<SpawnReplacement> SpawnReplacements;
	local int i;

	KFMI = KFMapInfo(WorldInfo.GetMapInfo());
	if (KFMI != none)
	{
		KFGRI = KFGameReplicationInfo(WorldInfo.GRI);
		if (KFMI.bUsePresetObjectives &&
			((!KFMI.WaveHasPresetObjectives(WaveNum, GameLength)) ||
			 (KFGRI != none && KFGRI.ObjectiveInterface != none && KFGRI.ObjectiveInterface.CanActivateObjective())))
		{
			switch (GameLength)
			{
			case GL_Short:
				SpawnReplacements = KFMI.PresetWaveObjectives.ShortObjectives[WaveNum-1].SpawnReplacements;
				break;

			case GL_Normal:
				SpawnReplacements = KFMI.PresetWaveObjectives.MediumObjectives[WaveNum-1].SpawnReplacements;
				break;

			case GL_Long:
				SpawnReplacements = KFMI.PresetWaveObjectives.LongObjectives[WaveNum-1].SpawnReplacements;
				break;
			};

			if (SpawnReplacements.Length > 0)
			{
				for (i = 0; i < SpawnReplacements.Length; ++i)
				{
					if (SpawnReplacements[i].SpawnEntry == AIType && FRand() < SpawnReplacements[i].PercentChance)
					{
						if (SpawnReplacements[i].NewClass.Length > 0)
						{
							return SpawnReplacements[i].NewClass[Rand(SpawnReplacements[i].NewClass.Length)];
						}
					}
				}
			}
		}
	}

    return AIClassList[AIType];
}

/** Scale to use against WaveTotalAI to determine full wave size */
function float GetTotalWaveCountScale()
{
	local float WaveScale;
	local KFMapInfo KFMI;
	local KFGameReplicationInfo KFGRI;

	WaveScale = super.GetTotalWaveCountScale();
	KFMI = KFMapInfo(WorldInfo.GetMapInfo());
	if (KFMI != none)
	{
		KFGRI = KFGameReplicationInfo(WorldInfo.GRI);
		if (KFMI.bUsePresetObjectives &&
			((!KFMI.WaveHasPresetObjectives(WaveNum, GameLength)) ||
			 (KFGRI != none && KFGRI.ObjectiveInterface != none && KFGRI.ObjectiveInterface.CanActivateObjective())))
		{
			switch (GameLength)
			{
			case GL_Short:
				WaveScale *= KFMI.PresetWaveObjectives.ShortObjectives[WaveNum-1].WaveScale;
				break;

			case GL_Normal:
				WaveScale *= KFMI.PresetWaveObjectives.MediumObjectives[WaveNum-1].WaveScale;
				break;

			case GL_Long:
				WaveScale *= KFMI.PresetWaveObjectives.LongObjectives[WaveNum-1].WaveScale;
				break;
			};
		}
	}

	return WaveScale;
}

/** Allow specific game types to modify the spawn rate at a global level */
function float GetGameInfoSpawnRateMod()
{
	local float SpawnRateMod;
	local KFGameReplicationInfo KFGRI;
	local KFMapInfo KFMI;
	local int NumPlayersAlive;

	SpawnRateMod = super.GetGameInfoSpawnRateMod();

	KFGRI = KFGameReplicationInfo(WorldInfo.GRI);
	if (KFGRI == none)
	{
		return SpawnRateMod;
	}

	KFMI = KFMapInfo(WorldInfo.GetMapInfo());
	if (KFMI == none)
	{
		return SpawnRateMod;
	}

	if (KFMI.bUsePresetObjectives &&
		((!KFMI.WaveHasPresetObjectives(WaveNum, GameLength)) ||
		(KFGRI != none && KFGRI.ObjectiveInterface != none && KFGRI.ObjectiveInterface.CanActivateObjective())))
	{
		switch (GameLength)
		{
		case GL_Short:
			NumPlayersAlive = Clamp(KFGRI.GetNumPlayersAlive(), 1, KFMI.PresetWaveObjectives.ShortObjectives[WaveNum-1].PerPlayerSpawnRateMod.Length) - 1;
			SpawnRateMod *= KFMI.PresetWaveObjectives.ShortObjectives[WaveNum-1].PerPlayerSpawnRateMod[NumPlayersAlive];
			break;

		case GL_Normal:
			NumPlayersAlive = Clamp(KFGRI.GetNumPlayersAlive(), 1, KFMI.PresetWaveObjectives.MediumObjectives[WaveNum-1].PerPlayerSpawnRateMod.Length) - 1;
			SpawnRateMod *= KFMI.PresetWaveObjectives.MediumObjectives[WaveNum-1].PerPlayerSpawnRateMod[NumPlayersAlive];
			break;

		case GL_Long:
			NumPlayersAlive = Clamp(KFGRI.GetNumPlayersAlive(), 1, KFMI.PresetWaveObjectives.LongObjectives[WaveNum-1].PerPlayerSpawnRateMod.Length) - 1;
			SpawnRateMod *= KFMI.PresetWaveObjectives.LongObjectives[WaveNum-1].PerPlayerSpawnRateMod[NumPlayersAlive];
			break;
		};
	}

	return SpawnRateMod;
}

/*********************************************************************************************
 * state TraderOpen
 *********************************************************************************************/

/** Called when TimeBetweenWaves expires */
function CloseTraderTimer();

function SkipTrader(int TimeAfterSkipTrader)
{
	SetTimer(TimeAfterSkipTrader, false, nameof(CloseTraderTimer));
}

/** Cleans up anything from the previous wave that needs to be removed for trader time */
function DoTraderTimeCleanup();

/** Handle functionality for opening trader */
function OpenTrader()
{
	local int UpdatedTimeBetweenWaves;

    UpdatedTimeBetweenWaves = TimeBetweenWaves;

	// In castle volter the trader needs to have a special time
	if (WorldInfo.GetMapName(true) == "KF-CastleVolter" && WaveNum == (WaveMax - 1) )
	{
		UpdatedTimeBetweenWaves = UpdatedTimeBetweenWaves * CastleVolterTraderModifier;
	}

    MyKFGRI.OpenTrader(UpdatedTimeBetweenWaves);
	NotifyTraderOpened();
}

State TraderOpen
{
	function BeginState( Name PreviousStateName )
	{
		local KFPlayerController KFPC;

		MyKFGRI.SetWaveActive(FALSE, GetGameIntensityForMusic());

		ForEach WorldInfo.AllControllers(class'KFPlayerController', KFPC)
		{
			if( KFPC.GetPerk() != none )
			{
				KFPC.GetPerk().OnWaveEnded();
			}
			KFPC.ApplyPendingPerks();
		}

		// Restart players
		StartHumans();

		OpenTrader();

		if ( AllowBalanceLogging() )
		{
			LogPlayersDosh(GBE_TraderOpen);
		}

		SetTimer(TimeBetweenWaves, false, nameof(CloseTraderTimer));
	}

	/** Cleans up anything from the previous wave that needs to be removed for trader time */
	function DoTraderTimeCleanup()
	{
		local KFProj_BloatPukeMine PukeMine;

	    // Destroy all lingering explosions
	    MyKFGRI.FadeOutLingeringExplosions();

		// Destroy all puke mine projectiles
	    foreach DynamicActors( class'KFProj_BloatPukeMine', PukeMine )
	    {
	        PukeMine.FadeOut();
	    }
	}

	/** Called when TimeBetweenWaves expires */
	function CloseTraderTimer()
	{
		GotoState('PlayingWave');
	}

	function EndState( Name NextStateName )
	{
		if ( AllowBalanceLogging() )
		{
			LogPlayersInventory();
		}
	}

	/** Special handling for survival/wave mode.  Reduces health to 1 */
	function bool PreventDeath(Pawn KilledPawn, Controller Killer, class<DamageType> DamageType, vector HitLocation)
	{
		// (player-only) Prevent enemy team kills during trader time to fix players
		// missing the respawn and then dying from certain attacks that can do damage
		// just after the last zed dies (e.g. explosives/husk suicide, damage over time)
		if ( KilledPawn.Controller != None && KilledPawn.Controller.bIsPlayer
			&& (Killer == none || (KilledPawn.GetTeamNum() != Killer.GetTeamNum()))
			// @hack: Somehow we can get a suicide where Killer!=Victim?
			&& DamageType != class'DmgType_Suicided' )
		{
			// sanity check - The killer pawn should be dead or are detached by now
			if ( Killer == none || Killer.Pawn == None || !Killer.Pawn.IsAliveAndWell() )
			{
				return true;
			}
		}

		return Global.PreventDeath(KilledPawn, Killer, DamageType, HitLocation);
	}

Begin:
	Sleep(0.1f);
	DoTraderTimeCleanup();
}

/** Tell Kismet a trader opened */
function NotifyTraderOpened()
{
	local array<SequenceObject> AllTraderOpenedEvents;
	local array<int> OutputLinksToActivate;
	local KFSeqEvent_TraderOpened TraderOpenedEvt;
	local Sequence GameSeq;
	local int i;

	// Get the gameplay sequence.
	GameSeq = WorldInfo.GetGameSequence();

	if( GameSeq != none )
	{
		GameSeq.FindSeqObjectsByClass(class'KFSeqEvent_TraderOpened', TRUE, AllTraderOpenedEvents);

		for( i = 0; i < AllTraderOpenedEvents.Length; i++ )
		{
			TraderOpenedEvt = KFSeqEvent_TraderOpened(AllTraderOpenedEvents[i]);

			if( TraderOpenedEvt != None  )
			{
				TraderOpenedEvt.Reset();
				TraderOpenedEvt.SetWaveNum( WaveNum, WaveMax );
				if( MyKFGRI.IsFinalWave() && TraderOpenedEvt.OutputLinks.Length > 1 )
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

/** Tell Kismet a Trader closed */
function NotifyTraderClosed()
{
	local KFSeqEvent_TraderClosed TraderClosedEvt;
	local array<SequenceObject> AllTraderClosedEvents;
	local Sequence GameSeq;
	local int i;

	GameSeq = WorldInfo.GetGameSequence();
	if (GameSeq != none)
	{
		GameSeq.FindSeqObjectsByClass(class'KFSeqEvent_TraderClosed', true, AllTraderClosedEvents);
		for (i = 0; i < AllTraderClosedEvents.Length; ++i)
		{
			TraderClosedEvt = KFSeqEvent_TraderClosed(AllTraderClosedEvents[i]);
			if (TraderClosedEvt != none)
			{
				TraderClosedEvt.Reset();
				TraderClosedEvt.SetWaveNum(WaveNum, WaveMax);
				TraderClosedEvt.CheckActivate(self, self);
			}
		}
	}
}

final function ForceChangeLevel()
{
    bGameRestarted = false;
    bChangeLevels = true;
    RestartGame();
}

 /*********************************************************************************************
 * state MatchEnded
 *********************************************************************************************/

 State MatchEnded
 {
 	function BeginState( Name PreviousStateName )
	{
		if (WorldInfo.NetMode == NM_DedicatedServer)
		{
			//`REMOVEMESOON_ZombieServerLog("KFGameInfo_Survival:MatchEnded.BeginState - PreviousStateName: "$PreviousStateName);
		}

		`log("KFGameInfo_Survival - MatchEnded.BeginState - AARDisplayDelay:" @ AARDisplayDelay);

		MyKFGRI.EndGame();
		MyKFGRI.bWaitingForAAR = true; //@HSL - JRO - 6/15/2016 - Make sure we're still at full speed before the end of game menu shows up

		if ( AllowBalanceLogging() )
		{
			LogPlayersKillCount();
		}

		SetTimer(90.f, false, 'ForceChangeLevel');
		SetTimer(1.f, false, nameof(ProcessAwards));
		SetTimer(AARDisplayDelay, false, nameof(ShowPostGameMenu));
	}

	event Timer()
	{
		if (WorldInfo.NetMode == NM_DedicatedServer)
		{
			//`REMOVEMESOON_ZombieServerLog("KFGameInfo_Survival:MatchEnded.Timer - NumPlayers: "$NumPlayers);
		}

		global.Timer();
		if (NumPlayers == 0)
		{
			RestartGame();
		}
	}
 }

function EndOfMatch(bool bVictory)
{
	local KFPlayerController KFPC;

	if (WorldInfo.NetMode == NM_DedicatedServer)
	{
		//`REMOVEMESOON_ZombieServerLog("KFGameInfo_Survival.EndOfMatch - bVictory: "$bVictory);
	}

	`AnalyticsLog(("match_end", None, "#"$WaveNum, "#"$(bVictory ? "1" : "0"), "#"$GameConductor.ZedVisibleAverageLifespan));

	if(bVictory)
	{
		SetTimer(EndCinematicDelay, false, nameof(SetWonGameCamera));

		foreach WorldInfo.AllControllers(class'KFPlayerController', KFPC)
		{
			KFPC.ClientWonGame( WorldInfo.GetMapName( true ), GameDifficulty, GameLength,	IsMultiplayerGame() );
		}

		BroadcastLocalizedMessage(class'KFLocalMessage_Priority', GMT_MatchWon);
	}
	else
	{
		BroadcastLocalizedMessage(class'KFLocalMessage_Priority', GMT_MatchLost);
		SetZedsToVictoryState();
	}

    foreach WorldInfo.AllControllers(class'KFPlayerController', KFPC)
	{
		KFPC.ClientGameOver( WorldInfo.GetMapName(true), GameDifficulty, GameLength, IsMultiplayerGame(), WaveNum );
	}

	GotoState('MatchEnded');
}

//Get Top voted map
function string GetNextMap()
{
	local KFGameReplicationInfo KFGRI;
	local int NextMapIndex;

	KFGRI = KFGameReplicationInfo(WorldInfo.GRI);
	if( KFGRI != none )
	{
		NextMapIndex = KFGRI.VoteCollector.GetNextMap();
	}

	if( NextMapIndex != INDEX_NONE )
	{
		if(WorldInfo.NetMode == NM_Standalone)
		{
			return KFGRI.VoteCollector.Maplist[NextMapIndex];
		}
		else
		{
			return GameMapCycles[ActiveMapCycle].Maps[NextMapIndex];
		}

	}

	return super.GetNextMap();
}

function SetWonGameCamera()
{
	local KFPlayerController KFPC;

	foreach WorldInfo.AllControllers( class'KFPlayerController', KFPC )
	{
		KFPC.ServerCamera( 'ThirdPerson' );
	}
}

function SetZedsToVictoryState()
{
	local KFAIController KFAIC;

	foreach WorldInfo.AllControllers( class'KFAIController', KFAIC )
	{
		// Have the zeds enter their victory state
		KFAIC.EnterZedVictoryState();
	}
}

function ShowPostGameMenu()
{
	local KFGameReplicationInfo KFGRI;

	`log("KFGameInfo_Survival - ShowPostGameMenu");

	MyKFGRI.bWaitingForAAR = false; //@HSL - JRO - 6/15/2016 - Make sure we're still at full speed before the end of game menu shows up

	bEnableDeadToVOIP=true; //Being dead at this point is irrelevant.  Allow players to talk about AAR -ZG
	KFGRI = KFGameReplicationInfo(WorldInfo.GRI);

	if(KFGRI != none)
	{
		KFGRI.OnOpenAfterActionReport( GetEndOfMatchTime() );
	}

	class'EphemeralMatchStats'.Static.SendMapOptionsAndOpenAARMenu();

	UpdateCurrentMapVoteTime( GetEndOfMatchTime(), true);

	WorldInfo.TWPushLogs();
}

function float GetEndOfMatchTime()
{
	return MapVoteDuration;
}

function ProcessAwards()
{
	class'EphemeralMatchStats'.Static.ProcessPostGameStats();
}

function UpdateCurrentMapVoteTime(byte NewTime, optional bool bStartTime)
{
	if(WorldInfo.GRI.RemainingTime > NewTime || bStartTime)
	{
		ClearTimer(nameof(RestartGame));
		SetTimer(NewTime, false, nameof(TryRestartGame));
		WorldInfo.GRI.RemainingMinute = NewTime;
		WorldInfo.GRI.RemainingTime  = NewTime;
	}

	//in the case that the server has a 0 for the time we still want to be able to trigger a server travel.
	if(NewTime <= 0 || WorldInfo.GRI.RemainingTime <= 0)
	{
		TryRestartGame();
	}
}

function TryRestartGame()
{
	RestartGame();
}

/************************************************************************************
 * @name		Objectives
 ***********************************************************************************/

function bool IsMapObjectiveEnabled()
{
	return bEnableMapObjectives;
}

function ObjectiveFailed()
{
	MyKFGRI.DeactivateObjective();
}

function OnEndlessSpawningObjectiveDeactivated()
{
	CheckWaveEnd();
}

 /*********************************************************************************************
 * state DebugSuspendWave
 *********************************************************************************************/

 state DebugSuspendWave
 {
 	ignores CheckWaveEnd;

 	function BeginState( Name PreviousStateName )
 	{
 		local PlayerController PC;

 		DebugKillZeds();

 		foreach WorldInfo.AllControllers(class'PlayerController', PC)
		{
 			PC.ClientMessage("Survival: Spawn suspended");
 		}
	}

	function EndState( Name NextStateName )
	{
		local PlayerController PC;

		foreach WorldInfo.AllControllers(class'PlayerController', PC)
		{
 			PC.ClientMessage("Survival: Spawn resumed");
		}
	}
}

/**
 * Invoke the CheatManager function.  For some reason calling
 * ConsoleCommand directly on the GI does not follow through, so
 * as a workaround just find a PC and assume they have cheats on
 */
function DebugKillZeds()
{
	local PlayerController PC;

	if( AllowWaveCheats() )
	{
		foreach WorldInfo.AllControllers(class'PlayerController', PC)
		{
			if (KFDemoRecSpectator(PC) == none)
			{
				PC.ConsoleCommand("KillZeds");
				return;
			}
		}
	}
}

function OnOutbreakWaveWon() {}

function UpdateBonfires()
{
	local KFBarmwichBonfireVolume BonfireVolume;

	foreach AllActors(class'KFBarmwichBonfireVolume', BonfireVolume)
	{
		BonfireVolumes.AddItem(BonfireVolume);
	}
}

function ClearAllActorsFromBonfire()
{
	local KFBarmwichBonfireVolume BonfireVolume;

	foreach BonfireVolumes(BonfireVolume)
	{
		BonfireVolume.ClearAllActors();
	}
}

function ClearActorFromBonfire(Actor Other)
{
	local KFBarmwichBonfireVolume BonfireVolume;

	foreach BonfireVolumes(BonfireVolume)
	{
		BonfireVolume.ClearActor(Other);
	}
}

DefaultProperties
{
	TimeBetweenWaves=60			//This is going to be a difficulty setting later
	EndCinematicDelay=4
	AARDisplayDelay=15
	bCanPerkAlwaysChange=false
	MaxGameDifficulty=3
	bWaveStarted=false
	bGunGamePlayerOnLastGun=false
	CastleVolterTraderModifier = 1.0f;

	ObjectiveSpawnDelay=5

	SpawnManagerClasses(0)=class'KFGame.KFAISpawnManager_Short'
	SpawnManagerClasses(1)=class'KFGame.KFAISpawnManager_Normal'
	SpawnManagerClasses(2)=class'KFGame.KFAISpawnManager_Long'

	MaxRespawnDosh(0)=1750.f // Normal
	MaxRespawnDosh(1)=1550.f // Hard
	MaxRespawnDosh(2)=1700.f // Suicidal  //1550
	MaxRespawnDosh(3)=1550.f // Hell On Earth //1000.0

	GameplayEventsWriterClass=class'KFGame.KFGameplayEventsWriter'
	TraderVoiceGroupClass=class'KFGameContent.KFTraderVoiceGroup_Default'
	DifficultyInfoClass=class'KFGameDifficulty_Survival'
	DifficultyInfoConsoleClass=class'KFGameDifficulty_Survival_Console'

	// Preload content classes (by reference) to prevent load time hitches during gameplay
	// and keeps the GC happy.  This will also load client content -- via GRI.GameClass
	AIClassList(AT_Clot)=class'KFGameContent.KFPawn_ZedClot_Cyst'
	AIClassList(AT_AlphaClot)=class'KFGameContent.KFPawn_ZedClot_Alpha'
	AIClassList(AT_SlasherClot)=class'KFGameContent.KFPawn_ZedClot_Slasher'
	AIClassList(AT_Crawler)=class'KFGameContent.KFPawn_ZedCrawler'
	AIClassList(AT_GoreFast)=class'KFGameContent.KFPawn_ZedGorefast'
	AIClassList(AT_Stalker)=class'KFGameContent.KFPawn_ZedStalker'
	AIClassList(AT_Scrake)=class'KFGameContent.KFPawn_ZedScrake'
	AIClassList(AT_FleshPound)=class'KFGameContent.KFPawn_ZedFleshpound'
    AIClassList(AT_FleshpoundMini)=class'KFGameContent.KFPawn_ZedFleshpoundMini'
	AIClassList(AT_Bloat)=class'KFGameContent.KFPawn_ZedBloat'
	AIClassList(AT_Siren)=class'KFGameContent.KFPawn_ZedSiren'
	AIClassList(AT_Husk)=class'KFGameContent.KFPawn_ZedHusk'

	AIClassList(AT_EliteClot)=class'KFGameContent.KFPawn_ZedClot_AlphaKing'
	AIClassList(AT_EliteCrawler)=class'KFGameContent.KFPawn_ZedCrawlerKing'
	AIClassList(AT_EliteGoreFast)=class'KFGameContent.KFPawn_ZedGorefastDualBlade'
	AIClassList(AT_EDAR_EMP)=class'KFGameContent.KFPawn_ZedDAR_Emp'
	AIClassList(AT_EDAR_Laser)=class'KFGameContent.KFPawn_ZedDAR_Laser'
	AIClassList(AT_EDAR_Rocket)=class'KFGameContent.KFPawn_ZedDAR_Rocket'
	AIClassList(AT_HansClot)=class'KFGameContent.KFPawn_ZedHansClot'

	NonSpawnAIClassList(0)=class'KFGameContent.KFPawn_ZedBloatKingSubspawn'

	AIBossClassList(BAT_Hans)=class'KFGameContent.KFPawn_ZedHans'
	AIBossClassList(BAT_Patriarch)=class'KFGameContent.KFPawn_ZedPatriarch'
    AIBossClassList(BAT_KingFleshpound)=class'KFGameContent.KFPawn_ZedFleshpoundKing'
	AIBossClassList(BAT_KingBloat)=class'KFGameContent.KFPawn_ZedBloatKing'
	AIBossClassList(BAT_Matriarch)=class'KFGameContent.KFPawn_ZedMatriarch'

	// Short Wave
	LateArrivalStarts(0)={(
		StartingDosh[0]=700,	//550
		StartingDosh[1]=850,	//650
		StartingDosh[2]=1650,	//1200
		StartingDosh[3]=2200	//1500
	)}

	// Normal Wave
	LateArrivalStarts(1)={(
		StartingDosh[0]=600,	//450
		StartingDosh[1]=800,	//600
		StartingDosh[2]=1000,	//750
		StartingDosh[3]=1100,	//800
		StartingDosh[4]=1500,	//1100
		StartingDosh[5]=2000,	//1400
		StartingDosh[6]=2200,	//1500
		StartingDosh[7]=2400	//1600
	)}

	// Long Wave
	LateArrivalStarts(2)={(
		StartingDosh[0]=600,	//450
		StartingDosh[1]=700,	//550
		StartingDosh[2]=1000,	//750
		StartingDosh[3]=1300,	//1000
		StartingDosh[4]=1650,	//1200
		StartingDosh[5]=1800,	//1300
		StartingDosh[6]=2000,	//1400
		StartingDosh[7]=2200,	//1500
		StartingDosh[8]=2400,	//1600
		StartingDosh[9]=2400	//1600
	)}
}
