//=============================================================================
// KFSM_PlayerHusk_FlameThrowerAttack
//=============================================================================
// Play a flamethrower attack
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//=============================================================================
class KFSM_PlayerHusk_FlameThrowerAttack extends KFSM_Husk_FlameThrowerAttack;

var bool bAnimCanBeInterrupted;

function SpecialMoveStarted( bool bForced, name PrevMove )
{
	bAnimCanBeInterrupted = false;
	bPendingStopFire = false;

	if( KFPOwner.IsLocallyControlled() )
	{
		KFPOwner.SetTimer( KFSkeletalMeshComponent(KFPOwner.Mesh).GetAnimInterruptTime(AnimName), false, nameOf(Timer_AnimInterrupt), self );
	}

	super.SpecialMoveStarted( bForced, PrevMove );
}

/** Called on animations that can be interrupted */
function Timer_AnimInterrupt()
{
	bAnimCanBeInterrupted = true;

	if( bPendingStopFire )
	{
		SpecialMoveButtonReleased();
	}
}

/** When the grapple animation ends, continue it with a different grapple anim */
function SpecialMoveFlagsUpdated()
{
	if( KFPOwner.SpecialMoveFlags == FLAG_SpecialMoveButtonReleased )
	{
		KFPOwner.EndSpecialMove();
	}
	else
	{
		super.SpecialMoveFlagsUpdated();
	}
}

/* Called on some player-controlled moves when a firemode input has been pressed */
function SpecialMoveButtonRetriggered()
{
	bPendingStopFire = false;
}

/** Called on some player-controlled moves when a firemode input has been released */
function SpecialMoveButtonReleased()
{
	bPendingStopFire = true;

	if( !bAnimCanBeInterrupted )
	{
		return;
	}

	KFPOwner.DoSpecialMove( KFPOwner.SpecialMove, true,, FLAG_SpecialMoveButtonReleased );
	if( KFPOwner.Role < ROLE_Authority && KFPOwner.IsLocallyControlled() )
	{
		KFPOwner.ServerDoSpecialMove( KFPOwner.SpecialMove, true,, FLAG_SpecialMoveButtonReleased );
	}
}

DefaultProperties
{
	// SpecialMove
	Handle=KFSM_PlayerHusk_FlameThrowerAttack
	bDisableSteering=false
	bDisableMovement=true
   	bDisableTurnInPlace=true
   	bCanBeInterrupted=true

   	// Animation
	AnimName=Player_Flame
	AnimStance=EAS_FullBody

	// Flamethrower
	FlameSprayArchetype=SprayActor_Flame'zed_husk_arch.Husk_Flamethrower_Flame_Player'
	FlameAttackPlayEvent=AkEvent'WW_ZED_Husk.ZED_Husk_SFX_Flamethrower_LP'
    FlameAttackStopEvent=AkEvent'WW_ZED_Husk.ZED_Husk_SFX_Flamethrower_Stop'
}
