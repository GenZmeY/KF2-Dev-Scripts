//=============================================================================
// KFWeap_Shotgun_HRG_Kaboomstick
//=============================================================================
// A double barrel shotgun that shoots explosives projectiles
//=============================================================================
// Killing Floor 2
// Copyright (C) 2019 Tripwire Interactive LLC
// Tulio Beloqui (Saber Interactive)
//=============================================================================

class KFWeap_Shotgun_HRG_Kaboomstick extends KFWeap_Shotgun_DoubleBarrel;

defaultproperties
{
	// Inventory
	InventorySize=6
	GroupPriority=75
	WeaponSelectTexture=Texture2D'WEP_UI_HRG_Kaboomstick_TEX.UI_WeaponSelect_HRG_Kaboomstick'

    // FOV
    MeshFOV=75
	MeshIronSightFOV=52
    PlayerIronSightFOV=70

	// Depth of field
	DOF_FG_FocalRadius=65
	DOF_FG_MaxNearBlurSize=3

	// Zooming/Position
	PlayerViewOffset=(X=4.0,Y=7.0,Z=-5.0)
	IronSightPosition=(X=7,Y=0.22,Z=-0.6)

	// Content
	PackageKey="HRG_Kaboomstick"
	FirstPersonMeshName="WEP_1P_HRG_Kaboomstick_MESH.Wep_1stP_HRG_Kaboomstick_Rig"
	FirstPersonAnimSetNames(0)="WEP_1P_HRG_Kaboomstick_ANIM.Wep_1stP_HRG_Kaboomstick_Anim"
	PickupMeshName="WEP_3P_HRG_Kaboomstick_MESH.Wep_HRG_Kaboomstick_Pickup"
	AttachmentArchetypeName="WEP_HRG_Kaboomstick_ARCH.Wep_HRG_Kaboomstick_3P"
	MuzzleFlashTemplateName="WEP_HRG_Kaboomstick_ARCH.Wep_HRG_Kaboomstick_MuzzleFlash"

	// Animations
	FireAnim=Shoot_Single
	FireDoubleAnim=Shoot_Double
	FireSightedAnims[0]=Shoot_Iron_Single
	FireSightedAnims[1]=Shoot_Iron_Double
    bHasFireLastAnims=false

	// DEFAULT_FIREMODE
	FireModeIconPaths(DEFAULT_FIREMODE)=Texture2D'ui_firemodes_tex.UI_FireModeSelect_ShotgunSingle'
	FiringStatesArray(DEFAULT_FIREMODE)=WeaponSingleFiring
	WeaponFireTypes(DEFAULT_FIREMODE)=EWFT_Projectile
	WeaponProjectiles(DEFAULT_FIREMODE)=class'KFProj_Explosive_HRG_Kaboomstick'
	InstantHitDamage(DEFAULT_FIREMODE)=15 //10 //25
	InstantHitDamageTypes(DEFAULT_FIREMODE)=class'KFDT_Ballistic_HRG_Kaboomstick'
	PenetrationPower(DEFAULT_FIREMODE)=0
	FireInterval(DEFAULT_FIREMODE)=0.25 // 240 RPM
	FireOffset=(X=25,Y=3.5,Z=-4)
	NumPellets(DEFAULT_FIREMODE)=8 
	Spread(DEFAULT_FIREMODE)=0.45 //0.2
	ForceReloadTimeOnEmpty=0.3

	// ALT_FIREMODE
	FireModeIconPaths(ALTFIRE_FIREMODE)=Texture2D'ui_firemodes_tex.UI_FireModeSelect_ShotgunAuto'
	FiringStatesArray(ALTFIRE_FIREMODE)=WeaponDoubleBarrelFiring
	WeaponFireTypes(ALTFIRE_FIREMODE)=EWFT_Projectile
	WeaponProjectiles(ALTFIRE_FIREMODE)=class'KFProj_Explosive_HRG_Kaboomstick'
	InstantHitDamage(ALTFIRE_FIREMODE)=15 //10 //25
	InstantHitDamageTypes(ALTFIRE_FIREMODE)=class'KFDT_Ballistic_HRG_Kaboomstick'
	PenetrationPower(ALTFIRE_FIREMODE)=0
	FireInterval(ALTFIRE_FIREMODE)=0.25 // 240 RPM
	NumPellets(ALTFIRE_FIREMODE)=16 // 8
	Spread(ALTFIRE_FIREMODE)=0.45 //0.2

	DoubleBarrelKickMomentum=1000
	FallingMomentumReduction=0.5

	// BASH_FIREMODE
	InstantHitDamageTypes(BASH_FIREMODE)=class'KFDT_Bludgeon_HRG_Kaboomstick'
	InstantHitDamage(BASH_FIREMODE)=26

	// Fire Effects
	WeaponFireSnd(DEFAULT_FIREMODE)=(DefaultCue=AkEvent'WW_WEP_SA_Shotgun.Play_SA_WEP_DoubleBarrel_Fire_3P', FirstPersonCue=AkEvent'WW_WEP_SA_Shotgun.Play_SA_WEP_DoubleBarrel_Fire_1P')
    WeaponFireSnd(ALTFIRE_FIREMODE)=(DefaultCue=AkEvent'WW_WEP_SA_Shotgun.Play_SA_WEP_DoubleBarrel_Fire_3P', FirstPersonCue=AkEvent'WW_WEP_SA_Shotgun.Play_SA_WEP_DoubleBarrel_Alt_Fire_1P')

	WeaponDryFireSnd(DEFAULT_FIREMODE)=AkEvent'WW_WEP_SA_Shotgun.Play_SA_WEP_DoubleBarrel_Handling_DryFire'
	WeaponDryFireSnd(ALTFIRE_FIREMODE)=AkEvent'WW_WEP_SA_Shotgun.Play_SA_WEP_DoubleBarrel_Handling_DryFire'

	// Attachments
	bHasIronSights=true
	bHasFlashlight=false

	// Ammo
	MagazineCapacity[0]=2
	SpareAmmoCapacity[0]=46
	InitialSpareMags[0]=9 //13
	AmmoPickupScale[0]=3.0 //4.0
	bCanBeReloaded=true
	bReloadFromMagazine=true
	bNoMagazine=true

	// Recoil
	maxRecoilPitch=900
	minRecoilPitch=775
	maxRecoilYaw=500
	minRecoilYaw=-500
	RecoilRate=0.085
	RecoilBlendOutRatio=1.1
	RecoilMaxYawLimit=500
	RecoilMinYawLimit=65035
	RecoilMaxPitchLimit=1500
	RecoilMinPitchLimit=64785
	RecoilISMaxYawLimit=50
	RecoilISMinYawLimit=65485
	RecoilISMaxPitchLimit=500
	RecoilISMinPitchLimit=65485
	RecoilViewRotationScale=0.8
	FallingRecoilModifier=1.5
	DoubleFireRecoilModifier=2.2
	HippedRecoilModifier=1.25

	AssociatedPerkClasses(0)=class'KFPerk_Demolitionist'

	WeaponFireWaveForm=ForceFeedbackWaveform'FX_ForceFeedback_ARCH.Gunfire.Heavy_Recoil_SingleShot'

	WeaponUpgrades.Empty()
	WeaponUpgrades[0]=(Stats=((Stat=EWUS_Damage0, Scale=1.f, Add=0), (Stat=EWUS_Weight, Scale=1.f, Add=0)))
	WeaponUpgrades[1]=(Stats=((Stat=EWUS_Damage0, Scale=1.15f), (Stat=EWUS_Damage1, Scale=1.15f), (Stat=EWUS_Weight, Add=1)))
	WeaponUpgrades[2]=(Stats=((Stat=EWUS_Damage0, Scale=1.30f), (Stat=EWUS_Damage1, Scale=1.30f), (Stat=EWUS_Weight, Add=2)))
}