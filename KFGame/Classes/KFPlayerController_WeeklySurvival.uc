//=============================================================================
// KFGameInfo_WeeklySurvival
//=============================================================================
// Weekly variant of KFPC for handling per-player functionality related to
//      different weekly survival modes.
//=============================================================================
// Killing Floor 2
// Copyright (C) 2017 Tripwire Interactive LLC
//  - Dan Weiss
//=============================================================================

class KFPlayerController_WeeklySurvival extends KFPlayerController
    native(Controller)
    dependson(EphemeralMatchStats);

/** If the game mode is using permanent zed time, our handling of some functionality is a bit different */
var bool bUsingPermanentZedTime;

/** One of our changes is a radius/height check for relevant actors that would normally kick us out of zed time */
var float ZedTimeRadius;
var float ZedTimeBossRadius;
var float ZedTimeHeight;

/** How often to check for coming out of partial zed time if bUsingPermanentZedTime is on */
var float ZedRecheckTime;

/** Number of consecutive goompa stomps */
var int GoompaStreak;

/** Bonus to apply */
var int GoompaStreakBonus;

/** Max number of goompa stomps for damage bonus */
var transient int MaxGoompaStreak;

var	protected const name 	RhytmMethodRTPCName;
var	protected const	AkEvent	RhythmMethodSoundReset;
var	protected const	AkEvent	RhythmMethodSoundHit;
var	protected const	AkEvent	RhythmMethodSoundTop;
var	protected const	AkEvent	AracnoStompSoundEvent;
var protected const AKEvent GunGameLevelUpSoundEvent;
var protected const AKEvent GunGameLevelUpFinalWeaponSoundEvent;

struct native GunGameInfo
{
    var transient byte Level;
    var transient int  Score;
    var array<byte> GunGamePreselectedWeapons;
    var byte WaveToUseForRestart;
    var bool GiveWeaponMaster;

structdefaultproperties
{
    Level=0;
    Score=0;
    WaveToUseForRestart=0;
    GiveWeaponMaster=false;
}
};
var transient GunGameInfo GunGameData;

cpptext
{
    virtual UBOOL TestZedTimeVisibility(APawn* P, UNetConnection* Connection, UBOOL bLocalPlayerTest) override;
}

replication
{
    if (bNetDirty)
        bUsingPermanentZedTime, ZedTimeRadius, ZedTimeBossRadius, ZedTimeHeight, GoompaStreak, GunGameData;
}

simulated event PostBeginPlay()
{
    local KFGameInfo KFGI;

	super.PostBeginPlay();

    KFGI = KFGameInfo(WorldInfo.Game);
	if (KFGI != none && KFGI.OutbreakEvent != none && KFGI.OutbreakEvent.ActiveEvent.bGoompaJumpEnabled)
    {
        MaxGoompaStreak = KFGI.OutbreakEvent.ActiveEvent.GoompaStreakMax;
    }
}


function EnterZedTime()
{
    local bool bNewResult;
    local KFPawn KFP;
    local KFPerk MyPerk;

    //Some hax around rechecking zed time if we're in permanent mode.  Do the recheck on IsAffectedByZedTime
    //      and only call client function if the result is different than before.
    if (bUsingPermanentZedTime)
    {
        SetTimer(ZedRecheckTime, false, 'RecheckZedTime');

        KFP = KFPawn(Pawn);
        if (KFP != none)
        {
            bNewResult = IsAffectedByZedTime();
            //== because Pawn is !PC result
            if (KFP.bUnaffectedByZedTime == bNewResult)
            {
                MyPerk = GetPerk();
                if ( MyPerk != none )
                {
                    MyPerk.NotifyZedTimeStarted();
                }

                KFP.bUnaffectedByZedTime = !bNewResult;

                if ( KFP.bUnaffectedByZedTime )
                {
                    StartPartialZedTimeSightCounter();
                }

                // Call the client
                ClientEnterZedTime(KFP.bUnaffectedByZedTime);
            }
        }
    }
    else
    {
        super.EnterZedTime();
    }
}

function RecheckZedTime()
{
    EnterZedTime();
}

reliable client function UpdateWaveCount()
{
    if (MyGFxHUD != none)
	{
        MyGFxHUD.UpdateWaveCount();
    } 
}

reliable client function UpdateGunGameWidget(int score, int max_score, int level, int max_level)
{
    if (MyGFxHUD != none)
	{
		MyGFxHUD.UpdateGunGameWidget(score, max_score, level, max_level);
	}
}

/**
    Arachnophobia Goompa Stomp Streak functions
 */
function UpdateGoompaStreak()
{
    ++GoompaStreak;
    GoompaStreakBonus = GoompaStreak;
    UpdateGoompaCounterWidget(GoompaStreak, MaxGoompaStreak);
    GoompaStompMessage(GoompaStreak);

    if (IsTimerActive(nameof(ResetStreakInfo)))
    {
        ClearTimer(nameof(ResetStreakInfo));
    }
}

function ResetGoompaStreak()
{
    local KFGameInfo KFGI;
   
    if (GoompaStreak > 0)
    {
        KFGI = KFGameInfo(WorldInfo.Game);
        GoompaStreak = 0;
        if(KFGI != none)
        {
            SetTimer(KFGI.OutbreakEvent.ActiveEvent.GoompaBonusDuration, false, nameof(ResetStreakInfo));
        }
    }
}

