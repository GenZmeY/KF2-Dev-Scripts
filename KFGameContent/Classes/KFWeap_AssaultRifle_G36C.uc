//=============================================================================
// KFWeap_AssaultRifle_G36C
//=============================================================================
// Class Description
//=============================================================================
// Killing Floor 2
// Copyright (C) 2022 Tripwire Interactive LLC
//=============================================================================

class KFWeap_AssaultRifle_G36C extends KFWeap_SMGBase;

simulated function ZoomIn(bool bAnimateTransition, float ZoomTimeToGo)
{
    super.ZoomIn(bAnimateTransition, ZoomTimeToGo);

    if (LaserSight != none)
    {
		LaserSight.ChangeVisibility(false);
    }
}

simulated function ZoomOut( bool bAnimateTransition, float ZoomTimeToGo )
{
	super.ZoomOut( bAnimateTransition, ZoomTimeToGo );

    if (LaserSight != none)
    {
		LaserSight.ChangeVisibility(true);
	}
}

simulated function AttachLaserSight()
{
	if( WorldInfo.NetMode == NM_DedicatedServer )
	{
        return;
	}

	super.AttachLaserSight();

	if (LaserSight != none)
	{
		LaserSight.bForceDotToMatch = true;
	}
}

static simulated event EFilterTypeUI GetTraderFilter()
{
	return FT_Assault;
}

