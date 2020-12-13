//=============================================================================
// KFWeap_Rifle_M99
//=============================================================================
//
//=============================================================================
// Killing Floor 2
// Copyright (C) 2016 Tripwire Interactive LLC
// John "Ramm-Jaeger" Gibson
//=============================================================================

class KFWeap_Rifle_M99 extends KFWeap_ScopedBase;

defaultproperties
{
	// Inventory / Grouping
	InventorySize=12 //11
	GroupPriority=125
	WeaponSelectTexture=Texture2D'WEP_UI_M99_TEX.UI_WeaponSelect_M99'
   	AssociatedPerkClasses(0)=class'KFPerk_Sharpshooter'

 	// 2D scene capture
	Begin Object Name=SceneCapture2DComponent0
	   TextureTarget=TextureRenderTarget2D'Wep_Mat_Lib.WEP_ScopeLense_Target'
	   FieldOfView=12.5 // "2.0X" = 25.0(our real world FOV determinant)/2.0
	End Object

    ScopedSensitivityMod=8.0

	ScopeLenseMICTemplate=MaterialInstanceConstant'WEP_1P_M99_MAT.WEP_1P_M99_Scope_MAT'

    // FOV
    MeshFOV=60 //70
	MeshIronSightFOV=27
    PlayerIronSightFOV=70

	// Depth of field
	DOF_BlendInSpeed=3.0
	DOF_FG_FocalRadius=0//70
	DOF_FG_MaxNearBlurSize=3.5

	// Content
	PackageKey="M99"
	FirstPersonMeshName="WEP_1P_M99_MESH.Wep_1stP_M99_Rig"
	FirstPersonAnimSetNames(0)="WEP_1P_M99_ANIM.Wep_1stP_M99_Anim"
	PickupMeshName="WEP_3P_M99_MESH.Wep_3rdP_M99_Pickup"
	AttachmentArchetypeName="WEP_M99_ARCH.Wep_M99_3P"
	MuzzleFlashTemplateName="WEP_M99_ARCH.Wep_M99_MuzzleFlash"

	LaserSightTemplate=KFLaserSightAttachment'FX_LaserSight_ARCH.LaserSight_WithAttachment_1P'

	// Ammo
	MagazineCapacity[0]=1
	SpareAmmoCapacity[0]=20 //30
	InitialSpareMags[0]=6
	bCanBeReloaded=true
	bReloadFromMagazine=true
	AmmoPickupScale[0]=2.0

	// Zooming/Position
	PlayerViewOffset=(X=15.0,Y=11.5,Z=-4)
	IronSightPosition=(X=0.0,Y=0,Z=0)

	// AI warning system
	bWarnAIWhenAiming=true
	AimWarningDelay=(X=0.4f, Y=0.8f)
	AimWarningCooldown=0.0f

	// Recoil
	maxRecoilPitch=1200
	minRecoilPitch=775
	maxRecoilYaw=800
	minRecoilYaw=-500
	RecoilRate=0.085
	RecoilMaxYawLimit=500
	RecoilMinYawLimit=65035
	RecoilMaxPitchLimit=900
	RecoilMinPitchLimit=65035
	RecoilISMaxYawLimit=150
	RecoilISMinYawLimit=65385
	RecoilISMaxPitchLimit=375
	RecoilISMinPitchLimit=65460
	RecoilViewRotationScale=0.8
	FallingRecoilModifier=1.0
	HippedRecoilModifier=3.0

	// DEFAULT_FIREMODE
	FireModeIconPaths(DEFAULT_FIREMODE)=Texture2D'ui_firemodes_tex.UI_FireModeSelect_BulletSingle'
	FiringStatesArray(DEFAULT_FIREMODE)=WeaponSingleFiring
	WeaponFireTypes(DEFAULT_FIREMODE)=EWFT_InstantHit
	WeaponProjectiles(DEFAULT_FIREMODE)=class'KFProj_Bullet_M99'
	InstantHitDamage(DEFAULT_FIREMODE)=850 //850
	InstantHitDamageTypes(DEFAULT_FIREMODE)=class'KFDT_Ballistic_M99'
	FireInterval(DEFAULT_FIREMODE)=0.2 //0.2
	PenetrationPower(DEFAULT_FIREMODE)=5.0
	Spread(DEFAULT_FIREMODE)=0.006
	FireOffset=(X=30,Y=3.0,Z=-2.5)
	ForceReloadTimeOnEmpty=0.5

	// ALT_FIREMODE
	FiringStatesArray(ALTFIRE_FIREMODE) = WeaponSingleFiring
	WeaponFireTypes(ALTFIRE_FIREMODE) = EWFT_None

	// BASH_FIREMODE
	InstantHitDamageTypes(BASH_FIREMODE)=class'KFDT_Bludgeon_M99'
	InstantHitDamage(BASH_FIREMODE)=30

	// Fire Effects
	WeaponFireSnd(DEFAULT_FIREMODE)=(DefaultCue=AkEvent'WW_WEP_M99.Play_WEP_M99_Fire_3P_Single', FirstPersonCue=AkEvent'WW_WEP_M99.Play_WEP_M99_Fire_1P_Single')
	WeaponDryFireSnd(DEFAULT_FIREMODE)=AkEvent'WW_WEP_M99.Play_WEP_M99_DryFire''

	// Custom animations
	FireSightedAnims=(Shoot_Iron, Shoot_Iron2, Shoot_Iron3)

	// Attachments
	bHasIronSights=true
	bHasFlashlight=false

	WeaponFireWaveForm=ForceFeedbackWaveform'FX_ForceFeedback_ARCH.Gunfire.Heavy_Recoil'


}
