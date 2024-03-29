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

var protected const AKEvent VIPChosenSoundEvent;
var protected const AKEvent VIPLowHealthSoundEvent;
var protected float VIPLowHealthLastTimePlayed;

var protected const AKEvent RandomPerkChosenSoundEvent;

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

struct native VIPGameInfo
{
    var bool IsVIP;
    var bool WasVIP;
    var bool PendingHealthReset;

    var int ExtraHealth;

    var int DamageHealthLimit;
    var int DamageHealthTop;
    var int DamageHealthBottom;

    var float DamageLimitModifier;

    var float OutputDamageTopModifier;
    var float InputDamageTopModifier;

    var float OutputDamageBottomModifier;
    var float InputDamageBottomModifier;

    structdefaultproperties
    {
        IsVIP = false
        WasVIP = false
        PendingHealthReset = false
        
        ExtraHealth = 100

        DamageHealthLimit = 100
        DamageHealthTop = 50
        DamageHealthBottom = 25

        DamageLimitModifier = 1.0

        OutputDamageTopModifier = 1.5
        InputDamageTopModifier = 0.75

        OutputDamageBottomModifier = 1.75
        InputDamageBottomModifier = 0.5
   }
};
var transient VIPGameInfo VIPGameData;

// RandomPerk weekly
var byte InitialRandomPerk;

// Contamination Mode weekly
var float ContaminationModeGraceCurrentTimer;
var bool ContaminationModePlayerIsInside;
var int ContaminationModeLastTimePlayerOutPulsate;
var bool ContaminationModeLastPulsate;

// Bounty Hunt weekly
var int BountyHuntCurrentExtraZeds;

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

simulated function UpdateVIPWidget(ReplicatedVIPGameInfo VIPInfo)
{
    if (MyGFxHUD != none)
	{
		MyGFxHUD.UpdateVIP(VIPInfo, VIPInfo.VIPPlayer == PlayerReplicationInfo);
	}
}

reliable client function UpdateContaminationModeWidget(bool IsPlayerIn)
{
    // Reset pulsate
    if (IsPlayerIn != ContaminationModePlayerIsInside)
    {
        ContaminationModeLastPulsate = true;
        ContaminationModeLastTimePlayerOutPulsate = WorldInfo.TimeSeconds;
    }

    // Pulsate ping pongs for showing text when player is out or not
    if (IsPlayerIn == false && WorldInfo.TimeSeconds - ContaminationModeLastTimePlayerOutPulsate > 1.f)
    {
        ContaminationModeLastTimePlayerOutPulsate = WorldInfo.TimeSeconds;
        ContaminationModeLastPulsate = !ContaminationModeLastPulsate;
    }

    ContaminationModePlayerIsInside = IsPlayerIn;

    if (MyGFxHUD != none)
    {
        MyGFxHUD.UpdateContaminationMode(IsPlayerIn, ContaminationModeLastPulsate);
        
        if (MyGFxHUD.PlayerStatusContainer != none)
        {
            MyGFxHUD.PlayerStatusContainer.UpdateContaminationModeIconVisible(IsPlayerIn == false);
        }
    } 
}

reliable client function UpdateContaminationModeWidget_Timer(int Timer)
{
    if (MyGFxHUD != none)
    {
        MyGFxHUD.UpdateContaminationMode_Timer(Timer);
    }
}

reliable client Function ShowContaminationMode()
{
    if (MyGFxHUD != none)
    {
        MyGFxHUD.ShowContaminationMode();
    }  
}

reliable client function HideContaminationMode()
{
    if (MyGFxHUD != none)
    {
        MyGFxHUD.HideContaminationMode();

        if (MyGFxHUD.PlayerStatusContainer != none)
	    {
		    MyGFxHUD.PlayerStatusContainer.UpdateContaminationModeIconVisible(false);
	    }   
    } 
}

reliable client function DisplayBountyHuntObjective(int Bounties)
{
    if (MyGFxHUD != none)
    {
        MyGFxHUD.DisplayBountyHuntObjective(Bounties);
    } 
}

reliable client function DisplayBountyHuntStatus(int CurrentAliveBounties, int MaxBounties, int DeadBounties, int Dosh, int DoshNoAssist)
{
    if (MyGFxHUD != none)
    {
        //`Log("CurrentAliveBounties :" $CurrentAliveBounties);
        //`Log("(MaxBounties - DeadBounties) :" $(MaxBounties - DeadBounties));

        BountyHuntCurrentExtraZeds = (MaxBounties - DeadBounties) - CurrentAliveBounties;

        MyGFxHUD.DisplayBountyHuntStatus(MaxBounties - DeadBounties, Dosh, DoshNoAssist);
    } 
}

