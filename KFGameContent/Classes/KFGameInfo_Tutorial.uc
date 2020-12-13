//=============================================================================
// KFGameInfo_Tutorial
//=============================================================================
// The game mode class for a single player tutorial
//=============================================================================
// Killing Floor 2
// Copyright (C) 2016 Tripwire Interactive LLC
//=============================================================================

class KFGameInfo_Tutorial extends KFGameInfo_Survival
    dependson(KFTutorialSectionInfo)
    hidedropdown;

var class<KFGFxMoviePlayer_Tutorial>  MoviePlayerTutorialClass;
var KFGFxMoviePlayer_Tutorial         MyGFXTutorial;

var KFTutorialSectionInfo LobbyStartInfo;
var KFTutorialSectionInfo StartMatchInfo;
var KFTutorialSectionInfo Wave1EndInfo;
var KFTutorialSectionInfo TraderCloseInfo;
var KFTutorialSectionInfo VictoryInfo;
var KFTutorialSectionInfo HealSelfInfo;
var KFTutorialSectionInfo ZedTimeInfo;
var KFTutorialSectionInfo MeleeTutorial;

var KFTutorialSectionInfo TraderMenuTutorial;
var KFTutorialSectionInfo PerkMenuTutorial;
var KFTutorialSectionInfo GearMenuTutorial;
var KFTutorialSectionInfo InventoryMenuTutorial;
var KFTutorialSectionInfo StoreMenuTutorial;

var bool bShowedHealSelf;
var bool bShowedZedTime;
var bool bShowedTraderTutorial;
var bool bShowedMeleeTutorial;
var bool bShowedPerkMenuTutorial;
var bool bShowedGearMenuTutorial;
var bool bShowedInventoryMenuTutorial;
var bool bShowedStoreMenuTutorial;
var bool bShowedTraderCloseInfo;

/** Timer countdown (seconds) after player is done trading */
var int TimeAfterTrading;

/** Amount of dosh the player spawns with in the tutorial */
var int StartingDosh;

/** Cached local player controller ref */
var KFPlayerController MyPC;
/** Cached weapon for melee tutorial */
var Weapon CurrentWeapon;

event InitGame( string Options, out string ErrorMessage )
{
    // Force standalone for this game mode.  SetGameType() would be
    // ideal, but NetMode has no been set yet.
    if ( WorldInfo.NetMode != NM_Standalone )
    {
        ConsoleCommand("open" @ WorldInfo.GetMapName(true));
        return;
    }

    Super.InitGame(Options, ErrorMessage);
}

