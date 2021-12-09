//=============================================================================
// KFWeap_Rifle_ParasiteImplanter
//=============================================================================
// Weapon code for parasite implanter.
//=============================================================================
// Killing Floor 2
// Copyright (C) 2021 Tripwire Interactive LLC
//=============================================================================

class KFWeap_Rifle_ParasiteImplanter extends KFWeap_ScopedBase;

`define PARASITE_MIC_LED_INDEX 0

var float LastFireInterval;

/** How many seed ammo to recharge per second */
var float SeedFullRechargeSeconds;
/** How many ammo to recharge per second. */
var transient float SeedRechargePerSecond;

var transient float SeedIncrement;
var repnotify byte SeedAmmo;

const SecondaryFireAnim     = 'Shoot_Secondary';
const SecondaryFireIronAnim = 'Shoot_Secondary_Iron';

/** Material colors applied to different fire modes */
var LinearColor NoAmmoMaterialColor;
var LinearColor AmmoReadyMaterialColor;

/** How much recoil the altfire should do */
var protected const float AltFireRecoilScale;

replication
{
	if (bNetDirty && Role == ROLE_Authority)
		SeedAmmo;
}

simulated event ReplicatedEvent(name VarName)
{
	if (VarName == nameof(SeedAmmo))
	{
		if (AmmoCount[ALTFIRE_FIREMODE] < AmmoCost[ALTFIRE_FIREMODE] && SeedAmmo >= AmmoCost[ALTFIRE_FIREMODE])
		{
			UpdateMaterial(true);
		}
		else if (AmmoCount[ALTFIRE_FIREMODE] >= AmmoCost[ALTFIRE_FIREMODE] && SeedAmmo < AmmoCost[ALTFIRE_FIREMODE])
		{
			UpdateMaterial(false);
		}
		AmmoCount[ALTFIRE_FIREMODE] = SeedAmmo;
	}
	else
	{
		Super.ReplicatedEvent(VarName);
	}
}

/*********************************************************************************************
 * @name	Trader
 *********************************************************************************************/

/** Returns trader filter index based on weapon type */
static simulated event EFilterTypeUI GetTraderFilter()
{
	if( default.FiringStatesArray[DEFAULT_FIREMODE] == 'WeaponFiring' || default.FiringStatesArray[DEFAULT_FIREMODE] == 'WeaponBurstFiring' )
	{
		return FT_Assault;
	}
	else // if( FiringStatesArray[DEFAULT_FIREMODE] == 'WeaponSingleFiring')
	{
		return FT_Rifle;
	}
}

simulated event PreBeginPlay()
{
	super.PreBeginPlay();
	StartSeedRecharge();
} 

function StartSeedRecharge()
{
	// local KFPerk InstigatorPerk;
	local float UsedSeedRechargeTime;

	// begin ammo recharge on server
	if( Role == ROLE_Authority )
	{
		UsedSeedRechargeTime = SeedFullRechargeSeconds;
	    SeedRechargePerSecond = MagazineCapacity[ALTFIRE_FIREMODE] / UsedSeedRechargeTime;
		SeedIncrement = 0;
	}
}

function RechargeSeed(float DeltaTime)
{
	if ( Role == ROLE_Authority )
	{
		SeedIncrement += SeedRechargePerSecond * DeltaTime;

		if( SeedIncrement >= 1.0 && AmmoCount[ALTFIRE_FIREMODE] < MagazineCapacity[ALTFIRE_FIREMODE] )
		{
			AmmoCount[ALTFIRE_FIREMODE]++;
			SeedIncrement -= 1.0;
			SeedAmmo = AmmoCount[ALTFIRE_FIREMODE];
		}
	}
}

/** Overridden to call StartHealRecharge on server */
function GivenTo( Pawn thisPawn, optional bool bDoNotActivate )
{
	super.GivenTo( thisPawn, bDoNotActivate );

	if( Role == ROLE_Authority && !thisPawn.IsLocallyControlled() )
	{
		StartSeedRecharge();
	}
}
/*********************************************************************************************
 @name Actor
********************************************************************************************* */
simulated event Tick( FLOAT DeltaTime )
{
	local bool bWasLowAmmo;
	bWasLowAmmo = AmmoCount[ALTFIRE_FIREMODE] < AmmoCost[ALTFIRE_FIREMODE];

    if( AmmoCount[ALTFIRE_FIREMODE] < MagazineCapacity[ALTFIRE_FIREMODE] )
	{
        RechargeSeed(DeltaTime);
	}

	if (WorldInfo.NetMode != NM_DedicatedServer)
	{
		if (bWasLowAmmo && AmmoCount[ALTFIRE_FIREMODE] >= AmmoCost[ALTFIRE_FIREMODE])
		{
			UpdateMaterial(true);
		}
	}
	else
	{
		if (bWasLowAmmo && AmmoCount[ALTFIRE_FIREMODE] >= AmmoCost[ALTFIRE_FIREMODE])
		{
			NotifyAltAmmoReady(true);
		}
	}

	Super.Tick(DeltaTime);
}

/*********************************************************************************************
 * Trader
 ********************************************************************************************/

/** Allows weapon to set its own trader stats (can set number of stats, names and values of stats) */
static simulated event SetTraderWeaponStats( out array<STraderItemWeaponStats> WeaponStats )
{
	super.SetTraderWeaponStats( WeaponStats );

	WeaponStats.Length = WeaponStats.Length + 1;
	WeaponStats[WeaponStats.Length-1].StatType = TWS_RechargeTime;
	WeaponStats[WeaponStats.Length-1].StatValue = default.SeedFullRechargeSeconds;
}

/** Seeds doesn't count as ammo for purposes of inventory management (e.g. switching) */
simulated function bool HasAnyAmmo()
{
	return HasSpareAmmo() || HasAmmo(DEFAULT_FIREMODE);
}

simulated function ConsumeAmmo( byte FireModeNum )
{
	local bool bWasHighAmmo;

    if( FireModeNum != ALTFIRE_FIREMODE )
    {
        Super.ConsumeAmmo(FireModeNum);
        return;
    }

`if(`notdefined(ShippingPC))
    if( bInfiniteAmmo )
    {
        return;
    }
`endif

	bWasHighAmmo = AmmoCount[ALTFIRE_FIREMODE] >= AmmoCost[ALTFIRE_FIREMODE];

	// If AmmoCount is being replicated, don't allow the client to modify it here
	if (Role == ROLE_Authority)
	{
        // Don't consume ammo if magazine size is 0 (infinite ammo with no reload)
		if (MagazineCapacity[1] > 0 && AmmoCount[1] > 0)
		{
			// Reduce ammo amount by heal ammo cost
            AmmoCount[1] = Max(AmmoCount[1] - AmmoCost[1], 0);
		}
	}

	if (WorldInfo.NetMode != NM_DedicatedServer)
	{
		if (bWasHighAmmo && AmmoCount[ALTFIRE_FIREMODE] < AmmoCost[ALTFIRE_FIREMODE])
		{
			UpdateMaterial(false);
		}
	}
	else if (bWasHighAmmo && AmmoCount[ALTFIRE_FIREMODE] < AmmoCost[ALTFIRE_FIREMODE])
	{
		NotifyAltAmmoReady(false);
	}
}