function ResetStreakInfo()
{
    UpdateGoompaCounterWidget(GoompaStreak, MaxGoompaStreak);
    GoompaStompMessage(GoompaStreak);
    GoompaStreakBonus = 0;
}

function bool IsGoompaBonusActive()
{
    return GoompaStreakBonus > 0;
}

reliable client function GoompaStompMessage( byte StompNum)
{
    local int i;
	local AkEvent TempAkEvent;

	if( MyGFxHUD == none )
	{
        return;
	}

	i = StompNum;
	UpdateGoompaCounterWidget( StompNum, MaxGoompaStreak );

    if (StompNum == 0)
    {
        TempAkEvent = RhythmMethodSoundReset;
    }
    else if (StompNum == MaxGoompaStreak - 1)
    {
        TempAkEvent = RhythmMethodSoundHit;
    }
    else if (StompNum == MaxGoompaStreak)
    {
        TempAkEvent = RhythmMethodSoundTop;
        ++i;
    }

    if( TempAkEvent != none )
	{
		PlayRMEffect( TempAkEvent, RhytmMethodRTPCName, i );
	}

    if (StompNum > 0 && AracnoStompSoundEvent != none)
    {
        PlaySoundBase(AracnoStompSoundEvent);
    }
}

reliable client function PlayGunGameMessage(bool isLastLevel)
{
    if (isLastLevel)
    {
        if (GunGameLevelUpFinalWeaponSoundEvent != none)
        {
            PlaySoundBase(GunGameLevelUpFinalWeaponSoundEvent);
        }
    }
    else
    {
        if (GunGameLevelUpSoundEvent != none)
        {
            PlaySoundBase(GunGameLevelUpSoundEvent);
        }
    }
}

/** Resets all gameplay FX to initial state.
	Append to this list if additional effects are added. */
function ResetGameplayPostProcessFX()
{
    local KFGameReplicationInfo KFGRI;

    super.ResetGameplayPostProcessFX();

    KFGRI = KFGameReplicationInfo(WorldInfo.GRI);

	if((KFGRI != none && KFGRI.bIsWeeklyMode && KFGRI.CurrentWeeklyIndex == 12) && GameplayPostProcessEffectMIC != none)
	{
		GameplayPostProcessEffectMIC.SetScalarParameterValue(EffectZedTimeSepiaParamName, 1.f);
	}
}

simulated function SetBossCamera( KFInterface_MonsterBoss Boss )
{
    local KFGameReplicationInfo KFGRI;
    local bool bIsBossRush;

    KFGRI       = KFGameReplicationInfo(WorldInfo.GRI);
    bIsBossRush = KFGRI.bIsWeeklyMode && KFGRI.CurrentWeeklyIndex == 14;

    if (bIsBossRush && Boss.GetHealthPercent() <= 0.0f && KFGRI.WaveNum != KFGRI.WaveMax)
    {
        SetTimer(5.0f, false, nameof(ResetBossCamera));
    }

    super.SetBossCamera(Boss);
}

simulated function ResetBossCamera()
{
    super(PlayerController).ResetCameraMode();
}

function RestartGunGame()
{
    local KFGameInfo KFGI;
    local KFGameReplicationInfo KFGRI;

    KFGI = KFGameInfo(WorldInfo.Game);
    KFGRI = KFGameReplicationInfo(WorldInfo.GRI);

	if (KFGI != none && KFGRI != none)
    {
        KFGI.RestartGunGamePlayerWeapon(self, GunGameData.WaveToUseForRestart);
    }
}

function UpdateInitialHeldWeapon()
{
    //local KFWeapon KFW;
    local KFPawn_Human KFPH;
    local KFGameInfo KFGI;
    local KFGameReplicationInfo KFGRI;

    KFPH = KFPawn_Human(Pawn);

    if (KFPH == none || KFPH.InvManager == none)
    {
        return;
    }

    /*foreach KFPH.InvManager.InventoryActors( class'KFWeapon', KFW )
    {
        /** Seems its in order, so knife goes first. Equip it */

        KFPH.InvManager.SetCurrentWeapon(KFW);
        break;
    }*/

    KFGI = KFGameInfo(WorldInfo.Game);
    KFGRI = KFGameReplicationInfo(WorldInfo.GRI);

	if (KFGI != none && KFGRI != none)
    {
        KFGI.ResetGunGame(self);

        GunGameData.WaveToUseForRestart = KFGRI.WaveNum;

        SetTimer(1.0, false, 'RestartGunGame');
    }
}

//
defaultProperties
{
    GoompaStreak      = 0 
    MaxGoompaStreak   = -1
    GoompaStreakBonus = 0
   	RhytmMethodRTPCName    ="R_Method"
   	RhythmMethodSoundReset =AkEvent'WW_UI_PlayerCharacter.Play_R_Method_Reset'
	RhythmMethodSoundHit   =AkEvent'WW_UI_PlayerCharacter.Play_R_Method_Hit'
	RhythmMethodSoundTop   =AkEvent'WW_UI_PlayerCharacter.Play_R_Method_Top'
    AracnoStompSoundEvent   =AkEvent'WW_GLO_Runtime.WeeklyArcno'
    GunGameLevelUpSoundEvent=AkEvent'WW_GLO_Runtime.WeeklyAALevelUp'
    GunGameLevelUpFinalWeaponSoundEvent=AkEvent'WW_GLO_Runtime.WeeklyAALevelFinal'
}
