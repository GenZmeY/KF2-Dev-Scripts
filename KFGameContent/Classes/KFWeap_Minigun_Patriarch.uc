//=============================================================================
// KFWeap_Minigun_Patriarch
//=============================================================================
// Patriarch's minigun
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//=============================================================================

class KFWeap_Minigun_Patriarch extends KFWeap_RifleBase;

simulated function KFProjectile SpawnProjectile( class<KFProjectile> KFProjClass, vector RealStartLoc, vector AimDir )
{
	local KFProjectile	SpawnedProjectile;
	local int ProjDamage;

	// Spawn projectile
	SpawnedProjectile = Spawn( KFProjClass, Self,, RealStartLoc);
	if( SpawnedProjectile != none && !SpawnedProjectile.bDeleteMe )
	{
		// Mirror damage and damage type from weapon. This is set on the server only and
		// these properties are replicated via TakeHitInfo
		if ( InstantHitDamage.Length > CurrentFireMode && InstantHitDamageTypes.Length > CurrentFireMode )
		{
            ProjDamage = InstantHitDamage[CurrentFireMode];
            SpawnedProjectile.Damage = ProjDamage;
            SpawnedProjectile.MyDamageType = InstantHitDamageTypes[CurrentFireMode];
		}

		// Set the penetration power for this projectile
        if( SpawnedProjectile != none )
        {
			SpawnedProjectile.PenetrationPower = GetInitialPenetrationPower(CurrentFireMode);
        }

		SpawnedProjectile.Init( AimDir );
	}

	// return it up the line
	return SpawnedProjectile;
}

/** Overridden. Patriarch does not consume ammo */
simulated function ConsumeAmmo( byte FireModeNum )
{
}

/** Overridden, sprint is controlled by AI */
simulated function StopPawnSprint(bool bClearPlayerInput)
{
}

simulated state Active
{
	simulated function GotoWeaponSprinting()
	{
	}
}

/** Overridden to give the minigun more vertical spread */
simulated function rotator AddSpread(rotator BaseAim)
{
	local vector X, Y, Z;
	local float CurrentSpread, RandY, RandZ;

	CurrentSpread = Spread[CurrentFireMode];

	// Add in any spread.
	GetAxes(BaseAim, X, Y, Z);
	RandY = fRand() < 0.5f ? -fRand() : fRand();
	RandZ = fRand() < 0.5f ? -fRand() : fRand();
	return rotator( X + (RandY * CurrentSpread * Y) + (RandZ * CurrentSpread * Z) );
}

defaultproperties
{
	InventorySize=6

    // FOV
    bHidden=true
    MeshFOV=75
	MeshIronSightFOV=33
    PlayerIronSightFOV=70

	// Depth of field
	DOF_FG_FocalRadius=50
	DOF_FG_MaxNearBlurSize=3

	// Zooming/Position
	PlayerViewOffset=(X=2.0,Y=8,Z=-3)

	// Content
	WeaponContentLoaded=true

	AttachmentArchetype=KFWeaponAttachment'WEP_Patriarch_ARCH.Wep_Patriarch_Minigun_3P'

	// Ammo
	MagazineCapacity[0]=60
	SpareAmmoCapacity[0]=270
	InitialSpareMags[0]=3
	bCanBeReloaded=false//true
	bReloadFromMagazine=false//true

	// Recoil
	maxRecoilPitch=200
	minRecoilPitch=150
	maxRecoilYaw=175
	minRecoilYaw=-125
	RecoilRate=0.085
	RecoilMaxYawLimit=500
	RecoilMinYawLimit=65035
	RecoilMaxPitchLimit=900
	RecoilMinPitchLimit=65035
	RecoilISMaxYawLimit=75
	RecoilISMinYawLimit=65460
	RecoilISMaxPitchLimit=375
	RecoilISMinPitchLimit=65460
	IronSightMeshFOVCompensationScale=2.5

	// Grouping
	GroupPriority=50
	//WeaponSelectTexture=Texture2D'ui_weaponselect_tex.UI_WeaponSelect_AK12'

	// DEFAULT_FIREMODE
	FiringStatesArray(DEFAULT_FIREMODE)=WeaponFiring
	WeaponFireTypes(DEFAULT_FIREMODE)=EWFT_InstantHit
	WeaponProjectiles(DEFAULT_FIREMODE)=class'KFProj_Bullet_AssaultRifle'
	FireInterval(DEFAULT_FIREMODE)=+0.06 // 1250 RPM
	InstantHitDamageTypes(DEFAULT_FIREMODE)=class'KFDT_Ballistic_PatMinigun'
	Spread(DEFAULT_FIREMODE)=0.07
	InstantHitDamage(DEFAULT_FIREMODE)=8.0
	FireOffset=(X=32,Y=4.0,Z=-5)

	// ALT_FIREMODE
	FiringStatesArray(ALTFIRE_FIREMODE)=WeaponSingleFiring
	WeaponFireTypes(ALTFIRE_FIREMODE)=EWFT_None

	// Fire Effects
	MuzzleFlashTemplate=KFMuzzleFlash'WEP_L85A2_ARCH.Wep_L85A2_MuzzleFlash'
	WeaponFireSnd(DEFAULT_FIREMODE)=(DefaultCue=AkEvent'WW_ZED_Patriarch.Play_Mini_Gun_LP', FirstPersonCue=AkEvent'WW_ZED_Patriarch.Play_Mini_Gun_LP')
	WeaponFireSnd(ALTFIRE_FIREMODE) = (DefaultCue=AkEvent'WW_WEP_Stoner.Play_WEP_Stoner_Fire_3P_Single', FirstPersonCue=AkEvent'WW_WEP_Stoner.Play_WEP_Stoner_Fire_3P_Single')
	WeaponDryFireSnd(DEFAULT_FIREMODE)=AkEvent'WW_WEP_SA_AK12.Play_WEP_SA_AK12_Handling_DryFire'
	WeaponDryFireSnd(ALTFIRE_FIREMODE)=AkEvent'WW_WEP_SA_AK12.Play_WEP_SA_AK12_Handling_DryFire'

	// Advanced (High RPM) Fire Effects
	bLoopingFireAnim(DEFAULT_FIREMODE)=true
	bLoopingFireSnd(DEFAULT_FIREMODE)=true
	WeaponFireLoopEndSnd(DEFAULT_FIREMODE)=(DefaultCue=AkEvent'WW_ZED_Patriarch.Play_Mini_Gun_Tail', FirstPersonCue=AkEvent'WW_ZED_Patriarch.Play_Mini_Gun_Tail')
	SingleFireSoundIndex=ALTFIRE_FIREMODE

	// Attachments
	bHasIronSights=true
	bHasFlashlight=false

	AssociatedPerkClasses(0)=none

	bCanThrow=false
	bDropOnDeath=false
	bUseAnimLenEquipTime=false
}