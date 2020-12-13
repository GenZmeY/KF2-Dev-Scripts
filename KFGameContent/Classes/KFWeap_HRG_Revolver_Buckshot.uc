//=============================================================================
// KFWeap_HRG_Revolver_Buckshot
//=============================================================================
// A Smith & Wesson .500 "Bone Collector"
//=============================================================================
// Killing Floor 2
// Copyright (C) 2019 Tripwire Interactive LLC
//=============================================================================

class KFWeap_HRG_Revolver_Buckshot extends KFWeap_Revolver_SW500;

/*********************************************************************************************
 Firing / Projectile - Below projectile spawning code copied from KFWeap_ShotgunBase
********************************************************************************************* */

/** Spawn projectile is called once for each shot pellet fired */
simulated function KFProjectile SpawnAllProjectiles(class<KFProjectile> KFProjClass, vector RealStartLoc, vector AimDir)
{
	local KFPerk InstigatorPerk;

	if (CurrentFireMode == GRENADE_FIREMODE)
	{
		return Super.SpawnProjectile(KFProjClass, RealStartLoc, AimDir);
	}

	InstigatorPerk = GetPerk();
	if (InstigatorPerk != none)
	{
		Spread[CurrentFireMode] = default.Spread[CurrentFireMode] * InstigatorPerk.GetTightChokeModifier();
	}

	return super.SpawnAllProjectiles(KFProjClass, RealStartLoc, AimDir);
}

defaultproperties
{
	// Inventory
	InventorySize=2
	GroupPriority=75

	// Recoil
	maxRecoilPitch=525 //750
	minRecoilPitch=472 //675
	maxRecoilYaw=300
	minRecoilYaw=-300
	RecoilRate=0.1
	RecoilMaxYawLimit=500
	RecoilMinYawLimit=65035
	RecoilMaxPitchLimit=900
	RecoilMinPitchLimit=65035
	RecoilISMaxYawLimit=50
	RecoilISMinYawLimit=65485
	RecoilISMaxPitchLimit=500
	RecoilISMinPitchLimit=65485
	IronSightMeshFOVCompensationScale=1.4

	// DEFAULT_FIREMODE
	FireModeIconPaths(DEFAULT_FIREMODE)="ui_firemodes_tex.UI_FireModeSelect_ShotgunSingle"
	FiringStatesArray(DEFAULT_FIREMODE)=WeaponSingleFiring
	WeaponFireTypes(DEFAULT_FIREMODE)=EWFT_Projectile
	WeaponProjectiles(DEFAULT_FIREMODE)=class'KFProj_Bullet_Pellet'
	InstantHitDamage(DEFAULT_FIREMODE)=32.0
	InstantHitDamageTypes(DEFAULT_FIREMODE)=class'KFDT_Ballistic_HRGBuckshot'
	PenetrationPower(DEFAULT_FIREMODE)=2.0
	NumPellets(DEFAULT_FIREMODE) = 5
	Spread(DEFAULT_FIREMODE)=0.12 //0.15

	// ALTFIRE_FIREMODE
	InstantHitDamageTypes(ALTFIRE_FIREMODE) = class'KFDT_Ballistic_HRGBuckshot'

	// BASH_FIREMODE
	InstantHitDamageTypes(BASH_FIREMODE)=class'KFDT_Bludgeon_HRGBuckshot'

	AssociatedPerkClasses.Empty()
	AssociatedPerkClasses(0)=class'KFPerk_Support'

	// Recoil
	RecoilBlendOutRatio=0.35

	//Ammunition
	SpareAmmoCapacity[0]=85
	InitialSpareMags[0]=5

	WeaponSelectTexture=Texture2D'WEP_UI_HRG_SW_500_TEX.UI_WeaponSelect_HRG_SW500'

	//Weqapon Upgrades
	WeaponUpgrades[1]=(Stats=((Stat=EWUS_Damage0, Scale=1.15f), (Stat=EWUS_Weight, Add=1)))
	WeaponUpgrades[2]=(Stats=((Stat=EWUS_Damage0, Scale=1.3f), (Stat=EWUS_Weight, Add=2)))

	FireAnim=HRG_Shoot
	FireSightedAnims[0]=HRG_Shoot_Iron
	FireSightedAnims[1]=HRG_Shoot_Iron2
	FireSightedAnims[2]=HRG_Shoot_Iron3
	FireLastAnim=HRG_Shoot_Last
	FireLastSightedAnim=HRG_Shoot_Iron_Last

	DualClass=class'KFWeap_HRG_Revolver_DualBuckshot'

		// Content
	PackageKey="HRG_SW_500"
	FirstPersonMeshName="WEP_1P_HRG_SW_500_MESH.Wep_1stP_HRG_SW_500_Rig"
	FirstPersonAnimSetNames(0)="WEP_1P_HRG_SW_500_ANIM.WEP_1stP_HRG_SW_500_Anim"
	PickupMeshName="WEP_3P_HRG_SW_500_MESH.Wep_3rdP_HRG_SW_500_Pickup"
	AttachmentArchetypeName="WEP_HRG_SW_500_ARCH.Wep_HRG_SW_500_3P"
	MuzzleFlashTemplateName="WEP_HRG_SW_500_ARCH.Wep_HRG_SW_500_MuzzleFlash"

	//Weapon Sounds
	WeaponFireSnd(DEFAULT_FIREMODE)=(DefaultCue=AkEvent'WW_WEP_SA_SW500.Play_WEP_HRG_Buckshot_Fire_3P', FirstPersonCue=AkEvent'WW_WEP_SA_SW500.Play_WEP_HRG_Buckshot_Fire_1P')
    WeaponDryFireSnd(DEFAULT_FIREMODE)=AkEvent'WW_WEP_SA_SW500.Play_WEP_HRG_Buckshot_Fire_DryFire'

	// Revolver shell/cap replacement
	UnusedBulletMeshTemplate=SkeletalMesh'wep_3p_hrg_sw_500_mesh.Wep_3rdP_HRG_SW_500_Bullet'
	UsedBulletMeshTemplate=SkeletalMesh'wep_3p_hrg_sw_500_mesh.Wep_3rdP_HRG_SW_500_EmptyShell'
	BulletFXSocketNames=(RW_Bullet_FX_5, RW_Bullet_FX_4, RW_Bullet_FX_3, RW_Bullet_FX_2, RW_Bullet_FX_1)

}