defaultproperties
{
	bHasFireLastAnims=true
	BonesToLockOnEmpty=(RW_Bolt, RW_Charging_Handle)

	// Shooting Animations
	FireSightedAnims[0]=Shoot_Iron
	FireSightedAnims[1]=Shoot_Iron2
	FireSightedAnims[2]=Shoot_Iron3

    // FOV
	MeshFOV=70
	MeshIronSightFOV=20
    PlayerIronSightFOV=70

	// Depth of field
	DOF_FG_FocalRadius=150
	DOF_FG_MaxNearBlurSize=3

	// Zooming/Position
	IronSightPosition=(X=40,Y=0.1,Z=-4.57)
	PlayerViewOffset=(X=14,Y=11,Z=-5)

	// Content
	PackageKey="G36C"
	FirstPersonMeshName="WEP_1P_G36C_MESH.Wep_1stP_G36C_Rig"
	FirstPersonAnimSetNames(0)="WEP_1P_G36C_ANIM.Wep_1stP_G36C_Anim"
	PickupMeshName="WEP_3P_G36C_MESH.Wep_G36C_Pickup"
	AttachmentArchetypeName="WEP_G36C_ARCH.Wep_G36C_3P"
	MuzzleFlashTemplateName="WEP_G36C_ARCH.Wep_G36C_MuzzleFlash"

	LaserSightTemplate=KFLaserSightAttachment'FX_LaserSight_ARCH.LaserSight_WithAttachment_1P'

	// Ammo
	MagazineCapacity[0]=30
	SpareAmmoCapacity[0]=450
	InitialSpareMags[0]=3
	bCanBeReloaded=true
	bReloadFromMagazine=true

	// Recoil
	maxRecoilPitch=50
	minRecoilPitch=40
	maxRecoilYaw=70
	minRecoilYaw=-70
	RecoilRate=0.085
	RecoilMaxYawLimit=500
	RecoilMinYawLimit=65035
	RecoilMaxPitchLimit=900
	RecoilMinPitchLimit=65035
	RecoilISMaxYawLimit=100
	RecoilISMinYawLimit=65460
	RecoilISMaxPitchLimit=350
	RecoilISMinPitchLimit=65460
	IronSightMeshFOVCompensationScale=6.0

	// Old Recoil Data
	// maxRecoilPitch=80
	// minRecoilPitch=65
	// maxRecoilYaw=60
	// minRecoilYaw=-60
	// RecoilRate=0.063
	// RecoilMaxYawLimit=400
	// RecoilMinYawLimit=65135
	// RecoilMaxPitchLimit=800
	// RecoilMinPitchLimit=65035
	// RecoilISMaxYawLimit=150
	// RecoilISMinYawLimit=65385
	// RecoilISMaxPitchLimit=350
	// RecoilISMinPitchLimit=65435
	// IronSightMeshFOVCompensationScale=1.5

	// Inventory
	InventorySize=7
	GroupPriority=100
	WeaponSelectTexture=Texture2D'wep_ui_g36c_tex.UI_WeaponSelect_G36C' 

	// DEFAULT_FIREMODE
	FireModeIconPaths(DEFAULT_FIREMODE)=Texture2D'ui_firemodes_tex.UI_FireModeSelect_BulletAuto'
	FiringStatesArray(DEFAULT_FIREMODE)=WeaponFiring
	WeaponFireTypes(DEFAULT_FIREMODE)=EWFT_InstantHit
	WeaponProjectiles(DEFAULT_FIREMODE)=class'KFProj_Bullet_AssaultRifle'
	InstantHitDamageTypes(DEFAULT_FIREMODE)=class'KFDT_Ballistic_G36C'
	PenetrationPower(DEFAULT_FIREMODE)=4.0
	FireInterval(DEFAULT_FIREMODE)=+0.08 // 750 RPM
	Spread(DEFAULT_FIREMODE)=0.005
	InstantHitDamage(DEFAULT_FIREMODE)=45.0
	FireOffset=(X=30,Y=4.5,Z=-5)

	// ALT_FIREMODE
	FireModeIconPaths(ALTFIRE_FIREMODE)=Texture2D'ui_firemodes_tex.UI_FireModeSelect_BulletSingle'
	FiringStatesArray(ALTFIRE_FIREMODE)=WeaponSingleFiring
	WeaponFireTypes(ALTFIRE_FIREMODE)=EWFT_InstantHit
	WeaponProjectiles(ALTFIRE_FIREMODE)=class'KFProj_Bullet_AssaultRifle'
	InstantHitDamageTypes(ALTFIRE_FIREMODE)=class'KFDT_Ballistic_G36C'
	PenetrationPower(ALTFIRE_FIREMODE)=4.0
	FireInterval(ALTFIRE_FIREMODE)=+0.08 // 750 RPM
	InstantHitDamage(ALTFIRE_FIREMODE)=45.0
	Spread(ALTFIRE_FIREMODE)=0.005

	// BASH_FIREMODE
	InstantHitDamageTypes(BASH_FIREMODE)=class'KFDT_Bludgeon_G36C'
	InstantHitDamage(BASH_FIREMODE)=26

	// Fire Effects
	WeaponFireSnd(DEFAULT_FIREMODE)=(DefaultCue=AkEvent'WW_WEP_G36C.Play_WEP_G36C_3P_Shoot_LP', FirstPersonCue=AkEvent'WW_WEP_G36C.Play_WEP_G36C_1P_Shoot_LP')
	WeaponFireSnd(ALTFIRE_FIREMODE)=(DefaultCue=AkEvent'WW_WEP_G36C.Play_WEP_G36C_3P_Shoot_Single', FirstPersonCue=AkEvent'WW_WEP_G36C.Play_WEP_G36C_1P_Shoot_Single')
	WeaponDryFireSnd(DEFAULT_FIREMODE)=AkEvent'WW_WEP_SA_AK12.Play_WEP_SA_AK12_Handling_DryFire' //@TODO: Replace me
	WeaponDryFireSnd(ALTFIRE_FIREMODE)=AkEvent'WW_WEP_SA_AK12.Play_WEP_SA_AK12_Handling_DryFire' //@TODO: Replace me
//	WeaponDryFireSnd(DEFAULT_FIREMODE)=AkEvent'WW_WEP_G36C.Play_WEP_G36C_Dry_Fire'
//	WeaponDryFireSnd(ALTFIRE_FIREMODE)=AkEvent'WW_WEP_G36C.Play_WEP_G36C_Dry_Fire'

	// Advanced (High RPM) Fire Effects
	bLoopingFireAnim(DEFAULT_FIREMODE)=true
	bLoopingFireSnd(DEFAULT_FIREMODE)=true
	WeaponFireLoopEndSnd(DEFAULT_FIREMODE)=(DefaultCue=AkEvent'WW_WEP_G36C.Play_WEP_G36C_3P_End_LP', FirstPersonCue=AkEvent'WW_WEP_G36C.Play_WEP_G36C_1P_End_LP')
	SingleFireSoundIndex=ALTFIRE_FIREMODE

	// Attachments
	bHasIronSights=true
	bHasFlashlight=false
	bHasLaserSight=true

	AssociatedPerkClasses(0)=class'KFPerk_Swat'

	// Weapon Upgrade stat boosts
	WeaponUpgrades[1]=(Stats=((Stat=EWUS_Damage0, Scale=1.15f), (Stat=EWUS_Damage1, Scale=1.15f), (Stat=EWUS_Weight, Add=1)))
}
