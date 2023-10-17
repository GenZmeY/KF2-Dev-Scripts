//=============================================================================
// KFWeap_LMG_MG3
//=============================================================================
// The MG3 rifle
//=============================================================================
// Killing Floor 2
// Copyright (C) 2023 Tripwire Interactive LLC
//=============================================================================
class KFWeap_LMG_MG3 extends KFWeap_RifleBase;

/** Alternate reload anims (when below the bullet belt threshold */
const ReloadLowAmmoAnim = 'Reload_Empty_Half';
const ReloadLowAmmoEliteAnim = 'Reload_Empty_Half_Elite';

const AltFireLoopAnim      = 'ShootLoop_Secondary';
const AltFireLoopStartAnim = 'ShootLoop_Start_Secondary';
const AltFireLoopEndAnim   = 'ShootLoop_End_Secondary';

/** Array of bone names corresponding to bullets in the ammo belt */
var protected const string AmmoBeltBulletBonePrefix;

/** Number of bullets in the ammo belt */
var protected const int NumAmmoBeltBullets;

/** How much ammo we had the last time we updated the ammo belt */
var transient protected int LastAmmoCount;

/** TRUE when set for the first time */
var transient protected bool bAmmoBeltInitialized;

/** Number of bullets fired (Alt firemode))  */
var byte NumAltBullets;

/** Degrees used in altfire */
var float SpreadWidthDegrees;

/** Max offset from shot in Y and X axes. */
var vector2d SpreadMaxOffset;

var transient float StartingAltBulletPosition;

/** Just in case we spawned in with an ammo count that's lower than the threshold */
simulated event ReplicatedEvent( name VarName )
{
	super.ReplicatedEvent( VarName );

	if( !bAmmoBeltInitialized )
	{
		UpdateAmmoBeltBullets();
	}
}

simulated event PreBeginPlay()
{
    Super.PreBeginPlay();

    Spread[ALTFIRE_FIREMODE] = SpreadWidthDegrees * DegToRad / (NumAltBullets - 1);

    StartingAltBulletPosition = -SpreadWidthDegrees * DegToRad * 0.5f;
}

/** Just in case we spawned in with an ammo count that's lower than the threshold */
simulated event PostBeginPlay()
{
	super.PostBeginPlay();

	if( !bAmmoBeltInitialized && Role == ROLE_Authority )
	{
		UpdateAmmoBeltBullets();
	}
}

/** Update ammo belt */
simulated function ConsumeAmmo( byte FireModeNum )
{
	super.ConsumeAmmo( FireModeNum );

	UpdateAmmoBeltBullets();
}

/** Update ammo belt */
simulated function PerformReload( optional byte FireModeNum )
{
	super.PerformReload( FireModeNum );

	UpdateAmmoBeltBullets();
}

/** Notify triggered by reload animations, when ammo belt is grabbed offscreen */
simulated function ANIMNOTIFY_RestoreAmmoBelt()
{
	local int AmmoType, PendingAmmoCount;

	AmmoType = GetAmmoType(0);

	// This value will sync with the amount actually reloaded in PerformReload()
	PendingAmmoCount = Min( AmmoCount[AmmoType] + SpareAmmoCount[AmmoType], MagazineCapacity[AmmoType] );
	if( PendingAmmoCount < NumAmmoBeltBullets )
	{
		UpdateAmmoBeltBullets( PendingAmmoCount );
	}
	else
	{
		UpdateAmmoBeltBullets( , true );
	}
}

