//=============================================================================
// KFWeap_GrenadeLauncher_M32
//=============================================================================
// An M32 Grenade Launcher
//=============================================================================
// Killing Floor 2
// Copyright (C) 2017 Tripwire Interactive LLC
//=============================================================================

class KFWeap_GrenadeLauncher_M32 extends KFWeap_GrenadeLauncher_CylinderBase;

defaultproperties
{
	ForceReloadTime=0.0f

	// Inventory
	InventoryGroup=IG_Primary
	GroupPriority=125
	InventorySize=9
	WeaponSelectTexture=Texture2D'WEP_UI_M32_MGL_TEX.UI_WeaponSelect_M32_MGL'


    // FOV
	MeshIronSightFOV=52
    PlayerIronSightFOV=73

	// Zooming/Position
	PlayerViewOffset=(X=19.0,Y=13,Z=-2)
	FastZoomOutTime=0.2

	// Content
	PackageKey="M32_MGL"
	FirstPersonMeshName="WEP_1P_M32_MGL_MESH.Wep_1stP_M32_MGL_Rig"
	FirstPersonAnimSetNames(0)="WEP_1P_M32_MGL_ANIM.Wep_1stP_M32_MGL_Anim"
	PickupMeshName="WEP_3P_M32_MGL_MESH.Wep_3rdP_M32_MGL_Pickup"
	AttachmentArchetypeName="WEP_M32_MGL_ARCH.Wep_M32_MGL_3P"
	MuzzleFlashTemplateName="WEP_M32_MGL_ARCH.Wep_M32_MGL_MuzzleFlash" // Need to replace

	Begin Object Name=FirstPersonMesh
		// new anim tree with skelcontrol to rotate cylinders
		AnimTreeTemplate=AnimTree'CHR_1P_Arms_ARCH.WEP_1stP_Animtree_Master_Revolver'
	End Object

   	// Zooming/Position
	IronSightPosition=(X=0,Y=0,Z=0)

	// Ammo
	MagazineCapacity[0]=6
	SpareAmmoCapacity[0]=36
	InitialSpareMags[0]=2
	AmmoPickupScale[0]=1.0
	bCanBeReloaded=true
	bReloadFromMagazine=false

	// Recoil
	maxRecoilPitch=900
	minRecoilPitch=775
	maxRecoilYaw=500
	minRecoilYaw=-500
	RecoilRate=0.085
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
	FireModeIconPaths(DEFAULT_FIREMODE)=Texture2D'ui_firemodes_tex.UI_FireModeSelect_Grenade'
	FiringStatesArray(DEFAULT_FIREMODE)=WeaponSingleFiring
	WeaponFireTypes(DEFAULT_FIREMODE)=EWFT_Projectile
	WeaponProjectiles(DEFAULT_FIREMODE)=class'KFProj_HighExplosive_M32'
	FireInterval(DEFAULT_FIREMODE)=+0.25
	InstantHitDamage(DEFAULT_FIREMODE)=150.0
	InstantHitDamageTypes(DEFAULT_FIREMODE)=class'KFDT_Ballistic_M32Impact'
	Spread(DEFAULT_FIREMODE)=0.015
	FireOffset=(X=23,Y=4.0,Z=-3)

	// ALT_FIREMODE
	FiringStatesArray(ALTFIRE_FIREMODE)=WeaponSingleFiring
	WeaponFireTypes(ALTFIRE_FIREMODE)=EWFT_None

	// BASH_FIREMODE
	InstantHitDamageTypes(BASH_FIREMODE)=class'KFDT_Bludgeon_M32'
	InstantHitDamage(BASH_FIREMODE)=26

	// Fire Effects
	WeaponFireSnd(DEFAULT_FIREMODE)=(DefaultCue=AkEvent'WW_WEP_M32.Play_M32_Fire_3P_Single', FirstPersonCue=AkEvent'WW_WEP_M32.Play_M32_Fire_1P_Single')

	//@todo: add akevent when we have it
	WeaponDryFireSnd(DEFAULT_FIREMODE)=AkEvent'WW_WEP_M32.Play_M32_DryFire'

	// Animation
	bHasFireLastAnims=true

	// Attachments
	bHasIronSights=true
	bHasFlashlight=false

	AssociatedPerkClasses(0)=class'KFPerk_Demolitionist'

	WeaponFireWaveForm=ForceFeedbackWaveform'FX_ForceFeedback_ARCH.Gunfire.Heavy_Recoil_SingleShot'

	// Revolver
	bRevolver=true
	CylinderRotInfo=(Inc=60, Time=0.0875/*about 0.35 in the anim divided by ratescale of 4*/)

	// Revolver shell/cap replacement
	
	BulletFXSocketNames=(RW_Bullet_FX_1, RW_Bullet_FX_2, RW_Bullet_FX_3, RW_Bullet_FX_4, RW_Bullet_FX_5, RW_Bullet_FX_6)
	ShellBoneNames=(RW_Shell3, RW_Shell2, RW_Shell1, RW_Shell6, RW_Shell5, RW_Shell4)

	Begin Object Class=KFBulletSkeletalMeshComponent Name=BulletMeshComp0
		SkeletalMesh=SkeletalMesh'WEP_1P_M32_MGL_MESH.Wep_1stP_M32_MGL_Shell'
		UnusedBulletMeshTemplate = SkeletalMesh'WEP_1P_M32_MGL_MESH.Wep_1stP_M32_MGL_Shell'
		UsedBulletMeshTemplate = SkeletalMesh'WEP_1P_M32_MGL_MESH.Wep_1stP_M32_MGL_Empty_Shell'
		CollideActors=false
		BlockActors=false
		BlockZeroExtent=false
		BlockNonZeroExtent=false
		BlockRigidBody=false
		bAcceptsStaticDecals=false
		bAcceptsDecals=false
		CastShadow=false
		bUseAsOccluder=false
		DepthPriorityGroup=SDPG_Foreground // First person only
	End Object
	Components.Add(BulletMeshComp0)
	BulletMeshComponents.Add(BulletMeshComp0)

	Begin Object Class=KFBulletSkeletalMeshComponent Name=BulletMeshComp1
		SkeletalMesh=SkeletalMesh'WEP_1P_M32_MGL_MESH.Wep_1stP_M32_MGL_Shell'
		UnusedBulletMeshTemplate = SkeletalMesh'WEP_1P_M32_MGL_MESH.Wep_1stP_M32_MGL_Shell'
		UsedBulletMeshTemplate = SkeletalMesh'WEP_1P_M32_MGL_MESH.Wep_1stP_M32_MGL_Empty_Shell'
		CollideActors=false
		BlockActors=false
		BlockZeroExtent=false
		BlockNonZeroExtent=false
		BlockRigidBody=false
		bAcceptsStaticDecals=false
		bAcceptsDecals=false
		CastShadow=false
		bUseAsOccluder=false
		DepthPriorityGroup=SDPG_Foreground // First person only
	End Object
	Components.Add(BulletMeshComp1)
	BulletMeshComponents.Add(BulletMeshComp1)

	Begin Object Class=KFBulletSkeletalMeshComponent Name=BulletMeshComp2
		SkeletalMesh=SkeletalMesh'WEP_1P_M32_MGL_MESH.Wep_1stP_M32_MGL_Shell'
		UnusedBulletMeshTemplate = SkeletalMesh'WEP_1P_M32_MGL_MESH.Wep_1stP_M32_MGL_Shell'
		UsedBulletMeshTemplate = SkeletalMesh'WEP_1P_M32_MGL_MESH.Wep_1stP_M32_MGL_Empty_Shell'
		CollideActors=false
		BlockActors=false
		BlockZeroExtent=false
		BlockNonZeroExtent=false
		BlockRigidBody=false
		bAcceptsStaticDecals=false
		bAcceptsDecals=false
		CastShadow=false
		bUseAsOccluder=false
		DepthPriorityGroup=SDPG_Foreground // First person only
	End Object
	Components.Add(BulletMeshComp2)
	BulletMeshComponents.Add(BulletMeshComp2)

	Begin Object Class=KFBulletSkeletalMeshComponent Name=BulletMeshComp3
		SkeletalMesh=SkeletalMesh'WEP_1P_M32_MGL_MESH.Wep_1stP_M32_MGL_Shell'
		UnusedBulletMeshTemplate = SkeletalMesh'WEP_1P_M32_MGL_MESH.Wep_1stP_M32_MGL_Shell'
		UsedBulletMeshTemplate = SkeletalMesh'WEP_1P_M32_MGL_MESH.Wep_1stP_M32_MGL_Empty_Shell'
		CollideActors=false
		BlockActors=false
		BlockZeroExtent=false
		BlockNonZeroExtent=false
		BlockRigidBody=false
		bAcceptsStaticDecals=false
		bAcceptsDecals=false
		CastShadow=false
		bUseAsOccluder=false
		DepthPriorityGroup=SDPG_Foreground // First person only
	End Object
	Components.Add(BulletMeshComp3)
	BulletMeshComponents.Add(BulletMeshComp3)

	Begin Object Class=KFBulletSkeletalMeshComponent Name=BulletMeshComp4
		SkeletalMesh=SkeletalMesh'WEP_1P_M32_MGL_MESH.Wep_1stP_M32_MGL_Shell'
		UnusedBulletMeshTemplate = SkeletalMesh'WEP_1P_M32_MGL_MESH.Wep_1stP_M32_MGL_Shell'
		UsedBulletMeshTemplate = SkeletalMesh'WEP_1P_M32_MGL_MESH.Wep_1stP_M32_MGL_Empty_Shell'
		CollideActors=false
		BlockActors=false
		BlockZeroExtent=false
		BlockNonZeroExtent=false
		BlockRigidBody=false
		bAcceptsStaticDecals=false
		bAcceptsDecals=false
		CastShadow=false
		bUseAsOccluder=false
		DepthPriorityGroup=SDPG_Foreground // First person only
	End Object
	Components.Add(BulletMeshComp4)
	BulletMeshComponents.Add(BulletMeshComp4)

	Begin Object Class=KFBulletSkeletalMeshComponent Name=BulletMeshComp5
		SkeletalMesh=SkeletalMesh'WEP_1P_M32_MGL_MESH.Wep_1stP_M32_MGL_Shell'
		UnusedBulletMeshTemplate = SkeletalMesh'WEP_1P_M32_MGL_MESH.Wep_1stP_M32_MGL_Shell'
		UsedBulletMeshTemplate = SkeletalMesh'WEP_1P_M32_MGL_MESH.Wep_1stP_M32_MGL_Empty_Shell'
		CollideActors=false
		BlockActors=false
		BlockZeroExtent=false
		BlockNonZeroExtent=false
		BlockRigidBody=false
		bAcceptsStaticDecals=false
		bAcceptsDecals=false
		CastShadow=false
		bUseAsOccluder=false
		DepthPriorityGroup=SDPG_Foreground // First person only
	End Object
	Components.Add(BulletMeshComp5)
	BulletMeshComponents.Add(BulletMeshComp5)

	Begin Object Class=KFBulletSkeletalMeshComponent Name=BulletMeshComp6
		SkeletalMesh=SkeletalMesh'WEP_1P_M32_MGL_MESH.Wep_1stP_M32_MGL_Shell'
		UnusedBulletMeshTemplate=SkeletalMesh'WEP_1P_M32_MGL_MESH.Wep_1stP_M32_MGL_Shell'
		UsedBulletMeshTemplate=SkeletalMesh'WEP_1P_M32_MGL_MESH.Wep_1stP_M32_MGL_Empty_Shell'
		CollideActors=false
		BlockActors=false
		BlockZeroExtent=false
		BlockNonZeroExtent=false
		BlockRigidBody=false
		bAcceptsStaticDecals=false
		bAcceptsDecals=false
		CastShadow=false
		bUseAsOccluder=false
		DepthPriorityGroup=SDPG_Foreground // First person only
	End Object
	Components.Add(BulletMeshComp6)
	ReloadShell=BulletMeshComp6
}
