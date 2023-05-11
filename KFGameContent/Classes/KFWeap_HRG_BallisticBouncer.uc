//=============================================================================
// KFWeap_HRG_BallisticBouncer
//=============================================================================
// Killing Floor 2
// Copyright (C) 2022 Tripwire Interactive LLC
//=============================================================================
class KFWeap_HRG_BallisticBouncer extends KFWeapon;

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

var ParticleSystem ChargedEffect;

var transient ParticleSystemComponent FullyChargedPSC;
var transient bool bIsFullyCharged;

var const WeaponFireSndInfo FullyChargedSound;

var float FullChargedTimerInterval;
var float FXScalingFactorByCharge, ChargePercentage;
var float MinScale, MaxScale;

var int MaxDamageByCharge;
var int MinDamageByCharge;

const SecondaryFireAnim = 'Alt_Fire';
const SecondaryFireIronAnim = 'Alt_Fire_Iron';
const SecondaryFireAnimEmpty = 'Alt_Fire_Empty';
const SecondaryFireIronAnimEmpty = 'Alt_Fire_Iron_Empty';
var bool bHasToLaunchEmptyAnim;

var SkelControlSingleBone Control;

var bool bBlocked;

var() StaticMesh ChargeStaticMesh;
var transient StaticMeshComponent ChargeAttachment; 
var transient MaterialInstanceConstant ChargeMIC;

var float MinProjPlaceholderScale;
var float MaxProjPlaceHolderScale;

Replication
{
	if(Role == Role_Authority && bNetDirty)
		ChargeTime;
}

static simulated event EFilterTypeUI GetTraderFilter()
{
	return FT_Projectile;
}

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

