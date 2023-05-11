//=============================================================================
// KFWeap_Minigun
//=============================================================================
// Minigun
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//=============================================================================

class KFWeap_Minigun extends KFWeap_MinigunBase;

/** Camera shake when shooting */
var	CameraAnim	ShootCameraAnim;

/** Current camera shake animation */
var CameraAnimInst ShootCameraAnimInstance;

/** Camera shake play rate */
var float ShootCameraAnimPlayRate;

/** Camera shake strength */
var float ShootCameraAnimScale;

/** Camera shake blend time */
var float ShootCameraAnimBlendTime;

/**  Sound info for the barrel rotation in 1st person and 3rd person */
var WeaponFireSndInfo BarrelRotationLoopSound;

/** The system is currently playing the barrel sound */
var	bool bPlayingLoopingBarrelSnd;

/** The system is currently playing the barrel stop sound */
var	bool bPlayingLoopingBarrelStopSnd;

/** Audio event played when the rotation of the barrel ends */
var WeaponFireSndInfo BarrelStopRotationSound;

/** Stored value for the rotation sound parameter */
var transient float CurrentBarrelRotParam;

var transient KFPawn PreviousOwner;

simulated function StartFire(byte FireModeNum)
{
	if (FireModeNum == ALTFIRE_FIREMODE)
	{
		return;
	}
	Super.StartFire(FireModeNum);
}

simulated event Tick( float DeltaTime )
{
	local float NewCurrentBarrelParam;
	local KFPawn KFP;
	local bool bPlaySound;
	
	Super.Tick(DeltaTime);

	KFP = KFPawn(Instigator);
	
	if( KFP == none && PreviousOwner != none)
	{
		PreviousOwner.SetSecondaryWeaponComponentRTPCValue("MinigunRotation", 0);
		PreviousOwner.SetSecondaryWeaponAmbientSound(none, none);
		bPlayingLoopingBarrelSnd = false;
		bPlayingLoopingBarrelStopSnd = false;
		CurrentBarrelRotParam = 0;
		WindUpControlTime = 0;
		PreviousOwner = none;
		return;
	}
	
	bPlaySound = KFP != none && (WorldInfo.NetMode != NM_Client || KFP.IsLocallyControlled());
	
	NewCurrentBarrelParam = CurrentBarrelRotParam;
	
	if( KFP != none && KFP.IsFirstPerson() && (IsInState('WeaponPuttingDown') || IsInState('Inactive')) )
	{
		UpdateBarrelSoundOnForceStop( bPlaySound );
		return;
	}
	
	if( WindUpControlTime > 0 && !bPlayingLoopingBarrelSnd)
	{
		bPlayingLoopingBarrelSnd = true;
		if ( bPlaySound ) KFP.SetSecondaryWeaponAmbientSound(BarrelRotationLoopSound.DefaultCue, BarrelRotationLoopSound.FirstPersonCue);
	}
	else if( WindUpControlTime <= 0 && bPlayingLoopingBarrelSnd )
	{
		bPlayingLoopingBarrelSnd = false;
		bPlayingLoopingBarrelStopSnd = false;
		if ( bPlaySound ) KFP.SetSecondaryWeaponAmbientSound(none, none);
	}

	if(WindUpControlTime > 0)
	{
		NewCurrentBarrelParam = 100 * WindUpControlTime / WindUpActivationTime;
		if ( KFP != none ) KFP.SetSecondaryWeaponComponentRTPCValue("MinigunRotation", NewCurrentBarrelParam);

		if( NewCurrentBarrelParam < 20 && NewCurrentBarrelParam < CurrentBarrelRotParam && !bPlayingLoopingBarrelStopSnd )
		{
			bPlayingLoopingBarrelStopSnd = true;
			if ( KFP != none ) KFP.SetWeaponAmbientSound(BarrelStopRotationSound.DefaultCue, BarrelStopRotationSound.FirstPersonCue);
		}

		CurrentBarrelRotParam = NewCurrentBarrelParam;
	}

	PreviousOwner = KFP;
}

/*********************************************************************************************
 * @name	SFX
 *********************************************************************************************/

