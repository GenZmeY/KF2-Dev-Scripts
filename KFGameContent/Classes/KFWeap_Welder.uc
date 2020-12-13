//=============================================================================
// KFWeap_Healer_Syringe
//=============================================================================
// Weapon class used for the healer
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
// - Andrew "Strago" Ladenberger
//=============================================================================
class KFWeap_Welder extends KFWeapon
	hidedropdown;

/** If set, automatically equip the previous weapon when leaving a door trigger */
var() bool bAutoUnequip;

/*********************************************************************************************
 @name Firing
********************************************************************************************* */

/** Maximum range to find Door */
var() float WeldingRange;
/** How many points to add to a door's weld integrity per use (use rate determined by FireInterval) */
var() float FastenRate;
/** How many points to subtract from a door's weld integrity per use (use rate determined by FireInterval) */
var() float UnFastenRate;
/** Percent repaired per fire interval */
var() float RepairRate;

/** Give the welder extra range when it has a WeldTarget to avoid the ready animation
activating / deactivating on door that is is currently being damaged */
var const float ExtraWeldingRange;

/** How long (in seconds) it takes to recharge ammo by 1 unit */
var() float AmmoRechargeRate;

/*********************************************************************************************
 @name Animations
********************************************************************************************* */

/** animation names */
var name IdleWeldAnim;
var name WeldOpenAnim;
var name WeldCloseAnim;

/** Reference to the door we're pointing at */
var KFWeldableComponent WeldTarget;

/** Store last update to we can prevent idle->ready->idle to quickly */
var float LastTraceHitTime;

/*********************************************************************************************
 @name Screen
********************************************************************************************* */
var class<KFGFxWorld_WelderScreen> ScreenUIClass;
var KFGFxWorld_WelderScreen ScreenUI;

simulated event PreBeginPlay()
{
	local KFGameEngine KFGEngine;

	Super.PreBeginPlay();

	KFGEngine = KFGameEngine( Class'KFGameEngine'.static.GetEngine() );

	if(KFGEngine != none)
	{
		SetShownInInventory(KFGEngine.bShowWelderInInv);
	}
}

simulated function SetShownInInventory(bool bValue)
{
	InventoryGroup= bValue ? IG_Equipment : IG_None ;
	bAutoUnequip = !bValue;
}

/** Turn on the UI screen when we equip the healer */
simulated function AttachWeaponTo( SkeletalMeshComponent MeshCpnt, optional Name SocketName )
{
	super.AttachWeaponTo( MeshCpnt, SocketName );

	if( Instigator != none && Instigator.IsLocallyControlled() )
	{
		// Create the screen's UI piece
		if (ScreenUI == none)
		{
			ScreenUI = new( self ) ScreenUIClass;
			ScreenUI.Init();
			ScreenUI.Start(true);
		}

		if ( ScreenUI != none)
		{
			ScreenUI.SetPause(false);
			ScreenUI.SetCharge( AmmoCount[0] );
			ScreenUI.SetIntegrity( 255 );
		}
	}
}

/** Turn off the UI screen when we unequip the healer */
simulated function DetachWeapon()
{
	super.DetachWeapon();
	if ( Instigator != none && Instigator.IsLocallyControlled() && ScreenUI != none )
	{
		ScreenUI.SetPause();
	}
}

/** @see Weapon::Tick */
simulated event Tick(float DeltaTime)
{
	Super.Tick(DeltaTime);

	UpdateScreenUI();
}

simulated event Destroyed()
{
	if ( Instigator != none && Instigator.IsLocallyControlled() && ScreenUI != none)
	{
		ScreenUI.Close();
	}
	super.Destroyed();
}

