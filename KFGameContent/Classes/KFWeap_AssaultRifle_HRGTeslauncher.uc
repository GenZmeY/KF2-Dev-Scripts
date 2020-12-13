//=============================================================================
// KFWeap_AssaultRifle_HRGTeslauncher
//=============================================================================
// An M16 M203 Incendiary Assault Rifle
//=============================================================================
// Killing Floor 2
// Copyright (C) 2019 Tripwire Interactive LLC
// Fernando Ferrando @ Saber Interactive
//=============================================================================
class KFWeap_AssaultRifle_HRGTeslauncher extends KFWeap_AssaultRifle_M16M203;

var class<KFGFxWorld_MedicOptics> OpticsUIClass;
var KFGFxWorld_MedicOptics OpticsUI;
var byte StoredPrimaryAmmo;
var byte StoredSecondaryAmmo;

simulated event Tick( FLOAT DeltaTime )
{
	if (Instigator != none && Instigator.weapon == self)
	{
		UpdateOpticsUI(true);
	}

	Super.Tick(DeltaTime);
}

/*********************************************************************************************
 @name Optics UI
********************************************************************************************* */

/** Get our optics movie from the inventory once our InvManager is created */
reliable client function ClientWeaponSet(bool bOptionalSet, optional bool bDoNotActivate)
{
	local KFInventoryManager KFIM;
	super.ClientWeaponSet(bOptionalSet, bDoNotActivate);

	if (OpticsUI == none)
	{
		KFIM = KFInventoryManager(InvManager);
		if (KFIM != none)
		{
			//Create the screen's UI piece
			OpticsUI = KFGFxWorld_MedicOptics(KFIM.GetOpticsUIMovie(OpticsUIClass));
		}
	}
}

