//=============================================================================
// KFWeap_Pistol_AF2011
//=============================================================================
// An AF2011 pistol
//=============================================================================
// Killing Floor 2
// Copyright (C) 2017 Tripwire Interactive LLC
//=============================================================================

class KFWeap_Pistol_AF2011 extends KFWeap_PistolBase;

var vector BarrelOffset;

simulated function KFProjectile SpawnProjectile(class<KFProjectile> KFProjClass, vector RealStartLoc, vector AimDir)
{
	if (CurrentFireMode == GRENADE_FIREMODE)
	{
		return Super.SpawnProjectile(KFProjClass, RealStartLoc, AimDir);
	}

	Super.SpawnProjectile(KFProjClass, RealStartLoc + BarrelOffset / 2.f, AimDir);
	Super.SpawnProjectile(KFProjClass, RealStartLoc - BarrelOffset / 2.f, AimDir);

	return None;
}

defaultproperties
{
	BarrelOffset=(X=10.0,Y=0,Z=0)
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
	PackageKey="AF2001"
	FirstPersonMeshName="wep_1p_af2001_mesh.Wep_1stP_AF2001_Rig"
	FirstPersonAnimSetNames(0)="wep_1p_af2001_anim.Wep_1stP_AF2001_Anim"
	PickupMeshName="WEP_3P_AF2001_MESH.Wep_3rdP_AF2001_Pickup"
	AttachmentArchetypeName="WEP_AF2001_ARCH.Wep_AF2001_3P"
	MuzzleFlashTemplateName="WEP_AF2001_ARCH.Wep_AF2001_MuzzleFlash"

   	// Zooming/Position
	IronSightPosition=(X=11,Y=0,Z=0)

	// Ammo
	MagazineCapacity[0]=16
	SpareAmmoCapacity[0]=288
	InitialSpareMags[0]=4
	AmmoPickupScale[0]=2.0
	bCanBeReloaded=true
	bReloadFromMagazine=true

	// Recoil
	maxRecoilPitch=650  //650  //550
	minRecoilPitch=550  //550  //550
	maxRecoilYaw=550 //150
	minRecoilYaw=-550 //150
	RecoilRate=0.09 //0.07
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
	WeaponFireTypes(DEFAULT_FIREMODE)= EWFT_Projectile
	WeaponProjectiles(DEFAULT_FIREMODE)=class'KFProj_Bullet_PistolAF2011'
	FireInterval(DEFAULT_FIREMODE)=+0.1898
	InstantHitDamage(DEFAULT_FIREMODE)=53 //91
	InstantHitDamageTypes(DEFAULT_FIREMODE)=class'KFDT_Ballistic_AF2011'
	PenetrationPower(DEFAULT_FIREMODE)=1.5
	Spread(DEFAULT_FIREMODE)=0.01
	FireOffset=(X=20,Y=4.0,Z=-3)
    AmmoCost(DEFAULT_FIREMODE)=2

	// ALT_FIREMODE
	FiringStatesArray(ALTFIRE_FIREMODE)=WeaponSingleFiring
	WeaponFireTypes(ALTFIRE_FIREMODE)=EWFT_None

	// BASH_FIREMODE
	InstantHitDamageTypes(BASH_FIREMODE)=class'KFDT_Bludgeon_AF2011'
	InstantHitDamage(BASH_FIREMODE)=22

	// Fire Effects
	WeaponFireSnd(DEFAULT_FIREMODE)=(DefaultCue=AkEvent'WW_WEP_AF2011.Play_WEP_AF2011_Fire_3P', FirstPersonCue=AkEvent'WW_WEP_AF2011.Play_WEP_AF2011_Fire_1P') //@TODO: Replace me
	WeaponDryFireSnd(DEFAULT_FIREMODE)=AkEvent'WW_WEP_SA_DesertEagle.Play_WEP_SA_DesertEagle_Handling_DryFire' //@TODO: Replace me

	// Attachments
	bHasIronSights=true
	bHasFlashlight=false

	// Inventory
	InventorySize=3
	GroupPriority=25
	bCanThrow=true
	bDropOnDeath=true
	WeaponSelectTexture=Texture2D'WEP_UI_AF2001_TEX.UI_WeaponSelect_AF2011'
	bIsBackupWeapon=false
	AssociatedPerkClasses(0)=class'KFPerk_Gunslinger'

	DualClass=class'KFWeap_Pistol_DualAF2011'

	// Custom animations
	FireSightedAnims=(Shoot_Iron, Shoot_Iron2, Shoot_Iron3)
	IdleFidgetAnims=(Guncheck_v1, Guncheck_v2, Guncheck_v3, Guncheck_v4)

	bHasFireLastAnims=true

	BonesToLockOnEmpty=(RW_Bolt, RW_Bullets1)

	WeaponFireWaveForm=ForceFeedbackWaveform'FX_ForceFeedback_ARCH.Gunfire.Medium_Recoil'

	// Weapon Upgrade stat boosts
	//WeaponUpgrades[1]=(IncrementDamage=1.125f,IncrementWeight=1)

	WeaponUpgrades[1]=(Stats=((Stat=EWUS_Damage0, Scale=1.125f), (Stat=EWUS_Weight, Add=1)))
}