/** Hides/shows bones on the weapon to simulate reaching the end of the ammo belt */
simulated function UpdateAmmoBeltBullets( optional int ForcedBulletCount=INDEX_NONE, optional bool bShowAll=false )
{
	local Name BulletBoneName;
	local int NumAmmo, i;

	if( WorldInfo.NetMode == NM_DedicatedServer )
	{
		return;
	}

	// Don't do any bone alterations until the bone array has been filled out
	if( MySkelMesh.LocalAtoms.Length == 0 )
	{
		// Check on the next frame to see if we can init our ammo belt
		if( !IsTimerActive(nameOf(Timer_AttemptAmmoBeltUpdate)) )
		{
			SetTimer( 0.01f, false, nameOf(Timer_AttemptAmmoBeltUpdate) );
		}
		return;
	}

	// So we don't do this in PostInitAnimTree() or again in Timer_AttemptAmmoBeltUpdate() if we don't have to
	bAmmoBeltInitialized = true;

	// Don't do anything if ammo hasn't changed
	NumAmmo = ForcedBulletCount != INDEX_NONE ? ForcedBulletCount : AmmoCount[GetAmmoType(0)];
	if( !bShowAll && (LastAmmoCount == NumAmmo || (LastAmmoCount >= NumAmmoBeltBullets && NumAmmo >= NumAmmoBeltBullets)) )
	{
		return;
	}

	// Hide or unhide depending on place in array
	for( i = 0; i < NumAmmoBeltBullets; ++i )
	{
		BulletBoneName = Name( AmmoBeltBulletBonePrefix $ (i+1) );

		// Unhide all bullets if our ammo count is higher than the number of bullets
		if( bShowAll || NumAmmo >= NumAmmoBeltBullets )
		{
			MySkelMesh.UnHideBoneByName( BulletBoneName );
			continue;
		}

		if( i > NumAmmo-1 )
		{
			MySkelMesh.HideBoneByName( BulletBoneName, PBO_None );
		}
		else
		{
			MySkelMesh.UnHideBoneByName( BulletBoneName );
		}
	}

	LastAmmoCount = NumAmmo;
}

simulated function Timer_AttemptAmmoBeltUpdate()
{
	if( !bAmmoBeltInitialized )
	{
		UpdateAmmoBeltBullets();
	}
}

/** Returns animation to play based on reload type and status */
simulated function name GetReloadAnimName( bool bTacticalReload )
{
	if( AmmoCount[0] > 0 && AmmoCount[0] < NumAmmoBeltBullets )
	{
		// If we are below the threshold, play our low ammo reload
		return bTacticalReload ? ReloadLowAmmoEliteAnim : ReloadLowAmmoAnim;
	}
	else
	{
		return super.GetReloadAnimName( bTacticalReload );
	}
}

/**
 * State WeaponEquipping
 * The Weapon is in this state while transitioning from Inactive to Active state.
 * Typically, the weapon will remain in this state while its selection animation is being played.
 * While in this state, the weapon cannot be fired.
 */
simulated state WeaponEquipping
{
	simulated event BeginState( Name PreviousStateName )
	{
		super.BeginState( PreviousStateName );

		// Just in case a reload was interrupted after ANIMNOTIFY_RestoreAmmoBelt() was called,
		// set the ammo belt to the current amount of bullets in the magazine on equip
		UpdateAmmoBeltBullets();
	}
}


simulated function KFProjectile SpawnAllProjectiles(class<KFProjectile> KFProjClass, vector RealStartLoc, vector AimDir)
{
	local int i;
    local float InitialOffset;

    if (CurrentFireMode != ALTFIRE_FIREMODE)
    {
        return Super.SpawnAllProjectiles(KFProjClass, RealStartLoc, AimDir);
    }

    InitialOffset = StartingAltBulletPosition;

	for (i = 0; i < NumAltBullets; i++)
	{
		SpawnProjectile(KFProjClass, RealStartLoc, CalculateSpread(InitialOffset, Spread[ALTFIRE_FIREMODE], i));
	}
	
	return None;
}