/** Instead of switch fire mode use as immediate alt fire */
simulated function AltFireMode()
{
	if ( !Instigator.IsLocallyControlled() )
	{
		return;
	}

	StartFire(ALTFIRE_FIREMODE);
}

simulated function float GetFireInterval(byte FireModeNum)
{
	if (FireModeNum == DEFAULT_FIREMODE && AmmoCount[FireModeNum] == 0)
	{
		return LastFireInterval;
	}

	return super.GetFireInterval(FireModeNum);
}

simulated function name GetWeaponFireAnim(byte FireModeNum)
{
	if (FireModeNum == ALTFIRE_FIREMODE)
	{
		return bUsingSights ? SecondaryFireIronAnim : SecondaryFireAnim;
	}

	return super.GetWeaponFireAnim(FireModeNum);
}

simulated function UpdateMaterial(bool HasEnoughAmmo)
{
	local LinearColor MatColor;
	
	if (WorldInfo.NetMode != NM_DedicatedServer)
	{
		MatColor = HasEnoughAmmo ? AmmoReadyMaterialColor : NoAmmoMaterialColor;

		if( WeaponMICs.Length >= `PARASITE_MIC_LED_INDEX )
		{
			WeaponMICs[`PARASITE_MIC_LED_INDEX].SetVectorParameterValue('Vector_GlowColor', MatColor);
		}
	}
}

