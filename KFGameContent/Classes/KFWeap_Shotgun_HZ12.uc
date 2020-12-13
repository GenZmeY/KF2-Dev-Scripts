//=============================================================================
// KFWeap_Shotgun_HZ12
//=============================================================================
// Class Description
//=============================================================================
// Killing Floor 2
// Copyright (C) 2016 Tripwire Interactive LLC
//=============================================================================
class KFWeap_Shotgun_HZ12 extends KFWeap_ShotgunBase;

/** Keeps track of number of shots fired for the alternate fire animation */
var transient protected int NumShotsFired;

/** Fire interval used for pump shots */
var const protected float PumpFireInterval;

simulated protected function bool IsPumpFire()
{
	return NumShotsFired % 2 == 0;
}

/** Overridden to use a custom fire interval for pump shots */
simulated function float GetFireInterval( byte FireModeNum )
{
	if( IsPumpFire() )
	{
		return PumpFireInterval;
	}

	return super.GetFireInterval( FireModeNum );
}

/** Overridden to add to the number of shots fired */
simulated function ConsumeAmmo( byte FireModeNum )
{
	++NumShotsFired;

	super.ConsumeAmmo( FireModeNum );
}

/** Overridden to reset shot count */
simulated function PerformReload(optional byte FireModeNum)
{
	NumShotsFired = 0;

	super.PerformReload( FireModeNum );
}

/** We need to play a pump every 2 shots, as well as for the last shot to eject any shells remaining before reloading */
simulated function bool ShouldPlayFireLast( byte FireModeNum )
{
	if( IsPumpFire() )
	{
		return true;
	}

	return false;
}

/*********************************************************************************************
 * State WeaponSingleFiring
 * Fire must be released between every shot.
 *********************************************************************************************/

simulated state WeaponSingleFiring
{
	/**
	 * Timer event, call is set up in Weapon::TimeWeaponFiring().
	 * The weapon is given a chance to evaluate if another shot should be fired.
	 * This event defines the weapon's rate of fire.
	 */
	simulated function RefireCheckTimer()
	{
		super.RefireCheckTimer();

		//@TODO: Try to make timer time dilation work instead of restarting the timer, so we can
		// keep our timer overlaps. It's unlikely it could desynched with a magazine less than
		// 100, but it's still safer this way. -MattF
		/*if( IsTimerActive(nameOf(RefireCheckTimer)) )
		{
			if( IsPumpFire() )
			{
				//`log("numshotsfired:"@numshotsfired@FireInterval[0] / PumpFireInterval);
				ModifyTimerTimeDilation( nameOf(RefireCheckTimer), FireInterval[0] / PumpFireInterval );
			}
			else
			{
				`log("numshotsfired:"@numshotsfired@FireInterval[0]);
				ResetTimerTimeDilation( nameOf(RefireCheckTimer) );
			}
		}*/
	}

	/** Handle fire interval changes */
	simulated function FireAmmunition()
    {
    	super.FireAmmunition();

		// Gotta restart the timer every shot :(
		if( IsTimerActive(nameOf(RefireCheckTimer)) )
		{
			ClearTimer( nameOf(RefireCheckTimer) );
			TimeWeaponFiring( CurrentFireMode );
		}
    }
}

