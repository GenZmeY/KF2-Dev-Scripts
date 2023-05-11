//=============================================================================
// KFWeap_ThrownBase
//=============================================================================
// Base class used for weapons that are thrown
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
// - Jeff Robinson
//=============================================================================
class KFWeap_ThrownBase extends KFWeapon
	abstract;

const THROW_FIREMODE		= 0; // DEFAULT_FIREMODE

var(Animations) const editconst array<name> IdleLastAnims;
var(Animations) const editconst array<name>	IdleLastPickupAnims;

/** Default melee attack animation names when out of ammo */
var(Animations) const editconst array<name> MeleeAttackLastAnims;

var(Animations) const editconst name		EquipLastAnim;
var(Animations) const editconst name		PutDownLastAnim;

const SprintInLastAnim = 'Sprint_In_Last';
const SprintLoopLastAnim = 'Sprint_Loop_Last';
const SprintOutLastAnim = 'Sprint_Out_Last';

const NadeThrowLastAnim = 'Nade_Throw_Last';

/** Time between throwing a projectile and modifying spare ammo since we don't do a proper reload */
var float ConsumeSpareAmmoDelay;

/** If set execute PerformReload on client only and synchronize at end of state 
  * MUST MATCH SAME DEFINE IN KFWEAPON
  */
