//=============================================================================
// KFAISpawnManager_Versus
//=============================================================================
// The KFAISpawnManager for Versus Survival mode
//=============================================================================
// Killing Floor 2
// Copyright (C) 2016 Tripwire Interactive LLC
// - Matt "Squirrlz" Farber
//=============================================================================
class KFAISpawnManager_Versus extends KFAISpawnManager
    within KFGameInfo_VersusSurvival;

/** Player zed spawn groups for this wave */
var protected array<KFAISpawnSquad> PlayerZedSquads;

/** Player zed wave archetypes */
var const array<KFAIWaveInfo> PlayerZedWaves;

/** Time between player zed group spawns, set per-wave */
var array<float> PlayerZedSpawnInterval;

/** How long to wait at the start of a wave before spawning player zeds */
var float FirstWaveStartSpawnWaitTime;
var float LaterWaveStartSpawnWaitTime;

/** When TRUE, special squad for this wave has been spawned */
var bool bSpawnedSpecialSquad;

/** How much of a chance the spawner has of choosing the special squad this spawn cycle */
var float SpecialSquadRandomChance;

/** MAXIMUM number times the special squad can be spawned per wave */
var array<int> MaxPlayerSpecialSquadSpawns;

/** How many times the special squad has been spawned this wave */
var int NumPlayerSpecialSquadSpawns;

/** How much to add to the random chance of spawning the special squad each spawn cycle */
var float AdditionalSpecialSquadChancePerSpawn;

/** Array of zeds reserved for players to spawn as */
var protected array<class<KFPawn_Monster> > ReservedPlayerZeds;

/** The reserved zed queue limit */
var const int ReservedZedQueueLimit;

/** Maximum number of player-controlled Scrakes allowed at once */
var const int MaxActivePlayerScrakes;

/** Maximum number of player-controlled Fleshpounds allowed at once */
var const int MaxActivePlayerFleshpounds;

/** Number of player Scrakes that have been queued up to spawn this cycle */
var protected int NumScrakesThisSpawnCycle;

/** Number of player Fleshpounds that have been queued up to spawn this cycle */
var protected int NumFleshpoundsThisSpawnCycle;

/** TRUE when boss has been spawned in Versus */
var protected bool bBossSpawned;

/** How long to wait between spawn cycles during the boss round */
var protected float BossSpawnPlayerInterval;

/** The interval between spawn attempts when we're down to only one survivor */
var protected float FinalSurvivorBossSpawnPlayerInterval;

/** The largest squad size in this wave */
var protected int LargestSquadSize;
`if(`notdefined(ShippingPC))
/** TRUE if we are using simulated players */
var bool bUsingAISimulatedPlayers;

