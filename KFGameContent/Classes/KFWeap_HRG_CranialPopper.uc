//=============================================================================
// KFWeap_HRG_CranialPopper
//=============================================================================
//=============================================================================
// Killing Floor 2
// Copyright (C) 2022 Tripwire Interactive LLC
//=============================================================================

class KFWeap_HRG_CranialPopper extends KFWeap_ScopedBase;

/** How many alt ammo to recharge per second */
var float AltAmmoFullRechargeSeconds;
/** How many alt ammo to recharge per second. */
var transient float AltAmmoRechargePerSecond;

var transient float AltAmmoIncrement;
var repnotify byte AltAmmo;

var class<KFGFxWorld_MedicOptics> OpticsUIClass;
var KFGFxWorld_MedicOptics OpticsUI;

/** The last updated value for our ammo - Used to know when to update our optics ammo */
var byte StoredPrimaryAmmo;
var byte StoredSecondaryAmmo;

replication
{
	if (bNetDirty && Role == ROLE_Authority)
		AltAmmo;
}

simulated event ReplicatedEvent(name VarName)
{
	if (VarName == nameof(AltAmmo))
	{
		AmmoCount[ALTFIRE_FIREMODE] = AltAmmo;
	}
	else
	{
		Super.ReplicatedEvent(VarName);
	}
}

static simulated event EFilterTypeUI GetTraderFilter()
{
    return FT_Rifle;
}

simulated event PreBeginPlay()
{
	super.PreBeginPlay();
	StartAltAmmoRecharge();
} 

function StartAltAmmoRecharge()
{
	local float UsedAltAmmoRechargeTime;

	// begin ammo recharge on server
	if( Role == ROLE_Authority )
	{
		UsedAltAmmoRechargeTime = AltAmmoFullRechargeSeconds;
	    AltAmmoRechargePerSecond = MagazineCapacity[ALTFIRE_FIREMODE] / UsedAltAmmoRechargeTime;
		AltAmmoIncrement = 0;
	}
}

function RechargeAltAmmo(float DeltaTime)
{
	if ( Role == ROLE_Authority )
	{
		AltAmmoIncrement += AltAmmoRechargePerSecond * DeltaTime;

		if( AltAmmoIncrement >= 1.0 && AmmoCount[ALTFIRE_FIREMODE] < MagazineCapacity[ALTFIRE_FIREMODE] )
		{
			AmmoCount[ALTFIRE_FIREMODE]++;
			AltAmmoIncrement -= 1.0;
			AltAmmo = AmmoCount[ALTFIRE_FIREMODE];
		}
	}
}

/** Overridden to call StartHealRecharge on server */
function GivenTo( Pawn thisPawn, optional bool bDoNotActivate )
{
	super.GivenTo( thisPawn, bDoNotActivate );

	if( Role == ROLE_Authority && !thisPawn.IsLocallyControlled() )
	{
		StartAltAmmoRecharge();
	}
}

simulated event Tick( FLOAT DeltaTime )
{
    if( AmmoCount[ALTFIRE_FIREMODE] < MagazineCapacity[ALTFIRE_FIREMODE] )
	{
        RechargeAltAmmo(DeltaTime);
	}

	if (Instigator != none && Instigator.weapon == self)
	{
		UpdateOpticsUI();
	}

	Super.Tick(DeltaTime);
}

simulated function bool CanOverrideMagReload(byte FireModeNum)
{
	return FireModeNum == ALTFIRE_FIREMODE || Super.CanOverrideMagReload(FireModeNum);
}

/** Instead of switch fire mode use as immediate alt fire */
simulated function AltFireMode()
{
	if ( !Instigator.IsLocallyControlled() )
	{
		return;
	}

	StartFire(ALTFIRE_FIREMODE);
}

/** Alt ammo doesn't count as ammo for purposes of inventory management (e.g. switching) */
simulated function bool HasAnyAmmo()
{
	return HasSpareAmmo() || HasAmmo(DEFAULT_FIREMODE);
}

simulated function bool ShouldAutoReload(byte FireModeNum)
{
	if (FireModeNum == ALTFIRE_FIREMODE)
		return false;
	
	return super.ShouldAutoReload(FireModeNum);
}

/**
    Optic UI
 */