/** Only update the screen screen if we have the welder equipped and it's screen values have changed */
simulated function UpdateScreenUI()
{
	local float WeldPercentageFloat;
	local byte WeldPercentage;

	if ( Instigator != none && Instigator.IsLocallyControlled() && Instigator.Weapon == self )
	{
		if ( ScreenUI != none )
		{
			// Check if our current ammo reading has changed
			if ( ScreenUI.CurrentCharge != AmmoCount[0] )
			{
				ScreenUI.SetCharge( AmmoCount[0] );
			}

			if ( WeldTarget != none )
			{
				// Address rounding errors in UI
				WeldPercentageFloat = WeldTarget.GetWeldPct();
				if( WeldPercentageFloat < 1.f && WeldPercentageFloat > 0.f )
				{
					WeldPercentageFloat = 1.f;
				}
				else if( WeldPercentageFloat > 99.f && WeldPercentageFloat < 100.f )
				{
					WeldPercentageFloat = 99.f;
				}

				WeldPercentage = byte( WeldPercentageFloat );
				// Check if our weld integrity has changed
				if ( WeldPercentage != ScreenUI.IntegrityPercentage )
				{
		        	ScreenUI.SetIntegrity( WeldPercentage );
		     	}
			}
			// Remove our weld value
			else if ( ScreenUI.IntegrityPercentage != 255 )
			{
		    	ScreenUI.SetIntegrity( 255 );
			}
		}
	}
}

/*********************************************************************************************
 * @name Ammunition
 *********************************************************************************************/

simulated function bool HasAnyAmmo()
{
	return true;
}

simulated function bool HasAmmo( byte FireModeNum, optional int Amount )
{
	if ( FireModeNum == DEFAULT_FIREMODE || FireModeNum == ALTFIRE_FIREMODE )
	{
		if ( AmmoCount[0] >= AmmoCost[FireModeNum])
		{
			// Requires a valid WeldTarget (see ServerSetWeldTarget)
			return ( WeldTarget != None && CanWeldTarget(FireModeNum) );
		}
		return false;
	}

	return Super.HasAmmo(FireModeNum, Amount);
}

/** Returns true if weapon should be auto-reloaded */
simulated function bool ShouldAutoReload(byte FireModeNum)
{
	return false;
}

/*********************************************************************************************
 @name Firing / Projectile
********************************************************************************************* */

/** Unweld with RM/L2 */
simulated function SetIronSights(bool bNewIronSights)
{
	if ( !Instigator.IsLocallyControlled()  )
	{
		return;
	}

	if ( bNewIronSights )
	{
		StartFire(ALTFIRE_FIREMODE);
	}
	else
	{
		StopFire(ALTFIRE_FIREMODE);
	}
}

/** Also unweld with MM/R1 */
simulated function AltFireMode()
{
	if ( !Instigator.IsLocallyControlled() )
	{
		return;
	}

	// StartFire - StopFire called from KFPlayerInput
	StartFire(ALTFIRE_FIREMODE);
}

/**
 * @see Weapon::StartFire
 */
simulated function StartFire(byte FireModeNum)
{
	// Notify server of the weld target we plan to use
	if ( FireModeNum == DEFAULT_FIREMODE || FireModeNum == ALTFIRE_FIREMODE )
	{
		if ( Role < ROLE_Authority )
		{
			ServerSetWeldTarget(WeldTarget, false);
		}
	}

	Super.StartFire(FireModeNum);
}

/**
 * If the weapon isn't an instant hit, or a simple projectile, it should use the type EWFT_Custom.  In those cases
 * this function will be called.  It should be subclassed by the custom weapon.
 */
