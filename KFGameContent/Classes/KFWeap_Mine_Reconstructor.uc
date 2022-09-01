//=============================================================================
// KFWeap_Mine_Reconstructor
//=============================================================================
// KFWeap_Mine_Reconstructor weapon code based on HuskCannon
//=============================================================================
// Killing Floor 2
// Copyright (C) 2017 Tripwire Interactive LLC
// Fernando Ferrando @ saber3d
//=============================================================================
class KFWeap_Mine_Reconstructor extends KFWeapon;

//Props related to charging the weapon
var float MaxChargeTime;
var float ValueIncreaseTime;
var float DmgIncreasePerCharge;
var float AOEIncreasePerCharge;
var float IncapIncreasePerCharge;
var int AmmoIncreasePerCharge;

var transient float ChargeTime;
var transient float ConsumeAmmoTime;
var transient float MaxChargeLevel;

var ParticleSystem ChargingEffect;
var ParticleSystem ChargedEffect;

var const ParticleSystem MuzzleFlashEffectL3;

var transient ParticleSystemComponent FullyChargedPSC;
var transient ParticleSystemComponent ChargingPSC;
var transient bool bIsFullyCharged;

var const WeaponFireSndInfo FullyChargedSound;

var float SelfDamageReductionValue;

var float FullChargedTimerInterval;
var float FXScalingFactorByCharge, ChargePercentage;
var float MinScale, MaxScale;

var int MaxDamageByCharge;
var int MinDamageByCharge;

var private array<KFProj_Mine_Reconstructor> PoolOfMines;

const SecondaryFireAnim = 'Alt_Fire';
const SecondaryFireIronAnim = 'Alt_Fire_Iron';
const SecondaryFireAnimEmpty = 'Alt_Fire_Empty';
const SecondaryFireIronAnimEmpty = 'Alt_Fire_Iron_Empty';
var bool bHasToLaunchEmptyAnim;

var SkelControlSingleBone Control;

//var int iCounterA;

var bool bBlocked;

Replication
{
	if(Role == Role_Authority && bNetDirty)
		ChargeTime;
}

/******************************************************

		POOL BASED ON KFGAMEPOOLMANAGER

******************************************************/


/** The maximum global number of Mine Reconstructor Mines that can be active in play */
var protected const byte MAX_ACTIVE_MINE_RECONSTRUCTOR_MINES;

/** Determines the pool type and adds a new projectile to that pool */
function AddProjectileToPool( KFProj_Mine_Reconstructor Proj )
{
	AddProjectileToPool_Internal( PoolOfMines, Proj, MAX_ACTIVE_MINE_RECONSTRUCTOR_MINES );
}

/** Determines the pool type and removes a projectile from the pool */
function RemoveProjectileFromPool( KFProj_Mine_Reconstructor Proj )
{
	RemoveProjectileFromPool_Internal( PoolOfMines, Proj );
}

/** Add a projectile to its respective pool, removing the oldest if we are at the pool limit */
private function AddProjectileToPool_Internal( out array<KFProj_Mine_Reconstructor> PoolProjectiles, KFProj_Mine_Reconstructor Proj, byte MaxActiveProjectiles )
{
	if( PoolProjectiles.Length == MaxActiveProjectiles )
	{
		if( PoolProjectiles[0] != none )
		{
			PoolProjectiles[0].Detonate();
		}
		PoolProjectiles.Remove( 0, 1 );
	}

	PoolProjectiles.AddItem( Proj );
}

/** Remove a projectile from the pool (it's been destroyed) */
private function RemoveProjectileFromPool_Internal( out array<KFProj_Mine_Reconstructor> PoolProjectiles, KFProj_Mine_Reconstructor Proj)
{
	PoolProjectiles.RemoveItem( Proj );
}

/******************************************************

		END POOL BASED ON KFGAMEPOOLMANAGER

******************************************************/

/******************************************************

		RECOVER THE DATA FROM THE PICKUP

******************************************************/