reliable client function ResetSyringe()
{
    local KFInventoryManager InventoryManager;
    local KFWeapon CurrentWeapon;

    InventoryManager = KFInventoryManager(Pawn.InvManager);

    if (InventoryManager.HealerWeapon == none)
    {
        foreach InventoryManager.InventoryActors ( class'KFWeapon', CurrentWeapon )
        {
            if (KFWeap_HealerBase(CurrentWeapon) != none)
            {
                InventoryManager.HealerWeapon = KFWeap_HealerBase(CurrentWeapon);
            }
        }   
    }

    if (InventoryManager.HealerWeapon != none)
    {
        InventoryManager.HealerWeapon.AmmoCount[0] = InventoryManager.HealerWeapon.MagazineCapacity[0];

        if (MyGFxHUD != none)
        {
            MyGFxHUD.ResetSyringe(InventoryManager.HealerWeapon.AmmoCount[0], InventoryManager.HealerWeapon.MagazineCapacity[0]);
        }   
    }
}

function bool CanUseHealObject()
{
    local KFGameReplicationInfo KFGRI;

    KFGRI = KFGameReplicationInfo(WorldInfo.GRI);

    // VIP cannot heal
    if (KFGRI != none
        && KFGRI.VIPRepPlayer != none
        && KFGRI.VIPRepPlayer == KFPlayerReplicationInfo(PlayerReplicationInfo))
    {
        return false;
    }
    
    return super.CanUseHealObject();
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

reliable client function PlayVIPSound_ChosenInternal()
{
    if (VIPChosenSoundEvent != none)
    {
        PlaySoundBase(VIPChosenSoundEvent);
    }
}

reliable client function PlayVIPGameChosenSound(float delay)
{
    // Put a timer because the sound happens at the same time as end wave and it's difficult to distinguish
    SetTimer(delay, false, nameof(PlayVIPSound_ChosenInternal));
}

reliable client function PlayVIPGameLowHealthSound()
{
    if (VIPLowHealthSoundEvent != none)
    {
        if (WorldInfo.TimeSeconds - VIPLowHealthLastTimePlayed > 8.f)
        {
            VIPLowHealthLastTimePlayed = WorldInfo.TimeSeconds;

            PlaySoundBase(VIPLowHealthSoundEvent);
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

function AdjustDamage(out int InDamage, Controller InstigatedBy, class<DamageType> DamageType, Actor DamageCauser, Actor DamageReceiver)
{
    local KFGameInfo KFGI;
    local float Multiplier, ModifierRange, HealthTop, HealthRange;
    local KFGameReplicationInfo KFGRI;
    local KFPawn_Monster KFPM;
    local int BountyHuntZedIt, BountyHuntIt;
    local float WaveProgress;

    super.AdjustDamage(InDamage, InstigatedBy, DamageType, DamageCauser, DamageReceiver);

    KFGI = KFGameInfo(WorldInfo.Game);

    if (KFGI != none)
    {
        KFGRI = KFGameReplicationInfo(WorldInfo.GRI);
    }

	if (Pawn != None && KFGI != none && KFGI.OutbreakEvent != none && KFGI.OutbreakEvent.ActiveEvent.bVIPGameMode)
    {
        // If I am the VIP doing the damage, and I am NOT doing damage to myself
        if (KFGRI != none
            && KFGRI.VIPRepPlayer != none
            && KFGRI.VIPRepPlayer == KFPlayerReplicationInfo(PlayerReplicationInfo)
            && InstigatedBy == self
            && DamageReceiver != self.Pawn)
        {            
            Multiplier = 1.0;

            //`Log("Current health for VIP OUTPUT DAMAGE: " $Pawn.Health);

            if (Pawn.Health < VIPGameData.DamageHealthLimit)
            {
                if (Pawn.Health <= VIPGameData.DamageHealthBottom)
                {
                    Multiplier = VIPGameData.OutputDamageBottomModifier;
                }
                else
                {
                    if (Pawn.Health > VIPGameData.DamageHealthTop)
                    {
                        Multiplier = VIPGameData.DamageLimitModifier;

                        // From 1.0 to 1.5 on the range of 100 - 50
                        ModifierRange = VIPGameData.OutputDamageTopModifier - VIPGameData.DamageLimitModifier;
                    
                        HealthTop = VIPGameData.DamageHealthLimit;
                        HealthRange = Abs(HealthTop - VIPGameData.DamageHealthTop);
                    }
                    else
                    {
                        // From 1.5 to 1.75 on the range of 50 - 25
                        Multiplier = VIPGameData.OutputDamageTopModifier;

                        ModifierRange = VIPGameData.OutputDamageBottomModifier - VIPGameData.OutputDamageTopModifier;

                        HealthTop = VIPGameData.DamageHealthTop;
                        HealthRange = Abs(HealthTop - VIPGameData.DamageHealthBottom);
                    }

                    Multiplier += ModifierRange * ((HealthTop - Pawn.Health) / HealthRange);
                }
            }
            else
            {
                Multiplier = VIPGameData.DamageLimitModifier;
            }

            //`Log("Multiplier for VIP OUTPUT DAMAGE: Output: " $Multiplier);

            InDamage = int(float(InDamage) * Multiplier);   
        }
    }

	if (Pawn != None && KFGRI != none && KFGRI.IsBountyHunt())
    {
        KFPM = KFPawn_Monster(DamageCauser);       

        if (KFPM != none && KFPM.bIsBountyHuntObjective)
        {
            // Depending on wave progress we tweak the Damage

			if (KFGRI.WaveTotalAICount > 0)
			{
                // Don't count current alive Bounty Zeds
				WaveProgress = float(KFGRI.AIRemaining - KFGI.WeeklyCurrentExtraNumberOfZeds()) / float(KFGRI.WaveTotalAICount);
			}
			else
			{
				WaveProgress = 0.f;
			}

            // Find first node of data for the Zed type we checking,.
            for (BountyHuntZedIt = 0 ; BountyHuntZedIt < KFGI.OutbreakEvent.ActiveEvent.BountyHuntGame.BountyHuntZedAndProgression.Length; ++BountyHuntZedIt)
            {
                if (KFGI.OutbreakEvent.ActiveEvent.BountyHuntGame.BountyHuntZedAndProgression[BountyHuntZedIt].ZedType == KFPM.class)
                {
                    break;
                }
            }

            // Update to the current level
            for (BountyHuntIt = 0 ; BountyHuntIt < KFGI.OutbreakEvent.ActiveEvent.BountyHuntGame.BountyHuntZedAndProgression[BountyHuntZedIt].BountyHuntZedProgression.Length; ++BountyHuntIt)
            {
                if (WaveProgress >= KFGI.OutbreakEvent.ActiveEvent.BountyHuntGame.BountyHuntZedAndProgression[BountyHuntZedIt].BountyHuntZedProgression[BountyHuntIt].RemainingZedRatio)
                {
                    break;
                }
            }

            if (BountyHuntIt == KFGI.OutbreakEvent.ActiveEvent.BountyHuntGame.BountyHuntZedAndProgression[BountyHuntZedIt].BountyHuntZedProgression.Length)
            {
                BountyHuntIt = KFGI.OutbreakEvent.ActiveEvent.BountyHuntGame.BountyHuntZedAndProgression[BountyHuntZedIt].BountyHuntZedProgression.Length - 1;
            } 

            //`Log("BOUNTY HUNT : Initial InDamage = " $InDamage);

            //`Log("WaveProgress : " $WaveProgress);

            InDamage += InDamage * KFGI.OutbreakEvent.ActiveEvent.BountyHuntGame.BountyHuntZedAndProgression[BountyHuntZedIt].BountyHuntZedProgression[BountyHuntIt].DamageBuffRatio;

            //`Log("BOUNTY HUNT : Output Damage: " $KFGI.OutbreakEvent.ActiveEvent.BountyHuntGame.BountyHuntZedAndProgression[BountyHuntZedIt].BountyHuntZedProgression[BountyHuntIt].DamageBuffRatio);
            //`Log("BOUNTY HUNT : Final InDamage = " $InDamage);
        }
    }
}

function AdjustVIPDamage(out int InDamage, Controller InstigatedBy)
{
    local KFGameInfo KFGI;
    local float Multiplier, ModifierRange, HealthTop, HealthRange;
    local KFGameReplicationInfo KFGRI;

    KFGI = KFGameInfo(WorldInfo.Game);
	if (Pawn != None && KFGI != none && KFGI.OutbreakEvent != none && KFGI.OutbreakEvent.ActiveEvent.bVIPGameMode)
    {
        KFGRI = KFGameReplicationInfo(WorldInfo.GRI);

        // If I am the VIP
        // We do it on a different step as don't want to scale InDamage to VIP Armour when receiving damage
        if (KFGRI != none
            && KFGRI.VIPRepPlayer != none
            && KFGRI.VIPRepPlayer == KFPlayerReplicationInfo(PlayerReplicationInfo))
        {
            Multiplier = 1.0;            

            //`Log("Current health for VIP INPUT DAMAGE: " $Pawn.Health);

            if (Pawn.Health < VIPGameData.DamageHealthLimit)
            {
                if (Pawn.Health <= VIPGameData.DamageHealthBottom)
                {
                    Multiplier = VIPGameData.InputDamageBottomModifier;
                }
                else
                {
                    if (Pawn.Health > VIPGameData.DamageHealthTop)
                    {
                        Multiplier = VIPGameData.DamageLimitModifier;

                        // From 1.0 to 0.5 on the range of 100 - 50
                        ModifierRange = VIPGameData.InputDamageTopModifier - VIPGameData.DamageLimitModifier;
                       
                        HealthTop = VIPGameData.DamageHealthLimit;
                        HealthRange = Abs(HealthTop - VIPGameData.DamageHealthTop);
                    }
                    else
                    {
                        // From 0.5 to 0.25 on the range of 50 - 25
                        Multiplier = VIPGameData.InputDamageTopModifier;

                        ModifierRange = VIPGameData.InputDamageBottomModifier - VIPGameData.InputDamageTopModifier;

                        HealthTop = VIPGameData.DamageHealthTop;
                        HealthRange = Abs(HealthTop - VIPGameData.DamageHealthBottom);                        
                    }

                    Multiplier += ModifierRange * ((HealthTop - Pawn.Health) / HealthRange);
                }
            }
            else
            {
                Multiplier = VIPGameData.DamageLimitModifier;
            }

            //`Log("Multiplier for VIP INPUT DAMAGE: Output: " $Multiplier);

            InDamage = int(float(InDamage) * Multiplier);
        }
    }
}

function NotifyTakeHit(Controller InstigatedBy, vector HitLocation, int Damage, class<DamageType> damageType, vector Momentum)
{
    local KFPlayerController_WeeklySurvival KFPC_WS;

	Super.NotifyTakeHit(InstigatedBy,HitLocation,Damage,damageType,Momentum);

    if (VIPGameData.IsVIP)
    {
        // Only sound once we pass down 50, sound again if recovered health and go down again
        if (Pawn.Health < 50 && Pawn.Health + Damage >= 50)
        {
            foreach WorldInfo.AllControllers(class'KFPlayerController_WeeklySurvival', KFPC_WS)
            {
                KFPC_WS.PlayVIPGameLowHealthSound();
            }
        }
    }
}

function UpdateVIPDamage()
{
    local KFGameReplicationInfo KFGRI;

    if (VIPGameData.IsVIP)
    {
        KFGRI = KFGameReplicationInfo(WorldInfo.GRI);

        if (KFGRI != none)
        {
            KFGRI.UpdateVIPCurrentHealth(Pawn.Health);
        }
    }
}

simulated function ForceNewPerk(byte NewPerkIndex)
{
    ServerSelectPerk(NewPerkIndex, Perklist[NewPerkIndex].PerkLevel, Perklist[NewPerkIndex].PrestigeLevel, true);
    SavedPerkIndex = NewPerkIndex;
    ForceNewSavedPerkIndex(NewPerkIndex);
}

unreliable client function PlayRandomPerkChosenSound(optional float delay = 0.0f)
{
    if (delay > 0.0f)
    {
        SetTimer(delay, false, nameof(PlayRandomPerkChosenSound_Internal));
    }
    else
    {
        PlayRandomPerkChosenSound_Internal();
    }
}

simulated function PlayRandomPerkChosenSound_Internal()
{
    if (RandomPerkChosenSoundEvent != none)
    {
        PlaySoundBase(RandomPerkChosenSoundEvent);
    }
}

simulated function OnStatsInitialized( bool bWasSuccessful )
{
    local KFGameReplicationInfo KFGRI;

    Super.OnStatsInitialized(bWasSuccessful);

    KFGRI = KFGameReplicationInfo(WorldInfo.GRI);
    if (KFGRI != none && KFGRI.IsRandomPerkMode())
    {
        ServerOnStatsInitialized();
    }
}

reliable server function ServerOnStatsInitialized()
{
    local KFGameInfo KFGI;

    KFGI = KFGameInfo(WorldInfo.Game);
    if (KFGI != none)
    {
        KFGI.NotifyPlayerStatsInitialized(self);
    }
}

reliable client function ForceNewSavedPerkIndex(byte NewPerkIndex)
{
    SavedPerkIndex = NewPerkIndex;
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
    VIPChosenSoundEvent=AkEvent'WW_UI_Menu.Play_AAR_TOPWEAPON_SLIDEIN_B'
    RandomPerkChosenSoundEvent=AkEvent'WW_UI_Menu.Play_AAR_TOPWEAPON_SLIDEIN_B'
    VIPLowHealthSoundEvent=AkEvent'WW_GLO_Runtime.WeeklyVIPAlarm'
    VIPLowHealthLastTimePlayed = 0.f
    InitialRandomPerk=255
    ContaminationModeGraceCurrentTimer=0.f
    ContaminationModePlayerIsInside=false
    ContaminationModeLastTimePlayerOutPulsate=0
    ContaminationModeLastPulsate=false
}