simulated function CustomFire()
{
	local float CurrentFastenRate, CurrentUnfastenRate;
	WeldTarget = TraceWeldables();
	// Fasten/Unfasten the door
	if ( Role == ROLE_Authority )
	{
		if( !IsTimerActive(nameof(RechargeAmmo)) )
		{
			SetTimer(AmmoRechargeRate, true, nameof(RechargeAmmo));
		}

		if(WeldTarget != None)
		{
			CurrentFastenRate = FastenRate;
			CurrentUnfastenRate = UnFastenRate;

			GetPerk().ModifyWeldingRate(CurrentFastenRate, CurrentUnfastenRate);

			if ( WeldTarget.bIsDestroyed && !WeldTarget.Owner.IsA('KFRepairableActor') )
			{
				WeldTarget.Repair(RepairRate, KFPawn(Instigator));
			}
			else if ( CurrentFireMode == DEFAULT_FIREMODE )
			{
				WeldTarget.Weld(CurrentFastenRate, KFPawn(Instigator));
			}
			else
			{
				WeldTarget.Weld(CurrentUnfastenRate, KFPawn(Instigator));
			}
		}
	}

	// On the local player check to see if we should stop firing
	// It makes sense to do this in ShouldRefire(), but there is no guarantee
	// that it will sync on server/client.  So, use StopFire() instead.
	if ( Instigator.IsLocallyControlled() )
	{
		if ( WeldTarget == none || !CanWeldTarget() )
		{
			// TargetDoor is no longer valid
			StopFire(CurrentFireMode);
		}
	}
}

simulated function bool CanWeldTarget( optional int FireModeNum=CurrentFireMode )
{
	local KFPerk WelderPerk;

	WelderPerk = GetPerk();

	if ( FireModeNum == DEFAULT_FIREMODE && !WeldTarget.CanBeWelded() )
	{
		if( WelderPerk != none && WelderPerk.CanExplosiveWeld() )
		{
			return WeldTarget.CanBeDemoWelded();
		}

		return false;
	}
	else if ( FireModeNum == ALTFIRE_FIREMODE && !WeldTarget.CanBeUnwelded() )
	{
		return false;
	}
	return true;
}

/** Ammo regen timer */
function RechargeAmmo()
{
	if ( AmmoCount[0] < MagazineCapacity[0] )
	{
		AmmoCount[0]++;

		// If we are holding down the mouse when we regen enough ammo, fire again
		if ( AmmoCount[0] == AmmoCost[0] )
		{
		 	Refire();
			if ( !Instigator.IsLocallyControlled() )
			{
				ClientRefire();
			}
		}
	}
	else
	{
	 	ClearTimer(nameof(RechargeAmmo));
	}
}

/**	If we are holding down the mouse when we regen enough ammo, fire again */
simulated function Refire()
{
	local byte i;
    // if either of the fire modes are pending, perform them
	for( i=0; i<=ALTFIRE_FIREMODE; i++ )
	{
		if( PendingFire(i) )
		{
			SendToFiringState(i);
			break;
		}
	}
}

/** RechargeAmmo is called on authority only. When we have enough ammo to fire again
*	we want to make sure that the client plays his animations and fire effects */
reliable client function ClientRefire()
{
 	Refire();
}

/** If we recieve a valid door target after the fire key was already pressed down */
simulated function CheckDelayedStartFire()
{
	local bool bNotifyServer;

	if ( WeldTarget != None )
	{
		if( PendingFire(DEFAULT_FIREMODE) )
		{
			BeginFire(DEFAULT_FIREMODE);
			bNotifyServer = true;
		}
		else if( PendingFire(ALTFIRE_FIREMODE) )
		{
			BeginFire(ALTFIRE_FIREMODE);
			bNotifyServer = true;
		}

		if ( bNotifyServer && Role < ROLE_Authority )
		{
			ServerSetWeldTarget(WeldTarget, true);
		}
	}
}

/*********************************************************************************************
 @name Animation
********************************************************************************************* */

/*********************************************************************************************
 @name WeldTarget
********************************************************************************************* */

/**
 * Find doors within welding range
 * Network: Local Player
 */
