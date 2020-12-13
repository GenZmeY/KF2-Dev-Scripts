//=============================================================================
// KFWeap_MeleeBase
//=============================================================================
// Base class used for weapons where melee is the primary firemode
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
// - Andrew "Strago" Ladenberger
//=============================================================================
class KFWeap_MeleeBase extends KFWeapon
	abstract
	native;

/************************************************************************************
 * @name Firing / Timing / States
 ***********************************************************************************/

/** These override the base firemodes of the same ID (for readability) */
const BLOCK_FIREMODE		= 1; // ALTFIRE_FIREMODE
const HEAVY_ATK_FIREMODE	= 5; // NEW - IronSights Key

/** Set when blood material value is high */
var bool bIsBloody;

/** Maximum number of attacks that can be played without releasing fire */
var byte MaxChainAtkCount;

/** Minimum amount of time to go to the MeleeSustained state for */
var float MinMeleeSustainedTime;
/** Minimum amount of time to wait before dealing damage in the  MeleeSustained state */
var() float MeleeSustainedWarmupTime;
/** Amount of time required between cancelling attacks with reload*/
var private const float ReloadCancelTimeLimit;

/** Whether this can be interrupted by another attack/reload/etc. */
var bool StartFireDisabled;

/*********************************************************************************************
 * @name Defensive Abilities
 *********************************************************************************************/

struct native BlockEffectInfo
{
	var class<DamageType> DmgType;

	/** If != None, overrides the class default FX */
	var AkEvent 		BlockSound;
	var AkEvent			ParrySound;
	var ParticleSystem	BlockParticleSys;
	var ParticleSystem  ParryParticleSys;
};

var array<BlockEffectInfo> BlockTypes;

/** Damage while blocking will be mitigated by this percentage */
var() float BlockDamageMitigation;

/** Parry damage will be mitigated by this percentage */
var() float ParryDamageMitigationPercent;
/** Hit reaction strength to bypass pawn's ParryStumbleResist */
var() byte ParryStrength;

/** If true, owning pawn moves at a slower (iron sight) walking speed */
var bool bMoveAtWalkingSpeed;

/** Time between block hit reaction anims */
var() protected float BlockHitAnimCooldownTime;

/** The last time we played a block hit reaction anim */
var transient protected float LastBlockHitAnimTime;

/*********************************************************************************************
 * @name Animation
 *********************************************************************************************/

/** 4-way directional melee attack animation names */
const MeleeAttackAnim_F  = 'Atk_F';
const MeleeAttackAnim_B	 = 'Atk_B';
const MeleeAttackAnim_L  = 'Atk_L';
const MeleeAttackAnim_R  = 'Atk_R';

/** 4-way directional heavy attack animation names */
const MeleeHeavyAttackAnim_F = 'Atk_H_F';
const MeleeHeavyAttackAnim_B = 'Atk_H_B';
const MeleeHeavyAttackAnim_L = 'Atk_H_L';
const MeleeHeavyAttackAnim_R = 'Atk_H_R';

/** 8-way directional combo chain animation names */
const MeleeComboChainAnim_F	 = 'Combo_F';
const MeleeComboChainAnim_FL = 'Combo_FL';
const MeleeComboChainAnim_FR = 'Combo_FR';
const MeleeComboChainAnim_B  = 'Combo_B';
const MeleeComboChainAnim_BL = 'Combo_BL';
const MeleeComboChainAnim_BR = 'Combo_BR';
const MeleeComboChainAnim_L  = 'Combo_L';
const MeleeComboChainAnim_R  = 'Combo_R';

/** Special ability attacks */
const MeleeDrawStrikeAnim = 'Atk_Draw';

/** Defensive stance animation names */
const MeleeBlockStartAnim = 'Brace_in';
const MeleeBlockLoopAnim  = 'Brace_loop';
const MeleeBlockEndAnim   = 'Brace_out';

/** Weapon wear/cleaning */
const CleanBloodyAnim     = 'Clean_Blood';
const CleanNonBloodyAnim  = 'Clean_NoBlood';

/** MeleeSustained default anims - To modify this in a subclass override GetLoopingFireAnim, etc... */
const MeleeSustainedLoopAnim	= 'Atk_F_Loop';
const MeleeSustainedStartAnim	= 'Atk_F_In';
const MeleeSUstainedEndAnim		= 'Atk_F_Out';

/** Settle animations played after an attack */
var array<name> MeleeAttackSettleAnims;

/** Animations played on successful block */
var array<name> MeleeBlockHitAnims;

/*********************************************************************************************
 * @name	Effects
 ********************************************************************************************* */

/** (deprecated) particle system templates for trail notifies */
var ParticleSystem DistortTrailParticle;
var ParticleSystem WhiteTrailParticle;
var ParticleSystem BlueTrailParticle;
var ParticleSystem RedTrailParticle;

/** Block / Parry */
var AkBaseSoundObject BlockSound;
var AKBaseSoundObject ParrySound;
var ParticleSystem	  BlockParticleSystem;
var ParticleSystem	  ParryParticleSystem;
var name			  BlockEffectsSocketName;

/*********************************************************************************************
 * @name	Trader
 ********************************************************************************************* */

/** Estimated attack rate for this weapon, taking chaining, etc. into account.
  * Basically, just eyeball the animations and take an average.
 */
var() byte EstimatedFireRate;

cpptext
{
	// custom trail overrides
	virtual class UParticleSystem* GetAnimTrailParticleSystem(const class UAnimNotify_Trails* AnimNotifyData) const;
}

/*********************************************************************************************
 * @name		Instigator Movement Speed
********************************************************************************************* */

/** If TRUE, Instigator/Owner moves at walking speed when this weapon is equipped */
simulated function bool ShouldOwnerWalk()
{
	return bMoveAtWalkingSpeed;
}

