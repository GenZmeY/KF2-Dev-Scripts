//=============================================================================
// KFWeap_GrenadeLauncher_CylinderBase
//=============================================================================
// Cylinder based grenade launcher
//=============================================================================
// Killing Floor 2
// Copyright (C) 2017 Tripwire Interactive LLC
//=============================================================================

class KFWeap_GrenadeLauncher_CylinderBase extends KFWeap_GrenadeLauncher_Base
	native;

var int CurrentShellSlotReloading;
var bool bReloadingFromEmpty;
var bool bInitialReloadIsOpenOnly;

/*********************************************************************************************
* @name	Revolver vars
********************************************************************************************* */

// Whether this weapon is a revolver. Enables revolver functionality like rotating cylinder and noticeably-used shells
var bool bRevolver;

// Meshes to indicate which rounds have been fired or not
var array<name> BulletFXSocketNames;
var array<KFBulletSkeletalMeshComponent> BulletMeshComponents;

var array<name> ShellBoneNames;

var name ReloadShellSocketName;
var KFBulletSkeletalMeshComponent ReloadShell;

const CYLINDERSTATE_READY = 0;
const CYLINDERSTATE_PENDING = 1;
const CYLINDERSTATE_ROTATING = 2;

var CylinderRotationInfo CylinderRotInfo;

cpptext
{
	// cylinder is incrementally rotated
	virtual void TickSpecial(FLOAT DeltaSeconds);
};

// directly sets cylinder rotation, instead of allowing tickspecial to increment rotation
native simulated function SetCylinderRotation(out CylinderRotationInfo RotInfo, float Degrees);


/** Cache Anim Nodes from the tree
* 	@note: skipped on server because AttachComponent/AttachWeaponTo is not called
*/
simulated event PostInitAnimTree(SkeletalMeshComponent SkelComp)
{
	super.PostInitAnimTree(SkelComp);

	if (bRevolver)
	{
		PostInitAnimTreeRevolver(SkelComp);
	}
}

/*********************************************************************************************
* @name	Ammo
********************************************************************************************* */

// /**
//  * @see Weapon::ConsumeAmmo
//  */
simulated function ConsumeAmmo(byte FireModeNum)
{
	local int BulletIndex;

	BulletIndex = MagazineCapacity[DEFAULT_FIREMODE] - AmmoCount[DEFAULT_FIREMODE];

	super.ConsumeAmmo(FireModeNum);

	// update bullet mesh
	if (BulletIndex < BulletMeshComponents.Length)
	{
		BulletMeshComponents[BulletIndex].SetBulletState(BS_Used);
	}

	// do revovler ammo before actually consuming ammo
	if (bRevolver && Instigator != none && Instigator.IsLocallyControlled())
	{
		ConsumeAmmoRevolver();
	}
}

simulated function PerformReload(optional byte FireModeNum)
{
	if (!bInitialReloadIsOpenOnly)
	{
		bInitialReloadIsOpenOnly = true;
		return;
	}
	
	super.PerformReload(FireModeNum);
	BulletMeshComponents[CurrentShellSlotReloading].SetBulletState(BS_Unused);
	CurrentShellSlotReloading++;
}

simulated function UpdateShellsBaseOnAmmoCount(optional byte FireModeNum = 0)
{
	local int i;

	for (i = 0; i < BulletMeshComponents.length; i++)
	{
		if (BulletMeshComponents[i].GetBulletShellState() != BS_Unused && AmmoCount[FireModeNum] > i)
		{
			BulletMeshComponents[i].SetBulletState(BS_Unused);
			return;
		}
	}
}

simulated function GetFirstEmptyShell()
{
	
}

simulated function SetShellToState(int ShellIndex, byte ShellState)
{
	switch (ShellState)
	{
	case 0:
		BulletMeshComponents[ShellIndex].SetBulletState(BS_Unused);
		break;
	case 1:
		BulletMeshComponents[ShellIndex].SetBulletState(BS_Used);
		break;
	case 2:
		BulletMeshComponents[ShellIndex].SetBulletState(BS_Unloaded);
		break;
	default:
		BulletMeshComponents[ShellIndex].SetBulletState(BS_Unused);
	}
}

/**
* State Reloading
* State the weapon is in when it is being reloaded (current magazine replaced with a new one, related animations and effects played).
*/
simulated state Reloading
{
	ignores ForceReload, ShouldAutoReload, AllowSprinting;

simulated function BeginState(name PreviousStateName)
{
	super.BeginState(PreviousStateName);

	if (bRevolver)
	{
		ResetCylinder();
	}
}
}

/*********************************************************************************************
* @name	Revolver
********************************************************************************************* */

simulated event PostInitAnimTreeRevolver(SkeletalMeshComponent SkelComp)
{
	local int i;

	CylinderRotInfo.Control = SkelControlSingleBone(SkelComp.FindSkelControl('CylinderControl'));
	if (CylinderRotInfo.Control != none)
	{
		CylinderRotInfo.Control.SetSkelControlActive(true);
	}

	// attach bullet meshes to correct sockets
	for (i = 0; i < BulletMeshComponents.Length; ++i)
	{
		BulletMeshComponents[i].SetBulletState(BS_Unused);
		MySkelMesh.AttachComponentToSocket(BulletMeshComponents[i], BulletFXSocketNames[i]);
	}
	MySkelMesh.AttachComponentToSocket(ReloadShell, ReloadShellSocketName);
}