simulated function StartFire(byte FiremodeNum)
{
	if (IsTimerActive('RefireCheckTimer'))
	{
		return;
	}
 
	if (bBlocked && AmmoCount[0] == 0 && !IsTimerActive(nameof(RefireCheckTimer)) && !IsTimerActive(nameof(UnlockClientFire)))
	{

		bBlocked = false;
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
	PlayFireEffects(CurrentFireMode, vect(0, 0, 0));
}

simulated function ANIMNOTIFY_FILLMAG()
{
	local vector vec;

	if (Control != none)
	{
		vec.X = Control.BoneTranslation.X;
		vec.Y = Control.BoneTranslation.Y;
		vec.Z = 0;
		Control.BoneTranslation = vec;
	}
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

		if (WorldInfo.NetMode == NM_Client || WorldInfo.NetMode == NM_Standalone)
		{
			if (ChargeAttachment == none)
			{
				ChargeAttachment = new (self) class'StaticMeshComponent';

				// ChargeAttachment.SetActorCollision(false, false);
				ChargeAttachment.SetStaticMesh(ChargeStaticMesh);
				// ChargeAttachment.SetShadowParent(Mesh);

				ChargeMIC = ChargeAttachment.CreateAndSetMaterialInstanceConstant(0);
				
				MySkelMesh.AttachComponentToSocket(ChargeAttachment, 'MuzzleFlash');

				ChargeAttachment.SetHidden(true);
			}
			else
			{
				ChargeAttachment.SetStaticMesh(ChargeStaticMesh);
			}
		}

		bIsFullyCharged = false;

		global.OnStartFire();

		ChargeTime = 0;
		FXScalingFactorByCharge = 0;
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
		local float NewScale;

		global.Tick(DeltaTime);

		if (ChargeAttachment != none && ChargeAttachment.StaticMesh == none)
		{
			ChargeAttachment.SetStaticMesh(ChargeStaticMesh);
		}

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
			
			ChargePercentage = FMin(ChargeTime / MaxChargeTime, 1);

			if (ChargeAttachment != none && !bIsFullyCharged)
			{
				FXScalingFactorByCharge = FMin(Lerp(MinScale, MaxScale, ChargeTime / MaxChargeTime), MaxScale);

				if(ChargePercentage < 0.1f)
				{
					InstantHitDamageValue = Lerp(MinDamageByCharge, MaxDamageByCharge, 0.1f);
				}
				else
				{
					InstantHitDamageValue = Lerp(MinDamageByCharge, MaxDamageByCharge, ChargePercentage);
				}
				InstantHitDamage[DEFAULT_FIREMODE] = InstantHitDamageValue;

				NewScale = Lerp(MinProjPlaceholderScale, MaxProjPlaceholderScale, ChargePercentage);

				ChargeAttachment.SetHidden(false);
				ChargeAttachment.SetScale( NewScale );

				if (ChargeMIC != none)
				{	
					// Change Color
					ChargeMIC.SetScalarParameterValue('Charge', ChargePercentage);
				}
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

		if (ChargeAttachment != none)
		{
			ChargeAttachment.SetHidden(true);
			ChargeAttachment.SetScale(MinProjPlaceholderScale);
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
	}

	simulated function PutDownWeapon()
	{
		global.FireAmmunition();

		if (bPlayingLoopingFireAnim)
		{
			StopLoopingFireEffects(CurrentFireMode);
		}
		
		SetTimer(0.1f, false, 'Timer_StopFireEffects');

		if (ChargeAttachment != none)
		{
			ChargeAttachment.SetHidden(true);
			ChargeAttachment.SetScale(MinProjPlaceholderScale);
		}

		NotifyWeaponFinishedFiring(CurrentFireMode);
		
		if(Role == Role_Authority)
		{
			UnlockClientFire();
		}

		super.PutDownWeapon();
	}
}

simulated function StopFireEffects(byte FireModeNum)
{
	Super.StopFireEffects(FireModeNum);

	if (ChargeAttachment != none)
	{
		ChargeAttachment.SetStaticMesh(none); // if we don't do this it doesn't work ?!, when starting fire it assigns again so no problem..

		ChargeAttachment.SetHidden(true);
		ChargeAttachment.SetScale(MinProjPlaceholderScale);
	}
}

// Placing the actual Weapon Firing end state here since we need it to happen at the end of the actual firing loop.
simulated function Timer_StopFireEffects()
{
	// Simulate weapon firing effects on the local client
	if (WorldInfo.NetMode == NM_Client)
	{
		Instigator.WeaponStoppedFiring(self, false);

		if (ChargeAttachment != none)
		{
			ChargeAttachment.SetHidden(true);
		}
		
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
    local KFProj_HRG_BallisticBouncer BouncingProj;

    BouncingProj = KFProj_HRG_BallisticBouncer(super.SpawnProjectile(KFProjClass, RealStartLoc, AimDir));
    //Calc and set scaling values
    if (BouncingProj != none)
    {
		ChargePercentage = FMax(0.1, ChargePercentage);
		FXScalingFactorByCharge = FMax(0.1, FXScalingFactorByCharge);
		BouncingProj.SetInheritedScale(FXScalingFactorByCharge, ChargePercentage);
        return BouncingProj;
    }
	
    return none;
}

simulated function CauseMuzzleFlash(byte FireModeNum)
{
	local vector vec;

	if (MuzzleFlash == None)
	{
		AttachMuzzleFlash();
	}

	if (MuzzleFlash != none)
	{
		vec.X = ChargePercentage;
   		vec.Y = ChargePercentage;
		vec.Z = ChargePercentage;

		MuzzleFlash.MuzzleFlash.PSC.SetVectorParameter(name("Charge"), vec);
		MuzzleFlash.CauseMuzzleFlash(FireModeNum);
	}

	super.CauseMuzzleFlash(FireModeNum);
}

simulated function int GetChargeLevel()
{
	return Min(ChargeTime / ValueIncreaseTime, MaxChargeLevel);
}

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

state WeaponSingleFiring
{
	/** Get whether we should play the reload anim as well or not */
	simulated function name GetWeaponFireAnim(byte FireModeNum)
	{
		if(bUsingSights)
		{
			return (bHasToLaunchEmptyAnim == false) ? SecondaryFireIronAnim : SecondaryFireIronAnimEmpty;
		}
		else
		{
			return (bHasToLaunchEmptyAnim == false) ? SecondaryFireIronAnim : SecondaryFireIronAnimEmpty;
		}
	}
}

defaultproperties
{
    //Gameplay Props
    MaxChargeTime=0.6
    AmmoIncreasePerCharge=1
	ValueIncreaseTime=0.1

	//FOR LERPING DAMANGE
	MaxDamageByCharge=300
	MinDamageByCharge=15
    // FOV
    Meshfov=80
	MeshIronSightFOV=65 //52
    PlayerIronSightFOV=50 //80

	// Depth of field
	DOF_FG_FocalRadius=150
	DOF_FG_MaxNearBlurSize=1

	// Content
	PackageKey="HRG_BallisticBouncer"
	FirstPersonMeshName="wep_1p_hrg_ballisticbouncer_mesh.Wep_1stP_HRG_BallisticBouncer_Rig"
	FirstPersonAnimSetNames(0)="wep_1p_hrg_ballisticbouncer_anim.Wep_1stP_BallisticBouncer_Anim"
	PickupMeshName="wep_3p_hrg_ballisticbouncer_mesh.Wep_3rdP_HRG_BallisticBouncer_Pickup"
	AttachmentArchetypeName="wep_hrg_ballisticbouncer_arch.Wep_HRG_BallisticBouncer_3P"
	MuzzleFlashTemplateName="WEP_HRG_BallisticBouncer_ARCH.Wep_HRG_BallisticBouncer_MuzzleFlash"

	Begin Object Name=FirstPersonMesh
		// new anim tree with skelcontrol to rotate cylinders
		AnimTreeTemplate=AnimTree'WEP_HRG_BallisticBouncer_ARCH.WEP_1stP_Animtree_HRG_BallisticBouncer'
	End Object

   	// Zooming/Position
	PlayerViewOffset=(X=0.0,Y=12,Z=-1)
	IronSightPosition=(X=0,Y=0,Z=0)
	
	// Controls the rotation when Hans(the bastard) grabs you
	QuickWeaponDownRotation=(Pitch=-19192,Yaw=-11500,Roll=16384) // (Pitch=-19192,Yaw=-11000,Roll=16384)

	// Ammo
	MagazineCapacity[0]=18
	SpareAmmoCapacity[0]=162
	InitialSpareMags[0]=3 //2
	AmmoPickupScale[0]=1.5 //1 //0.75
	bCanBeReloaded=true
	bReloadFromMagazine=true

	// Recoil
	maxRecoilPitch=180
	minRecoilPitch=140
	maxRecoilYaw=150
	minRecoilYaw=-150
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
	InventorySize=5
	GroupPriority=80 //75
	WeaponSelectTexture=Texture2D'wep_ui_hrg_ballisticbouncer_tex.UI_WeaponSelect_HRG_BallisticBouncer'

	// DEFAULT_FIREMODE
	//FireModeIconPaths(DEFAULT_FIREMODE)=Texture2D'ui_firemodes_tex.UI_FireModeSelect_Grenade' //@TODO: Replace me
	FireModeIconPaths(DEFAULT_FIREMODE)=Texture2D'ui_firemodes_tex.UI_FireModeSelect_ShotgunSingle'
	FiringStatesArray(DEFAULT_FIREMODE)=MineReconstructorCharge
	WeaponFireTypes(DEFAULT_FIREMODE)=EWFT_Projectile
    WeaponProjectiles(DEFAULT_FIREMODE)=class'KFProj_HRG_BallisticBouncer'
	FireInterval(DEFAULT_FIREMODE)=+0.223 //+0.33 
	InstantHitDamage(DEFAULT_FIREMODE)=100
	PenetrationPower(DEFAULT_FIREMODE)=0.0;
	InstantHitDamageTypes(DEFAULT_FIREMODE)=class'KFDT_Bludgeon_HRG_BallisticBouncer_Shot'
	FireOffset=(X=39,Y=4.5,Z=-10)
	
    // ALT_FIREMODE
	FiringStatesArray(ALTFIRE_FIREMODE)=WeaponFiring
	WeaponFireTypes(ALTFIRE_FIREMODE)=EWFT_None

	// BASH_FIREMODE
	InstantHitDamageTypes(BASH_FIREMODE)=class'KFDT_Bludgeon_HRG_BallisticBouncer'
	InstantHitDamage(BASH_FIREMODE)=27

	// Fire Effects
	WeaponFireSnd(DEFAULT_FIREMODE)=(DefaultCue=AkEvent'WW_WEP_HRG_BallisticBouncer.Play_WEP_HRG_BallisticBouncer_3P_Start', FirstPersonCue=AkEvent'WW_WEP_HRG_BallisticBouncer.Play_WEP_HRG_BallisticBouncer_1P_Start')
	WeaponFireLoopEndSnd(DEFAULT_FIREMODE)=(DefaultCue=AkEvent'WW_WEP_HRG_BallisticBouncer.Play_WEP_HRG_BallisticBouncer_3P_Shoot', FirstPersonCue=AkEvent'WW_WEP_HRG_BallisticBouncer.Play_WEP_HRG_BallisticBouncer_1P_Shoot')
	FullyChargedSound=(DefaultCue = AkEvent'WW_WEP_HRG_BallisticBouncer.Play_WEP_HRG_BallisticBouncer_Charged_3P', FirstPersonCue=AkEvent'WW_WEP_HRG_BallisticBouncer.Play_WEP_HRG_BallisticBouncer_Charged')

	WeaponDryFireSnd(DEFAULT_FIREMODE)=AkEvent'WW_WEP_HRG_BallisticBouncer.Play_WEP_HRG_BallisticBouncer_DryFire'

	// Advanced (High RPM) Fire Effects
	bLoopingFireAnim(DEFAULT_FIREMODE)=true
	bLoopingFireSnd(DEFAULT_FIREMODE)=true
	SingleFireSoundIndex=FIREMODE_NONE

	// Attachments
	bHasIronSights=true
	bHasFlashlight=false

   	AssociatedPerkClasses(0)= class'KFPerk_Support'

	WeaponFireWaveForm=ForceFeedbackWaveform'FX_ForceFeedback_ARCH.Gunfire.Weak_Recoil'
	
	ChargedEffect=ParticleSystem'WEP_HRG_BallisticBouncer_EMIT.FX_Mine_HRG_BallisticBouncer_FullCharge'

	FullChargedTimerInterval=2.0f

	// Weapon Upgrade stat boosts
	//WeaponUpgrades[1]=(IncrementDamage=1.1f,IncrementWeight=1)

	WeaponUpgrades[1]=(Stats=((Stat=EWUS_Damage0, Scale=1.15f), (Stat=EWUS_Weight, Add=1)))
	WeaponUpgrades[2]=(Stats=((Stat=EWUS_Damage0, Scale=1.3f), (Stat=EWUS_Weight, Add=2)))

	FXScalingFactorByCharge = 0;
	MinScale=0.5
	MaxScale=1.5

	bBlocked = false;

	bAllowClientAmmoTracking = false;

	ChargeStaticMesh = StaticMesh'WEP_HRG_BallisticBouncer_EMIT.HRG_BallisticBouncer_ball_MESH'
	MinProjPlaceholderScale = 2.0f;
	MaxProjPlaceholderScale = 3.0f;

	UseFixedPhysicalFireLocation=true
}