/** Used to toggle bMoveAtWalkingSpeed */
simulated function SetSlowMovement(bool bEnabled)
{
	if ( Instigator.IsLocallyControlled() )
	{
		bMoveAtWalkingSpeed = bEnabled;

		if ( Role < ROLE_Authority )
		{
			ServerSetSlowMovement(bEnabled);
		}
	}
}

/** Called by local player to synchronize movement the same way ServerZoomIn/ServerZoomOut does */
reliable server function ServerSetSlowMovement(bool bEnabled)
{
	bMoveAtWalkingSpeed = bEnabled;
}

/*********************************************************************************************
 * @name		Firing / Projectile
********************************************************************************************* */

/**
 * @see Weapon::StartFire
 */
simulated function StartFire(byte FireModeNum)
{
	// can't start fire because it's in an uninterruptible state
	if (StartFireDisabled)
	{
		return;
	}

	// if the weapon is currently attacking
	if (CurrentFireMode == DEFAULT_FIREMODE || CurrentFireMode == ALTFIRE_FIREMODE || CurrentFireMode == BASH_FIREMODE)
	{
		// and the player tries to cancel with a reload action
		if(FireModeNum == RELOAD_FIREMODE)
		{
			// stop them from reload cancelling if it has already happened too recently
			if (IsTimerActive(nameof(Timer_FireCancel)))
			{
				return;
			}
			else
			{
				SetTimer(ReloadCancelTimeLimit, false, nameof(Timer_FireCancel));
			}
		}
	}
	// Get attack type and send to server
	if( FireModeNum == DEFAULT_FIREMODE || FireModeNum == HEAVY_ATK_FIREMODE )
	{
		StartMeleeFire(FireModeNum, MeleeAttackHelper.ChooseAttackDir(), ATK_Normal);
		return;
	}

	// If we're going to pretend bash is primary (see SendToFiringState) need to init directional melee
	if( FireModeNum == BASH_FIREMODE && WeaponFireTypes[FireModeNum] == EWFT_None )
	{
		StartMeleeFire(FireModeNum, MeleeAttackHelper.ChooseAttackDir(), ATK_Normal);
		return;
	}

	Super.StartFire(FireModeNum);
}

simulated function Timer_FireCancel() {}

/**
 * Like StartFire, but replicates a attack type
 * Network: LocalPlayer
 */
simulated function StartMeleeFire(byte FireModeNum, EPawnOctant AttackDir, EMeleeAttackType AtkType)
{
	MeleeAttackHelper.InitAttackSequence(AttackDir, AtkType);

	// derived from StartFire()
	if( Instigator == None || !Instigator.bNoWeaponFiring )
	{
		if( Role < Role_Authority )
		{
			// if we're a client, synchronize server
			ServerStartMeleeFire(FireModeNum, AttackDir, AtkType);
		}

		// Start fire locally
		BeginFire(FireModeNum);
	}
}

/**
 * Sets the desired attack type for an incoming melee fire mode
 * Network: Dedicated Server only, or Listen Server for remote clients.
 */
reliable server private function ServerStartMeleeFire(byte FireModeNum, EPawnOctant AttackDir, EMeleeAttackType AtkType)
{
	MeleeAttackHelper.InitAttackSequence(AttackDir, AtkType);
	Super.ServerStartFire(FireModeNum);
}

/** Instead of switch fire mode use as immediate alt fire */
simulated function AltFireMode()
{
	if ( !Instigator.IsLocallyControlled() )
	{
		return;
	}

	// StartFire - StopFire called from KFPlayerInput
	StartFire(BLOCK_FIREMODE);
}

/** Route ironsight player input to heavy attack */
simulated function SetIronSights(bool bNewIronSights)
{
	if ( !Instigator.IsLocallyControlled()  )
	{
		return;
	}

	if ( bNewIronSights )
	{
		StartFire(HEAVY_ATK_FIREMODE);
	}
	else
	{
		StopFire(HEAVY_ATK_FIREMODE);
	}
}

/**
 * Send weapon to proper firing state
 */
simulated function SendToFiringState(byte FireModeNum)
{
	// If we don't have anything assigned to BASH_FIREMODE (V) route to primary attack (LMB)
	if( FireModeNum == BASH_FIREMODE && WeaponFireTypes[FireModeNum] == EWFT_None )
	{
		Super.SendToFiringState(DEFAULT_FIREMODE);
		ClearPendingFire(BASH_FIREMODE);
	}

	Super.SendToFiringState(FireModeNum);
}

/*********************************************************************************************
 * @name		Damage
********************************************************************************************* */

/** process local player impact for clientside hit detection */
event RecieveClientImpact(byte FiringMode, const out ImpactInfo Impact, optional out float PenetrationValue, optional int ImpactNum)
{
	MeleeAttackHelper.ProcessMeleeHit(FiringMode, Impact);
}

/** returns the damage amount for this attack */
simulated function int GetMeleeDamage(byte FireModeNum, optional vector RayDir)
{
	local int Damage;
	local KFPerk InstigatorPerk;

	Damage = GetModifiedDamage(FireModeNum, RayDir);
	// decode damage scale (see GetDamageScaleByAngle) from the RayDir
	if ( !IsZero(RayDir) )
	{
		Damage = Round(float(Damage) * FMin(VSize(RayDir), 1.f));
	}

	InstigatorPerk = GetPerk();
	if( InstigatorPerk != none )
	{
		if( IsHeavyAttack( FireModeNum ) )
		{
			InstigatorPerk.ModifyHardAttackDamage( Damage );
		}
		else if( IsLightAttack(FireModeNum) )
		{
			InstigatorPerk.ModifyLightAttackDamage( Damage );
		}
	}

	return Damage;
}