`define USE_RELOAD_SYNC		1

/** Whether we should use "last" (empty-handed) anims */
simulated function bool ShouldPlayLastAnims()
{
	return GetTotalAmmoAmount(THROW_FIREMODE) <= 0;
}

/** Get name of the animation to play for PlayFireEffects */
simulated function name GetMeleeAnimName(EPawnOctant AtkDir, EMeleeAttackType AtkType)
{
	local int idx;

	if( ShouldPlayLastAnims() )
	{
		if( MeleeAttackLastAnims.Length > 0 )
		{
			// These are randomely selected, so anim lengths should match!
			idx = Rand(MeleeAttackLastAnims.Length);
			return MeleeAttackLastAnims[idx];
		}
	}
	else
	{
		if( MeleeAttackAnims.Length > 0 )
		{
			// These are randomely selected, so anim lengths should match!
			idx = Rand(MeleeAttackAnims.Length);
			return MeleeAttackAnims[idx];
		}
	}
}

/** Get putdown anim name 
  * Overridden to play "last" anim  
  */
simulated function name GetWeaponPutDownAnimName()
{
	return ShouldPlayLastAnims() ? PutDownLastAnim : super.GetWeaponPutDownAnimName();
}

/** Get sprint start anim name 
  * Overridden to play "last" anim  
  */
simulated function name GetSprintStartAnimName()
{
	return ShouldPlayLastAnims() ? SprintInLastAnim : super.GetSprintStartAnimName();
}

/** Get sprint loop anim name 
  * Overridden to play "last" anim  
  */
simulated function name GetSprintLoopAnimName()
{
	return ShouldPlayLastAnims() ? SprintLoopLastAnim : super.GetSprintLoopAnimName();
}

/** Get sprint end anim name 
  * Overridden to play "last" anim  
  */
simulated function name GetSprintEndAnimName()
{
	return ShouldPlayLastAnims() ? SprintOutLastAnim : super.GetSprintEndAnimName();
}

/** Get equip anim name 
  * Overridden to play "last" anim  
  */
simulated function name GetEquipAnimName()
{
	return ShouldPlayLastAnims() ? EquipLastAnim : super.GetEquipAnimName();
}

/** Get nade throw anim name 
  * Overridden to play "last" anim  
  */
simulated function name GetGrenadeThrowAnim()
{
	return ShouldPlayLastAnims() ? NadeThrowLastAnim : super.GetGrenadeThrowAnim();
}

/** Return true if this weapon should play the fire last animation for this shoot animation */
simulated function bool ShouldPlayFireLast(byte FireModeNum)
{
    if( GetTotalAmmoAmount(THROW_FIREMODE) == 0 )
    {
        return true;
    }

    return false;
}

/** There is no reloading thrown weapons */
simulated function bool ShouldAutoReload( byte FireModeNum )
{
	return false;
}

/** Don't sprint until we've finished our throw and reload cycle */
simulated function bool AllowSprinting()
{
	return !IsTimerActive( nameOf(PerformArtificialReload) );
}

/*********************************************************************************************
 * State Active
 * A Weapon this is being held by a pawn should be in the active state.  In this state,
 * a weapon should loop any number of idle animations, as well as check the PendingFire flags
 * to see if a shot has been fired.
 *********************************************************************************************/

simulated state Active
{
	simulated event BeginState( name PreviousStateName )
	{
		// Reload immediately after coming back to active state if we managed to pick up ammo while sprinting
		if( PreviousStateName == 'WeaponSprinting' && !HasAmmo(THROW_FIREMODE) && HasSpareAmmo() )
		{
			// If there was a previous reload timer active for whatever reason, cancel it
			ClearTimer( nameOf(PerformArtificialReload) );
			PerformArtificialReload();
		}

		super.BeginState( PreviousStateName );
	}
	
	/** overridden to add "idle last" anims if out of ammo */
	simulated function PlayIdleAnim()
	{
		local int IdleIndex;

		if ( Instigator.IsFirstPerson() )
		{
			if( bUsingSights && IdleSightedAnims.Length > 0 )
			{
				IdleIndex = Rand(IdleSightedAnims.Length);
				PlayAnimation(IdleSightedAnims[IdleIndex], 0.0, true, 0.1);

				StartIdleFidgetTimer();
			}
			else if( ShouldPlayFireLast(THROW_FIREMODE) && IdleLastAnims.Length > 0 )
			{
				IdleIndex = Rand(IdleLastAnims.Length);
				PlayAnimation(IdleLastAnims[IdleIndex], 0.0, true, 0.2);

				// don't start idle fidget timer if we are out of ammo, because at the moment fidgets use the projectile model
				// @todo: update fidget system to account for hidden projectile mesh?
			//StartIdleFidgetTimer();
			}
			else if ( IdleAnims.Length > 0 )
			{
				IdleIndex = Rand(IdleAnims.Length);
				PlayAnimation(IdleAnims[IdleIndex], 0.0, true, 0.2);

				StartIdleFidgetTimer();
			}

			ToggleAdditiveBobAnim(!bUsingSights);
		}
	}

	/** Overridden to play pickup anim. Calls global. */
	function int AddAmmo( int Amount )
	{
		local int OldAmmo, AmmoAdded;

		OldAmmo = AmmoCount[0];

		AmmoAdded = Global.AddAmmo( Amount );

		if( OldAmmo == 0 && AmmoAdded > 0 )
		{
			ClientNotifyAmmoAddedEmpty();
		}

		return AmmoAdded;
	}
}

/** Notification for when we were empty but now we're not (perform a "reload") */
reliable client function ClientNotifyAmmoAddedEmpty()
{
	local int IdleIndex;

	// We only need to do this if ammo is actually empty and we don't already have a pending reload active
	// @NOTE: We need this in case the weapon state changes before the call gets to the client. -MattF
	if( !HasAmmo(THROW_FIREMODE) && !IsTimerActive(nameOf(PerformArtificialReload)) )
	{
		IdleIndex = Rand(IdleLastPickupAnims.Length);
		PlayAnimation(IdleLastPickupAnims[IdleIndex], 0.0, false, 0.2);
		
		// time forcereload to when we pull up a new projectile
		SetTimer( ConsumeSpareAmmoDelay - GetFireInterval(THROW_FIREMODE), false, nameof(PerformArtificialReload) );
	}
}

/*********************************************************************************************
 * State WeaponThrowing
 * Handles throwing weapon (similar to state GrenadeFiring)
 *********************************************************************************************/

simulated state WeaponThrowing extends WeaponSingleFiring
{
	// Overriden to not call FireAmmunition right at the start of the state
    simulated event BeginState( Name PreviousStateName )
	{
		local name WeaponFireAnimName;
        local KFPerk InstigatorPerk;

        InstigatorPerk = GetPerk();
        if( InstigatorPerk != none )
        {
            SetZedTimeResist( InstigatorPerk.GetZedTimeModifier(self) );
        }

		`LogInv("PreviousStateName:" @ PreviousStateName);

		ConsumeAmmo(CurrentFireMode);

		// play animation here since we're not calling super (because we don't want to call FireAmmunition yet)
		if( Instigator != none && Instigator.IsFirstPerson() )
	    {
	    	WeaponFireAnimName = GetWeaponFireAnim(CurrentFireMode);
	    	if ( WeaponFireAnimName != '' )
	    	{
	    		PlayAnimation(WeaponFireAnimName, MySkelMesh.GetAnimLength(WeaponFireAnimName),,FireTweenTime);
	    	}
	    }

	    // set timer for spawning projectile
		TimeWeaponFiring(CurrentFireMode);
		ClearPendingFire(CurrentFireMode);

		NotifyBeginState();

		// time forcereload to when we pull up a new projectile
		SetTimer( ConsumeSpareAmmoDelay, false, nameof(PerformArtificialReload) );

		// called here and ignored in ProjectileFire in EndState because we want to play the 3p anims now
		IncrementFlashCount();
	}

	simulated function EndState(Name NextStateName)
	{
		Super.EndState(NextStateName);
		NotifyEndState();

		// Spawn projectile
		// (don't use FireAmmunition because that causes FireAnim to be played again)
		ProjectileFire();
		NotifyWeaponFired(CurrentFireMode);
	}
}

