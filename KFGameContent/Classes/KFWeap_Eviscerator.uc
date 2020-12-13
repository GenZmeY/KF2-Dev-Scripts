//=============================================================================
// KFWeap_Eviscerator
//=============================================================================
// A hybrid melee weapon that shoots circular saw blades
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
// Andrew Ladenberger and John "Ramm-Jaeger" Gibson
//=============================================================================

class KFWeap_Eviscerator extends KFWeap_MeleeBase;

/** Anim names */
const IdleNoGasAnim = 'Idle_NoGas';
const BlockLoopNoGasAnim	= 'Brace_loop_NoGas';

/** BlendNode that's active while weapon has fuel */
var AnimNodeAdditiveBlending AdditiveBlendNode;
/** BlendNode that's active when primary ammo is empty */
var AnimNodeBlendPerBone OutOfBladesBlendNode;

/** Sound to play while weapon has fuel */
var AKEvent IdleMotorSound;

/** Short time from end of FireInterval when blocking can cancel the firing state */
var float BlockInterruptFiringTime;

//------------------------------------------------------------------------------

/**
 * Called immediately before gameplay begins.
 */
simulated event PreBeginPlay()
{
	Super.PreBeginPlay();

	// to prevent exploits the fire interrupt cannot be longer than the block intro
	BlockInterruptFiringTime = FMin(BlockInterruptFiringTime, MySkelMesh.GetAnimLength(MeleeBlockStartAnim));
}

/** The SkeletalMeshComponents Animations are being instanced from AnimTreeTemplate
* 	before PostInitAnimTree. Be sure to never set the Mesh's animations directly through
*	the package */
simulated event PostInitAnimTree(SkeletalMeshComponent SkelComp)
{
	Super.PostInitAnimTree(SkelComp);

	AdditiveBlendNode = AnimNodeAdditiveBlending(SkelComp.FindAnimNode('MotorAdditiveBlend'));
	OutOfBladesBlendNode = AnimNodeBlendPerBone(SkelComp.FindAnimNode('OutOfBladesBlend'));
}

/* OVERRIDE BECAUSE WE DONT NEED TO LOOK AT ALTFIRE_MODE, AS FOR MELEE WEAPONS IS THE BLOCK FIREMODE AND WILL RESULT IN 
	THE WEAPON ALWAYS GLOWING GREEN
 */

simulated function bool HasAnyAmmo()
{
	if ( HasSpareAmmo() || HasAmmo(DEFAULT_FIREMODE) )
	{
		return true;
	}

	if (MedicComp != none)
	{
		return false;
	}

    if( UsesSecondaryAmmo() && (HasSpareAmmo(HEAVY_ATK_FIREMODE) || HasAmmo(HEAVY_ATK_FIREMODE) ))
    {
		return true;
	}

	return false;
}

/*********************************************************************************************
 * @name		Ammunition
 ********************************************************************************************* */

/**
 * @see Weapon::StartFire
 */
simulated function StartFire(byte FireModeNum)
{
	// If we're out of fuel, do a melee 'bash' instead
	if( FireModeNum == HEAVY_ATK_FIREMODE && !HasAmmo(FireModeNum) )
	{
		FireModeNum = BASH_FIREMODE;
	}

	// skip MeleeBase logic
	Super(KFWeapon).StartFire(FireModeNum);
}

 /**
 * Returns which ammo pool a fire mode should pull from, primary or secondary.
 @ param    FiringMode  the fire mode we want to check against
 @ return   the ammo pool we should pull from for the input fire mode
 */
simulated function int GetAmmoType(byte FiringMode)
{
	//UI looking for altfire
    if( FiringMode == HEAVY_ATK_FIREMODE || FiringMode == ALTFIRE_FIREMODE)
	{
        return 1;
	}
    else
	{
        return 0;
	}
}

/*********************************************************************************************
 * @name		Firing / Projectile
********************************************************************************************* */

/** process local player impact for clientside hit detection */
event RecieveClientImpact(byte FiringMode, const out ImpactInfo Impact, optional out float PenetrationValue, optional int ImpactNum)
{
	if ( FiringMode == DEFAULT_FIREMODE )
	{
		super(KFWeapon).RecieveClientImpact(FiringMode, Impact, PenetrationValue);
	}
	else
	{
		MeleeAttackHelper.ProcessMeleeHit(FiringMode, Impact);
	}
}

/*********************************************************************************************
 * @section		Animation
********************************************************************************************* */

simulated function HideBlade()
{
    // @todo: remove this stub if/when we remove the notifies from the anim
}

simulated function UnHideBlade()
{
    // @todo: remove this stub if/when we remove the notifies from the anim
}

