//=============================================================================
// KFWeap_ShrinkRayGun
//=============================================================================
// Matheson would like this.
//=============================================================================
// Killing Floor 2
// Copyright (C) 2022 Tripwire Interactive LLC
//=============================================================================

class KFWeap_ShrinkRayGun extends KFWeap_FlameBase;

simulated event PostBeginPlay()
{
	super.PostBeginPlay();
	BarrelHeat = FlameSprayArchetype.default.MaterialHeatRange.X;
	ChangeMaterial();
	LastBarrelHeat = BarrelHeat;
}

static simulated event EFilterTypeUI GetTraderFilter()
{
	return FT_Electric;
}

/** Disable normal bullet spread */
simulated function rotator AddSpread( rotator BaseAim )
{
	return BaseAim; // do nothing
}

simulated protected function TurnOffPilot()
{
	// Undo the invert of the pilot, so it does really deactivate

	bInvertPilot = false;

    Super.TurnOffPilot();

	bInvertPilot = true;
}

defaultproperties
{
    FlameSprayArchetype=SprayActor_Flame'WEP_ShrinkRay_Gun_ARCH.WEP_ShrinkRay_Gun_SprayFire'

	// Shooting Animations
	bHasFireLastAnims=true
	FireSightedAnims[0]=Shoot
	FireSightedAnims[1]=Shoot_Heavy_Iron

    // FOV
	MeshIronSightFOV=52
    PlayerIronSightFOV=77

	// Zooming/Position
	PlayerViewOffset=(X=0.0,Y=14,Z=-1) //(X=-2,Y=12,Z=0)
	IronSightPosition=(X=-5.0,Y=-0.05,Z=1.0) //(X=-0.5,Y=-0.05,Z=1.35) //(X=5.0,Y=9,Z=-3)

	// Depth of field
	DOF_FG_FocalRadius=150
	DOF_FG_MaxNearBlurSize=1

	// Content
	PackageKey="ShrinkRay_Gun"
	FirstPersonMeshName="WEP_1P_ShrinkRay_Gun_MESH.Wep_1stP_ShrinkRay_Gun_Rig"
	FirstPersonAnimSetNames(0)="WEP_1p_ShrinkRay_Gun_ANIM.WEP_1stp_shrinkray_gun_anim"
	PickupMeshName="WEP_3P_ShrinkRay_Gun_MESH.Wep_ShrinkRay_Gun_Pickup"
	AttachmentArchetypeName="WEP_ShrinkRay_Gun_ARCH.Microwave_Gun_3P"
	MuzzleFlashTemplateName="WEP_ShrinkRay_Gun_ARCH.Wep_Microwave_Gun_MuzzleFlash"

	// Ammo
	MagazineCapacity[0]=100
	SpareAmmoCapacity[0]=600
	InitialSpareMags[0]=1
	AmmoPickupScale[0]=1.0
	bCanBeReloaded=true
	bReloadFromMagazine=true

	// Recoil
	maxRecoilPitch=50
	minRecoilPitch=50
	maxRecoilYaw=115
	minRecoilYaw=-115
	RecoilRate=0.085
	RecoilMaxYawLimit=500
	RecoilMinYawLimit=65035
	RecoilMaxPitchLimit=900
	RecoilMinPitchLimit=65035
	RecoilISMaxYawLimit=75
	RecoilISMinYawLimit=65460
	RecoilISMaxPitchLimit=375
	RecoilISMinPitchLimit=65460
	RecoilViewRotationScale=0.25
	IronSightMeshFOVCompensationScale=1.5
    HippedRecoilModifier=1.5

    // Inventory
	InventorySize=5
	GroupPriority=100
	WeaponSelectTexture=Texture2D'WEP_UI_ShrinkRay_Gun_TEX.UI_Weapon_Select_Shrink_Ray_Gun'

	// DEFAULT_FIREMODE
	FireModeIconPaths(DEFAULT_FIREMODE)=Texture2D'ui_firemodes_tex.UI_FireModeSelect_Electricity'
	FiringStatesArray(DEFAULT_FIREMODE)=SprayingFire
	WeaponFireTypes(DEFAULT_FIREMODE)=EWFT_Custom
	FireInterval(DEFAULT_FIREMODE)=+0.08 // 750 RPM
	MinAmmoConsumed=3
	FireOffset=(X=30,Y=4.5,Z=-5)

	Spread(DEFAULT_FIREMODE)=0.12f

	// ALT_FIREMODE
	FiringStatesArray(ALTFIRE_FIREMODE)=WeaponSingleFiring
	WeaponFireTypes(ALTFIRE_FIREMODE)=EWFT_None

	// BASH_FIREMODE
	InstantHitDamageTypes(BASH_FIREMODE)=class'KFDT_Bludgeon_ShrinkRay'
	InstantHitDamage(BASH_FIREMODE)=26

	// Fire Effects
	WeaponFireSnd(DEFAULT_FIREMODE)=(DefaultCue=AkEvent'ww_wep_shrink_ray_gun.Play_WEP_ShrinkRay_Gun_Shoot_Loop_3P', FirstPersonCue=AkEvent'ww_wep_shrink_ray_gun.Play_WEP_ShrinkRay_Gun_Shoot_Loop_1P')
    WeaponFireLoopEndSnd(DEFAULT_FIREMODE)=(DefaultCue=AkEvent'WW_WEP_Shrink_Ray_Gun.Play_WEP_ShrinkRay_Gun_Shoot_Loop_End_3P', FirstPersonCue=AkEvent'WW_WEP_Shrink_Ray_Gun.Play_WEP_ShrinkRay_Gun_Shoot_Loop_End_1P')

	// Muzzle Flash point light
	// want this light to illuminate characters only
    Begin Object Class=PointLightComponent Name=PilotPointLight0
		LightColor=(R=0,G=200,B=255,A=255)
		Brightness=35.f
		FalloffExponent=20.f
		Radius=95.f
		CastShadows=TRUE
		CastStaticShadows=FALSE
		CastDynamicShadows=TRUE
		bCastPerObjectShadows=false
		bEnabled=FALSE
		LightingChannels=(Indoor=TRUE,Outdoor=TRUE,bInitialized=FALSE)
	End Object

	    Begin Object Class=PointLightComponent Name=PilotPointLight1
		LightColor=(R=250,G=150,B=85,A=255)
		Brightness=3.f
		FalloffExponent=8.f
		Radius=32.f
		CastShadows=False
		CastStaticShadows=FALSE
		CastDynamicShadows=TRUE
		bCastPerObjectShadows=false
		bEnabled=FALSE
		LightingChannels=(Indoor=TRUE,Outdoor=TRUE,bInitialized=FALSE)
	End Object

	PilotLights(0)=(Light=PilotPointLight0,FlickerIntensity=25.f,FlickerInterpSpeed=50f,LightAttachBone=MuzzleFlash)
	PilotLights(1)=(Light=PilotPointLight1,FlickerIntensity=15.f,FlickerInterpSpeed=50.f,LightAttachBone=MuzzleFlash)

	bInvertPilot=true

	//@todo: add akevents when we have them
	WeaponDryFireSnd(DEFAULT_FIREMODE)=AkEvent'ww_wep_shrink_ray_gun.Play_WEP_ShrinkRay_Gun_Dry_Fire'
	WeaponDryFireSnd(ALTFIRE_FIREMODE)=AkEvent'ww_wep_shrink_ray_gun.Play_WEP_ShrinkRay_Gun_Dry_Fire'
	//PilotLightPlayEvent=AkEvent'WW_WEP_SA_Microwave_Gun.Play_SA_MicrowaveGun_PilotLight_Loop'
	//PilotLightStopEvent=AkEvent'WW_WEP_SA_Microwave_Gun.Stop_SA_MicrowaveGun_PilotLight_Loop'

	// Advanced (High RPM) Fire Effects
	bLoopingFireAnim(DEFAULT_FIREMODE)=true
	bLoopingFireSnd(DEFAULT_FIREMODE)=true
	SingleFireSoundIndex=FIREMODE_NONE

	// Attachments
	bHasIronSights=true
	bHasFlashlight=false

   	AssociatedPerkClasses(0)=class'KFPerk_Survivalist'

   	BonesToLockOnEmpty=(RW_Handle1, RW_BatteryCylinder1, RW_BatteryCylinder2, RW_LeftArmSpinner, RW_RightArmSpinner, RW_LockEngager2, RW_LockEngager1)

 	// AI Warning
 	bWarnAIWhenFiring=true
    MaxAIWarningDistSQ=2250000

	// Weapon Upgrade stat boosts
	//WeaponUpgrades[1]=(IncrementDamage=1.15f,IncrementWeight=1)

	WeaponUpgrades[1]=(Stats=((Stat=EWUS_Damage0, Scale=1.35f), (Stat=EWUS_Damage1, Scale=1.35f), (Stat=EWUS_Weight, Add=1)))
	WeaponUpgrades[2]=(Stats=((Stat=EWUS_Damage0, Scale=1.7f), (Stat=EWUS_Damage1, Scale=1.7f), (Stat=EWUS_Weight, Add=2)))

	CooldownBarrelModifier = 2.5f;
}