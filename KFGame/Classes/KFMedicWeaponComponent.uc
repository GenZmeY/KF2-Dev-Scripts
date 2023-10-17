//=============================================================================
// KFMedicWeaponComponent
//=============================================================================
// Actor that encapsulates the management and replication of medic weapon info.
// Enables any weapon to be medic.
//=============================================================================
// Killing Floor 2
// Copyright (C) 2019 Tripwire Interactive LLC
//=============================================================================
class KFMedicWeaponComponent extends Actor
	abstract;

/** Fire mode 0 is the default weapon firing. */
const DEFAULT_FIREMODE			= 0;
/** Fire mode 1 is the alternate weapon firing. */
const ALTFIRE_FIREMODE			= 1;

var KFWeapon KFW;
var byte AmmoCost;
var bool bOpticsPaused;

/*********************************************************************************************
 * @name Healing Darts
 ********************************************************************************************* */

/** DamageTypes for Instant Hit Weapons */
var	class<DamageType> HealingDartDamageType;

/** How much to heal for when using this weapon */
var int	HealAmount;

/** How many points of heal ammo to recharge per second */
var float HealFullRechargeSeconds;

/** Keeps track of incremental healing since we have to heal in whole integers */
var float HealingIncrement;

/** How many points of heal ammo to recharge per second. Calculated from the HealFullRechargeSeconds */
var float HealRechargePerSecond;

/** The sound of the healing dart hitting someone they will heal */
var AKEvent	HealImpactSoundPlayEvent;

/** The sound of the healing dart hitting someone they will hurt */
var AKEvent	HurtImpactSoundPlayEvent;

/** Sound to play when the weapon is fired */
var WeaponFireSndInfo DartFireSnd;

const ShootDartAnim	= 'Shoot_Dart';
const ShootDartIronAnim	= 'Shoot_Iron_Dart';

/** How long after we shoot a healing dart before a zed can grab us.
  * Prevents us from missing healing shots from being grabbed */
var float HealDartShotWeakZedGrabCooldown;

/** Recoil override for healing dart alt-fire */
var	int	DartMaxRecoilPitch;
var	int DartMinRecoilPitch;
var	int	DartMaxRecoilYaw;
var	int	DartMinRecoilYaw;

/** Controller rumble override for healing dart. */
var ForceFeedbackWaveform HealingDartWaveForm;

var repnotify byte HealingDartAmmo;

var bool bRechargeHealAmmo;

/*********************************************************************************************
 @name Optics UI
********************************************************************************************* */

var class<KFGFxWorld_MedicOptics> OpticsUIClass;
var KFGFxWorld_MedicOptics OpticsUI;

/** The last updated value for our ammo - Used to know when to update our optics ammo */
var byte StoredPrimaryAmmo;
var byte StoredSecondaryAmmo;

/*********************************************************************************************
 @name methods
********************************************************************************************* */

replication
{
	if (bNetDirty && bRechargeHealAmmo)
		HealingDartAmmo;
}

simulated event ReplicatedEvent(name VarName)
{
	if (VarName == nameof(HealingDartAmmo))
	{
		KFW.AmmoCount[ALTFIRE_FIREMODE] = HealingDartAmmo;
	}
	else
	{
		Super.ReplicatedEvent(VarName);
	}
}

simulated function Init(KFWeapon InKFW, byte InAmmoCost)
{
	KFW = InKFW;
	Instigator = InKFW.Instigator;
	AmmoCost = InAmmoCost;
}

simulated event Tick(float DeltaTime)
{
	super.Tick(DeltaTime);
	if(KFW != none)
	{
		if (KFW.AmmoCount[ALTFIRE_FIREMODE] < KFW.MagazineCapacity[ALTFIRE_FIREMODE])
		{
			HealAmmoRegeneration(DeltaTime);
		}
	}
	if(Instigator != none)
	{
		if (Instigator.IsLocallyControlled() && Instigator.Weapon == KFW)
		{
			UpdateOpticsUI();
		}
	}
}

/*********************************************************************************************
 * @name Healing Darts
 ********************************************************************************************* */