/*********************************************************************************************
 * @name		Blood/Wear Effects
 *********************************************************************************************/

/** Increment bloody material parameter --- Network: Local Player */
simulated function AddBlood(float MinAmount, float MaxAmount)
{
	Super.AddBlood(MinAmount, MaxAmount);

	if ( !bIsBloody )
	{
		bIsBloody = true;
		ServerSetBloody(true);
	}
}

/** Syncronize this with the server for reloading state */
reliable server private function ServerSetBloody(bool bNewIsBloody)
{
	bIsBloody = bNewIsBloody;
}

/** Remove blood material parameter from this weapon */
simulated function ANIMNOTIFY_CleanBlood()
{
	local int i;

	bIsBloody = false;

	if ( WorldInfo.NetMode != NM_DedicatedServer && WeaponMICs.Length > 0 )
	{
		BloodParamValue = 0.f;

		for( i = 0; i < WeaponMICs.Length; ++i )
		{
			if( WeaponMICs[i] != none )
			{
				WeaponMICs[i].SetScalarParameterValue( BloodParamName, BloodParamValue );
			}
		}
	}
}

/*********************************************************************************************
 * @name		Animation
********************************************************************************************* */

/** Overriden to use WeaponAnimNodeSeq */
simulated function PlayWeaponAnimation(name Sequence, float fDesiredDuration, optional bool bLoop, optional SkeletalMeshComponent SkelMesh)
{
	Super.PlayWeaponAnimation(Sequence, fDesiredDuration, bLoop, SkelMesh);

	// Reset CameraAnim following
	bFollowAnimSeqCamera = default.bFollowAnimSeqCamera;
}

/** Called from the MeleeHelper class to allow for the weapon to override settings */
simulated function PlayMeleeAnimation(name AnimName, out float out_Rate, float BlendTime)
{
	Super.PlayMeleeAnimation(AnimName, out_Rate, BlendTime);

	// Enable CameraAnim following
	bFollowAnimSeqCamera = true;

	`DialogManager.PlayMeleeAttackDialog( KFPawn(Instigator), IsHeavyAttack(CurrentFireMode) );
}

/*********************************************************************************************
 * State WeaponUpkeep
 * A firemode that replaces reload where the user cleans or sharpens the weapon
 *********************************************************************************************/

simulated function UpkeepComplete();

/** Returns true if weapon can potentially be reloaded */
simulated function bool CanReload(optional byte FireModeNum)
{
	if ( FiringStatesArray[RELOAD_FIREMODE] == 'WeaponUpkeep' )
	{
		return true;
	}

	return Super.CanReload(FireModeNum);
}

simulated state WeaponUpkeep
{
	simulated function byte GetWeaponStateId()
	{
		return WEP_Cleaning;
	}

	simulated function BeginState(name PreviousStateName)
	{
		local name AnimName;
		local float Duration;

		// Calc Reload Duration
		AnimName = (bIsBloody) ? CleanBloodyAnim : CleanNonBloodyAnim;
		Duration = MySkelMesh.GetAnimInterruptTime(AnimName);

		if ( Duration > 0.f )
		{
			if ( Instigator.IsFirstPerson() )
			{
				PlayAnimation(AnimName);
			}

			SetTimer(Duration, FALSE, nameof(UpkeepComplete));
		}
		else
		{
			`warn("Duration is zero!!!"@AnimName);
			SetTimer(0.001, FALSE, nameof(UpkeepComplete));
		}

		NotifyBeginState();
	}

	// Allow for players to skip cleaning the weapon and go right into attacking.
	simulated function BeginFire(byte FireModeNum)
	{
		Global.BeginFire(FireModeNum);

		// handle reload interrupts
		if ( FireModeNum != RELOAD_FIREMODE )
		{
			// if able, immediately interupt/abort the reload state
			if( PendingFire(FireModeNum) && HasAmmo(FireModeNum) )
			{
                ClearPendingFire(RELOAD_FIREMODE);
				GotoState('Active');
			}
		}
	}

	simulated event EndState(Name NextStateName)
	{
		NotifyEndState();
	}

	/** Cleanup state */
	simulated function UpkeepComplete()
	{
		// we're done, leave state and go back to active
		GotoState('Active');
	}
}

simulated function bool CanOverrideMagReload(byte FireModeNum)
{
	return Super.CanOverrideMagReload(FireModeNum) || FireModeNum == GRENADE_FIREMODE;
}

/*********************************************************************************************
 * State MeleeChainAttacking
 * A melee firemode that chains together a sequence of attacks
 *********************************************************************************************/

simulated function bool IsLightAttack( byte FireMode );

