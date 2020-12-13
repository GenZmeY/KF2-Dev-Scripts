//=============================================================================
// KFWeap_Pistol_HRGScorcher
//=============================================================================
// A Horzine experimental flare gun (Scorcher)
//=============================================================================
// Killing Floor 2
// Copyright (C) 2020 Tripwire Interactive LLC
// Roberto Moreno (Saber Interactive)
//=============================================================================

class KFWeap_Pistol_HRGScorcher extends KFWeap_GrenadeLauncher_Base;

var protected const array<vector2D> PelletSpread;

/** Last time a submunition projectile was fired from this weapon */
var float LastSubmunitionFireTime;



/** We avoid alternating between firemodes and directly altfire */
simulated function AltFireMode()
{
	if ( !Instigator.IsLocallyControlled() )
	{
		return;
	}

	StartFire(ALTFIRE_FIREMODE);
}

static simulated event EFilterTypeUI GetAltTraderFilter()
{
	return FT_Pistol;
}

defaultproperties
{
	ForceReloadTime=0.3f

	// Shooting Animations
	FireSightedAnims[0]=Shoot_Iron
	FireSightedAnims[1]=Shoot_Iron2
	FireSightedAnims[2]=Shoot_Iron3

	// Inventory
	InventoryGroup=IG_Secondary
	GroupPriority=75
	InventorySize=4
	WeaponSelectTexture=Texture2D'WEP_UI_HRGScorcher_Pistol_TEX.UI_WeaponSelect_HRGScorcher'

    // FOV
	MeshIronSightFOV=52
    PlayerIronSightFOV=73

	// Zooming/Position
	PlayerViewOffset=(X=13.0,Y=13,Z=-4)
	FastZoomOutTime=0.2

	// Content
	PackageKey="HRGScorcher_Pistol"
	FirstPersonMeshName="WEP_1P_HRGScorcher_Pistol_MESH.Wep_1stP_HRGScorcher_Pistol_Rig"
	FirstPersonAnimSetNames(0)="WEP_1P_HRGScorcher_Pistol_ANIM.Wep_1stP_HRGScorcher_Pistol_Anim"
	PickupMeshName="wep_3p_HRGScorcher_Pistol_mesh.WEP_HRGScorcher_Pickup"
	AttachmentArchetypeName="WEP_HRGScorcher_Pistol_ARCH.Wep_HRGScorcher_Pistol_3P"
	MuzzleFlashTemplateName="WEP_HRGScorcher_Pistol_ARCH.Wep_HRGScorcher_Pistol_MuzzleFlash"

   	// Zooming/Position
	IronSightPosition=(X=0,Y=0,Z=0)

	// Ammo
	MagazineCapacity[0]=1
	SpareAmmoCapacity[0]=31 //28
	InitialSpareMags[0]=12
	AmmoPickupScale[0]=4.0 //3.0
	bCanBeReloaded=true
	bReloadFromMagazine=true
	bNoMagazine=true

	// Recoil
	maxRecoilPitch=900
	minRecoilPitch=775
	maxRecoilYaw=500
	minRecoilYaw=-500
	RecoilRate=0.04
	RecoilBlendOutRatio=0.35
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
	HippedRecoilModifier=1.25

	// DEFAULT_FIREMODE
	FireModeIconPaths(DEFAULT_FIREMODE)=Texture2D'ui_firemodes_tex.UI_FireModeSelect_BulletSingle'
	FiringStatesArray(DEFAULT_FIREMODE)=WeaponSingleFireAndReload
	WeaponFireTypes(DEFAULT_FIREMODE)=EWFT_Projectile
	WeaponProjectiles(DEFAULT_FIREMODE)=class'KFProj_LightingFlare_HRGScorcher'
	InstantHitDamage(DEFAULT_FIREMODE)=333	//370 //185 //210 //250.0
	InstantHitDamageTypes(DEFAULT_FIREMODE)=class'KFDT_Ballistic_HRGScorcherLightingImpact'
	PenetrationPower(DEFAULT_FIREMODE)=0
	Spread(DEFAULT_FIREMODE)=0.01f//0.05f//0.1f
	FireInterval(DEFAULT_FIREMODE)=0.25
	FireOffset=(X=23,Y=4.0,Z=-3)

	// ALT_FIREMODE
	FireModeIconPaths(ALTFIRE_FIREMODE)=Texture2D'ui_firemodes_tex.UI_FireModeSelect_BulletSingle'
	FiringStatesArray(ALTFIRE_FIREMODE)=WeaponSingleFireAndReload
	WeaponFireTypes(ALTFIRE_FIREMODE)=EWFT_Projectile
	WeaponProjectiles(ALTFIRE_FIREMODE)=class'KFProj_BrokenFlare_HRGScorcher'
	FireInterval(ALTFIRE_FIREMODE)=0.25
	InstantHitDamage(ALTFIRE_FIREMODE)=70 //80.0//50.0
	InstantHitDamageTypes(ALTFIRE_FIREMODE)=class'KFDT_Ballistic_HRGScorcherBrokenImpact'
	PenetrationPower(ALTFIRE_FIREMODE)=0
	Spread(ALTFIRE_FIREMODE)=0.1f

	// BASH_FIREMODE
	InstantHitDamageTypes(BASH_FIREMODE)=class'KFDT_Bludgeon_HRGScorcher'
	InstantHitDamage(BASH_FIREMODE)=26

	// Fire Effects
	WeaponFireSnd(DEFAULT_FIREMODE)=(DefaultCue=AkEvent'WW_WEP_HRG_Scorcher.Play_WEP_HRG_Scorcher_Fire_3P', FirstPersonCue=AkEvent'WW_WEP_HRG_Scorcher.Play_WEP_HRG_Scorcher_Fire_1P')

	WeaponFireSnd(ALTFIRE_FIREMODE)=(DefaultCue=AkEvent'WW_WEP_HRG_Scorcher.Play_WEP_HRG_Scorcher_AltFire_3P', FirstPersonCue=AkEvent'WW_WEP_HRG_Scorcher.Play_WEP_HRG_Scorcher_AltFire_1P')

	//@todo: add akevent when we have it
	WeaponDryFireSnd(DEFAULT_FIREMODE)=none

	// Animation
	bHasFireLastAnims=true

	// Attachments
	bHasIronSights=true
	bHasFlashlight=false

   	AssociatedPerkClasses(0)=class'KFPerk_Firebug'

	WeaponFireWaveForm=ForceFeedbackWaveform'FX_ForceFeedback_ARCH.Gunfire.Medium_Recoil'

	WeaponUpgrades[1]=(Stats=((Stat=EWUS_Damage0, Scale=1.2f), (Stat=EWUS_Weight, Add=1)))
	WeaponUpgrades[2]=(Stats=((Stat=EWUS_Damage0, Scale=1.4f), (Stat=EWUS_Weight, Add=2)))

}