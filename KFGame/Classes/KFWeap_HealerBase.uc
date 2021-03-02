//=============================================================================
// KFWeap_HealerBase
//=============================================================================
// Base weapon class used for the healer
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
// - Andrew "Strago" Ladenberger
//=============================================================================
class KFWeap_HealerBase extends KFWeapon
	abstract;

/*********************************************************************************************
 Ammo / Reload
********************************************************************************************* */

/** How many points of heal ammo to recharge per second */
var()        float      HealSelfRechargeSeconds;

/** How many points of heal ammo to recharge per second when healing ourselves */
var()        float      HealOtherRechargeSeconds;

/** How many points of heal ammo to recharge per second */
var 		float 		HealRechargeTime;

/** Keeps track of incremental healing since we have to heal in whole integers */
var          float      HealingIncrement;

/** How many points of heal ammo to recharge per second. Calculated from the HealFullRechargeSeconds */
var          float      HealRechargePerSecond;

/** Set while healer is mixing / regenerating */
var repnotify bool	bIsAmmoRecharging;

/** Automatically use self-heal and then re-equip previous weapon */
var bool bQuickHealMode;

/** If set, play the reload version of the firing anim */
var bool bPlayHealAndReload;

/** The sound effect to play once we've finished recharging */
var AKEvent RechargeCompleteSound;

/** How long after we shart trying to heal before a zed can grab us.
  * Prevents us from missing healing shots from being grabbed */
var(Weapon) float   HealAttemptWeakZedGrabCooldown;


/*********************************************************************************************
 Healing (aka Firing Mode)
********************************************************************************************* */

/** Maximum range to find teammate */
var() float HealingRangeSQ;

/** Reference to a healable friendly set in TickSpecial */
var Pawn HealTarget;

/** Reference to last valid heal target, used for "Heal Miss" dialog */
var Pawn LastValidHealTarget;

/** Store last update to we can prevent idle->ready->idle to quickly */
var float LastReadyHealTime;

/** How much to heal when playing a standalone game */
var const float StandAloneHealAmount;

var bool bIsQuickHealMessageShowing;

/*********************************************************************************************
 Animations
********************************************************************************************* */

/** animation names */
const IdleReadyAnim			= 'Idle_Ready';
const HealSelfAnim			= 'Heal_Self';
const HealSelfReloadAnim	= 'Heal_Self_Reload';
const HealTeamAnim			= 'Heal_Team';
const HealTeamReloadAnim	= 'Heal_Team_Reload';
const QuickHealAnim			= 'Heal_Quick';

/*********************************************************************************************
 Screen
********************************************************************************************* */
var class<KFGFxWorld_HealerScreen> ScreenUIClass;
var KFGFxWorld_HealerScreen ScreenUI;

var float LastUIUpdateTime;
var float UIUpdateInterval;

replication
{
	if (bNetDirty)
		bIsAmmoRecharging;
}

simulated event ReplicatedEvent(name VarName)
{
	super.ReplicatedEvent(VarName);
	if (VarName == nameof(bIsAmmoRecharging))
	{
		if(!bIsAmmoRecharging && Owner != none)
		{
			PlaySoundBase( RechargeCompleteSound, true, false, false, Owner.Location );
		}
	}
}
//-------------------------------------------------------------------------------------------

function GivenTo(Pawn NewOwner, optional bool bDoNotActivate)
{
	local KFInventoryManager KFInvManger;

	Super.GivenTo( NewOwner, bDoNotActivate );

	//Register with inventory manager for easy access later. (Eg: HUD indicator)
	KFInvManger = KFInventoryManager(InvManager);
	if( InvManager != none && KFInvManger != none )
	{
		KFInvManger.HealerWeapon = self;
	}
}

/** Turn on the UI screen when we equip the healer */
simulated function AttachWeaponTo( SkeletalMeshComponent MeshCpnt, optional Name SocketName )
{
	super.AttachWeaponTo( MeshCpnt, SocketName );

	if (Instigator != none && Instigator.IsLocallyControlled() )
	{
		//Create the screen's UI piece
		if (ScreenUI == none)
		{
			ScreenUI = new( self ) ScreenUIClass;
			ScreenUI.Init();
			ScreenUI.Start(true);
		}

		if (ScreenUI != none)
		{
			ScreenUI.SetPause(false);
			ScreenUI.SetCharge( MagazineCapacity[0] );
		}
	}
}