simulated state MeleeChainAttacking extends MeleeAttackBasic
{
	simulated function BeginState(Name PrevStateName)
	{
		super.BeginState( PrevStateName );
	}

	simulated function byte GetWeaponStateId()
	{
		switch (MeleeAttackHelper.CurrentAttackDir)
		{
		case DIR_Forward:		return WEP_Melee_F;
		case DIR_ForwardLeft:	return WEP_Melee_F;
		case DIR_ForwardRight:	return WEP_Melee_F;
		case DIR_Backward:		return WEP_Melee_B;
		case DIR_BackwardLeft:	return WEP_Melee_B;
		case DIR_BackwardRight: return WEP_Melee_B;
		case DIR_Left:			return WEP_Melee_L;
		case DIR_Right:			return WEP_Melee_R;
		}

		return WEP_MeleeChain;
	}

	/** Called when primary fire is let go, or when ShouldContinueMelee returns false */
	simulated function EndState(Name NextStateName)
	{
		Super.EndState(NextStateName);

		PlayMeleeSettleAnim();

		// If both melee attacks are pressed, give priority to heavy attack.  Need
		// to do this because BeginFire is called in numeric order.
		if ( PendingFire(DEFAULT_FIREMODE) && PendingFire(HEAVY_ATK_FIREMODE) )
		{
			ClearPendingFire(DEFAULT_FIREMODE);
		}
	}

	/** Checks to see if we can perform another melee strike without changing states */
	simulated function bool ShouldContinueMelee(optional int ChainCount)
	{
		// If next attack is of a different fire mode we want leave the attacking state so
		// that the FiringState and FiringMode are properly updated for the new attack.
		if ( PendingFire(HEAVY_ATK_FIREMODE) )
		{
			return false;
		}

		// normal weapon path (pending fire, etc...)
		if ( !ShouldRefire() )
		{
			return false;
		}

		// make sure our firemode handler supports chain attacks
		if ( !MeleeAttackHelper.bHasChainAttacks )
		{
			return false;
		}

		return (ChainCount + 1) < MaxChainAtkCount;
	}

	/** Get name of the animation to play for PlayFireEffects */
	simulated function name GetMeleeAnimName(EPawnOctant AtkDir, EMeleeAttackType AtkType)
	{
		// Update our animation rate before changing weapon state to stay synced
		UpdateWeaponAttachmentAnimRate( GetThirdPersonAnimRate() );

		// update state id to match new attack direction
		KFPawn(Instigator).WeaponStateChanged(GetWeaponStateId());

		// primary / normal strikes and chain attacks
		if ( AtkType == ATK_Combo )
		{
			switch (AtkDir)
			{
			case DIR_Forward:		return MeleeComboChainAnim_F;
			case DIR_ForwardLeft:	return MeleeComboChainAnim_FL;
			case DIR_ForwardRight:	return MeleeComboChainAnim_FR;
			case DIR_Backward:		return FRand() < 0.5f ? MeleeComboChainAnim_BL : MeleeComboChainAnim_BR;
			case DIR_BackwardLeft:	return MeleeComboChainAnim_BL;
			case DIR_BackwardRight: return MeleeComboChainAnim_BR;
			case DIR_Left:			return MeleeComboChainAnim_L;
			case DIR_Right:			return MeleeComboChainAnim_R;
			}
		}

		switch (AtkDir)
		{
		case DIR_Forward:		return MeleeAttackAnim_F;
		case DIR_ForwardLeft:	return MeleeAttackAnim_F;
		case DIR_ForwardRight:	return MeleeAttackAnim_F;
		case DIR_Backward:		return MeleeAttackAnim_B;
		case DIR_BackwardLeft:	return MeleeAttackAnim_B;
		case DIR_BackwardRight: return MeleeAttackAnim_B;
		case DIR_Left:			return MeleeAttackAnim_L;
		case DIR_Right:			return MeleeAttackAnim_R;
		}
	}

	simulated function bool IsLightAttack( byte FireMode )
	{
		return true;
	}

	/** Gets the current animation rate, scaled or not */
	simulated function float GetThirdPersonAnimRate()
	{
		local float ScaledRate;

		ScaledRate = EvalInterpCurveFloat( MeleeAttackHelper.FatigueCurve, MeleeAttackHelper.NumChainedAttacks );
		ModifyMeleeAttackSpeed(ScaledRate, CurrentFireMode);

		return 1.f / ScaledRate;
	}
}

/** Plays a 'settle' animation after a melee attack is finished */
simulated function PlayMeleeSettleAnim()
{
	local int AnimIdx;

	if( MeleeAttackSettleAnims.Length > 0 )
	{
		AnimIdx = Rand(MeleeAttackSettleAnims.Length);
		PlayAnimation(MeleeAttackSettleAnims[AnimIdx], 0.0, false, 0.1);
	}
}

/*********************************************************************************************
 * State MeleeHeavyAttacking
 * This is the alt-fire Melee State.
 *********************************************************************************************/

simulated function bool IsHeavyAttack(byte FireMode);

simulated state MeleeHeavyAttacking extends MeleeAttackBasic
{
	simulated function byte GetWeaponStateId()
	{
		switch (MeleeAttackHelper.CurrentAttackDir)
		{
		case DIR_Forward:		return WEP_MeleeHeavy_F;
		case DIR_ForwardLeft:	return WEP_MeleeHeavy_F;
		case DIR_ForwardRight:	return WEP_MeleeHeavy_F;
		case DIR_Backward:		return WEP_MeleeHeavy_B;
		case DIR_BackwardLeft:	return WEP_MeleeHeavy_B;
		case DIR_BackwardRight: return WEP_MeleeHeavy_B;
		case DIR_Left:			return WEP_MeleeHeavy_L;
		case DIR_Right:			return WEP_MeleeHeavy_R;
		}

		return WEP_Idle;
	}

	simulated function BeginState(name PreviousStateName)
    {
   		Super.BeginState(PreviousStateName);

		// freeze the player for a short time for heavy damage strikes
		if ( Instigator.IsLocallyControlled() )
		{
			KFPlayerController(Instigator.Controller).PauseMoveInput(0.1f);
		}
	}

	simulated function EndState(Name NextStateName)
	{
		Super.EndState(NextStateName);
		PlayMeleeSettleAnim();
	}

	/** heavy damage attack anims */
	simulated function name GetMeleeAnimName(EPawnOctant AtkDir, EMeleeAttackType AtkType)
	{
		// heavy damage attacks
		if ( AtkType == ATK_DrawStrike )
		{
			return MeleeDrawStrikeAnim;
		}

		switch (AtkDir)
		{
		case DIR_Forward:		return MeleeHeavyAttackAnim_F;
		case DIR_ForwardLeft:	return MeleeHeavyAttackAnim_F;
		case DIR_ForwardRight:	return MeleeHeavyAttackAnim_F;
		case DIR_Backward:		return MeleeHeavyAttackAnim_B;
		case DIR_BackwardLeft:	return MeleeHeavyAttackAnim_B;
		case DIR_BackwardRight: return MeleeHeavyAttackAnim_B;
		case DIR_Left:			return MeleeHeavyAttackAnim_L;
		case DIR_Right:			return MeleeHeavyAttackAnim_R;
		}
	}

	simulated function bool IsHeavyAttack(byte FireMode)
	{
		return true;
	}
}