/** Get our optics movie from the inventory once our InvManager is created */
reliable client function ClientWeaponSet(bool bOptionalSet, optional bool bDoNotActivate)
{
	local KFInventoryManager KFIM;

	super.ClientWeaponSet(bOptionalSet, bDoNotActivate);

	if (OpticsUI == none && OpticsUIClass != none)
	{
		KFIM = KFInventoryManager(InvManager);
		if (KFIM != none)
		{
			//Create the screen's UI piece
			OpticsUI = KFGFxWorld_MedicOptics(KFIM.GetOpticsUIMovie(OpticsUIClass));
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
			OpticsUI.SetHealerCharge(StoredSecondaryAmmo);
		}

		if(OpticsUI.MinPercentPerShot != AmmoCost[ALTFIRE_FIREMODE])
		{
			OpticsUI.SetShotPercentCost( AmmoCost[ALTFIRE_FIREMODE] );
		}
	}
}

function ItemRemovedFromInvManager()
{
	local KFInventoryManager KFIM;
	local KFWeap_MedicBase KFW;

	Super.ItemRemovedFromInvManager();

	if (OpticsUI != none)
	{
		KFIM = KFInventoryManager(InvManager);
		if (KFIM != none)
		{
			// @todo future implementation will have optics in base weapon class
			foreach KFIM.InventoryActors(class'KFWeap_MedicBase', KFW)
			{
				if( KFW.OpticsUI.Class == OpticsUI.class)
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
		OpticsUI.ClearLockOn();
		UpdateOpticsUI(true);
		OpticsUI.SetShotPercentCost( AmmoCost[ALTFIRE_FIREMODE]);
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

defaultproperties
{
    AltAmmoFullRechargeSeconds=3.5

    // Inventory / Grouping
    InventorySize=7
    GroupPriority=75
    WeaponSelectTexture=Texture2D'wep_ui_hrg_cranialpopper_tex.UI_WeaponSelect_HRG_CranialPopper'
    SecondaryAmmoTexture=Texture2D'ui_firemodes_tex.UI_FireModeSelect_Electricity'
    AssociatedPerkClasses(0)=class'KFPerk_Sharpshooter'

    // FOV
    MeshFOV=60
    MeshIronSightFOV=27
    PlayerIronSightFOV=70

    // Depth of field
    DOF_BlendInSpeed=3.0
    DOF_FG_FocalRadius=0//70
    DOF_FG_MaxNearBlurSize=3.5

	// Content
	PackageKey="HRG_CranialPopper"
	FirstPersonMeshName="WEP_1P_HRG_CranialPopper_MESH.Wep_1stP_HRG_CranialPopper_Rig"
	FirstPersonAnimSetNames(0)="wep_1p_hrg_cranialpopper_anim.Wep_1stP_HRG_CranialPopper_Anim"
	PickupMeshName="WEP_3P_HRG_CranialPopper_MESH.Wep_3rdP_HRG_CranialPopper_Pickup"
    AttachmentArchetypeName="WEP_HRG_CranialPopper_ARCH.Wep_HRG_CrannialPopper_3P"
	MuzzleFlashTemplateName="WEP_HRG_CranialPopper_ARCH.Wep_HRG_CranialPopper_MuzzleFlash"

    LaserSightTemplate=KFLaserSightAttachment'FX_LaserSight_ARCH.LaserSight_WithAttachment_1P'

    // Ammo
    MagazineCapacity[0]=7
    SpareAmmoCapacity[0]=112 //98
    InitialSpareMags[0]=5
	AmmoPickupScale[0]=2.0
    bCanBeReloaded=true
    bReloadFromMagazine=true

	MagazineCapacity[1]=100
	AltAmmo=100
	bCanRefillSecondaryAmmo=false

    // Zooming/Position
    PlayerViewOffset=(X=15.0,Y=11.5,Z=-4) //(X=20.0,Y=11.0,Z=-2) //(X=15.0,Y=11.5,Z=-4)
    IronSightPosition=(X=-7.0,Y=0.07,Z=0.05) //(X=30.0,Y=0,Z=0)

    // AI warning system
    bWarnAIWhenAiming=true
    AimWarningDelay=(X=0.4f, Y=0.8f)
    AimWarningCooldown=0.0f

    // Recoil
    maxRecoilPitch=225
    minRecoilPitch=200
    maxRecoilYaw=200
    minRecoilYaw=-200
    RecoilRate=0.08
    RecoilMaxYawLimit=500
    RecoilMinYawLimit=65035
    RecoilMaxPitchLimit=900
    RecoilMinPitchLimit=65035
    RecoilISMaxYawLimit=150
    RecoilISMinYawLimit=65385
    RecoilISMaxPitchLimit=375
    RecoilISMinPitchLimit=65460
    RecoilViewRotationScale=0.6

	// Scope Render
  	// 2D scene capture
	Begin Object Name=SceneCapture2DComponent0
	   //TextureTarget=TextureRenderTarget2D'WEP_1P_HRG_CranialPopper_MAT.WEP_1P_Cranial_zoomed_Scope_MAT'
	   FieldOfView=12.5 //23.0 // "1.5X" = 35.0(our real world FOV determinant)/1.5
	End Object

    ScopedSensitivityMod=8.0 //16.0
	ScopeLenseMICTemplate=MaterialInstanceConstant'WEP_1P_HRG_CranialPopper_MAT.WEP_1P_Cranial_zoomed_Scope_MAT'
	ScopeMICIndex=2

    // DEFAULT_FIREMODE
    FireModeIconPaths(DEFAULT_FIREMODE)=Texture2D'ui_firemodes_tex.UI_FireModeSelect_BulletSingle'
    FiringStatesArray(DEFAULT_FIREMODE)=WeaponSingleFiring
    WeaponFireTypes(DEFAULT_FIREMODE)=EWFT_InstantHit
    WeaponProjectiles(DEFAULT_FIREMODE)=class'KFProj_Bullet_HRG_CranialPopper'
    InstantHitDamage(DEFAULT_FIREMODE)=50.0 //100.0
    InstantHitDamageTypes(DEFAULT_FIREMODE)=class'KFDT_Piercing_HRG_CranialPopper'
    FireInterval(DEFAULT_FIREMODE)=0.25
    PenetrationPower(DEFAULT_FIREMODE)=0.0 //2.0
    Spread(DEFAULT_FIREMODE)=0.006
    FireOffset=(X=30,Y=3.0,Z=-2.5)

    // ALT_FIREMODE
    FiringStatesArray(ALTFIRE_FIREMODE)=WeaponSingleFiring
	WeaponFireTypes(ALTFIRE_FIREMODE)=EWFT_Projectile
	WeaponProjectiles(ALTFIRE_FIREMODE)=class'KFProj_Grenade_HRG_CranialPopper'
    InstantHitDamage(ALTFIRE_FIREMODE)=0.0 //override by AfflictionHandler.GetBigHeadAfflictionDamageModifier()
    InstantHitDamageTypes(ALTFIRE_FIREMODE)=Class'KFDT_Blast_HRG_CranialPopper'
	FireInterval(ALTFIRE_FIREMODE)=+0.25
	AmmoCost(ALTFIRE_FIREMODE)=100

    // BASH_FIREMODE
    InstantHitDamageTypes(BASH_FIREMODE)=class'KFDT_Bludgeon_HRG_CranialPopper'
    InstantHitDamage(BASH_FIREMODE)=26

    // Fire Effects
    WeaponFireSnd(DEFAULT_FIREMODE)=(DefaultCue=AkEvent'WW_WEP_HRG_CranialPopper.Play_WEP_HRG_CranialPopper_Fire_3P', FirstPersonCue=AkEvent'WW_WEP_HRG_CranialPopper.Play_WEP_HRG_CranialPopper_Fire_1P') 
    WeaponDryFireSnd(DEFAULT_FIREMODE)=AkEvent'WW_WEP_SA_EBR.Play_WEP_SA_EBR_Handling_DryFire'  //@TODO: Replace

    // Custom animations
    FireSightedAnims=(Shoot_Iron, Shoot_Iron2, Shoot_Iron3)

    // Attachments
    bHasIronSights=true
    bHasFlashlight=false
    bHasLaserSight=false

    WeaponFireWaveForm=ForceFeedbackWaveform'FX_ForceFeedback_ARCH.Gunfire.Heavy_Recoil'

    //WeaponUpgrades[1]=(IncrementDamage=1.4f,IncrementWeight=1, IncrementHealFullRecharge=.8)
    //WeaponUpgrades[2]=(IncrementDamage=1.8f,IncrementWeight=2, IncrementHealFullRecharge=.6)

	WeaponUpgrades[1]=(Stats=((Stat=EWUS_Damage0, Scale=1.15f), (Stat=EWUS_Weight, Add=1)))
	WeaponUpgrades[2]=(Stats=((Stat=EWUS_Damage0, Scale=1.3f), (Stat=EWUS_Weight, Add=2)))
	
    // From original KFWeap_RifleBase base class
	AimCorrectionSize=40.f

    NumBloodMapMaterials=3
    
    OpticsUIClass=class'KFGFxWorld_MedicOptics'
}
