//=============================================================================
// KFWeap_SMG_HK_UMP
//=============================================================================
// Weapon class for Heckler UMP
//=============================================================================
// Killing Floor 2
// Copyright (C) 2017 Tripwire Interactive LLC
//=============================================================================

class KFWeap_SMG_HK_UMP extends KFWeap_SMGBase;

/** RecoilRate when firing in burst fire. */
var(Recoil) float BurstFireRecoilRate;
/** How much to scale recoil when firing in burst fire. */
var(Recoil) float BurstFireRecoilModifier;

// Standard
/** Animation to play when the weapon is fired  in burst mode with 2 rounds left */
var(Animations) const editconst	name	BurstFire2RdAnim;
/** Animation to play when the weapon is fired in burst fire mode for 3 rounds*/
var(Animations) const editconst	name	BurstFire3RdAnim;

// Iron Sights
/** Animation to play when the weapon is fired in burst mode with 2 rounds left */
var(Animations) const editconst	name	BurstFire2RdSightedAnim;
/** Animation to play when the weapon is fired in burst fire mode for 3 rounds*/
var(Animations) const editconst	name	BurstFire3RdSightedAnim;

/** Sound to play when the weapon is fired in burst mode with 2 rounds left  */
var(Sounds)	WeaponFireSndInfo	WeaponFire2RdSnd;
/** Sound to play when the weapon is fired in burst fire mode for 3 rounds */
var(Sounds)	WeaponFireSndInfo	WeaponFire3RdSnd;
/** Keeps track of whether or not the gun has played fire effects this burst. */
var bool bBurstPlayedFireEffects;

/*********************************************************************************************
* State WeaponBurstFiring
* Fires a burst of bullets. Fire must be released between every shot.
*********************************************************************************************/

