//=============================================================================
// KFWeap_HRG_Dragonbreath
//=============================================================================
// Killing Floor 2
// Copyright (C) 2022 Tripwire Interactive LLC
//=============================================================================
class KFWeap_HRG_Dragonbreath extends KFWeap_ShotgunBase;

/** How much to scale recoil when firing in double barrel fire. */
var(Recoil) float QuadFireRecoilModifier;

/** Shoot animation to play when shooting both barrels from the hip */
var(Animations) const editconst	name	FireQuadAnim;

/** How much momentum to apply when fired in double barrel */
var(Recoil) float DoubleBarrelKickMomentum;

/** How much to reduce shoot momentum when falling */
var(Recoil) float FallingMomentumReduction;

var(Spread) const float SpreadWidthDegrees;
var(Spread) const float SpreadWidthDegreesAlt;

var transient float StartingPelletPosition;
var transient float StartingPelletPositionAlt;

var const float BarrelHeatPerProjectile;
var const float MaxBarrelHeat;
var const float BarrelCooldownRate;
var transient float CurrentBarrelHeat;
var transient float LastBarrelHeat;

simulated event PreBeginPlay()
{
    Super.PreBeginPlay();

    Spread[DEFAULT_FIREMODE] = SpreadWidthDegrees * DegToRad / NumPellets[DEFAULT_FIREMODE];
    Spread[ALTFIRE_FIREMODE] = SpreadWidthDegreesAlt * DegToRad / NumPellets[ALTFIRE_FIREMODE];

    StartingPelletPosition = -SpreadWidthDegrees * DegToRad / 2.0f;
    StartingPelletPositionAlt = -SpreadWidthDegreesAlt * DegToRad / 2.0f;
}

simulated event PostBeginPlay()
{
	Super.PostBeginPlay();

	// Force start with "Glow_Intensity" of 0.0f
	LastBarrelHeat = MaxBarrelHeat;
	ChangeBarrelMaterial();
}

simulated function AltFireMode()
{
	if ( !Instigator.IsLocallyControlled() )
	{
		return;
	}

	StartFire(ALTFIRE_FIREMODE);
}

/** Returns number of projectiles to fire from SpawnProjectile */
simulated function byte GetNumProjectilesToFire(byte FireModeNum)
{
	return NumPellets[CurrentFireMode];
}

/** Handle one-hand fire anims */
simulated function name GetWeaponFireAnim(byte FireModeNum)
{
	if (bUsingSights)
	{
		return FireSightedAnims[FireModeNum];
	}
	else
	{
		if (FireModeNum == ALTFIRE_FIREMODE)
		{
			return FireQuadAnim;
		}
		else
		{
			return FireAnim;
		}
	}
}

simulated function KFProjectile SpawnAllProjectiles(class<KFProjectile> KFProjClass, vector RealStartLoc, vector AimDir)
{
	local int ProjectilesToFire, i;
    local float InitialOffset;

	ProjectilesToFire = GetNumProjectilesToFire(CurrentFireMode);
	if (CurrentFireMode == GRENADE_FIREMODE || ProjectilesToFire <= 1)
	{
		return SpawnProjectile(KFProjClass, RealStartLoc, AimDir);
	}

    InitialOffset = CurrentFireMode == DEFAULT_FIREMODE ? StartingPelletPosition : StartingPelletPositionAlt;

	for (i = 0; i < ProjectilesToFire; i++)
	{
		SpawnProjectile(KFProjClass, RealStartLoc, CalculateSpread(InitialOffset, Spread[CurrentFireMode], i, CurrentFireMode == ALTFIRE_FIREMODE));
		CurrentBarrelHeat = fmin(CurrentBarrelHeat + BarrelHeatPerProjectile, MaxBarrelHeat);
	}
	
	ChangeBarrelMaterial();
	return None;
}

simulated function vector CalculateSpread(float InitialOffset, float CurrentSpread, byte PelletNum, bool bHorizontal)
{
    local Vector X, Y, Z, POVLoc;
    local Quat R;
	local rotator POVRot;

	if (Instigator != None && Instigator.Controller != none)
	{
		Instigator.Controller.GetPlayerViewPoint(POVLoc, POVRot);
	}

    GetAxes(POVRot, X, Y, Z);

    R = QuatFromAxisAndAngle(bHorizontal ? Z : Y, InitialOffset + CurrentSpread * PelletNum);
    return QuatRotateVector(R, vector(POVRot));
}