defaultproperties
{
	// Inventory
	InventorySize=5
	GroupPriority=55
	WeaponSelectTexture=Texture2D'WEP_UI_HZ12_TEX.UI_WeaponSelect_HZ12'

    // FOV
    MeshFOV=75
	MeshIronSightFOV=52
    PlayerIronSightFOV=70

	// Depth of field
	DOF_FG_FocalRadius=95
	DOF_FG_MaxNearBlurSize=3.5

	// Zooming/Position
	PlayerViewOffset=(X=20,Y=7.6,Z=-3.0)
	IronSightPosition=(X=6.0,Y=0,Z=0)

	// Content
	PackageKey="HZ12"
	FirstPersonMeshName="WEP_1P_HZ12_MESH.Wep_1stP_HZ12_Rig"
	FirstPersonAnimSetNames(0)="WEP_1P_HZ12_ANIM.Wep_1stP_HZ12_Anim"
	PickupMeshName="WEP_3P_HZ12_MESH.Wep_3rdP_HZ12_Pickup"
	AttachmentArchetypeName="WEP_HZ12_ARCH.Wep_HZ12_3P"
	MuzzleFlashTemplateName="WEP_HZ12_ARCH.Wep_HZ12_MuzzleFlash"

	// DEFAULT_FIREMODE
	FireModeIconPaths(DEFAULT_FIREMODE)="ui_firemodes_tex.UI_FireModeSelect_ShotgunSingle"
	FiringStatesArray(DEFAULT_FIREMODE)=WeaponSingleFiring
	WeaponFireTypes(DEFAULT_FIREMODE)=EWFT_Projectile
	WeaponProjectiles(DEFAULT_FIREMODE)=class'KFProj_Bullet_Pellet'
	InstantHitDamage(DEFAULT_FIREMODE)=20.0
	InstantHitDamageTypes(DEFAULT_FIREMODE)=class'KFDT_Ballistic_HZ12'
	PenetrationPower(DEFAULT_FIREMODE)=2.0
	FireInterval(DEFAULT_FIREMODE)=0.1
	Spread(DEFAULT_FIREMODE)=0.15
	FireOffset=(X=30,Y=3,Z=-3)
	// Shotgun
	NumPellets(DEFAULT_FIREMODE)=10

	// HZ12
	PumpFireInterval=0.66 //0.77

	// ALT_FIREMODE
	FireModeIconPaths(ALTFIRE_FIREMODE)=Texture2D'ui_firemodes_tex.UI_FireModeSelect_ShotgunSingle'
	FiringStatesArray(ALTFIRE_FIREMODE)=WeaponSingleFiring
	WeaponFireTypes(ALTFIRE_FIREMODE)=EWFT_None

	// BASH_FIREMODE
	InstantHitDamageTypes(BASH_FIREMODE)=class'KFDT_Bludgeon_HZ12'
	InstantHitDamage(BASH_FIREMODE)=25

	// Fire Effects
	WeaponFireSnd(DEFAULT_FIREMODE)=(DefaultCue=AkEvent'WW_WEP_HZ12.Play_WEP_HZ12_Fire_3P', FirstPersonCue=AkEvent'WW_WEP_HZ12.Play_WEP_HZ12_Fire_1P')
    WeaponFireSnd(ALTFIRE_FIREMODE)=(DefaultCue=AkEvent'WW_WEP_HZ12.Play_WEP_HZ12_Fire_3P', FirstPersonCue=AkEvent'WW_WEP_HZ12.Play_WEP_HZ12_Fire_1P')

    // using M4 dry fire sound. this is intentional.
	WeaponDryFireSnd(DEFAULT_FIREMODE)=AkEvent'WW_WEP_SA_M4.Play_WEP_SA_M4_Handling_DryFire'
	WeaponDryFireSnd(ALTFIRE_FIREMODE)=AkEvent'WW_WEP_SA_M4.Play_WEP_SA_M4_Handling_DryFire'

	// Attachments
	bHasIronSights=true
	bHasFlashlight=true

	// Ammo
	MagazineCapacity[0]=16
	SpareAmmoCapacity[0]=80
	InitialSpareMags[0]=1
	bCanBeReloaded=true
	bReloadFromMagazine=true

	// Recoil
	maxRecoilPitch=900
	minRecoilPitch=775
	maxRecoilYaw=500
	minRecoilYaw=-500
	RecoilRate=0.085
	RecoilBlendOutRatio=1.1 //0.35
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

	// Animation
	bHasFireLastAnims=false

	AssociatedPerkClasses(0)=class'KFPerk_Support'

	WeaponFireWaveForm=ForceFeedbackWaveform'FX_ForceFeedback_ARCH.Gunfire.Heavy_Recoil_SingleShot'

	// Weapon Upgrade stat boosts
	//WeaponUpgrades[1]=(IncrementDamage=1.1f,IncrementWeight=1)
	//WeaponUpgrades[2]=(IncrementDamage=1.2f,IncrementWeight=2)
	//WeaponUpgrades[3]=(IncrementDamage=1.3f,IncrementWeight=3)

	WeaponUpgrades[1]=(Stats=((Stat=EWUS_Damage0, Scale=1.1f), (Stat=EWUS_Weight, Add=1)))
	WeaponUpgrades[2]=(Stats=((Stat=EWUS_Damage0, Scale=1.2f), (Stat=EWUS_Weight, Add=2)))
	WeaponUpgrades[3]=(Stats=((Stat=EWUS_Damage0, Scale=1.3f), (Stat=EWUS_Weight, Add=3)))
}
