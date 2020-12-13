//=============================================================================
// KFSM_GrappleAttack
//=============================================================================
// Base Move to play a single animation, and end itself once it's done playing.
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//=============================================================================

class KFSM_PlaySingleAnim extends KFSpecialMove
	abstract
	native(SpecialMoves);

/** Animation to play */
var() name				AnimName;
var() EAnimSlotStance	AnimStance;
var bool 				bLoopAnim;

var	float		BlendInTime;
var	float		BlendOutTime;
var	bool		bUseRootMotion;

/** Is set, the owner can cancel/abort this move after it's been started */
var bool bCanBeInterrupted;
/** BlendOut time when animation is interrupted */
var	float AbortBlendOutTime;

function SpecialMoveStarted(bool bForced, Name PrevMove)
{
	Super.SpecialMoveStarted(bForced, PrevMove);

	// Play animation
	PlayAnimation();

	if( bUseRootMotion && AnimStance == EAS_FullBody )
	{
		EnableRootMotion();
	}
}

function SpecialMoveEnded(Name PrevMove, Name NextMove)
{
	if( bUseRootMotion )
	{
		DisableRootMotion();
	}

	// If still playing an upperbody or fullbody animation allow it to be interrupted
 	if ( bCanBeInterrupted && KFPOwner.BodyStanceNodes[AnimStance].bIsPlayingCustomAnim )
 	{
		KFPOwner.StopBodyAnim(AnimStance, AbortBlendOutTime);
	}

	Super.SpecialMoveEnded(PrevMove, NextMove);
}

/** Play an animation and enable the OnAnimEnd notification */
function PlayAnimation()
{
	PlaySpecialMoveAnim(AnimName, AnimStance, BlendInTime, BlendOutTime, 1.f, bLoopAnim);
}

/**  When the animation finishes playing end this move */
function AnimEndNotify(AnimNodeSequence SeqNode, float PlayedTime, float ExcessTime)
{
	if( !bLoopAnim )
	{
		KFPOwner.EndSpecialMove();
	}
}

/** Notification from the pawn that a medium (aka gun) or heavy (aka melee) affliction has been activated */
function NotifyHitReactionInterrupt()
{
	if ( bCanBeInterrupted )
	{
		KFPOwner.EndSpecialMove();
	}
}

defaultproperties
{
	// ---------------------------------------------
	// Animations
	BlendInTime=0.33f
	BlendOutTime=0.33f
	AbortBlendOutTime=0.33f
	bLoopAnim=false

	bAllowMomentumPush=true
}