/*********************************************************************************************
 * State MeleeSustained
  * A special melee state used for chainsaw like weapons.  Extends WeaponFiring which is a
  * bit odd, but it shares more in common with it than it does with MeleeAttackBasic
 *********************************************************************************************/

// Global declarations for this state
function SustainedMinFireTimer();
function SustainedWarmupEndTimer();

simulated state MeleeSustained extends WeaponFiring
{
	ignores AllowSprinting, AllowIronSights;

	simulated function bool IsMeleeing()
	{
		return TRUE;
	}

	simulated function BeginState(Name PreviousStateName)
	{
		// @note: No super because we don't want to FireAmmunition() right away
		local KFPerk InstigatorPerk;

		InstigatorPerk = GetPerk();
		if( InstigatorPerk != none )
		{
			SetZedTimeResist( InstigatorPerk.GetZedTimeModifier(self) );
		}

		if ( MeleeSustainedWarmupTime > 0.f )
		{
			SetTimer(MeleeSustainedWarmupTime, false, nameof(SustainedWarmupEndTimer));
		}
		else
		{
			SustainedWarmupEndTimer();
		}

		StartLoopingFireEffects(CurrentFireMode, true);
		NotifyBeginState();
	}

	simulated function EndState(Name NextStateName)
	{
		Super.EndState(NextStateName);
		NotifyEndState();
	}

	/** Handle MinMeleeSustainedTime */
	simulated function bool StillFiring(byte FireMode)
	{
		if ( Global.StillFiring(FireMode) || IsTimerActive(nameof(SustainedMinFireTimer)) )
		{
			return true;
		}
		return false;
	}

	/** Called after warmup when weapon is ready to fire */
	simulated function SustainedWarmupEndTimer()
	{
		// Do the first damage right away, we've already waited for the warmup time
		FireAmmunition();
		TimeWeaponFiring(CurrentFireMode);

		if ( MinMeleeSustainedTime > 0.f )
		{
			SetTimer(MinMeleeSustainedTime, false, nameof(SustainedMinFireTimer));
		}
	}

	/** Performs melee hit detection and does damage */
    simulated function FireAmmunition()
	{
		HandleWeaponShotTaken( CurrentFireMode );
        MeleeAttackHelper.bHitEnemyThisAttack = false;
        MeleeAttackHelper.MeleeAttackImpact();

    	// Use ammunition to fire
    	ConsumeAmmo( CurrentFireMode );
	}

	/** Get name of the animation to play for PlayFireEffects */
	simulated function name GetLoopingFireAnim(byte FireModeNum)
	{
		return MeleeSustainedLoopAnim;
	}

	/** Get name of the animation to play for PlayFireEffects */
	simulated function name GetLoopStartFireAnim(byte FireModeNum)
	{
		return MeleeSustainedStartAnim;
	}

	/** Get name of the animation to play for PlayFireEffects */
	simulated function name GetLoopEndFireAnim(byte FireModeNum)
	{
		return MeleeSustainedEndAnim;
	}

	simulated function byte GetWeaponStateId()
	{
		return WEP_MeleeSustained;
	}
}

/*********************************************************************************************
 * State MeleeBlocking
  * This is the default Blocking State.  It's performed on both the client and the server.
 *********************************************************************************************/

// Global declarations for blocking state
simulated function BlockLoopTimer();
simulated function ParryCheckTimer();

/** Called on the server when successfully block/parry an attack */
unreliable client function ClientPlayBlockEffects(optional byte BlockTypeIndex=255)
{
	local AkBaseSoundObject Sound;
	local ParticleSystem PSTemplate;

	GetBlockEffects(BlockTypeIndex, Sound, PSTemplate);
	PlayLocalBlockEffects(Sound, PSTemplate);
}

/** Called on the server when successfully block/parry an attack */
reliable client function ClientPlayParryEffects(optional byte BlockTypeIndex=255)
{
	local AkBaseSoundObject Sound;
	local ParticleSystem PSTemplate;
	local KFPerk InstigatorPerk;

	InstigatorPerk = GetPerk();
	if( InstigatorPerk != none )
	{
		InstigatorPerk.SetSuccessfullParry();
	}

	GetParryEffects(BlockTypeIndex, Sound, PSTemplate);
	PlayLocalBlockEffects(Sound, PSTemplate);
}

simulated function NotifyAttackParried();
simulated function NotifyAttackBlocked();