event PostBeginPlay()
{
    super.PostBeginPlay();

    // use defaultprops instead of difficulty sysstem
    TimeBetweenWaves = default.TimeBetweenWaves;
    `TraderDialogManager.bEnabled = false;
}

/** We're going to use our local PC often, so may as well cache it */
event PostLogin( PlayerController NewPlayer )
{
    Super.PostLogin(NewPlayer);

    // We're going to use our local PC often, so may as well cache it
    if ( NewPlayer.IsLocalController() )
    {
		MyPC = KFPlayerController(NewPlayer);
        CreateTutorialHUD(LobbyStartInfo);
    }
}

/** Override starting dosh */
function RestartPlayer(Controller NewPlayer)
{
    Super.RestartPlayer(NewPlayer);

    if( NewPlayer.PlayerReplicationInfo != None )
    {
        NewPlayer.PlayerReplicationInfo.Score = StartingDosh;
        CreateTutorialHUD(StartMatchInfo);
    }
}

/** 50% damage recieved */
function ReduceDamage(out int Damage, Pawn Injured, Controller InstigatedBy, vector HitLocation, out vector Momentum, class<DamageType> DamageType, Actor DamageCauser, TraceHitInfo HitInfo)
{
    if ( Injured.IsHumanControlled() )
    {
        //Damage = Max(Round(Damage / 2.f), 1);
        if(!bShowedHealSelf)
        {
            if(Injured.Health <= Injured.HealthMax * 0.90f)
            {
                CreateTutorialHUD(HealSelfInfo);
                bShowedHealSelf = true;
            }
        }
    }

    // checks neutral zone and god mode and calls mutator hook
    Super.ReduceDamage(Damage, Injured, InstigatedBy, HitLocation, Momentum, DamageType, DamageCauser, HitInfo);
}

function bool PreventDeath(Pawn KilledPawn, Controller Killer, class<DamageType> DamageType, vector HitLocation)
{
    if ( KilledPawn.IsHumanControlled() )
    {
        // give some bonus health so we're not always at 1 health
        KilledPawn.Health = KilledPawn.HealthMax * 0.25f;
        return true;
    }

    return Super.PreventDeath(KilledPawn, Killer, DamageType, HitLocation);
}

/**  */
function WaveEnded(EWaveEndCondition WinCondition)
{
    // Skip the final "dummy" wave and go to match ended
    if ( WaveNum == (WaveMax - 1) )
    {
        WaveNum = WaveMax;
    }

    Super.WaveEnded(WinCondition);
}

/**  */
function EndOfMatch(bool bVictory)
{
    Super.EndOfMatch(bVictory);

    if ( bVictory )
    {
		// Console builds try to claim tutorial rewards now
        //@SABER_EGS IsEosBuild() case added
		if( WorldInfo.IsConsoleBuild() || WorldInfo.IsEosBuild())
		{
			PlayfabInter.AddOnCloudScriptExecutionCompleteDelegate( OnTutorialRewardsComplete );
			PlayfabInter.ExecuteCloudScript( "ClaimTutorialRewards", none );
		}
        CreateTutorialHUD(VictoryInfo);
    }
}


function OnTutorialRewardsComplete( bool bWasSuccessful, string FunctionName, JsonObject FunctionResult )
{
	PlayfabInter.ClearOnCloudScriptExecutionCompleteDelegate( OnTutorialRewardsComplete );
	// On success, re-read inventory
	if( bWasSuccessful && FunctionName == "ClaimTutorialRewards" )
	{
		class'GameEngine'.static.GetPlayfabInterface().ReadInventory();
	}
}


/** Skip the AAR and return to main menu */
function ShowPostGameMenu()
{
    ConsoleCommand("disconnect");
}

/** Picks next trader index and allows for mutator hook */
function byte DetermineNextTraderIndex()
{
   local int index;
   local KFTraderTrigger Trader;

   // In evac there is a specific trader we want near some doors to weld
   ForEach TraderList(Trader, index)
   {
        if ( Trader.Name == 'KFTraderTrigger_17' )
        {
            return index;
        }
   }

   return super.DetermineNextTraderIndex();
}

/** No pickups introduced in the first round */
function ResetPickups( array<KFPickupFactory> PickupList, int NumPickups )
{
    if( WaveNum == 1 )
    {
        Super(KFGameInfo).ResetPickups(PickupList, 0);
    }

    super.ResetPickups( PickupList, NumPickups );
}

function SetZedTimeDilation(float NewTimeDilation)
{
    super.SetZedTimeDilation(NewTimeDilation);
    if(NewTimeDilation == ZedTimeSlomoScale)   
    {
        if(!bShowedZedTime)
        {
            CreateTutorialHUD(ZedTimeInfo);
            bShowedZedTime = true;
        }
    }
}

/** check main menu tutorial(s) */
function NotifyMenuOpened(byte MenuIndex)
{        
    switch(MenuIndex)
    {
        case UI_Perks:
            if ( !bShowedPerkMenuTutorial )
            {
                CreateTutorialHUD(PerkMenuTutorial);
                bShowedPerkMenuTutorial = true;
                return;
            }
            break;

        case UI_Gear:
            if ( !bShowedGearMenuTutorial )
            {
                CreateTutorialHUD(GearMenuTutorial);
                bShowedGearMenuTutorial = true;
                return;
            }
            break;
        case UI_Inventory:
            if ( !bShowedInventoryMenuTutorial )
            {
                CreateTutorialHUD(InventoryMenuTutorial);
                bShowedInventoryMenuTutorial = true;
                return;
            }
            break;
        case UI_Store:
            if ( !bShowedStoreMenuTutorial )
            {
                CreateTutorialHUD(StoreMenuTutorial);
                bShowedStoreMenuTutorial = true;
                return;
            }
            break;
    }
}

/*********************************************************************************************
 * KFGFxMoviePlayer_Tutorial Interface
 *********************************************************************************************/

function bool AllowUnpause()
{
    if(MyGFXTutorial != none)
    {
        return false;
    }
    
    return true;
}

/** Create/Open a tutorial popup */
function CreateTutorialHUD(KFTutorialSectionInfo TutorialSectionInfo, optional bool bViaTimer)
{
    local PlayerController PC;

    // If we asked for a tutorial that requires a delay do that now.  Track
    // on the tutorial object so we can have multiple simultaneous timers
    if ( !bViaTimer && TutorialSectionInfo.OpenDelay > 0 )
    {
        SetTimer(TutorialSectionInfo.OpenDelay, false, nameof(TutorialSectionInfo.OpenDelayTimer), TutorialSectionInfo);
        return;
    }

    PC = GetALocalPlayerController();

    PC.PlayerInput.ResetInput();

    // @todo: object creation should only be done once?
    if(MyGFXTutorial == none && MoviePlayerTutorialClass != None )
    {
        MyGFXTutorial = new MoviePlayerTutorialClass;        
        MyGFXTutorial.SetTimingMode(TM_Real);
        MyGFXTutorial.TutorialSectionInfo = TutorialSectionInfo;
        MyGFXTutorial.TargetTutorialArray = TutorialSectionInfo.GetSlides(PC);
    }
    
    if(PC != none && MyGFXTutorial != none)
    {        
        MyGFXTutorial.Init(class'Engine'.static.GetEngine().GamePlayers[MyGFXTutorial.LocalPlayerOwnerIndex]);
        PC.SetPause(true, AllowUnpause);     
        if(MyGFXTutorial.TutorialSectionInfo.VoiceOverOpenEvent != none)
        {
            PC.PlaySoundBase( MyGFXTutorial.TutorialSectionInfo.VoiceOverOpenEvent, true, false, false );   
        }
    }
}

/** Close, unpause, and delete the tutorial UI object **/
function RemoveTutorialHud()
{
    local PlayerController PC;

    if ( MyGFXTutorial != None )
    {
        PC = GetALocalPlayerController();
        if(PC != none)
        {
            if(MyGFXTutorial.TutorialSectionInfo.VoiceOverOpenEvent != none)
            {
                PC.PlaySoundBase( MyGFXTutorial.TutorialSectionInfo.VoiceOverCloseEvent, true, false, false );   
            }
            MyGFXTutorial.Close(true);
            MyGFXTutorial = None;
            PC.SetPause(false);
        }
    }
}


function NotifyControllerDisconnected()
{
	if( MyGFXTutorial != none )
	{
		MyGFXTutorial.SetVisibility( false );
		// Make tutorial hide if we need to show controller disconnect dialog
		MyGFXTutorial.SetPriority(1);
		KFPlayerController(GetALocalPlayerController()).MyGFxManager.SetPriority(2);
	}
}


function NotifyControllerReconnected()
{
	if (MyGFXTutorial != none)
	{
		MyGFXTutorial.SetVisibility( true );
		// Put tutorial back on top
		MyGFXTutorial.SetPriority(2);
		KFPlayerController(GetALocalPlayerController()).MyGFxManager.SetPriority(1);
	}
}


/*********************************************************************************************
 * Update
 *********************************************************************************************/

function Tick( float DeltaTime )
{
    Super.Tick(DeltaTime);

    // Normally we wouldn't use a script tick for something like this, but in this
    // case it's a little cleaner using the brute force approach and this is not
    // a performance critical class.
    CheckPlayerAction();
}

/** Brute force update for what a player has done recently so we can display tutorials */
function CheckPlayerAction()
{
    // check melee tutorial
    if ( !bShowedMeleeTutorial && MyPC.Pawn != None && CurrentWeapon != MyPC.Pawn.Weapon )
    {
        if ( MyPC.Pawn.Weapon.IsA('KFWeap_MeleeBase') )
        {
            CreateTutorialHUD(MeleeTutorial);
            bShowedMeleeTutorial = true;
        }
        CurrentWeapon = MyPC.Pawn.Weapon;
    }
}

/*********************************************************************************************
 * state TraderOpen
 *********************************************************************************************/

State TraderOpen
{   
    function BeginState( Name PreviousStateName )
    {
        super.BeginState(PreviousStateName);
        CreateTutorialHUD(Wave1EndInfo);
    }

    // Normally we would use Timer(), but perf is not an issue here
    function CheckPlayerAction()
    {
        // Notify when menu is closed.  Menu wil be 'None' before it's been opened for the first time
        if ( MyKFGRI.RemainingTime > TimeAfterTrading )
        {           
            if ( MyPC != None && MyPC.MyGFxManager.TraderMenu != None )
            {
                if ( !MyPC.bClientTraderMenuOpen )
                {
                    OnTraderMenuClosed();
                    return;
                }
                else if ( !bShowedTraderTutorial )
                {
                    CreateTutorialHUD(TraderMenuTutorial);
                    bShowedTraderTutorial = true;
                    return;
                }
                else
                {
                    MyKFGRI.RemainingTime = TimeBetweenWaves;
                    MyKFGRI.RemainingMinute = TimeBetweenWaves;
                }
            }
        }

        if( MyPC.bClientTraderMenuOpen )
        {
            MyKFGRI.RemainingTime = TimeBetweenWaves;
            MyKFGRI.RemainingMinute = TimeBetweenWaves;
            ClearTimer(nameof(CloseTraderTimer));
        }

        Global.CheckPlayerAction();
    }
}

function OnTraderMenuClosed()
{
    // shorten time remaining before next wave
    if ( MyKFGRI.RemainingTime > TimeAfterTrading )
    {
        MyKFGRI.RemainingTime = TimeAfterTrading;
        MyKFGRI.RemainingMinute = TimeAfterTrading;

		if( !bShowedTraderCloseInfo )
        {
            CreateTutorialHUD(TraderCloseInfo);
            bShowedTraderCloseInfo = true;
        }

        // refresh timer
        SetTimer(TimeAfterTrading, false, nameof(CloseTraderTimer));
    }
}

function bool IsMapObjectiveEnabled()
{
	return false;
}

DefaultProperties
{
    StartMatchInfo=KFTutorialSectionInfo'GP_Tutorial_ARCH.StartMatchArch'
    Wave1EndInfo=KFTutorialSectionInfo'GP_Tutorial_ARCH.Wave1EndArch'    
    TraderCloseInfo=KFTutorialSectionInfo'GP_Tutorial_ARCH.TraderCloseArch'
    VictoryInfo=KFTutorialSectionInfo'GP_Tutorial_ARCH.VictoryArch'
    HealSelfInfo=KFTutorialSectionInfo'GP_Tutorial_ARCH.HealSelfArch'
    ZedTimeInfo=KFTutorialSectionInfo'GP_Tutorial_ARCH.ZedTimeArch'
    LobbyStartInfo=KFTutorialSectionInfo'GP_Tutorial_ARCH.LobbyStartArch'
    MeleeTutorial=KFTutorialSectionInfo'GP_Tutorial_ARCH.MeleeArch'

    PerkMenuTutorial=KFTutorialSectionInfo'GP_Tutorial_ARCH.PerkMenuArch'
    GearMenuTutorial=KFTutorialSectionInfo'GP_Tutorial_ARCH.GearMenuArch'
    InventoryMenuTutorial=KFTutorialSectionInfo'GP_Tutorial_ARCH.InventoryMenuArch'
    StoreMenuTutorial=KFTutorialSectionInfo'GP_Tutorial_ARCH.StoreMenuArch'
    TraderMenuTutorial=KFTutorialSectionInfo'GP_Tutorial_ARCH.TraderOpenArch'

    // tutorial subclass to catch player menu navigation
    KFGFxManagerClass=class'KFGFxMoviePlayer_Manager_Tutorial'

    MoviePlayerTutorialClass =Class'KFGFxMoviePlayer_Tutorial'
    MaxGameDifficulty=0
    SpawnManagerClasses.Empty
	SpawnManagerClasses(0)=class'KFAISpawnManager_Tutorial'

    TimeBetweenWaves=600
    TimeAfterTrading=30
    StartingDosh=2000
}