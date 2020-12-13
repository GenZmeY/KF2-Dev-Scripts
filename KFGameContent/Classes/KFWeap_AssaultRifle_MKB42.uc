//=============================================================================
// KFWeap_AssaultRifle_MKB42
//=============================================================================
// An MKB42 Assault Rifle
//=============================================================================
// Killing Floor 2
// Copyright (C) 2017 Tripwire Interactive LLC
//=============================================================================

class KFWeap_AssaultRifle_MKB42 extends KFWeap_RifleBase;

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
	// FOV
	MeshFOV=75
	MeshIronSightFOV=33
	PlayerIronSightFOV=70

	// Depth of field
	DOF_FG_FocalRadius=50
	DOF_FG_SharpRadius=0
	DOF_FG_MinBlurSize=0
	DOF_FG_MaxNearBlurSize=3
	DOF_FG_ExpFalloff=1

	// Zooming/Position
	IronSightPosition=(X=15,Y=0,Z=0)
	PlayerViewOffset=(X=20.0,Y=8,Z=-2.5)

	// Content
	PackageKey="MKB42"
	FirstPersonMeshName="wep_1p_mkb42_mesh.Wep_1stP_MKB42_Rig"
	FirstPersonAnimSetNames(0)="wep_1p_mkb42_anim.wep_1p_mkb42_anim"
	PickupMeshName="WEP_3P_MKB42_MESH.Wep_3rdP_MKB42_Pickup"
	AttachmentArchetypeName="WEP_MKB42_ARCH.Wep_MKB42_3P"
	MuzzleFlashTemplateName="WEP_MKB42_ARCH.Wep_MKB42_MuzzleFlash" //@TODO: Replace me

	// Ammo
	MagazineCapacity[0]=30
	SpareAmmoCapacity[0]=270 //240
	InitialSpareMags[0]=3
	bCanBeReloaded=true
	bReloadFromMagazine=true

	// Recoil
	maxRecoilPitch=150  //200  //300 //200
	minRecoilPitch=100 //150   //225 //170
	maxRecoilYaw=224  //175    //262 //274
	minRecoilYaw=-224  //-175    //-262  //-274
	RecoilRate=0.11 //0.085
	//BurstFireRecoilRate=0.05
	RecoilMaxYawLimit=500
	RecoilMinYawLimit=65035
	RecoilMaxPitchLimit=900
	RecoilMinPitchLimit=65035
	RecoilISMaxYawLimit=75
	RecoilISMinYawLimit=65460
	RecoilISMaxPitchLimit=375
	RecoilISMinPitchLimit=65460
	//BurstFireRecoilModifier=0.8
	IronSightMeshFOVCompensationScale=1.5 //1.3

	// Inventory / Grouping
	InventorySize=7
	GroupPriority=75
	WeaponSelectTexture=Texture2D'WEP_UI_MKB42_TEX.UI_WeaponSelect_MKB42'

	// DEFAULT_FIREMODE
	FireModeIconPaths(DEFAULT_FIREMODE)=Texture2D'ui_firemodes_tex.UI_FireModeSelect_BulletAuto'
	FiringStatesArray(DEFAULT_FIREMODE)=WeaponFiring
	WeaponFireTypes(DEFAULT_FIREMODE)=EWFT_InstantHit
	WeaponProjectiles(DEFAULT_FIREMODE)=class'KFProj_Bullet_AssaultRifle'
	FireInterval(DEFAULT_FIREMODE)=+0.12 // 500 RPM
	InstantHitDamageTypes(DEFAULT_FIREMODE)=class'KFDT_Ballistic_MKB42'
	Spread(DEFAULT_FIREMODE)=0.0085
	InstantHitDamage(DEFAULT_FIREMODE)=50.0 //60
	FireOffset=(X=32,Y=4.0,Z=-5)

	// ALT_FIREMODE
	FireModeIconPaths(ALTFIRE_FIREMODE)=Texture2D'ui_firemodes_tex.UI_FireModeSelect_BulletSingle'
	FiringStatesArray(ALTFIRE_FIREMODE)=WeaponSingleFiring
	WeaponFireTypes(ALTFIRE_FIREMODE)=EWFT_InstantHit
	WeaponProjectiles(ALTFIRE_FIREMODE)=class'KFProj_Bullet_AssaultRifle'
	FireInterval(ALTFIRE_FIREMODE)=+0.12 // 1000 RPM
	InstantHitDamageTypes(ALTFIRE_FIREMODE)=class'KFDT_Ballistic_MKB42'
	InstantHitDamage(ALTFIRE_FIREMODE)=50.0 //60
	Spread(ALTFIRE_FIREMODE)=0.0085
	//BurstAmount=3
	//BurstFire2RdAnim=Shoot_Burst2
	//BurstFire3RdAnim=Shoot_Burst
	//BurstFire2RdSightedAnim=Shoot_Burst2_Iron
	//BurstFire3RdSightedAnim=Shoot_Burst_Iron
	//WeaponFire2RdSnd=(DefaultCue=AkEvent'WW_WEP_SA_AK12.Play_WEP_SA_AK12_Fire_2RdBurst_M', FirstPersonCue=AkEvent'WW_WEP_SA_AK12.Play_WEP_SA_AK12_Fire_2RdBurst_S') //@TODO: Replace me
	//WeaponFire3RdSnd=(DefaultCue=AkEvent'WW_WEP_SA_AK12.Play_WEP_SA_AK12_Fire_Burst_M', FirstPersonCue=AkEvent'WW_WEP_SA_AK12.Play_WEP_SA_AK12_Fire_Burst_S') //@TODO: Replace me

	// BASH_FIREMODE
	InstantHitDamageTypes(BASH_FIREMODE)=class'KFDT_Bludgeon_MKB42'
	InstantHitDamage(BASH_FIREMODE)=26

	// Fire Effects
	WeaponFireSnd(DEFAULT_FIREMODE)=(DefaultCue=AkEvent'WW_WEP_MKB42.Play_WEP_MKB42_Fire_3P_Loop', FirstPersonCue=AkEvent'WW_WEP_MKB42.Play_WEP_MKB42_Fire_1P_Loop') //@TODO: Replace me
	WeaponFireSnd(ALTFIRE_FIREMODE)=(DefaultCue=AkEvent'WW_WEP_MKB42.Play_WEP_MKB42_Fire_3P_Single', FirstPersonCue=AkEvent'WW_WEP_MKB42.Play_WEP_MKB42_Fire_1P_Single') //@TODO: Replace me
	WeaponDryFireSnd(DEFAULT_FIREMODE)=AkEvent'WW_WEP_SA_AK12.Play_WEP_SA_AK12_Handling_DryFire' //@TODO: Replace me
	WeaponDryFireSnd(ALTFIRE_FIREMODE)=AkEvent'WW_WEP_SA_AK12.Play_WEP_SA_AK12_Handling_DryFire' //@TODO: Replace me


	// Advanced (High RPM) Fire Effects
	bLoopingFireAnim(DEFAULT_FIREMODE)=true
	bLoopingFireSnd(DEFAULT_FIREMODE)=true
	WeaponFireLoopEndSnd(DEFAULT_FIREMODE)=(DefaultCue=AkEvent'WW_WEP_MKB42.Play_WEP_MKB42_Fire_3P_EndLoop', FirstPersonCue=AkEvent'WW_WEP_MKB42.Play_WEP_MKB42_Fire_1P_EndLoop') //@TODO: Replace me
	SingleFireSoundIndex=ALTFIRE_FIREMODE

	FireLoopEndLastAnim=ShootLoop_End_Last
	FireLoopEndLastSightedAnim=ShootLoop_Iron_End_Last
	bHasFireLastAnims=true

	// Attachments
	bHasIronSights=true
	bHasFlashlight=false

	AssociatedPerkClasses(0)=class'KFPerk_Commando'

	// Weapon Upgrade stat boosts
	//WeaponUpgrades[1]=(IncrementDamage=1.2f,IncrementWeight=1)
	//WeaponUpgrades[2]=(IncrementDamage=1.4f,IncrementWeight=2)

	WeaponUpgrades[1]=(Stats=((Stat=EWUS_Damage0, Scale=1.2f), (Stat=EWUS_Damage1, Scale=1.2f), (Stat=EWUS_Weight, Add=1)))
	WeaponUpgrades[2]=(Stats=((Stat=EWUS_Damage0, Scale=1.4f), (Stat=EWUS_Damage1, Scale=1.4f), (Stat=EWUS_Weight, Add=2)))
}