/** Allows pickup to update weapon properties
  * Overridden to allow C4 to update charges
  */
function SetOriginalValuesFromPickup( KFWeapon PickedUpWeapon )
{
	local int i, NumDeployedCharges;

	super.SetOriginalValuesFromPickup( PickedUpWeapon );

	PoolOfMines = KFWeap_Mine_Reconstructor(PickedUpWeapon).PoolOfMines;
	NumDeployedCharges = PoolOfMines.Length;
	bForceNetUpdate = true;

	for( i = 0; i < NumDeployedCharges; ++i )
	{
		// charge alerts (beep, light) need current instigator
		PoolOfMines[i].Instigator = Instigator;
        PoolOfMines[i].SetOwner(self);
		if( Instigator.Controller != none )
		{
			PoolOfMines[i].InstigatorController = Instigator.Controller;
		}
	}
}

/******************************************************

		END RECOVER THE DATA FROM THE PICKUP

******************************************************/

/****************************************************************

		CUSTOM FIREMODE (DELETE AL THE MINES OWNED BY THE WEAPON)

****************************************************************/

simulated function CustomFire()
{
	local int i, NumDeployedCharges;
	super.CustomFire();
	NumDeployedCharges = PoolOfMines.Length;
	bForceNetUpdate = true;

	// Alt-fire blast only (server authoritative)
	if ( CurrentFireMode != ALTFIRE_FIREMODE )
	{
		Super.CustomFire();
		return;
	}


	if ( Instigator.Role < ROLE_Authority )
	{
		return;
	}

	if(NumDeployedCharges <= 0)
	{
		bHasToLaunchEmptyAnim = true;
		return;
	}

	for( i = 0; i < NumDeployedCharges; ++i )
	{
		
		if(PoolOfMines[i] == none) continue;

		PoolOfMines[i].Instigator = Instigator;
        PoolOfMines[i].SetOwner(self);
		if( Instigator.Controller != none )
		{
			PoolOfMines[i].ManuallyDetonate();
		}
	}
	PoolOfMines.Remove(0, PoolOfMines.Length);
	bHasToLaunchEmptyAnim = false;

}

/****************************************************************

		END CUSTOM FIREMODE (DELETE AL THE MINES OWNED BY THE WEAPON)

****************************************************************/


/*********************************************************************************************
 
 * 	CONTROL FOR AMMO TANK
 
********************************************************************************************* */

simulated event PostInitAnimTree( SkeletalMeshComponent SkelComp )
{
	local vector vec;
	local float fPercentage;

	super.PostInitAnimTree( SkelComp );

	Control = SkelControlSingleBone( SkelComp.FindSkelControl('AmmoControl') );
	if( Control != none )
	{
		Control.SetSkelControlActive( true );
	}

	
	//from 0 to -8
    // If AmmoCount is being replicated, don't allow the client to modify it here
	fPercentage = FMin((float(AmmoCount[0])/(MagazineCapacity[0])), 1);
	vec.X = Control.BoneTranslation.X;
   	vec.Y = Control.BoneTranslation.Y;
    vec.Z = Lerp(-8, 0, fPercentage);
	Control.BoneTranslation = vec;
}


/*********************************************************************************************
 
 * 	END CONTROL FOR AMMO TANK

********************************************************************************************* */

/**
* @see Weapon::ConsumeAmmo
*/
simulated function ConsumeAmmo(byte FireModeNum)
{
	local vector vec;
	local float fPercentage;
	
	//from 0 to -8
    // If AmmoCount is being replicated, don't allow the client to modify it here
    if (Role == ROLE_Authority)
    {
		fPercentage = FMin(float(AmmoCount[0])/(MagazineCapacity[0]), 1);
		super.ConsumeAmmo(FireModeNum);

		if(Control != none)
		{
			vec.X = Control.BoneTranslation.X;
   			vec.Y = Control.BoneTranslation.Y;
    		vec.Z = Lerp(-8, 0, fPercentage);
			Control.BoneTranslation = vec;
		}

		//Notify the client about the new percentage as the client is not tracking the ammo
		ClientUpdateVisualAmmo(fPercentage);
    }

	//function que modifque 
}

