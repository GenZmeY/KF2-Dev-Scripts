//=============================================================================
// KFWeap_AssaultRifle_Doshinegun
//=============================================================================
// Like if we were rich...
//=============================================================================
// Killing Floor 2
// Copyright (C) 2021 Tripwire Interactive LLC
//=============================================================================

class KFWeap_AssaultRifle_Doshinegun extends KFWeap_RifleBase;

var int DoshCost;
var transient KFPlayerReplicationInfo KFPRI;
var transient bool bIsBeingDropped;

simulated function Activate()
{
	local KFPawn KFP;

	super.Activate();

	if (KFPRI == none)
	{
		KFP = KFPawn(Instigator);
		if (KFP != none)
		{
			KFPRI = KFPlayerReplicationInfo(KFP.PlayerReplicationInfo);
		}
	}
}

simulated function bool HasAnyAmmo()
{
    return bIsBeingDropped ? AmmoCount[0] > 0 : (AmmoCount[0] > 0 || KFPRI.Score >= DoshCost);
}

/** Returns true if weapon can potentially be reloaded */
simulated function bool CanReload(optional byte FireModeNum)
{
	return KFPRI.Score >= DoshCost && AmmoCount[FireModeNum] < MagazineCapacity[FireModeNum];
}

/** Performs actual ammo reloading */
simulated function PerformReload(optional byte FireModeNum)
{
	local int ReloadAmount;
	local int AmmoType;

	AmmoType = GetAmmoType(FireModeNum);

	if ( bInfiniteSpareAmmo )
	{
		AmmoCount[AmmoType] = MagazineCapacity[AmmoType];
		ReloadAmountLeft = 0;
		return;
	}

	if ( (Role == ROLE_Authority && !bAllowClientAmmoTracking) || (Instigator.IsLocallyControlled() && bAllowClientAmmoTracking) )
	{
		ReloadAmount = Min(MagazineCapacity[0] - AmmoCount[0], KFPRI.Score / DoshCost);
		AmmoCount[AmmoType] = Min(AmmoCount[AmmoType] + ReloadAmount, MagazineCapacity[AmmoType]);
		KFPRI.AddDosh(-ReloadAmount * DoshCost);
	}

	ReloadAmountLeft = 0;
	ShotsHit = 0;
}

function int AddAmmo(int Amount)
{
	return 0;
}

simulated function bool CanBuyAmmo()
{
	return false;
}

static simulated event bool UsesAmmo()
{
    return true;
}

// Overriden to deactivate low ammo dialogue
simulated state Reloading
{
	simulated function EndState(Name NextStateName)
	{
		local int ActualReloadAmount;
		ClearZedTimeResist();
		ClearTimer(nameof(ReloadStatusTimer));
		ClearTimer(nameof(ReloadAmmoTimer));
		ClearPendingFire(RELOAD_FIREMODE);

		if ( bAllowClientAmmoTracking && Role < ROLE_Authority )
		{
			// Get how much total ammo was reloaded on the client side over the entire course of the reload.
			ActualReloadAmount = InitialReloadAmount - ReloadAmountLeft;
			// Sync spare ammo counts using initial spare ammo, and how much ammo has been reloaded since reload began.
			ServerSyncReload(InitialReloadSpareAmmo - ActualReloadAmount);
		}

		CheckBoltLockPostReload();
		NotifyEndState();

		CurrentFireMode = DEFAULT_FIREMODE;

		ReloadStatus = RS_None;
	}
}

/**
 * Drop this item out in to the world
 */
function DropFrom(vector StartLocation, vector StartVelocity)
{
	bIsBeingDropped=true;
	super.DropFrom(StartLocation, StartVelocity);
}

function SetOriginalValuesFromPickup( KFWeapon PickedUpWeapon )
{
	local KFPawn KFP;

	bIsBeingDropped=false;
	// Reset the replication info
	KFP = KFPawn(Instigator);
	if (KFP != none)
	{
		KFPRI = KFPlayerReplicationInfo(KFP.PlayerReplicationInfo);
	}
	super.SetOriginalValuesFromPickup(PickedUpWeapon);
}