/** Check if we're out of blades or fuel and toggle effects accordingly */
simulated function UpdateOutOfAmmoEffects(float BlendTime)
{
	if ( AmmoCount[1] > 0 )
	{
		PlayIdleMotorSound();
		if ( AdditiveBlendNode != None )
		{
			AdditiveBlendNode.SetBlendTarget(1.f, BlendTime);
		}
	}
	else
	{
		StopIdleMotorSound();
		if ( AdditiveBlendNode != None )
		{
			AdditiveBlendNode.SetBlendTarget(0.f, BlendTime);
		}
	}

	if ( OutOfBladesBlendNode != None )
	{
		OutOfBladesBlendNode.SetBlendTarget((AmmoCount[0] > 0) ? 0.f : 1.f, BlendTime);
	}
}

/** Check to see if sound is already playing before calling SetWeaponAmbientSound */
simulated function PlayIdleMotorSound()
{
	local KFPawn P;
	P = KFPawn(Instigator);
	if ( P != None && P.WeaponAmbientSound != IdleMotorSound )
	{
		P.SetWeaponAmbientSound(IdleMotorSound);
	}
}

/** Check to see if sound is already stopped before calling SetWeaponAmbientSound */
simulated function StopIdleMotorSound()
{
	local KFPawn P;
	P = KFPawn(Instigator);
	if ( P != None && P.WeaponAmbientSound != None )
	{
		P.SetWeaponAmbientSound(None);
	}
}

/*********************************************************************************************
 * State Active
 * Extended to handle IdleMotorSound
 *********************************************************************************************/

simulated state Active
{
	simulated function BeginState(name PreviousStateName)
	{
		Super.BeginState(PreviousStateName);
		UpdateOutOfAmmoEffects(0.2f);
	}

	simulated function PlayIdleAnim()
	{
		if ( Instigator.IsFirstPerson() )
		{
			// If we're out of fuel play a special idle with no motor vibration
			if ( AmmoCount[1] <= 0 )
			{
				PlayAnimation(IdleNoGasAnim, 0.0, true, 0.2);
			}
			else
			{
				Super.PlayIdleAnim();
			}
		}
	}
}

/*********************************************************************************************
 * state Inactive
 * Extended to handle IdleMotorSound
 *********************************************************************************************/

auto state Inactive
{
	simulated function BeginState(name PreviousStateName)
	{
		Super.BeginState(PreviousStateName);
		StopIdleMotorSound();
	}

	// moved to kfweapon
	//simulated function EndState(Name NextStateName)
	//{
	//	Super.EndState(NextStateName);
	//	UpdateOutOfAmmoEffects(0.0f);
	//}
}

/*********************************************************************************************
 * State Reloading
 * This is the default Reloading State.  It's performed on both the client and the server.
 *********************************************************************************************/

simulated state Reloading
{
	simulated function BeginState(name PreviousStateName)
	{
		Super.BeginState(PreviousStateName);

		// When the player starts reload force unlock the OutOfBlades bones temporarily
		if ( OutOfBladesBlendNode != None )
		{
			OutOfBladesBlendNode.SetBlendTarget(0.f, 0.1f);
		}
	}
}

/** Called during reload state */
simulated function bool CanOverrideMagReload(byte FireModeNum)
{
	return super.CanOverrideMagReload(FireModeNum) || FireModeNum == BLOCK_FIREMODE || FireModeNum == HEAVY_ATK_FIREMODE;
}

/*********************************************************************************************
 * State MeleeBlocking
  * This is the default Blocking State.  It's performed on both the client and the server.
 *********************************************************************************************/

simulated state MeleeBlocking
{
	// Override to play BlockLoopNoGasAnim
	simulated function BlockLoopTimer()
	{
		if( AmmoCount[1] <= 0 && Instigator.IsLocallyControlled() )
		{
			PlayAnimation(BlockLoopNoGasAnim, , true);
		}

		Super.BlockLoopTimer();
	}
}

/*********************************************************************************************
 * State MeleeSustained
 * Derived to prevent Active:BeginState from playing the looping idle sound from UpdateOutOfAmmoEffects after the super changes the state to MeleeSustained
 *********************************************************************************************/

simulated state MeleeSustained
{
	// This prevents the Active:BeginState from playing the looping idle sound after the super changes the state to MeleeSustained
	ignores UpdateOutOfAmmoEffects;
}

/*********************************************************************************************
 * Trader
 ********************************************************************************************/

/** Allows weapon to calculate its own damage for display in trader
  * While eviscerator is a melee weapon, it does more damage with its default fire projectile
  */