simulated function UpdateBarrelSoundOnForceStop(bool bPlaySound)
{
	local KFPawn KFP;
	
	if(bPlayingLoopingBarrelSnd)
	{
		KFP = KFPawn(Instigator);

		CurrentBarrelRotParam -= 2;
		if ( KFP != none ) KFP.SetSecondaryWeaponComponentRTPCValue("MinigunRotation", CurrentBarrelRotParam);

		if( CurrentBarrelRotParam > 20 && !bPlayingLoopingBarrelStopSnd )
		{
			bPlayingLoopingBarrelStopSnd = true;
			if ( KFP != none ) KFP.SetWeaponAmbientSound(BarrelStopRotationSound.DefaultCue, BarrelStopRotationSound.FirstPersonCue);
		}

		if(CurrentBarrelRotParam < 0)
		{
			CurrentBarrelRotParam = 0;
			bPlayingLoopingBarrelSnd = false;
			bPlayingLoopingBarrelStopSnd = false;
			if ( bPlaySound ) KFP.SetSecondaryWeaponAmbientSound(none, none);
		}
	}
}

/*********************************************************************************************
 * @name	Trader
 *********************************************************************************************/

/** Returns trader filter index based on weapon type */
static simulated event EFilterTypeUI GetTraderFilter()
{
	return FT_Assault;
}

/*********************************************************************************************
 * State WeaponFiring
 * The weapon is in this state while holding fire button
*********************************************************************************************/

simulated state WeaponFiring
{
	simulated function BeginState(Name PrevStateName)
	{
		Super.BeginState(PrevStateName);
		
		if ( Instigator.IsLocallyControlled()  )
		{
			ShootCameraAnimInstance = PlayCameraAnim(ShootCameraAnim, ShootCameraAnimScale, ShootCameraAnimPlayRate, 
				ShootCameraAnimBlendTime, ShootCameraAnimBlendTime, true, false);
		}
	}

	simulated function EndState(Name NextStateName)
	{	
		local PlayerController PC;
		
		Super.EndState(NextStateName);
		
		if ( Instigator.IsLocallyControlled()  )
		{
			PC = PlayerController(Instigator.Controller);
			if (PC.PlayerCamera != None && ShootCameraAnimInstance != None)
			{
				PC.PlayerCamera.StopCameraAnim(ShootCameraAnimInstance);
				ShootCameraAnimInstance = None;
			}
		}
	}
}