simulated function vector CalculateSpread(float InitialOffset, float CurrentSpread, byte BulletNum)
{
    local Vector X, Y, Z, POVLoc;
    local Quat R;
	local rotator POVRot;
	local float RandValue;

	if (Instigator != None && Instigator.Controller != none)
	{
		Instigator.Controller.GetPlayerViewPoint(POVLoc, POVRot);
	}

    GetAxes(POVRot, X, Y, Z);

	// Calculate random offset on X axis
	RandValue = FRand() * SpreadMaxOffset.X * DegToRad * (Rand(2) == 0 ? 1 : -1);
    R = QuatFromAxisAndAngle(Z, InitialOffset + CurrentSpread * BulletNum + RandValue);

	// Calculate random offset on Y axisº
	RandValue = FRand() * SpreadMaxOffset.Y * DegToRad * (Rand(2) == 0 ? 1 : -1);
	R = QuatProduct(R, QuatFromAxisAndAngle(Y, RandValue));
	
    return QuatRotateVector(R, vector(POVRot));
}

simulated function StartFire(byte FireModeNum)
{
	if (FireModeNum == DEFAULT_FIREMODE && bUseAltFireMode)
	{
		if (AmmoCount[FireModeNum] < AmmoCost[ALTFIRE_FIREMODE] && SpareAmmoCount[FireModeNum] > 0)
		{
			BeginFire(RELOAD_FIREMODE);
			return;
		}
	}

	super.StartFire(FireModeNum);
}

simulated function InstantFireClient()
{
	local vector			StartTrace, EndTrace;
	local rotator			AimRot;
	local Array<ImpactInfo>	ImpactList;
	local int				Idx;
	local ImpactInfo		RealImpact;
	local float				CurPenetrationValue;

	// see Controller AimHelpDot() / AimingHelp()
	bInstantHit = true;

	// define range to use for CalcWeaponFire()
	StartTrace = GetSafeStartTraceLocation();
	AimRot = GetAdjustedAim(StartTrace);
	EndTrace = StartTrace + vector(AimRot) * GetTraceRange();

	bInstantHit = false;

    // Initialize penetration power
    PenetrationPowerRemaining = GetInitialPenetrationPower(CurrentFireMode);
    CurPenetrationValue = PenetrationPowerRemaining;

	if (bUseAltFireMode)
	{
		EndTrace = StartTrace + CalculateSpread(StartingAltBulletPosition, Spread[ALTFIRE_FIREMODE], 0) * GetTraceRange();
	}

	// Perform shot
	RealImpact = CalcWeaponFire(StartTrace, EndTrace, ImpactList);

	// Set flash location to trigger client side effects.  Bypass Weapon.SetFlashLocation since
	// that function is not marked as simulated and we want instant client feedback.
	// ProjectileFire/IncrementFlashCount has the right idea:
	//	1) Call IncrementFlashCount on Server & Local
	//	2) Replicate FlashCount if ( !bNetOwner )
	//	3) Call WeaponFired() once on local player
	if( Instigator != None )
	{
		Instigator.SetFlashLocation( Self, CurrentFireMode, RealImpact.HitLocation );
	}

	// local player only for clientside hit detection
	if ( Instigator != None && Instigator.IsLocallyControlled() )
	{
		// allow weapon to add extra bullet impacts (useful for shotguns)
		InstantFireClient_AddImpacts(StartTrace, AimRot, ImpactList);

		for (Idx = 0; Idx < ImpactList.Length; Idx++)
		{
			ProcessInstantHitEx(CurrentFireMode, ImpactList[Idx],, CurPenetrationValue, Idx);
		}

		if ( Instigator.Role < ROLE_Authority )
		{
            SendClientImpactList(CurrentFireMode, ImpactList);
		}
	}
}

simulated function InstantFireClient_AddImpacts(vector StartTrace, rotator Aim, out array<ImpactInfo> ImpactList)
{
	local int i;
	local ImpactInfo RealImpact;

	if (!bUseAltFireMode)
	{
		return;
	}

	for (i = 1; i < NumAltBullets; ++i)
	{
		RealImpact = CalcWeaponFire(StartTrace, StartTrace + CalculateSpread(StartingAltBulletPosition, Spread[ALTFIRE_FIREMODE], i) * GetTraceRange(), ImpactList);
		if( Instigator != None )
		{
			Instigator.SetFlashLocation( Self, CurrentFireMode, RealImpact.HitLocation );
		}
	}
}