simulated function ChangeBarrelMaterial()
{
	local int i;

    if( CurrentBarrelHeat != LastBarrelHeat )
    {
    	for( i = 0; i < WeaponMICs.Length; ++i )
    	{
    		if( WeaponMICs[i] != none )
    		{
				WeaponMICs[i].SetScalarParameterValue('Barrel_intensity', CurrentBarrelHeat);
				LastBarrelHeat = CurrentBarrelHeat; 
			}
		}
    }
}

simulated function Tick(float Delta)
{
	Super.Tick(Delta);

	CurrentBarrelHeat = fmax(CurrentBarrelHeat - BarrelCooldownRate * Delta, 0.0f);
	ChangeBarrelMaterial();
}

defaultproperties
{
	// Inventory
	InventorySize=7
	GroupPriority=110
	WeaponSelectTexture=Texture2D'WEP_UI_HRG_MegaDragonsbreath_TEX.UI_WeaponSelect_HRG_MegaDragonsbreath'

    // FOV
    MeshFOV=60
	MeshIronSightFOV=52
    PlayerIronSightFOV=70

	// Depth of field
	DOF_FG_FocalRadius=65
	DOF_FG_MaxNearBlurSize=3

	// Zooming/Position
	PlayerViewOffset=(X=15.0,Y=8.0,Z=-4.5)
	IronSightPosition=(X=3,Y=0,Z=0)

	// Content
	PackageKey="HRG_MegaDragonsbreath"
	FirstPersonMeshName="wep_1p_hrg_megadragonsbreath_mesh.Wep_1stP_HRG_MegaDragonsbreath_Rig"
	FirstPersonAnimSetNames(0)="wep_1p_hrg_megadragonsbreath_anim.Wep_1stP_HRG_MegaDragonsbreath_Anim"
	PickupMeshName="wep_3p_hrg_megadragonsbreath_mesh.Wep_3rdP_HRG_MegaDragonsbreath_Pickup"
	AttachmentArchetypeName="wep_hrg_megadragonsbreath_arch.Wep_HRG_MegaDragonsbreath_3P"
	MuzzleFlashTemplateName="wep_hrg_megadragonsbreath_arch.Wep_HRG_MegaDragonsbreath_MuzzleFlash"

	// Animations
	FireAnim=Shoot_Single
	FireQuadAnim=Shoot_Double
	FireSightedAnims[0]=Shoot_Iron_Single
	FireSightedAnims[1]=Shoot_Iron_Double
    bHasFireLastAnims=false

	// DEFAULT_FIREMODE
	FireModeIconPaths(DEFAULT_FIREMODE)=Texture2D'ui_firemodes_tex.UI_FireModeSelect_ShotgunSingle'
	FiringStatesArray(DEFAULT_FIREMODE)=WeaponSingleFiring
	WeaponFireTypes(DEFAULT_FIREMODE)=EWFT_Projectile
	WeaponProjectiles(DEFAULT_FIREMODE)=class'KFProj_Pellet_HRG_Dragonbreath'
	InstantHitDamage(DEFAULT_FIREMODE)=28.0 //36
	InstantHitDamageTypes(DEFAULT_FIREMODE)=class'KFDT_Ballistic_HRG_Dragonbreath'
	PenetrationPower(DEFAULT_FIREMODE)=4.0
	FireInterval(DEFAULT_FIREMODE)=0.25 // 240 RPM
	FireOffset=(X=25,Y=3.5,Z=-4)
	NumPellets(DEFAULT_FIREMODE)=8
	Spread(DEFAULT_FIREMODE)=0
	ForceReloadTimeOnEmpty=0.3

	// ALT_FIREMODE
	FireModeIconPaths(ALTFIRE_FIREMODE)=Texture2D'ui_firemodes_tex.UI_FireModeSelect_ShotgunAuto'
	FiringStatesArray(ALTFIRE_FIREMODE)= WeaponSingleFiring
	WeaponFireTypes(ALTFIRE_FIREMODE)=EWFT_Projectile
	WeaponProjectiles(ALTFIRE_FIREMODE)=class'KFProj_Pellet_HRG_Dragonbreath'
	InstantHitDamage(ALTFIRE_FIREMODE)=28.0
	InstantHitDamageTypes(ALTFIRE_FIREMODE)=class'KFDT_Ballistic_HRG_Dragonbreath'
	PenetrationPower(ALTFIRE_FIREMODE)=4.0
	FireInterval(ALTFIRE_FIREMODE)=0.25 // 240 RPM
	NumPellets(ALTFIRE_FIREMODE)=8
	Spread(ALTFIRE_FIREMODE)=0
	AmmoCost(ALTFIRE_FIREMODE)=1
	DoubleBarrelKickMomentum=1000
	FallingMomentumReduction=0.5

	// BASH_FIREMODE
	InstantHitDamageTypes(BASH_FIREMODE)=class'KFDT_Bludgeon_HRG_Dragonbreath'
	InstantHitDamage(BASH_FIREMODE)=27

	// Fire Effects
	WeaponFireSnd(DEFAULT_FIREMODE)=(DefaultCue=AkEvent'WW_WEP_Quad_Shotgun.Play_Quad_Shotgun_Fire_3P_Single', FirstPersonCue=AkEvent'WW_WEP_Quad_Shotgun.Play_Quad_Shotgun_Fire_1P_Single') //@TODO: Replace
    WeaponFireSnd(ALTFIRE_FIREMODE)=(DefaultCue=AkEvent'WW_WEP_Quad_Shotgun.Play_Quad_Shotgun_Fire_3P_AltFire', FirstPersonCue=AkEvent'WW_WEP_Quad_Shotgun.Play_Quad_Shotgun_Fire_1P_AltFire') //@TODO: Replace

	WeaponDryFireSnd(DEFAULT_FIREMODE)=AkEvent'WW_WEP_Quad_Shotgun.Play_Quad_Shotgun_DryFire' //@TODO: Replace
	WeaponDryFireSnd(ALTFIRE_FIREMODE)=AkEvent'WW_WEP_Quad_Shotgun.Play_Quad_Shotgun_DryFire' //@TODO: Replace

	// Attachments
	bHasIronSights=true
	bHasFlashlight=false

	// Ammo
	MagazineCapacity[0]=4
	SpareAmmoCapacity[0]=60 //48 //72
	InitialSpareMags[0]=3 //8
	AmmoPickupScale[0]=2.0 //3.0
	bCanBeReloaded=true
	bReloadFromMagazine=true
	bNoMagazine=true

	// Recoil
	maxRecoilPitch=1200 //900
	minRecoilPitch=775
	maxRecoilYaw=800 //500
	minRecoilYaw=-500
	RecoilRate=0.085
	RecoilBlendOutRatio=1.1
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
	HippedRecoilModifier=1.1 //1.25
	QuadFireRecoilModifier=2.0

	AssociatedPerkClasses(0)=class'KFPerk_Firebug'

	WeaponFireWaveForm=ForceFeedbackWaveform'FX_ForceFeedback_ARCH.Gunfire.Heavy_Recoil_SingleShot'


	// Weapon Upgrade stat boosts
	//WeaponUpgrades[1]=(IncrementDamage=1.15f,IncrementWeight=1)

	WeaponUpgrades[1]=(Stats=((Stat=EWUS_Damage0, Scale=1.15f), (Stat=EWUS_Damage1, Scale=1.15f), (Stat=EWUS_Weight, Add=1)))

    SpreadWidthDegrees=7.0f
    SpreadWidthDegreesAlt=15.0f

    StartingPelletPosition=0.0f
    StartingPelletPositionAlt=0.0f

	MaxBarrelHeat=5.0f
	BarrelHeatPerProjectile=0.089f
	BarrelCooldownRate=0.45f
	
	CurrentBarrelHeat=0.0f
	LastBarrelHeat=0.0f

	NumBloodMapMaterials=3
}
