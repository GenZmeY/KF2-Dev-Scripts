//=============================================================================
// KFWeap_Shotgun_Nailgun
//=============================================================================
// A makeshift shotgun that shoots nails
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//=============================================================================
class KFWeap_Shotgun_Nailgun extends KFWeap_ShotgunBase;

/** Animations to play when the weapon is alt fired when sighted */
var(Animations) const editconst	array<name>	AltFireSightedAnims;
/** Animation to play when the weapon is alt fired */
var(Animations) const editconst	name		AltFireAnim;

/** How much to scale recoil when alt firing */
var(Recoil) float AltFireRecoilModifier;

/*********************************************************************************************
 * State WeaponAltFiring
 * Fire must be released between every shot.
 *********************************************************************************************/

simulated state WeaponAltFiring extends WeaponSingleFiring
{
    /** Overrideen to include the DoubleFireRecoilModifier*/
    simulated function ModifyRecoil( out float CurrentRecoilModifier )
	{
		super.ModifyRecoil( CurrentRecoilModifier );
	    CurrentRecoilModifier *= AltFireRecoilModifier;
	}

	/** Initialize the weapon as being active and ready to go. */
	simulated function BeginState( Name PreviousStateName )
	{
        super.BeginState(PreviousStateName);

		// Initialize recoil blend out settings
		if( RecoilRate > 0 && RecoilBlendOutRatio > 0 )
		{
			RecoilYawBlendOutRate = ((maxRecoilYaw*AltFireRecoilModifier)/RecoilRate) * RecoilBlendOutRatio;
			RecoilPitchBlendOutRate = ((maxRecoilPitch*AltFireRecoilModifier)/RecoilRate) * RecoilBlendOutRatio;
		}
    }
}

/**
 * @see Weapon::ConsumeAmmo
 */
simulated function ConsumeAmmo( byte FireModeNum )
{
    local int AmountToConsume;

`if(`notdefined(ShippingPC))
    if( bInfiniteAmmo )
    {
        return;
    }
