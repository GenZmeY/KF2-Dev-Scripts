//=============================================================================
// KFWeap_SMG_P90
//=============================================================================
// Class Description
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//  - Author 11/20/2013
//=============================================================================

class KFWeap_SMG_P90 extends KFWeap_SMGBase;

defaultproperties
{
	// Inventory
	InventorySize=5
	GroupPriority=80
	WeaponSelectTexture=Texture2D'WEP_UI_P90_TEX.UI_WeaponSelect_FNP90'

	// FOV
	MeshFOV=75
	MeshIronSightFOV=55
	PlayerIronSightFOV=75

	// Zooming/Position
	IronSightPosition=(X=0.f,Y=0.f,Z=0.f)
	PlayerViewOffset=(X=19,Y=10,Z=-0.5)

	//Content
	PackageKey="P90"
	FirstPersonMeshName="wep_1p_p90_mesh.Wep_1stP_P90_Rig"
	FirstPersonAnimSetNames(0)="wep_1p_p90_anim.Wep_1stP_P90_Anim"
	PickupMeshName="wep_3p_p90_mesh.Wep_P90_Pickup"
	AttachmentArchetypeName="wep_p90_arch.Wep_P90_3P"
	MuzzleFlashTemplateName="wep_p90_arch.Wep_P90_MuzzleFlash"

	// Ammo
	MagazineCapacity[0]=50
	SpareAmmoCapacity[0]=350
	InitialSpareMags[0]=2
	bCanBeReloaded=true
	bReloadFromMagazine=true

	// Recoil
	maxRecoilPitch=80
	minRecoilPitch=65
	maxRecoilYaw=60
	minRecoilYaw=-60
	RecoilRate=0.063
	RecoilMaxYawLimit=400
	RecoilMinYawLimit=65135
	RecoilMaxPitchLimit=800
	RecoilMinPitchLimit=65035
	RecoilISMaxYawLimit=150
	RecoilISMinYawLimit=65385
	RecoilISMaxPitchLimit=350
	RecoilISMinPitchLimit=65435
	IronSightMeshFOVCompensationScale=1.5

	// DEFAULT_FIREMODE
	FireModeIconPaths(DEFAULT_FIREMODE)=Texture2D'ui_firemodes_tex.UI_FireModeSelect_BulletAuto'
	FiringStatesArray(DEFAULT_FIREMODE)=WeaponFiring
	WeaponFireTypes(DEFAULT_FIREMODE)=EWFT_InstantHit
	WeaponProjectiles(DEFAULT_FIREMODE)=class'KFProj_Bullet_AssaultRifle'
	InstantHitDamageTypes(DEFAULT_FIREMODE)=class'KFDT_Ballistic_P90'
	FireInterval(DEFAULT_FIREMODE)=+.07 // 900 RPM
	Spread(DEFAULT_FIREMODE)=0.015
	InstantHitDamage(DEFAULT_FIREMODE)=30
	FireOffset=(X=30,Y=4.5,Z=-5)

	// ALT_FIREMODE
	FireModeIconPaths(ALTFIRE_FIREMODE)=Texture2D'ui_firemodes_tex.UI_FireModeSelect_BulletSingle'
	FiringStatesArray(ALTFIRE_FIREMODE)=WeaponSingleFiring
	WeaponFireTypes(ALTFIRE_FIREMODE)=EWFT_InstantHit
	WeaponProjectiles(ALTFIRE_FIREMODE)=class'KFProj_Bullet_AssaultRifle'
	InstantHitDamageTypes(ALTFIRE_FIREMODE)=class'KFDT_Ballistic_P90'
	FireInterval(ALTFIRE_FIREMODE)=+0.1
	InstantHitDamage(ALTFIRE_FIREMODE)=30
	Spread(ALTFIRE_FIREMODE)=0.015

	// BASH_FIREMODE
	InstantHitDamageTypes(BASH_FIREMODE)=class'KFDT_Bludgeon_P90'
	InstantHitDamage(BASH_FIREMODE)=25

	// Fire Effects
	WeaponFireSnd(DEFAULT_FIREMODE)=(DefaultCue=AkEvent'WW_WEP_P90.Play_P90_Fire_3P_Loop', FirstPersonCue=AkEvent'WW_WEP_P90.Play_P90_Fire_1P_Loop')
	WeaponFireSnd(ALTFIRE_FIREMODE)=(DefaultCue=AkEvent'WW_WEP_P90.Play_P90_Fire_3P_Single', FirstPersonCue=AkEvent'WW_WEP_P90.Play_P90_Fire_1P_Single')

	//@todo: add akevents when we have them
	WeaponDryFireSnd(DEFAULT_FIREMODE)=none
	WeaponDryFireSnd(ALTFIRE_FIREMODE)=none

	// Advanced (High RPM) Fire Effects
	bLoopingFireAnim(DEFAULT_FIREMODE)=true
	bLoopingFireSnd(DEFAULT_FIREMODE)=true
	WeaponFireLoopEndSnd(DEFAULT_FIREMODE)=(DefaultCue=AkEvent'WW_WEP_P90.Play_P90_Fire_3P_EndLoop', FirstPersonCue=AkEvent'WW_WEP_P90.Play_P90_Fire_1P_EndLoop')
	SingleFireSoundIndex=ALTFIRE_FIREMODE

	// Attachments
	bHasIronSights=true
	bHasFlashlight=true

	AssociatedPerkClasses(0)=class'KFPerk_Swat'

	// Weapon Upgrade stat boosts
	//WeaponUpgrades[1]=(IncrementDamage=1.14f,IncrementWeight=1)
	//WeaponUpgrades[2]=(IncrementDamage=1.28f,IncrementWeight=2)

	WeaponUpgrades[1]=(Stats=((Stat=EWUS_Damage0, Scale=1.14f), (Stat=EWUS_Damage1, Scale=1.14f), (Stat=EWUS_Weight, Add=1)))
	WeaponUpgrades[2]=(Stats=((Stat=EWUS_Damage0, Scale=1.28f), (Stat=EWUS_Damage1, Scale=1.28f), (Stat=EWUS_Weight, Add=2)))
}
