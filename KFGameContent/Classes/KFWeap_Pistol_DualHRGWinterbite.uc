//=============================================================================
// KFWeap_Pistol_DualHRGWinterbite
//=============================================================================
// A frosty twist on the Spitfire (KFWeap_Pistol_Flare)
//=============================================================================
// Killing Floor 2
// Copyright (C) 2019 Tripwire Interactive LLC
//=============================================================================

class KFWeap_Pistol_DualHRGWinterbite extends KFWeap_DualBase;

static simulated event EFilterTypeUI GetAltTraderFilter()
{
    return FT_Flame;
}

defaultproperties
{
	//Content
	PackageKey="dual_Winterbite"
	FirstPersonMeshName="wep_1p_dual_winterbite_mesh.Wep_1stP_Dual_Winterbite_Rig"
	FirstPersonAnimSetNames(0)="wep_1p_dual_Winterbite_anim.Wep_1stP_Dual_Winterbite_Anim"
	PickupMeshName="WEP_3P_HRG_Winterbite_MESH.Wep_HRG_Winterbite_Pickup"
	AttachmentArchetypeName="wep_dual_winterbite_arch.Wep_Dual_Winterbite_3P"
	MuzzleFlashTemplateName="wep_dual_winterbite_arch.Wep_Winterbite_MuzzleFlash"

	Begin Object Name=FirstPersonMesh
		AnimTreeTemplate=AnimTree'CHR_1P_Arms_ARCH.WEP_1stP_Dual_Animtree_Master_Revolver'
	End Object

	FireOffset=(X=17,Y=4.0,Z=-2.25)
	LeftFireOffset=(X=17,Y=-4,Z=-2.25)

	// Position and FOV
	IronSightPosition=(X=4,Y=0,Z=0)
	PlayerViewOffset=(X=23,Y=0,Z=-1)
	QuickWeaponDownRotation=(Pitch=-8192,Yaw=0,Roll=0)
	MeshFOV=60
	MeshIronSightFOV=55
    PlayerIronSightFOV=77

	// Depth of field
	DOF_FG_FocalRadius=40
	DOF_FG_MaxNearBlurSize=3.5

	// Ammo
	MagazineCapacity[0]=12 // twice as much as single
	SpareAmmoCapacity[0]=144
	InitialSpareMags[0]=4
	AmmoPickupScale[0]=1.0
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
	FireInterval(DEFAULT_FIREMODE)=+0.11 // about twice as fast as single
	InstantHitDamage(DEFAULT_FIREMODE)=49 //40.0
	InstantHitDamageTypes(DEFAULT_FIREMODE)=class'KFDT_Freeze_HRGWinterbiteImpact'
	Spread(DEFAULT_FIREMODE)=0.009 //0.015
	FireModeIconPaths(DEFAULT_FIREMODE)=Texture2D'ui_firemodes_tex.UI_FireModeSelect_BulletSingle'

	// ALTFIRE_FIREMODE
	FiringStatesArray(ALTFIRE_FIREMODE)=WeaponSingleFiring
	WeaponFireTypes(ALTFIRE_FIREMODE)=EWFT_Projectile
	WeaponProjectiles(ALTFIRE_FIREMODE)=class'KFProj_Explosive_HRGWinterbite'
	FireInterval(ALTFIRE_FIREMODE)=+0.11 // about twice as fast as single
	InstantHitDamage(ALTFIRE_FIREMODE)=49 //40.0
	InstantHitDamageTypes(ALTFIRE_FIREMODE)=class'KFDT_Freeze_HRGWinterbiteImpact'
	Spread(ALTFIRE_FIREMODE)=0.009 //0.015
	FireModeIconPaths(ALTFIRE_FIREMODE)=Texture2D'ui_firemodes_tex.UI_FireModeSelect_BulletSingle'

	// BASH_FIREMODE
	InstantHitDamage(BASH_FIREMODE)=24.0
	InstantHitDamageTypes(BASH_FIREMODE)=class'KFDT_Bludgeon_HRGWinterbite'

	// Fire Effects
	WeaponFireSnd(DEFAULT_FIREMODE)=(DefaultCue=AkEvent'WW_WEP_Flare_Gun.Play_WEP_Flare_Gun_Fire_3P', FirstPersonCue=AkEvent'WW_WEP_Flare_Gun.Play_WEP_Flare_Gun_Fire_1P')
	WeaponDryFireSnd(DEFAULT_FIREMODE)=AkEvent'WW_WEP_Flare_Gun.Play_WEP_Flare_Gun_DryFire'

	WeaponFireSnd(ALTFIRE_FIREMODE)=(DefaultCue=AkEvent'WW_WEP_Flare_Gun.Play_WEP_Flare_Gun_Fire_3P', FirstPersonCue=AkEvent'WW_WEP_Flare_Gun.Play_WEP_Flare_Gun_Fire_1P')
	WeaponDryFireSnd(ALTFIRE_FIREMODE)=AkEvent'WW_WEP_Flare_Gun.Play_WEP_Flare_Gun_DryFire'

	// Inventory
	InventorySize=4
	GroupPriority=35
	WeaponSelectTexture=Texture2D'WEP_UI_Dual_Winterbite_Item_TEX.UI_WeaponSelect_HRG_DualWinterbite'
	bIsBackupWeapon=false
	bCanThrow=true
	bDropOnDeath=true
	SingleClass=class'KFWeap_Pistol_HRGWinterbite'
    AssociatedPerkClasses(0)=class'KFPerk_Gunslinger'

	// Attachments
	bHasIronSights=true
	bHasFlashlight=true

	// Hammer lock control
	bHasFireLastAnims=true
	BonesToLockOnEmpty=(RW_Hammer)
	BonesToLockOnEmpty_L=(LW_Hammer)

	// Revolver
	bRevolver=true
	CylinderRotInfo=(Inc=-60.0, Time=0.0875/*about 0.35 in the anim divided by ratescale of 4*/)
	CylinderRotInfo_L=(Inc=-60.0, Time=0.0875/*about 0.35 in the anim divided by ratescale of 4*/)

	// Weapon Upgrade stat boosts
	WeaponUpgrades[1]=(Stats=((Stat=EWUS_Damage0, Scale=1.4f), (Stat=EWUS_Damage1, Scale=1.4f)))
	WeaponUpgrades[2]=(Stats=((Stat=EWUS_Damage0, Scale=1.8f), (Stat=EWUS_Damage1, Scale=1.8f), (Stat=EWUS_Weight, Add=2)))
	WeaponUpgrades[3]=(Stats=((Stat=EWUS_Damage0, Scale=2.0f), (Stat=EWUS_Damage1, Scale=2.0f), (Stat=EWUS_Weight, Add=4)))
}