/** Number of players we're simulating */
var int AISimulatedPlayerNum;
`endif

/** We need to add our reserved zeds to the alive count */
function int GetAIAliveCount()
{
    return super.GetAIAliveCount() + ReservedPlayerZeds.Length;
}

/** Next wave's basic setup */
function SetupNextWave(byte NextWaveIndex, int TimeToNextWaveBuffer = 0)
{
    local int i, j, SquadZedCount;
    local array<KFAISpawnSquad> SquadList;
    local KFPlayerControllerVersus KFPCV;
    local float SpawnWaitTime;

    super.SetupNextWave( NextWaveIndex, TimeToNextWaveBuffer );

    // Get the maximum squad size count
    LargestSquadSize = 0;
    WaveSettings.Waves[NextWaveIndex].GetNewSquadList( SquadList );
    for( i = 0; i < AvailableSquads.Length; ++i )
    {
        SquadZedCount = 0;
        for( j = 0; j < AvailableSquads[i].MonsterList.Length; j++ )
        {
            SquadZedCount += AvailableSquads[i].MonsterList[j].Num;
        }

        if( SquadZedCount > LargestSquadSize )
        {
            LargestSquadSize = SquadZedCount;
        }
    }

    // Set up player zed squad list
    if( NextWaveIndex < PlayerZedWaves.Length )
    {
        PlayerZedWaves[NextWaveIndex].GetNewSquadList( PlayerZedSquads );

        // Set initial spawn timer
        SpawnWaitTime = NextWaveIndex == 0 ? FirstWaveStartSpawnWaitTime : LaterWaveStartSpawnWaitTime;
        SetTimer( SpawnWaitTime, false, nameOf(Timer_SpawnPlayerZeds), self );
        MyKFGRIV.SetPlayerZedSpawnTime( SpawnWaitTime, false );
    }
    else
    {
        // Set our boss pawn spawn timer
        SetTimer( 5.f, false, nameOf(Timer_SpawnPlayerZeds), self );

        // Disable the spawn timer on clients
        MyKFGRIV.SetPlayerZedSpawnTime( 255, false );
    }

    // Clear out any pending zed spawn info
    foreach WorldInfo.AllControllers( class'KFPlayerControllerVersus', KFPCV )
    {
        KFPCV.PlayerZedSpawnInfo.PendingZedPawnClass = none;
        KFPCV.PlayerZedSpawnInfo.PendingZedSpawnLocation = vect(0,0,0);
    }

    // Reset special squad spawn properties
    bSpawnedSpecialSquad = false;
    SpecialSquadRandomChance = 0.1f;
    NumPlayerSpecialSquadSpawns = 0;
}

/** Find best spawn location and spawn a squad there */
function int SpawnSquad( out array< class<KFPawn_Monster> > AIToSpawn, optional bool bSkipHumanZedSpawning=false )
{
    local int NumSpawned;

    NumSpawned = super.SpawnSquad( AIToSpawn, bSkipHumanZedSpawning );

    // If an AI boss spawned, we shouldn't allow a player boss to
    if( NumSpawned > 0 && DesiredSquadType == EST_Boss )
    {
        bBossSpawned = true;
    }

    return NumSpawned;
}

/** Spawns the next squad of players, if possible */
function Timer_SpawnPlayerZeds()
{
`if(`notdefined(ShippingPC))
    local array<class<KFPawn_Monster> > AISquad;
    local KFSpawnVolume KFSV;
    local KFAIController KFAIC;
    local int ReservedIndex, OtherRandNum, i, j;
    local bool bRemoveFromSquad;
`endif
    local int RandNum;
    local array<class<KFPawn_Monster> > NewSquad;
    local float SpawnTimer;

    // Early out if takeover timer is active or spawning isn't allowed
    if( IsTimerActive(nameOf(Timer_CheckForZedTakeovers), self) || !IsPlayerZedSpawnAllowed() || CheckForTakeoverTimer() )
    {
        // Spawn our boss pawn
        if( MyKFGRI.WaveNum == MyKFGRI.WaveMax )
        {
            RespawnZedHumanPlayers( none );
        }
        else
        {
            MyKFGRIV.SetPlayerZedSpawnTime( 255, true );
        }
        return;
    }

    // If we have no zed players, spawn in the remaining reserved zeds
    if( !HaveZedPlayers() )
    {
        SpawnRemainingReservedZeds();
        return;
    }

    // Reset our big zed counts
    NumScrakesThisSpawnCycle = 0;
    NumFleshpoundsThisSpawnCycle = 0;

    // Only do spawning if the wave isn't paused
    if( WorldInfo.Game.IsInState('PlayingWave') )
    {
        // Repopulate squad list if we don't have any squads available to spawn (or need to spawn our special squad)
        CheckForSpecialSquadSpawn();

        // Generate list of classes to spawn and remove squad from possible squad list
        RandNum = Rand( PlayerZedSquads.Length );
        GetSpawnListFromSquad( RandNum, PlayerZedSquads, NewSquad );
        PlayerZedSquads.Remove( RandNum, 1 );
`if(`notdefined(ShippingPC))
        // Fake players using AI
        if( bUsingAISimulatedPlayers )
        {
            i = AISimulatedPlayerNum;

            // Subtract the number of alive simulated AI from the number we want to spawn
            foreach WorldInfo.AllControllers( class'KFAIController', KFAIC )
            {
                if( KFAIC.bIsSimulatedPlayerController && KFAIC.Pawn != none && KFAIC.Pawn.IsAliveAndWell() )
                {
                    --i;
                }
            }

            // Add our reserved zeds first
            for( j = 0; j < ReservedPlayerZeds.Length && i > 0; ++j )
            {
                AISquad.AddItem( ReservedPlayerZeds[j] );
                ReservedPlayerZeds.Remove( j, 1 );
                --j;
                --i;
            }

            // Build our simulated squad
            while( i > 0 && NewSquad.Length > 0 )
            {
                OtherRandNum = Rand( NewSquad.Length );
                AISquad.AddItem( NewSquad[OtherRandNum] );
                NewSquad.Remove( OtherRandNum, 1 );
                --i;
            }

            // If we have simulated players to spawn, do it immediately
            if( AISquad.Length > 0 )
            {
                // Change squad classes to player zed versions
                for( i = 0; i < AISquad.Length; ++i )
                {
                    // Make sure we're not going over our active Scrake/FP limit
                    bRemoveFromSquad = false;
                    if( AISquad[i] == AIClassList[AT_Scrake] )
                    {
                        if( NumScrakesThisSpawnCycle >= MaxActivePlayerScrakes || GetNumActiveZedsOfClass(class'KFPawn_ZedScrake') >= MaxActivePlayerScrakes )
                        {
                            bRemoveFromSquad = true;
                        }
                        else
                        {
                            ++NumScrakesThisSpawnCycle;
                        }
                    }
                    else if( AISquad[i] == AIClassList[AT_Fleshpound] )
                    {
                        if( NumFleshpoundsThisSpawnCycle >= MaxActivePlayerFleshpounds || GetNumActiveZedsOfClass(class'KFPawn_ZedFleshpound') >= MaxActivePlayerFleshpounds )
                        {
                            bRemoveFromSquad = true;
                        }
                        else
                        {
                            ++NumFleshpoundsThisSpawnCycle;
                        }
                    }

                    if( bRemoveFromSquad )
                    {
                        NewSquad.AddItem( AISquad[i] );
                        AISquad.Remove( i, 1 );
                        --i;
                        continue;
                    }

                    for( j = 0; j < PlayerZedClasses.Length; ++j )
                    {
                        if( ClassIsChildOf(PlayerZedClasses[j], AISquad[i]) )
                        {
                            // Make sure we're clearing our reserved array
                            ReservedIndex = ReservedPlayerZeds.Find( AISquad[i] );
                            if( ReservedIndex != INDEX_NONE )
                            {
                                ReservedPlayerZeds.Remove( ReservedIndex, 1 );
                            }

                            // Assign our player zed class to the AI squad
                            AISquad[i] = PlayerZedClasses[j];
                        }
                    }
                }

                // Spawn our simulated AI squad
                KFSV = GetBestSpawnVolume( AISquad );
                KFSV.SpawnWave( AISquad, true, true );

                // Add our new simulated AI players to the spawned AI count
                foreach WorldInfo.AllControllers( class'KFAIController', KFAIC )
                {
                    if( KFAIC.bIsSimulatedPlayerController && KFAIC.CreationTime == WorldInfo.TimeSeconds )
                    {
                        ++NumAISpawnsQueued;
                    }
                }
            }
        }
`endif

        // Assign zed classes to players
        AssignZedsToPlayers( NewSquad );

        // Respawn all pending zed players
        RespawnZedHumanPlayers( LastAISpawnVolume );
    }

    // Set timer for next spawn
    SpawnTimer = PlayerZedSpawnInterval[MyKFGRI.WaveNum-1];
    SetTimer( SpawnTimer, false, nameOf(Timer_SpawnPlayerZeds), self );
    MyKFGRIV.SetPlayerZedSpawnTime( SpawnTimer, false );
}

/** See if we can spawn the special squad yet */
function CheckForSpecialSquadSpawn()
{
    local int WaveArrayNum;
    local bool bRequireEndWaveSpecialSquadSpawn;

    WaveArrayNum = MyKFGRI.WaveNum-1;

    // If we can't spawn any special squads, early out
    if( MaxPlayerSpecialSquadSpawns[WaveArrayNum] == 0 || NumPlayerSpecialSquadSpawns >= MaxPlayerSpecialSquadSpawns[WaveArrayNum] )
    {
        if( PlayerZedSquads.Length == 0 )
        {
            PlayerZedWaves[WaveArrayNum].GetNewSquadList( PlayerZedSquads );
        }
        return;
    }

    // First, make sure that we've spawned in our special squad if we've reached the middle/end of the wave
    bRequireEndWaveSpecialSquadSpawn = (WaveTotalAI - NumAISpawnsQueued <= LargestSquadSize*3);
    if( bRequireEndWaveSpecialSquadSpawn || (NumPlayerSpecialSquadSpawns == 0 && NumAISpawnsQueued >= WaveTotalAI * 0.5f) )
    {
        GetSpecialSquad( WaveArrayNum );
    }

    // Next, deal with the squad array being empty
    if( PlayerZedSquads.Length == 0 )
    {
        // If we've already spawned our special squad, reset for next cycle but don't add to squads array
        if( bSpawnedSpecialSquad )
        {
            bSpawnedSpecialSquad = false;
            SpecialSquadRandomChance = 0.f;
        }
        else
        {
            // We haven't spawned our special squad yet, so do it now
            GetSpecialSquad( WaveArrayNum );
        }
    }

    // Check against our random number to see if we can spawn a special squad
    if( !bSpawnedSpecialSquad )
    {
        SpecialSquadRandomChance += AdditionalSpecialSquadChancePerSpawn;
        if( fRand() < SpecialSquadRandomChance )
        {
            GetSpecialSquad( WaveArrayNum );
        }
    }

    // Make sure we still fill the squad array in case there was no special squad
    if( PlayerZedSquads.Length == 0 )
    {
        PlayerZedWaves[WaveArrayNum].GetNewSquadList( PlayerZedSquads );
    }
}

/** Clears the squad array and assigns the special squad */
function GetSpecialSquad( int WaveArrayNum )
{
    PlayerZedSquads.Length = 0;
    PlayerZedWaves[WaveArrayNum].GetSpecialSquad( PlayerZedSquads );
    bSpawnedSpecialSquad = true;
    SpecialSquadRandomChance = 0.f;
    ++NumPlayerSpecialSquadSpawns;
}

/** Assign and reserve zed squad members for human players if this is a versus game */
function AssignZedsToPlayers( out array<class<KFPawn_Monster> > NewZeds )
{
    local KFPlayerControllerVersus KFPCV;

    // Always refresh the alive count when handing out zed classes
    RefreshMonsterAliveCount();

    // First, give players that are waiting an immediate spawn
    foreach WorldInfo.AllControllers( class'KFPlayerControllerVersus', KFPCV )
    {
        if( KFPCV.GetTeamNum() == 255
            && (KFPCV.Pawn == none || !KFPCV.Pawn.IsAliveAndWell())
            && KFPCV.CanRestartPlayer()
            && KFPCV.PlayerZedSpawnInfo.PendingZedPawnClass == none )
        {
            if( ReservedPlayerZeds.Length > 0 )
            {
                GiveAvailableZedClass( KFPCV, ReservedPlayerZeds,, true );
                if( KFPCV.PlayerZedSpawnInfo.PendingZedPawnClass != none )
                {
                    continue;
                }
            }

            if( NewZeds.Length == 0 )
            {
                continue;
            }

            GiveAvailableZedClass( KFPCV, NewZeds );
        }
    }

    // Now reserve any remaining strong zeds for players
    ReserveStrongZedsForPlayers( NewZeds );
}

/** Gives a dead player a zed class to spawn with */
function GiveAvailableZedClass( KFPlayerControllerVersus KFPCV, out array<class<KFPawn_Monster> > AvailableZeds, optional bool bSecondPass, optional bool bReservedCheck )
{
    local int i, j;
    local int ZedIndex;
    local array<int> PassedOnZeds;
    local array<class<KFPawn_Monster> > PossibleZeds;

    // Clear our spawned zeds array if we've spawned as most of the zed types already
    if( KFPCV.HasSpawnedZeds.Length >= PlayerZedClasses.Length - 3 )
    {
        KFPCV.HasSpawnedZeds.Length = 0;
    }

    // Iterate through all available zeds and populate array with classes we haven't spawned as yet
    for( i = 0; i < AvailableZeds.Length; ++i )
    {
        // Make sure we're not spawning more than are allowed to be active
        if( AvailableZeds[i] == AIClassList[AT_Scrake] )
        {
            if( NumScrakesThisSpawnCycle >= MaxActivePlayerScrakes || GetNumActiveZedsOfClass(class'KFPawn_ZedScrake') >= MaxActivePlayerScrakes )
            {
                continue;
            }
        }
        else if( AvailableZeds[i] == AIClassList[AT_Fleshpound] )
        {
            if( NumFleshpoundsThisSpawnCycle >= MaxActivePlayerFleshpounds || GetNumActiveZedsOfClass(class'KFPawn_ZedFleshpound') >= MaxActivePlayerFleshpounds )
            {
                continue;
            }
        }

        for( j = 0; j < PlayerZedClasses.Length; ++j )
        {
            // Check our spawnzed zeds array to see if we've spawned as this class yet
            if( ClassIsChildOf(PlayerZedClasses[j], AvailableZeds[i]) )
            {
                if( j < KFPCV.HasSpawnedZeds.Length && KFPCV.HasSpawnedZeds[j] )
                {
                    PassedOnZeds.AddItem( j );
                    break;
                }

                PossibleZeds.AddItem( AvailableZeds[i] );
                break;
            }
        }
    }

    // Determine if we should check the list again or take over a zed instead
    if( PossibleZeds.Length == 0 )
    {
        // If this isn't a reserved zed check, either process second pass or find a takeover zed
        if( !bReservedCheck )
        {
            // See if we need to trim our spawned types array and start fresh
            if( !bSecondPass && PassedOnZeds.Length > 1 )
            {
                // Remove one of the zed types we passed on
                KFPCV.HasSpawnedZeds.Remove( PassedOnZeds[Rand(PassedOnZeds.Length)], 1 );

                // Do our second pass, with trimming
                GiveAvailableZedClass( KFPCV, AvailableZeds, true );
                return;
            }

            // Try to take over an existing zed if we have no available squad slots
            FindTakeoverZed( KFPCV );
        }

        return;
    }

    // Pick a zed at random
    ZedIndex = Rand( PossibleZeds.Length );
    for( i = 0; i < PlayerZedClasses.Length; ++i )
    {
        if( ClassIsChildOf(PlayerZedClasses[i], PossibleZeds[ZedIndex]) )
        {
            if( PossibleZeds[ZedIndex] == AIClassList[AT_Scrake] )
            {
                ++NumScrakesThisSpawnCycle;
            }
            else if( PossibleZeds[ZedIndex] == AIClassList[AT_Fleshpound] )
            {
                ++NumFleshpoundsThisSpawnCycle;
            }

            KFPCV.PlayerZedSpawnInfo.PendingZedPawnClass = PlayerZedClasses[i];
            AvailableZeds.Remove( AvailableZeds.Find(PossibleZeds[ZedIndex]), 1 );
            KFPCV.HasSpawnedZeds[i] = true;

            // Only increment this if we are not taking a reserved zed
            // NOTE: The queue counter is already incremented when a reserved zed is taken out of the squad
            if( !bReservedCheck )
            {
                ++NumAISpawnsQueued;
            }
            return;
        }
    }
}

/** Reserves strong zeds for players */
function ReserveStrongZedsForPlayers( out array<class<KFPawn_Monster> > LeftoverZeds )
{
    local int i;
    local class<KFPawn_Monster> LeftoverZedClass;

    for( i = 0; i < LeftoverZeds.Length; ++i )
    {
        LeftoverZedClass = LeftoverZeds[i];

        // Always reserve Scrake or Fleshpound, and always at the front of the queue
        if( ClassIsChildOf(PlayerZedClasses[AT_Fleshpound], LeftoverZedClass)
            || ClassIsChildOf(PlayerZedClasses[AT_Scrake], LeftoverZedClass) )
        {
            LeftoverZeds.Remove( i, 1 );
            ReservedPlayerZeds.Insert( 0, 1 );
            ReservedPlayerZeds[0] = LeftoverZedClass;
            ++NumAISpawnsQueued;
            --i;
            continue;
        }
    }
}

/** Pings the spawn volume to get the best location to spawn a player zed */
function vector GetSpawnLocation( class<KFPawn_Monster> MonsterPawnClass, KFSpawnVolume SpawnVolume )
{
    SpawnVolume.SetLastSpawnTime( WorldInfo.TimeSeconds );
    return SpawnVolume.FindSpawnLocation( MonsterPawnClass );
}

/** Attempt to respawn all player zeds */
protected function RespawnZedHumanPlayers( KFSpawnVolume SpawnVolume, optional bool bIsTakeOverSpawn )
{
    local KFPlayerController KFPC;
    local vector SpawnLocation;
    local ESquadType SquadType;
    local array<KFPlayerController> CrawlerPlayers, MediumPlayers, LargePlayers, BossPlayers;
    local int NumSpawned, NumSquadMembers;
    local array<class<KFPawn_Monster> > TempPawnClasses, CrawlerPawnClasses, MediumPawnClasses, LargePawnClasses, BossPawnClasses;
    local int i;
    local bool bStopSpawning;

    // If match is over or trader is open, do nothing
    if( !IsWaveActive() )
    {
        return;
    }

    // Spawn a boss pawn
    if( MyKFGRI.WaveNum == MyKFGRI.WaveMax && !bBossSpawned )
    {
        // Make sure the zed takeover timer isn't running
        if( IsTimerActive(nameOf(Timer_CheckForZedTakeovers), self) )
        {
            ClearTimer( nameOf(Timer_CheckForZedTakeovers), self );
        }

        // Clear reserved list
        ReservedPlayerZeds.Length = 0;

        // Count how many player zeds we have
        foreach WorldInfo.AllControllers( class'KFPlayerController', KFPC )
        {
            // Clear out any pending zed spawn info
            KFPC.PlayerZedSpawnInfo.PendingZedPawnClass = none;
            KFPC.PlayerZedSpawnInfo.PendingZedSpawnLocation = vect(0,0,0);

            if( KFPC.CanRestartPlayer() && KFPC.GetTeamNum() == 255 )
            {
                BossPlayers.AddItem( KFPC );
            }
        }

        KFPC = BossPlayers[Rand(BossPlayers.Length)];

        if( KFPC != none )
        {
            // Set our boss pawn class
            KFPC.PlayerZedSpawnInfo.PendingZedPawnClass = PlayerBossClassList[Rand(PlayerBossClassList.Length)];
            BossPawnClasses[0] = KFPC.PlayerZedSpawnInfo.PendingZedPawnClass;

            // Make sure we get a valid spawn volume to start
            if( SpawnVolume == none || SpawnVolume.bNoPlayers )
            {
                SetDesiredSquadTypeForZedList( BossPawnClasses );
                SpawnVolume = GetBestSpawnVolume( BossPawnClasses,, KFPC );
            }

            // Make sure we kill the previous pawn
            if( KFPC.Pawn != none )
            {
                KFPC.Pawn.Destroy();
            }

            RestartPlayer( KFPC );
            if( KFPC.Pawn != none )
            {
                bBossSpawned = true;
                SpawnLocation = GetSpawnLocation( class<KFPawn_Monster>(KFPC.Pawn.Class), SpawnVolume );
                KFPC.SetLocation( SpawnLocation );
                KFPC.Pawn.SetLocation( SpawnLocation );
                KFPC.InitGameplayPostProcessFX();
                KFPC.PlayerZedSpawnInfo.PendingZedPawnClass = none;
                KFPC.PlayerZedSpawnInfo.PendingZedSpawnLocation = vect(0,0,0);
                ++NumAISpawnsQueued;

                RefreshMonsterAliveCount();
            }
            else
            {
                // Try to find a different player
                RespawnZedHumanPlayers( none );
                return;
            }
        }

        // Set the player zed spawn timer
        SetTimer( BossSpawnPlayerInterval, false, nameOf(Timer_SpawnBossPlayerZeds), self );
        return;
    }

    // Collect squads
    foreach WorldInfo.AllControllers( class'KFPlayerController', KFPC )
    {
        if( KFPC.Pawn != none && KFPC.Pawn.IsAliveAndWell() )
        {
            continue;
        }

        // Separate pending zed players out into squads
        if( KFPC.PlayerZedSpawnInfo.PendingZedPawnClass != none && KFPC.CanRestartPlayer() && KFPC.GetTeamNum() == 255 )
        {
            TempPawnClasses[0] = KFPC.PlayerZedSpawnInfo.PendingZedPawnClass;
            SquadType = GetDesiredSquadTypeForZedList( TempPawnClasses );

            if( SquadType == EST_Crawler )
            {
                CrawlerPlayers.AddItem( KFPC );
                CrawlerPawnClasses.AddItem( KFPC.PlayerZedSpawnInfo.PendingZedPawnClass );
            }
            else if( SquadType == EST_Small || SquadType == EST_Medium )
            {
                MediumPlayers.AddItem( KFPC );
                MediumPawnClasses.AddItem( KFPC.PlayerZedSpawnInfo.PendingZedPawnClass );
            }
            else
            {
                LargePlayers.AddItem( KFPC );
                LargePawnClasses.AddItem( KFPC.PlayerZedSpawnInfo.PendingZedPawnClass );
            }
        }
    }

    // Early out if we have no players to spawn
    if( CrawlerPlayers.Length == 0 && MediumPlayers.Length == 0 && LargePlayers.Length == 0 )
    {
        CheckForTakeoverTimer();
        return;
    }

    // Refresh our alive count
    RefreshMonsterAliveCount();

    // Crawlers
    if( CrawlerPlayers.Length > 0 )
    {
        SetDesiredSquadTypeForZedList( CrawlerPawnClasses );
        SpawnVolume = GetBestSpawnVolume( CrawlerPawnClasses,, CrawlerPlayers[0] );
        for( i = 0; i < CrawlerPlayers.Length; ++i )
        {
            if( !IsWaveActive() )
            {
                return;
            }

            // Make sure we have enough slots
            if( MyKFGRI.WaveNum < MyKFGRI.WaveMax && AIAliveCount + NumSpawned + 1 > MyKFGRI.AIRemaining )
            {
                bStopSpawning = true;
                break;
            }

            // Only allow 3 spawns per volume
            if( NumSquadMembers % 3 == 0 )
            {
                SetDesiredSquadTypeForZedList( CrawlerPawnClasses );
                SpawnVolume = GetBestSpawnVolume( CrawlerPawnClasses,, CrawlerPlayers[i] );
            }

            // Spawn player
            if( RestartPlayerZed(CrawlerPlayers[i], SpawnVolume) )
            {
                // Count the number of spawns, if we have more than 2 then choose a new spawn volume
                ++NumSpawned;
                ++NumSquadMembers;
            }

            // Clear these zeds out of the array in case we need to get another spawn volume
            CrawlerPlayers.Remove( i, 1 );
            CrawlerPawnClasses.Remove( i, 1 );
            --i;
        }
    }

    // Small-medium zeds
    if( !bStopSpawning && MediumPlayers.Length > 0 )
    {
        NumSquadMembers = 0;
        SetDesiredSquadTypeForZedList( MediumPawnClasses );
        SpawnVolume = GetBestSpawnVolume( MediumPawnClasses,, MediumPlayers[0] );
        for( i = 0; i < MediumPlayers.Length; ++i )
        {
            if( !IsWaveActive() )
            {
                return;
            }

            // Make sure we have enough slots
            if( MyKFGRI.WaveNum < MyKFGRI.WaveMax && AIAliveCount + NumSpawned + 1 > MyKFGRI.AIRemaining )
            {
                bStopSpawning = true;
                break;
            }

            // Only allow 3 spawns per volume
            if( NumSquadMembers % 3 == 0 )
            {
                SetDesiredSquadTypeForZedList( MediumPawnClasses );
                SpawnVolume = GetBestSpawnVolume( MediumPawnClasses,, MediumPlayers[i] );
            }

            // Spawn player
            if( RestartPlayerZed(MediumPlayers[i], SpawnVolume) )
            {
                // Count the number of spawns, if we have more than 2 then choose a new spawn volume
                ++NumSpawned;
                ++NumSquadMembers;
            }

            // Clear these zeds out of the array in case we need to get another spawn volume
            MediumPlayers.Remove( i, 1 );
            MediumPawnClasses.Remove( i, 1 );
            --i;
        }
    }

    // Large zeds
    if( !bStopSpawning && LargePlayers.Length > 0 )
    {
        NumSquadMembers = 0;
        SetDesiredSquadTypeForZedList( LargePawnClasses );
        SpawnVolume = GetBestSpawnVolume( LargePawnClasses,, LargePlayers[0] );
        for( i = 0; i < LargePlayers.Length; ++i )
        {
            if( !IsWaveActive() )
            {
                return;
            }

            // Make sure we have enough slots
            if( MyKFGRI.WaveNum < MyKFGRI.WaveMax && AIAliveCount + NumSpawned + 1 > MyKFGRI.AIRemaining )
            {
                bStopSpawning = true;
                break;
            }

            // Only allow 3 spawns per volume
            if( NumSquadMembers % 3 == 0 )
            {
                SetDesiredSquadTypeForZedList( LargePawnClasses );
                SpawnVolume = GetBestSpawnVolume( LargePawnClasses,, LargePlayers[i] );
            }

            // Spawn player
            if( RestartPlayerZed(LargePlayers[i], SpawnVolume) )
            {
                // Count the number of spawns, if we have more than 2 then choose a new spawn volume
                ++NumSpawned;
                ++NumSquadMembers;
            }

            // Clear these zeds out of the array in case we need to get another spawn volume
            LargePlayers.Remove( i, 1 );
            LargePawnClasses.Remove( i, 1 );
            --i;
        }
    }

    // Add spawned to monster alive count
    AIAliveCount += NumSpawned;
	NumAIFinishedSpawning += NumSpawned;
	UpdateAIRemaining();

    // If we need to stop spawning, clear all pending zed spawns
    if( bStopSpawning )
    {
        foreach WorldInfo.AllControllers( class'KFPlayerController', KFPC )
        {
            KFPC.PlayerZedSpawnInfo.PendingZedPawnClass = none;
        }
    }

    // Check if our takeover timer should be started
    CheckForTakeoverTimer();
}

/** Checks the wave status to see if we can start our zed takeover timer */
function bool CheckForTakeoverTimer()
{
    local KFPlayerControllerVersus KFPCV;
    local int ZedPlayers;

    // Don't allow if this is not a normal wave
    if( !IsPlayerZedSpawnAllowed() )
    {
        if( IsTimerActive(nameOf(Timer_CheckForZedTakeovers), self) )
        {
            ClearTimer( nameOf(Timer_CheckForZedTakeovers), self );
        }
        return false;
    }

    // Count up number of active zed players
    foreach WorldInfo.AllControllers( class'KFPlayerControllerVersus', KFPCV )
    {
        if( !KFPCV.CanRestartPlayer() )
        {
            continue;
        }

        if( KFPCV.GetTeamNum() == 255 )
        {
            ++ZedPlayers;
        }
    }

    // Set a timer to take over zeds right before the last squad
    if( WaveTotalAI - NumAISpawnsQueued <= LargestSquadSize+ZedPlayers )
    {
        if( !IsTimerActive(nameOf(Timer_CheckForZedTakeovers), self) )
        {
            MyKFGRIV.SetPlayerZedSpawnTime( 255, true );
            SetTimer( 1.f, true, nameOf(Timer_CheckForZedTakeovers), self );
        }

        return true;
    }

    return false;
}

/** Searches for AI zeds to take over */
function Timer_CheckForZedTakeovers()
{
    local KFPlayerControllerVersus KFPCV;
    local bool bNeedRespawn;
    local array<KFPlayerControllerVersus> ZedPlayers;
    local int i, LivingPlayerCount, DesiredTakeovers;

    // Always refresh the alive count when this timer is active
    RefreshMonsterAliveCount();

    // Don't allow if this is not a normal wave
    if( !IsPlayerZedSpawnAllowed() )
    {
        ClearTimer( nameOf(Timer_CheckForZedTakeovers), self );
        return;
    }

    // Make sure we're putting in our remaining reserved zeds
    SpawnRemainingReservedZeds();

    // Set to zero
    DesiredTakeovers = 0;
    bNeedRespawn = false;

    // If the survivors are down to 1 person, don't allow more than 3 player zeds at once
    LivingPlayerCount = GetLivingPlayerCount();
    if( LivingPlayerCount < 3 )
    {
        DesiredTakeovers = LivingPlayerCount == 2 ? 4 : 3;
        foreach WorldInfo.AllControllers( class'KFPlayerControllerVersus', KFPCV )
        {
            if( KFPCV.GetTeamNum() == 255 )
            {
                if( KFPCV.Pawn != none && KFPCV.Pawn.IsAliveAndWell()  )
                {
                    --DesiredTakeovers;

                    // Early out if we have no available spawns left
                    if( DesiredTakeovers == 0 )
                    {
                        return;
                    }
                }
                else if( KFPCV.CanRestartPlayer() )
                {
                    if( KFPCV.PlayerZedSpawnInfo.PendingZedPawnClass != none )
                    {
                        // We had a pending zed class already, so we'll need at least one respawn
                        bNeedRespawn = true;
                        continue;
                    }

                    // Make sure we clear out our reserved zeds first
                    if( ReservedPlayerZeds.Length > 0 )
                    {
                        GiveAvailableZedClass( KFPCV, ReservedPlayerZeds,, true );
                    }

                    if( KFPCV.PlayerZedSpawnInfo.PendingZedPawnClass == none )
                    {
                        ZedPlayers.AddItem( KFPCV );
                    }
                    else
                    {
                        // We had a pending zed class already, so we'll need at least one respawn
                        bNeedRespawn = true;
                    }
                }
            }
        }
    }
    else
    {
        // Collect our pending zed players
        foreach WorldInfo.AllControllers( class'KFPlayerControllerVersus', KFPCV )
        {
            if( KFPCV.GetTeamNum() != 255 || !KFPCV.CanRestartPlayer() )
            {
                continue;
            }

            if( KFPCV.PlayerZedSpawnInfo.PendingZedPawnClass != none )
            {
                // We had a pending zed class already, so we'll need at least one respawn
                bNeedRespawn = true;
                continue;
            }

            if( KFPCV.Pawn == none || !KFPCV.Pawn.IsAliveAndWell() )
            {
                // Make sure we clear out our reserved zeds first
                if( ReservedPlayerZeds.Length > 0 )
                {
                    GiveAvailableZedClass( KFPCV, ReservedPlayerZeds,, true );
                }

                if( KFPCV.PlayerZedSpawnInfo.PendingZedPawnClass == none )
                {
                    ZedPlayers.AddItem( KFPCV );
                }
                else
                {
                    // We had a pending zed class already, so we'll need at least one respawn
                    bNeedRespawn = true;
                }
            }
        }
    }

    // Early out if we have no players waiting for spawn
    if( ZedPlayers.Length == 0 && !bNeedRespawn )
    {
        return;
    }

    // Only attempt takeovers if we have players waiting for a spawn
    if( ZedPlayers.Length > 0 )
    {
        // Remove enough pending zed players to fit within our available spawn slots
        if( DesiredTakeovers > 0 )
        {
            while( ZedPlayers.Length > DesiredTakeovers )
            {
                ZedPlayers.Remove( Rand(ZedPlayers.Length), 1 );
            }
        }

        // Attempt to find zeds for takeover
        for( i = 0; i < ZedPlayers.Length; ++i )
        {
            KFPCV = ZedPlayers[i];
            FindTakeoverZed( KFPCV );
            if( KFPCV.PlayerZedSpawnInfo.PendingZedPawnClass != none )
            {
                bNeedRespawn = true;
            }
        }
    }

    // Respawn all pending controllers
    if( bNeedRespawn )
    {
        RespawnZedHumanPlayers( none );
    }
}

function bool NeedPlayerSpawnVolume()
{
    return IsTimerActive( nameOf(Timer_CheckForZedTakeovers), self );
}

/** Spawns in our remaining reserved zeds */
function SpawnRemainingReservedZeds( optional bool bSpawnAllReservedZeds )
{
    local int NumWaitingZedPlayers;
    local array<class<KFPawn_Monster> > TempSquad;

    // Early out if this is not a normal wave or there are no reserved zeds remaining
    if( ReservedPlayerZeds.Length == 0 || !IsPlayerZedSpawnAllowed() )
    {
        // Make sure this stays clear
        ReservedPlayerZeds.Length = 0;
        return;
    }

    // Refresh our alive count
    RefreshMonsterAliveCount();

    // Don't spawn in any of our leftover reserved zeds if it would exceed the zed counter
    if( AIAliveCount + 1 > MyKFGRI.AIRemaining )
    {
        ReservedPlayerZeds.Length = 0;
        return;
    }
    else
    {
        // Prune to spawn limits
        while( ReservedPlayerZeds.Length > 0 && AIAliveCount + ReservedPlayerZeds.Length > MyKFGRI.AIRemaining )
        {
            ReservedPlayerZeds.Remove( 0, 1 );
        }

        // No reserved zeds left!
        if( ReservedPlayerZeds.Length == 0 )
        {
            return;
        }
    }

    // See how many are still waiting to spawn. If we don't have any, spawn them in as AI
    NumWaitingZedPlayers = GetNumWaitingZedPlayers();
    if( NumWaitingZedPlayers == 0 )
    {
        TempSquad = ReservedPlayerZeds;
        ReservedPlayerZeds.Length = 0;
    }
    else
    {
        while( ReservedPlayerZeds.Length > NumWaitingZedPlayers )
        {
            TempSquad.AddItem( ReservedPlayerZeds[0] );
            ReservedPlayerZeds.Remove( 0, 1 );
        }
    }

    // No need to modify NumAISpawnsQueued as these zeds were already queued
    if( TempSquad.Length > 0 )
    {
        // Make sure squad doesn't exceed remaining AI
        while( TempSquad.Length > 0 && AIAliveCount + ReservedPlayerZeds.Length + TempSquad.Length > MyKFGRI.AIRemaining )
        {
            TempSquad.Remove( 0, 1 );
        }

        if( TempSquad.Length > 0 )
        {
            SpawnSquad( TempSquad, true );
        }
    }
}

/** Finds an AI zed to take over */
function FindTakeoverZed( KFPlayerControllerVersus KFPCV )
{
    local KFPawn_Monster KFPM;
    local Controller C;
    local bool bNextZed;
    local class<KFPawn_Monster> AliveClass;
    local int i;

    // Don't allow if this is not a normal wave
    if( !IsPlayerZedSpawnAllowed() )
    {
        return;
    }

    foreach WorldInfo.AllPawns( class'KFPawn_Monster', KFPM )
    {
        // Only try to take over zeds that are still valid for play
        if( !KFPM.CanTakeOver() )
        {
            continue;
        }

        // Only choose zeds that are not relatively close to players
        bNextZed = false;
        foreach WorldInfo.AllControllers( class'Controller', C )
        {
            if( !C.bIsPlayer || C.GetTeamNum() == 255 || C.Pawn == none || !C.Pawn.IsAliveAndWell() )
            {
                continue;
            }

            // Dist >= 8 meters
            if( VSizeSQ(C.Pawn.Location - KFPM.Location) < 640000.f )
            {
                bNextZed = true;
                break;
            }
        }

        // Skip if this zed was too close to a player
        if( bNextZed )
        {
            continue;
        }

        // Cache off class
        AliveClass = KFPM.class;

        for( i = 0; i < PlayerZedClasses.Length; ++i )
        {
            if( ClassIsChildOf(PlayerZedClasses[i], AliveClass) )
            {
                // Deal explosive damage, make them burst apart
                KFPM.TakeRadiusDamage( none, 100000, 1000, class'KFDT_Explosive_PlayerZedTakeover', 1, KFPM.Location, true, none );

                // Make sure this AI died
                if( KFPM == none || KFPM.Health <= 0 || KFPM.bPlayedDeath || KFPM.bPendingDelete || KFPM.bDeleteMe )
                {
                    KFPCV.PlayerZedSpawnInfo.PendingZedPawnClass = PlayerZedClasses[i];
                    KFPCV.PlayerZedSpawnInfo.PendingZedSpawnLocation = KFPM.Location;
                    KFPCV.HasSpawnedZeds[i] = true;

                    // Need to increment AI remaining, because killing the AI subtracted a zed
                    MyKFGRI.AIRemaining += 1;
					NumAIFinishedSpawning -= 1;
                }
                return;
            }
        }
    }
}

/** Spawn players into low-level zeds every set number of seconds */
function Timer_SpawnBossPlayerZeds()
{
    local KFPlayerController KFPC;
    local KFPlayerController BestPlayer, SecondBestPlayer;
    local int LivingPlayerCount;
    local float LongestSpawnTime, TimeSinceSpawn;
    local float RandomFloat;
    local bool bNeedRespawn;

    if( MyKFGRI.bMatchIsOver )
    {
        ClearTimer( nameOf(Timer_SpawnBossPlayerZeds), self );
        return;
    }

    LivingPlayerCount = GetLivingPlayerCount();

    // If there is already at least one player zed minion with 1 survivor left, early out
    if( LivingPlayerCount == 1 && GetMonsterAliveCount() > 1 )
    {
        return;
    }

    // Respawn the dead player zeds
    BestPlayer = none;
    bNeedRespawn = false;
    foreach WorldInfo.AllControllers( class'KFPlayerController', KFPC )
    {
        if( KFPC.GetTeamNum() != 255 || !KFPC.CanRestartPlayer() )
        {
            continue;
        }

        // Clear any pending zed class here
        KFPC.PlayerZedSpawnInfo.PendingZedPawnClass = none;

        if( KFPC.Pawn == none || !KFPC.Pawn.IsAliveAndWell() )
        {
            // If we're down to just one survivor, only spawn in two player zeds each boss spawn interval
            if( LivingPlayerCount == 1 )
            {
                // Pick the players that haven't spawned in the longest time
                TimeSinceSpawn = `TimeSince(KFPC.PlayerZedSpawnInfo.LastSpawnedTime);
                if( LongestSpawnTime == 0 || TimeSinceSpawn > LongestSpawnTime )
                {
                    LongestSpawnTime = TimeSinceSpawn;

                    // Keep the two players with the longest wait time since last spawn
                    SecondBestPlayer = BestPlayer;
                    BestPlayer = KFPC;

                    bNeedRespawn = true;
                }
            }
            else
            {
                RandomFloat = fRand();
                if( RandomFloat < 0.33f )
                {
                    KFPC.PlayerZedSpawnInfo.PendingZedPawnClass = PlayerZedClasses[AT_Crawler];
                }
                else if( RandomFloat < 0.66f )
                {
                    KFPC.PlayerZedSpawnInfo.PendingZedPawnClass = PlayerZedClasses[AT_SlasherClot];
                }
                else
                {
                    KFPC.PlayerZedSpawnInfo.PendingZedPawnClass = PlayerZedClasses[AT_GoreFast];
                }
                bNeedRespawn = true;
            }
        }
    }

    // Give our chosen player (if any) a zed class
    if( BestPlayer != none )
    {
        if( fRand() < 0.5f )
        {
            BestPlayer.PlayerZedSpawnInfo.PendingZedPawnClass = PlayerZedClasses[AT_SlasherClot];
        }
        else
        {
            BestPlayer.PlayerZedSpawnInfo.PendingZedPawnClass = PlayerZedClasses[AT_GoreFast];
        }

        if( SecondBestPlayer != none )
        {
            if( fRand() < 0.5f )
            {
                SecondBestPlayer.PlayerZedSpawnInfo.PendingZedPawnClass = PlayerZedClasses[AT_SlasherClot];
            }
            else
            {
                SecondBestPlayer.PlayerZedSpawnInfo.PendingZedPawnClass = PlayerZedClasses[AT_GoreFast];
            }
        }
    }

    // Respawn all of our player zeds
    if( bNeedRespawn )
    {
        RespawnZedHumanPlayers( none );
    }

    // Use our adjusted spawn time when only one survivor remains
    if( LivingPlayerCount == 1 )
    {
        SetTimer( FinalSurvivorBossSpawnPlayerInterval, false, nameOf(Timer_SpawnBossPlayerZeds), self );
    }
    else
    {
        SetTimer( BossSpawnPlayerInterval, false, nameOf(Timer_SpawnBossPlayerZeds), self );
    }
}

