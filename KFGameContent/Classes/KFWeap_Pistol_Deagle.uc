//=============================================================================
// KFWeap_Pistol_Deagle
//=============================================================================
// A Desert Eagle pistol
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
// Jeff Robinson
//=============================================================================

class KFWeap_Pistol_Deagle extends KFWeap_PistolBase;

defaultproperties
{
    // FOV
	MeshFOV=86
	MeshIronSightFOV=77
    PlayerIronSightFOV=77

	// Depth of field
	DOF_FG_FocalRadius=38
	DOF_FG_MaxNearBlurSize=3.5

	// Zooming/Position
	PlayerViewOffset=(X=14.0,Y=10,Z=-4)

	// Content
	PackageKey="Deagle"
	FirstPersonMeshName="WEP_1P_Deagle_MESH.Wep_1stP_Deagle_Rig"
	FirstPersonAnimSetNames(0)="WEP_1P_Deagle_ANIM.Wep_1st_Deagle_Anim"
	PickupMeshName="WEP_3P_Deagle_MESH.Wep_Deagle_Pickup"
	AttachmentArchetypeName="WEP_Deagle_ARCH.Wep_Deagle_3P"
	MuzzleFlashTemplateName="WEP_Deagle_ARCH.Wep_Deagle_MuzzleFlash"

   	// Zooming/Position
	IronSightPosition=(X=11,Y=0,Z=0)

	// Ammo
	MagazineCapacity[0]=7
	SpareAmmoCapacity[0]=105
	InitialSpareMags[0]=5
	AmmoPickupScale[0]=2.0
	bCanBeReloaded=true
	bReloadFromMagazine=true

	// Recoil
	maxRecoilPitch=650
	minRecoilPitch=550
	maxRecoilYaw=150
	minRecoilYaw=-150
	RecoilRate=0.07
	RecoilMaxYawLimit=500
	RecoilMinYawLimit=65035
	RecoilMaxPitchLimit=1250
	RecoilMinPitchLimit=65035
	RecoilISMaxYawLimit=50
	RecoilISMinYawLimit=65485
	RecoilISMaxPitchLimit=500
	RecoilISMinPitchLimit=65485

	// DEFAULT_FIREMODE
	FiringStatesArray(DEFAULT_FIREMODE)=WeaponSingleFiring
	WeaponFireTypes(DEFAULT_FIREMODE)=EWFT_InstantHit
	WeaponProjectiles(DEFAULT_FIREMODE)=class'KFProj_Bullet_Pistol50AE'
	FireInterval(DEFAULT_FIREMODE)=+0.2
	InstantHitDamage(DEFAULT_FIREMODE)=91.0
	InstantHitDamageTypes(DEFAULT_FIREMODE)=class'KFDT_Ballistic_Deagle'
	PenetrationPower(DEFAULT_FIREMODE)=2.0
	Spread(DEFAULT_FIREMODE)=0.01
	FireOffset=(X=20,Y=4.0,Z=-3)

	// ALT_FIREMODE
	FiringStatesArray(ALTFIRE_FIREMODE)=WeaponSingleFiring
	WeaponFireTypes(ALTFIRE_FIREMODE)=EWFT_None

	// BASH_FIREMODE
	InstantHitDamageTypes(BASH_FIREMODE)=class'KFDT_Bludgeon_Deagle'
	InstantHitDamage(BASH_FIREMODE)=22

	// Fire Effects
	WeaponFireSnd(DEFAULT_FIREMODE)=(DefaultCue=AkEvent'WW_WEP_SA_DesertEagle.Play_WEP_SA_DesertEagle_Fire_Single_M', FirstPersonCue=AkEvent'WW_WEP_SA_DesertEagle.Play_WEP_SA_DesertEagle_Fire_Single_S')
	WeaponDryFireSnd(DEFAULT_FIREMODE)=AkEvent'WW_WEP_SA_DesertEagle.Play_WEP_SA_DesertEagle_Handling_DryFire'

	// Attachments
	bHasIronSights=true
	bHasFlashlight=false

	// Inventory
	InventorySize=2
	GroupPriority=25
	bCanThrow=true
	bDropOnDeath=true
	WeaponSelectTexture=Texture2D'WEP_UI_Deagle_TEX.UI_WeaponSelect_Deagle'
	bIsBackupWeapon=false
	AssociatedPerkClasses(0)=class'KFPerk_Gunslinger'

	DualClass=class'KFWeap_Pistol_DualDeagle'

	// Custom animations
	FireSightedAnims=(Shoot_Iron, Shoot_Iron2, Shoot_Iron3)
	IdleFidgetAnims=(Guncheck_v1, Guncheck_v2, Guncheck_v3, Guncheck_v4)

	bHasFireLastAnims=true

	BonesToLockOnEmpty=(RW_Slide, RW_Bullets1)

	WeaponFireWaveForm=ForceFeedbackWaveform'FX_ForceFeedback_ARCH.Gunfire.Medium_Recoil'

	// Weapon Upgrade stat boosts
	//WeaponUpgrades[1]=(IncrementDamage=1.25f,IncrementWeight=1)
	//WeaponUpgrades[2]=(IncrementDamage=1.4f,IncrementWeight=2)

	WeaponUpgrades[1]=(Stats=((Stat=EWUS_Damage0, Scale=1.25f), (Stat=EWUS_Weight, Add=1)))
	WeaponUpgrades[2]=(Stats=((Stat=EWUS_Damage0, Scale=1.4f), (Stat=EWUS_Weight, Add=2)))
}