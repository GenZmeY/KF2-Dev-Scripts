//=============================================================================
// KFWeap_Pistol_9mm
//=============================================================================
// An 9mm Beretta Pistol
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
// John "Ramm-Jaeger" Gibson
//=============================================================================

class KFWeap_Pistol_9mm extends KFWeap_PistolBase;

defaultproperties
{
    // FOV
	MeshFOV=96
	MeshIronSightFOV=77
    PlayerIronSightFOV=77

	// Depth of field
	DOF_FG_FocalRadius=40
	DOF_FG_MaxNearBlurSize=3.5

	// Zooming/Position
	PlayerViewOffset=(X=12.0,Y=12,Z=-6)

	// Content
	PackageKey="9mm"
	FirstPersonMeshName="WEP_1P_9MM_MESH.Wep_1stP_9mm_Rig"
	FirstPersonAnimSetNames(0)="WEP_1P_9MM_ANIM.Wep_1stP_9MM_Anim"
	PickupMeshName="WEP_3P_9MM_MESH.Wep_9mm_Pickup"
	AttachmentArchetypeName="WEP_9MM_ARCH.Wep_9mm_3P"
	MuzzleFlashTemplateName="WEP_9MM_ARCH.Wep_9MM_MuzzleFlash"

   	// Zooming/Position
	IronSightPosition=(X=10,Y=0,Z=0)

	// Ammo
	MagazineCapacity[0]=15
	SpareAmmoCapacity[0]=75 //225
	InitialSpareMags[0]=4
	bCanBeReloaded=true
	bReloadFromMagazine=true

	// Recoil
	maxRecoilPitch=250
	minRecoilPitch=200
	maxRecoilYaw=100
	minRecoilYaw=-100
	RecoilRate=0.07
	RecoilMaxYawLimit=500
	RecoilMinYawLimit=65035
	RecoilMaxPitchLimit=900
	RecoilMinPitchLimit=65035
	RecoilISMaxYawLimit=50
	RecoilISMinYawLimit=65485
	RecoilISMaxPitchLimit=250
	RecoilISMinPitchLimit=65485

	// DEFAULT_FIREMODE
	FiringStatesArray(DEFAULT_FIREMODE)=WeaponSingleFiring
	WeaponFireTypes(DEFAULT_FIREMODE)=EWFT_InstantHit
	WeaponProjectiles(DEFAULT_FIREMODE)=class'KFProj_Bullet_Pistol9mm'
	FireInterval(DEFAULT_FIREMODE)=+0.2 //0.175
	InstantHitDamage(DEFAULT_FIREMODE)=25.0 //15
	InstantHitDamageTypes(DEFAULT_FIREMODE)=class'KFDT_Ballistic_9mm'
	Spread(DEFAULT_FIREMODE)=0.015
	FireOffset=(X=20,Y=4.0,Z=-3)

	// ALT_FIREMODE
	FiringStatesArray(ALTFIRE_FIREMODE)=WeaponSingleFiring
	WeaponFireTypes(ALTFIRE_FIREMODE)=EWFT_None

	// BASH_FIREMODE
	InstantHitDamageTypes(BASH_FIREMODE)=class'KFDT_Bludgeon_9mm'
	InstantHitDamage(BASH_FIREMODE)=20

	// Fire Effects
	WeaponFireSnd(DEFAULT_FIREMODE)=(DefaultCue=AkEvent'WW_WEP_SA_9mm.Play_WEP_SA_9mm_Fire_Single_M', FirstPersonCue=AkEvent'WW_WEP_SA_9mm.Play_WEP_SA_9mm_Fire_Single_S')
	WeaponDryFireSnd(DEFAULT_FIREMODE)=AkEvent'WW_WEP_SA_9mm.Play_WEP_SA_9mm_Handling_DryFire'

	// Attachments
	bHasIronSights=true
	bHasFlashlight=true

	AssociatedPerkClasses(0)=none

	// Inventory
	InventorySize=0
	GroupPriority=13
	bCanThrow=false
	bDropOnDeath=false
	WeaponSelectTexture=Texture2D'ui_weaponselect_tex.UI_WeaponSelect_9mm'
	bIsBackupWeapon=true

	DualClass=class'KFWeap_Pistol_Dual9mm'

	// Custom animations
	FireSightedAnims=(Shoot_Iron, Shoot_Iron2, Shoot_Iron3)
	IdleFidgetAnims=(Guncheck_v1, Guncheck_v2, Guncheck_v3, Guncheck_v4)

	bHasFireLastAnims=true

	BonesToLockOnEmpty=(RW_Bolt, RW_Bullets1)

	// Weapon Upgrade stat boosts. Setting weight to 0 because single 9MM cannot be sold.
	//WeaponUpgrades[1]=(IncrementDamage=1.2f,IncrementWeight=0)
	//WeaponUpgrades[2]=(IncrementDamage=1.4f,IncrementWeight=0) //1
	//WeaponUpgrades[3]=(IncrementDamage=1.6f,IncrementWeight=0) //1
	//WeaponUpgrades[4]=(IncrementDamage=1.8f,IncrementWeight=0) //2
	//WeaponUpgrades[5]=(IncrementDamage=2.0f,IncrementWeight=0) //3

	WeaponUpgrades[1]=(Stats=((Stat=EWUS_Damage0, Scale=1.2f)))
	WeaponUpgrades[2]=(Stats=((Stat=EWUS_Damage0, Scale=1.4f)))
	WeaponUpgrades[3]=(Stats=((Stat=EWUS_Damage0, Scale=1.6f)))
	WeaponUpgrades[4]=(Stats=((Stat=EWUS_Damage0, Scale=1.8f)))
	WeaponUpgrades[5]=(Stats=((Stat=EWUS_Damage0, Scale=2.0f)))
}