function ItemRemovedFromInvManager()
{
	local KFInventoryManager KFIM;
	local KFWeap_AssaultRifle_HRGTeslauncher KFW;

	Super.ItemRemovedFromInvManager();

	if (OpticsUI != none)
	{
		KFIM = KFInventoryManager(InvManager);
		if (KFIM != none)
		{
			// @todo future implementation will have optics in base weapon class
			foreach KFIM.InventoryActors(class'KFWeap_AssaultRifle_HRGTeslauncher', KFW)
			{
				if( KFW != self && KFW.OpticsUI.Class == OpticsUI.class)
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

/** Unpause our optics movie and reinitialize our ammo when we equip the weapon */
simulated function AttachWeaponTo(SkeletalMeshComponent MeshCpnt, optional Name SocketName)
{
	super.AttachWeaponTo(MeshCpnt, SocketName);

	if (OpticsUI != none)
	{
		OpticsUI.SetPause(false);
		UpdateOpticsUI(true);
		`Warn("AMMOCOST " $AmmoCost[ALTFIRE_FIREMODE]$ "");
		OpticsUI.SetShotPercentCost( AmmoCost[ALTFIRE_FIREMODE] );
	}
}

/** Pause the optics movie once we unequip the weapon so it's not playing in the background */
simulated function DetachWeapon()
{
	local Pawn OwnerPawn;
	super.DetachWeapon();

	OwnerPawn = Pawn(Owner);
	if( OwnerPawn != none && OwnerPawn.Weapon == self )
	{
		if (OpticsUI != none)
		{
			OpticsUI.SetPause();
		}
	}
}

/**
 * Update our displayed ammo count if it's changed
 */
simulated function UpdateOpticsUI(optional bool bForceUpdate)
{
	if (OpticsUI != none && OpticsUI.OpticsContainer != none)
	{
		if (AmmoCount[DEFAULT_FIREMODE] != StoredPrimaryAmmo || bForceUpdate)
		{
			StoredPrimaryAmmo = AmmoCount[DEFAULT_FIREMODE];
			OpticsUI.SetPrimaryAmmo(StoredPrimaryAmmo);
		}

		if (AmmoCount[ALTFIRE_FIREMODE] != StoredSecondaryAmmo || bForceUpdate)
		{
			StoredSecondaryAmmo = AmmoCount[ALTFIRE_FIREMODE];
			OpticsUI.SetHealerCharge(StoredSecondaryAmmo * 100);
		}

		if(OpticsUI.MinPercentPerShot != AmmoCost[ALTFIRE_FIREMODE])
		{
			OpticsUI.SetShotPercentCost( AmmoCost[ALTFIRE_FIREMODE] );
		}
	}
}

static simulated event EFilterTypeUI GetTraderFilter()
{
	return FT_Rifle;
}

static simulated event EFilterTypeUI GetAltTraderFilter()
{
	return FT_Flame;
}

simulated function bool CanLockOnTo(Actor TA)
{
	return false;
}

/*********************************************************************************************
 * State GrenadeFiring
 * Handles firing grenade launcher.
 *********************************************************************************************/

simulated state FiringSecondaryState 
{
	// Overriden to not call FireAmmunition right at the start of the state
	simulated event BeginState( Name PreviousStateName )
	{
		Super.BeginState(PreviousStateName);
		NotifyBeginState();
	}

	simulated function EndState(Name NextStateName)
	{
		Super.EndState(NextStateName);
		NotifyEndState();
	}

    /**
     * This function returns the world location for spawning the visual effects
     * Overridden to use a special offset for throwing grenades
     */
	simulated event vector GetMuzzleLoc()
	{
		local vector MuzzleLocation;

		// swap fireoffset temporarily
		FireOffset = SecondaryFireOffset;
		MuzzleLocation = Global.GetMuzzleLoc();
		FireOffset = default.FireOffset;

		return MuzzleLocation;
	}

	/** Get whether we should play the reload anim as well or not */
	simulated function name GetWeaponFireAnim(byte FireModeNum)
	{
		return bUsingSights ? SecondaryFireIronAnim : SecondaryFireAnim;
	}
}

defaultproperties
{
	
	// Pickup scale
    AmmoPickupScale[0]=1.0
    AmmoPickupScale[1]=2.0

	// Ammo
	MagazineCapacity[0]=30
	InitialSpareMags[0]=2
	SpareAmmoCapacity[0]=240

	//Grenades
	MagazineCapacity[1]=1
	InitialSpareMags[1]=1
	SpareAmmoCapacity[1]=7 //9 //10

	//Inventory
	InventorySize=7 //Weight Ammount
	GroupPriority=100

	FireOffset=(X=30,Y=4.5,Z=-5)
	SecondaryFireOffset=(X=20.f,Y=4.5,Z=-7.f)
	//SecondaryFireOffset=(X=0,Y=20,Z=-30)

	// Recoil
	maxRecoilPitch=150
	minRecoilPitch=125
	maxRecoilYaw=125
	minRecoilYaw=-125
	RecoilRate=0.11 //0.085
	RecoilMaxYawLimit=500
	RecoilMinYawLimit=65035
	RecoilMaxPitchLimit=900
	RecoilMinPitchLimit=65035
	RecoilISMaxYawLimit=75
	RecoilISMinYawLimit=65460
	RecoilISMaxPitchLimit=375
	RecoilISMinPitchLimit=65460
	IronSightMeshFOVCompensationScale=1.5
    HippedRecoilModifier=1.5

	OpticsUIClass=class'KFGFxWorld_MedicOptics'

	// Content
	PackageKey="HRG_Teslauncher"
	FirstPersonMeshName="WEP_1P_HRG_Teslauncher_MESH.WEP_1stP_HRG_Teslauncher_Rig"
	FirstPersonAnimSetNames(0)="WEP_1P_HRG_Teslauncher_ANIM.Wep_1stP_HRG_Teslauncher_Anim"
	PickupMeshName="WEP_3P_HRG_Teslauncher_MESH.Wep_3rdP_Medic_GrenadeLauncher_Pickup"
	AttachmentArchetypeName="WEP_HRG_Teslauncher_ARCH.Wep_HRG_Teslauncher_3P"
	MuzzleFlashTemplateName="WEP_HRG_Teslauncher_ARCH.Wep_HRG_Teslauncher_MuzzleFlash"
	WeaponSelectTexture=Texture2D'WEP_UI_HRG_Teslauncher_TEX.UI_WeaponSelect_HRG_Teslauncher'

	// DEFAULT_FIREMODE
	FireModeIconPaths(DEFAULT_FIREMODE)=Texture2D'ui_firemodes_tex.UI_FireModeSelect_BulletAuto'
	FiringStatesArray(DEFAULT_FIREMODE)=WeaponFiring
	WeaponFireTypes(DEFAULT_FIREMODE)=EWFT_Projectile
	WeaponProjectiles(DEFAULT_FIREMODE)=class'KFProj_Bullet_HRGTeslauncher'
	InstantHitDamageTypes(DEFAULT_FIREMODE)=class'KFDT_Ballistic_HRGTeslauncher'
	PenetrationPower(DEFAULT_FIREMODE)=5
	FireInterval(DEFAULT_FIREMODE)=+0.12 // 700 RPM
	Spread(DEFAULT_FIREMODE)=0.0085
	InstantHitDamage(DEFAULT_FIREMODE)=68.0 //DEFAULT MODE DAMAGE

	// ALT_FIREMODE
	FireModeIconPaths(ALTFIRE_FIREMODE)=Texture2D'ui_firemodes_tex.UI_FireModeSelect_BulletSingle'
	FiringStatesArray(ALTFIRE_FIREMODE)=FiringSecondaryState
	WeaponFireTypes(ALTFIRE_FIREMODE)=EWFT_Projectile
	WeaponProjectiles(ALTFIRE_FIREMODE)=class'KFProj_Grenade_HRGTeslauncher'
	InstantHitDamageTypes(ALTFIRE_FIREMODE)=class'KFDT_Ballistic_HRGTeslauncherGrenadeImpact'
	PenetrationPower(ALTFIRE_FIREMODE)=0
	FireInterval(ALTFIRE_FIREMODE)=+0.25f
	InstantHitDamage(ALTFIRE_FIREMODE)=50.0 //150 //225
	Spread(ALTFIRE_FIREMODE)=0.0085

	// BASH_FIREMODE
	InstantHitDamageTypes(BASH_FIREMODE)=class'KFDT_Bludgeon_HRGTeslauncher'
	InstantHitDamage(BASH_FIREMODE)=26

	// Fire Effects
	WeaponFireSnd(DEFAULT_FIREMODE)=(DefaultCue=AkEvent'WW_WEP_HRG_Teslauncher.Play_WEP_HRG_Teslauncher_Shoot_3P', FirstPersonCue=AkEvent'WW_WEP_HRG_Teslauncher.Play_WEP_HRG_Teslauncher_Shoot_1P')
	WeaponFireSnd(ALTFIRE_FIREMODE)=(DefaultCue=AkEvent'WW_WEP_Medic_GrenadeLauncher.Play_WEP_Medic_GrenadeLauncher_SecondaryFire_3P_Single', FirstPersonCue=AkEvent'WW_WEP_Medic_GrenadeLauncher.Play_WEP_Medic_GrenadeLauncher_SecondaryFire_1P_Single')

	WeaponDryFireSnd(DEFAULT_FIREMODE)=AkEvent'WW_WEP_SA_L85A2.Play_WEP_SA_L85A2_Handling_DryFire'
	WeaponDryFireSnd(ALTFIRE_FIREMODE)=AkEvent'WW_WEP_SA_L85A2.Play_WEP_SA_L85A2_Handling_DryFire'

	// Advanced (High RPM) Fire Effects
	bLoopingFireAnim(DEFAULT_FIREMODE)=true
	bLoopingFireSnd(DEFAULT_FIREMODE)=false
	WeaponFireSnd(2)=(DefaultCue=AkEvent'WW_WEP_M16M203.Play_M16_Fire_3P_Single', FirstPersonCue=AkEvent'WW_WEP_M16M203.Play_M16_Fire_1P_Single')
	SingleFireSoundIndex=2
	
	// Perk
	AssociatedPerkClasses.Empty()
	AssociatedPerkClasses(0)=class'KFPerk_Berserker'

	// Weapon Upgrade
	WeaponUpgrades.Empty()
	WeaponUpgrades[0]=(Stats=((Stat=EWUS_Damage0, Scale=1.f, Add=0), (Stat=EWUS_Weight, Scale=1.f, Add=0)))
	WeaponUpgrades[1]=(Stats=((Stat=EWUS_Damage0, Scale=1.125f), (Stat=EWUS_Damage1, Scale=1.125f), (Stat=EWUS_Weight, Add=1)))
	//WeaponUpgrades[2]=(Stats=((Stat=EWUS_Damage0, Scale=1.4f), (Stat=EWUS_Damage1, Scale=1.4f), (Stat=EWUS_Weight, Add=2)))
}