simulated state WeaponBurstFiring
{
	simulated function BeginState(Name PrevStateName)
{
	// Modify the recoil for burst fire
	RecoilRate = BurstFireRecoilRate;

	// Initialize recoil blend out settings
	if (RecoilRate > 0 && RecoilBlendOutRatio > 0)
	{
		RecoilYawBlendOutRate = maxRecoilYaw / RecoilRate * RecoilBlendOutRatio;
		RecoilPitchBlendOutRate = maxRecoilPitch / RecoilRate * RecoilBlendOutRatio;
	}

	bBurstPlayedFireEffects = false;

	super.BeginState(PrevStateName);
}


/**
* PlayFireEffects Is the root function that handles all of the effects associated with
* a weapon.  This function creates the 1st person effects.  It should only be called
* on a locally controlled player.
*/
simulated function PlayFireEffects(byte FireModeNum, optional vector HitLocation)
{
	local name WeaponFireAnimName;

	// Only play the burst fire sound on the first shot as the sound includes additional shot sounds baked in
	if (FireModeNum != ALTFIRE_FIREMODE || (FireModeNum == ALTFIRE_FIREMODE &&
		(!bBurstPlayedFireEffects || `IsInZedTime(self))) )
		{
		PlayFiringSound(CurrentFireMode);
		}

	if (Instigator != none)
	{
		UpdateWeaponAttachmentAnimRate(GetThirdPersonAnimRate());

		if (Instigator.IsFirstPerson())
		{
			if (!bPlayingLoopingFireAnim && (FireModeNum != ALTFIRE_FIREMODE || (FireModeNum == ALTFIRE_FIREMODE &&
				!bBurstPlayedFireEffects)))
			{
				WeaponFireAnimName = GetWeaponFireAnim(FireModeNum);

				if (WeaponFireAnimName != '')
				{
					PlayAnimation(WeaponFireAnimName, MySkelMesh.GetAnimLength(WeaponFireAnimName),,FireTweenTime);
				}
			}

			HandleRecoil();

			ShakeView();

			// Start muzzle flash effect
			CauseMuzzleFlash(FireModeNum);
		}
	}

	bBurstPlayedFireEffects = true;
}

/** Overridden to include the BurstFireModifier*/
simulated function ModifyRecoil(out float CurrentRecoilModifier)
{
	super.ModifyRecoil(CurrentRecoilModifier);
	CurrentRecoilModifier *= BurstFireRecoilModifier;
}

/** Get name of the animation to play for PlayFireEffects. Overriden to play the right animation for the number of shots in the burst fire */
simulated function name GetWeaponFireAnim(byte FireModeNum)
{
	if (BurstAmount == 3)
	{
		if (bUsingSights)
		{
			return BurstFire3RdSightedAnim;
		}
		return BurstFire3RdAnim;
	}
	else if (BurstAmount == 2)
	{
		if (bUsingSights)
		{
			return BurstFire2RdSightedAnim;
		}
		return BurstFire2RdAnim;
	}
	else
	{
		return super.GetWeaponFireAnim(FireModeNum);
	}
}

/**
* Tells the weapon to play a firing sound (uses CurrentFireMode)
*/
simulated function PlayFiringSound(byte FireModeNum)
{
	if (!bPlayingLoopingFireSnd && BurstAmount > 1 && `NotInZedTime(self) )
		{
		MakeNoise(1.0, 'PlayerFiring');
		if (BurstAmount == 3)
		{
			WeaponPlayFireSound(WeaponFire3RdSnd.DefaultCue, WeaponFire3RdSnd.FirstPersonCue);
		}
		else if (BurstAmount == 2)
		{
			WeaponPlayFireSound(WeaponFire2RdSnd.DefaultCue, WeaponFire2RdSnd.FirstPersonCue);
		}
		}
	else
	{
		super.PlayFiringSound(FireModeNum);
	}
}

simulated event EndState(Name NextStateName)
{
	// Set recoil settings back to normal
	RecoilRate = default.RecoilRate;

	// Initialize recoil blend out settings
	if (RecoilRate > 0 && RecoilBlendOutRatio > 0)
	{
		RecoilYawBlendOutRate = maxRecoilYaw / RecoilRate * RecoilBlendOutRatio;
		RecoilPitchBlendOutRate = maxRecoilPitch / RecoilRate * RecoilBlendOutRatio;
	}

	Super.EndState(NextStateName);
}
}

defaultproperties
{
    // Inventory
    InventorySize=5
    GroupPriority=90 //60
    WeaponSelectTexture=Texture2D'WEP_UI_HK_UMP_TEX.UI_WeaponSelect_UMP'

    // FOV
    MeshFOV=86
    MeshIronSightFOV=50
    PlayerIronSightFOV=75

    // Zooming/Position
    IronSightPosition=(X=0.0f,Y=0.0f,Z=0.0f)  //x0.9
    PlayerViewOffset=(X=3.f,Y=10.0f,Z=-2.0f)
   // IronSightPosition=(X=10.f,Y=0,Z=0)
    //PlayerViewOffset=(X=17.f,Y=8,Z=-4.0)

	// Content
	PackageKey="HK_UMP"
	FirstPersonMeshName="WEP_1P_HK_UMP_MESH.Wep_1stP_HK_UMP_Rig"
	FirstPersonAnimSetNames(0)="WEP_1P_HK_UMP_ANIM.WEP_1stP_HK_UMP_Anim"
	PickupMeshName="WEP_3P_HK_UMP_MESH.Wep_3rdP_HK_UMP_Pickup"
	AttachmentArchetypeName="WEP_HK_UMP_ARCH.Wep_HK_UMP_3P"
	MuzzleFlashTemplateName="WEP_HK_UMP_ARCH.Wep_HK_UMP_MuzzleFlash"

    // Ammo
    MagazineCapacity[0]=30
    SpareAmmoCapacity[0]=290 //320
    InitialSpareMags[0]=2
    bCanBeReloaded=true
    bReloadFromMagazine=true

// Recoil
    maxRecoilPitch=120
    minRecoilPitch=92
    maxRecoilYaw=101 //92
    minRecoilYaw=-101  //92
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
    HippedRecoilModifier=1.4

	BurstFireRecoilRate= 0.085
	BurstFireRecoilModifier = 1.0
    // Recoil
   // maxRecoilPitch=60
   // minRecoilPitch=40
   // maxRecoilYaw=50
   // minRecoilYaw=-50
   // RecoilRate=0.06
   // RecoilMaxYawLimit=500
   // RecoilMinYawLimit=65035
   // RecoilMaxPitchLimit=550
   // RecoilMinPitchLimit=65035
    //RecoilISMaxYawLimit=75
    //RecoilISMinYawLimit=65460
    //RecoilISMaxPitchLimit=375
    //RecoilISMinPitchLimit=65460
    //IronSightMeshFOVCompensationScale=1.6
    //WalkingRecoilModifier=1.1
    //JoggingRecoilModifier=1.2

    // DEFAULT_FIREMODE
    FireModeIconPaths(DEFAULT_FIREMODE)=Texture2D'ui_firemodes_tex.UI_FireModeSelect_BulletAuto'
    FiringStatesArray(DEFAULT_FIREMODE)=WeaponFiring
    WeaponFireTypes(DEFAULT_FIREMODE)=EWFT_InstantHit
    WeaponProjectiles(DEFAULT_FIREMODE)=class'KFProj_Bullet_AssaultRifle'
    InstantHitDamageTypes(DEFAULT_FIREMODE)=class'KFDT_Ballistic_HK_UMP'
    FireInterval(DEFAULT_FIREMODE)=+0.1 // 600 RPM
    Spread(DEFAULT_FIREMODE)=0.01
    InstantHitDamage(DEFAULT_FIREMODE)=45
    FireOffset=(X=30,Y=4.5,Z=-5)

    // ALT_FIREMODE
    FireModeIconPaths(ALTFIRE_FIREMODE)=Texture2D'ui_firemodes_tex.UI_FireModeSelect_BulletBurst'
    FiringStatesArray(ALTFIRE_FIREMODE)=WeaponBurstFiring
    WeaponFireTypes(ALTFIRE_FIREMODE)=EWFT_InstantHit
    WeaponProjectiles(ALTFIRE_FIREMODE)=class'KFProj_Bullet_AssaultRifle'
    InstantHitDamageTypes(ALTFIRE_FIREMODE)=class'KFDT_Ballistic_HK_UMP'
    FireInterval(AltFire_FIREMODE)=+0.1 // 600 RPM
	BurstAmount=3
	BurstFire2RdAnim=Shoot_Burst2
	BurstFire3RdAnim=Shoot_Burst
	BurstFire2RdSightedAnim=Shoot_Burst2_Iron
	BurstFire3RdSightedAnim=Shoot_Burst_Iron
    WeaponFire2RdSnd=(DefaultCue=AkEvent'WW_WEP_UMP.Play_WEP_UMP_Fire_3P_2Round', FirstPersonCue=AkEvent'WW_WEP_UMP.Play_WEP_UMP_Fire_1P_2Round')
    WeaponFire3RdSnd=(DefaultCue=AkEvent'WW_WEP_UMP.Play_WEP_UMP_Fire_3P_3Round', FirstPersonCue=AkEvent'WW_WEP_UMP.Play_WEP_UMP_Fire_1P_3Round')
    InstantHitDamage(ALTFIRE_FIREMODE)=45
    Spread(ALTFIRE_FIREMODE)=0.01

    // BASH_FIREMODE
    InstantHitDamageTypes(BASH_FIREMODE)=class'KFDT_Bludgeon_HK_UMP'
    InstantHitDamage(BASH_FIREMODE)=24.0

    // Fire Effects
    //@todo: add akevents when we have them
    WeaponFireSnd(DEFAULT_FIREMODE)=(DefaultCue=AkEvent'WW_WEP_UMP.Play_WEP_UMP_Fire_3P_Loop',FirstPersonCue=AkEvent'WW_WEP_UMP.Play_WEP_UMP_Fire_1P_Loop')
    WeaponFireSnd(ALTFIRE_FIREMODE)=(DefaultCue=AkEvent'WW_WEP_UMP.Play_WEP_UMP_Fire_3P_Single',FirstPersonCue=AkEvent'WW_WEP_UMP.Play_WEP_UMP_Fire_1P_Single')
    WeaponDryFireSnd(DEFAULT_FIREMODE)=AkEvent'WW_WEP_SA_MedicSMG.Play_SA_MedicSMG_Handling_DryFire'
    WeaponDryFireSnd(ALTFIRE_FIREMODE)=AkEvent'WW_WEP_SA_MedicSMG.Play_SA_MedicSMG_Handling_DryFire'

    // Advanced (High RPM) Fire Effects
    bLoopingFireAnim(DEFAULT_FIREMODE)=true
    bLoopingFireSnd(DEFAULT_FIREMODE)=true
    WeaponFireLoopEndSnd(DEFAULT_FIREMODE)=(DefaultCue=AkEvent'WW_WEP_UMP.Play_WEP_UMP_Fire_3P_EndLoop',FirstPersonCue=AkEvent'WW_WEP_UMP.Play_WEP_UMP_Fire_1P_EndLoop')
    SingleFireSoundIndex=ALTFIRE_FIREMODE

    // Attachments
    bHasIronSights=true
    bHasFlashlight=true

    AssociatedPerkClasses(0)=class'KFPerk_Swat'

    // Weapon Upgrade stat boosts
    //WeaponUpgrades[1]=(IncrementDamage=1.13f,IncrementWeight=1)
    //WeaponUpgrades[2]=(IncrementDamage=1.24f,IncrementWeight=2)

	WeaponUpgrades[1]=(Stats=((Stat=EWUS_Damage0, Scale=1.13f), (Stat=EWUS_Damage1, Scale=1.13f), (Stat=EWUS_Weight, Add=1)))
	WeaponUpgrades[2]=(Stats=((Stat=EWUS_Damage0, Scale=1.24f), (Stat=EWUS_Damage1, Scale=1.24f), (Stat=EWUS_Weight, Add=2)))
}
