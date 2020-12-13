//=============================================================================
// KFWeap_AssaultRifle_Thompson
//=============================================================================
//
//=============================================================================
// Killing Floor 2
// Copyright (C) 2017 Tripwire Interactive LLC
//=============================================================================

class KFWeap_AssaultRifle_Thompson extends KFWeap_SMGBase;

defaultproperties
{
	bHasFireLastAnims=true
	BonesToLockOnEmpty=(RW_Charging_Handle)

	// Shooting Animations
	FireSightedAnims[0]=Shoot_Iron
	FireSightedAnims[1]=Shoot_Iron2
	FireSightedAnims[2]=Shoot_Iron3

    // FOV
    MeshFOV=75
	MeshIronSightFOV=52
    PlayerIronSightFOV=70

	// Depth of field
	DOF_FG_FocalRadius=85
	DOF_FG_MaxNearBlurSize=2.5

	// Content
	PackageKey="TommyGun"
	FirstPersonMeshName="WEP_1P_TommyGun_MESH.Wep_1stP_TommyGun_Rig"
	FirstPersonAnimSetNames(0)="WEP_1P_TommyGun_ANIM.WEP_1stP_TommyGun_Anim"
	PickupMeshName="WEP_3P_TommyGun_MESH.Wep_3rdP_TommyGun_Pickup"
	AttachmentArchetypeName="WEP_TommyGun_ARCH.Wep_TommyGun_3P"
	MuzzleFlashTemplateName="WEP_TommyGun_ARCH.Wep_TommyGun_MuzzleFlash"

   	// Zooming/Position
	PlayerViewOffset=(X=5.0,Y=9,Z=-5)
	IronSightPosition=(X=5,Y=0,Z=0)

	// Ammo
	MagazineCapacity[0]=50
	SpareAmmoCapacity[0]=250
	InitialSpareMags[0]=3
	bCanBeReloaded=true
	bReloadFromMagazine=true

	// Recoil
	maxRecoilPitch=130 //165
	minRecoilPitch=115 //130
	maxRecoilYaw=115  //130
	minRecoilYaw=-115 //130
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
	InventorySize=6
	GroupPriority=50
	WeaponSelectTexture=Texture2D'WEP_UI_TommyGun_TEX.UI_WeaponSelect_TommyGun'

	AssociatedPerkClasses(0)=class'KFPerk_SWAT'
   	AssociatedPerkClasses(1)=class'KFPerk_Commando'

	// DEFAULT_FIREMODE
	FireModeIconPaths(DEFAULT_FIREMODE)=Texture2D'ui_firemodes_tex.UI_FireModeSelect_BulletAuto'
	FiringStatesArray(DEFAULT_FIREMODE)=WeaponFiring
	WeaponFireTypes(DEFAULT_FIREMODE)=EWFT_InstantHit
	WeaponProjectiles(DEFAULT_FIREMODE)=class'KFProj_Bullet_AssaultRifle'
	InstantHitDamageTypes(DEFAULT_FIREMODE)=class'KFDT_Ballistic_Thompson'
	FireInterval(DEFAULT_FIREMODE)=+0.0833 // 720 RPM
	Spread(DEFAULT_FIREMODE)=0.025 //0.0085
	InstantHitDamage(DEFAULT_FIREMODE)=30.0 //25
	FireOffset=(X=30,Y=4.5,Z=-5)

	// ALT_FIREMODE
	FireModeIconPaths(ALTFIRE_FIREMODE)=Texture2D'ui_firemodes_tex.UI_FireModeSelect_BulletSingle'
	FiringStatesArray(ALTFIRE_FIREMODE)=WeaponSingleFiring
	WeaponFireTypes(ALTFIRE_FIREMODE)=EWFT_InstantHit
	WeaponProjectiles(ALTFIRE_FIREMODE)=class'KFProj_Bullet_AssaultRifle'
	InstantHitDamageTypes(ALTFIRE_FIREMODE)=class'KFDT_Ballistic_Thompson'
	FireInterval(ALTFIRE_FIREMODE)=+0.0833 // 720 RPM
	InstantHitDamage(ALTFIRE_FIREMODE)=30.0 //25
	Spread(ALTFIRE_FIREMODE)=0.025 //0.0085

	// BASH_FIREMODE
	InstantHitDamageTypes(BASH_FIREMODE)=class'KFDT_Bludgeon_Thompson'
	InstantHitDamage(BASH_FIREMODE)=26

	// Fire Effects
	WeaponFireSnd(DEFAULT_FIREMODE)=(DefaultCue=AkEvent'WW_WEP_Thompson.Play_WEP_Thompson_Fire_3P_Loop', FirstPersonCue=AkEvent'WW_WEP_Thompson.Play_WEP_Thompson_Fire_1P_Loop')
	WeaponFireSnd(ALTFIRE_FIREMODE)=(DefaultCue=AkEvent'WW_WEP_Thompson.Play_WEP_Thompson_Fire_3P_Single', FirstPersonCue=AkEvent'WW_WEP_Thompson.Play_WEP_Thompson_Fire_1P_Single')
	WeaponFireLoopEndSnd(DEFAULT_FIREMODE)=(DefaultCue=AkEvent'WW_WEP_Thompson.Play_WEP_Thompson_Fire_3P_EndLoop', FirstPersonCue=AkEvent'WW_WEP_Thompson.Play_WEP_Thompson_Fire_1P_EndLoop')

	WeaponDryFireSnd(DEFAULT_FIREMODE)=AkEvent'WW_WEP_SA_L85A2.Play_WEP_SA_L85A2_Handling_DryFire'
	WeaponDryFireSnd(ALTFIRE_FIREMODE)=AkEvent'WW_WEP_SA_L85A2.Play_WEP_SA_L85A2_Handling_DryFire'

	// Advanced (High RPM) Fire Effects
	bLoopingFireAnim(DEFAULT_FIREMODE)=true
	bLoopingFireSnd(DEFAULT_FIREMODE)=true
	SingleFireSoundIndex=ALTFIRE_FIREMODE

	// Attachments
	bHasIronSights=true
	bHasFlashlight=false

		// Weapon Upgrade stat boosts
	//WeaponUpgrades[1]=(IncrementDamage=1.2f,IncrementWeight=1)
	//WeaponUpgrades[2]=(IncrementDamage=1.4f,IncrementWeight=2)
	//WeaponUpgrades[3]=(IncrementDamage=1.6f,IncrementWeight=3)

	WeaponUpgrades[1]=(Stats=((Stat=EWUS_Damage0, Scale=1.2f), (Stat=EWUS_Damage1, Scale=1.2f), (Stat=EWUS_Weight, Add=1)))
	WeaponUpgrades[2]=(Stats=((Stat=EWUS_Damage0, Scale=1.4f), (Stat=EWUS_Damage1, Scale=1.4f), (Stat=EWUS_Weight, Add=2)))
	WeaponUpgrades[3]=(Stats=((Stat=EWUS_Damage0, Scale=1.6f), (Stat=EWUS_Damage1, Scale=1.6f), (Stat=EWUS_Weight, Add=3)))
}