reliable client function ClientUpdateVisualAmmo(float BoneControlTranslation)
{
	local vector vec;

	if ( Role < ROLE_Authority && Control != none )
	{
		vec.X = Control.BoneTranslation.X;
   		vec.Y = Control.BoneTranslation.Y;
    	vec.Z = Lerp(-8, 0, BoneControlTranslation);
		Control.BoneTranslation = vec;
	}
}

simulated function BeginFire(Byte FireModeNum)
{
	super.BeginFire(FireModeNum);
}

simulated function StartFire(byte FiremodeNum)
{
	if (IsTimerActive('RefireCheckTimer') || bBlocked)
	{
		return;
	}
	if(Role != Role_Authority && FireModeNum == DEFAULT_FIREMODE && HasAmmo(DEFAULT_FIREMODE))
	{
		bBlocked = true;
		if(IsTimerActive(nameof(UnlockClientFire)))
		{
			ClearTimer(nameof(UnlockClientFire));
		}
	}

	super.StartFire(FiremodeNum);

	if ( PendingFire(RELOAD_FIREMODE) && Role != Role_Authority)
	{
		bBlocked = false;
	}


}

simulated function RefireCheckTimer()
{
	Super.RefireCheckTimer();
	if(bBlocked && Role != Role_Authority)
	{
		SetTimer(0.25f , false, nameof(UnlockClientFire));
	}
}

reliable client function UnlockClientFire()
{
	bBlocked = false;
}

simulated function EndFire(byte FiremodeNum)
{
	//`Log("EndFire");
	super.EndFire(FireModeNum);
}

simulated function OnStartFire()
{
	local KFPawn PawnInst;
	PawnInst = KFPawn(Instigator);

	if (PawnInst != none)
	{
		PawnInst.OnStartFire();
	}
}