/** Start the heal recharge cycle */
function StartHealRecharge()
{
	local KFPerk InstigatorPerk;
	local float UsedHealRechargeTime;

	if (!bRechargeHealAmmo)
	{
		return;
	}

	if (Role == ROLE_Authority)
	{
		InstigatorPerk = KFW.GetPerk();
		UsedHealRechargeTime = HealFullRechargeSeconds;
		UsedHealRechargeTime *= KFW.static.GetUpgradeHealRechargeMod(KFW.CurrentWeaponUpgradeIndex);

        InstigatorPerk.ModifyHealerRechargeTime(UsedHealRechargeTime);
        HealRechargePerSecond = KFW.MagazineCapacity[ALTFIRE_FIREMODE] / UsedHealRechargeTime;
		HealingIncrement = 0;
	}
}

function HealAmmoRegeneration(float DeltaTime)
{
	if (!bRechargeHealAmmo)
	{
		return;
	}

	if (Role == ROLE_Authority)
	{
		HealingIncrement += HealRechargePerSecond * DeltaTime;

		if (HealingIncrement >= 1.0 && KFW.AmmoCount[ALTFIRE_FIREMODE] < KFW.MagazineCapacity[ALTFIRE_FIREMODE])
		{
			KFW.AmmoCount[ALTFIRE_FIREMODE]++;
			HealingIncrement -= 1.0;

			// Heal ammo regen is only tracked on the server, so even though we told the client he could
			// keep track of ammo himself like a big boy, we still have to spoon-feed it to him.
			if (KFW.bAllowClientAmmoTracking)
			{
				HealingDartAmmo = KFW.AmmoCount[ALTFIRE_FIREMODE];
			}
		}
	}
}

/*********************************************************************************************
 @name Optics UI
********************************************************************************************* */

simulated function InitOptics()
{
	local KFInventoryManager KFIM;

	if (OpticsUI == none && WorldInfo.NetMode != NM_DedicatedServer)
	{
		KFIM = KFInventoryManager(KFW.InvManager);
		if (KFIM != none)
		{
			OpticsUI = KFGFxWorld_MedicOptics(KFIM.GetOpticsUIMovie(OpticsUIClass));
		}
	}
}

simulated function ShutdownOptics()
{
	local KFInventoryManager KFIM;
	local KFWeapon InvKFW;

	if (OpticsUI != none)
	{
		KFIM = KFInventoryManager(KFW.InvManager);
		if (KFIM != none)
		{
			foreach KFIM.InventoryActors(class'KFWeapon', InvKFW)
			{
				if (InvKFW != KFW &&
					((InvKFW.MedicComp != none && InvKFW.MedicComp.OpticsUI.class == OpticsUI.class)) ||
					((KFWeap_MedicBase(InvKFW) != none && KFWeap_MedicBase(InvKFW).OpticsUI.class == OpticsUI.Class)))
				{
					// A different weapon is still using this optics class
					return;
				}
			}

			//Create the screen's UI piece
			KFIM.RemoveOpticsUIMovie(OpticsUI.class);

			OpticsUI.Close();
			OpticsUI = none;
		}
	}
}

simulated function UpdateOpticsUI(optional bool bForceUpdate)
{
	local int DefAmmoCount, AltAmmoCount;

	DefAmmoCount = 0; // @TODO: change?

	if (KFW.Instigator != none && KFW.Instigator.weapon == KFW)
	{
		if (OpticsUI == none)
		{
			InitOptics();
		}

		if (DefAmmoCount != StoredPrimaryAmmo || bForceUpdate)
		{
			StoredPrimaryAmmo = DefAmmoCount;
			OpticsUI.SetPrimaryAmmo(StoredPrimaryAmmo);
		}

		AltAmmoCount = KFW.GetTotalAmmoAmount(ALTFIRE_FIREMODE);
		if (AltAmmoCount != StoredSecondaryAmmo || bForceUpdate)
		{
			StoredSecondaryAmmo = AltAmmoCount;
			OpticsUI.SetHealerCharge(StoredSecondaryAmmo * 100); //1 = full
		}

		if (OpticsUI.MinPercentPerShot != AltAmmoCount)
		{
			OpticsUI.SetShotPercentCost(AmmoCost);
		}
	}
}

/*********************************************************************************************
 @name Weapon events
********************************************************************************************* */

