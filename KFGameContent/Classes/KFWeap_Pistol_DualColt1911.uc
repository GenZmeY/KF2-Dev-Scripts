//=============================================================================
// KFWeap_Pistol_DualColt1911
//=============================================================================
// A set of Colt 1911 pistols
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
// Jeff Robinson
//=============================================================================

class KFWeap_Pistol_DualColt1911 extends KFWeap_DualBase;

defaultproperties
{
	// Content
	PackageKey="Dual_M1911"
	FirstPersonMeshName="WEP_1P_Dual_M1911_MESH.Wep_1stP_Dual_M1911_Rig"
	FirstPersonAnimSetNames(0)="WEP_1P_Dual_M1911_ANIM.Wep_1stP_Dual_M1911_Anim"
	PickupMeshName="WEP_3P_Dual_M1911_MESH.Wep_M1911_Pickup"
	AttachmentArchetypeName="WEP_Dual_M1911_ARCH.Wep_Dual_M1911_3P"
	MuzzleFlashTemplateName="WEP_Dual_M1911_ARCH.Wep_Dual_M1911_MuzzleFlash"

	FireOffset=(X=17,Y=4.0,Z=-2.25)
	LeftFireOffset=(X=17,Y=-4,Z=-2.25)

	// Zooming/Position
	IronSightPosition=(X=15,Y=0,Z=0)
	PlayerViewOffset=(X=16,Y=0,Z=-5)
	QuickWeaponDownRotation=(Pitch=-8192,Yaw=0,Roll=0)

	bCanThrow=true
	bDropOnDeath=true

	SingleClass=class'KFWeap_Pistol_Colt1911'

	// FOV
	MeshFOV=75
	MeshIronSightFOV=60
    PlayerIronSightFOV=77

	// Depth of field
	DOF_FG_FocalRadius=40
	DOF_FG_MaxNearBlurSize=3.5

	// Ammo
	MagazineCapacity[0]=16
	SpareAmmoCapacity[0]=128
	InitialSpareMags[0]=3
	AmmoPickupScale[0]=1.0
	bCanBeReloaded=true
	bReloadFromMagazine=true

	// Recoil
	maxRecoilPitch=450
	minRecoilPitch=400
	maxRecoilYaw=150
	minRecoilYaw=-150
	RecoilRate=0.07
	RecoilMaxYawLimit=500
	RecoilMinYawLimit=65035
	RecoilMaxPitchLimit=900
	RecoilMinPitchLimit=65035
	RecoilISMaxYawLimit=50
	RecoilISMinYawLimit=65485
	RecoilISMaxPitchLimit=500
	RecoilISMinPitchLimit=65485
	IronSightMeshFOVCompensationScale=1.35

	// DEFAULT_FIREMODE
	FiringStatesArray(DEFAULT_FIREMODE)=WeaponSingleFiring
	WeaponFireTypes(DEFAULT_FIREMODE)=EWFT_InstantHit
	WeaponProjectiles(DEFAULT_FIREMODE)=class'KFProj_Bullet_PistolColt1911'
	FireInterval(DEFAULT_FIREMODE)=+0.1 // about twice as fast as single
	InstantHitDamage(DEFAULT_FIREMODE)=50.0
	InstantHitDamageTypes(DEFAULT_FIREMODE)=class'KFDT_Ballistic_Colt1911'
	PenetrationPower(DEFAULT_FIREMODE)=1.0
	Spread(DEFAULT_FIREMODE)=0.015

	FireModeIconPaths(DEFAULT_FIREMODE)=Texture2D'ui_firemodes_tex.UI_FireModeSelect_BulletSingle'

	// ALTFIRE_FIREMODE
	FiringStatesArray(ALTFIRE_FIREMODE)=WeaponSingleFiring
	WeaponFireTypes(ALTFIRE_FIREMODE)=EWFT_InstantHit
	WeaponProjectiles(ALTFIRE_FIREMODE)=class'KFProj_Bullet_PistolColt1911'
	FireInterval(ALTFIRE_FIREMODE)=+0.1 // about twice as fast as single
	InstantHitDamage(ALTFIRE_FIREMODE)=50.0
	InstantHitDamageTypes(ALTFIRE_FIREMODE)=class'KFDT_Ballistic_Colt1911'
	PenetrationPower(ALTFIRE_FIREMODE)=1.0
	Spread(ALTFIRE_FIREMODE)=0.015

	FireModeIconPaths(ALTFIRE_FIREMODE)=Texture2D'ui_firemodes_tex.UI_FireModeSelect_BulletSingle'

	// BASH_FIREMODE
	InstantHitDamage(BASH_FIREMODE)=24
	InstantHitDamageTypes(BASH_FIREMODE)=class'KFDT_Bludgeon_Colt1911'

	// Fire Effects
	WeaponFireSnd(DEFAULT_FIREMODE)=(DefaultCue=AkEvent'WW_WEP_1911.Play_WEP_SA_1911_Fire_Single_M', FirstPersonCue=AkEvent'WW_WEP_1911.Play_WEP_SA_1911_Fire_Single_S')
	WeaponDryFireSnd(DEFAULT_FIREMODE)=AkEvent'WW_WEP_1911.Play_WEP_SA_1911_Handling_DryFire'

	WeaponFireSnd(ALTFIRE_FIREMODE)=(DefaultCue=AkEvent'WW_WEP_1911.Play_WEP_SA_1911_Fire_Single_M', FirstPersonCue=AkEvent'WW_WEP_1911.Play_WEP_SA_1911_Fire_Single_S')
	WeaponDryFireSnd(ALTFIRE_FIREMODE)=AkEvent'WW_WEP_1911.Play_WEP_SA_1911_Handling_DryFire'

	// Attachments
	bHasIronSights=true
	bHasFlashlight=true

	// Inventory
	InventorySize=4
	GroupPriority=40
	WeaponSelectTexture=Texture2D'WEP_UI_Dual_M1911_TEX.UI_WeaponSelect_DualM1911'
	bIsBackupWeapon=false
	AssociatedPerkClasses(0)=class'KFPerk_Gunslinger'

	BonesToLockOnEmpty=(RW_Bolt, RW_Bullets1)
    BonesToLockOnEmpty_L=(LW_Bolt, LW_Bullets1)

    bHasFireLastAnims=true

    // Weapon Upgrade stat boosts
	//WeaponUpgrades[1]=(IncrementDamage=1.4f,IncrementWeight=0)
	//WeaponUpgrades[2]=(IncrementDamage=1.8f,IncrementWeight=2)
	//WeaponUpgrades[3]=(IncrementDamage=2.0f,IncrementWeight=4)

	WeaponUpgrades[1]=(Stats=((Stat=EWUS_Damage0, Scale=1.4f), (Stat=EWUS_Damage1, Scale=1.4f)))
	WeaponUpgrades[2]=(Stats=((Stat=EWUS_Damage0, Scale=1.8f), (Stat=EWUS_Damage1, Scale=1.8f), (Stat=EWUS_Weight, Add=2)))
	WeaponUpgrades[3]=(Stats=((Stat=EWUS_Damage0, Scale=2.0f), (Stat=EWUS_Damage1, Scale=2.0f), (Stat=EWUS_Weight, Add=4)))
}