/** Get name of the animation to play for PlayFireEffects */
simulated function name GetLoopingFireAnim(byte FireModeNum)
{
	if (FireModeNum == ALTFIRE_FIREMODE && !bUsingSights)
	{
		return AltFireLoopAnim;
	}

	return super.GetLoopingFireAnim(FireModeNum);
}

/** Get name of the animation to play for PlayFireEffects */
simulated function name GetLoopStartFireAnim(byte FireModeNum)
{
	if (FireModeNum == ALTFIRE_FIREMODE && !bUsingSights)
	{
		return AltFireLoopStartAnim;
	}

	return super.GetLoopStartFireAnim(FireModeNum);
}


/** Get name of the animation to play for PlayFireEffects */
simulated function name GetLoopEndFireAnim(byte FireModeNum)
{
	if (FireModeNum == ALTFIRE_FIREMODE && !bUsingSights)
	{
		return AltFireLoopEndAnim;
	}

	return super.GetLoopEndFireAnim(FireModeNum);
}

defaultproperties
{
	// Shooting Animations
	FireSightedAnims[0]=Shoot_Iron
	FireSightedAnims[1]=Shoot_Iron2
	FireSightedAnims[2]=Shoot_Iron3

    // FOV
    MeshFOV=75
	MeshIronSightFOV=35
    PlayerIronSightFOV=70

	// Depth of field
	DOF_FG_FocalRadius=85
	DOF_FG_MaxNearBlurSize=2.5

	// Content
	PackageKey="MG3"
	FirstPersonMeshName="WEP_1P_MG3_MESH.Wep_1stP_MG3_Rig"
	FirstPersonAnimSetNames(0)="WEP_1P_MG3_ANIM.Wep_1stP_MG3_Anim"
	PickupMeshName="WEP_3P_MG3_MESH.Wep_MG3_Pickup"
	AttachmentArchetypeName="WEP_MG3_ARCH.Wep_MG3_3P"
	MuzzleFlashTemplateName="WEP_MG3_ARCH.Wep_MG3_MuzzleFlash"

   	// Zooming/Position
	PlayerViewOffset=(X=-5,Y=9,Z=-5) // (X=-8.5,Y=9,Z=-5) 
	IronSightPosition=(X=5,Y=0,Z=-5) // (X=8.5,Y=0,Z=-5)

	// Ammo
	MagazineCapacity[0]=75
	SpareAmmoCapacity[0]=525
	InitialSpareMags[0]=1
	bCanBeReloaded=true
	bReloadFromMagazine=true

	// Recoil
	maxRecoilPitch=120
	minRecoilPitch=70
	maxRecoilYaw=130
	minRecoilYaw=-130
	RecoilRate=0.08
	RecoilMaxYawLimit=500
	RecoilMinYawLimit=65035
	RecoilMaxPitchLimit=900
	RecoilMinPitchLimit=65035
	RecoilISMaxYawLimit=75
	RecoilISMinYawLimit=65460
	RecoilISMaxPitchLimit=375
	RecoilISMinPitchLimit=65460
	RecoilViewRotationScale=0.25
	IronSightMeshFOVCompensationScale=2.3
    HippedRecoilModifier=1.5

    // Inventory / Grouping
	InventorySize=9
	GroupPriority=100
	WeaponSelectTexture=Texture2D'WEP_UI_MG3_TEX.UI_WeaponSelect_MG3'
   	AssociatedPerkClasses(0)=class'KFPerk_Commando'

	// DEFAULT_FIREMODE
	FireModeIconPaths(DEFAULT_FIREMODE)=Texture2D'ui_firemodes_tex.UI_FireModeSelect_BulletAuto'
	FiringStatesArray(DEFAULT_FIREMODE)=WeaponFiring
	WeaponFireTypes(DEFAULT_FIREMODE)=EWFT_InstantHit
	WeaponProjectiles(DEFAULT_FIREMODE)=class'KFProj_Bullet_AssaultRifle'
	InstantHitDamageTypes(DEFAULT_FIREMODE)=class'KFDT_Ballistic_MG3'
	FireInterval(DEFAULT_FIREMODE)=+0.066 // 900 RPM
	Spread(DEFAULT_FIREMODE)=0.0085
	InstantHitDamage(DEFAULT_FIREMODE)=35.0
	FireOffset=(X=30,Y=4.5,Z=-5)

	// ALT_FIREMODE
	FireModeIconPaths(ALTFIRE_FIREMODE)=Texture2D'ui_firemodes_tex.UI_FireModeSelect_BulletBurst'
	FiringStatesArray(ALTFIRE_FIREMODE)=WeaponFiring
	WeaponFireTypes(ALTFIRE_FIREMODE)=EWFT_InstantHit
    WeaponProjectiles(ALTFIRE_FIREMODE)=class'KFProj_Bullet_MG3_Alt'
	InstantHitDamageTypes(ALTFIRE_FIREMODE)=class'KFDT_Ballistic_MG3_Alt'
	FireInterval(ALTFIRE_FIREMODE)=+0.132 // 900 RPM it was +0.066 originally
	Spread(ALTFIRE_FIREMODE)=0.001
	InstantHitDamage(ALTFIRE_FIREMODE)=15.0 // 30
	AmmoCost(ALTFIRE_FIREMODE)=3

	// BASH_FIREMODE
	InstantHitDamageTypes(BASH_FIREMODE)=class'KFDT_Bludgeon_MG3'
	InstantHitDamage(BASH_FIREMODE)=26

	// Fire Effects
	WeaponFireSnd(DEFAULT_FIREMODE)=(DefaultCue=AkEvent'WW_WEP_MG3.Play_WEP_MG3_Fire_3P_Loop', FirstPersonCue=AkEvent'WW_WEP_MG3.Play_WEP_MG3_Fire_1P_Loop')
	WeaponFireSnd(ALTFIRE_FIREMODE)=(DefaultCue=AkEvent'WW_WEP_MG3.Play_WEP_MG3_AltFire_3P_Single', FirstPersonCue=AkEvent'WW_WEP_MG3.Play_WEP_MG3_AltFire_1P_Single')
	WeaponFireLoopEndSnd(DEFAULT_FIREMODE)=(DefaultCue=AkEvent'WW_WEP_MG3.Play_WEP_MG3_Fire_3P_EndLoop', FirstPersonCue=AkEvent'WW_WEP_MG3.Play_WEP_MG3_Fire_1P_EndLoop')
	WeaponDryFireSnd(DEFAULT_FIREMODE)=AkEvent'WW_WEP_SA_L85A2.Play_WEP_SA_L85A2_Handling_DryFire'
	WeaponDryFireSnd(ALTFIRE_FIREMODE)=AkEvent'WW_WEP_SA_L85A2.Play_WEP_SA_L85A2_Handling_DryFire'
	EjectedShellForegroundDuration=0.8f

	// Advanced (High RPM) Fire Effects
	bLoopingFireAnim(DEFAULT_FIREMODE)=true
	bLoopingFireSnd(DEFAULT_FIREMODE)=true
	bLoopingFireAnim(ALTFIRE_FIREMODE)=true
	SingleFireSoundIndex=ALTFIRE_FIREMODE

	// Attachments
	bHasIronSights=true
	bHasFlashlight=false

	// Ammo belt
	AmmoBeltBulletBonePrefix="RW_Bullets"
	NumAmmoBeltBullets=14
	LastAmmoCount=-1

    NumAltBullets=5
    SpreadWidthDegrees=20
    StartingAltBulletPosition=0.0f
	SpreadMaxOffset=(X=1.2f, Y=1.5f)
}