simulated state MeleeBlocking
{
	ignores ForceReload, ShouldAutoReload;

	simulated function byte GetWeaponStateId()
	{
		return WEP_MeleeBlock;
	}

	simulated function BeginState(name PreviousStateName)
    {
    	local float ParryDuration;

   		ParryDuration = PlayBlockStart();

		// Set the duration of the window to parry incoming attacks
		if ( ParryDuration > 0.f )
		{
			SetTimer( ParryDuration, false, nameof(ParryCheckTimer) );
		}

		NotifyBeginState();
	}

	simulated function EndState(Name NextStateName)
	{
		if ( Instigator.IsLocallyControlled() )
		{
			PlayAnimation(MeleeBlockEndAnim);
		}

		//SetSlowMovement(false);
		NotifyEndState();
	}

	/** Return to active state if we're done blocking */
	simulated function EndFire(byte FireModeNum)
	{
		Global.EndFire(FireModeNum);

		// Wait until parry is finished, then check PendingFire to stop blocking
		if ( !StillFiring(CurrentFireMode) && !IsTimerActive(nameof(ParryCheckTimer)) )
		{
			GotoState('BlockingCooldown');
		}
	}

	/** After the parry window is finished, check PendingFire to see if we're still blocking */
	simulated function ParryCheckTimer()
	{
		// Check PendingFire to stop blocking
		if ( !StillFiring(CurrentFireMode) )
		{
			GotoState('BlockingCooldown');
		}
	}

	/** Grab/Grapple attacks can be parried */
	function bool IsGrappleBlocked(Pawn InstigatedBy)
	{
		local float FacingDot;
		local vector Dir2d;

		// zero Z to give us a 2d dot product
		Dir2d = Normal2d(InstigatedBy.Location - Instigator.Location);
		FacingDot = vector(Instigator.Rotation) dot (Dir2d);

		// Cos(85)
		if ( FacingDot > 0.087f )
		{
			if ( IsTimerActive(nameof(ParryCheckTimer)) )
			{
				KFPawn(InstigatedBy).NotifyAttackParried(Instigator, 255);
				ClientPlayParryEffects();
				NotifyAttackParried();
			}
			else
			{
				ClientPlayBlockEffects();
				NotifyAttackBlocked();
			}

			return TRUE;
		}
		return FALSE;
	}

	/** While holding a melee weapon reduce some incoming damage */
	function AdjustDamage(out int InDamage, class<DamageType> DamageType, Actor DamageCauser)
	{
		local float FacingDot;
		local vector Dir2d;
		local KFPerk InstigatorPerk;
		local byte BlockTypeIndex;

		// don't apply block/parry effects for teammates
		if (Instigator.IsSameTeam(DamageCauser.Instigator))
		{
			return;
		}

		// zero Z to give us a 2d dot product
		Dir2d = Normal2d(DamageCauser.Location - Instigator.Location);
		FacingDot = vector(Instigator.Rotation) dot (Dir2d);

		// Cos(85)
		if ( FacingDot > 0.087f && CanBlockDamageType(DamageType, BlockTypeIndex) )
		{
			InstigatorPerk = GetPerk();

			if ( IsTimerActive(nameof(ParryCheckTimer)) )
			{
				InDamage *= GetUpgradedParryDamageMitigation(CurrentWeaponUpgradeIndex);
				// Notify attacking pawn for effects / animations
				if ( KFPawn(DamageCauser) != None )
				{
					KFPawn(DamageCauser).NotifyAttackParried(Instigator, ParryStrength);
				}

				// @NOTE: This is now always true per discussion with AndrewL on KFII-29686. Since we always
				// do the damage mitigation, we should always play the effect regardless of whether the
				// zed was stumbled or knocked down. -MattF
				ClientPlayParryEffects(BlockTypeIndex);

				NotifyAttackParried();

				if( InstigatorPerk != none )
				{
					InstigatorPerk.SetSuccessfullParry();
				}
			}
			else
			{
				InDamage *= GetUpgradedBlockDamageMitigation(CurrentWeaponUpgradeIndex);
				ClientPlayBlockEffects(BlockTypeIndex);

				NotifyAttackBlocked();

				if( InstigatorPerk != none )
				{
					InstigatorPerk.SetSuccessfullBlock();
				}
			}
		}
	}

	simulated function BlockLoopTimer()
	{
		if( Instigator.IsLocallyControlled() )
		{
			PlayAnimation(MeleeBlockLoopAnim, , true);
		}
	}

	/** State override for Block_Hit animations */
	unreliable client function ClientPlayBlockEffects(optional byte BlockTypeIndex=255)
	{
		local int AnimIdx;
		local float Duration;
		local KFPerk InstigatorPerk;

		Global.ClientPlayBlockEffects(BlockTypeIndex);

		InstigatorPerk = GetPerk();
		if( InstigatorPerk != none )
		{
			InstigatorPerk.SetSuccessfullBlock();
		}

		if( MeleeBlockHitAnims.Length > 0 && `TimeSince(LastBlockHitAnimTime) > BlockHitAnimCooldownTime && !IsTimerActive(nameof(ParryCheckTimer)) )
		{
			AnimIdx = Rand(MeleeBlockHitAnims.Length);
			Duration = MySkelMesh.GetAnimLength(MeleeBlockHitAnims[AnimIdx]);

			if ( Duration > 0 )
			{
				LastBlockHitAnimTime = WorldInfo.TimeSeconds;
				PlayAnimation(MeleeBlockHitAnims[AnimIdx]);
				SetTimer(Duration, false, nameof(BlockLoopTimer));
			}
		}
	}
}

simulated function float PlayBlockStart()
{
	local float AnimDuration;

	if( Instigator.IsLocallyControlled() )
	{
		PlayAnimation(MeleeBlockStartAnim);
	}

	// set when to start playing the looping anim
	AnimDuration = MySkelMesh.GetAnimLength(MeleeBlockStartAnim);
	if ( AnimDuration > 0.f )
	{
		SetTimer(AnimDuration, false, nameof(BlockLoopTimer));
	}
	else
	{
		BlockLoopTimer();
	}

	// set the parry duration to the same as the block start anim
	return AnimDuration;
}

/** Called on the client when successfully block/parry an attack */
simulated function PlayLocalBlockEffects(AKBaseSoundObject Sound, ParticleSystem PSTemplate)
{
	local vector Loc;
	local rotator Rot;
	local ParticleSystemComponent PSC;

	if ( Sound != None )
	{
		PlaySoundBase(Sound, true);
	}

	if ( PSTemplate != None )
	{
		if ( MySkelMesh.GetSocketWorldLocationAndRotation(BlockEffectsSocketName, Loc, Rot) )
		{
			PSC = WorldInfo.MyEmitterPool.SpawnEmitter(PSTemplate, Loc,  Rot);
			PSC.SetDepthPriorityGroup(SDPG_Foreground);
		}
		else
		{
			`log(self@GetFuncName()@"missing BlockEffects Socket!");
		}
	}
}

