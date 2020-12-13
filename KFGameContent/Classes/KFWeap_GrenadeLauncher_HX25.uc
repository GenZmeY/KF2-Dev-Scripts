//=============================================================================
// KFWeap_GrenadeLauncher_HX25
//=============================================================================
// A Horzine experimental 25mm grenade launcher
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
// John "Ramm-Jaeger" Gibson
//=============================================================================

class KFWeap_GrenadeLauncher_HX25 extends KFWeap_GrenadeLauncher_Base;

var protected const array<vector2D> PelletSpread;

/** Last time a submunition projectile was fired from this weapon */
var float LastSubmunitionFireTime;

/*********************************************************************************************
 Firing / Projectile
********************************************************************************************* */

/** Disable normal bullet spread */
simulated function rotator AddSpread(rotator BaseAim)
{
	return BaseAim; // do nothing
}

 /** Same as AddSpread(), but used with MultiShotSpread */
static function rotator AddMultiShotSpread( rotator BaseAim, float CurrentSpread, byte PelletNum )
{
	local vector X, Y, Z;
	local float RandY, RandZ;

	if (CurrentSpread == 0)
	{
		return BaseAim;
	}
	else
	{
		// Add in any spread.
		GetAxes(BaseAim, X, Y, Z);
		RandY = default.PelletSpread[PelletNum].Y * RandRange( 0.5f, 1.5f );
		RandZ = default.PelletSpread[PelletNum].X * RandRange( 0.5f, 1.5f );
		return rotator(X + RandY * CurrentSpread * Y + RandZ * CurrentSpread * Z);
	}
}

///////////////////////////////////////////////////////////////////////////////////////////
//
// Trader
//
///////////////////////////////////////////////////////////////////////////////////////////

/** Allows weapon to calculate its own damage for display in trader
  * Overridden to multiply damage by number of pellets.
  */
static simulated function float CalculateTraderWeaponStatDamage()
{
	local float BaseDamage, DoTDamage;
	local class<KFDamageType> DamageType;

	local GameExplosion ExplosionInstance;

	ExplosionInstance = class<KFProjectile>(default.WeaponProjectiles[DEFAULT_FIREMODE]).default.ExplosionTemplate;

	BaseDamage = default.InstantHitDamage[DEFAULT_FIREMODE] + ExplosionInstance.Damage;

	DamageType = class<KFDamageType>(ExplosionInstance.MyDamageType);
	if( DamageType != none && DamageType.default.DoT_Type != DOT_None )
	{
		DoTDamage = (DamageType.default.DoT_Duration / DamageType.default.DoT_Interval) * (BaseDamage * DamageType.default.DoT_DamageScale);
	}

	return BaseDamage * default.NumPellets[DEFAULT_FIREMODE] + DoTDamage;
}

static simulated event EFilterTypeUI GetAltTraderFilter()
{
	return FT_Pistol;
}