defaultproperties
{
	// FOV
	MeshFOV=65
	MeshIronSightFOV=45 //52
    PlayerIronSightFOV=70

	// Depth of field
	DOF_FG_FocalRadius=150 //85
	DOF_FG_MaxNearBlurSize=1 //2.5

	// Content
	PackageKey="Doshinegun"
	FirstPersonMeshName="WEP_1P_Doshinegun_MESH.Wep_1stP_Doshinegun_Rig"
	FirstPersonAnimSetNames(0)="WEP_1P_Doshinegun_ANIM.Wep_1st_Doshinegun_Anim"
	PickupMeshName="WEP_3P_Doshinegun_MESH.Wep_Doshinegun_Pickup"
	AttachmentArchetypeName="WEP_Doshinegun_ARCH.Wep_Doshinegun_3P"
	MuzzleFlashTemplateName="WEP_Doshinegun_ARCH.Wep_Doshinegun_MuzzleFlash"

   	// Zooming/Position
	PlayerViewOffset=(X=1.0,Y=8.5,Z=-3)
	IronSightPosition=(X=5.0,Y=0.05,Z=-1.2)

	// Ammo
	MagazineCapacity[0]=20
	SpareAmmoCapacity[0]=0
	InitialSpareMags[0]=0
	AmmoPickupScale[0]=0.0
	bCanBeReloaded=true
	bReloadFromMagazine=true

	// Recoil
	maxRecoilPitch=250 //150
	minRecoilPitch=200 //115
	maxRecoilYaw=115
	minRecoilYaw=-115
	RecoilRate=0.085
	RecoilMaxYawLimit=500
	RecoilMinYawLimit=65035
	RecoilMaxPitchLimit=900
	RecoilMinPitchLimit=65035
	RecoilISMaxYawLimit=75
	RecoilISMinYawLimit=65460
	RecoilISMaxPitchLimit=375
	RecoilISMinPitchLimit=65460
	RecoilViewRotationScale=0.25
	IronSightMeshFOVCompensationScale=1.5
    HippedRecoilModifier=1.5

    // Inventory / Grouping
	InventorySize=4 //6
	GroupPriority=50
	WeaponSelectTexture=Texture2D'WEP_UI_Doshinegun_TEX.UI_Weapon_Select_Doshinegun'
   	//AssociatedPerkClasses(0)=class'KFPerk_Survivalist'
	AssociatedPerkClasses(0)=none

	// DEFAULT_FIREMODE
	FireModeIconPaths(DEFAULT_FIREMODE)=Texture2D'ui_firemodes_tex.UI_FireModeSelect_BulletAuto'
	FiringStatesArray(DEFAULT_FIREMODE)=WeaponFiring
	WeaponFireTypes(DEFAULT_FIREMODE)=EWFT_Projectile
	WeaponProjectiles(DEFAULT_FIREMODE)=class'KFProj_Dosh'
	InstantHitDamageTypes(DEFAULT_FIREMODE)=class'KFDT_Bludgeon_Doshinegun_Shot' 
	FireInterval(DEFAULT_FIREMODE)=+0.2
	Spread(DEFAULT_FIREMODE)=0.015
	InstantHitDamage(DEFAULT_FIREMODE)=60.0 //55.0 //60.0
	FireOffset=(X=30,Y=4.5,Z=-5)

	// ALT_FIREMODE
	FireModeIconPaths(ALTFIRE_FIREMODE)=Texture2D'ui_firemodes_tex.UI_FireModeSelect_BulletSingle'
	FiringStatesArray(ALTFIRE_FIREMODE)=WeaponSingleFiring
	WeaponFireTypes(ALTFIRE_FIREMODE)=EWFT_Projectile
	WeaponProjectiles(ALTFIRE_FIREMODE)=class'KFProj_Dosh'
	InstantHitDamageTypes(ALTFIRE_FIREMODE)=class'KFDT_Bludgeon_Doshinegun_Shot'
	FireInterval(ALTFIRE_FIREMODE)=+0.2
	InstantHitDamage(ALTFIRE_FIREMODE)=60.0 //55.0 //60.0
	Spread(ALTFIRE_FIREMODE)=0.015

	// BASH_FIREMODE
	InstantHitDamageTypes(BASH_FIREMODE)=class'KFDT_Bludgeon_Doshinegun'
	InstantHitDamage(BASH_FIREMODE)=26

	// Fire Effects
	WeaponFireSnd(DEFAULT_FIREMODE)=(DefaultCue=AkEvent'WW_WEP_Doshinegun.Play_WEP_Doshinegun_Shoot_Fire_3P_Loop', FirstPersonCue=AkEvent'WW_WEP_Doshinegun.Play_WEP_Doshinegun_Shoot_Fire_1P_Loop')
	WeaponFireSnd(ALTFIRE_FIREMODE)=(DefaultCue=AkEvent'WW_WEP_Doshinegun.Play_WEP_Doshinegun_Fire_3P', FirstPersonCue=AkEvent'WW_WEP_Doshinegun.Play_WEP_Doshinegun_Fire_1P')
	WeaponFireLoopEndSnd(DEFAULT_FIREMODE)=(DefaultCue=AkEvent'WW_WEP_Doshinegun.Play_WEP_Doshinegun_Shoot_Fire_3P_EndLoop', FirstPersonCue=AkEvent'WW_WEP_Doshinegun.Play_WEP_Doshinegun_Shoot_Fire_1P_EndLoop')

	WeaponDryFireSnd(DEFAULT_FIREMODE)=AkEvent'WW_WEP_Doshinegun.Play_WEP_Doshinegun_Dry_Fire'
	WeaponDryFireSnd(ALTFIRE_FIREMODE)=AkEvent'WW_WEP_Doshinegun.Play_WEP_Doshinegun_Dry_Fire'

	// Advanced (High RPM) Fire Effects
	bLoopingFireAnim(DEFAULT_FIREMODE)=true
	bLoopingFireSnd(DEFAULT_FIREMODE)=true
	SingleFireSoundIndex=ALTFIRE_FIREMODE

	// Attachments
	bHasIronSights=true
	bHasFlashlight=false

	// Weapon Upgrade stat boosts
	//WeaponUpgrades[1]=(IncrementDamage=1.3f,IncrementWeight=1)
	//WeaponUpgrades[2]=(IncrementDamage=1.65f,IncrementWeight=2)
	//WeaponUpgrades[3]=(IncrementDamage=1.85f,IncrementWeight=3)

	WeaponUpgrades[1]=(Stats=((Stat=EWUS_Damage0, Scale=1.23f), (Stat=EWUS_Damage1, Scale=1.23f), (Stat=EWUS_Weight, Add=1)))
	WeaponUpgrades[2]=(Stats=((Stat=EWUS_Damage0, Scale=1.47f), (Stat=EWUS_Damage1, Scale=1.47f), (Stat=EWUS_Weight, Add=2)))
	WeaponUpgrades[3]=(Stats=((Stat=EWUS_Damage0, Scale=1.70f), (Stat=EWUS_Damage1, Scale=1.70f), (Stat=EWUS_Weight, Add=3)))

    DoshCost = 20; //25;
	bUsesSecondaryAmmoAltHUD=true
	bAllowClientAmmoTracking=false
	bIsBeingDropped=false
}