`endif

	// If AmmoCount is being replicated, don't allow the client to modify it here
	if ( Role == ROLE_Authority || bAllowClientAmmoTracking )
	{
		// Don't consume ammo if magazine size is 0 (infinite ammo with no reload)
		if (MagazineCapacity[GetAmmoType(FireModeNum)] > 0 && AmmoCount[GetAmmoType(FireModeNum)] > 0)
		{
			// Only consume up to the number of nails left
            AmountToConsume = Min( NumPellets[CurrentFireMode], AmmoCount[GetAmmoType(FireModeNum)] );
            AmmoCount[GetAmmoType(FireModeNum)]-=AmountToConsume;
		}
	}
}

/** Returns number of projectiles to fire from SpawnProjectile */
simulated function byte GetNumProjectilesToFire(byte FireModeNum)
{
	return Min( NumPellets[CurrentFireMode], AmmoCount[GetAmmoType(CurrentFireMode)] );
}

/** Get name of the animation to play for PlayFireEffects */
simulated function name GetWeaponFireAnim(byte FireModeNum)
{
    if( FireModeNum == DEFAULT_FIREMODE )
    {
        return super.GetWeaponFireAnim(FireModeNum);
    }

	// ironsights animations
	if ( bUsingSights )
	{
        return AltFireSightedAnims[Rand(AltFireSightedAnims.Length)];
	}
	else
	{
        return AltFireAnim;
	}
}

defaultproperties
{
    // Inventory
	InventorySize=5 //6
	GroupPriority=50
	WeaponSelectTexture=Texture2D'ui_weaponselect_tex.UI_WeaponSelect_NailShotgun'

	// Shooting Animations
	FireSightedAnims[0]=Shoot_Iron
	FireSightedAnims[1]=Shoot_Iron2
	FireSightedAnims[2]=Shoot_Iron3
	bHasFireLastAnims=false

	// Altfire Shooting Animations
	AltFireAnim=Shoot_Single
	AltFireSightedAnims[0]=Shoot_Iron_Single
//	FireSightedAnims[1]=Shoot_Iron2
//	FireSightedAnims[2]=Shoot_Iron3

    // FOV / Position
	MeshIronSightFOV=52
    PlayerIronSightFOV=70
	PlayerViewOffset=(X=10.0,Y=8,Z=-4)
	IronSightPosition=(X=12,Y=0,Z=0)

	// Content
	PackageKey="Nail_Shotgun"
	FirstPersonMeshName="WEP_1P_Nail_Shotgun_MESH.Wep_1stP_Nail_ShotGun_Rig"
	FirstPersonAnimSetNames(0)="WEP_1P_Nail_Shotgun_ANIM.Wep_1stP_Nail_Shotgun_Anim"
	PickupMeshName="WEP_3P_Nail_Shotgun_MESH.Wep_NailShotgun_Pickup""
	AttachmentArchetypeName="WEP_Nail_Shotgun_ARCH.Wep_Nail_Shotgun_3P"
	MuzzleFlashTemplateName="WEP_Nail_Shotgun_ARCH.Wep_Nail_Shotgun_MuzzleFlash"

	// DEFAULT_FIREMODE
	FireModeIconPaths(DEFAULT_FIREMODE)=Texture2D'ui_firemodes_tex.UI_FireModeSelect_NailsBurst'
	FiringStatesArray(DEFAULT_FIREMODE)=WeaponSingleFiring
	WeaponFireTypes(DEFAULT_FIREMODE)=EWFT_Projectile
	WeaponProjectiles(DEFAULT_FIREMODE)=class'KFProj_Nail_Nailgun'
	InstantHitDamage(DEFAULT_FIREMODE)=35
	InstantHitDamageTypes(DEFAULT_FIREMODE)=class'KFDT_Ballistic_NailShotgun'
	Spread(DEFAULT_FIREMODE)=0.16
	PenetrationPower(DEFAULT_FIREMODE)=3.0
	FireInterval(DEFAULT_FIREMODE)=0.3 // 200 RPM
	FireOffset=(X=30,Y=5,Z=-4)
	// Shotgun
	NumPellets(DEFAULT_FIREMODE)=7

	// ALT_FIREMODE
	FireModeIconPaths(ALTFIRE_FIREMODE)=Texture2D'ui_firemodes_tex.UI_FireModeSelect_Nail'
	FiringStatesArray(ALTFIRE_FIREMODE)=WeaponAltFiring
	WeaponFireTypes(ALTFIRE_FIREMODE)=EWFT_Projectile
	WeaponProjectiles(ALTFIRE_FIREMODE)=class'KFProj_Nail_Nailgun'
	InstantHitDamage(ALTFIRE_FIREMODE)=35
	InstantHitDamageTypes(ALTFIRE_FIREMODE)=class'KFDT_Ballistic_NailShotgun'
	Spread(ALTFIRE_FIREMODE)=0.02
	PenetrationPower(ALTFIRE_FIREMODE)=3.0
	FireInterval(ALTFIRE_FIREMODE)=0.2 // 300 RPM
	AltFireRecoilModifier=0.5
	// Shotgun
	NumPellets(ALTFIRE_FIREMODE)=1

	// BASH_FIREMODE
	InstantHitDamageTypes(BASH_FIREMODE)=class'KFDT_Bludgeon_NailShotgun'
	InstantHitDamage(BASH_FIREMODE)=26

	// Fire Effects
	WeaponFireSnd(DEFAULT_FIREMODE)=(DefaultCue=AkEvent'WW_WEP_SA_Nailgun.Play_WEP_SA_Nailgun_Fire_3P', FirstPersonCue=AkEvent'WW_WEP_SA_Nailgun.Play_WEP_SA_Nailgun_Fire_1P')
    WeaponFireSnd(ALTFIRE_FIREMODE)=(DefaultCue=AkEvent'WW_WEP_SA_Nailgun.Play_WEP_SA_Nailgun_Fire_3P', FirstPersonCue=AkEvent'WW_WEP_SA_Nailgun.Play_WEP_SA_Nailgun_Fire_1P')

	WeaponDryFireSnd(DEFAULT_FIREMODE)=AkEvent'WW_WEP_SA_Nailgun.Play_WEP_SA_Nailgun_Dryfire'
	WeaponDryFireSnd(ALTFIRE_FIREMODE)=AkEvent'WW_WEP_SA_Nailgun.Play_WEP_SA_Nailgun_Dryfire'

	// Attachments
	bHasIronSights=true
	bHasFlashlight=false

	// Ammo
	MagazineCapacity[0]=42
	SpareAmmoCapacity[0]=336
	InitialSpareMags[0]=3
	bCanBeReloaded=true
	bReloadFromMagazine=true

	// Recoil
	maxRecoilPitch=550
	minRecoilPitch=450
	maxRecoilYaw=250
	minRecoilYaw=-250
	RecoilRate=0.085
	RecoilMaxYawLimit=500
	RecoilMinYawLimit=65035
	RecoilMaxPitchLimit=900
	RecoilMinPitchLimit=64785
	RecoilISMaxYawLimit=50
	RecoilISMinYawLimit=65485
	RecoilISMaxPitchLimit=250
	RecoilISMinPitchLimit=65485
	RecoilViewRotationScale=0.6
	FallingRecoilModifier=1.5

	AssociatedPerkClasses(0)=class'KFPerk_Berserker'
	AssociatedPerkClasses(1)=class'KFPerk_Support'

	WeaponFireWaveForm=ForceFeedbackWaveform'FX_ForceFeedback_ARCH.Gunfire.Heavy_Recoil_SingleShot'

	// Weapon Upgrade stat boosts
	//WeaponUpgrades[1]=(IncrementDamage=1.2f, IncrementWeight=1)
	//WeaponUpgrades[2]=(IncrementDamage=1.25f,IncrementWeight=2)
	//WeaponUpgrades[3]=(IncrementDamage=1.4f, IncrementWeight=3)

	WeaponUpgrades[1]=(Stats=((Stat=EWUS_Damage0, Scale=1.2f), (Stat=EWUS_Damage1, Scale=1.2f), (Stat=EWUS_Weight, Add=1)))
	WeaponUpgrades[2]=(Stats=((Stat=EWUS_Damage0, Scale=1.3f), (Stat=EWUS_Damage1, Scale=1.3f), (Stat=EWUS_Weight, Add=2)))
	WeaponUpgrades[3]=(Stats=((Stat=EWUS_Damage0, Scale=1.4f), (Stat=EWUS_Damage1, Scale=1.4f), (Stat=EWUS_Weight, Add=3)))
}