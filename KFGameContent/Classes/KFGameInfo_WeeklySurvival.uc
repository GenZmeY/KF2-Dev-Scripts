//=============================================================================
// KFGameInfo_WeeklySurvival
//=============================================================================
// Weekly variant of survival with runtime adjusted rule sets.
//=============================================================================
// Killing Floor 2
// Copyright (C) 2017 Tripwire Interactive LLC
//  - Dan Weiss
//=============================================================================

class KFGameInfo_WeeklySurvival extends KFGameInfo_Survival;

/** Current frame booms */
var int CurrentFrameBooms;

/** Index of event to use as the default block */
var int ActiveEventIdx;

//-----------------------------------------------------------------------------
// Statics
static event class<GameInfo> SetGameType(string MapName, string Options, string Portal)
{
    local KFGameEngine KGE;

    KGE = KFGameEngine(class'Engine'.static.GetEngine());
    if (KGE != none)
    {
        //Valid index
        if (KGE.GetWeeklyEventIndex() >= 0)
        {
            return super.SetGameType(MapName, Options, Portal);
        }
    }

    //Invalid state, set to normal survival
    return class'KFGameInfo_Survival';
}

static function bool GametypeChecksDifficulty()
{
    return false;
}

static function bool GametypeChecksWaveLength()
{
    return false;
}

//-----------------------------------------------------------------------------
// Initialization

event InitGame( string Options, out string ErrorMessage )
{
	Super.InitGame(Options, ErrorMessage);

	//SetModifiedGameDifficulty();
    SetPickupItemList();
    SetZedTimeOverrides();
    SetSpawnPointOverrides();
    OutbreakEvent.SetWorldInfoOverrides();
}

event PreBeginPlay()
{
    super.PreBeginPlay();

	OutbreakEvent.UpdateGRI();

    if (Role == Role_Authority && MyKFGRI != none)
    {
        MyKFGRI.NotifyWeeklyEventIndex(ActiveEventIdx);
        if ( OutbreakEvent.ActiveEvent.bUnlimitedWeaponPickups)
        {
            MyKFGRI.NotifyBrokenTrader();
        }
    }
}

event PostBeginPlay()
{
	super.PostBeginPlay();

	if (OutbreakEvent.ActiveEvent.TimeBetweenWaves >= 0.f)
	{
		TimeBetweenWaves = OutbreakEvent.ActiveEvent.TimeBetweenWaves;
	}
}

function CreateOutbreakEvent()
{
	//The KFGameEngine at startup will store the week index of our current time
	//      Pull from there and figure out which event it corresponds to.
	//      The beginning of time to reset the loop can be changed in UKFGameEngine::UpdateTimedGameEvents

	local KFGameEngine KGE;

	super.CreateOutbreakEvent();

	KGE = KFGameEngine(class'Engine'.static.GetEngine());
	if (KGE != none)
	{
		ActiveEventIdx = KGE.GetWeeklyEventIndex() % OutbreakEvent.SetEvents.Length;
	}
	ActiveEventIdx = OutbreakEvent.SetActiveEvent(ActiveEventIdx);
}

function bool UsesModifiedDifficulty()
{
	return true;
}

function SetModifiedGameDifficulty()
{
	super.SetModifiedGameDifficulty();

	if (OutbreakEvent == none)
	{
		CreateOutbreakEvent();
	}
    //Set game difficulty.  super will create the intended DifficultyInfo object.
    MinGameDifficulty = OutbreakEvent.ActiveEvent.EventDifficulty;
    MaxGameDifficulty = OutbreakEvent.ActiveEvent.EventDifficulty;
	GameDifficulty = Clamp(GameDifficulty, MinGameDifficulty, MaxGameDifficulty);
}

//for difficulty override
function bool UsesModifiedLength()
{
	return true;
}

function SetModifiedGameLength()
{
    GameLength = OutbreakEvent.ActiveEvent.GameLength;
}

/** Allow for updates to various game systems if we have an override allowable item list */
function SetPickupItemList()
{
    local STraderItem TraderItem;
    local KFPickupFactory_Item ItemFactory;
    local int Idx;
    
    if (MyKFGRI.IsGunGameMode())
    {
        foreach AllActors(class'KFPickupFactory_Item', ItemFactory)
        {
            for (Idx = ItemFactory.ItemPickups.Length - 1; Idx >= 0; --Idx)
            {
                if (ItemFactory.ItemPickups[Idx].ItemClass.Name != 'KFInventory_Armor')
                {
                    ItemFactory.ItemPickups.Remove(Idx, 1);
                }
            }
        }

        return;
    }

    //If we have an override weapon list, it's not enough to block trader and default inventory.
    //      Iterate through the item pickups in the map to trim their lists as well.
    if (OutbreakEvent.ActiveEvent.TraderWeaponList != none)
    {
        //So many loops
        foreach AllActors(class'KFPickupFactory_Item', ItemFactory)
        {
            //we dont want item pickups, so kiss them goodbye
            if(OutbreakEvent.ActiveEvent.OverrideItemPickupModifier == 0)
            {
                ItemFactory.ShutDown();
                ItemFactory.ItemPickups.Remove(0, ItemFactory.ItemPickups.Length);
                continue;
            }

            foreach OutbreakEvent.ActiveEvent.TraderWeaponList.SaleItems(TraderItem)
            {
                for (Idx = ItemFactory.ItemPickups.Length - 1; Idx >= 0; --Idx)
                {
                    if (ItemFactory.ItemPickups[Idx].ItemClass.Name != TraderItem.ClassName)
                    {
                        ItemFactory.ItemPickups.Remove(Idx, 1);
                    }
                }
            }
        }
    }
}

function SetZedTimeOverrides()
{
    if (ZedTimeSlomoScale != OutbreakEvent.ActiveEvent.OverrideZedTimeSlomoScale)
    {
        ZedTimeSlomoScale = OutbreakEvent.ActiveEvent.OverrideZedTimeSlomoScale;
    }
}

function SetSpawnPointOverrides()
{
    local KFSpawnVolume KFSV;

    foreach WorldInfo.AllActors(class'KFSpawnVolume', KFSV)
    {
        if (OutbreakEvent.ActiveEvent.OverrideSpawnDerateTime >= 0.f)
        {
            KFSV.SpawnDerateTime = OutbreakEvent.ActiveEvent.OverrideSpawnDerateTime;
        }

        if (OutbreakEvent.ActiveEvent.OverrideTeleportDerateTime >= 0.f)
        {
            KFSV.TeleportDerateTime = OutbreakEvent.ActiveEvent.OverrideTeleportDerateTime;
        }
    }
}