/** Turn off the UI screen when we unequip the healer */
simulated function DetachWeapon()
{
	super.DetachWeapon();
	if (Instigator != none && Instigator.IsLocallyControlled() && ScreenUI != none)
	{
		ScreenUI.SetPause();
	}
}

simulated event Destroyed()
{
	if (Instigator != none && Instigator.IsLocallyControlled() && ScreenUI != none)
	{
		ScreenUI.Close();
	}
	super.Destroyed();
}

/*********************************************************************************************
 * Ammunition
 *********************************************************************************************/

/** SpareAmmoCount is used for recharging, but it doesn't show on HUD */
simulated function int GetSpareAmmoForHUD()
{
	return 0;
}

simulated function bool HasAnyAmmo()
{
	return true;
}

/** Performs actual ammo reloading */
simulated function PerformReload(optional byte FireModeNum)
{
	local KFPerk InstigatorPerk;

	InstigatorPerk = GetPerk();
	// begin ammo recharge on server
	if ( Role == ROLE_Authority )
	{
		bIsAmmoRecharging = true;

		InstigatorPerk.ModifyHealerRechargeTime( HealRechargeTime );
		// Set the healing recharge rate whenever we start charging
        HealRechargePerSecond = MagazineCapacity[0]/HealRechargeTime;
	}
}

/** Heal Ammo Regen */
function HealAmmoRegeneration(float DeltaTime)
{
    HealingIncrement += HealRechargePerSecond * DeltaTime;

    if( HealingIncrement >= 1.0 && AmmoCount[0] < MagazineCapacity[0] )
    {
        AmmoCount[0]++;
        HealingIncrement -= 1.0;

        if( AmmoCount[0] == MagazineCapacity[0] )
        {
            bIsAmmoRecharging = false;

            if(Instigator.IsLocallyControlled() && Owner != none)
            {
				PlaySoundBase( RechargeCompleteSound, true, false, false, Owner.Location );
			}
        }
    }
}

/** Returns true if weapon can potentially be reloaded */
// reload is handled automatically, see bPlayHealAndReload
simulated function bool CanReload(optional byte FireModeNum);

/*********************************************************************************************
 Firing / Projectile
********************************************************************************************* */

/** Instead of switch fire mode use as immediate alt fire */
simulated function AltFireMode()
{
	if ( !Instigator.IsLocallyControlled()  )
	{
		return;
	}

	// StartFire - StopFire called from KFPlayerInput
	StartFire(ALTFIRE_FIREMODE);
}

/**
 * If the weapon isn't an instant hit, or a simple projectile, it should use the tyoe EWFT_Custom.  In those cases
 * this function will be called.  It should be subclassed by the custom weapon.
 */
simulated function CustomFire()
{
	local float HealAmount;

	if( Role == ROLE_Authority )
	{
		// Healing a teammate
		if( CurrentFireMode == DEFAULT_FIREMODE )
		{
			HealAmount = InstantHitDamage[CurrentFireMode];
			HealTarget.HealDamage( HealAmount, Instigator.Controller, InstantHitDamageTypes[CurrentFireMode]);
			HealRechargeTime = HealOtherRechargeSeconds;
		}
		// Healing Self
		else if( CurrentFireMode == ALTFIRE_FIREMODE )
		{
			if ( GetActivePlayerCount() < 2 )
			{
				HealAmount = StandAloneHealAmount;
			}
			else
			{
				HealAmount = InstantHitDamage[CurrentFireMode];
			}
			Instigator.HealDamage(HealAmount, Instigator.Controller, InstantHitDamageTypes[CurrentFireMode]);
			HealRechargeTime = HealSelfRechargeSeconds;
		}
	}
}

/**
 * @see Weapon::StartFire
 */