/** Recycles a player's pending zed pawn class back into the spawn rotation */
function RecyclePendingZedPawnClass( KFPlayerController KFPC )
{
    local int i;

    // Early out if there is no pending zed pawn class
    if( KFPC.PlayerZedSpawnInfo.PendingZedPawnClass == none )
    {
        return;
    }

    // Find matching AI zed pawn class
    for( i = 0; i < AIClassList.Length; ++i )
    {
        if( ClassIsChildOf(KFPC.PlayerZedSpawnInfo.PendingZedPawnClass, AIClassList[i]) )
        {
            ReservedPlayerZeds.AddItem( AIClassList[i] );
            break;
        }
    }
}

/** Spawns a player zed */
function bool RestartPlayerZed( KFPlayerController KFPC, KFSpawnVolume SpawnVolume )
{
    local vector SpawnLocation;
    local rotator SpawnRotation;

    // No spawning if the trader is open or the match is over
    if( !IsWaveActive() )
    {
        return false;
    }

    RestartPlayer( KFPC );
    if( KFPC.Pawn != none )
    {
        // Set spawn location
        SpawnLocation = ( !IsZero(KFPC.PlayerZedSpawnInfo.PendingZedSpawnLocation) )
            ? KFPC.PlayerZedSpawnInfo.PendingZedSpawnLocation
            : GetSpawnLocation( class<KFPawn_Monster>(KFPC.Pawn.Class), SpawnVolume );
        KFPC.SetLocation( SpawnLocation );
        KFPC.Pawn.SetLocation( SpawnLocation );

        // Set spawn rotation
        SpawnRotation = RotRand( false );
        SpawnRotation.Roll = 0;
        KFPC.SetRotation( SpawnRotation );
        SpawnRotation.Pitch = 0;
        KFPC.Pawn.SetRotation( SpawnRotation );

        // Init
        KFPC.ServerCamera( 'ThirdPerson' );
        KFPC.InitGameplayPostProcessFX();

        // Start fading in the camera
        KFPC.ClientSetCameraFade( true, MakeColor(255,255,255,255), vect2d(1.f, 0.f), 0.6f, true );

        // Clear pending spawn values
        KFPC.PlayerZedSpawnInfo.PendingZedPawnClass = none;
        KFPC.PlayerZedSpawnInfo.PendingZedSpawnLocation = vect(0,0,0);

        // Set our last spawned time
        KFPC.PlayerZedSpawnInfo.LastSpawnedTime = WorldInfo.TimeSeconds;

        return true;
    }

    return false;
}