simulated function bool ProcessInstantHitEx(ImpactInfo Impact)
{
	local KFPawn HealTarget;
	local float AdjustedHealAmount;

    HealTarget = KFPawn(Impact.HitActor);
	if (HealTarget == none)
	{
		return false;
	}

	if (WorldInfo.GRI.OnSameTeam(Instigator, HealTarget))
	{
		if (KFPlayerController(Instigator.Controller) != none)
		{
			KFPlayerController(Instigator.Controller).AddShotsHit(1);
		}

		AdjustedHealAmount = HealAmount * KFW.static.GetUpgradeHealMod(KFW.CurrentWeaponUpgradeIndex);
    	HealTarget.HealDamage(AdjustedHealAmount, Instigator.Controller, HealingDartDamageType);

		if (HealImpactSoundPlayEvent != None && !KFW.bSuppressSounds)
    	{
    		HealTarget.PlaySoundBase(HealImpactSoundPlayEvent, false, false ,, Impact.HitLocation);
    	}

		return true;
	}
	else
	{
		if (HurtImpactSoundPlayEvent != None && HealTarget != None && !KFW.bSuppressSounds)
    	{
    	    HealTarget.PlaySoundBase(HurtImpactSoundPlayEvent, false, false,, Impact.HitLocation);
    	}

		return false;
	}
}

simulated event AdjustRecoil(byte CurrentFireMode)
{
	if (CurrentFireMode == ALTFIRE_FIREMODE)
	{
		KFW.minRecoilPitch = DartMinRecoilPitch;
		KFW.maxRecoilPitch = DartMaxRecoilPitch;
		KFW.minRecoilYaw = DartMinRecoilYaw;
		KFW.maxRecoilYaw = DartMaxRecoilYaw;
	}
	else
	{
		KFW.minRecoilPitch = KFW.default.minRecoilPitch;
		KFW.maxRecoilPitch = KFW.default.maxRecoilPitch;
		KFW.minRecoilYaw = KFW.default.minRecoilYaw;
		KFW.maxRecoilYaw = KFW.default.maxRecoilYaw;
	}
}

simulated function AdjustShakeView(byte CurrentFireMode)
{
	if (CurrentFireMode == ALTFIRE_FIREMODE)
	{
		KFW.WeaponFireWaveForm = HealingDartWaveForm;
	}
	else
	{
		KFW.WeaponFireWaveForm = KFW.default.WeaponFireWaveForm;
	}
}

simulated function OnWeaponFireAmmunition(byte CurrentFireMode)
{
	if (CurrentFireMode == ALTFIRE_FIREMODE)
    {
        // Don't let a weak zed grab us when we just shot a healing dart
        KFW.SetWeakZedGrabCooldownOnPawn(HealDartShotWeakZedGrabCooldown);
        StartHealRecharge();
    }
}

// This makes it impossible for the server to fire before the fire animation has the chance to play on the client side.
simulated function bool ShouldStartFire(byte FireModeNum)
{
	return FireModeNum != ALTFIRE_FIREMODE || KFW.HasAmmo(ALTFIRE_FIREMODE, AmmoCost);
}

function OnWeaponGivenTo(Pawn thisPawn, optional bool bDoNotActivate)
{
	if (Role == ROLE_Authority && !thisPawn.IsLocallyControlled())
	{
		StartHealRecharge();
	}
}

simulated function PlayFiringSound()
{
	KFW.WeaponPlayFireSound(DartFireSnd.DefaultCue, DartFireSnd.FirstPersonCue);
}

simulated function name GetWeaponFireAnim()
{
	return (KFW.bUsingSights) ? ShootDartIronAnim : ShootDartAnim;
}

simulated function OnClientWeaponSet()
{
	InitOptics();
	StartHealRecharge();
}

simulated function OnWeaponRemovedFromInvManager()
{
	ShutdownOptics();
}

simulated function OnWeaponAttachedTo()
{
	if (OpticsUI != none)
	{
		OpticsUI.SetPause(false);
		OpticsUI.ClearLockOn();
		UpdateOpticsUI(true);
		OpticsUI.SetShotPercentCost(AmmoCost);
	}
}

simulated function OnWeaponDetached()
{
	if (Instigator != none && Instigator.Weapon == KFW)
	{
		if (OpticsUI != none)
		{
			OpticsUI.SetPause();
		}
	}
}

defaultproperties
{
	// Healing charge
	bRechargeHealAmmo=true
	HealingDartAmmo=100
    HealAmount=20
	HealFullRechargeSeconds=15
	HealDartShotWeakZedGrabCooldown=0.5

	DartMaxRecoilPitch=250
	DartMinRecoilPitch=200
	DartMaxRecoilYaw=100
	DartMinRecoilYaw=-100

	RemoteRole=ROLE_SimulatedProxy
	bOnlyRelevantToOwner=true
	bHidden=true
	bCollideActors=false
	bProjTarget=false
	bStatic=false
	bNoDelete=false
}