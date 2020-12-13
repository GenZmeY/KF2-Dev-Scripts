//=============================================================================
// KFWeap_Pistol_Dual9mm
//=============================================================================
// A set of 9mm Beretta Pistols
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
// John "Ramm-Jaeger" Gibson and Jeff Robinson
//=============================================================================

class KFWeap_Pistol_Dual9mm extends KFWeap_DualBase;

defaultproperties
{
	// Content
	PackageKey="Dual_9mm"
	FirstPersonMeshName="WEP_1P_Dual_9MM_MESH.Wep_1stP_Dual_9mm_Rig"
	FirstPersonAnimSetNames(0)="WEP_1P_Dual_9MM_ANIM.Wep_1stP_Dual_9MM_Anim"
	PickupMeshName="WEP_3P_Dual_9MM_MESH.Wep_9mm_Pickup"
	AttachmentArchetypeName="WEP_Dual_9MM_ARCH.WEP_Dual_9MM_3P"
	MuzzleFlashTemplateName="wep_dual_9mm_arch.Wep_Dual_9MM_MuzzleFlash"

	FireOffset=(X=17,Y=4.0,Z=-2.25)
	LeftFireOffset=(X=17,Y=-4,Z=-2.25)

	// Zooming/Position
	IronSightPosition=(X=-3,Y=0,Z=0)
	PlayerViewOffset=(X=5,Y=0,Z=-5)
	QuickWeaponDownRotation=(Pitch=-8192,Yaw=0,Roll=0)

	bCanThrow=true
	bDropOnDeath=true

	SingleClass=class'KFWeap_Pistol_9mm'

	// FOV
	MeshFOV=96
	MeshIronSightFOV=77
    PlayerIronSightFOV=77

	// Depth of field
	DOF_FG_FocalRadius=40
	DOF_FG_MaxNearBlurSize=3.5

	// Ammo
	MagazineCapacity[0]=30 // twice as much as single
	SpareAmmoCapacity[0]=60 //210
	InitialSpareMags[0]=2
	AmmoPickupScale[0]=1.0
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
	FireInterval(DEFAULT_FIREMODE)=+0.12 // about twice as fast as single
	InstantHitDamage(DEFAULT_FIREMODE)=25.0 //15
	InstantHitDamageTypes(DEFAULT_FIREMODE)=class'KFDT_Ballistic_9mm'
	Spread(DEFAULT_FIREMODE)=0.015

	FireModeIconPaths(DEFAULT_FIREMODE)=Texture2D'ui_firemodes_tex.UI_FireModeSelect_BulletSingle'

	// ALTFIRE_FIREMODE
	FiringStatesArray(ALTFIRE_FIREMODE)=WeaponSingleFiring
	WeaponFireTypes(ALTFIRE_FIREMODE)=EWFT_InstantHit
	WeaponProjectiles(ALTFIRE_FIREMODE)=class'KFProj_Bullet_Pistol9mm'
	FireInterval(ALTFIRE_FIREMODE)=+0.12 // about twice as fast as single
	InstantHitDamage(ALTFIRE_FIREMODE)=25.0 //15
	InstantHitDamageTypes(ALTFIRE_FIREMODE)=class'KFDT_Ballistic_9mm'
	Spread(ALTFIRE_FIREMODE)=0.015

	FireModeIconPaths(ALTFIRE_FIREMODE)=Texture2D'ui_firemodes_tex.UI_FireModeSelect_BulletSingle'

	// BASH_FIREMODE
	InstantHitDamage(BASH_FIREMODE)=22
	InstantHitDamageTypes(BASH_FIREMODE)=class'KFDT_Bludgeon_9mm'

	// Fire Effects
	WeaponFireSnd(DEFAULT_FIREMODE)=(DefaultCue=AkEvent'WW_WEP_SA_9mm.Play_WEP_SA_9mm_Fire_Single_M', FirstPersonCue=AkEvent'WW_WEP_SA_9mm.Play_WEP_SA_9mm_Fire_Single_S')
	WeaponDryFireSnd(DEFAULT_FIREMODE)=AkEvent'WW_WEP_SA_9mm.Play_WEP_SA_9mm_Handling_DryFire'

	WeaponFireSnd(ALTFIRE_FIREMODE)=(DefaultCue=AkEvent'WW_WEP_SA_9mm.Play_WEP_SA_9mm_Fire_Single_M', FirstPersonCue=AkEvent'WW_WEP_SA_9mm.Play_WEP_SA_9mm_Fire_Single_S')
	WeaponDryFireSnd(ALTFIRE_FIREMODE)=AkEvent'WW_WEP_SA_9mm.Play_WEP_SA_9mm_Handling_DryFire'

	// Attachments
	bHasIronSights=true
	bHasFlashlight=true

	AssociatedPerkClasses(0)=none

	// Inventory
	InventoryGroup=IG_Secondary
	InventorySize=2
	GroupPriority=20
	WeaponSelectTexture=Texture2D'WEP_UI_Dual_9MM_TEX.UI_WeaponSelect_Dual9mm'
	bIsBackupWeapon=false

	BonesToLockOnEmpty=(RW_Bolt, RW_Bullets1)
    BonesToLockOnEmpty_L=(LW_Bolt, LW_Bullets1)

    bHasFireLastAnims=true

    // Weapon Upgrade stat boosts
	//WeaponUpgrades[1]=(IncrementDamage=1.2f,IncrementWeight=0)
	//WeaponUpgrades[2]=(IncrementDamage=1.4f,IncrementWeight=0) //1
	//WeaponUpgrades[3]=(IncrementDamage=1.6f,IncrementWeight=0) //1
	//WeaponUpgrades[4]=(IncrementDamage=1.8f,IncrementWeight=0) //2
	//WeaponUpgrades[5]=(IncrementDamage=2.0f,IncrementWeight=0) //3

	WeaponUpgrades[1]=(Stats=((Stat=EWUS_Damage0, Scale=1.2f), (Stat=EWUS_Damage1, Scale=1.2f)))
	WeaponUpgrades[2]=(Stats=((Stat=EWUS_Damage0, Scale=1.4f), (Stat=EWUS_Damage1, Scale=1.4f)))
	WeaponUpgrades[3]=(Stats=((Stat=EWUS_Damage0, Scale=1.6f), (Stat=EWUS_Damage1, Scale=1.6f)))
	WeaponUpgrades[4]=(Stats=((Stat=EWUS_Damage0, Scale=1.8f), (Stat=EWUS_Damage1, Scale=1.8f)))
	WeaponUpgrades[5]=(Stats=((Stat=EWUS_Damage0, Scale=2.0f), (Stat=EWUS_Damage1, Scale=2.0f)))
}