simulated function FireAmmunition()
{

	//`Log("FireAmmunition"@iCounterA);
	//`Warn("ChargePercentage"@ChargePercentage);
	//++iCounterA;
	// Let the accuracy tracking system know that we fired
	HandleWeaponShotTaken(CurrentFireMode);

	// Handle the different fire types
	switch (WeaponFireTypes[CurrentFireMode])
	{
	case EWFT_InstantHit:
		// Launch a projectile if we are in zed time, and this weapon has a projectile to launch for this mode
		if (`IsInZedTime(self) && WeaponProjectiles[CurrentFireMode] != none )
		{
			ProjectileFire();
		}
		else
		{
			InstantFireClient();
		}

		break;

	case EWFT_Projectile:
		ProjectileFire();
		break;

	case EWFT_Custom:
		CustomFire();
		break;
	}

	//// If we're firing without charging, still consume one ammo
	if (GetChargeLevel() < 1)
	{
		ConsumeAmmo(CurrentFireMode);
	}

	NotifyWeaponFired(CurrentFireMode);

	// Play fire effects now (don't wait for WeaponFired to replicate)
	//PlayFireEffects(CurrentFireMode, vect(0, 0, 0));
}

simulated function ANIMNOTIFY_FILLMAG()
{
	local vector vec;
	vec.X = Control.BoneTranslation.X;
   	vec.Y = Control.BoneTranslation.Y;
    vec.Z = 0;
	Control.BoneTranslation = vec;
}

/**
 * @see Weapon::HasAmmo
 */
simulated event bool HasAmmo( byte FireModeNum, optional int Amount )
{
	local KFPerk InstigatorPerk;
	// we can always do a melee attack
	if( FireModeNum == BASH_FIREMODE )
	{
		return TRUE;
	}
	else if ( FireModeNum == RELOAD_FIREMODE )
	{
		return CanReload();
	}
	else if ( FireModeNum == GRENADE_FIREMODE )
	{
        if( KFInventoryManager(InvManager) != none )
        {
            return KFInventoryManager(InvManager).HasGrenadeAmmo(Amount);
        }
	}
	else if(FireModeNum == ALTFIRE_FIREMODE)
	{
		return true;
	}
	
	InstigatorPerk = GetPerk();
	if( InstigatorPerk != none && InstigatorPerk.GetIsUberAmmoActive( self ) )
	{
		return true;
	}

	// If passed in ammo isn't set, use default ammo cost.
	if( Amount == 0 )
	{
		Amount = AmmoCost[FireModeNum];
	}

	return AmmoCount[GetAmmoType(FireModeNum)] >= Amount;
}


simulated state MineReconstructorCharge extends WeaponFiring
{
    //For minimal code purposes, I'll directly call global.FireAmmunition after charging is released
    simulated function FireAmmunition()
    {
		return;
	}

    //Store start fire time so we don't have to timer this
    simulated event BeginState(Name PreviousStateName)
    {
		local KFPerk InstigatorPerk;

        super.BeginState(PreviousStateName);


		InstigatorPerk = GetPerk();
		if( InstigatorPerk != none )
		{
			SetZedTimeResist( InstigatorPerk.GetZedTimeModifier(self) );
		}

		ChargeTime = 0;
		ConsumeAmmoTime = 0;
		MaxChargeLevel = int(MaxChargeTime / ValueIncreaseTime);

		if (ChargingPSC == none)
		{
			ChargingPSC = new(self) class'ParticleSystemComponent';

			if(MySkelMesh != none)
			{
				MySkelMesh.AttachComponentToSocket(ChargingPSC, 'MuzzleFlash');
			}
			else
			{
				AttachComponent(ChargingPSC);
			}
		}
		else
		{
			ChargingPSC.ActivateSystem();
		}

		bIsFullyCharged = false;

		global.OnStartFire();

		if(ChargingPSC != none)
		{
			ChargingPSC.SetTemplate(ChargingEffect);
		}
		ChargeTime = 0;
		FXScalingFactorByCharge = 0;
		//ConsumeAmmo(CurrentFireMode);
    }

	simulated function bool ShouldRefire()
	{
		// ignore how much ammo is left (super/global counts ammo)
		return StillFiring(CurrentFireMode);
	}

    simulated event Tick(float DeltaTime)
    {
        local float ChargeRTPC;
		local float InstantHitDamageValue;

		global.Tick(DeltaTime);

		if(bIsFullyCharged) return;

		// Don't charge unless we're holding down the button
		if (PendingFire(CurrentFireMode))
		{
			ConsumeAmmoTime += DeltaTime;
		}

		if (bIsFullyCharged)
		{
			if (ConsumeAmmoTime >= FullChargedTimerInterval)
			{
				ConsumeAmmo(DEFAULT_FIREMODE);
				ConsumeAmmoTime -= FullChargedTimerInterval;
			}

			return;
		}

		// Don't charge unless we're holding down the button
		if (PendingFire(CurrentFireMode))
		{

			if(Role == Role_Authority && !bIsFullyCharged)
			{
				ChargeTime += DeltaTime;
				bNetDirty = true;
			}
			
			if( ChargingPSC != none && !bIsFullyCharged)
			{
				FXScalingFactorByCharge = FMin(Lerp(MinScale, MaxScale, ChargeTime / MaxChargeTime), MaxScale);
				ChargePercentage = FMin(ChargeTime / MaxChargeTime, 1);

				if(ChargePercentage < 0.1f)
				{
					InstantHitDamageValue = Lerp(MinDamageByCharge, MaxDamageByCharge, 0.1f);
				}
				else
				{
					InstantHitDamageValue = Lerp(MinDamageByCharge, MaxDamageByCharge, ChargePercentage);
				}
				InstantHitDamage[DEFAULT_FIREMODE] = InstantHitDamageValue;

				ChargingPSC.SetFloatParameter( name("InflateBlob"), ChargePercentage );
				if(ChargePercentage > 0.51f)
					InstantHitDamageTypes[DEFAULT_FIREMODE]=class'KFDT_Toxic_MineReconstructorImpactHeavy';
				else
					InstantHitDamageTypes[DEFAULT_FIREMODE]=class'KFDT_Toxic_MineReconstructorImpact';

			}
		}

		ChargeRTPC = FMin(ChargeTime / MaxChargeTime, 1.f);
        KFPawn(Instigator).SetWeaponComponentRTPCValue("Weapon_Charge", ChargeRTPC); //For looping component
        Instigator.SetRTPCValue('Weapon_Charge', ChargeRTPC); //For one-shot sounds
		
		if (ConsumeAmmoTime >= ValueIncreaseTime && !bIsFullyCharged)
		{
			ConsumeAmmo(DEFAULT_FIREMODE);
			ConsumeAmmoTime -= ValueIncreaseTime;
		}

		if (ChargeTime >= MaxChargeTime || !HasAmmo(DEFAULT_FIREMODE))
		{
			bIsFullyCharged = true;
			//ChargingPSC.SetTemplate(ChargedEffect);
			if(( Instigator.Role != ROLE_Authority ) || WorldInfo.NetMode == NM_Standalone)
			{
				if (FullyChargedPSC == none)
				{
					FullyChargedPSC = new(self) class'ParticleSystemComponent';
	
					if(MySkelMesh != none)
					{
						MySkelMesh.AttachComponentToSocket(FullyChargedPSC, 'MuzzleFlash');
					}
					else
					{
						AttachComponent(FullyChargedPSC);
					}
				}
				else
				{
					FullyChargedPSC.ActivateSystem();
				}
	
				FullyChargedPSC.SetTemplate(ChargedEffect);
	
	
				KFPawn(Instigator).SetWeaponAmbientSound(FullyChargedSound.DefaultCue, FullyChargedSound.FirstPersonCue);
			}
		}

    }

    //Now that we're done charging, directly call FireAmmunition. This will handle the actual projectile fire and scaling.
    simulated event EndState(Name NextStateName)
    {
		if(Role == Role_Authority)
		{
			UnlockClientFire();
		}

		ClearZedTimeResist();
        ClearPendingFire(CurrentFireMode);
		ClearTimer(nameof(RefireCheckTimer));

		KFPawn(Instigator).bHasStartedFire = false;
		KFPawn(Instigator).bNetDirty = true;

		if (ChargingPSC != none)
		{
			ChargingPSC.DeactivateSystem();
		}

		if (FullyChargedPSC != none)
		{
			FullyChargedPSC.DeactivateSystem();
		}

		KFPawn(Instigator).SetWeaponAmbientSound(none);
    }

	simulated function HandleFinishedFiring()
	{
		global.FireAmmunition();

		if (bPlayingLoopingFireAnim)
		{
			StopLoopingFireEffects(CurrentFireMode);
		}

		SetTimer(0.1f, false, 'Timer_StopFireEffects');

		NotifyWeaponFinishedFiring(CurrentFireMode);

		super.HandleFinishedFiring();
		//`Log("ChargePercentage"@ChargePercentage);
	}

	simulated function PutDownWeapon()
	{
		global.FireAmmunition();

		if (bPlayingLoopingFireAnim)
		{
			StopLoopingFireEffects(CurrentFireMode);
		}
		
		SetTimer(0.1f, false, 'Timer_StopFireEffects');

		NotifyWeaponFinishedFiring(CurrentFireMode);
		
		if(Role == Role_Authority)
		{
			UnlockClientFire();
		}

		super.PutDownWeapon();
	}
}

// Placing the actual Weapon Firing end state here since we need it to happen at the end of the actual firing loop.
simulated function Timer_StopFireEffects()
{
	// Simulate weapon firing effects on the local client
	if (WorldInfo.NetMode == NM_Client)
	{
		Instigator.WeaponStoppedFiring(self, false);

		if (FullyChargedPSC != none)
		{
			FullyChargedPSC.DeactivateSystem();
		}
	}

	ClearFlashCount();
	ClearFlashLocation();
}

simulated state Active
{
	simulated function BeginState(name PreviousStateName)
	{
		Super.BeginState(PreviousStateName);
		if(Role == Role_Authority)
		{
			UnlockClientFire();
		}
	}

}


simulated function KFProjectile SpawnProjectile(class<KFProjectile> KFProjClass, vector RealStartLoc, vector AimDir)
{
    local KFProj_Mine_Reconstructor Mine;

    Mine = KFProj_Mine_Reconstructor(super.SpawnProjectile(KFProjClass, RealStartLoc, AimDir));
    //Calc and set scaling values
    if (Mine != none)
    {
		AddProjectileToPool(Mine);
		ChargePercentage = FMax(0.1, ChargePercentage);
		FXScalingFactorByCharge = FMax(0.1, FXScalingFactorByCharge);
		Mine.SetInheritedScale(FXScalingFactorByCharge, ChargePercentage);
        return Mine;
    }
    return none;
}

simulated function CauseMuzzleFlash(byte FireModeNum)
{
	if (MuzzleFlash == None)
	{
		AttachMuzzleFlash();
	}

	if (MuzzleFlash != none)
	{
		/*MuzzleFlash.MuzzleFlash.ParticleSystemTemplate = MuzzleFlashEffectL3;
		MuzzleFlash.MuzzleFlash.PSC.SetTemplate(MuzzleFlashEffectL3);*/
	}

	super.CauseMuzzleFlash(FireModeNum);
}

simulated function int GetChargeLevel()
{
	return Min(ChargeTime / ValueIncreaseTime, MaxChargeLevel);
}

/****************************************************************

		TRADER FUNCTIONS

****************************************************************/

static simulated event EFilterTypeUI GetTraderFilter()
{
    return FT_Flame;
}

static simulated function float CalculateTraderWeaponStatDamage()
{
	local float CalculatedDamage;
	local class<KFDamageType> DamageType;
	local GameExplosion ExplosionInstance;

	ExplosionInstance = class<KFProjectile>(default.WeaponProjectiles[DEFAULT_FIREMODE]).default.ExplosionTemplate;

	CalculatedDamage = default.InstantHitDamage[DEFAULT_FIREMODE] + ExplosionInstance.Damage;

	DamageType = class<KFDamageType>(ExplosionInstance.MyDamageType);
	if (DamageType != none && DamageType.default.DoT_Type != DOT_None)
	{
		CalculatedDamage += (DamageType.default.DoT_Duration / DamageType.default.DoT_Interval) * (CalculatedDamage * DamageType.default.DoT_DamageScale);
	}

	return CalculatedDamage;
}

/****************************************************************

		END TRADER FUNCTIONS

****************************************************************/

/****************************************************************

		PAWN ADJUST DAMAGE

****************************************************************/

// increase the instant hit damage based on the charge level
simulated function int GetModifiedDamage(byte FireModeNum, optional vector RayDir)
{
	local int ModifiedDamage;
	ModifiedDamage = super.GetModifiedDamage(FireModeNum, RayDir);
	return ModifiedDamage;
}

/** We avoid alternating between firemodes and directly altfire */
simulated function AltFireMode()
{
	if ( !Instigator.IsLocallyControlled() )
	{
		return;
	}

	StartFire(ALTFIRE_FIREMODE);
}

/****************************************************************

		END PAWN ADJUST DAMAGE

****************************************************************/

state WeaponSingleFiring
{
	/** Get whether we should play the reload anim as well or not */
	local name Returned;
	simulated function name GetWeaponFireAnim(byte FireModeNum)
	{
		if(bUsingSights)
		{
			Returned = (bHasToLaunchEmptyAnim == false) ? SecondaryFireIronAnim : SecondaryFireIronAnimEmpty ;
			return Returned;
		}
		else
		{
			Returned = (bHasToLaunchEmptyAnim == false) ? SecondaryFireAnim : SecondaryFireAnimEmpty ;;
			return Returned;
		}
	}
}



defaultproperties
{
	SelfDamageReductionValue=0.1f
    //Gameplay Props
    MaxChargeTime=1.2
    AmmoIncreasePerCharge=1
	ValueIncreaseTime=0.2

	//FOR LERPING DAMANGE
	MaxDamageByCharge=350 //300 //250 //200 //120
	MinDamageByCharge=35 //30 //25 //30
    // FOV
    Meshfov=80
	MeshIronSightFOV=65 //52
    PlayerIronSightFOV=50 //80

	// Depth of field
	DOF_FG_FocalRadius=150
	DOF_FG_MaxNearBlurSize=1

	// Content
	PackageKey="Mine_Reconstructor"
	FirstPersonMeshName="WEP_1P_Mine_Reconstructor_MESH.Wep_1stP_HMTech_Mine_Reconstructor_Rig"
	FirstPersonAnimSetNames(0)="WEP_1P_Mine_Reconstructor_ANIM.Wep_1stP_Mine_Reconstructor_Anim"
	PickupMeshName="WEP_3P_Mine_Reconstructor_MESH.Wep_3rdP_Mine_Reconstructor_Lowpoly_Pickup"
	AttachmentArchetypeName="WEP_Mine_Reconstructor_Arch.Wep_Mine_Reconstructor_3P"
	MuzzleFlashTemplateName="WEP_Mine_Reconstructor_Arch.Wep_Mine_Reconstructor_MuzzleFlash"

   	// Zooming/Position
	PlayerViewOffset=(X=0.0,Y=12,Z=-1)
	IronSightPosition=(X=0,Y=0,Z=0)
	
	// Controls the rotation when Hans(the bastard) grabs you
	QuickWeaponDownRotation=(Pitch=-19192,Yaw=-11500,Roll=16384) // (Pitch=-19192,Yaw=-11000,Roll=16384)

	// Ammo
	MagazineCapacity[0]=12 //24
	SpareAmmoCapacity[0]=132 //108
	InitialSpareMags[0]=3 //2
	AmmoPickupScale[0]=1.5 //1 //0.75
	bCanBeReloaded=true
	bReloadFromMagazine=true

	// Recoil
	maxRecoilPitch=150
	minRecoilPitch=115
	maxRecoilYaw=115
	minRecoilYaw=-115
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
    HippedRecoilModifier=1.5

    // Inventory
	InventorySize=7 //8
	GroupPriority=80 //75
	WeaponSelectTexture=Texture2D'WEP_UI_Mine_Reconstructor_TEX.UI_WeaponSelect_HMTechMineReconstructor' //@TODO: Replace me

	// DEFAULT_FIREMODE
	//FireModeIconPaths(DEFAULT_FIREMODE)=Texture2D'ui_firemodes_tex.UI_FireModeSelect_Grenade' //@TODO: Replace me
	FireModeIconPaths(DEFAULT_FIREMODE)=Texture2D'ui_firemodes_tex.UI_FireModeSelect_MedicDart'
	FiringStatesArray(DEFAULT_FIREMODE)=MineReconstructorCharge
	WeaponFireTypes(DEFAULT_FIREMODE)=EWFT_Projectile
    WeaponProjectiles(DEFAULT_FIREMODE)=class'KFProj_Mine_Reconstructor'
	FireInterval(DEFAULT_FIREMODE)=+0.223 //+0.33 
	InstantHitDamage(DEFAULT_FIREMODE)=120
	PenetrationPower(DEFAULT_FIREMODE)=0.0;
	InstantHitDamageTypes(DEFAULT_FIREMODE)=class'KFDT_Toxic_MineReconstructorImpact'
	FireOffset=(X=30,Y=4.5,Z=-5)

	// ALT_FIREMODE
	FiringStatesArray(ALTFIRE_FIREMODE)=WeaponSingleFiring
	WeaponFireTypes(ALTFIRE_FIREMODE)=EWFT_Custom
	FireInterval(ALTFIRE_FIREMODE)=+0.15 //+0.25
	AmmoCost(ALTFIRE_FIREMODE)=0

	// BASH_FIREMODE
	InstantHitDamageTypes(BASH_FIREMODE)=class'KFDT_Bludgeon_Mine_Reconstructor'
	InstantHitDamage(BASH_FIREMODE)=26

	// Fire Effects
	WeaponFireSnd(DEFAULT_FIREMODE)=(DefaultCue=AkEvent'WW_WEP_MineReconstructor.Play_WEP_Mine_Reconstructor_3P_Start', FirstPersonCue=AkEvent'WW_WEP_MineReconstructor.Play_WEP_Mine_Reconstructor_1P_Start')
	WeaponFireLoopEndSnd(DEFAULT_FIREMODE)=(DefaultCue=AkEvent'WW_WEP_MineReconstructor.Play_WEP_Mine_Reconstructor_3P_Shoot', FirstPersonCue=AkEvent'WW_WEP_MineReconstructor.Play_WEP_Mine_Reconstructor_1P_Shoot')
	FullyChargedSound=(DefaultCue = AkEvent'WW_WEP_MineReconstructor.Play_WEP_Mine_Reconstructor_Charged_3P', FirstPersonCue=AkEvent'WW_WEP_MineReconstructor.Play_WEP_Mine_Reconstructor_Charged')

	WeaponDryFireSnd(DEFAULT_FIREMODE)=AkEvent'WW_WEP_SA_Flamethrower.Play_WEP_SA_Flamethrower_Handling_DryFire' //@TODO: Replace me
	WeaponDryFireSnd(ALTFIRE_FIREMODE)=AkEvent'WW_WEP_SA_Flamethrower.Play_WEP_SA_Flamethrower_Handling_DryFire' //@TODO: Replace me

	// Advanced (High RPM) Fire Effects
	bLoopingFireAnim(DEFAULT_FIREMODE)=true
	bLoopingFireSnd(DEFAULT_FIREMODE)=true
	SingleFireSoundIndex=FIREMODE_NONE
	bLoopingFireAnim(ALTFIRE_FIREMODE)=false
	bLoopingFireSnd(ALTFIRE_FIREMODE)=false

	// Attachments
	bHasIronSights=true
	bHasFlashlight=false

   	AssociatedPerkClasses(0)= class'KFPerk_FieldMedic'

	WeaponFireWaveForm=ForceFeedbackWaveform'FX_ForceFeedback_ARCH.Gunfire.Weak_Recoil'

	ChargingEffect=ParticleSystem'WEP_Mine_Reconstructor_EMIT.FX_Bile_BlobCharge_01'
	ChargedEffect=ParticleSystem'WEP_Mine_Reconstructor_EMIT.FX_Mine_Reconstructor_FullCharge'

	MuzzleFlashEffectL3=ParticleSystem'WEP_HuskCannon_EMIT.FX_Huskcannon_MuzzleFlash_L3_1P'

	FullChargedTimerInterval=2.0f

	// Weapon Upgrade stat boosts
	//WeaponUpgrades[1]=(IncrementDamage=1.1f,IncrementWeight=1)

	WeaponUpgrades[1]=(Stats=((Stat=EWUS_Damage0, Scale=1.15f), (Stat=EWUS_Weight, Add=1)))
	WeaponUpgrades[2]=(Stats=((Stat=EWUS_Damage0, Scale=1.3f), (Stat=EWUS_Weight, Add=2)))

	FXScalingFactorByCharge = 0;
	MinScale=0.5
	MaxScale=1.5
	MAX_ACTIVE_MINE_RECONSTRUCTOR_MINES = 12;
	bAllowClientAmmoTracking = false;

	Begin Object Name=FirstPersonMesh
		// new anim tree with skelcontrol to rotate cylinders
		AnimTreeTemplate=AnimTree'WEP_Mine_Reconstructor_Arch.WEP_1stP_Animtree_MineReconstructor'
	End Object
	//iCounterA = 0
	bBlocked = false;
}