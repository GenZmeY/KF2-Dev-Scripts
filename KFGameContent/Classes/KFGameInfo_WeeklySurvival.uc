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
	OutbreakEvent.SetActiveEvent(ActiveEventIdx);
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

    //If we have an override weapon list, it's not enough to block trader and default inventory.
    //      Iterate through the item pickups in the map to trim their lists as well.
    if (OutbreakEvent.ActiveEvent.TraderWeaponList != none)
    {
        //So many loops
        foreach AllActors(class'KFPickupFactory_Item', ItemFactory)
        {
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

function StartMatch()
{
    super.StartMatch();

    //Set timer for global ticking damage
    if (OutbreakEvent.ActiveEvent.GlobalDamageTickRate > 0.f && OutbreakEvent.ActiveEvent.GlobalDamageTickAmount > 0.f)
    {
        SetTimer(OutbreakEvent.ActiveEvent.GlobalDamageTickRate, true, 'ApplyGlobalDamage', OutbreakEvent);
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
    local KFPlayerController_WeeklySurvival KFPC;
    local KFPawn_Customization KFCustomizePawn;
    super.PostLogin(NewPlayer);

    KFPC = KFPlayerController_WeeklySurvival(NewPlayer);
    if (KFPC != none)
    {
        KFPC.bUsingPermanentZedTime = OutbreakEvent.ActiveEvent.bPermanentZedTime;
        KFPC.ZedTimeRadius = OutbreakEvent.ActiveEvent.ZedTimeRadius * OutbreakEvent.ActiveEvent.ZedTimeRadius;
        KFPC.ZedTimeBossRadius = OutbreakEvent.ActiveEvent.ZedTimeBossRadius * OutbreakEvent.ActiveEvent.ZedTimeBossRadius;
        KFPC.ZedTimeHeight = OutbreakEvent.ActiveEvent.ZedTimeHeight;
        KFPC.ZedRecheckTime = OutbreakEvent.ActiveEvent.PermanentZedResetTime;

        //Handle any visual-related things for customization pawn so the pregame lobby has the fun things
        KFCustomizePawn = KFPawn_Customization(KFPC.Pawn);
        if (KFCustomizePawn != none)
        {
            KFCustomizePawn.IntendedHeadScale = OutbreakEvent.ActiveEvent.PlayerSpawnHeadScale;
            KFCustomizePawn.SetHeadScale(KFCustomizePawn.IntendedHeadScale, KFCustomizePawn.CurrentHeadScale);
        }
    }
}

function SetBossIndex()
{
	local BossSpawnReplacement Replacement;
	local int ReplaceIdx;

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
    super.WaveEnded(WinCondition);

    if (OutbreakEvent.ActiveEvent.bPermanentZedTime && ZedTimeRemaining > ZedTimeBlendOutTime)
    {
        ClearZedTimePCTimers();
        ZedTimeRemaining = ZedTimeBlendOutTime;
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

    super.EndOfMatch(bVictory);

    if (bVictory)
    {
        foreach WorldInfo.AllControllers(class'KFPlayerController', KFPC)
		{
			KFPC.CompletedWeeklySurvival();
		}
    }
}

function StartWave()
{
    super.StartWave();
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
            if (Item.ClassName == name(ClassPath))
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

function RestartPlayer(Controller NewPlayer)
{
	local KFPawn_Human KFPH;

    super.RestartPlayer(NewPlayer);

	KFPH = KFPawn_Human(NewPlayer.Pawn);
    OutbreakEvent.AdjustRestartedPlayer(KFPH);
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

defaultproperties
{
    //Overrides
	GameReplicationInfoClass=class'KFGameContent.KFGameReplicationInfo_WeeklySurvival'
    PlayerControllerClass=class'KFGame.KFPlayerController_WeeklySurvival'
	OutbreakEventClass=class'KFOutbreakEvent_Weekly'
}