simulated function StartFire(byte FireModeNum)
{
	local Pawn Healee;

	// Reload, grenade, melee all work the same as base weapon
	if ( FireModeNum > ALTFIRE_FIREMODE )
	{
		Super.StartFire(FireModeNum);
		return;
	}

	Healee = (FireModeNum == DEFAULT_FIREMODE) ? HealTarget : Instigator;

	// Exit if we have no valid target for a team heal or the target has full health
	if ( Healee == None || !IsValidHealingTarget( Healee ) )
	{
		// Play miss dialog.  Define "miss" as tried to fire, but recently lost target.
		// @todo (JDR): replace magic number with less-magical number
		if ( FireModeNum == DEFAULT_FIREMODE && HealTarget == None
			&& `TimeSince(LastReadyHealTime) < 2.f )// && LastValidHealTarget.bIsMoving )
		{
			MissHeal( LastValidHealTarget );
		}

		return;
	}

	if( Instigator == None || !Instigator.bNoWeaponFiring )
	{
		// always do this (medics may be able to heal without reloading)
		// @todo bPlayHealAndReload when reload animations are back in
		//bPlayHealAndReload = true;

		if( Role < Role_Authority )
		{
			// tell the server who we want to heal
			ServerStartHeal(FireModeNum, HealTarget, bPlayHealAndReload);
		}

		// Start fire locally
		BeginFire(FireModeNum);
	}
}

simulated function bool IsValidHealingTarget( Pawn Healee )
{
	if( Healee != none )
	{
		return Healee.Health < Healee.HealthMax && Healee.IsAliveAndWell();
	}

	return false;
}


/** Set the heal target and start firing mode */
reliable server private function ServerStartHeal(byte FireModeNum, Pawn P, bool bClientIsReloading)
{
	if ( FireModeNum == DEFAULT_FIREMODE && !P.IsAliveAndWell() )
	{
		return;
	}

	// sync up reload status (AmmoCount is probably good enough )
	bPlayHealAndReload = bClientIsReloading;

	HealTarget = P;
	ServerStartFire(FireModeNum);
}

simulated function MissHeal( Pawn P )
{
	if( Role < ROLE_Authority )
	{
		ServerMissHeal( P );
	}
	else
	{
		`DialogManager.PlayHealMissDialog( KFPawn(Instigator), KFPawn(P) );
	}
}

unreliable server private function ServerMissHeal( Pawn P )
{
	MissHeal( P );
}

/*********************************************************************************************
 * Effects / Mesh / Animations / Sounds
 *********************************************************************************************/

/**
 * Called when damage is healed (instead of when heal anim starts)
 */
simulated function PlayFireEffects( byte FireModeNum, optional vector HitLocation )
{
	PlayFiringSound(CurrentFireMode);

	if( Instigator != none && Instigator.IsFirstPerson() )
	{
	    ShakeView();
	}
}

simulated function name GetHealAnimName(byte FireModeNum)
{
	if ( bPlayHealAndReload )
	{
		return (FireModeNum == DEFAULT_FIREMODE) ? HealTeamReloadAnim : HealSelfReloadAnim;
	}
	else
	{
		return (FireModeNum == DEFAULT_FIREMODE) ? HealTeamAnim : HealSelfAnim;
	}
}

/*********************************************************************************************
 * Timing
 *********************************************************************************************/

/** @see Weapon::GetFireInterval */
simulated function float GetFireInterval( byte FireModeNum )
{
	local name AnimName;

	if ( FireModeNum <= ALTFIRE_FIREMODE )
	{
		// Base the fire internval on the animation.  This is a little unusual, but since we're
		// in a WeaponSingleFiring state and the server/client anim are sync'ed up it's okay.
		AnimName = GetHealAnimName(FireModeNum);
		return FMax(MySkelMesh.GetAnimInterruptTime(AnimName), 0.01f);
	}
	return super.GetFireInterval( FireModeNum );
}

// The healer should only be able to refire if it's animation or interrupt has completed
simulated function bool ShouldRefire()
{
	return false;
}

/** @see Weapon::Tick */
simulated event Tick(float DeltaTime)
{
	Super.Tick(DeltaTime);

	// @todo: this could should not be called if ammo is charged
	if (Role == ROLE_Authority && AmmoCount[0] < MagazineCapacity[0])
	{
		HealAmmoRegeneration(DeltaTime);
	}

	if (Instigator != none && Instigator.WorldInfo.TimeSeconds - LastUIUpdateTime > UIUpdateInterval)
	{
		LastUIUpdateTime = Instigator.WorldInfo.TimeSeconds;   // throttle the updates so we're not spamming Actionscript with data.
		UpdateInteractionMessage();
	}

	UpdateScreenUI();
}

//Updates weither or not the "Press GBA_QuickHeal to heal" should be shown based on health, ammo and other factors
simulated function UpdateInteractionMessage()
{
	local KFPlayerController InstigatorKFPC;
	local bool bCannotBeHealed;

	//Update Interaction message	
	if (Instigator != none && Instigator.IsLocallyControlled() && Instigator.Health > 0)
	{
		InstigatorKFPC = KFPlayerController(Instigator.Controller);

		if (InstigatorKFPC == none)
		{
			return;
		}
		
		//Check if the player can heal
		bCannotBeHealed = !InstigatorKFPC.CanUseHealObject();

		if (bIsQuickHealMessageShowing)
		{
			//We use AmmoCount[0] since the healer weapon only uses this ammo.  AmmoCost[ALTFIRE_FIREMODE] is the cost to heal yourself
			if (Instigator.Health > InstigatorKFPC.LowHealthThreshold || AmmoCount[0] < AmmoCost[ALTFIRE_FIREMODE] || bCannotBeHealed)
			{
				bIsQuickHealMessageShowing = false;
				InstigatorKFPC.ReceiveLocalizedMessage(class'KFLocalMessage_Interaction', IMT_None);
			}
		}

		//We use AmmoCount[0] since the healer weapon only uses this ammo.  AmmoCost[ALTFIRE_FIREMODE] is the cost to heal yourself
		if (Instigator.Health <= InstigatorKFPC.LowHealthThreshold && AmmoCount[0] >= AmmoCost[ALTFIRE_FIREMODE] && !bCannotBeHealed)
		{
			bIsQuickHealMessageShowing = true;
			InstigatorKFPC.ReceiveLocalizedMessage(class'KFLocalMessage_Interaction', IMT_HealSelfWarning);
		}
	}
}

/** Only update the screen screen if we have the healer equipped and it's value is different than our AmmoCount */
simulated function UpdateScreenUI()
{
	if ( Instigator != none && Instigator.IsLocallyControlled() && Instigator.Weapon == self )
	{
		if ( ScreenUI != none && ScreenUI.CurrentCharge != AmmoCount[0] )
		{
		 	ScreenUI.SetCharge( AmmoCount[0] );
	 	}
	}
}

/*********************************************************************************************
 * State Active
 * A Weapon this is being held by a pawn should be in the active state.  In this state,
 * a weapon should loop any number of idle animations, as well as check the PendingFire flags
 * to see if a shot has been fired.
 *********************************************************************************************/

simulated state Active
{
	simulated event Tick(float DeltaTime)
	{
		// Caution - Super will skip our global, but global will skip super's state function!
		Global.Tick(DeltaTime);

		// will trace each call, but it's decently fast (zero-extent)
		UpdateHealTarget();
		UpdateScreenUI();
	}

	simulated function PlayIdleAnim()
	{
		local int IdleIndex;

		if ( Instigator != none && Instigator.IsFirstPerson() )
		{
			// Update target immediately and enable tick (first time)
			UpdateHealTarget(true);

			if( HealTarget != None )
			{
				PlayAnimation(IdleReadyAnim, 0.0, true, 0.2);
			}
			else
			{
				IdleIndex = Rand(IdleAnims.Length);
				PlayAnimation(IdleAnims[IdleIndex], 0.0, true, 0.2);
			}
		}
	}
}

/**
 * Find friendly pawns within healing range
 * Network: Local Player
 */
simulated function UpdateHealTarget(optional bool bSkipOnAnimEnd)
{
	local bool bHasHealTarget;
	local vector AimDir, StartTrace, Projection;
	local Pawn P;
	local KFPawn KFP;
	local float DistSQ, FOV, HealTargetRating, BestHealTargetRating;

	// prevent state from changing too often (also a optimization)
	if ( `TimeSince(LastReadyHealTime) < 0.2f )
	{
		return;
	}

	bHasHealTarget = (HealTarget != None);
	HealTarget = None;

	// define range to use for CalcWeaponFire()
	StartTrace = Instigator.GetWeaponStartTraceLocation();
	AimDir = vector( GetAdjustedAim(StartTrace) );

	// consider adding this to KFMeleeHelperWeapon so it can be used by other weapons
	foreach WorldInfo.AllPawns( class'Pawn', P )
	{
		if( P != Instigator && P.GetTeamNum() == Instigator.GetTeamNum() && P.IsAliveAndWell() )
		{
			KFP = KFPawn(P);
			if (KFP != none && !KFP.CanBeHealed())
			{
				continue;
			}

			Projection = P.Location - StartTrace;

			DistSQ = VSizeSQ( Projection );
			if( DistSQ > HealingRangeSQ )
			{
				continue;
			}

			FOV = AimDir dot Normal( Projection );
			if( FOV > 0.4f )
			{
				HealTargetRating = FOV + ( 0.4f * (1.f - (DistSQ / HealingRangeSQ)) );
				if( HealTargetRating > BestHealTargetRating && FastTrace(P.Location, StartTrace) )
				{
					BestHealTargetRating = HealTargetRating;
					HealTarget = P;
					LastValidHealTarget = P;
					LastReadyHealTime = WorldInfo.TimeSeconds;
				}
			}
		}
	}

	// refresh idle anim if ready state has changed
	if ( !bSkipOnAnimEnd && bHasHealTarget != (HealTarget != None) )
	{
		OnAnimEnd(none,0.f,0.f);
	}
}

/*********************************************************************************************
 * State WeaponHealing
 * Firing mode state for healer items.
 *********************************************************************************************/

simulated state WeaponHealing extends WeaponSingleFiring
{
	simulated function byte GetWeaponStateId()
	{
		return WEP_Heal;
	}

	/** "fires" in EndState instead of begin */
    simulated event BeginState( Name PreviousStateName )
	{
		`LogInv("PreviousStateName:" @ PreviousStateName);

        // Don't let a weak zed grab us while in the middle of a heal
        SetWeakZedGrabCooldownOnPawn(HealAttemptWeakZedGrabCooldown);

		PlayHeal();
		TimeWeaponFiring( CurrentFireMode );

		NotifyBeginState();
	}

	simulated function PlayHeal()
	{
		local name AnimName;
		AnimName = GetHealAnimName(CurrentFireMode);

		if( Instigator != none && Instigator.IsFirstPerson() )
		{
			if ( AnimName != '' )
			{
				PlayAnimation(AnimName,,,FireTweenTime);
			}
		}
	}

	simulated function RefireCheckTimer()
	{
		// Do actual healing and start recharging used ammo
		FireAmmunition();
		PerformReload();

		HandleFinishedFiring();
	}

	simulated function EndState(Name NextStateName)
	{
		Super.EndState(NextStateName);
		NotifyEndState();
	}
}

/*********************************************************************************************
 * State WeaponQuickHeal
 * Special firing state that combines Equip, Heal, and PutAway into one action
 *********************************************************************************************/

// Global defs for state code
simulated function QuickHealEndTimer();
simulated function QuickHealFireTimer();

simulated state WeaponQuickHeal extends WeaponHealing
{
	simulated function byte GetWeaponStateId()
	{
		return WEP_HealQuick;
	}

    simulated event BeginState( Name PreviousStateName )
	{
		Super.BeginState(PreviousStateName);
		bQuickHealMode = false;
	}

	simulated function EndState(Name NextStateName)
	{
		Super.EndState(NextStateName);
		ClearTimer(nameof(QuickHealEndTimer));
	}

	/** Override normal firing state timers */
	simulated function TimeWeaponFiring( byte FireModeNum )
	{
		local float Duration, QuickHealFireTime;
		local name AnimName;

		AnimName = GetHealAnimName(FireModeNum);

		// Set a end state timer seperate from RefireCheckTimer
		Duration = MySkelMesh.GetAnimLength(AnimName);
		if ( Duration > 0 )
		{
			SetTimer(Duration, false, nameof(QuickHealEndTimer));
		}

		// Use interrupts in the animation to determine when to fire
		QuickHealFireTime = FMax(MySkelMesh.GetAnimInterruptTime(AnimName), 0.01f);
		SetTimer(QuickHealFireTime, false, nameof(QuickHealFireTimer));
	}

	/** Handle state exit */
	simulated function QuickHealEndTimer()
	{
		KFInventoryManager(InvManager).SwitchToLastWeapon();

		// Start weapon put away
		PutDownWeapon();
		// Skip anim and go straight to inactive
		WeaponIsDown();
	}

	/** Do actual healing and start recharging used ammo */
	simulated function QuickHealFireTimer()
	{
		FireAmmunition();
		PerformReload();
	}

	simulated function name GetHealAnimName(byte FireModeNum)
	{
		return QuickHealAnim;
	}
}

/** Handle bQuickHealMode */
simulated function Activate()
{
	Super.Activate();
	
	HealTarget = none; //clear heal target so that distance exploit cannot happen

	if ( bQuickHealMode && Instigator.IsLocallyControlled() )
	{
		SetCurrentFireMode(ALTFIRE_FIREMODE);
		GotoState('WeaponQuickHeal');

		if ( Role < ROLE_Authority )
		{
			ServerStartQuickHeal();
		}
	}
}

/** Notify server of quick heal */
reliable server private function ServerStartQuickHeal()
{
	SetCurrentFireMode(ALTFIRE_FIREMODE);
	GotoState('WeaponQuickHeal');
}

/** Returns the number of players active in the game */
function int GetActivePlayerCount()
{
	local KFPlayerController KFPC;
	local int totalPlayers;

	totalPlayers = 0;
	foreach WorldInfo.AllControllers( class'KFPlayerController', KFPC )
	{
		if( KFPC.bIsAchievementPlayer )
		{
			totalPlayers++;
		}
	}

	return totalPlayers;
}

defaultproperties
{
	UIUpdateInterval=1.f
	FireTweenTime=0.3f
	HealingRangeSQ=23000.f
	StandAloneHealAmount=50.0f
    ScreenUIClass=class'KFGFxWorld_HealerScreen'

	// Aim Assist
	AimCorrectionSize=0.f
	bTargetAdhesionEnabled=false

	// Heal Friendly
	FiringStatesArray(DEFAULT_FIREMODE)=WeaponHealing
	WeaponFireTypes(DEFAULT_FIREMODE)=EWFT_Custom
	FireInterval(DEFAULT_FIREMODE)=+0.2
	InstantHitDamage(DEFAULT_FIREMODE)=20.0
	InstantHitDamageTypes(DEFAULT_FIREMODE)=class'KFDT_Healing'
	AmmoCost(DEFAULT_FIREMODE)=100
	HealAttemptWeakZedGrabCooldown=1.0

	// Heal Self
	FiringStatesArray(ALTFIRE_FIREMODE)=WeaponHealing
	WeaponFireTypes(ALTFIRE_FIREMODE)=EWFT_Custom
	FireInterval(ALTFIRE_FIREMODE)=+2.0
	InstantHitDamage(ALTFIRE_FIREMODE)=20.0
	InstantHitDamageTypes(ALTFIRE_FIREMODE)=class'KFDT_Healing'
	AmmoCost(ALTFIRE_FIREMODE)=100

	// Ammo
	MagazineCapacity[0]=100
	SpareAmmoCapacity[0]=0
	bCanBeReloaded=true
	bReloadFromMagazine=true
	bInfiniteSpareAmmo=true
	HealSelfRechargeSeconds=15
	HealOtherRechargeSeconds=7.5
	bAllowClientAmmoTracking=false

    // Inventory
	GroupPriority=6
	InventoryGroup=IG_Equipment

	// Fire Effects
	WeaponFireSnd(DEFAULT_FIREMODE)=(DefaultCue=AkEvent'WW_WEP_SA_Syringe.Play_WEP_SA_Syringe_3P_Fire_Single', FirstPersonCue=AkEvent'WW_WEP_SA_Syringe.Play_WEP_SA_Syringe_1P_Fire_Single')
	WeaponFireSnd(ALTFIRE_FIREMODE)=(DefaultCue=AkEvent'WW_WEP_SA_Syringe.Play_WEP_SA_Syringe_3P_Fire_Single', FirstPersonCue=AkEvent'WW_WEP_SA_Syringe.Play_WEP_SA_Syringe_1P_Fire_Single')

	RechargeCompleteSound=AkEvent'WW_WEP_SA_Syringe.Play_WEP_SA_Syringe_Charged'

	AssociatedPerkClasses(0)=none
}
