//=============================================================================
// KFWeap_AssaultRifle_Medic
//=============================================================================
// A Medic Assault Rifle
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
// John "Ramm-Jaeger" Gibson
//=============================================================================

class KFWeap_AssaultRifle_Medic extends KFWeap_MedicBase;

/*********************************************************************************************
 * @name	Trader
 *********************************************************************************************/

/** Returns trader filter index based on weapon type */
static simulated event EFilterTypeUI GetTraderFilter()
{
	return FT_Assault;
}

defaultproperties
{
	// Healing charge
    HealAmount=15
	HealFullRechargeSeconds=10

	// Inventory
	InventorySize=7
	GroupPriority=100
	WeaponSelectTexture=Texture2D'ui_weaponselect_tex.UI_WeaponSelect_MedicAssault'
	SecondaryAmmoTexture=Texture2D'UI_SecondaryAmmo_TEX.MedicDarts'

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
	PackageKey="Medic_Assault"
	FirstPersonMeshName="WEP_1P_Medic_Assault_MESH.Wep_1stP_Medic_Assault_Rig"
	FirstPersonAnimSetNames(0)="WEP_1P_Medic_Assault_ANIM.Wep_1stP_Medic_Assault_Anim"
	PickupMeshName="WEP_3P_Medic_Assault_MESH.Wep_Medic_Assault_Pickup"
	AttachmentArchetypeName="WEP_Medic_Assault_ARCH.Wep_Medic_Assault_3P"
	MuzzleFlashTemplateName="WEP_Medic_Assault_ARCH.Wep_Medic_Assault_MuzzleFlash"

	HealingDartDamageType=class'KFDT_Dart_Healing'
	DartFireSnd=(DefaultCue=AkEvent'WW_WEP_SA_MedicDart.Play_WEP_SA_Medic_Dart_Fire_3P', FirstPersonCue=AkEvent'WW_WEP_SA_MedicDart.Play_WEP_SA_Medic_Dart_Fire_1P')
	LockAcquiredSoundFirstPerson=AkEvent'WW_WEP_SA_MedicDart.Play_WEP_SA_Medic_Alert_Locked_1P'
	LockLostSoundFirstPerson=AkEvent'WW_WEP_SA_MedicDart.Play_WEP_SA_Medic_Alert_Lost_1P'
	LockTargetingSoundFirstPerson=AkEvent'WW_WEP_SA_MedicDart.Play_WEP_SA_Medic_Alert_Locking_1P'
    HealImpactSoundPlayEvent=AkEvent'WW_WEP_SA_MedicDart.Play_WEP_SA_Medic_Dart_Heal'
    HurtImpactSoundPlayEvent=AkEvent'WW_WEP_SA_MedicDart.Play_WEP_SA_Medic_Dart_Hurt'
	OpticsUIClass=class'KFGFxWorld_MedicOptics'
	HealingDartWaveForm=ForceFeedbackWaveform'FX_ForceFeedback_ARCH.Gunfire.Default_Recoil'

   	// Zooming/Position
	PlayerViewOffset=(X=15.0,Y=6.5,Z=-3)
	IronSightPosition=(X=12,Y=0,Z=0)

	// Ammo
	MagazineCapacity[0]=40 //30
	SpareAmmoCapacity[0]=400 //390
	InitialSpareMags[0]=2  //3
	bCanBeReloaded=true
	bReloadFromMagazine=true

	// Recoil
	maxRecoilPitch=140  //200
	minRecoilPitch=105  //150
	maxRecoilYaw=122    //175
	minRecoilYaw=-122   //-125
	RecoilRate=0.075
	RecoilMaxYawLimit=500
	RecoilMinYawLimit=65035
	RecoilMaxPitchLimit=900
	RecoilMinPitchLimit=65035
	RecoilISMaxYawLimit=75
	RecoilISMinYawLimit=65460
	RecoilISMaxPitchLimit=375
	RecoilISMinPitchLimit=65460
	IronSightMeshFOVCompensationScale=1.5
	HippedRecoilModifier=1.5

	// DEFAULT_FIREMODE
	FireModeIconPaths(DEFAULT_FIREMODE)=Texture2D'ui_firemodes_tex.UI_FireModeSelect_BulletAuto'
	FiringStatesArray(DEFAULT_FIREMODE)=WeaponFiring
	WeaponFireTypes(DEFAULT_FIREMODE)=EWFT_InstantHit
	WeaponProjectiles(DEFAULT_FIREMODE)=class'KFProj_Bullet_AssaultRifle'
	InstantHitDamageTypes(DEFAULT_FIREMODE)=class'KFDT_Ballistic_Assault_Medic'
	FireInterval(DEFAULT_FIREMODE)=+0.08 // //750  0.08    650 RPM 0.0923
	Spread(DEFAULT_FIREMODE)=0.0085
	InstantHitDamage(DEFAULT_FIREMODE)=35.0
	FireOffset=(X=30,Y=4.5,Z=-5)

	// ALTFIRE_FIREMODE
	AmmoCost(ALTFIRE_FIREMODE)=30
	WeaponProjectiles(ALTFIRE_FIREMODE)=class'KFProj_HealingDart_MedicBase'
	InstantHitDamageTypes(ALTFIRE_FIREMODE)=class'KFDT_Dart_Toxic'

	// BASH_FIREMODE
	InstantHitDamage(BASH_FIREMODE)=27
	InstantHitDamageTypes(BASH_FIREMODE)=class'KFDT_Bludgeon_Assault_Medic'

	// Fire Effects
	WeaponFireSnd(DEFAULT_FIREMODE)=(DefaultCue=AkEvent'WW_WEP_SA_MedicAssault.Play_SA_MedicAssault_Fire_3P_Loop', FirstPersonCue=AkEvent'WW_WEP_SA_MedicAssault.Play_SA_MedicAssault_Fire_1P_Loop')
	WeaponFireSnd(ALTFIRE_FIREMODE)=(DefaultCue=AkEvent'WW_WEP_SA_MedicAssault.Play_SA_MedicAssault_Fire_3P_Single', FirstPersonCue=AkEvent'WW_WEP_SA_MedicAssault.Play_SA_MedicAssault_Fire_1P_Single')
	WeaponFireLoopEndSnd(DEFAULT_FIREMODE)=(DefaultCue=AkEvent'WW_WEP_SA_MedicAssault.Play_SA_MedicAssault_Fire_3P_EndLoop', FirstPersonCue=AkEvent'WW_WEP_SA_MedicAssault.Play_SA_MedicAssault_Fire_1P_EndLoop')

	WeaponDryFireSnd(DEFAULT_FIREMODE)=AkEvent'WW_WEP_SA_MedicAssault.Play_SA_MedicAssault_Handling_DryFire'
	WeaponDryFireSnd(ALTFIRE_FIREMODE)=AkEvent'WW_WEP_SA_MedicDart.Play_WEP_SA_Medic_Dart_DryFire'

	// Advanced (High RPM) Fire Effects
	bLoopingFireAnim(DEFAULT_FIREMODE)=true
	bLoopingFireSnd(DEFAULT_FIREMODE)=true
	SingleFireSoundIndex=ALTFIRE_FIREMODE

	// Attachments
	bHasIronSights=true
	bHasFlashlight=true

   	AssociatedPerkClasses(0)=class'KFPerk_FieldMedic'
   	AssociatedPerkClasses(1)=class'KFPerk_Commando'

   	// Weapon Upgrade stat boosts
	//WeaponUpgrades[1]=(IncrementDamage=1.15f, IncrementWeight=1, IncrementHealFullRecharge=.9)

	WeaponUpgrades[1]=(Stats=((Stat=EWUS_Damage0, Scale=1.15f), (Stat=EWUS_Weight, Add=1), (Stat=EWUS_HealFullRecharge, Scale=0.9f)))
}
