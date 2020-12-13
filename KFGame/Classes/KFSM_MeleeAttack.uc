//=============================================================================
// KFSM_MeleeAttack
//=============================================================================
// Handles close-range melee attacks, and base class for all NPC melee attacks.
// An attack is considered to be a melee attack if there are no projectiles
// involved (i.e, just play an animation-based attack)
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//=============================================================================

class KFSM_MeleeAttack extends KFSM_PlaySingleAnim
	native(SpecialMoves);

/** If Interruptible, is this attack affected by parry stumble */
var transient bool bCannotBeParried;

static function byte PackFlagsBase(KFPawn P)
{
	local byte StrikeFlags;
	local KFPawn_Monster KFPM;

	KFPM = KFPawn_Monster(P);
	if ( KFPM == none || P.MyKFAIC == none )
	{
		return 255;
	}

	if( KFPM != none && KFPM.PawnAnimInfo != none )
	{
		StrikeFlags = KFPM.PawnAnimInfo.GetStrikeFlags(P.MyKFAIC.PendingAnimStrikeIndex);

		if( StrikeFlags != 255 )
		{
			//class'AICommand_Attack_Melee'.static.Melee( self, Enemy, StrikeFlags );
			P.MyKFAIC.UpdatePendingStrike();
		}
	}
	return StrikeFlags;
}

/** Unpack Special move flags */
function UnpackSpecialMoveFlags()
{
	local byte AtkIndex, AtkVariant;

	AtkIndex = KFPOwner.SpecialMoveFlags & 15;
	AtkVariant = KFPOwner.SpecialMoveFlags >> 4;

	// setup next attack animation based on SpecialMoveFlags
	AnimName = KFPOwner.PawnAnimInfo.InitMeleeSpecialMove(self, AtkIndex, AtkVariant);

	// for now all non-RootMotion are also interruptible
	bCanBeInterrupted = (bCanBeInterrupted || !bUseRootMotion);
}

/**
 * Can a new special move override this one before it is finished?
 * This is only if CanDoSpecialMove() == TRUE && !bForce when starting it.
 */
function bool CanOverrideMoveWith( Name NewMove )
{
	if ( bCanBeInterrupted && (NewMove == 'KFSM_Stunned' || NewMove == 'KFSM_Stumble' || NewMove == 'KFSM_Knockdown' || NewMove == 'KFSM_Frozen') )
	{
		return TRUE; // for NotifyAttackParried
	}
	return FALSE;
}

function SpecialMoveStarted( bool bForced, name PrevMove )
{
	local KFPawn_Monster KFPM;

	bUseRootMotion = false;
	bCanBeInterrupted = false;

	UnpackSpecialMoveFlags();

	KFPM = KFPawn_Monster(KFPOwner);
	if ( KFPM != none && KFPM.bCanCloak && KFPM.bIsCloaking )
	{
		KFPM.SetCloaked(false);
	}

	Super.SpecialMoveStarted( bForced, PrevMove );
}

function SpecialMoveEnded(Name PrevMove, Name NextMove)
{
	local KFPawn_Monster KFPM;

	PawnOwner.ClearTimer(nameof(InterruptCheckTimer), self);

	// prevent this anim from triggering melee impact notifies during AbortBlendOutTime
 	if ( bCanBeInterrupted && KFPOwner.BodyStanceNodes[AnimStance].bIsPlayingCustomAnim )
 	{
		KFPOwner.BodyStanceNodes[AnimStance].SetNotifyWeightThreshold(0.8f);
	}

	KFPM = KFPawn_Monster(KFPOwner);
	if ( KFPM != none )
	{
		if( KFPM.bCanCloak && KFPM.bCloakOnMeleeEnd && !KFPM.bIsCloaking )
		{
            KFPM.SetCloaked(true);
        }

		KFPM.MeleeSpecialMoveEnded();
	}

	Super.SpecialMoveEnded(PrevMove, NextMove);
}

/** Called from SpecialMoveStarted */
function PlayAnimation()
{
	local float InterruptTime;

	if( AnimName == '' )
	{
		`warn( KFPOwner$" "$GetFuncName()$" "$self$" attempting special move attack but the AttackAnims array is empty!" );
		return;
	}

	`AILog_Ext( GetFuncName()$" "$self$" chose attack animation "$AnimName, 'Command_SpecialMove', AIOwner );
	if( bCanBeInterrupted )
	{
		InterruptTime = KFSkeletalMeshComponent(PawnOwner.Mesh).GetAnimInterruptTime(AnimName);
		PawnOwner.SetTimer(InterruptTime, false, nameof(InterruptCheckTimer), self);
	}

	PlaySpecialMoveAnim( AnimName, AnimStance, BlendInTime, BlendOutTime, KFPOwner.AttackSpeedModifier);
}

/** Notification from the pawn that a medium (aka gun) or heavy (aka melee) affliction has been activated */
function NotifyHitReactionInterrupt()
{
	// only non-RM attacks can be aborted
	if ( bCanBeInterrupted )
	{
		KFPOwner.EndSpecialMove();

		// Reset melee timer after interrupt
		if( AIOwner != None )
		{
			AIOwner.LastGetStrikeTime = -1;
		}
	}
}

/** Called by owning AI Command when AI behavior decides to stop this attack */
function AbortedByAICommand()
{
	local KFPawn_Monster KFPMOwner;

	if ( bCanBeInterrupted )
	{
		if( !KFPOwner.IsTimerActive( nameof(InterruptCheckTimer), self) )
		{
			KFPMOwner = KFPawn_Monster(KFPOwner);
			KFPOwner.EndSpecialMove();
			if( KFPMOwner != none )
			{
				KFPMOwner.NotifyAnimInterrupt();
			}
			if( AIOwner != None )
			{
				// Reset melee timer after interrupt
				AIOwner.LastGetStrikeTime = -1;
			}
		}
	}
}

/** Called when it's safe to interrupt this animation */
function InterruptCheckTimer()
{
	local AICommand_Attack_Melee MeleeCommand;
	local KFPawn_Monster KFPMOwner;

	if ( bCanBeInterrupted && AIOwner != None )
	{
		MeleeCommand = AICommand_Attack_Melee(AIOwner.GetActiveCommand());
		if( MeleeCommand != none && MeleeCommand.bAttackAborted )
		{
			KFPMOwner = KFPawn_Monster(KFPOwner);
			if( KFPMOwner != none )
			{
				KFPMOwner.NotifyAnimInterrupt();
			}
			KFPOwner.EndSpecialMove();

			// Reset melee timer after interrupt
			AIOwner.LastGetStrikeTime = -1;
		}
	}
}

/** Called when owning pawn has damage parried during this move */
function bool CanInterruptWithParry()
{
	return !bCannotBeParried;
}

defaultproperties
{
	BlendInTime=0.2f
	BlendOutTime=0.33f

	// ---------------------------------------------
	// Animations
	bUseRootMotion=false
	AbortBlendOutTime=0.5f

	// ---------------------------------------------
	// SpecialMove
	Handle=KFSM_MeleeAttack
	bDisableSteering=false
	bDisableMovement=true
	bUseHigherMeshSmoothingThreshold=true
}