simulated function ConsumeAmmoRevolver()
{
	CheckCylinderRotation(CylinderRotInfo);
	CylinderRotInfo.State = CYLINDERSTATE_PENDING;
}

simulated function CheckCylinderRotation(out CylinderRotationInfo RotInfo, optional bool bResetState)
{
	if (RotInfo.State != CYLINDERSTATE_READY)
	{
		RotateCylinder(RotInfo, true);

		if (bResetState)
		{
			RotInfo.State = CYLINDERSTATE_READY;
		}
	}
}

simulated function ANIMNOTIFY_ResetBulletMeshes()
{
	local int i;
	
	for (i = 0; i < BulletMeshComponents.length; i++)
	{
		BulletMeshComponents[i].SetBulletState(i < MagazineCapacity[0] - AmmoCount[0] ? BS_Unloaded  : BS_Unused );
	}
}

/** Initiate cylinder rotation (rotation occurs in tickspecial in native) */
simulated function ANIMNOTIFY_RotateCylinder()
{
	RotateCylinder(CylinderRotInfo);
}

/** Initiates cylinder rotation process */
simulated function RotateCylinder(out CylinderRotationInfo RotInfo, optional bool bInstant)
{
	if (bInstant)
	{
		// don't use timer, just set rotation

		if (RotInfo.State == CYLINDERSTATE_PENDING)
		{
			// if we're pending, we don't have an updated rotation yet, so get a rotation
			IncrementCylinderRotation(RotInfo);
		}
		else
		{
			// if we're rotating already, we're going to go to a pending state after forcing rotation
			RotInfo.State = CYLINDERSTATE_PENDING;
		}

		SetCylinderRotation(RotInfo, RotInfo.NextDegrees);
		RotInfo.Timer = 0.f;
	}
	else
	{
		// use timer, rotate over time in native tickspecial
		RotInfo.State = CYLINDERSTATE_ROTATING;
		IncrementCylinderRotation(RotInfo);
		RotInfo.Timer = RotInfo.Time;
	}
}

simulated function IncrementCylinderRotation(out CylinderRotationInfo RotInfo)
{
	local bool bReloading;

	bReloading = ReloadStatus == RS_Reloading;
	//if reloading reverse the rotation
	RotInfo.PrevDegrees = RotInfo.NextDegrees;
	RotInfo.NextDegrees += bReloading ? -RotInfo.Inc : RotInfo.Inc;
}

simulated function ResetCylinderInfo(out CylinderRotationInfo RotInfo)
{
	RotInfo.PrevDegrees = 0;
	RotInfo.NextDegrees = 0;
	RotInfo.State = CYLINDERSTATE_READY;
}

simulated event OnCylinderRotationFinished(out CylinderRotationInfo RotInfo)
{
	RotInfo.State = CYLINDERSTATE_READY;
}

/** Resets cylinder orientation to initial state and repositions bullet meshes to line up with their pre-reset locations */
simulated function ResetCylinder()
{
	// reset cylinder rotation (skel control needs to be reset to initial state while bullet casings are not on screen)
	SetCylinderRotation(CylinderRotInfo, 0);
	ResetCylinderInfo(CylinderRotInfo);

	// now, we need to make sure the used bullets are still in the correct positions

	// if we fired all our ammo, it doesn't matter where the bullets are, because they're all the same (used)
	if (AmmoCount[DEFAULT_FIREMODE] == 0)
	{
		return;
	}
}

/** Sets all bullet casing meshes back to unused state */
simulated function ResetBulletMeshes()
{
	local int i;
	return;
	for (i = 0; i < BulletMeshComponents.Length; ++i)
	{
		BulletMeshComponents[i].SetBulletState(BS_Unused);
	}
}

/*********************************************************************************************
* State WeaponPuttingDown
* Putting down weapon in favor of a new one.
* Weapon is transitioning to the Inactive state.
*********************************************************************************************/

simulated state WeaponPuttingDown
{
	simulated function EndState(Name NextStateName)
{
	super.EndState(NextStateName);
	CheckCylinderRotation(CylinderRotInfo, true);
}
}


/*********************************************************************************************
* @name	Iron Sights / Zoom
*********************************************************************************************/

/**
* Adjust the FOV for the first person weapon and arms.
*/
simulated event SetFOV(float NewFOV)
{
	local int i;

	super.SetFOV(NewFOV);

	for (i = 0; i < BulletMeshComponents.Length; ++i)
	{
		BulletMeshComponents[i].SetFOV(NewFOV);
	}

	if (ReloadShell != none)
	{
		ReloadShell.SetFOV(NewFOV);
	}
}

/*********************************************************************************************
* @name	Reload
*********************************************************************************************/

