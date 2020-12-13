//=============================================================================
// KFWeap_Rifle_CenterfireMB464
//=============================================================================
// The MB464 centerfire lever-action rifle
//=============================================================================
// Killing Floor 2
// Copyright (C) 2016 Tripwire Interactive LLC
//=============================================================================
class KFWeap_Rifle_CenterfireMB464 extends KFWeap_RifleBase;

defaultproperties
{
	// Inventory / Grouping
	InventorySize=5
	GroupPriority=50
	WeaponSelectTexture=Texture2D'WEP_UI_Centerfire_TEX.UI_WeaponSelect_Centerfire'
   	AssociatedPerkClasses(0)=class'KFPerk_Sharpshooter'
   	AssociatedPerkClasses(1)=class'KFPerk_Gunslinger'

    // FOV
    MeshFOV=75
	MeshIronSightFOV=40
    PlayerIronSightFOV=65

	// Depth of field
	DOF_FG_FocalRadius=50
	DOF_FG_MaxNearBlurSize=3.5

	// Content
	PackageKey="Centerfire"
	FirstPersonMeshName="WEP_1P_Centerfire_MESH.Wep_1stP_Centerfire_Rig"
	FirstPersonAnimSetNames(0)="WEP_1P_Centerfire_ANIM.Wep_1stP_Centerfire_Anim"
	PickupMeshName="WEP_3P_Centerfire_MESH.Wep_3rdP_Centerfire_Pickup"
	AttachmentArchetypeName="WEP_Centerfire_ARCH.Wep_Centerfire_3P"
	MuzzleFlashTemplateName="WEP_Centerfire_ARCH.Wep_Centerfire_MuzzleFlash"

	// Ammo
	MagazineCapacity[0]=10
	SpareAmmoCapacity[0]=70
	InitialSpareMags[0]=2
	bCanBeReloaded=true
	bReloadFromMagazine=false

	// Zooming/Position
	PlayerViewOffset=(X=11.0,Y=8,Z=-2) //x7
	IronSightPosition=(X=10,Y=0,Z=0) //x0

	// AI warning system
	bWarnAIWhenAiming=true
	AimWarningDelay=(X=0.4f, Y=0.8f)
	AimWarningCooldown=0.0f

	// Recoil
	maxRecoilPitch=500
	minRecoilPitch=400
	maxRecoilYaw=150
	minRecoilYaw=-150
	RecoilRate=0.08
	RecoilMaxYawLimit=500
	RecoilMinYawLimit=65035
	RecoilMaxPitchLimit=1250
	RecoilMinPitchLimit=64785
	RecoilISMaxYawLimit=50
	RecoilISMinYawLimit=65485
	RecoilISMaxPitchLimit=500
	RecoilISMinPitchLimit=65485
	RecoilViewRotationScale=0.6
	IronSightMeshFOVCompensationScale=1.5

	// DEFAULT_FIREMODE
	FireModeIconPaths(DEFAULT_FIREMODE)=Texture2D'ui_firemodes_tex.UI_FireModeSelect_BulletSingle'
	FiringStatesArray(DEFAULT_FIREMODE)=WeaponSingleFiring
	WeaponFireTypes(DEFAULT_FIREMODE)=EWFT_InstantHit
	WeaponProjectiles(DEFAULT_FIREMODE)=class'KFProj_Bullet_Winchester1894'
	InstantHitDamage(DEFAULT_FIREMODE)=165 //180
	InstantHitDamageTypes(DEFAULT_FIREMODE)=class'KFDT_Ballistic_CenterfireMB464'
	FireInterval(DEFAULT_FIREMODE)=0.4 //0.45
	Spread(DEFAULT_FIREMODE)=0.007
	PenetrationPower(DEFAULT_FIREMODE)=1.5
	FireOffset=(X=25,Y=3.0,Z=-2.5)

	// ALT_FIREMODE
	FiringStatesArray(ALTFIRE_FIREMODE)=WeaponSingleFiring
	WeaponFireTypes(ALTFIRE_FIREMODE)=EWFT_None

	// Custom animations
	FireSightedAnims=(Shoot_Iron, Shoot_Iron2, Shoot_Iron3)
	BonesToLockOnEmpty=(RW_Hammer)
	bHasFireLastAnims=true

	// BASH_FIREMODE
	InstantHitDamageTypes(BASH_FIREMODE)=class'KFDT_Bludgeon_CenterfireMB464'
	InstantHitDamage(BASH_FIREMODE)=25

	// Fire Effects
	WeaponFireSnd(DEFAULT_FIREMODE)=(DefaultCue=AkEvent'WW_WEP_SA_Winchester.Play_WEP_Centerfire_Fire_3P', FirstPersonCue=AkEvent'WW_WEP_SA_Winchester.Play_WEP_Centerfire_Fire_1P')
	WeaponDryFireSnd(DEFAULT_FIREMODE)=AkEvent'WW_WEP_SA_Winchester.Play_WEP_SA_Winchester_Handling_DryFire'
	EjectedShellForegroundDuration=1.5f

	// Attachments
	bHasIronSights=true
	bHasFlashlight=false

	WeaponFireWaveForm=ForceFeedbackWaveform'FX_ForceFeedback_ARCH.Gunfire.Medium_Recoil'

	// Weapon Upgrade stat boosts
	//WeaponUpgrades[1]=(IncrementDamage=1.15f,IncrementWeight=1)
	//WeaponUpgrades[2]=(IncrementDamage=1.3f,IncrementWeight=2)
	//WeaponUpgrades[3]=(IncrementDamage=1.45f,IncrementWeight=3)

	WeaponUpgrades[1]=(Stats=((Stat=EWUS_Damage0, Scale=1.15f), (Stat=EWUS_Weight, Add=1)))
	WeaponUpgrades[2]=(Stats=((Stat=EWUS_Damage0, Scale=1.3f), (Stat=EWUS_Weight, Add=2)))
	WeaponUpgrades[3]=(Stats=((Stat=EWUS_Damage0, Scale=1.45f), (Stat=EWUS_Weight, Add=3)))
}