/** Enable some hax to permanently be in zed time */
function SetPermanentZedTime()
{
    local KFPlayerController KFPC;
    if (OutbreakEvent.ActiveEvent.bPermanentZedTime)
    {
        ZedTimeRemaining = 999999.f;
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

//Do a reset on the permanent zed time.  Leaves us in zed time, but puts valid players into the partial mode.
function ResetPermanentZed()
{
    local KFPlayerController KFPC;
    local KFPawn KFP;

    foreach WorldInfo.AllControllers(class'KFPlayerController', KFPC)
    {
        KFP = KFPawn(KFPC.Pawn);
        if (KFPC != none && KFP != none)
        {
            KFP.bUnaffectedByZedTime = !KFPC.IsAffectedByZedTime();
            if (KFP.bUnaffectedByZedTime)
            {
                KFPC.StartPartialZedTimeSightCounter();
            }
            KFPC.ClientEnterZedTime(KFP.bUnaffectedByZedTime);
        }
    }
}

function float GetAdjustedAIDoshValue( class<KFPawn_Monster> MonsterClass )
{
    if (!OutbreakEvent.ActiveEvent.bBossRushMode)
    {
	    return super.GetAdjustedAIDoshValue(MonsterClass) * OutbreakEvent.ActiveEvent.DoshOnKillGlobalModifier;
    }
    else
    {
        if ((WaveNum-1) < OutbreakEvent.ActiveEvent.BossRushOverrideParams.PerWaves.length)
        {
            return super.GetAdjustedAIDoshValue(MonsterClass) * OutbreakEvent.ActiveEvent.BossRushOverrideParams.PerWaves[WaveNum-1].DoshOnKillGlobalModifier;
        }
    }

    return super.GetAdjustedAIDoshValue(MonsterClass);
}

protected function ScoreMonsterKill( Controller Killer, Controller Monster, KFPawn_Monster MonsterPawn )
{
    super.ScoreMonsterKill(Killer, Monster, MonsterPawn);

	if(OutbreakEvent.ActiveEvent.bHealAfterKill)
    {
        if( MonsterPawn != none && MonsterPawn.DamageHistory.Length > 0 )
        {
            if(OutbreakEvent.ActiveEvent.bHealWithHeadshot)
            {
                if (MonsterPawn.LastHitZoneIndex == HZI_HEAD)
                {
                    HealAfterKilling( MonsterPawn, Killer, false );
                }
            }
            else
            {
                HealAfterKilling( MonsterPawn, Killer );
            }
        }
	}

    if (OutbreakEvent.ActiveEvent.bGunGameMode)
    {
        GunGameScoreAssistanceAfterKilling(MonsterPawn, Killer);
    }
}


/** Heal players after a Zed was killed, based in more heal to the player that was the killer and less heal to the players that damaged the Zed */
function HealAfterKilling(KFPawn_Monster MonsterPawn , Controller Killer, optional bool bGivePowerUp = true)
{
	local int i;
    local int j;
	local KFPlayerController KFPC;
	local KFPlayerReplicationInfo DamagerKFPRI;
    local array<DamageInfo> DamageHistory;
    local array<KFPlayerController> Attackers;
    local KFPawn_Human PawnHuman;
    local KFGameInfo KFGI;
    
    DamageHistory = MonsterPawn.DamageHistory;
    
    KFGI = KFGameInfo(WorldInfo.Game);
	
	for ( i = 0; i < DamageHistory.Length; i++ )
	{
		if( DamageHistory[i].DamagerController != none
			&& DamageHistory[i].DamagerController.bIsPlayer
			&& DamageHistory[i].DamagerPRI.GetTeamNum() == 0
			&& DamageHistory[i].DamagerPRI != none )
		{
			DamagerKFPRI = KFPlayerReplicationInfo(DamageHistory[i].DamagerPRI);
			if( DamagerKFPRI != none )
			{
                KFPC = KFPlayerController(DamagerKFPRI.Owner);
                if( KFPC != none )
                {
                    if(Attackers.Find(KFPC) < 0)
                    {
                    	PawnHuman = KFPawn_Human(KFPC.Pawn);
                        Attackers.AddItem(KFPC);

                        /*
                            Weekly event Aracnophobia (10):
                            2 kind of heales: one for killing and another for killing by jumping on enemies.
                            HealByAssistance is used for the latest, no need to add extra variables.
                         */
                        if( KFPC == Killer && KFGI != none && KFGI.OutbreakEvent.ActiveEvent.bGoompaJumpEnabled )
                        {
                            for (j = 0; j < DamageHistory[i].DamageTypes.Length; j++)
                            {
                                if (DamageHistory[i].DamageTypes[j] == class 'KFDT_GoompaStomp')
                                {
                                    PawnHuman.HealDamageForce(MonsterPawn.HealByAssistance, KFPC, class'KFDT_Healing', false, false );
                                    return;
                                }
                            }

                            PawnHuman.HealDamageForce(MonsterPawn.HealByKill, KFPC, class'KFDT_Healing', false, false );
                            return;
                        }
                        //

                        if( KFPC == Killer )
                        {
            				PawnHuman.HealDamageForce(MonsterPawn.HealByKill, KFPC, class'KFDT_Healing', false, false );
                            
                            if( bGivePowerUp && ( KFPawn_ZedFleshpound(MonsterPawn) != none || KFPawn_ZedScrake(MonsterPawn) != none ))
                            {
                                KFPC.ReceivePowerUp(class'KFPowerUp_HellishRage_NoCostHeal');
                            }
                        }
                        else
                        {
            				PawnHuman.HealDamageForce(MonsterPawn.HealByAssistance, KFPC, class'KFDT_Healing', false, false );
                        }
                    }
				}
			}
		}
	}
}

function GunGameScoreAssistanceAfterKilling(KFPawn_Monster MonsterPawn , Controller Killer)
{
    local int i;
    local KFPlayerController_WeeklySurvival KFPC_WS;
    local array<DamageInfo> DamageHistory;
    local KFPlayerReplicationInfo DamagerKFPRI;
    local array<KFPlayerController> Attackers;

    DamageHistory = MonsterPawn.DamageHistory;

 	for (i = 0; i < DamageHistory.Length; i++)
	{
		if (DamageHistory[i].DamagerController != none
			&& DamageHistory[i].DamagerController.bIsPlayer
			&& DamageHistory[i].DamagerPRI.GetTeamNum() == 0
			&& DamageHistory[i].DamagerPRI != none)
		{
			DamagerKFPRI = KFPlayerReplicationInfo(DamageHistory[i].DamagerPRI);
			if (DamagerKFPRI != none)
			{
                KFPC_WS = KFPlayerController_WeeklySurvival(DamagerKFPRI.Owner);
                if (KFPC_WS != none && KFPC_WS != Killer)
                {
                    if (Attackers.Find(KFPC_WS) < 0)
                    {
                    	Attackers.AddItem(KFPC_WS);

                        if (KFPC_WS.Pawn.Health > 0)
                        {
                            KFPC_WS.GunGameData.Score += MonsterPawn.GunGameAssistanceScore;
                            UpdateGunGameLevel(KFPC_WS);
                        }
                    }
                }
            }
        }
    }
}

function StartMatch()
{
    super.StartMatch();

    if (OutbreakEvent.ActiveEvent.bForceWWLMusic)
    {
        ForceWWLMusicTrack();
    }
}

function CreateDifficultyInfo(string Options)
{
    super.CreateDifficultyInfo(Options);

    //If we want to use custom weapon respawn times, set them here
    if (OutbreakEvent.ActiveEvent.bUseOverrideItemRespawnTime)
    {
        DifficultyInfo.NumPlayers_WeaponPickupRespawnTime = OutbreakEvent.ActiveEvent.OverrideItemRespawnTime;
    }

    //If we want to use custom ammo respawn times, set them here
    if (OutbreakEvent.ActiveEvent.bUseOverrideAmmoRespawnTime)
    {
        DifficultyInfo.NumPlayers_AmmoPickupRespawnTime = OutbreakEvent.ActiveEvent.OverrideAmmoRespawnTime;
    }
}

event PostLogin( PlayerController NewPlayer )
{
    local KFPlayerController_WeeklySurvival KFPC_WS;
    local KFPawn_Customization KFCustomizePawn;

    super.PostLogin(NewPlayer);

    KFPC_WS = KFPlayerController_WeeklySurvival(NewPlayer);
    if (KFPC_WS != none)
    {
        KFPC_WS.bUsingPermanentZedTime = OutbreakEvent.ActiveEvent.bPermanentZedTime;
        KFPC_WS.ZedTimeRadius = OutbreakEvent.ActiveEvent.ZedTimeRadius * OutbreakEvent.ActiveEvent.ZedTimeRadius;
        KFPC_WS.ZedTimeBossRadius = OutbreakEvent.ActiveEvent.ZedTimeBossRadius * OutbreakEvent.ActiveEvent.ZedTimeBossRadius;
        KFPC_WS.ZedTimeHeight = OutbreakEvent.ActiveEvent.ZedTimeHeight;
        KFPC_WS.ZedRecheckTime = OutbreakEvent.ActiveEvent.PermanentZedResetTime;

        //Handle any visual-related things for customization pawn so the pregame lobby has the fun things
        KFCustomizePawn = KFPawn_Customization(KFPC_WS.Pawn);
        if (KFCustomizePawn != none)
        {
            KFCustomizePawn.IntendedHeadScale = OutbreakEvent.ActiveEvent.PlayerSpawnHeadScale;
            KFCustomizePawn.SetHeadScale(KFCustomizePawn.IntendedHeadScale, KFCustomizePawn.CurrentHeadScale);
        }
    }

    LoadGunGameWeapons(NewPlayer);
}

function SetBossIndex()
{
	local BossSpawnReplacement Replacement;
	local int ReplaceIdx;
    local int i;

    // Ignore normal events.
    if (OutbreakEvent.ActiveEvent.bBossRushMode)
    {
        if (BossRushEnemies.length == 0)
        {
            for(i=0; i < default.AIBossClassList.length; ++i)
            {
                BossRushEnemies.AddItem(i);
            }
        }
    }

    BossIndex = Rand(default.AIBossClassList.Length);

    //Search in the replacement list for the one that the game type wanted to use
    //		If we find it, grab the appropriate index into the original AI class list
    //		so we can properly cache it.
    foreach OutbreakEvent.ActiveEvent.BossSpawnReplacementList(Replacement)
    {
        if (Replacement.SpawnEntry == BossIndex)
        {
            ReplaceIdx = AIBossClassList.Find(Replacement.NewClass);
            if (ReplaceIdx != INDEX_NONE)
            {
                BossIndex = ReplaceIdx;
                break;
            }
        }
    }

	MyKFGRI.CacheSelectedBoss(BossIndex);
}

//-----------------------------------------------------------------------------
// Ticking
function Tick(float DeltaTime)
{
    CurrentFrameBooms = 0;
    super.Tick(DeltaTime);
}

function TickZedTime( float DeltaTime )
{
    super.TickZedTime(DeltaTime);

    //If we're in permanent mode with a valid wave, set remaining time to a stupid value to stay in zed time
    if (OutbreakEvent.ActiveEvent.bPermanentZedTime && IsWaveActive())
    {
        //Keep up the timer if we have enough zeds left or it's a boss phase
        if (MyKFGRI.AIRemaining > OutbreakEvent.ActiveEvent.PermanentZedTimeCutoff || WaveNum == WaveMax)
        {
            ZedTimeRemaining = 999999.f;
        }
        //Else start the fade back to normal
        else if (ZedTimeRemaining > ZedTimeBlendOutTime)
        {
            ZedTimeRemaining = ZedTimeBlendOutTime;
            ClearZedTimePCTimers();
        }
    }
}

function WaveEnded(EWaveEndCondition WinCondition)
{
    local KFPawn_Human Pawn;
    local bool bWasFirstTime;
    
    // This function is called multiple times in a row. Only apply it once.
    bWasFirstTime = bWaveStarted;

    // Choose new perk before the end of wave message triggers in supper. 
    if (MyKFGRI.IsRandomPerkMode() && WinCondition == WEC_WaveWon)
    {
        ChooseRandomPerks();
    }

    super.WaveEnded(WinCondition);

    if (OutbreakEvent.ActiveEvent.bPermanentZedTime && ZedTimeRemaining > ZedTimeBlendOutTime)
    {
        ClearZedTimePCTimers();
        ZedTimeRemaining = ZedTimeBlendOutTime;
    }

    if (OutbreakEvent.ActiveEvent.bHealPlayerAfterWave)
    {
        foreach WorldInfo.AllPawns(class'KFPawn_Human', Pawn)
	    {
		    Pawn.Health = Pawn.HealthMax;
	    }
    }

    if (WinCondition == WEC_WaveWon && bWasFirstTime)
    {
        GrantExtraDoshOnWaveWon();
    }

    DisableGlobalDamage();
}

/** Grant dosh to every player even no matter it's state when a wave is won. */
function GrantExtraDoshOnWaveWon()
{
    local KFPlayerController KFPC;
    local int ExtraDosh;
    //
    if (OutbreakEvent.ActiveEvent.bBossRushMode && (WaveNum-1) < OutbreakEvent.ActiveEvent.BossRushOverrideParams.PerWaves.length)
    {
        ExtraDosh = OutbreakEvent.ActiveEvent.BossRushOverrideParams.PerWaves[WaveNum-1].ExtraDoshGrantedonWaveWon;
        foreach WorldInfo.AllControllers(class'KFPlayerController', KFPC)
	    {
            KFPlayerReplicationInfo(KFPC.PlayerReplicationInfo).AddDosh(ExtraDosh, true);
        }
    }
}

function ClearZedTimePCTimers()
{
    local KFPlayerController_WeeklySurvival KFPC;

    foreach AllActors(class'KFPlayerController_WeeklySurvival', KFPC)
    {
        KFPC.ClearTimer('RecheckZedTime');
    }
}

//-----------------------------------------------------------------------------
// Completion
function EndOfMatch(bool bVictory)
{
    local KFPlayerController KFPC;

    if (bVictory)
    {
        foreach WorldInfo.AllControllers(class'KFPlayerController', KFPC)
		{
			KFPC.CompletedWeeklySurvival();
		}
    }

    super.EndOfMatch(bVictory);
}

function StartWave()
{
    super.StartWave();

    // Stop Global Damage for boss wave
    if (!OutbreakEvent.ActiveEvent.bApplyGlobalDamageBossWave && WaveNum == WaveMax)
    {
        DisableGlobalDamage();
    }
    // In case there was a previous boss wave. Not sure if possible
    else if (OutbreakEvent.ActiveEvent.GlobalDamageTickRate > 0.f && OutbreakEvent.ActiveEvent.GlobalDamageTickAmount > 0.f)
    {
        if(!IsTimerActive('EnableGlobalDamage', self))
        {
            SetTimer(OutbreakEvent.ActiveEvent.DamageDelayAfterWaveStarted, false, 'EnableGlobalDamage', self);
        }

            // Check if we are in the zed frustration time to stop applying damage
        SetTimer(1.0f, true, 'CheckForZedFrustrationMode', self);
    }

    if (OutbreakEvent.ActiveEvent.bPermanentZedTime)
    {
        //If we're a boss wave, wait until the camera animation is going
        if (WaveNum == WaveMax)
        {
            SetTimer(0.25f, true, nameof(BossCameraZedTimeRecheck));
        }
        else
        {
            //Enable permanent zed time
            SetPermanentZedTime();
        }
    }

    if (OutbreakEvent.ActiveEvent.AdditionalBossWaveInfo != none && WaveNum == WaveMax)
    {
        SetTimer(OutbreakEvent.ActiveEvent.AdditionalBossWaveStartDelay, true, nameof(SpawnBossWave));
    }

    if (OutbreakEvent.ActiveEvent.bUnlimitedWeaponPickups)
    {
        OverridePickupList();
    }
}

function bool OverridePickupList()
{
    local KFPickupFactory PickupFactory;
    local KFPickupFactory_Item ItemFactory;
    local KFGameReplicationInfo_WeeklySurvival KFGRI_WS;

    KFGRI_WS=KFGameReplicationInfo_WeeklySurvival(MyKFGRI);
    if (KFGRI_WS == none)
        return false;

    foreach ItemPickups(PickupFactory)
    {
        ItemFactory = KFPickupFactory_Item(PickupFactory);

        if (ItemFactory == none)
            continue;
        
        KFGRI_WS.OverrideWeaponPickups(ItemFactory);
        ItemFactory.OverridePickup();
    }

    return true;
}

function EnableGlobalDamage()
{
    MyKFGRI.SetGlobalDamage(true);
    SetTimer(OutbreakEvent.ActiveEvent.GlobalDamageTickRate, true, 'ApplyGlobalDamage', OutbreakEvent);
}

function DisableGlobalDamage()
{
    MyKFGRI.SetGlobalDamage(false);

    if (IsTimerActive('ApplyGlobalDamage', OutbreakEvent))
    {
        ClearTimer('ApplyGlobalDamage', OutbreakEvent);
    }

    if (IsTimerActive('EnableGlobalDamage', self))
    {
        ClearTimer('EnableGlobalDamage', self);
    }
}

function CheckForZedFrustrationMode()
{
    if(IsTimerActive('ApplyGlobalDamage', OutbreakEvent))
    {
        if(class'KFAIController'.default.FrustrationThreshold > 0 && MyKFGRI.AIRemaining <= class'KFAIController'.default.FrustrationThreshold)
        {
            DisableGlobalDamage();
            ClearTimer('CheckForZedFrustrationMode', self);
        }
    }
}

function BossCameraZedTimeRecheck()
{
    local KFPawn_Monster KFM;
    local KFInterface_MonsterBoss BossRef;

    foreach WorldInfo.AllPawns(class'KFPawn_Monster', KFM)
    {
        if (KFM.static.IsABoss())
        {
            BossRef = KFInterface_MonsterBoss(KFM);
            if (BossRef != none)
            {
                if (BossRef.UseAnimatedBossCamera())
                {
                    return;
                }
                //We have a boss that isn't animating.  Go ahead and start zed time
                else
                {
                    ClearTimer(nameof(BossCameraZedTimeRecheck));
                    SetPermanentZedTime();
                }
            }
        }
    }
}

//Hijack existing boss summon functionality to spawn extra boss wave
function SpawnBossWave()
{
    SetTimer(OutbreakEvent.ActiveEvent.AdditionalBossWaveFrequency, false, nameof(SpawnBossWave));
    SpawnManager.SummonBossMinions(OutbreakEvent.ActiveEvent.AdditionalBossWaveInfo.Squads, GetAdditionalBossSpawns());

    if (!OutbreakEvent.ActiveEvent.bContinuousAdditionalBossWave)
    {
        //Arbitrary time, but delay a bit for spawns to go through, then cut off additional boss wave spawning til next timer hit
        SetTimer(2.f, false, nameof(PauseAdditionalBossWaves));
    }
}

function PauseAdditionalBossWaves()
{
    SpawnManager.StopSummoningBossMinions();
}

function byte GetAdditionalBossSpawns()
{
    return byte(Lerp(OutbreakEvent.ActiveEvent.AdditionalBossSpawnCount.X, OutbreakEvent.ActiveEvent.AdditionalBossSpawnCount.Y,fMax(NumPlayers, 1) / float(MaxPlayers)));
}

function OpenTrader()
{
    //If we're in permanent zed time, disable it for trader time
    if (OutbreakEvent.ActiveEvent.bPermanentZedTime && ZedTimeRemaining > ZedTimeBlendOutTime)
    {
        ClearZedTimePCTimers();
        ZedTimeRemaining = ZedTimeBlendOutTime;
    }

    if (!OutbreakEvent.ActiveEvent.bDisableTraders)
    {
        super.OpenTrader();
    }
    else if (KFGameReplicationInfo(GameReplicationInfo) != none)
    {
        KFGameReplicationInfo(GameReplicationInfo).StartScavengeTime(TimeBetweenWaves);
    }
}

function SetupNextTrader()
{
    if (!OutbreakEvent.ActiveEvent.bDisableTraders)
    {
        super.SetupNextTrader();
    }
}

State TraderOpen
{
	function BeginState( Name PreviousStateName )
	{
        super.BeginState(PreviousStateName);

        //Adding the call here.  Whether or not super gets called is based on ActiveEvent flag.
        ResetAllPickups();
    }
}

function InitAllPickups()
{
    super.InitAllPickups();

    //If this event is trying to do things to the pickup count, redo the init functionality
    if (OutbreakEvent.ActiveEvent.OverrideItemPickupModifier >= 0.f || OutbreakEvent.ActiveEvent.OverrideAmmoPickupModifier >= 0.f)
    {
        NumWeaponPickups = ItemPickups.Length * (OutbreakEvent.ActiveEvent.OverrideItemPickupModifier >= 0.f ? OutbreakEvent.ActiveEvent.OverrideItemPickupModifier : DifficultyInfo.GetItemPickupModifier());
		NumAmmoPickups = AmmoPickups.Length * (OutbreakEvent.ActiveEvent.OverrideAmmoPickupModifier >= 0.f ? OutbreakEvent.ActiveEvent.OverrideAmmoPickupModifier : DifficultyInfo.GetAmmoPickupModifier());

`if(`__TW_SDK_)
	if( BaseMutator != none )
	{
		BaseMutator.ModifyPickupFactories();
	}
`endif

        ResetAllPickups();
    }
}

function ResetAllPickups()
{
    local bool bCallReset;

    bCallReset = false;
    switch(OutbreakEvent.ActiveEvent.PickupResetTime)
    {
    case PRS_Wave:
        bCallReset = IsWaveActive();
        break;
    case PRS_Trader:
        bCallReset = !IsWaveActive();
        break;
    case PRS_WaveAndTrader:
        bCallReset = true;
        break;
    case PRS_Never:
        bCallReset = false;
        break;
    }

    if (bCallReset)
    {
        super.ResetAllPickups();
    }
}

function ResetPickups( array<KFPickupFactory> PickupList, int NumPickups )
{
    //If we're resetting ammo and in an ammo list, use that modifier
    if (OutbreakEvent.ActiveEvent.WaveAmmoPickupModifiers.Length >= WaveMax && KFPickupFactory_Ammo(PickupList[0]) != none)
    {
        NumPickups *= OutbreakEvent.ActiveEvent.WaveAmmoPickupModifiers[WaveNum];
        super(KFGameInfo).ResetPickups(PickupList, NumPickups);
    }
    //If we're resetting items and in an item list, use that modifier
    else if (OutbreakEvent.ActiveEvent.WaveItemPickupModifiers.Length >= WaveMax && KFPickupFactory_Item(PickupList[0]) != none)
    {
        NumPickups *= OutbreakEvent.ActiveEvent.WaveItemPickupModifiers[WaveNum];
        if(OutbreakEvent.ActiveEvent.OverrideItemPickupModifier == 0) NumPickups = 0;
        super(KFGameInfo).ResetPickups(PickupList, NumPickups);
    }
    //Otherwise, use normal path
    else
    {
        super.ResetPickups(PickupList, NumPickups);
    }
}

//-----------------------------------------------------------------------------
// Spawning

/** Allow specific game type to override the spawn class.  Default implementation returns from the AI class list. */
function class<KFPawn_Monster> GetAISpawnType(EAIType AIType)
{
    if (WaveNum < WaveMax || OutbreakEvent.ActiveEvent.bAllowSpawnReplacementDuringBossWave)
    {
        return OutbreakEvent.GetAISpawnOverrirde(AIType);
    }

    //No override, return default
    return AIClassList[AIType];
}

/** Whether or not a specific primary weapon is allowed.  Called at player spawn time while setting inventory. */
function bool AllowPrimaryWeapon(string ClassPath)
{
    local STraderItem Item;

    if (OutbreakEvent.ActiveEvent.SpawnWeaponList != none)
    {
        foreach OutbreakEvent.ActiveEvent.SpawnWeaponList.SaleItems(Item)
        {
            if ( name(Item.WeaponDef.default.WeaponClassPath) == name(ClassPath) )
            {
                return true;
            }
        }    
        return false;
    }
    return true;
}

/** Whether or not a specific secondary weapon is allowed.  Called at player spawn time while setting inventory. */
function bool AllowSecondaryWeapon(string ClassPath)
{
    local STraderItem Item;
    if (OutbreakEvent.ActiveEvent.SpawnWeaponList != none && OutbreakEvent.ActiveEvent.bSpawnWeaponListAffectsSecondaryWeapons)
    {
        foreach OutbreakEvent.ActiveEvent.SpawnWeaponList.SaleItems(Item)
        {
            if ( name(Item.WeaponDef.default.WeaponClassPath) == name(ClassPath) )
            {
                return true;
            }
        }
        return false;
    }
    return true;
}

/** Allows gametype to adjust starting grenade count.  Called at player spawn time from GiveInitialGrenadeCount in the inventory. */
function int AdjustStartingGrenadeCount(int CurrentCount)
{
    if (OutbreakEvent.ActiveEvent.bDisableGrenades)
    {
        return 0;
    }
    return CurrentCount;
}

/** Allows gametype to validate a perk for the current match */
function bool IsPerkAllowed(class<KFPerk> PerkClass)
{
	Local int index;

	if(OutbreakEvent.ActiveEvent.PerksAvailableList.length == 0)
	{
		return true;
	}

	for( index=0 ; index<OutbreakEvent.ActiveEvent.PerksAvailableList.length ; index++)
	{
		if(OutbreakEvent.ActiveEvent.PerksAvailableList[index] == PerkClass)
		{
			return true;
		}
	}

    return false;
}

function LoadGunGameWeapons(Controller NewPlayer)
{
    local int i, RandomNumber;
    local KFPlayerController_WeeklySurvival KFPC_WS;
    local class<Inventory> InventoryClass;
    local Inventory Inv;
    local KFWeapon Weapon;

    // Deactivated preload in console version

    if (OutbreakEvent.ActiveEvent.bGunGameMode && WorldInfo.IsConsoleBuild() == false)
    {
        KFPC_WS = KFPlayerController_WeeklySurvival(NewPlayer);

        if (KFPC_WS == none)
        {
            return;
        }
         
        for (i=0; i < OutbreakEvent.ActiveEvent.GunGamePerksData.GunGameLevels.Length; i++)
        {                   
            RandomNumber = Rand(OutbreakEvent.ActiveEvent.GunGamePerksData.GunGameLevels[i].GrantedWeapons.Length);

            KFPC_WS.GunGameData.GunGamePreselectedWeapons.AddItem(RandomNumber);

            InventoryClass = class<KFWeapon> (DynamicLoadObject(OutbreakEvent.ActiveEvent.GunGamePerksData.GunGameLevels[i].GrantedWeapons[RandomNumber].default.WeaponClassPath, class'Class'));
            Inv = KFPC_WS.Pawn.InvManager.CreateInventory(InventoryClass, true);

            if (Inv != none)
            {
                Weapon = KFWeapon(Inv);
                if (Weapon != none)
                {
                    Weapon.RemoveGun();
                }
            }
        }  
    }
}

function RestartPlayer(Controller NewPlayer)
{
	local KFPawn_Human KFPH;

    super.RestartPlayer(NewPlayer);

	KFPH = KFPawn_Human(NewPlayer.Pawn);

    OutbreakEvent.AdjustRestartedPlayer(KFPH);
}

function RestartGunGamePlayerWeapon(KFPlayerController_WeeklySurvival KFPC_WS, byte WaveToUse)
{
    local byte i;
    local int CurrentGunGameWaveLevel;

	super.RestartGunGamePlayerWeapon(KFPC_WS, WaveToUse);

    ResetGunGame(KFPC_WS);

    CurrentGunGameWaveLevel = -1;

    // Find wave level, the data needs to be ordered

	for (i = 0; i < OutbreakEvent.ActiveEvent.GunGamePerksData.GunGameRespawnLevels.Length; i++)
    {
        if (WaveToUse >= OutbreakEvent.ActiveEvent.GunGamePerksData.GunGameRespawnLevels[i].Wave)
        {
            CurrentGunGameWaveLevel = OutbreakEvent.ActiveEvent.GunGamePerksData.GunGameRespawnLevels[i].Level - 1;
        }
    }

    // If any level we force gun game update

    if (CurrentGunGameWaveLevel >= 0)
    {
        KFPC_WS.GunGameData.Score = OutbreakEvent.ActiveEvent.GunGamePerksData.GunGameLevels[CurrentGunGameWaveLevel].RequiredScore;

        UpdateGunGameLevel(KFPC_WS);
    }
}

function DoDeathExplosion(Pawn DeadPawn, KFGameExplosion ExplosionTemplate, class<KFPawn> ExplosionIgnoreClass)
{
    local KFExplosionActorReplicated ExploActor;

    if (CurrentFrameBooms < OutbreakEvent.ActiveEvent.MaxBoomsPerFrame)
    {
        ExploActor = Spawn(class'KFExplosionActorReplicated', DeadPawn, , DeadPawn.Location);
        if (ExploActor != none)
        {
            ExploActor.InstigatorController = DeadPawn.Controller;
            ExploActor.Instigator = DeadPawn;
            ExploActor.Attachee = DeadPawn;
            ExplosionTemplate.ActorClassToIgnoreForDamage = ExplosionIgnoreClass;
            ExploActor.Explode(ExplosionTemplate, vect(0, 0, 1));
            ++CurrentFrameBooms;
        }
    }
}

simulated function AddWeaponsFromSpawnList(KFPawn P)
{
    local STraderItem Item;

    if (OutbreakEvent.ActiveEvent.SpawnWeaponList != none || OutbreakEvent.ActiveEvent.bAddSpawnListToLoadout)
    {
        foreach OutbreakEvent.ActiveEvent.SpawnWeaponList.SaleItems(Item)
        {
            P.DefaultInventory.AddItem(class<Weapon>(DynamicLoadObject(Item.WeaponDef.default.WeaponClassPath, class'Class')));
        }    
    }
}

simulated function OverrideHumanDefaults(KFPawn_Human P)
{
    if (OutbreakEvent.ActiveEvent.JumpZ >= 0.0f)
    {
        P.JumpZ = OutbreakEvent.ActiveEvent.JumpZ;
    }
}

simulated function ModifyDamageGiven(out int InDamage, optional Actor DamageCauser, optional KFPawn_Monster MyKFPM, optional KFPlayerController DamageInstigator, optional class<KFDamageType> DamageType, optional int HitZoneIdx )
{
    local KFPlayerController_WeeklySurvival KFPC;
    local int Streak;

    if (OutbreakEvent.ActiveEvent.bGoompaJumpEnabled)
    {
        KFPC = KFPlayerController_WeeklySurvival(DamageInstigator);
        if (KFPC != none)
        {
            Streak = KFPC.GoompaStreakBonus < KFPC.MaxGoompaStreak ? KFPC.GoompaStreakBonus : KFPC.MaxGoompaStreak;
            InDamage *= (1 + OutbreakEvent.ActiveEvent.GoompaStreakDamage * Streak);
        }
    }
}

/*
 *  Gun Game
 */

function ResetGunGame(KFPlayerController_WeeklySurvival KFPC_WS)
{
    KFPC_WS.GunGameData.Score = 0;
    KFPC_WS.GunGameData.Level = 0;

    KFPC_WS.UpdateGunGameWidget(0, OutbreakEvent.ActiveEvent.GunGamePerksData.GunGameLevels[0].RequiredScore, 0, OutbreakEvent.ActiveEvent.GunGamePerksData.GunGameLevels.Length); 
}

function NotifyKilled(Controller Killer, Controller Killed, Pawn KilledPawn, class<DamageType> damageType )
{
    local KFPawn_Monster KFPM;
    local KFPlayerController_WeeklySurvival KFPC_WS_Killer, KFPC_WS_Killed;
    
    super.NotifyKilled(Killer, Killed, KilledPawn, damageType);

    KFPM            = KFPawn_Monster(KilledPawn);
    KFPC_WS_Killer  = KFPlayerController_WeeklySurvival(Killer);
    KFPC_WS_Killed  = KFPlayerController_WeeklySurvival(Killed);

    if (OutbreakEvent.ActiveEvent.bGunGameMode)
    {       
        // If pawn is monster increase gun game score for that monster

        if (KFPM != none && KFPC_WS_Killer != none)
        {
            if (KFPC_WS_Killer.Pawn.Health > 0)
            {
                KFPC_WS_Killer.GunGameData.Score += KFPM.GunGameKilledScore;
                UpdateGunGameLevel(KFPC_WS_Killer);
            }
        }
        else
        {
            // If pawn is human reset game score (we can just check Killed exists as Controller
            if (KFPC_WS_Killed != none)
            {
                ResetGunGame(KFPC_WS_Killed);
            }
        }
    }

    if (OutbreakEvent.ActiveEvent.bVIPGameMode)
    {
        if (KFPC_WS_Killed != none && KFPC_WS_Killed.VIPGameData.isVIP)
        {
			// UnregisterPlayer is done on the same frame but this function comes first..
            // we queue a petition to end the game if no vip is found
            SetTimer(1.5f, false, 'OnVIPDiesEndMatch');
        }
    }
}

function GunGameLevelGrantWeapon(KFPlayerController_WeeklySurvival KFPC_WS, class<KFWeaponDefinition> ToGrantWeaponDefinition)
{
    local class<Inventory> InventoryClass;
    local Inventory Inv;
    local KFWeapon KFW;

    InventoryClass = class<KFWeapon> (DynamicLoadObject(ToGrantWeaponDefinition.default.WeaponClassPath, class'Class'));
    Inv = KFPC_WS.Pawn.InvManager.CreateInventory(InventoryClass, true);

    if (Inv != none)
    {
        KFW = KFWeapon(Inv);
        if (KFW != none)
        {
            KFW.bDropOnDeath = false;
            KFW.bGivenAtStart = true;
            KFW = KFInventoryManager(KFPC_WS.Pawn.InvManager).CombineWeaponsOnPickup( KFW );
            KFW.NotifyPickedUp();
                
            // Refill ammo
            KFW.AmmoCount[0] = KFW.MagazineCapacity[0];
            KFW.AddAmmo(KFW.GetMaxAmmoAmount(0));
            KFW.AmmoCount[1] = KFW.MagazineCapacity[1];
            KFW.AddSecondaryAmmo(KFW.GetMaxAmmoAmount(1));

            KFPC_WS.Pawn.InvManager.SetCurrentWeapon(KFW);
        }
    }   
}

function UpdateGunGameLevel(KFPlayerController_WeeklySurvival KFPC_WS)
{
    local byte CurrentLevel, InitialLevel, RandomNumber;
    local class<KFWeaponDefinition> ToGrantWeaponDefinition;
    local GunGamePerkData PerkData;
    local KFWeapon CurrentWeapon;
    local bool found_base_weapon;

    if (!OutbreakEvent.ActiveEvent.bGunGameMode)
        return;

    PerkData = OutbreakEvent.ActiveEvent.GunGamePerksData;
    
    InitialLevel = KFPC_WS.GunGameData.Level;
    CurrentLevel = KFPC_WS.GunGameData.Level;

    // Update to the current level
    while (CurrentLevel < PerkData.GunGameLevels.Length && KFPC_WS.GunGameData.Score >= PerkData.GunGameLevels[CurrentLevel].RequiredScore)
    {
        ++CurrentLevel;
    }

    // Update HUD

    if (CurrentLevel > PerkData.GunGameLevels.Length - 1)
    {
        KFPC_WS.UpdateGunGameWidget(KFPC_WS.GunGameData.Score, -1, PerkData.GunGameLevels.Length, PerkData.GunGameLevels.Length);
    }
    else
    {
        KFPC_WS.UpdateGunGameWidget(KFPC_WS.GunGameData.Score, PerkData.GunGameLevels[CurrentLevel].RequiredScore, CurrentLevel, PerkData.GunGameLevels.Length);
    }

    if (InitialLevel != CurrentLevel)
    {
        // If this player reached last level..
        if (CurrentLevel > PerkData.GunGameLevels.Length - 1)
        {
            if (bGunGamePlayerOnLastGun == false)
            {
                KFPC_WS.GunGameData.GiveWeaponMaster = true;
            }

            bGunGamePlayerOnLastGun = true;

            KFPC_WS.PlayGunGameMessage(true);
        }
        else
        {
            KFPC_WS.PlayGunGameMessage(false);
        }
 
        KFPC_WS.GunGameData.Level = CurrentLevel;

        found_base_weapon = false;

        // Remove Previous Granted Items
        foreach KFPC_WS.Pawn.InvManager.InventoryActors ( class'KFWeapon', CurrentWeapon )
        {
            // (not if it's knife/9mm/syringe)
            if (!class'KFPerk'.static.IsKnife(CurrentWeapon)
                && !class'KFPerk_SWAT'.static.Is9mm(CurrentWeapon)
                && !class'KFPerk'.static.IsSyringe(CurrentWeapon)
                && !class'KFPerk'.static.IsWelder(CurrentWeapon))
            {
                // To prevent audio/vfx lock, while firing when removing the equipped weapon we do a proper gun remove
                // This new function manages it's state internally
                CurrentWeapon.RemoveGun();
            }

            if (class'KFPerk_SWAT'.static.Is9mm(CurrentWeapon))
            {
                found_base_weapon = true;
            }
        }

        // We need to grant 9MM is we don't have it and we jumped levels

        if (CurrentLevel > 1 && found_base_weapon == false)
        {
            ToGrantWeaponDefinition = PerkData.GunGameLevels[0].GrantedWeapons[0];

            GunGameLevelGrantWeapon(KFPC_WS, ToGrantWeaponDefinition);
        }

        // Grant Weapon

        // Generate random weapon to grant from the list

        // Deactivated preload in console version
        if (WorldInfo.IsConsoleBuild())
        {
            RandomNumber = Rand(PerkData.GunGameLevels[CurrentLevel-1].GrantedWeapons.Length);
        }
        else
        {
            RandomNumber = KFPC_WS.GunGameData.GunGamePreselectedWeapons[CurrentLevel-1];
        }

        ToGrantWeaponDefinition = PerkData.GunGameLevels[CurrentLevel-1].GrantedWeapons[RandomNumber];

        GunGameLevelGrantWeapon(KFPC_WS, ToGrantWeaponDefinition);
    }
}

///////////////////////////////////////////////////////////////////////////////////

function UnregisterPlayer(PlayerController PC)
{
	local KFPlayerController_WeeklySurvival KFPC_WS;

	super.UnregisterPlayer(PC);

	KFPC_WS = KFPlayerController_WeeklySurvival(PC);
    if (OutbreakEvent.ActiveEvent.bVIPGameMode)
    {
        if (KFPC_WS != none && KFPC_WS.VIPGameData.IsVIP)
        {
            ChooseVIP(false, KFPC_WS);
        }
    }
}

function WaveStarted()
{
    Super.WaveStarted();
    
    if (OutbreakEvent.ActiveEvent.bVIPGameMode)
    {
        if (WaveNum <= 1)
        {
            ChooseVIP(true);
        }
    }
}

/**
 *  Weekly 17: VIP MODE
 */

function OnVIPDiesEndMatch()
{
 	local KFPlayerController KFPC;

	foreach WorldInfo.AllControllers(class'KFPlayerController', KFPC)
	{
        KFPC.SetCameraMode('ThirdPerson');   
    }

    WaveEnded(WEC_TeamWipedOut);
}

function ChooseVIP_SetupVIP()
{
    local KFPlayerController_WeeklySurvival KFPC_WS, NewVIP;
    local KFGameReplicationInfo KFGRI;

    NewVIP = none;
    KFGRI = KFGameReplicationInfo(WorldInfo.GRI);

	foreach WorldInfo.AllControllers(class'KFPlayerController_WeeklySurvival', KFPC_WS)
	{
		if (KFPC_WS != none)
		{
  			if (KFPC_WS.VIPGameData.IsVIP)
			{
                NewVIP = KFPC_WS;
                break;
            }
        }
    }

    if (NewVIP != none)
    {
        //`Log("Setup new VIP: " $NewVIP);

        if (NewVIP.Pawn != none)
        {
            //`Log("Finished setup new VIP: " $NewVIP);

            NewVIP.GetPerk().PerkSetOwnerHealthAndArmor(false);

            if (NewVIP.VIPGameData.PendingHealthReset)
            {
                NewVIP.VIPGameData.PendingHealthReset = false;

                // Change current health directly, Pawn.HealDamage does a lot of other stuff that can block the healing
                NewVIP.Pawn.Health = NewVIP.Pawn.HealthMax;
            }

            // Replicate new data to clients
            KFGRI.UpdateVIPPlayer(KFPlayerReplicationInfo(NewVIP.PlayerReplicationInfo));
            KFGRI.UpdateVIPMaxHealth(NewVIP.Pawn.HealthMax);
            KFGRI.UpdateVIPCurrentHealth(NewVIP.Pawn.Health);

            NewVIP.PlayVIPGameChosenSound(3.5f);

            ClearTimer('ChooseVIP_SetupVIP');
        }
    }
}

function ChooseVIP(bool ForceAddHealth, optional KFPlayerController_WeeklySurvival PlayerJustLeft = none)
{
	local int RandomNumber;
	local KFPlayerController_WeeklySurvival KFPC_WS, CurrentVIP, NewVIP;
	local array<KFPlayerController_WeeklySurvival> PotentialVIP;
	local KFGameReplicationInfo KFGRI;

    //`Log("ChooseVIP!!!!!");

    ClearTimer('ChooseVIP_SetupVIP');

    KFGRI = KFGameReplicationInfo(WorldInfo.GRI);

	foreach WorldInfo.AllControllers(class'KFPlayerController_WeeklySurvival', KFPC_WS)
	{
		if (KFPC_WS != none)
		{
			if (KFPC_WS.VIPGameData.IsVIP == false && KFPC_WS.VIPGameData.WasVIP == false)
			{
				PotentialVIP.AddItem(KFPC_WS);
			}

			if (KFPC_WS.VIPGameData.IsVIP)
			{
				CurrentVIP = KFPC_WS;
			}
		}
	}

	if (CurrentVIP != none)
	{
		//`Log("Remove old VIP: " $CurrentVIP);

		CurrentVIP.VIPGameData.IsVIP = false;

        CurrentVIP.GetPerk().PerkSetOwnerHealthAndArmor(false);
	}

	// If there's no potential VIP we restart
	if (PotentialVIP.Length == 0)
	{
		foreach WorldInfo.AllControllers(class'KFPlayerController_WeeklySurvival', KFPC_WS)
		{
			if (KFPC_WS != none)
			{
				KFPC_WS.VIPGameData.WasVIP = false;

				if (PlayerJustLeft == none
					|| PlayerJustLeft != KFPC_WS)
				{
					PotentialVIP.AddItem(KFPC_WS);
				}
			}
		}
	}

	if (PotentialVIP.Length > 0)
	{
		RandomNumber = Rand(PotentialVIP.Length);

		NewVIP = PotentialVIP[RandomNumber];

		NewVIP.VIPGameData.IsVIP = true;
		NewVIP.VIPGameData.WasVIP = true;
	}	

	if (NewVIP != none)
	{
        if (ForceAddHealth || (KFGRI != none && KFGRI.bWaveIsActive == false))
		{
            NewVIP.VIPGameData.PendingHealthReset = true;
        }

        // If there's no Pawn we have to wait on a Timer function
        if (NewVIP.Pawn != none)
        {
            ChooseVIP_SetupVIP();
        }
        else
        {
            SetTimer(0.25f, true, 'ChooseVIP_SetupVIP');
        }

        ClearTimer('OnVIPDiesEndMatch');
	}
}

function OnOutbreakWaveWon()
{
    Super.OnOutbreakWaveWon();

    // GunGame Mode
    if (OutbreakEvent.ActiveEvent.bGunGameMode)
    {
        MyKFGRI.GunGameWavesCurrent += 1;

        // If we unlocked last weapon we only finish if we completed the boss wave
        // If we didn't unlock to last weapon and we just finished last wave (before BOSS), repeat
        if (bGunGamePlayerOnLastGun)
        {
            MyKFGRI.bWaveGunGameIsFinal = true;

            if (WaveNum < WaveMax)
            {
                WaveNum = WaveMax - 1;
            }
        }
        else if (WaveNum >= WaveMax - 1)
        {
            // Repeat wave before BOSS till forever
            WaveNum = WaveMax - 2;
        }

        MyKFGRI.bNetDirty = true;
    }	

    // VIP Mode
    if (OutbreakEvent.ActiveEvent.bVIPGameMode)
    {
        ChooseVIP(true);
    }
}

/*
 * Weekly 18: Random Perks
 */

simulated function NotifyPlayerStatsInitialized(KFPlayerController_WeeklySurvival KFPC)
{
    if (KFPC != none && MyKFGRI.IsRandomPerkMode())
    {
        ChooseInitialRandomPerk(KFPC);
    }
}

function ChooseInitialRandomPerk(KFPlayerController_WeeklySurvival KFPC_WS)
{
    local KFPlayerController_WeeklySurvival OtherKFPC;
    local array<class<KFPerk> > AvailablePerks;
    local int i;
    local byte NewPerkIndex;
    local bool bPerkFound;

    `Log("CHOOSING INITIAL PERKS");

    for (i = 0; i < KFPC_WS.PerkList.Length; ++i)
    {
        bPerkFound = false;

        foreach WorldInfo.AllControllers(class'KFPlayerController_WeeklySurvival', OtherKFPC)
        {
            if (OtherKFPC == KFPC_WS)
            {
                continue;
            }

            if (KFPC_WS.Perklist[i].PerkClass == OtherKFPC.CurrentPerk.Class)
            {
                bPerkFound = true;
                break;
            }
        }   

        if (!bPerkFound)
        {
            AvailablePerks.AddItem(KFPC_WS.PerkList[i].PerkClass);
        }
    }

    if (AvailablePerks.Length == 0)
    {
        for (i = 0; i < KFPC_WS.Perklist.Length; ++i)
        {
            AvailablePerks.AddItem(KFPC_WS.Perklist[i].PerkClass);
        }
        KFPC_WS.LockedPerks.Length = 0;
    }

    NewPerkIndex = Rand(AvailablePerks.Length);
    
    KFPC_WS.LockedPerks.AddItem(AvailablePerks[NewPerkIndex]);
    KFPC_WS.ForceNewPerk(AvailablePerks[NewPerkIndex]);
}

function ChooseRandomPerks()
{
    local KFPlayerController_WeeklySurvival KFPC;
    local array<class<KFPerk> > AvailablePerks;
    local array<class<KFPerk> > PickedPerks;
    local int i, j;
    local byte NewPerkIndex;
    local bool bPerkFound;

    foreach WorldInfo.AllControllers(class'KFPlayerController_WeeklySurvival', KFPC)
    {
        AvailablePerks.Length = 0;

        for (i = 0; i < KFPC.Perklist.Length; ++i)
        {
            bPerkFound = false;
            for (j = 0; j < PickedPerks.Length; ++j)
            {
                if (KFPC.Perklist[i].PerkClass == PickedPerks[j])
                {
                    bPerkFound = true;
                    break;
                }
            }

            if (!bPerkFound)
            {
                for (j = 0; j < KFPC.LockedPerks.Length; ++j)
                {
                    if (KFPC.Perklist[i].PerkClass == KFPC.LockedPerks[j])
                    {
                        bPerkFound = true;
                        break;
                    }
                }
            }

            if (!bPerkFound)
            {
                AvailablePerks.AddItem(KFPC.Perklist[i].PerkClass);
            }
        }

        if (AvailablePerks.Length == 0)
        {
            for (i = 0; i < KFPC.Perklist.Length; ++i)
            {
                bPerkFound = false;
                for (j = 0; j < PickedPerks.Length; ++j)
                {
                    if (KFPC.Perklist[i].PerkClass == PickedPerks[j])
                    {
                        bPerkFound = true;
                        break;
                    }
                }

                if (!bPerkFound && KFPC.Perklist[i].PerkClass != KFPC.CurrentPerk.Class)
                {
                    AvailablePerks.AddItem(KFPC.Perklist[i].PerkClass);
                }
            }

            if (AvailablePerks.Length == 0)
            {
                for (i = 0; i < KFPC.Perklist.Length; ++i)
                {
                    AvailablePerks.AddItem(KFPC.Perklist[i].PerkClass);
                    PickedPerks.Length = 0;
                }
            }
            
            KFPC.LockedPerks.Length = 0;
        }

        NewPerkIndex = Rand(AvailablePerks.Length);
        PickedPerks.AddItem(AvailablePerks[NewPerkIndex]);
        KFPC.LockedPerks.AddItem(AvailablePerks[NewPerkIndex]);

        KFPC.ForceNewPerk(AvailablePerks[NewPerkIndex]);

        KFPC.PlayRandomPerkChosenSound();
    }
}

//
// Overide BroadcastLocalizedMessage for the RandomPerk weekly (18)
// Perk is replicated while the message is sent through a RPC, so the message arrives before
// the perk is updated on clients. 
// Override the BroadcastLocalizedMessage function to RPC each player the message with their own 
// new perk class as the optional object so the client knows the information before it gets the perk updated.
//
event BroadcastLocalizedMessage( class<LocalMessage> InMessageClass, optional int Switch, optional PlayerReplicationInfo RelatedPRI_1, optional PlayerReplicationInfo RelatedPRI_2, optional Object OptionalObject )
{
    if (!MyKFGRI.IsRandomPerkMode() || Switch != GMT_WaveEnd)
    {
        Super.BroadcastLocalizedMessage(InMessageClass, Switch, RelatedPRI_1, RelatedPRI_2, OptionalObject);
    }
    else
    {
        BroadcastCustomWaveEndMessage(self, InMessageClass, Switch);
    }
}

function BroadcastCustomWaveEndMessage( actor Sender, class<LocalMessage> InMessageClass, optional int Switch, optional PlayerReplicationInfo RelatedPRI_1, optional PlayerReplicationInfo RelatedPRI_2, optional Object OptionalObject )
{
    local KFPlayerController KFPC;

	foreach WorldInfo.AllControllers(class'KFPlayerController', KFPC)
	{
        KFPC.ReceiveLocalizedMessage( InMessageClass, Switch, RelatedPRI_1, RelatedPRI_2, KFPC.GetPerk().Class);
	}
}
//

defaultproperties
{
    //Overrides
	GameReplicationInfoClass=class'KFGameContent.KFGameReplicationInfo_WeeklySurvival'
    PlayerControllerClass=class'KFGame.KFPlayerController_WeeklySurvival'
	OutbreakEventClass=class'KFOutbreakEvent_Weekly'
}