/** General function to indicate whether normal wave player zed spawning is allowed */
protected function bool IsPlayerZedSpawnAllowed()
{
    return !MyKFGRIV.bTraderIsOpen && !MyKFGRIV.bMatchIsOver && !MyKFGRIV.bRoundIsOver && MyKFGRIV.WaveNum < MyKFGRIV.WaveMax;
}

/** Returns true if there is at least one zed player */
protected function bool HaveZedPlayers()
{
    local int i;

    // Iterating through PRIArray should be faster than AllControllers() since it doesn't need to go in and out of native,
    // and the PRI list is shorter by default due to AI not being included.
    for( i = 0; i < MyKFGRI.PRIArray.Length; ++i )
    {
        if( !MyKFGRI.PRIArray[i].bOnlySpectator && MyKFGRI.PRIArray[i].GetTeamNum() == 255 )
        {
            return true;
        }
    }

`if(`notdefined(ShippingPC))
    // If we have simulated zed players, allow spawning to continue
    return AISimulatedPlayerNum > 0;
`endif
    return false;
}

/** Retrieves the number of zed players */
protected function int GetNumWaitingZedPlayers()
{
    local KFPlayerControllerVersus KFPCV;
    local int NumWaiting;

    foreach WorldInfo.AllControllers( class'KFPlayerControllerVersus', KFPCV )
    {
        if( KFPCV.PlayerZedSpawnInfo.PendingZedPawnClass == none
                && KFPCV.GetTeamNum() == 255 && KFPCV.CanRestartPlayer()
                && (KFPCV.Pawn == none || !KFPCV.Pawn.IsAliveAndWell()) )
            {
                ++NumWaiting;
            }
    }

    return NumWaiting;
}

/** Retrieves the number of active (alive and well) zeds of class ZedClass */
protected function int GetNumActiveZedsOfClass( class<KFPawn_Monster> ZedClass )
{
    local KFPawn_Monster MonsterPawn;
    local int NumZeds;

    foreach WorldInfo.AllPawns( class'KFPawn_Monster', MonsterPawn )
    {
        if( !MonsterPawn.IsAliveAndWell() )
        {
            continue;
        }

        if( ClassIsChildOf(MonsterPawn.class, ZedClass) )
        {
            NumZeds++;
        }
    }

    return NumZeds;
}

/** Determines whether we have any zed players that can play as the boss */
protected function bool CanSpawnPlayerBoss()
{
    local KFPlayerControllerVersus KFPCV;

    // If we've already spawned in the boss, we already know that a boss player can spawn
    if( bBossSpawned )
    {
        return true;
    }

    foreach WorldInfo.AllControllers( class'KFPlayerControllerVersus', KFPCV )
    {
        if( KFPCV.GetTeamNum() == 255 && KFPCV.CanRestartPlayer()
            && (KFPCV.Pawn == none || !KFPCV.Pawn.IsAliveAndWell()) )
        {
            return true;
        }
    }

    return false;
}

function ResetSpawnManager()
{
    bBossSpawned = false;
    ReservedPlayerZeds.Length = 0;
}

DefaultProperties
{
    FinalSurvivorBossSpawnPlayerInterval=20.f
    EarlyWaveIndex=2
    MaxSpecialSquadRecycles=1
    // Slow down the early wave spawning in versus
    EarlyWaveSpawnRateModifier(0)=2.10 // 1.65 -> 2.10

    RecycleSpecialSquad.Empty
    RecycleSpecialSquad(0)=true
    bRecycleSpecialSquad=true
    bSpawnedSpecialSquad=false
    AdditionalSpecialSquadChancePerSpawn=0.1f

    MaxActivePlayerScrakes=2
    MaxActivePlayerFleshpounds=2

    // Added to slow stuff down for the late waves in VS kb
    LateWavesSpawnTimeModByPlayers(0)=1.8       // 1 player  1.2    //1.2
    LateWavesSpawnTimeModByPlayers(1)=1.7       // 2 players 1.2    //1.2
    LateWavesSpawnTimeModByPlayers(2)=1.6       // 3 players  1.2   //1.2
    LateWavesSpawnTimeModByPlayers(3)=1.5      // 4 players //1.09  //1.2
    LateWavesSpawnTimeModByPlayers(4)=1.17      // 5 players //0.82 //0.94
    LateWavesSpawnTimeModByPlayers(5)=1      // 6 players //0.65 //0.8

    // ---------------------------------------------
    // Wave settings
    DifficultyWaveSettings(0)={(Waves[0]=KFAIWaveInfo'GP_Spawning_ARCH.Versus.ZED_Wave1',
                                Waves[1]=KFAIWaveInfo'GP_Spawning_ARCH.Versus.ZED_Wave2',
                                Waves[2]=KFAIWaveInfo'GP_Spawning_ARCH.Versus.ZED_Wave3',
                                Waves[3]=KFAIWaveInfo'GP_Spawning_ARCH.Versus.ZED_Wave4',
                                Waves[4]=KFAIWaveInfo'GP_Spawning_ARCH.Versus.ZED_Boss')}
    PlayerZedWaves(0)=KFAIWaveInfo'GP_Spawning_ARCH.Versus.PlayerZED_Wave1'
    PlayerZedWaves(1)=KFAIWaveInfo'GP_Spawning_ARCH.Versus.PlayerZED_Wave2'
    PlayerZedWaves(2)=KFAIWaveInfo'GP_Spawning_ARCH.Versus.PlayerZED_Wave3'
    PlayerZedWaves(3)=KFAIWaveInfo'GP_Spawning_ARCH.Versus.PlayerZED_Wave4'

    // This is the maximum number of times special squads can be spawned in each wave
    MaxPlayerSpecialSquadSpawns(0)=0
    MaxPlayerSpecialSquadSpawns(1)=0
    MaxPlayerSpecialSquadSpawns(2)=2
    MaxPlayerSpecialSquadSpawns(3)=2

    // This is the fixed amount of time between player zed spawns
    PlayerZedSpawnInterval(0)=20.f //40 //25
    PlayerZedSpawnInterval(1)=27.f //40 //30
    PlayerZedSpawnInterval(2)=30.f //40 //35
    PlayerZedSpawnInterval(3)=35.f //40 //40
    BossSpawnPlayerInterval=40.f
    FirstWaveStartSpawnWaitTime=15.f // 20
    LaterWaveStartSpawnWaitTime=10.f //5

    // Normal
    SoloWaveSpawnRateModifier(0)={(RateModifier[0]=1.5,     // Wave 1
                                     RateModifier[1]=1.5,     // Wave 2
                                     RateModifier[2]=1.5,     // Wave 3
                                     RateModifier[3]=1.5)}    // Wave 4

    // Hard
    SoloWaveSpawnRateModifier(1)={(RateModifier[0]=1.5,     // Wave 1
                                     RateModifier[1]=1.5,     // Wave 2
                                     RateModifier[2]=1.5,     // Wave 3
                                     RateModifier[3]=1.5)}    // Wave 4

    // Suicidal
    SoloWaveSpawnRateModifier(2)={(RateModifier[0]=1.5,     // Wave 1
                                     RateModifier[1]=1.5,     // Wave 2
                                     RateModifier[2]=1.5,     // Wave 3
                                     RateModifier[3]=1.5)}    // Wave 4

    // Hell On Earth
    SoloWaveSpawnRateModifier(3)={(RateModifier[0]=1.0,     // Wave 1
                                     RateModifier[1]=1.0,     // Wave 2
                                     RateModifier[2]=1.0,     // Wave 3
                                     RateModifier[3]=1.0)}    // Wave 4

    // Reserved queue
    ReservedZedQueueLimit=5
}