simulated function InitializeReload()
{
	bInitialReloadIsOpenOnly = false;
	RebuildLockedBonesForReload();
	super.InitializeReload();
	CheckCylinderRotation(CylinderRotInfo, true);
	CurrentShellSlotReloading = 0;
}

simulated function RebuildLockedBonesForReload()
{
	local int i;
	local int NumOfShotsToReload;

	if (EmptyMagBlendNode != none)
	{
		EmptyMagBlendNode.SetBlendTarget(0, 0);
	}
	
	BonesToLockOnEmpty.length = 0;
	NumOfShotsToReload = MagazineCapacity[0] - AmmoCount[0];
	
	for (i=NumOfShotsToReload; i < ShellBoneNames.length; i++)
	{
		
		BonesToLockOnEmpty.AddItem(ShellBoneNames[i]);
	}
	if (EmptyMagBlendNode != none && BonesToLockOnEmpty.Length > 0)
	{
		BuildEmptyMagNodeWeightList(EmptyMagBlendNode, BonesToLockOnEmpty);
		EmptyMagBlendNode.SetBlendTarget(1, 0);
	}
}

/** Returns animation to play based on reload type and status */

simulated function name GetReloadAnimName(bool bTacticalReload)
{
	if (!bReloadFromMagazine)
	{
		switch (ReloadStatus)
		{
		case RS_OpeningBolt:
			ReloadStatus = GetNextReloadStatus();
			
			bReloadingFromEmpty = AmmoCount[0] == 0;
				
			return bReloadingFromEmpty ? 'Reload_Empty_Open' : 'Reload_Half_Open';

		case RS_Reloading:
			return bReloadingFromEmpty ? 'Reload_Empty_Insert' : 'Reload_Half_Insert';
			
		case RS_ClosingBolt:
			return bReloadingFromEmpty ? 'Reload_Empty_Close' : 'Reload_Half_Close';
		}

		return 'Reload_Half_Insert';
	}
}

simulated function UnloadAllBulletMeshes()
{
	local int i;

	for (i = 0; i < BulletMeshComponents.length; i++)
	{
		BulletMeshComponents[i].SetBulletState(BS_Unloaded);
	}
}

defaultproperties
{
	ForceReloadTime=0.0f

	// Inventory
	InventoryGroup=IG_Primary
	GroupPriority=75
	InventorySize=6
	WeaponSelectTexture=Texture2D'WEP_UI_M79_TEX.UI_WeaponSelect_M79' // //NEED TO REPLACE

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
	PickupMeshName="WEP_3P_M79_MESH.Wep_m79_Pickup"  //NEED TO REPLACE
	AttachmentArchetypeName="WEP_M32_MGL_ARCH.Wep_M32_MGL_3P"
	MuzzleFlashTemplateName="WEP_M79_ARCH.Wep_M79_MuzzleFlash" // Need to replace

   	// Zooming/Position
	IronSightPosition=(X=0,Y=0,Z=0)

	// Ammo
	MagazineCapacity[0]=6
	SpareAmmoCapacity[0]=36
	InitialSpareMags[0]=9
	AmmoPickupScale[0]=2.0
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
	//WeaponProjectiles(DEFAULT_FIREMODE)=class'KFProj_HighExplosive_M32'
	FireInterval(DEFAULT_FIREMODE)=+0.25
	InstantHitDamage(DEFAULT_FIREMODE)=150.0
//	InstantHitDamageTypes(DEFAULT_FIREMODE)=class'KFDT_Ballistic_M32Impact'
	Spread(DEFAULT_FIREMODE)=0.015
	FireOffset=(X=23,Y=4.0,Z=-3)

	// ALT_FIREMODE
	FiringStatesArray(ALTFIRE_FIREMODE)=WeaponSingleFiring
	WeaponFireTypes(ALTFIRE_FIREMODE)=EWFT_None

	// BASH_FIREMODE
//	InstantHitDamageTypes(BASH_FIREMODE)=class'KFDT_Bludgeon_M32'
	InstantHitDamage(BASH_FIREMODE)=26

	// Fire Effects
	WeaponFireSnd(DEFAULT_FIREMODE)=(DefaultCue=AkEvent'WW_WEP_SA_M79.Play_WEP_SA_M79_Fire_M', FirstPersonCue=AkEvent'WW_WEP_SA_M79.Play_WEP_SA_M79_Fire_S')

	//@todo: add akevent when we have it
	WeaponDryFireSnd(DEFAULT_FIREMODE)=none

	// Animation
	bHasFireLastAnims=true

	// Attachments
	bHasIronSights=true
	bHasFlashlight=false

	AssociatedPerkClasses(0)=class'KFPerk_Demolitionist'

	WeaponFireWaveForm=ForceFeedbackWaveform'FX_ForceFeedback_ARCH.Gunfire.Heavy_Recoil_SingleShot'

	// Revolver
	bRevolver=true
	CylinderRotInfo=(Inc=72.0, Time=0.0875/*about 0.35 in the anim divided by ratescale of 4*/)

	ReloadShellSocketName="RW_Shell_Reload"
}