static simulated function float CalculateTraderWeaponStatDamage()
{
	local float CalculatedDamage;
	local class<KFDamageType> DamageType;

	CalculatedDamage = default.InstantHitDamage[DEFAULT_FIREMODE];

	DamageType = class<KFDamageType>(default.InstantHitDamageTypes[DEFAULT_FIREMODE]);
	if( DamageType != none && DamageType.default.DoT_Type != DOT_None )
	{
		CalculatedDamage += (DamageType.default.DoT_Duration / DamageType.default.DoT_Interval) * (CalculatedDamage * DamageType.default.DoT_DamageScale);
	}

	return CalculatedDamage;
}

/** Returns trader filter index based on weapon type */
static simulated event EFilterTypeUI GetTraderFilter()
{
	return FT_Projectile;
}

static simulated event EFilterTypeUI GetAltTraderFilter()
{
	return FT_Melee;
}

/*********************************************************************************************
 * State WeaponSingleFiring
  * Handle special BlockInterruptTimer for this weapon's unusually long FireInterval
 *********************************************************************************************/

simulated function BlockInterruptTimer();

simulated state WeaponSingleFiring
{
	/** Set cooldown duration */
	simulated function BeginState( Name PreviousStateName )
	{
		local float CheckBlockInterruptTime;

		CheckBlockInterruptTime = FireInterval[CurrentFireMode] - BlockInterruptFiringTime;
		if ( BlockInterruptFiringTime > 0 && CheckBlockInterruptTime > 0 )
		{
			SetTimer(CheckBlockInterruptTime, false, nameof(BlockInterruptTimer));
		}

		Super.BeginState(PreviousStateName);
	}

	simulated function EndState(Name NextStateName)
	{
		ClearTimer( nameof(BlockInterruptTimer) );
		Super.EndState(NextStateName);
	}

	/** Check for pending fire */
	simulated function BlockInterruptTimer()
	{
		if ( PendingFire(BLOCK_FIREMODE) && HasAmmo(BLOCK_FIREMODE) )
		{
			SendToFiringState(BLOCK_FIREMODE);
		}
	}

	/** Check for interrupt near end of state */
	simulated function BeginFire(byte FireModeNum)
	{
		Global.BeginFire(FireModeNum);

		if ( FireModeNum == BLOCK_FIREMODE && BlockInterruptFiringTime > 0 )
		{
			if( HasAmmo(FireModeNum) && !IsTimerActive(nameof(BlockInterruptTimer)) )
			{
				SendToFiringState(FireModeNum);
			}
		}
	}
}