/**
	Should replicate to 3P to show the alt fire ready
 */
simulated function NotifyAltAmmoReady(bool bActive)
{
	local KFPawn KFP;

	if (WorldInfo.NetMode != NM_Client)
	{
		KFP = KFPawn(Instigator);
		KFP.OnWeaponSpecialAction(bActive ? 2 : 1);
	}
}

simulated function ModifyRecoil( out float CurrentRecoilModifier )
{
	if( CurrentFireMode == ALTFIRE_FIREMODE )
	{
		CurrentRecoilModifier *= AltFireRecoilScale;
	}

	super.ModifyRecoil( CurrentRecoilModifier );
}

simulated function bool ShouldAutoReload(byte FireModeNum)
{
	if (FireModeNum == ALTFIRE_FIREMODE)
		return false;
	
	return super.ShouldAutoReload(FireModeNum);
}

defaultproperties
{
	SeedFullRechargeSeconds=14 //10
	
	// Inventory / Grouping
	InventorySize=7
	GroupPriority=100
	WeaponSelectTexture=Texture2D'wep_ui_parasiteimplanter_tex.UI_WeaponSelect_ParasiteImplanter'
   	AssociatedPerkClasses(0)=class'KFPerk_FieldMedic'
   	AssociatedPerkClasses(1)=class'KFPerk_SharpShooter'

    // FOV
    MeshFOV=70 //65
	MeshIronSightFOV=27 //25 //45
    PlayerIronSightFOV=70 //65

	// Depth of field
	DOF_BlendInSpeed=3.0
	DOF_FG_FocalRadius=0 //50
	DOF_FG_MaxNearBlurSize=3.5

	// Content
	PackageKey="ParasiteImplanter"
	FirstPersonMeshName="WEP_1P_ParasiteImplanter_MESH.Wep_1stP_ParasiteImplanter_Rig"
	FirstPersonAnimSetNames(0)="WEP_1P_ParasiteImplanter_ANIM.Wep_1stP_ParasiteImplanter_Anim"
	PickupMeshName="WEP_3P_ParasiteImplanter_MESH.Wep_3rdP_ParasiteImplanter_Pickup"
	AttachmentArchetypeName="WEP_ParasiteImplanter_ARCH.Wep_ParasiteImplanter_3P"
	MuzzleFlashTemplateName="WEP_ParasiteImplanter_ARCH.Wep_ParasiteImplanter_MuzzleFlash"

	// Ammo
	MagazineCapacity[0]=6
	SpareAmmoCapacity[0]=78
	InitialSpareMags[0]=3
	bCanBeReloaded=true
	bReloadFromMagazine=true
	
	MagazineCapacity[1]=100
	SeedAmmo=100
	bCanRefillSecondaryAmmo=false

	// Zooming/Position
	PlayerViewOffset=(X=3.0,Y=8,Z=-1.8)
	//IronSightPosition=(X=0,Y=-0.07,Z=1.03)
	IronSightPosition=(X=0,Y=-0.09,Z=1.042)

	// AI warning system
	bWarnAIWhenAiming=true
	AimWarningDelay=(X=0.4f, Y=0.8f)
	AimWarningCooldown=0.0f

	// Recoil
	maxRecoilPitch=575 //700
	minRecoilPitch=425 //600
	maxRecoilYaw=135
	minRecoilYaw=-135
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
	AltFireRecoilScale=0.2f

	// Scope Render
  	// 2D scene capture
	Begin Object Name=SceneCapture2DComponent0
	   //TextureTarget=TextureRenderTarget2D'Wep_Mat_Lib.WEP_ScopeLense_Target'
	   FieldOfView=12.5 //23.0 // "1.5X" = 35.0(our real world FOV determinant)/1.5
	End Object

    ScopedSensitivityMod=8.0 //16.0
	ScopeLenseMICTemplate=MaterialInstanceConstant'WEP_1P_ParasiteImplanter_MAT.Wep_1stP_Parasite_Lens_MIC'
	ScopeMICIndex = 2

	// DEFAULT_FIREMODE
	FireModeIconPaths(DEFAULT_FIREMODE)=Texture2D'ui_firemodes_tex.UI_FireModeSelect_BulletSingle'
	FiringStatesArray(DEFAULT_FIREMODE)=WeaponSingleFiring
	WeaponFireTypes(DEFAULT_FIREMODE)=EWFT_InstantHit
	WeaponProjectiles(DEFAULT_FIREMODE)=class'KFProj_Bullet_ParasiteImplanter'
	InstantHitDamage(DEFAULT_FIREMODE)=275 //250 
	InstantHitDamageTypes(DEFAULT_FIREMODE)=class'KFDT_Ballistic_ParasiteImplanter'
	FireInterval(DEFAULT_FIREMODE)=+1.0 //60 RPM
    Spread(DEFAULT_FIREMODE)=0.005
	PenetrationPower(DEFAULT_FIREMODE)=3
	FireOffset=(X=25,Y=3.0,Z=-2.5)
	LastFireInterval=0.3

	// ALT_FIREMODE
	FiringStatesArray(ALTFIRE_FIREMODE)=WeaponSingleFiring
	WeaponFireTypes(ALTFIRE_FIREMODE)=EWFT_Projectile
	FireInterval(ALTFIRE_FIREMODE)=+0.5 //+1.0 //+0.175
	InstantHitDamage(ALTFIRE_FIREMODE)=1.0
	Spread(ALTFIRE_FIREMODE)=0.005
	AmmoCost(ALTFIRE_FIREMODE)=50
	WeaponProjectiles(ALTFIRE_FIREMODE)=class'KFProj_Bullet_ParasiteImplanterAlt'
	InstantHitDamageTypes(ALTFIRE_FIREMODE)=class'KFDT_Ballistic_ParasiteImplanterAlt'
	SecondaryAmmoTexture=Texture2D'ui_firemodes_tex.UI_FireModeSelect_Electricity'

	// BASH_FIREMODE
	InstantHitDamageTypes(BASH_FIREMODE)=class'KFDT_Bludgeon_ParasiteImplanter'
	InstantHitDamage(BASH_FIREMODE)=26

	// Custom animations
	FireSightedAnims=(Shoot_Iron)
	BonesToLockOnEmpty=(RW_Hammer)
	bHasFireLastAnims=true

	// Fire Effects
	WeaponFireSnd(DEFAULT_FIREMODE)=(DefaultCue=AkEvent'WW_WEP_ParasiteImplanter.Play_WEP_ParasiteImplanter_3P_Rifle', FirstPersonCue=AkEvent'WW_WEP_ParasiteImplanter.Play_WEP_ParasiteImplanter_1P_Rifle')
	WeaponDryFireSnd(DEFAULT_FIREMODE)=AkEvent'WW_WEP_ParasiteImplanter.Play_WEP_ParasiteImplanter_Dry_Fire_Rifle'
	WeaponFireSnd(ALTFIRE_FIREMODE)=(DefaultCue=AkEvent'WW_WEP_ParasiteImplanter.Play_WEP_ParasiteImplanter_3P_Altfire', FirstPersonCue=AkEvent'WW_WEP_ParasiteImplanter.Play_WEP_ParasiteImplanter_1P_Altfire')
	WeaponDryFireSnd(ALTFIRE_FIREMODE)=AkEvent'WW_WEP_ParasiteImplanter.Play_WEP_ParasiteImplanter_Dry_Fire_Altfire'
	EjectedShellForegroundDuration=1.5f

	// Attachments
	bHasIronSights=true
	bHasFlashlight=false

	WeaponFireWaveForm=ForceFeedbackWaveform'FX_ForceFeedback_ARCH.Gunfire.Medium_Recoil'

	WeaponUpgrades[1]=(Stats=((Stat=EWUS_Damage0, Scale=1.15f), (Stat=EWUS_Weight, Add=1)))

	// From original KFWeap_RifleBase base class
	AimCorrectionSize=40.f

	NoAmmoMaterialColor=(R=0.0f,G=0.0f,B=0.0f)
    AmmoReadyMaterialColor=(R=0.08f,G=1.0f,B=0.08f)

	NumBloodMapMaterials=2
}
