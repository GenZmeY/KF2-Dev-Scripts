//=============================================================================
// KFWeap_HRG_SonicGun
//=============================================================================
// The HRG Sonic Gun weapon
//=============================================================================
// Killing Floor 2
// Copyright (C) 2020 Tripwire Interactive LLC
//=============================================================================
class KFWeap_HRG_SonicGun extends KFWeapon;

`define SONICGUN_MIC_SIGHT_INDEX 1

var(Animations) const editconst name ChargeAnim;
var(Animations) const editconst name ChargeAnimLast;
var(Animations) const editconst name ChargeAnimIron;
var(Animations) const editconst name ChargeAnimIronLast;

/** How long to wait after firing to force reload */
var()			float		ForceReloadTime;

var transient int CurrentChargeLevel;

/** Maximum times weapon can be charged */
var int MaxChargeLevel;

/** How much multiply damage does default fire projectile do by charge level*/
var	Array<float> SonicBlastDamageByChargeLevel;

/** how much multiply momentum for default fire projectile by charge level */
var Array<float> SonicBlastMomentumByChargeLevel;

/** how much multiply penetration power for default fire projectile by charge level */
var Array<float> SonicBlastPenetrationPowerByChargeLevel;

/** DamageTypes for default fire projectile by charge level*/
var	Array< class<DamageType> >	SonicBlastDamageTypeByChargeLevel;

/** Projectile classes for default fire projectile by charge level*/
var	Array< class<KFProjectile> >	SonicBlastProjectileClassByChargeLevel;

/** Sounds for default fire by charge level*/
var	Array<WeaponFireSndInfo> SonicBlastFireSoundByChargeLevel;

/** Sounds for charge */
var	Array<WeaponFireSndInfo> SonicBlastFireSoundCharge;

/** Sounds for charge sound by charge level*/
var	Array<AkEvent> ChargeSoundByChargeLevel;

/** How much momentum to apply when fired in double barrel */
var(Recoil) float FullyChargedKickMomentum;

/** How much to reduce shoot momentum when falling */
var(Recoil) float FallingMomentumReduction;

/** VFX to play from the muzzle when firing the charged shot */
var ParticleSystem MuzzleEffectDefaultFire;

/** VFX to play from the muzzle when firing the charged shot */
var ParticleSystem MuzzleEffectChargedFire;


struct MomentumMultiplierByZed
{
	var Name ZedClassName;
	var float MomentumMultiplier;
};

var array<MomentumMultiplierByZed> MomentumMultiplierByZedArray;

/** Colors for holographic sight by charge level */
var const Array<LinearColor> HolographicSightByChargeLevel;
var const Array<LinearColor> HolographicSightScanlineByChargeLevel;
var Array<bool> HolographicSightUseDefaultByChargeLevel;

simulated function PostBeginPlay()
{
    CurrentChargeLevel=0;
	if( WeaponMICs.Length > `SONICGUN_MIC_SIGHT_INDEX )
	{
		if (!HolographicSightUseDefaultByChargeLevel[0])
		{
			WeaponMICs[`SONICGUN_MIC_SIGHT_INDEX].SetVectorParameterValue('Vector_Center_Color_A', HolographicSightByChargeLevel[0]);
			WeaponMICs[`SONICGUN_MIC_SIGHT_INDEX].SetVectorParameterValue('Vector_Scanline_Color_Mult', HolographicSightScanlineByChargeLevel[0]);
		}
		else {
			WeaponMICs[`SONICGUN_MIC_SIGHT_INDEX].ClearParameterValues();
		}
	}
}
/**
 * Toggle between DEFAULT and ALTFIRE
 */
simulated function AltFireMode()
{
	// skip super

	if (!Instigator.IsLocallyControlled())
	{
		return;
	}

	StartFire(ALTFIRE_FIREMODE);
}

/** Overridded to add spawned charge to list of spawned charges */
simulated function Projectile ProjectileFire()
{
	local Projectile P;

	P = super.ProjectileFire();

	return P;
}

/** Returns animation to play based on reload type and status */
simulated function name GetReloadAnimName(bool bTacticalReload)
{
	// magazine relaod
	if (AmmoCount[0] > 0)
	{
		return (bTacticalReload) ? ReloadNonEmptyMagEliteAnim : ReloadNonEmptyMagAnim;
	}
	else
	{
		return (bTacticalReload) ? ReloadEmptyMagEliteAnim : ReloadEmptyMagAnim;
	}
}

simulated function StartFire(byte FireModeNum)
{
    if (FireModeNum == ALTFIRE_FIREMODE)
    {
        if (!IsCanIncrementCharge())
        {
            return;
        }
    }

    super.StartFire(FireModeNum);
}

/*********************************************************************************************
 * State WeaponSonicGunCharging
 * The weapon is in this state while detonating a charge
*********************************************************************************************/

simulated function GotoActiveState();

simulated state WeaponSonicGunCharging
{
	ignores AllowSprinting;

	simulated event BeginState( name PreviousStateName )
	{
		local KFPerk InstigatorPerk;

		if (!IsCanIncrementCharge())
        {
			ClearPendingFire(CurrentFireMode);
            GotoActiveState();
			return;
        }

		InstigatorPerk = GetPerk();
		if( InstigatorPerk != none )
		{
			SetZedTimeResist( InstigatorPerk.GetZedTimeModifier(self) );
		}

		IncrementChargeAndPlayAnimation();
	}

	simulated function GotoActiveState()
	{
		GotoState('Active');
	}
}

simulated state WeaponSonicGunSingleFiring extends WeaponSingleFiring
{
	simulated function BeginState(name PreviousStateName)
    {
   	    local vector UsedKickMomentum;

    	// Push the player back when they fire a fully charged sonic blast
        if (Instigator != none && CurrentChargeLevel == 1 ) //2
    	{
            UsedKickMomentum.X = -FullyChargedKickMomentum;

            if( Instigator.Physics == PHYS_Falling  )
            {
                UsedKickMomentum = UsedKickMomentum >> Instigator.GetViewRotation();
                UsedKickMomentum *= FallingMomentumReduction;
            }
            else
            {
                UsedKickMomentum = UsedKickMomentum >> Instigator.Rotation;
                UsedKickMomentum.Z = 0;
    		}

            Instigator.AddVelocity(UsedKickMomentum,Instigator.Location,none);
    	}

		//We want to do it at the end because the kickmomentum needs to use CurrentChargeLevel and this is reset in FireAmmunition
		Super.BeginState(PreviousStateName);
	}

	simulated function FireAmmunition()
	{
		super.FireAmmunition();
        CurrentChargeLevel=0;

		if( WeaponMICs.Length > `SONICGUN_MIC_SIGHT_INDEX )
		{
			if (!HolographicSightUseDefaultByChargeLevel[0])
			{
				WeaponMICs[`SONICGUN_MIC_SIGHT_INDEX].SetVectorParameterValue('Vector_Center_Color_A', HolographicSightByChargeLevel[0]);
				WeaponMICs[`SONICGUN_MIC_SIGHT_INDEX].SetVectorParameterValue('Vector_Scanline_Color_Mult', HolographicSightScanlineByChargeLevel[0]);
			}
			else
			{
				WeaponMICs[`SONICGUN_MIC_SIGHT_INDEX].ClearParameterValues();
			}
		}
	}
}

// GrenadeLaunchers determine ShouldPlayFireLast based on the spare ammo
// overriding to use the base KFWeapon version since that uses the current ammo in the mag
simulated function bool ShouldPlayFireLast(byte FireModeNum)
{
	return Super(KFWeapon).ShouldPlayFireLast(FireModeNum);
}

simulated function bool IsCanIncrementCharge()
{
    return CurrentChargeLevel < MaxChargeLevel && AmmoCount[DEFAULT_FIREMODE] > 0;
}

simulated function IncrementChargeAndPlayAnimation()
{
	local name SelectedAnim;
	local float AnimDuration;
	local bool bInSprintState;

	// choose the detonate animation based on whether it is in ironsights and whether it is the last harpoon
	if (bUsingSights)
	{
		SelectedAnim = ShouldPlayFireLast(DEFAULT_FIREMODE) ? ChargeAnimIronLast : ChargeAnimIron;
	}
	else
	{
		SelectedAnim = ShouldPlayFireLast(DEFAULT_FIREMODE) ? ChargeAnimLast : ChargeAnim;
	}

	AnimDuration = MySkelMesh.GetAnimLength(SelectedAnim);
	bInSprintState = IsInState('WeaponSprinting');

	if (WorldInfo.NetMode != NM_DedicatedServer)
	{
		if ( KFPawn(Owner).IsLocallyControlled() )
		{
			PlaySoundBase(SonicBlastFireSoundCharge[CurrentChargeLevel].FirstPersonCue);
		}

		if (bInSprintState)
		{
			AnimDuration *= 0.25f;
			PlayAnimation(SelectedAnim, AnimDuration);
		}
		else
		{	
			PlayAnimation(SelectedAnim);
		}
	}

	// Don't want to play muzzle effects or shoot animation on detonate in 3p
	//IncrementFlashCount();

	//AnimDuration value here representes the ALTFIRE FireInterval
	AnimDuration = 0.75f; //1.f;
	if (bInSprintState)
	{
		SetTimer(AnimDuration * 0.8f, false, nameof(PlaySprintStart));
	}
	else
	{
		SetTimer(AnimDuration * 0.5f, false, nameof(GotoActiveState));
	}

	CurrentChargeLevel++;
	if( WeaponMICs.Length > `SONICGUN_MIC_SIGHT_INDEX )
	{
		if (!HolographicSightUseDefaultByChargeLevel[CurrentChargeLevel])
		{
			WeaponMICs[`SONICGUN_MIC_SIGHT_INDEX].SetVectorParameterValue('Vector_Center_Color_A', HolographicSightByChargeLevel[CurrentChargeLevel]);
			WeaponMICs[`SONICGUN_MIC_SIGHT_INDEX].SetVectorParameterValue('Vector_Scanline_Color_Mult', HolographicSightScanlineByChargeLevel[CurrentChargeLevel]);
		}
		else {
			WeaponMICs[`SONICGUN_MIC_SIGHT_INDEX].ClearParameterValues();
		}
	}
}


/** Returns trader filter index based on weapon type */
static simulated event EFilterTypeUI GetTraderFilter()
{
	return FT_Explosive;
}

simulated function float GetForceReloadDelay()
{
	return fMax( ForceReloadTime - FireInterval[CurrentFireMode], 0.f );
}

//Overriding to be able to change projectile stats depending on the charge level
simulated function KFProjectile SpawnProjectile( class<KFProjectile> KFProjClass, vector RealStartLoc, vector AimDir )
{
	local KFProjectile	SpawnedProjectile;
	local int ProjDamage;

	// Spawn projectile
	SpawnedProjectile = Spawn( KFProjClass, Self,, RealStartLoc,,,true);
	if( SpawnedProjectile != none && !SpawnedProjectile.bDeleteMe )
	{
		// Mirror damage and damage type from weapon. This is set on the server only and
		// these properties are replicated via TakeHitInfo
		if ( InstantHitDamage.Length > CurrentFireMode && InstantHitDamageTypes.Length > CurrentFireMode )
		{
            InstantHitDamage[DEFAULT_FIREMODE] = SonicBlastDamageByChargeLevel[CurrentChargeLevel];
			InstantHitMomentum[DEFAULT_FIREMODE]=SonicBlastMomentumByChargeLevel[CurrentChargeLevel];
			InstantHitDamageTypes[DEFAULT_FIREMODE]=SonicBlastDamageTypeByChargeLevel[CurrentChargeLevel];

            ProjDamage = GetModifiedDamage(CurrentFireMode);
            SpawnedProjectile.Damage = ProjDamage;
            SpawnedProjectile.MyDamageType = InstantHitDamageTypes[DEFAULT_FIREMODE];
		}

		// Set the penetration power for this projectile
		// because of clientside hit detection, we need two variables --
		// one that replicates on init and one that updates but doesn't replicate
		PenetrationPower[DEFAULT_FIREMODE]=SonicBlastPenetrationPowerByChargeLevel[CurrentChargeLevel];
		SpawnedProjectile.InitialPenetrationPower = GetInitialPenetrationPower(CurrentFireMode);
		SpawnedProjectile.PenetrationPower = SpawnedProjectile.InitialPenetrationPower;

		SpawnedProjectile.UpgradeDamageMod = GetUpgradeDamageMod();
		SpawnedProjectile.Init( AimDir );
	}

	// return it up the line
	return SpawnedProjectile;
}

//Overriding to make KFProjectile Class for default fire mode to be dependant on charge level
simulated function class<KFProjectile> GetKFProjectileClass()
{
    if (CurrentFireMode == DEFAULT_FIREMODE)
    {
        return SonicBlastProjectileClassByChargeLevel[CurrentChargeLevel];
    }
    return super.GetKFProjectileClass();
}

//Overriding to get current PenetrationPower, not default.PenetrationPower
simulated function float GetUpgradedPenetration(optional int FireMode = DEFAULT_FIREMODE, optional int UpgradeIndex = INDEX_NONE)
{
	if (UpgradeIndex == INDEX_NONE)
	{
		UpgradeIndex = CurrentWeaponUpgradeIndex;
	}

	return int(GetUpgradedStatValue(PenetrationPower[FireMode], EWeaponUpgradeStat(EWUS_Penetration0 + UpgradeFireModes[FireMode]), UpgradeIndex));
}

//Overriding to change shot sounds for default fire mode to be dependant on charge level
simulated function PlayFireEffects( byte FireModeNum, optional vector HitLocation )
{
	WeaponFireSnd[DEFAULT_FIREMODE]=SonicBlastFireSoundByChargeLevel[CurrentChargeLevel];
	super.PlayFireEffects(FireModeNum, HitLocation);
}

simulated function ProcessInstantHitEx(byte FiringMode, ImpactInfo Impact, optional int NumHits, optional out float out_PenetrationVal, optional int ImpactNum )
{
	local KFPerk InstigatorPerk;
	local int IndexMomentumMultiplierByZed;

	InstigatorPerk = GetPerk();
	if( InstigatorPerk != none )
	{
		InstigatorPerk.UpdatePerkHeadShots( Impact, InstantHitDamageTypes[FiringMode], ImpactNum );
	}

	//Modifying momentum by zed impacted
	if (Impact.HitActor != None && KFPawn_Monster(Impact.HitActor) != None)
	{
		IndexMomentumMultiplierByZed = MomentumMultiplierByZedArray.Find('ZedClassName', Impact.HitActor.Class.Name);
		if (IndexMomentumMultiplierByZed != INDEX_NONE)
		{
			InstantHitMomentum[DEFAULT_FIREMODE] *= MomentumMultiplierByZedArray[IndexMomentumMultiplierByZed].MomentumMultiplier;
		}
	}

	super.ProcessInstantHitEx( FiringMode, Impact, NumHits, out_PenetrationVal, ImpactNum );
}

simulated function CauseMuzzleFlash(byte FireModeNum)
{
	if (MuzzleFlash == None)
	{
		AttachMuzzleFlash();
	}

	if (CurrentChargeLevel > 0)
	{
		MuzzleFlash.MuzzleFlash.ParticleSystemTemplate = MuzzleEffectChargedFire;
		MuzzleFlash.MuzzleFlash.PSC.SetTemplate(MuzzleEffectChargedFire);
	}
	else
	{
		MuzzleFlash.MuzzleFlash.ParticleSystemTemplate = MuzzleEffectDefaultFire;
		MuzzleFlash.MuzzleFlash.PSC.SetTemplate(MuzzleEffectDefaultFire);
	}

	super.CauseMuzzleFlash(FireModeNum);
}

defaultproperties
{
	// Content
	PackageKey="HRG_SonicGun"
	FirstPersonMeshName="wep_1p_hrg_sonicgun_mesh.WEP_1stP_HRG_SonicGun_Rig"
	FirstPersonAnimSetNames(0)="wep_1p_hrg_sonicgun_anim.Wep_1stP_HRG_SonicGun_Anim"
	PickupMeshName="wep_3p_hrg_sonicgun_mesh.WEP_3rdP_HRG_SonicGun_Pickup"
	AttachmentArchetypeName="wep_hrg_sonicgun_arch.Wep_HRG_SonicGun_3P"
	MuzzleFlashTemplateName="WEP_HRG_SonicGun_ARCH.Wep_HRG_SonicGun_MuzzleFlash"

	// Inventory / Grouping
	InventorySize=7
	GroupPriority=75
	WeaponSelectTexture=Texture2D'WEP_UI_HRG_SonicGun_TEX.UI_WeaponSelect_HRG_SonicGun'
   	AssociatedPerkClasses(0)=class'KFPerk_Sharpshooter'

    // FOV
    MeshFOV=75
	MeshIronSightFOV=40
    PlayerIronSightFOV=65

	// Depth of field
	DOF_FG_FocalRadius=50
	DOF_FG_MaxNearBlurSize=3.5

	// Ammo
	MagazineCapacity[0]=12 //8
	SpareAmmoCapacity[0]=96 //72
	InitialSpareMags[0]=1
	bCanBeReloaded=true
	bReloadFromMagazine=true

	// Zooming/Position
	PlayerViewOffset=(X=11.0,Y=8,Z=-2)
	IronSightPosition=(X=10,Y=-0.1,Z=-0.2)

	// AI warning system
	bWarnAIWhenAiming=true
	AimWarningDelay=(X=0.4f, Y=0.8f)
	AimWarningCooldown=0.0f

	// Recoil
	maxRecoilPitch=200 //500
	minRecoilPitch=150 //400
	maxRecoilYaw=50 //150
	minRecoilYaw=-50 //-150
	RecoilRate=0.08
	RecoilMaxYawLimit=500
	RecoilMinYawLimit=65035
	RecoilMaxPitchLimit=1250
	RecoilMinPitchLimit=64785
	RecoilISMaxYawLimit=50
	RecoilISMinYawLimit=65485
	RecoilISMaxPitchLimit=500
	RecoilISMinPitchLimit=65485
	RecoilViewRotationScale=0.6
	IronSightMeshFOVCompensationScale=1.5

	// DEFAULT_FIREMODE
	FireModeIconPaths(DEFAULT_FIREMODE)=Texture2D'ui_firemodes_tex.UI_FireModeSelect_BulletSingle'
	FiringStatesArray(DEFAULT_FIREMODE)=WeaponSonicGunSingleFiring
	WeaponFireTypes(DEFAULT_FIREMODE)=EWFT_Projectile
	WeaponProjectiles(DEFAULT_FIREMODE)=class'KFProj_SonicBlastUncharged_HRG_SonicGun'
	InstantHitDamage(DEFAULT_FIREMODE)=125
	InstantHitDamageTypes(DEFAULT_FIREMODE)=class'KFDT_Ballistic_HRG_SonicGun_SonicBlastUncharged'
	InstantHitMomentum(DEFAULT_FIREMODE)=200000
	FireInterval(DEFAULT_FIREMODE)=0.5 //0.75
	Spread(DEFAULT_FIREMODE)=0.005
	PenetrationPower(DEFAULT_FIREMODE)=2.0
	FireOffset=(X=25,Y=3.0,Z=-2.5)
	FullyChargedKickMomentum=0 //1000
	FallingMomentumReduction=0.5

	// ALTFIRE_FIREMODE (remote detonate)
	FiringStatesArray(ALTFIRE_FIREMODE)=WeaponSonicGunCharging
	WeaponFireTypes(ALTFIRE_FIREMODE)=EWFT_Custom
	AmmoCost(ALTFIRE_FIREMODE)=0

	// BASH_FIREMODE
	InstantHitDamageTypes(BASH_FIREMODE)=class'KFDT_Bludgeon_HRG_SonicGun'
	InstantHitDamage(BASH_FIREMODE)=26

	// Custom animations
	FireSightedAnims=(Shoot_Iron, Shoot_Iron2, Shoot_Iron3)
	BonesToLockOnEmpty=(RW_BoltAssembly1, RW_BoltAssembly2, RW_BoltAssembly3)
	bHasFireLastAnims=true

	// Fire Effects
	WeaponFireSnd(DEFAULT_FIREMODE)=(DefaultCue=AkEvent'WW_WEP_HRG_SonicGun.Play_WEP_HRG_SonicGun_3P_Fire_Bass', FirstPersonCue=AkEvent'WW_WEP_HRG_SonicGun.Play_WEP_HRG_SonicGun_1P_Fire_Bass')
	WeaponDryFireSnd(DEFAULT_FIREMODE)=AkEvent'WW_WEP_HRG_SonicGun.Play_WEP_HRG_SonicGun_DryFire'
	EjectedShellForegroundDuration=1.5f

	// Attachments
	bHasIronSights=true
	bHasFlashlight=false

	WeaponFireWaveForm=ForceFeedbackWaveform'FX_ForceFeedback_ARCH.Gunfire.Medium_Recoil'

	ChargeAnim=Alt_Fire
	ChargeAnimLast=Alt_Fire_Last
	ChargeAnimIron=Alt_Fire_Iron
	ChargeAnimIronLast=Alt_Fire_Iron_Last

	WeaponUpgrades[1]=(Stats=((Stat=EWUS_Damage0, Scale=1.15f), (Stat=EWUS_Weight, Add=1)))
	WeaponUpgrades[2]=(Stats=((Stat=EWUS_Damage0, Scale=1.3f), (Stat=EWUS_Weight, Add=2)))

    ForceReloadTime=0.3
    bAllowClientAmmoTracking=true
    AimCorrectionSize=0.f

	MuzzleEffectDefaultFire=ParticleSystem'WEP_HRG_SonicGun_EMIT.FX_SonicGun_Muzzle'
	MuzzleEffectChargedFire=ParticleSystem'WEP_HRG_SonicGun_EMIT.FX_SonicGun_Muzzle_AltFire'
    
	SonicBlastDamageByChargeLevel(0)=110 //100
    //SonicBlastDamageByChargeLevel(1)=170 //160
    SonicBlastDamageByChargeLevel(1)=280 //310 //280

    SonicBlastPenetrationPowerByChargeLevel(0)=4.0
    //SonicBlastPenetrationPowerByChargeLevel(1)=3.0 //1.0
    SonicBlastPenetrationPowerByChargeLevel(1)=2.0 //0.0

	SonicBlastMomentumByChargeLevel(0)=100000 //80000 //60000
    //SonicBlastMomentumByChargeLevel(1)=50000 //40000
    SonicBlastMomentumByChargeLevel(1)=40000 //20000

    SonicBlastDamageTypeByChargeLevel(0)=class'KFDT_Ballistic_HRG_SonicGun_SonicBlastUncharged'
    //SonicBlastDamageTypeByChargeLevel(1)=class'KFDT_Ballistic_HRG_SonicGun_SonicBlastHalfCharged'
    SonicBlastDamageTypeByChargeLevel(1)=class'KFDT_Ballistic_HRG_SonicGun_SonicBlastFullyCharged'

    SonicBlastProjectileClassByChargeLevel(0)=class'KFProj_SonicBlastUncharged_HRG_SonicGun'
    //SonicBlastProjectileClassByChargeLevel(1)=class'KFProj_SonicBlastHalfCharged_HRG_SonicGun'
    SonicBlastProjectileClassByChargeLevel(1)=class'KFProj_SonicBlastFullyCharged_HRG_SonicGun'

    SonicBlastFireSoundByChargeLevel(0)=(DefaultCue=AkEvent'WW_WEP_HRG_SonicGun.Play_WEP_HRG_SonicGun_3P_Fire_Bass', FirstPersonCue=AkEvent'WW_WEP_HRG_SonicGun.Play_WEP_HRG_SonicGun_1P_Fire_Bass')
    //SonicBlastFireSoundByChargeLevel(1)=(DefaultCue=AkEvent'WW_WEP_HRG_SonicGun.Play_WEP_HRG_SonicGun_3P_Fire_Mid', FirstPersonCue=AkEvent'WW_WEP_HRG_SonicGun.Play_WEP_HRG_SonicGun_1P_Fire_Mid')
    SonicBlastFireSoundByChargeLevel(1)=(DefaultCue=AkEvent'WW_WEP_HRG_SonicGun.Play_WEP_HRG_SonicGun_3P_Fire_High', FirstPersonCue=AkEvent'WW_WEP_HRG_SonicGun.Play_WEP_HRG_SonicGun_1P_Fire_High')

	SonicBlastFireSoundCharge(0)=(DefaultCue=AkEvent'WW_WEP_HRG_SonicGun.Play_WEP_HRG_SonicGun_Charge_Once', FirstPersonCue=AkEvent'WW_WEP_HRG_SonicGun.Play_WEP_HRG_SonicGun_Charge_Once')
	SonicBlastFireSoundCharge(1)=(DefaultCue=AkEvent'WW_WEP_HRG_SonicGun.Play_WEP_HRG_SonicGun_Charge_Twice', FirstPersonCue=AkEvent'WW_WEP_HRG_SonicGun.Play_WEP_HRG_SonicGun_Charge_Twice')


    ChargeSoundByChargeLevel(0)=AkEvent'WW_WEP_Seeker_6.Play_Seeker_6_Reload_1'
    ChargeSoundByChargeLevel(1)=AkEvent'WW_WEP_Lazer_Cutter.Play_WEP_LaserCutter_Handling_Equip'
	//AkEvent'WW_WEP_Helios.Play_WEP_Helios_Handling_Equip'

    MaxChargeLevel=1 //2

	MomentumMultiplierByZedArray(0)=(ZedClassName="KFPawn_ZedClot_Cyst", MomentumMultiplier=1.0)
	MomentumMultiplierByZedArray(1)=(ZedClassName="KFPawn_ZedClot_Alpha", MomentumMultiplier=1.0)
	MomentumMultiplierByZedArray(2)=(ZedClassName="KFPawn_ZedClot_Slasher", MomentumMultiplier=1.0)
	MomentumMultiplierByZedArray(3)=(ZedClassName="KFPawn_ZedCrawler", MomentumMultiplier=1.0)
	MomentumMultiplierByZedArray(4)=(ZedClassName="KFPawn_ZedGorefast", MomentumMultiplier=1.2)
	MomentumMultiplierByZedArray(5)=(ZedClassName="KFPawn_ZedStalker", MomentumMultiplier=1.0)
	MomentumMultiplierByZedArray(6)=(ZedClassName="KFPawn_ZedScrake", MomentumMultiplier=1.2)
	MomentumMultiplierByZedArray(7)=(ZedClassName="KFPawn_ZedFleshpound", MomentumMultiplier=1.3)
	MomentumMultiplierByZedArray(8)=(ZedClassName="KFPawn_ZedFleshpoundMini", MomentumMultiplier=1.3)
	MomentumMultiplierByZedArray(9)=(ZedClassName="KFPawn_ZedBloat", MomentumMultiplier=1.7)
	MomentumMultiplierByZedArray(10)=(ZedClassName="KFPawn_ZedSiren", MomentumMultiplier=0.8)
	MomentumMultiplierByZedArray(11)=(ZedClassName="KFPawn_ZedHusk", MomentumMultiplier=0.8)
	MomentumMultiplierByZedArray(12)=(ZedClassName="KFPawn_ZedClot_AlphaKing", MomentumMultiplier=1.0) //elite clot
	MomentumMultiplierByZedArray(13)=(ZedClassName="KFPawn_ZedCrawlerKing", MomentumMultiplier=1.0) //elite crawler
	MomentumMultiplierByZedArray(14)=(ZedClassName="KFPawn_ZedGorefastDualBlade", MomentumMultiplier=1.3) //elite gorefast
	MomentumMultiplierByZedArray(15)=(ZedClassName="KFPawn_ZedDAR_EMP", MomentumMultiplier=1.4)
	MomentumMultiplierByZedArray(16)=(ZedClassName="KFPawn_ZedDAR_Laser", MomentumMultiplier=1.4)
	MomentumMultiplierByZedArray(17)=(ZedClassName="KFPawn_ZedDAR_Rocket", MomentumMultiplier=1.4)

	MomentumMultiplierByZedArray(18)=(ZedClassName="KFPawn_ZedBloatKingSubspawn", MomentumMultiplier=1.0)

	MomentumMultiplierByZedArray(19)=(ZedClassName="KFPawn_ZedHans", MomentumMultiplier=1.2)
	MomentumMultiplierByZedArray(20)=(ZedClassName="KFPawn_ZedPatriarch", MomentumMultiplier=1.2)
	MomentumMultiplierByZedArray(21)=(ZedClassName="KFPawn_ZedFleshpoundKing", MomentumMultiplier=1.2)
	MomentumMultiplierByZedArray(22)=(ZedClassName="KFPawn_ZedBloatKing", MomentumMultiplier=1.2)
	MomentumMultiplierByZedArray(23)=(ZedClassName="KFPawn_ZedMatriarch", MomentumMultiplier=1.2)

	//If no set any of the following colors, the default color from the material will be used
	HolographicSightByChargeLevel(0)=(R=0.88f,G=0.36f,B=0.11f, A=0.92f)
	HolographicSightByChargeLevel(1)=(R=0.27f,G=0.5f,B=2.35f, A=0.92f)
	HolographicSightScanlineByChargeLevel(0)=(R=0.5f,G=0.96f,B=0.96f, A=0.92f)
	HolographicSightScanlineByChargeLevel(1)=(R=0.88f,G=0.36f,B=0.11f, A=0.92f)

	HolographicSightUseDefaultByChargeLevel(0)=false
	HolographicSightUseDefaultByChargeLevel(1)=false

	NumBloodMapMaterials=2
}