simulated function bool TickWeldTarget()
{
	local KFWeldableComponent PreviousTarget;

	// prevent state from changing too often (also a optimization)
	if ( `TimeSince(LastTraceHitTime) < 0.2f )
	{
		return false;
	}

	PreviousTarget = WeldTarget;
	WeldTarget = TraceWeldables();

	// refresh idle anim if TargetDoor has changed
	if ( PreviousTarget != WeldTarget )
	{
		return PlayReadyTransition(PreviousTarget);
	}

	return false;
}

/** Network: All */
simulated function KFWeldableComponent TraceWeldables()
{
	local KFWeldableComponent WeldableComponent;
	local vector HitLoc, HitNorm, StartTrace, EndTrace, AdjustedAim;
	local bool bIsRepairableActor;
	local KFDoorActor WeldableDoor;

	// define range to use for CalcWeaponFire()
	StartTrace = Instigator.GetWeaponStartTraceLocation();
	AdjustedAim = vector(GetAdjustedAim(StartTrace));
	EndTrace = StartTrace + AdjustedAim * WeldingRange;

	// Give the welder extra range when it has a WeldTarget to avoid the ready animation
	// activating / deactivating on door that is is currently being damaged
	if( WeldTarget != none )
	{
		EndTrace += AdjustedAim * ExtraWeldingRange;
	}

	// find weldable (trace against basic cylinder)
	foreach GetTraceOwner().TraceActors(class'KFWeldableComponent', WeldableComponent, HitLoc, HitNorm, EndTrace, StartTrace)
	{
		if (WeldableComponent.Owner == none)
		{
			// should never happen, right?
			continue;
		}

		// trace against owner for more accuracy
		if (Trace(HitLoc, HitNorm, EndTrace, StartTrace, true) != WeldableComponent.Owner)
		{
			continue;
		}

		bIsRepairableActor = WeldableComponent.Owner.IsA('KFRepairableActor');

		if (!bIsRepairableActor && WeldableComponent.bIsDestroyed )
		{
			continue;
		}

		if (bIsRepairableActor && !WeldableComponent.CanBeWelded())
		{
			continue;
		}

		LastTraceHitTime = WorldInfo.TimeSeconds;
		return WeldableComponent;
	}

	WeldableDoor = FindRepairableDoor();
	return WeldableDoor != none ? WeldableDoor.WeldableComponent : none;
}

/** Try to find a nearby destroyed door.  Can't use TraceActors because the door geometry is gone! */
simulated function KFDoorActor FindRepairableDoor()
{
	local KFDoorTrigger DoorTrigger;
	local KFInterface_Usable UsableTrigger;
	local float FacingDot;
	local vector Dir2d;
	local KFPlayerController KFPC;

	// On local player we can detect the interaction message and early out for perf
	// On the server this is only called when firing (instead of on tick) so it's not as bad,
	// but if needed we could add a LastInteractionMessage var to UpdateInteractionMessages()
	if ( Instigator.IsLocallyControlled() )
	{
		KFPC = KFPlayerController(Instigator.Controller);
		if ( KFPC.MyGFxHUD.CurrentInteractionIndex != IMT_RepairDoor )
		{
			return None;
		}
	}

	UsableTrigger = class'KFPlayerController'.static.GetCurrentUsableActor(Instigator);
	DoorTrigger = KFDoorTrigger(UsableTrigger);

	// if we didn't find a door that could be welded, maybe there is one that can be repaired?
	if ( DoorTrigger != None && DoorTrigger.DoorActor != None && DoorTrigger.DoorActor.bIsDestroyed )
	{
		// zero Z to give us a 2d dot product
		Dir2d = Normal2d(DoorTrigger.DoorActor.Location - Instigator.Location);
		FacingDot = vector(Instigator.Rotation) dot (Dir2d);
		if ( FacingDot > 0.87 )
		{
			return DoorTrigger.DoorActor;
		}
	}

	return None;
}

/** Notify server of new WeldTarget for 'HasAmmo' */
reliable server private function ServerSetWeldTarget(KFWeldableComponent NewTarget, bool bDelayedStart)
{
	WeldTarget = NewTarget;
	
	if ( bDelayedStart )
	{
		CheckDelayedStartFire();
	}
}

/** Play a transition animation between idle ready states */
simulated function bool PlayReadyTransition(KFWeldableComponent PreviousTarget)
{
	local name AnimName;
	local float Duration;

	if( WeldTarget != None )
	{
		AnimName = WeldOpenAnim;
		// set timer to begin firing if PendingFire is already set
		if ( PreviousTarget == None )
		{
			Duration = MySkelMesh.GetAnimLength(AnimName);
			SetTimer(FMax(Duration - 0.2f, 0.01f), false, nameof(CheckDelayedStartFire));
		}
	}
	else if( PreviousTarget != None )
	{
		AnimName = WeldCloseAnim;
	}

	if ( AnimName != '' )
	{
		PlayAnimation(AnimName);
		return true;
	}

	return false;
}

/*********************************************************************************************
 * state Inactive
 * This state is the default state.  It needs to make sure Zooming is reset when entering/leaving
 *********************************************************************************************/

auto state Inactive
{
	simulated function BeginState(name PreviousStateName)
	{
		Super.BeginState(PreviousStateName);
		WeldTarget = none;
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
		
		if ( Instigator != none && Instigator.IsLocallyControlled() )
		{
			// local player - find nearbydoors
			TickWeldTarget();	// will trace each call, but it's decently fast (zero-extent)
			UpdateScreenUI();

			if (bAutoUnequip)
			{
				TickAutoUnequip();
			}
		}
	}

	simulated event OnAnimEnd(AnimNodeSequence SeqNode, float PlayedTime, float ExcessTime)
	{
		local bool bPlayingAnim;

		if ( Instigator != none && Instigator.IsLocallyControlled() )
		{
			// Update target immediately and enable tick (first time)
			bPlayingAnim = TickWeldTarget();

			// if animation didn't play in UpdateWeldTarget, play idle normally
			if ( !bPlayingAnim )
			{
				PlayIdleAnim();
			}
		}
	}

	simulated function PlayIdleAnim()
	{
		local int IdleIndex;

		if ( Instigator != none && Instigator.IsLocallyControlled() )
		{
			if( WeldTarget != None )
			{
				PlayAnimation(IdleWeldAnim, 0.0, true, 0.2);
			}
			else
			{
				IdleIndex = Rand(IdleAnims.Length);
				PlayAnimation(IdleAnims[IdleIndex], 0.0, true, 0.2);
			}
		}
	}
}

/** Automatically equip previous weapon when leaving a door trigger */
simulated function bool TickAutoUnequip()
{
	local Trigger_PawnsOnly Trigger;
	local KFInventoryManager KFIM;

	ForEach Instigator.TouchingActors(class'Trigger_PawnsOnly', Trigger)
	{
		if(Trigger.IsA('KFDoorTrigger') || Trigger.IsA('KFRepairableActorTrigger') || Trigger.IsA('KFWeldableTrigger'))
		{
			return FALSE;
		}
	}

	KFIM = KFInventoryManager( Instigator.InvManager );
	if ( KFIM != None )
	{
		KFIM.SwitchToLastWeapon();
		return TRUE;
	}

	return FALSE;
}

/*********************************************************************************************
 * state WeaponWelding
 * This is the default Firing State.  It's performed on both the client and the server.
 *********************************************************************************************/

simulated state WeaponWelding extends WeaponFiring
{
	simulated function byte GetWeaponStateId()
	{
		return WEP_Weld;
	}

	simulated function BeginState(Name PrevStateName)
	{
		super.BeginState(PrevStateName);
		NotifyBeginState();
	}

	simulated function EndState(Name NextStateName)
	{
		super.EndState(NextStateName);
		NotifyEndState();
	}
}

/*********************************************************************************************
* state WeaponSprinting
* When the pawn is sprinting, they need to check if they should auto unequip the welder.
*********************************************************************************************/

simulated state WeaponSprinting
{
	simulated event Tick(float DeltaTime)
	{
		Global.Tick(DeltaTime);

		if (Instigator != none && Instigator.IsLocallyControlled())
		{
			if (bAutoUnequip)
			{
				TickAutoUnequip();
			}
		}
	}
}

defaultproperties
{
	InventoryGroup=IG_None
	bCanThrow=false
	bDropOnDeath=false
	bAutoUnequip=true

	PlayerViewOffset=(X=20.0,Y=10,Z=-10)

	FireTweenTime=0.2f
	WeldingRange=150.f
	ExtraWeldingRange=10
	FastenRate=68.f
	UnFastenRate=-110.f
	RepairRate=0.03f  //0.05f
	IdleWeldAnim=Idle_Weld
	WeldOpenAnim=Weld_On
	WeldCloseAnim=Weld_Off

	// Content
	PackageKey="Welder"
	FirstPersonMeshName="WEP_1P_Welder_MESH.Wep_1stP_Welder_Rig"
	FirstPersonAnimSetNames(0)="WEP_1P_Welder_ANIM.Wep_1st_Welder_Anim"
	AttachmentArchetypeName="WEP_Welder_ARCH.Welder_3P"
	MuzzleFlashTemplateName="WEP_Welder_ARCH.Wep_Welder_MuzzleFlash"

	// Aim Assist
	AimCorrectionSize=0.f
	bTargetAdhesionEnabled=false

	// Ammo
	MagazineCapacity[0]=100
	SpareAmmoCapacity[0]=0
	bInfiniteSpareAmmo=true
	AmmoRechargeRate=0.08f
	bAllowClientAmmoTracking=false

	// Grouping
	GroupPriority=5
	WeaponSelectTexture=Texture2D'ui_weaponselect_tex.UI_WeaponSelect_Welder'

	// Weld
	FireModeIconPaths(DEFAULT_FIREMODE)=Texture2D'ui_firemodes_tex.UI_FireModeSelect_Electricity'
	FiringStatesArray(DEFAULT_FIREMODE)=WeaponWelding
	WeaponFireTypes(DEFAULT_FIREMODE)=EWFT_Custom
	FireInterval(DEFAULT_FIREMODE)=+0.2
	AmmoCost(DEFAULT_FIREMODE)=7

	// Un-Weld
	FireModeIconPaths(ALTFIRE_FIREMODE)=Texture2D'ui_firemodes_tex.UI_FireModeSelect_Electricity'
	FiringStatesArray(ALTFIRE_FIREMODE)=WeaponWelding
	WeaponFireTypes(ALTFIRE_FIREMODE)=EWFT_Custom
	FireInterval(ALTFIRE_FIREMODE)=+0.2
	AmmoCost(ALTFIRE_FIREMODE)=7

	// Fire Effects
	WeaponFireSnd(DEFAULT_FIREMODE)=(DefaultCue=AkEvent'WW_WEP_SA_Welder.Play_WEP_SA_Welder_Fire_Loop_M', FirstPersonCue=AkEvent'WW_WEP_SA_Welder.Play_WEP_SA_Welder_Fire_Loop_S')
	WeaponFireSnd(ALTFIRE_FIREMODE)=(DefaultCue=AkEvent'WW_WEP_SA_Welder.Play_WEP_SA_Welder_Fire_Loop_M', FirstPersonCue=AkEvent'WW_WEP_SA_Welder.Play_WEP_SA_Welder_Fire_Loop_S')

	// BASH_FIREMODE
	InstantHitDamageTypes(BASH_FIREMODE)=class'KFDT_Bludgeon_Welder'
	InstantHitDamage(BASH_FIREMODE)=20

	// Advanced (High RPM) Fire Effects
	bLoopingFireAnim(DEFAULT_FIREMODE)=true
	bLoopingFireAnim(ALTFIRE_FIREMODE)=true
	bLoopingFireSnd(DEFAULT_FIREMODE)=true
	bLoopingFireSnd(ALTFIRE_FIREMODE)=true
	WeaponFireLoopEndSnd(DEFAULT_FIREMODE)=(DefaultCue=AkEvent'WW_WEP_SA_Welder.Stop_WEP_SA_Welder_Fire_Loop_M', FirstPersonCue=AkEvent'WW_WEP_SA_Welder.Stop_WEP_SA_Welder_Fire_Loop_S')

    ScreenUIClass=class'KFGFxWorld_WelderScreen'

	AssociatedPerkClasses(0)=none

	bStorePreviouslyEquipped=false
}