defaultproperties
{
	ForceReloadTime=0.3f

	// Shooting Animations
	FireSightedAnims[0]=Shoot_Iron
	FireSightedAnims[1]=Shoot_Iron2
	FireSightedAnims[2]=Shoot_Iron3

	// x = 0 + r * cos(a)
	// y = 0 + r * sin(a)
	PelletSpread(0)=(X=0.f,Y=0.f)
	PelletSpread(1)=(X=0.5f,Y=0.f) 			//0deg 
	PelletSpread(2)=(X=0.3214,Y=0.3830) 	//60deg
	PelletSpread(3)=(X=-0.25,Y=0.4330)		//120deg
	PelletSpread(4)=(X=-0.5f,Y=0.f)			//180deg
	PelletSpread(5)=(X=-0.25f,Y=-0.4330)	//240deg
	PelletSpread(6)=(X=0.25,Y=-0.4330)		//300deg


	// Inventory
	InventoryGroup=IG_Secondary
	GroupPriority=25
	InventorySize=4
	WeaponSelectTexture=Texture2D'WEP_UI_HX25_Pistol_TEX.UI_WeaponSelect_HX25'

    // FOV
	MeshIronSightFOV=52
    PlayerIronSightFOV=73

	// Zooming/Position
	PlayerViewOffset=(X=13.0,Y=13,Z=-4)
	FastZoomOutTime=0.2

	// Content
	PackageKey="HX25_Pistol"
	FirstPersonMeshName="WEP_1P_HX25_Pistol_MESH.Wep_1stP_HX25_Pistol_Rig"
	FirstPersonAnimSetNames(0)="WEP_1P_HX25_Pistol_ANIM.Wep_1stP_HX25_Pistol_Anim"
	PickupMeshName="wep_3p_hx25_pistol_mesh.WEP_HX25_Pickup"
	AttachmentArchetypeName="WEP_HX25_Pistol_ARCH.Wep_HX25_Pistol_3P"
	MuzzleFlashTemplateName="WEP_HX25_Pistol_ARCH.Wep_HX25_Pistol_MuzzleFlash"

   	// Zooming/Position
	IronSightPosition=(X=0,Y=0,Z=0)

	// Ammo
	MagazineCapacity[0]=1
	SpareAmmoCapacity[0]=29
	InitialSpareMags[0]=17
	AmmoPickupScale[0]=3.0
	bCanBeReloaded=true
	bReloadFromMagazine=true

	// Recoil
	maxRecoilPitch=900
	minRecoilPitch=775
	maxRecoilYaw=500
	minRecoilYaw=-500
	RecoilRate=0.04
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
	FiringStatesArray(DEFAULT_FIREMODE)=WeaponSingleFireAndReload
	WeaponFireTypes(DEFAULT_FIREMODE)=EWFT_Projectile
	WeaponProjectiles(DEFAULT_FIREMODE)=class'KFProj_ExplosiveSubMunition_HX25'
	InstantHitDamage(DEFAULT_FIREMODE)=10.0
	InstantHitDamageTypes(DEFAULT_FIREMODE)=class'KFDT_Ballistic_HX25SubmunitionImpact'
	Spread(DEFAULT_FIREMODE)=0.1f
	FireInterval(DEFAULT_FIREMODE)=0.25
	FireOffset=(X=23,Y=4.0,Z=-3)
	// Projectile count
	NumPellets(DEFAULT_FIREMODE) = 7

	// ALT_FIREMODE
	FiringStatesArray(ALTFIRE_FIREMODE)=WeaponSingleFiring
	WeaponFireTypes(ALTFIRE_FIREMODE)=EWFT_None

	// BASH_FIREMODE
	InstantHitDamageTypes(BASH_FIREMODE)=class'KFDT_Bludgeon_HX25'
	InstantHitDamage(BASH_FIREMODE)=24

	// Fire Effects
	WeaponFireSnd(DEFAULT_FIREMODE)=(DefaultCue=AkEvent'WW_WEP_SA_HX25.Play_WEP_SA_HX25_Fire_3P', FirstPersonCue=AkEvent'WW_WEP_SA_HX25.Play_WEP_SA_HX25_Fire_1P')

	//@todo: add akevent when we have it
	WeaponDryFireSnd(DEFAULT_FIREMODE)=none

	// Animation
	bHasFireLastAnims=true

	// Attachments
	bHasIronSights=true
	bHasFlashlight=false

   	AssociatedPerkClasses(0)=class'KFPerk_Demolitionist'
   	AssociatedPerkClasses(1)=class'KFPerk_Gunslinger'

	WeaponFireWaveForm=ForceFeedbackWaveform'FX_ForceFeedback_ARCH.Gunfire.Medium_Recoil'

	// Weapon Upgrade stat boosts
	//WeaponUpgrades[1]=(IncrementDamage=1.25f,IncrementWeight=1)
	//WeaponUpgrades[2]=(IncrementDamage=1.4f,IncrementWeight=2)
	//WeaponUpgrades[3]=(IncrementDamage=1.6f,IncrementWeight=3)
	//WeaponUpgrades[4]=(IncrementDamage=1.9f,IncrementWeight=4)

	WeaponUpgrades[1]=(Stats=((Stat=EWUS_Damage0, Scale=1.25f), (Stat=EWUS_Weight, Add=1)))
	WeaponUpgrades[2]=(Stats=((Stat=EWUS_Damage0, Scale=1.4f), (Stat=EWUS_Weight, Add=2)))
	WeaponUpgrades[3]=(Stats=((Stat=EWUS_Damage0, Scale=1.6f), (Stat=EWUS_Weight, Add=3)))
	WeaponUpgrades[4]=(Stats=((Stat=EWUS_Damage0, Scale=1.9f), (Stat=EWUS_Weight, Add=4)))
}