defaultproperties
{
	// Wind Up variables
	WindUpActivationTime=0.70 //1.5
	WindUpRotationSpeed=1200

    // FOV
	MeshFOV=86
	MeshIronSightFOV=82
	PlayerIronSightFOV=82
	PlayerSprintFOV=95

	// Depth of field
	DOF_FG_FocalRadius=85
	DOF_FG_MaxNearBlurSize=2.5

	// Content
	PackageKey="Minigun"
	FirstPersonMeshName="wep_1p_minigun_mesh.Wep_1stP_Minigun_Rig"
	FirstPersonAnimSetNames(0)="wep_1p_minigun_anim.Wep_1stP_Minigun_Anim"
	PickupMeshName="WEP_3P_Minigun_MESH.Wep_3rdP_Minigun_LowPoly_Pickup"
	AttachmentArchetypeName="WEP_Minigun_ARCH.Wep_Minigun_3P"
	MuzzleFlashTemplateName="WEP_Minigun_ARCH.Wep_Minigun_MuzzleFlash"

   	// Zooming/Position
	PlayerViewOffset=(X=3.0,Y=15,Z=15)
	IronSightPosition=(X=3.0,Y=15,Z=15)

	// Ammo
	MagazineCapacity[0]=120 //125 //175 //250
	SpareAmmoCapacity[0]=600 //500 //750
	InitialSpareMags[0]=1
	AmmoPickupScale[0]=1 //0.67
	bCanBeReloaded=true
	bReloadFromMagazine=true

	// Recoil
	maxRecoilPitch=200 //187 //240 //225 //150
	minRecoilPitch=150 //144 //184 //175 //115
	maxRecoilYaw=130 //180 //115
	minRecoilYaw=-130 //-180 //-115
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
	IronSightMeshFOVCompensationScale=1
    HippedRecoilModifier=1.5

    // Inventory / Grouping
	InventorySize=10
	InventoryGroup=IG_Primary
	GroupPriority=130 //125
	WeaponSelectTexture=Texture2D'WEP_UI_Minigun_TEX.UI_WeaponSelect_Minigun'
   	AssociatedPerkClasses(0)=class'KFPerk_Commando'

	// DEFAULT_FIREMODE
	FireModeIconPaths(DEFAULT_FIREMODE)=Texture2D'ui_firemodes_tex.UI_FireModeSelect_BulletAuto'
	FiringStatesArray(DEFAULT_FIREMODE)=WeaponWindingUp
	WeaponFireTypes(DEFAULT_FIREMODE)=EWFT_InstantHit
	WeaponProjectiles(DEFAULT_FIREMODE)=class'KFProj_Bullet_Minigun'
	InstantHitDamageTypes(DEFAULT_FIREMODE)=class'KFDT_Ballistic_Minigun'
	FireInterval(DEFAULT_FIREMODE)=+0.05 // 1200 RPM
	Spread(DEFAULT_FIREMODE)=0.0085
	PenetrationPower(DEFAULT_FIREMODE)=2.0
	InstantHitDamage(DEFAULT_FIREMODE)=35.0 //32.0 //25
	FireOffset=(X=30,Y=4.5,Z=-5)

	// ALT_FIREMODE
	FiringStatesArray(ALTFIRE_FIREMODE)=WeaponWindingUp
	WeaponFireTypes(ALTFIRE_FIREMODE)=EWFT_None

	Begin Object Name=FirstPersonMesh
		// new anim tree with skelcontrol to rotate cylinders
		AnimTreeTemplate=AnimTree'WEP_Minigun_ARCH.WEP_Animtree_Minigun_1p'
	End Object

	// BASH_FIREMODE
	InstantHitDamageTypes(BASH_FIREMODE)=class'KFDT_Bludgeon_Minigun'
	InstantHitDamage(BASH_FIREMODE)=30

	// Fire Effects
	WeaponFireSnd(DEFAULT_FIREMODE)=(DefaultCue=AkEvent'WW_WEP_Minigun.Play_WEP_Minigun_Shoot_Loop_3P', FirstPersonCue=AkEvent'WW_WEP_Minigun.Play_WEP_Minigun_Shoot_Loop_1P')
	WeaponFireSnd(ALTFIRE_FIREMODE)=(DefaultCue=AkEvent'WW_WEP_Minigun.Play_WEP_Mingun_Shoot_3P', FirstPersonCue=AkEvent'WW_WEP_Minigun.Play_WEP_Mingun_Shoot_1P')
	WeaponFireLoopEndSnd(DEFAULT_FIREMODE)=(DefaultCue=AkEvent'WW_WEP_Minigun.Play_WEP_Minigun_Shoot_Loop_End_3P', FirstPersonCue=AkEvent'WW_WEP_Minigun.Play_WEP_Minigun_Shoot_Loop_End_1P')
	WeaponDryFireSnd(DEFAULT_FIREMODE)=AkEvent'WW_WEP_SA_L85A2.Play_WEP_SA_L85A2_Handling_DryFire'
	WeaponDryFireSnd(ALTFIRE_FIREMODE)=AkEvent'WW_WEP_SA_L85A2.Play_WEP_SA_L85A2_Handling_DryFire'

	BarrelRotationLoopSound=(DefaultCue=AkEvent'WW_WEP_Minigun.Play_WEP_Minigun_Loop_3P', FirstPersonCue=AkEvent'WW_WEP_Minigun.Play_WEP_Minigun_Loop_1P')
	BarrelStopRotationSound=(DefaultCue=AkEvent'WW_WEP_Minigun.Play_WEP_Minigun_Decelerate_3P', FirstPersonCue=AkEvent'WW_WEP_Minigun.Play_WEP_Minigun_Decelerate_1P')

	// Advanced (High RPM) Fire Effects
	bLoopingFireAnim(DEFAULT_FIREMODE)=true
	bLoopingFireSnd(DEFAULT_FIREMODE)=true
	SingleFireSoundIndex=ALTFIRE_FIREMODE

	// Attachments
	bHasIronSights=false
	bHasFlashlight=false

	EjectedShellForegroundDuration=0.8f
	
	// Camera shake animation
	ShootCameraAnim=CameraAnim'WEP_1P_Minigun_ANIM.Shoot'
	ShootCameraAnimPlayRate=1.0f //0.6f
	ShootCameraAnimScale=0.19f //0.25f
	ShootCameraAnimBlendTime=0.1f
	
	// movement and rotation speed values when winding up
	WindUpViewRotationSpeed=2000 // base rotation speed is 2000
	WindUpPawnMovementSpeed=0.9f //0.8f //0.7f // base modifier is 1
	
	// movement and rotation speed values when firing
	FiringViewRotationSpeed=1000 //488 //320 //270
	FiringPawnMovementSpeed=1.8f //0.3f //0.2f //0.08f
}


