//=============================================================================
// KFWeap_Pistol_HRGWinterbite
//=============================================================================
// A frosty twist on the Spitfire (KFWeap_Pistol_Flare)
//=============================================================================
// Killing Floor 2
// Copyright (C) 2019 Tripwire Interactive LLC
//=============================================================================

class KFWeap_Pistol_HRGWinterbite extends KFWeap_PistolBase;

defaultproperties
{
	// Content
	PackageKey="HRG_Winterbite"
	FirstPersonMeshName="WEP_1P_HRG_Winterbite_MESH.Wep_1stP_HRG_Winterbite_Rig"
	FirstPersonAnimSetNames(0)="wep_1p_HRG_Winterbite_anim.Wep_1stP_HRG_Winterbite_Anim"
	PickupMeshName="WEP_3P_HRG_Winterbite_MESH.Wep_HRG_Winterbite_Pickup"
	AttachmentArchetypeName="WEP_HRG_Winterbite_ARCH.Wep_HRG_Winterbite_3P"
	MuzzleFlashTemplateName="WEP_HRG_Winterbite_ARCH.Wep_HRG_Winterbite_MuzzleFlash"

	Begin Object Name=FirstPersonMesh
		AnimTreeTemplate=AnimTree'CHR_1P_Arms_ARCH.WEP_1stP_Animtree_Master_Revolver'
	End Object

   	// Position and FOV
   	PlayerViewOffset=(X=15.0,Y=14,Z=-6)
	IronSightPosition=(X=4,Y=0,Z=0)
	MeshFOV=60
	MeshIronSightFOV=55
    PlayerIronSightFOV=77

   	// Depth of field
	DOF_FG_FocalRadius=40
	DOF_FG_MaxNearBlurSize=3.5

	// Ammo
	MagazineCapacity[0]=6
	SpareAmmoCapacity[0]=150
	InitialSpareMags[0]=9
	AmmoPickupScale[0]=2.0
	bCanBeReloaded=true
	bReloadFromMagazine=true

	// Recoil
	maxRecoilPitch=400
	minRecoilPitch=350
	maxRecoilYaw=125
	minRecoilYaw=-125
	RecoilRate=0.08
	RecoilMaxYawLimit=500
	RecoilMinYawLimit=65035
	RecoilMaxPitchLimit=900
	RecoilMinPitchLimit=65035
	RecoilISMaxYawLimit=50
	RecoilISMinYawLimit=65485
	RecoilISMaxPitchLimit=400
	RecoilISMinPitchLimit=65485
	RecoilBlendOutRatio=0.75
	IronSightMeshFOVCompensationScale=1.5

	// DEFAULT_FIREMODE
	FiringStatesArray(DEFAULT_FIREMODE)=WeaponSingleFiring
	WeaponFireTypes(DEFAULT_FIREMODE)=EWFT_Projectile
	WeaponProjectiles(DEFAULT_FIREMODE)=class'KFProj_Explosive_HRGWinterbite'
	FireInterval(DEFAULT_FIREMODE)=+0.2
	InstantHitDamage(DEFAULT_FIREMODE)=49 //40.0
	InstantHitDamageTypes(DEFAULT_FIREMODE)=class'KFDT_Freeze_HRGWinterbiteImpact'
	Spread(DEFAULT_FIREMODE)=0.009 //0.015
	FireOffset=(X=20,Y=4.0,Z=-3)

	// ALT_FIREMODE
	FiringStatesArray(ALTFIRE_FIREMODE)=WeaponSingleFiring
	WeaponFireTypes(ALTFIRE_FIREMODE)=EWFT_None

	// BASH_FIREMODE
	InstantHitDamage(BASH_FIREMODE)=24
	InstantHitDamageTypes(BASH_FIREMODE)=class'KFDT_Bludgeon_HRGWinterbite'

	// Fire Effects
	WeaponFireSnd(DEFAULT_FIREMODE)=(DefaultCue=AkEvent'WW_WEP_Flare_Gun.Play_WEP_Flare_Gun_Fire_3P', FirstPersonCue=AkEvent'WW_WEP_Flare_Gun.Play_WEP_Flare_Gun_Fire_1P')
	WeaponDryFireSnd(DEFAULT_FIREMODE)=AkEvent'WW_WEP_Flare_Gun.Play_WEP_Flare_Gun_DryFire'

	// Inventory
	InventorySize=2
	GroupPriority=15
	bCanThrow=true
	bDropOnDeath=true
	WeaponSelectTexture=Texture2D'WEP_UI_HRG_Winterbite_Item_TEX.UI_WeaponSelect_HRG_Winterbite'
	bIsBackupWeapon=false
	DualClass=class'KFWeap_Pistol_DualHRGWinterbite'
    AssociatedPerkClasses(0)=class'KFPerk_Gunslinger'

	// Attachments
	bHasIronSights=true
	bHasFlashlight=true

	// Hammer lock control
	bHasFireLastAnims = true
	BonesToLockOnEmpty = (RW_Hammer)

	// Revolver
	bRevolver=true
	CylinderRotInfo=(Inc=-60.0, Time=0.0175/*about 0.07 in the anim divided by ratescale of 4*/)

	// Weapon Upgrade stat boosts
	WeaponUpgrades[1]=(Stats=((Stat=EWUS_Damage0, Scale=1.4f)))
	WeaponUpgrades[2]=(Stats=((Stat=EWUS_Damage0, Scale=1.8f), (Stat=EWUS_Weight, Add=1)))
	WeaponUpgrades[3]=(Stats=((Stat=EWUS_Damage0, Scale=2.0f), (Stat=EWUS_Weight, Add=2)))
}