/** If true, this damage type can be blocked by the MeleeBlocking state */
function bool CanBlockDamageType(class<DamageType> DamageType, optional out byte out_Idx)
{
	local int Idx;

	// Check if this damage should be ignored completely
	for (Idx = 0; Idx < BlockTypes.length; ++Idx)
	{
		if ( ClassIsChildOf(DamageType, BlockTypes[Idx].DmgType) )
		{
			out_Idx = Idx;
			return true;
		}
	}

	out_Idx = INDEX_NONE;
	return false;
}

/** Returns sound and particle system overrides using index into BlockTypes array */
simulated function GetBlockEffects(byte BlockIndex, out AKBaseSoundObject outSound, out ParticleSystem outParticleSys)
{
	outSound = BlockSound;
	outParticleSys = BlockParticleSystem;

	if ( BlockIndex != 255 )
	{
		if ( BlockTypes[BlockIndex].BlockSound != None )
		{
			outSound = BlockTypes[BlockIndex].BlockSound;
		}
		if ( BlockTypes[BlockIndex].BlockParticleSys != None )
		{
			outParticleSys = BlockTypes[BlockIndex].BlockParticleSys;
		}
	}
}

/** Returns sound and particle system overrides using index into BlockTypes array */
simulated function GetParryEffects(byte BlockIndex, out AKBaseSoundObject outSound, out ParticleSystem outParticleSys)
{
	outSound = ParrySound;
	outParticleSys = ParryParticleSystem;

	if ( BlockIndex != 255 )
	{
		if ( BlockTypes[BlockIndex].ParrySound != None )
		{
			outSound = BlockTypes[BlockIndex].ParrySound;
		}
		if ( BlockTypes[BlockIndex].ParryParticleSys != None )
		{
			outParticleSys = BlockTypes[BlockIndex].ParryParticleSys;
		}
	}
}

/*********************************************************************************************
 * State BlockingCooldown
  * A short cooldown state to prevent spamming block while still allowing pendingfire to be set
 *********************************************************************************************/

// Global declarations for this state
simulated function BlockCooldownTimer();

simulated state BlockingCooldown extends Active
{
	ignores AllowSprinting;

	/** Set cooldown duration */
	simulated function BeginState( Name PreviousStateName )
	{
		SetTimer(0.5, false, nameof(BlockCooldownTimer));
		Super.BeginState(PreviousStateName);
	}

	// prevent going to block/parry state
	simulated function bool HasAmmo( byte FireModeNum, optional int Amount )
	{
		if ( FireModeNum == BLOCK_FIREMODE )
		{
			return false;
		}

		return Global.HasAmmo(FireModeNum, Amount);
	}

	// prevent HasAmmo (above) from causing an auto reload
	simulated function bool ShouldAutoReload(byte FireModeNum)
	{
		if ( FireModeNum == BLOCK_FIREMODE )
		{
			return false;
		}

		return Global.ShouldAutoReload(FireModeNum);
	}

	simulated function BlockCooldownTimer()
	{
		GotoState('Active');
	}
}

/*********************************************************************************************
 * State WeaponEquipping
 * Overridden for DrawStrike ability
*********************************************************************************************/

/** Perform a special attack animation while equipping */
simulated function ANIMNOTIFY_DrawAtk();
simulated function AttemptDrawStrike();

simulated state WeaponEquipping
{
	/** Override BeginFire so that it will enter the firing state right away. */
	simulated function ANIMNOTIFY_DrawAtk()
	{
		// wait a short time because we can't call SetAnim during a notify
		SetTimer(0.001f, false, nameof(AttemptDrawStrike));
	}

	/** If melee attack fire modes are pending, perform draw strike */
	simulated function AttemptDrawStrike()
	{
	    // if either of the fire modes are pending, perform them
		if ( PendingFire(DEFAULT_FIREMODE) || PendingFire(HEAVY_ATK_FIREMODE) )
		{
			MeleeAttackHelper.InitAttackSequence(DIR_Right, ATK_DrawStrike);
			SendToFiringState(HEAVY_ATK_FIREMODE);
		}
	}
}

/*********************************************************************************************
 * Trader
 ********************************************************************************************/

/** Allows weapon to set its own trader stats (can set number of stats, names and values of stats) */
static simulated event SetTraderWeaponStats( out array<STraderItemWeaponStats> WeaponStats )
{
	super.SetTraderWeaponStats( WeaponStats );

	WeaponStats.Length = WeaponStats.Length + 1;
	WeaponStats[WeaponStats.Length-1].StatType = TWS_Block;
	WeaponStats[WeaponStats.Length-1].StatValue = GetUpgradedBlockDamageMitigation(0);

	WeaponStats.Length = WeaponStats.Length + 1;
	WeaponStats[WeaponStats.Length-1].StatType = TWS_Parry;
	WeaponStats[WeaponStats.Length-1].StatValue = GetUpgradedParryDamageMitigation(0);
}

/** Allows weapon to calculate its own damage for display in trader
  * In general, melee weapons should use heavy attack to determine damage
  */
static simulated function float CalculateTraderWeaponStatDamage()
{
	local float CalculatedDamage;
	local class<KFDamageType> DamageType;

	CalculatedDamage = default.InstantHitDamage[HEAVY_ATK_FIREMODE];

	DamageType = class<KFDamageType>(default.InstantHitDamageTypes[HEAVY_ATK_FIREMODE]);
	if( DamageType != none && DamageType.default.DoT_Type != DOT_None )
	{
		CalculatedDamage += (DamageType.default.DoT_Duration / DamageType.default.DoT_Interval) * (CalculatedDamage * DamageType.default.DoT_DamageScale);
	}

	return CalculatedDamage;
}

