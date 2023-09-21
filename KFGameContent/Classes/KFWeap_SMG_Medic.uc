//=============================================================================
// KFWeap_SMG_Medic
//=============================================================================
// Class Description
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//  - Greg Felber 7/31/2014
//=============================================================================

class KFWeap_SMG_Medic extends KFWeap_MedicBase;

/*********************************************************************************************
 * @name	Trader
 *********************************************************************************************/

/** Returns trader filter index based on weapon type */
static simulated event EFilterTypeUI GetTraderFilter()
{
	return FT_SMG;
}

defaultproperties
{
	// Healing charge
    HealAmount=15
	HealFullRechargeSeconds=13 //15

	// Inventory
	InventorySize=3
	GroupPriority=50
	WeaponSelectTexture=Texture2D'ui_weaponselect_tex.UI_WeaponSelect_MedicSMG'
	SecondaryAmmoTexture=Texture2D'UI_SecondaryAmmo_TEX.MedicDarts'

    // FOV
    MeshFOV=81
	MeshIronSightFOV=64
    PlayerIronSightFOV=70

	// Zooming/Position
	IronSightPosition=(X=8,Y=0.01,Z=-0.04)
	PlayerViewOffset=(X=22,Y=10,Z=-4.5)

	// Content
	PackageKey="Medic_SMG"
	FirstPersonMeshName="WEP_1P_Medic_SMG_MESH.Wep_1stP_Medic_SMG_Rig"
	FirstPersonAnimSetNames(0)="WEP_1P_Medic_SMG_ANIM.Wep_1stP_Medic_SMG_Anim"
	PickupMeshName="wep_3p_medic_smg_mesh.Wep_Medic_SMG_Pickup"
	AttachmentArchetypeName="WEP_Medic_SMG_ARCH.Wep_Medic_SMG_3P"
	MuzzleFlashTemplateName="WEP_Medic_SMG_ARCH.Wep_Medic_SMG_MuzzleFlash"

	HealingDartDamageType=class'KFDT_Dart_Healing'
	DartFireSnd=(DefaultCue=AkEvent'WW_WEP_SA_MedicDart.Play_WEP_SA_Medic_Dart_Fire_3P', FirstPersonCue=AkEvent'WW_WEP_SA_MedicDart.Play_WEP_SA_Medic_Dart_Fire_1P')
	LockAcquiredSoundFirstPerson=AkEvent'WW_WEP_SA_MedicDart.Play_WEP_SA_Medic_Alert_Locked_1P'
	LockLostSoundFirstPerson=AkEvent'WW_WEP_SA_MedicDart.Play_WEP_SA_Medic_Alert_Lost_1P'
	LockTargetingSoundFirstPerson=AkEvent'WW_WEP_SA_MedicDart.Play_WEP_SA_Medic_Alert_Locking_1P'
    HealImpactSoundPlayEvent=AkEvent'WW_WEP_SA_MedicDart.Play_WEP_SA_Medic_Dart_Heal'
    HurtImpactSoundPlayEvent=AkEvent'WW_WEP_SA_MedicDart.Play_WEP_SA_Medic_Dart_Hurt'
	OpticsUIClass=class'KFGFxWorld_MedicOptics'
	HealingDartWaveForm=ForceFeedbackWaveform'FX_ForceFeedback_ARCH.Gunfire.Default_Recoil'

	// Ammo
	MagazineCapacity[0]=40
	SpareAmmoCapacity[0]=480
	InitialSpareMags[0]=5
	bCanBeReloaded=true
	bReloadFromMagazine=true

	// Recoil
	maxRecoilPitch=75
	minRecoilPitch=50
	maxRecoilYaw=50
	minRecoilYaw=-50
	RecoilRate=0.06
	RecoilMaxYawLimit=500
	RecoilMinYawLimit=65035
	RecoilMaxPitchLimit=900
	RecoilMinPitchLimit=65035
	RecoilISMaxYawLimit=75
	RecoilISMinYawLimit=65460
	RecoilISMaxPitchLimit=375
	RecoilISMinPitchLimit=65460
	IronSightMeshFOVCompensationScale=1.5

	// DEFAULT_FIREMODE
	FireModeIconPaths(DEFAULT_FIREMODE)=Texture2D'ui_firemodes_tex.UI_FireModeSelect_BulletAuto'
	FiringStatesArray(DEFAULT_FIREMODE)=WeaponFiring
	WeaponFireTypes(DEFAULT_FIREMODE)=EWFT_InstantHit
	WeaponProjectiles(DEFAULT_FIREMODE)=class'KFProj_Bullet_AssaultRifle'
	InstantHitDamageTypes(DEFAULT_FIREMODE)=class'KFDT_Ballistic_SMG_Medic'
	FireInterval(DEFAULT_FIREMODE)=+.075 // 800 RPM
	Spread(DEFAULT_FIREMODE)=0.007
	InstantHitDamage(DEFAULT_FIREMODE)=20.0  //15.0
	FireOffset=(X=30,Y=4.5,Z=-5)

	// ALTFIRE_FIREMODE
	AmmoCost(ALTFIRE_FIREMODE)=40
	WeaponProjectiles(ALTFIRE_FIREMODE)=class'KFProj_HealingDart_MedicBase'
	InstantHitDamageTypes(ALTFIRE_FIREMODE)=class'KFDT_Dart_Toxic'
	InstantHitDamage(ALTFIRE_FIREMODE)=5

	// BASH_FIREMODE
	InstantHitDamage(BASH_FIREMODE)=23.0
	InstantHitDamageTypes(BASH_FIREMODE)=class'KFDT_Bludgeon_SMG_Medic'

	// Fire Effects
	WeaponFireSnd(DEFAULT_FIREMODE)=(DefaultCue=AkEvent'WW_WEP_SA_MedicSMG.Play_SA_MedicSMG_Fire_3P_Loop', FirstPersonCue=AkEvent'WW_WEP_SA_MedicSMG.Play_SA_MedicSMG_Fire_1P_Loop')
	WeaponFireSnd(ALTFIRE_FIREMODE)=(DefaultCue=AkEvent'WW_WEP_SA_MedicSMG.Play_SA_MedicSMG_Fire_3P_Single', FirstPersonCue=AkEvent'WW_WEP_SA_MedicSMG.Play_SA_MedicSMG_Fire_1P_Single')
	WeaponDryFireSnd(DEFAULT_FIREMODE)=AkEvent'WW_WEP_SA_MedicSMG.Play_SA_MedicSMG_Handling_DryFire'
	WeaponDryFireSnd(ALTFIRE_FIREMODE)=AkEvent'WW_WEP_SA_MedicDart.Play_WEP_SA_Medic_Dart_DryFire'

	// Advanced (High RPM) Fire Effects
	bLoopingFireAnim(DEFAULT_FIREMODE)=true
	bLoopingFireSnd(DEFAULT_FIREMODE)=true
	WeaponFireLoopEndSnd(DEFAULT_FIREMODE)=(DefaultCue=AkEvent'WW_WEP_SA_MedicSMG.Play_SA_MedicSMG_Fire_3P_EndLoop', FirstPersonCue=AkEvent'WW_WEP_SA_MedicSMG.Play_SA_MedicSMG_Fire_1P_EndLoop')
	SingleFireSoundIndex=ALTFIRE_FIREMODE

	// Attachments
	bHasIronSights=true
	bHasFlashlight=true

	AssociatedPerkClasses(0)=class'KFPerk_FieldMedic'
	AssociatedPerkClasses(1)=class'KFPerk_SWAT'

	// Weapon Upgrade stat boosts
	//WeaponUpgrades[1]=(IncrementDamage=1.4f,IncrementWeight=1, IncrementHealFullRecharge=.8)
	//WeaponUpgrades[2]=(IncrementDamage=1.59f,IncrementWeight=2, IncrementHealFullRecharge=.7)
	//WeaponUpgrades[3]=(IncrementDamage=1.85f,IncrementWeight=3, IncrementHealFullRecharge=.6)

	WeaponUpgrades[1]=(Stats=((Stat=EWUS_Damage0, Scale=1.2f), (Stat=EWUS_Weight, Add=1), (Stat=EWUS_HealFullRecharge, Scale=0.85f)))
	WeaponUpgrades[2]=(Stats=((Stat=EWUS_Damage0, Scale=1.4f), (Stat=EWUS_Weight, Add=2), (Stat=EWUS_HealFullRecharge, Scale=0.77f)))
	WeaponUpgrades[3]=(Stats=((Stat=EWUS_Damage0, Scale=1.6f), (Stat=EWUS_Weight, Add=3), (Stat=EWUS_HealFullRecharge, Scale=0.6f)))
}