defaultproperties
{
	// Inventory
	GroupPriority=100
	InventorySize=9
	InventoryGroup=IG_Primary
	WeaponSelectTexture=Texture2D'ui_weaponselect_tex.UI_WeaponSelect_SawbladeShooter'
	SecondaryAmmoTexture=Texture2D'UI_SecondaryAmmo_TEX.GasTank'

	// Content
	PackageKey="SawBlade"
	FirstPersonMeshName="WEP_1P_SawBlade_MESH.Wep_1stP_SawBlade_Rig"
	FirstPersonAnimSetNames(0)="WEP_1P_SawBlade_ANIM.WEP_1P_SawBlade_ANIM"
	FirstPersonAnimTree="WEP_1P_SawBlade_ANIM.1P_Sawblade_Animtree"
	PickupMeshName="WEP_3P_SawBlade_MESH.Wep_SawShooter_Pickup"
	AttachmentArchetypeName="WEP_Sawblade_ARCH.Wep_Eviscerator_3P"
	MuzzleFlashTemplateName="WEP_Sawblade_ARCH.Wep_Sawblade_MuzzleFlash"

	Begin Object Name=MeleeHelper_0
		MaxHitRange=180
		WorldImpactEffects=KFImpactEffectInfo'FX_Impacts_ARCH.Bladed_melee_impact'
		MeleeImpactCamShake=CameraShake'FX_CameraShake_Arch.Melee.Eviscerator'
	End Object

	// ------------------------------------------------------------------------
	// Fire modes
	FiringStatesArray(DEFAULT_FIREMODE)=WeaponSingleFiring
	WeaponFireTypes(DEFAULT_FIREMODE)=EWFT_Projectile
	WeaponProjectiles(DEFAULT_FIREMODE)=class'KFProj_Blade_Eviscerator'
	InstantHitDamage(DEFAULT_FIREMODE)=300.0
	InstantHitDamageTypes(DEFAULT_FIREMODE)=class'KFDT_Slashing_EvisceratorProj'
	Spread(DEFAULT_FIREMODE)=0.02
	PenetrationPower(DEFAULT_FIREMODE)=4.0
	FireInterval(DEFAULT_FIREMODE)=0.95 // 63 RPM
	FireOffset=(X=25,Y=5.0,Z=-10)
	FireModeIconPaths(DEFAULT_FIREMODE)=Texture2D'ui_firemodes_tex.UI_FireModeSelect_Sawblade'
	AmmoCost(DEFAULT_FIREMODE) = 1
	BlockInterruptFiringTime=0.5

	// Saw attack (uses fuel)
	FiringStatesArray(HEAVY_ATK_FIREMODE)=MeleeSustained
	InstantHitDamage(HEAVY_ATK_FIREMODE)=29
	InstantHitDamageTypes(HEAVY_ATK_FIREMODE)=class'KFDT_Slashing_Eviscerator'
	FireInterval(HEAVY_ATK_FIREMODE)=+0.12
	AmmoCost(HEAVY_ATK_FIREMODE)=1
	MeleeSustainedWarmupTime=0.1

	// BASH_FIREMODE
	FiringStatesArray(BASH_FIREMODE)=MeleeAttackBasic
	WeaponFireTypes(BASH_FIREMODE)=EWFT_Custom
	InstantHitDamage(BASH_FIREMODE)=90
	InstantHitDamageTypes(BASH_FIREMODE)=class'KFDT_Slashing_Eviscerator'

	// RELOAD
	FiringStatesArray(RELOAD_FIREMODE)="Reloading"

	// Blocking
	ParryDamageMitigationPercent=0.3
	BlockDamageMitigation=0.4

    // Fire Effects
	WeaponFireSnd(DEFAULT_FIREMODE)=(DefaultCue=AkEvent'WW_WEP_SA_SawBlade.Play_WEP_SA_Sawblade_Fire_3P', FirstPersonCue=AkEvent'WW_WEP_SA_SawBlade.Play_WEP_SA_Sawblade_Fire_1P')
	WeaponDryFireSnd(DEFAULT_FIREMODE)=AkEvent'WW_WEP_SA_SawBlade.Play_WEP_SA_Sawblade_Handling_DryFire'
	// Altfire/MeleeSustained
	WeaponFireSnd(HEAVY_ATK_FIREMODE)=(DefaultCue=AkEvent'WW_WEP_SA_SawBlade.Play_WEP_SA_Sawblade_Fire_Alt_LoopStart_3P', FirstPersonCue=AkEvent'WW_WEP_SA_SawBlade.Play_WEP_SA_Sawblade_Fire_Alt_LoopStart_1P')
	WeaponFireLoopEndSnd(HEAVY_ATK_FIREMODE)=(DefaultCue=AkEvent'WW_WEP_SA_SawBlade.Play_WEP_SA_Sawblade_Fire_Alt_LoopEnd_3P', FirstPersonCue=AkEvent'WW_WEP_SA_SawBlade.Play_WEP_SA_Sawblade_Fire_Alt_LoopEnd_1P')
	bLoopingFireAnim(HEAVY_ATK_FIREMODE)=true
	bLoopingFireSnd(HEAVY_ATK_FIREMODE)=true
	WeaponDryFireSnd(HEAVY_ATK_FIREMODE)=AkEvent'WW_WEP_SA_SawBlade.Play_WEP_SA_Sawblade_Handling_DryFire'

	IdleMotorSound=AkEvent'WW_WEP_SA_SawBlade.Play_WEP_SA_Sawblade_Idle_Loop'

	// Ammo
	bCanBeReloaded=true
	bReloadFromMagazine=true
	MagazineCapacity[0]=5
	SpareAmmoCapacity[0]=25
	InitialSpareMags[0]=0
	MagazineCapacity[1]=250 // 30 seconds of fuel
	AmmoPickupScale[1]=0.2

	// Animation
	MeleeAttackAnims=(Atk_B)
	bHasFireLastAnims=true
	QuickWeaponDownRotation=(Pitch=-8192,Yaw=0,Roll=8192)

	// Block Sounds
	BlockSound=AkEvent'WW_WEP_Bullet_Impacts.Play_Block_MEL_Katana'
	ParrySound=AkEvent'WW_WEP_Bullet_Impacts.Play_Block_MEL_Katana'

	AssociatedPerkClasses(0)=class'KFPerk_Berserker'

    bHasLaserSight=TRUE

	ParryStrength=5

	// Eviscerator uses its own anim tree with its own specified bones to lock, so leave it alone
	BonesToLockOnEmpty.Empty()

	WeaponFireWaveForm=ForceFeedbackWaveform'FX_ForceFeedback_ARCH.Gunfire.Heavy_Recoil_SingleShot'

	// Weapon Upgrade stat boosts
	//WeaponUpgrades[1]=(IncrementDamage=1.1f,IncrementWeight=1)

	WeaponUpgrades[1]=(Stats=((Stat=EWUS_Damage0, Scale=1.1f), (Stat=EWUS_Damage1, Scale=1.1f), (Stat=EWUS_Damage2, Scale=1.1f),  (Stat=EWUS_Weight, Add=1)))
}