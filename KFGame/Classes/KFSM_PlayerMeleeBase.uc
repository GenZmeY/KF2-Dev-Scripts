//=============================================================================
// KFSM_PlayerMeleeBase
//=============================================================================
// A base class for third person, player-controlled, creature melee attacks
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
// - Andrew "Strago" Ladenberger
//=============================================================================

class KFSM_PlayerMeleeBase extends KFSM_MeleeAttack
	abstract;

/** Max 16 types, 0-15 */
enum EPlayerZedAtkType
{
	PZA_Default,
	PZA_Sprinting,
	PZA_SprintBackwards,
	PZA_SprintCloaked,
	PZA_Cloaked,
	PZA_Jumping,
	PZA_Headless,
	PZA_Left,
	PZA_Right,
	PZA_Backwards,
	PZA_SpecialDefault,
	PZA_SpecialSprinting,
	PZA_SpecialBackwards,
};

struct PlayerZedAtkInfo
{
	var array<name> Anims;
	var bool bIsInputHeld;
	var EPlayerZedAtkType Type;
	var EAnimSlotStance Stance;
	var float MomentumPush;
	var bool bForceDisableRootMotion;
	var bool bCannotBeParried;
};

var bool bAnimCanBeInterrupted;

var array<PlayerZedAtkInfo> Attacks;

/** global stop event for looping sounds played during the animation */
var AkEvent SoundStopEvent;

static function byte PackFlagsBase( KFPawn P )
{
	local byte AtkIdx, Variant;
	local EPlayerZedAtkType Type;
	local bool bUsingSpecialAttacks;
	local EPawnOctant PawnMoveDir;

	if ( P != None )
	{
		PawnMoveDir = GetFourWayMoveDirection( P );
		bUsingSpecialAttacks = default.class.static.IsInSpecialMode( P );

		if ( P.IsHeadless() )
		{
			Type = PZA_Headless;
		}
		else if ( P.Physics == PHYS_Falling )
		{
			Type = PZA_Jumping;
		}
		else if ( P.bIsSprinting )
		{
			if( P.bIsCloaking )
			{
				Type = PZA_SprintCloaked;
			}
			else if( bUsingSpecialAttacks )
			{
				Type = PawnMoveDir == DIR_Backward ? PZA_SpecialBackwards : PZA_SpecialSprinting;
			}
			else if( PawnMoveDir == DIR_Right )
			{
				Type = PZA_Right;
			}
			else
			{
				Type = PawnMoveDir == DIR_Backward ? PZA_SprintBackwards : PZA_Sprinting;
			}
		}
		else if ( P.bIsCloaking )
		{
			Type = PZA_Cloaked;
		}
		else if ( PawnMoveDir == DIR_Backward )
		{
			Type = bUsingSpecialAttacks ? PZA_SpecialBackwards : PZA_Backwards;
		}
		else if( PawnMoveDir == DIR_Right )
		{
			Type = PZA_Right;
		}
		else if( PawnMoveDir == DIR_Left )
		{
			Type = PZA_Left;
		}
		else
		{
			Type = bUsingSpecialAttacks ? PZA_SpecialDefault : PZA_Default;
		}
	}
	
	AtkIdx = default.Attacks.Find('Type', Type);
	if ( AtkIdx == 255 )
	{
		AtkIdx = 0;
	}
	Variant = Rand(default.Attacks[AtkIdx].Anims.Length);
	return AtkIdx + (Variant << 4);
}

function SpecialMoveStarted( bool bForced, name PrevMove )
{
	super.SpecialMoveStarted( bForced, PrevMove );

	bAnimCanBeInterrupted = false;
	bPendingStopFire = false;

	// Must be able to interrupt a parriable (e.g. stumble) attack
	// @todo: all these interrupt variables are confusing and have a lot of overlap
	bCanBeInterrupted = !bCannotBeParried;
}

function SpecialMoveEnded( Name PrevMove, Name NextMove )
{
	Super.SpecialMoveEnded(PrevMove, NextMove);

	if ( SoundStopEvent != None && PawnOwner.WorldInfo.NetMode != NM_DedicatedServer )
	{
		PawnOwner.PostAkEvent(SoundStopEvent);
	}
}

/** Can be overridden in subclasses to determine if special attacks are used over defaults */
static function bool IsInSpecialMode( KFPawn P )
{
	return false;
}

/** Returns a 4-way direction based on pawn movement to use with SpecialMoveFlags */
static function EPawnOctant GetFourWayMoveDirection(Pawn P)
{
	local vector MoveDir;

	// Prefer to use acceleration, but if the player only has velocity use that.
	// This allows the player to let go off the movement keys just before an attack.
	MoveDir = (IsZero(P.Acceleration)) ? P.Velocity : P.Acceleration;

	return class'KFPawn'.static.CalcQuadRegion(P.Rotation, MoveDir);
}

/** Unpack Special move flags */
function UnpackSpecialMoveFlags()
{
	local byte Variant, AtkIdx;

	AtkIdx = KFPOwner.SpecialMoveFlags & 15;
	Variant = KFPOwner.SpecialMoveFlags >> 4;

	AnimName = Attacks[AtkIdx].Anims[Variant];
	AnimStance = Attacks[AtkIdx].Stance;

	bDisableMovement = (AnimStance == EAS_FullBody);
	bUseRootMotion = (AnimStance == EAS_FullBody && !Attacks[AtkIdx].bForceDisableRootMotion);

	// If we're doing a PHYS_Falling attack we need to allow RM take over
	// which means disabling bAllowMomentumPush.
	bAllowMomentumPush = (!bUseRootMotion || Attacks[AtkIdx].Type != PZA_Jumping);

	// Set parry flag on a per-attack basis
	bCannotBeParried = Attacks[AtkIdx].bCannotBeParried;

	if( Attacks[AtkIdx].bIsInputHeld )
	{
		bCanBeInterrupted = true;
		if( KFPOwner.IsLocallyControlled() )
		{
			KFPOwner.SetTimer( KFSkeletalMeshComponent(KFPOwner.Mesh).GetAnimInterruptTime(AnimName), false, nameOf(Timer_AnimInterrupt), self );
		}
	}

	// Apply momentum push, if we allow it and momentum is > 0
	if( bAllowMomentumPush && Attacks[AtkIdx].MomentumPush > 0.f && (KFPOwner.Role == ROLE_Authority || KFPOwner.IsLocallyControlled()) )
	{
		KFPOwner.Velocity += vector(KFPOwner.Rotation) * Attacks[AtkIdx].MomentumPush;
	}
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

defaultproperties
{
}