/** Does reload stuff without going to reload state or playing reload anims since we don't have them */
simulated function PerformArtificialReload()
{
	PerformReload();
	
`if(`USE_RELOAD_SYNC)
	if( bAllowClientAmmoTracking && Role < ROLE_Authority )
	{
		InitializeReload();
		ServerSyncReload(SpareAmmoCount[0]);
	}
`endif
}

 /** Overridden to ignore reload state changes, so we can still use ServerSendToReload() and ServerSyncReload() */
simulated function SendToFiringState(byte FireModeNum)
{
	if( FireModeNum == RELOAD_FIREMODE )
	{
		return;
	}

	super.SendToFiringState( FireModeNum );
}

/** Called from KFWeapon.ProjectileFire(), overridden because we call IncrementFlashCount in WeaponThrowing.BeginState */
simulated function bool ShouldIncrementFlashCountOnFire()
{
	return false;
}

///////////////////////////////////////////////////////////////////////////////////////////
//
// Trader
//
///////////////////////////////////////////////////////////////////////////////////////////

/** Allows weapon to calculate its own damage for display in trader.
  * Overridden to use projectile damage.
  */
static simulated function float CalculateTraderWeaponStatDamage()
{
	local float BaseDamage, DoTDamage;
	local class<KFProjectile> ProjClass;
	local class<KFDamageType> DamageType;

	ProjClass = class<KFProjectile>( default.WeaponProjectiles[THROW_FIREMODE] );

	if( ProjClass.default.ExplosionTemplate != none )
	{
		BaseDamage = ProjClass.default.ExplosionTemplate.Damage;
		DamageType = class<KFDamageType>( ProjClass.default.ExplosionTemplate.default.MyDamageType );
	}
	else
	{
		BaseDamage = ProjClass.default.Damage;
		DamageType = class<KFDamageType>( ProjClass.default.MyDamageType );
	}

	if( DamageType != none && DamageType.default.DoT_Type != DOT_None )
	{
		DoTDamage = (DamageType.default.DoT_Duration / DamageType.default.DoT_Interval) * (BaseDamage * DamageType.default.DoT_DamageScale);
	}

	return BaseDamage + DoTDamage;
}

simulated state WeaponPuttingDown
{
	simulated function BeginState( Name PreviousStateName )
	{
		super.BeginState(PreviousStateName);
		ClearTimer(nameOf(PerformArtificialReload) );
	}
}

defaultproperties
{
	// Anim
	// @todo: would be nice if all thrown weapons had a default "throw" anim (currently (5/13/15), C4 has "C4_Throw")
	FireAnim=Throw
	FireLastAnim=Throw_Last

	EquipLastAnim=Equip_Last
	PutDownLastAnim=Putaway_Last

	IdleLastAnims=(Idle_Last)
	IdleLastPickupAnims=(Idle_Last_Pickup)

	bHasFireLastAnims=true
	QuickWeaponDownRotation=(Pitch=-8192,Yaw=0,Roll=8192)

	MeleeAttackLastAnims=(Bash_Last)

	// DEPLOY_FIREMODE
	FiringStatesArray(THROW_FIREMODE)=WeaponThrowing
	FireInterval(THROW_FIREMODE)=0.6
	AmmoCost(THROW_FIREMODE)=1

	ConsumeSpareAmmoDelay=1.0

	// Aim Assist
	AimCorrectionSize=0.f
}