/** Allows weapon to calculate its own fire rate for display in trader.
  * Overridden to use estimated fire rate.
  */
static simulated function float CalculateTraderWeaponStatFireRate()
{
	// attack interval in anim-based, so there's no way to compute it programatically from the editor, where
	// this function is called from.

	return default.EstimatedFireRate;
}

/** Returns trader filter index based on weapon type */
static simulated event EFilterTypeUI GetTraderFilter()
{
	return FT_Melee;
}

/*********************************************************************************************
 * Upgrades
 ********************************************************************************************/

static simulated function float GetUpgradedBlockDamageMitigation(int UpgradeIndex)
{
	return GetUpgradedStatValue(default.BlockDamageMitigation, EWUS_BlockDmgMitigation, UpgradeIndex);
}

static simulated function float GetUpgradedParryDamageMitigation(int UpgradeIndex)
{
	return GetUpgradedStatValue(default.ParryDamageMitigationPercent, EWUS_ParryDmgMitigation, UpgradeIndex);
}

defaultproperties
{
	InventoryGroup=IG_Melee
	bMeleeWeapon=true

	Begin Object Name=FirstPersonMesh
		// Set MinTickTimeStep to ensure a high enough tickrate for melee hitbox collision
		MinTickTimeStep=0.025f // 40fps
	End Object

	// DEFAULT_FIREMODE
	FireModeIconPaths(DEFAULT_FIREMODE)=Texture2D'ui_firemodes_tex.UI_FireModeSelect_Melee'
	FiringStatesArray(DEFAULT_FIREMODE)=MeleeChainAttacking
	WeaponFireTypes(DEFAULT_FIREMODE)=EWFT_Custom
	InstantHitDamageTypes(DEFAULT_FIREMODE)=class'KFDT_Slashing'
	InstantHitDamage(DEFAULT_FIREMODE)=20
	AmmoCost(DEFAULT_FIREMODE)=0

	// ALT_FIREMODE
	FireModeIconPaths(HEAVY_ATK_FIREMODE)=Texture2D'ui_firemodes_tex.UI_FireModeSelect_Melee'
	FiringStatesArray(HEAVY_ATK_FIREMODE)=MeleeHeavyAttacking
	WeaponFireTypes(HEAVY_ATK_FIREMODE)=EWFT_Custom
	InstantHitDamageTypes(HEAVY_ATK_FIREMODE)=class'KFDT_Slashing'
	InstantHitDamage(HEAVY_ATK_FIREMODE)=50
	InstantHitMomentum(HEAVY_ATK_FIREMODE)=1.f
	AmmoCost(HEAVY_ATK_FIREMODE)=0

	// RELOAD_FIREMODE
	FiringStatesArray(RELOAD_FIREMODE)=WeaponUpkeep

	// MELEE_BLOCK_FIREMODE
	FiringStatesArray(BLOCK_FIREMODE)=MeleeBlocking
	WeaponFireTypes(BLOCK_FIREMODE)=EWFT_Custom
	FireInterval(BLOCK_FIREMODE)=1.f
	AmmoCost(BLOCK_FIREMODE)=0

	Begin Object Name=MeleeHelper_0
		bUseDirectionalMelee=true
		bHasChainAttacks=true
		bUseMeleeHitTimer=false
		MaxHitRange=150
	End Object

	// default MIC param names
	BlockEffectsSocketName=BlockEffect

	// Attachments
	bHasIronSights=false
	bHasFlashlight=false

	// Aim Assist
	AimCorrectionSize=0.f
	bTargetAdhesionEnabled=false

	//--------------------------------
	// Defensive
	BlockDamageMitigation=0.50f
	ParryDamageMitigationPercent=0.2
	ParryStrength=4
	BlockHitAnimCooldownTime=0.5f
	BlockTypes.Add((DmgType=class'KFDT_Bludgeon'))
	BlockTypes.Add((DmgType=class'KFDT_Slashing'))

	BlockSound=none
	ParrySound=none
	BlockParticleSystem=ParticleSystem'FX_Impacts_EMIT.FX_Block_melee_01'
	ParryParticleSystem=ParticleSystem'FX_Impacts_EMIT.FX_Parry_melee_01'
	MeleeBlockHitAnims=(Block_Hit_V1, Block_Hit_V2, Block_Hit_V3);

	DistortTrailParticle = ParticleSystem'FX_Gameplay_EMIT_THREE.Trails.FX_Trail_Distort_R_01'
	WhiteTrailParticle = ParticleSystem'FX_Gameplay_EMIT_THREE.Trails.FX_Trail_White_R_01'
	BlueTrailParticle = ParticleSystem'FX_Gameplay_EMIT_THREE.Trails.FX_Trail_Blue_R_01'
	RedTrailParticle = ParticleSystem'FX_Gameplay_EMIT_THREE.Trails.FX_Trail_Red_R_01'

	//--------------------------------
	// Animations
	MaxChainAtkCount = 3
	MeleeAttackSettleAnims.Add(Settle_V1)
	MinMeleeSustainedTime = 0.5f
	MeleeSustainedWarmupTime = 0.25f

	// Trader
	EstimatedFireRate = 100

	// Upgrades
	UpgradeFireModes(BLOCK_FIREMODE) = 0
	UpgradeFireModes(HEAVY_ATK_FIREMODE) = 1
	UpgradeFireModes(CUSTOM_FIREMODE) = 1

	ReloadCancelTimeLimit = 0.5f;
}
