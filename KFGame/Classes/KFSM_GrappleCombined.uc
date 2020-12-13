//=============================================================================
// KFSM_GrappleCombined
//=============================================================================
// One grapple to rule them all.  Combines GrappleAttack and GrappleStart
// so we have better control over the transition.
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//=============================================================================
class KFSM_GrappleCombined extends KFSM_InteractionPawnLeader
	native(SpecialMoves);

// Animations
var array<name>	 GrappleAnims;
var bool bStopFullBodyWhenMoveEnds;
var byte LastVariant;  // The last anim index this special move played

// Simple state flags for multi-stage special move
enum EGrappleState
{
    EGS_GrabAttempt,
    EGS_GrabSuccess,
    EGS_GrabMiss,
};

/** Beyond this distance the grapple will fail */
var float MaxGrabDistance;
/** Make sure Z distance isn't too far */
var float MaxVictimZOffset;
/** Anim to play when attempting to grab attach */
var name GrabStartAnimName;

/** If set, this ability can be blocked by a melee weapon */
var bool bCanBeBlocked;
/** Is set, the owner can cancel/abort this move after it's been started */
var bool bCanBeInterrupted;

/** The time from the start of the anim to check for a victim */
var float GrabCheckTime;

/** Minimum amount of time to grab if player released button */
var float MinPlayerGrabTime;

/** Should use root motion for the initial "grab attempt" animation */
var	bool  bUseRootMotion;

/** Restrictions for doing grab animation. */
protected function bool InternalCanDoSpecialMove()
{
	if( PawnOwner.IsHumanControlled() && PawnOwner.Physics == PHYS_Falling )
	{
		return false;
	}

	if ( KFPOwner.IsHeadless() )
	{
		return false;
	}

	return super.InternalCanDoSpecialMove();
}

/**
 * Can a new special move override this one before it is finished?
 * This is only if CanDoSpecialMove() == TRUE && !bForce when starting it.
 */
function bool CanOverrideMoveWith( Name NewMove )
{
	if ( KFPOwner.SpecialMoveFlags == EGS_GrabAttempt )
	{
		if ( NewMove == 'KFSM_Stunned' || NewMove == 'KFSM_Stumble' )
		{
			return TRUE; // for NotifyAttackParried
		}
	}
	return FALSE;
}

/** Called when owning pawn has damage parried during this move */
function bool CanInterruptWithParry()
{
	return (KFPOwner.SpecialMoveFlags == EGS_GrabAttempt);
}

/** Set our grab flag to EGS_GrabAttempt (we don't start the grapple until we've grabbed a pawn) */
static function byte PackFlagsBase( KFPawn P )
{
	return EGS_GrabAttempt;
}

/** Notification called when Special Move starts */
function SpecialMoveStarted(bool bForced, Name PrevMove )
{
	// skip default (instant attach) behavior 
	Super(KFSpecialMove).SpecialMoveStarted(bForced, PrevMove);

	// Reset variables
	Follower = None;
	bAlignFollowerLookSameDirAsMe = default.bAlignFollowerLookSameDirAsMe;
	bAlignPawns = default.bAlignPawns;
	bAlignFollowerRotation = default.bAlignFollowerRotation;
	bPendingStopFire = false;

	PlayGrabAnim();
}

/** Play an animation and enable the OnAnimEnd notification */
function PlayGrabAnim()
{
	GrabCheckTime = KFSkeletalMeshComponent(PawnOwner.Mesh).GetAnimInterruptTime(GrabStartAnimName);

	// On the server start a timer to check collision
	if ( PawnOwner.Role == ROLE_Authority )
	{
		if ( GrabCheckTime <= 0 )
		{
			`warn("Failed to play" @ GrabStartAnimName @ "on special move" @ Self @ "on Pawn" @ PawnOwner);
			PawnOwner.SetTimer(0.25f, FALSE, nameof(AbortSpecialMove), Self);
			return;
		}

		PawnOwner.SetTimer(GrabCheckTime, FALSE, nameof(CheckGrapple), Self);
	}

	PlaySpecialMoveAnim(GrabStartAnimName, EAS_FullBody);

	if ( bUseRootMotion )
	{
		EnableRootMotion();
	}
}

/**
  * Check to see if we're in range to lock into a grapple
  * Network: Server
  */
function CheckGrapple()
{
	local vector ToEnemy;
	local vector Extent, HitLocation, HitNormal;
	local Actor HitActor;
	local KFPawn Victim;

	if( KFPOwner.IsHumanControlled() )
	{
		Victim = KFPawn(FindPlayerGrabTarget());
	}
	else if( AIOwner != none )
	{
		Victim = KFPawn( AIOwner.Enemy );
	}

	if( Victim != none && Victim.IsAliveAndWell() && Victim.GetTeamNum() != KFPOwner.GetTeamNum() /*&& AIOwner.Enemy.Physics != PHYS_Falling*/ )
	{
		if ( Victim != None && (bCanBeBlocked && Victim.MyKFWeapon != None && Victim.MyKFWeapon.IsGrappleBlocked(PawnOwner))
            || (!Victim.CanBeGrabbed(KFPOwner, true)) )
		{
			return; // blocked by weapon or pawn can't be grabbed
		}

		// Check victim Z offset
		if( Abs(PawnOwner.Location.Z - Victim.Location.Z) > MaxVictimZOffset )
		{
			return;
		}

		ToEnemy = (PawnOwner.Location - Victim.Location);

		if( VSizeSq(ToEnemy) > Square(MaxGrabDistance) )
		{
			return; // exceeded max distance
		}

		if( !KFPOwner.IsHumanControlled() )
		{
			// Set our extent
			Extent.X = PawnOwner.GetCollisionRadius() * 0.5f;
			Extent.Y = Extent.X;
			Extent.Z = PawnOwner.GetCollisionHeight() * 0.5f;

			// trace for obstructions (already checked if IsHumanControlled())
			HitActor = PawnOwner.Trace(HitLocation, HitNormal, Victim.Location, PawnOwner.Location, true, Extent);
			if( HitActor != None && HitActor != Victim )
			{
				return;
			}
		}

		BeginGrapple(Victim);
		PlayGrappleLoopAnim();
	}
}

/** Returns a victim to try and grab onto */
function Pawn FindPlayerGrabTarget()
{
	local KFPawn_Monster KFPM;
	local vector StartLoc, EndLoc;

	KFPM = KFPawn_Monster(PawnOwner);
	if ( KFPM != None )
	{
		StartLoc = PawnOwner.Location;
		EndLoc = StartLoc + Normal(Vector(PawnOwner.Rotation)) * MaxGrabDistance;

		return KFPM.MeleeAttackHelper.FindVictimByFOV(StartLoc, EndLoc, MaxGrabDistance);
	}
}

/**
 * Used for Pawn to Pawn interactions.
 * Return TRUE if we can perform an Interaction with this Pawn.
 */
function bool CanInteractWithPawn(KFPawn OtherPawn)
{
	// Prevent interaction if potentiail victim is dead, not on our team, in Phys_Falling, or busy with another special move
	return( (OtherPawn.IsAliveAndWell() && !KFPOwner.IsSameTeam(OtherPawn) && OtherPawn.Physics != PHYS_Falling && !OtherPawn.IsDoingSpecialMove())
		&& Super.CanInteractWithPawn(OtherPawn) );
}

/** Called when grapple is successful and interaction pawn is attached */
function BeginGrapple(optional KFPawn Victim)
{
    if ( PawnOwner.Role == ROLE_Authority )
    {
        // @todo: Server only for now because the alignment code is not 
        // network safe on simulated proxy.  Needs invstigation!
        bAlignPawns = default.bAlignPawns;

        KFPOwner.InteractionPawn = Victim;
		KFPOwner.ReplicatedSpecialMove.InteractionPawn = Victim;

        // replicate attachment
        KFPOwner.SpecialMoveFlags = EGS_GrabSuccess;
        KFPOwner.ReplicatedSpecialMove.Flags = KFPOwner.SpecialMoveFlags;
    }

    // See if the grab should be ended early
	if( PawnOwner.IsHumanControlled() && PawnOwner.IsLocallyControlled() )
	{
		PawnOwner.SetTimer(MinPlayerGrabTime, false, nameof(CheckIfPlayerReleasedGrapple), self);
	}

	// stop root motion
	if ( bUseRootMotion && PawnOwner.Mesh.RootMotionMode == SMRootMotionMode )
	{
		DisableRootMotion();
	}

    // Set up a safety net in case interaction cannot be started
    PawnOwner.SetTimer( InteractionStartTimeOut, FALSE, nameof(self.InteractionStartTimedOut), self );

    // See if we can start interaction right now. If we can't, keep trying until we can.
    CheckReadyToStartInteraction();
}

/** StartInteraction */
function StartInteraction() 
{
	local KFAIDirector AIDirector;

	super.StartInteraction();

	if( Follower != none && KFPOwner != none )
	{
	    // Prevent grenade throwing for a short time after being grabbed to prevent players blowing themselves up
	    if( KFWeapon(Follower.Weapon) != none )
	    {
	        KFWeapon(Follower.Weapon).ZedGrabGrenadeTossCooldown = Follower.WorldInfo.TimeSeconds + 0.35;
	    }

		// Try to let the game's KFAIDirector know about the successful grab, so it can alert nearby Zeds
		// TODO: Might want to move this to a timer so other zeds aren't alerted until the grapple anim actively looping
		if( KFPOwner.MyKFAIC != none )
		{
			AIDirector = KFPOwner.MyKFAIC.MyAIDirector;

			//Let the AI controller know the initial attack succeeded
			if( KFAIController_Monster(KFPOwner.MyKFAIC) != none )
			{
	            KFAIController_Monster(KFPOwner.MyKFAIC).bCompletedInitialGrabAttack = true;
	        }
		}
		else if ( KFPOwner.WorldInfo.Game != None )
		{
			AIDirector = KFGameInfo( KFPOwner.WorldInfo.Game ).GetAIDirector();
			if ( AIDirector != None )
			{
				// We currently don't notify if/when the player breaks away from the grab
				AIDirector.NotifyPawnGrabbed( Follower, KFPOwner );
			}
		}
	}
}

/** Use timer & animlength instead of animend */
function AnimEndNotify(AnimNodeSequence SeqNode, float PlayedTime, float ExcessTime)
{
	if( KFPOwner != none && KFPOwner.Role == ROLE_Authority )
	{
		if ( KFPOwner.SpecialMoveFlags == EGS_GrabAttempt )
		{
			KFPOwner.EndSpecialMove();
		}
		else
		{
			PlayGrappleLoopAnim();
		}
	}
}

/** Toggle attachment */
function SpecialMoveFlagsUpdated()
{
    if ( KFPOwner.SpecialMoveFlags >= EGS_GrabSuccess )
    {
    	// one-time attachment
    	if ( Follower == None )
    	{
    		BeginGrapple();
    	}

   		PlayGrappleLoopAnim();
    }
}

/** Network: All */
function PlayGrappleLoopAnim()
{
	local byte Variant;

	if( KFPOwner != none && KFPOwner.Role == ROLE_Authority )
	{
		// Do not use the last variant
		Variant = Rand(default.GrappleAnims.Length);
		while(Variant == LastVariant)
		{
			Variant = Rand(default.GrappleAnims.Length);
		}

		LastVariant = Variant;
		KFPOwner.SpecialMoveFlags = (Variant << 4) + EGS_GrabSuccess;
		KFPOwner.ReplicatedSpecialMove.Flags = KFPOwner.SpecialMoveFlags;
	}

	PlaySpecialMoveAnim(GrappleAnims[KFPOwner.SpecialMoveFlags >> 4], EAS_FullBody);
}

/** Notification when Follower is leaving his FollowerSpecialMove */
function OnFollowerLeavingSpecialMove()
{
	KFPOwner.EndSpecialMove();
}

function SpecialMoveEnded(Name PrevMove, Name NextMove)
{
	// Clear timers.
	PawnOwner.ClearTimer(nameof(CheckGrapple), Self);

	// stop root motion
	if ( bUseRootMotion && PawnOwner.Mesh.RootMotionMode == SMRootMotionMode )
	{
		DisableRootMotion();
	}

	if( bStopFullBodyWhenMoveEnds )
	{
		KFPOwner.StopBodyAnim(EAS_FullBody, 0.2f);
	}

	Super.SpecialMoveEnded(PrevMove, NextMove);
}

/** Handle bCanBeInterrupted, also see CanOverrideMoveWith() for interrupt moves */
function NotifyOwnerTakeHit(class<KFDamageType> DamageType, vector HitLoc, vector HitDir, Controller InstigatedBy)
{
	// Don't break grab if the damage was from someone on the same team
    if( InstigatedBy != none && KFPOwner != none && InstigatedBy.GetTeamNum() == KFPOwner.GetTeamNum() )
    {
        return;
    }

	if( !KFPOwner.IsHumanControlled() )
	{
	    // End the move immediately and let ProcessAIHit force a SM_Stumble
		KFPOwner.EndSpecialMove();

		// force stumble when damaged from a grapple
		if ( KFPOwner.CanDoSpecialMove(SM_Stumble) && DamageType.default.StumblePower > 0 )
		{
			KFPOwner.DoSpecialMove(SM_Stumble,,, class'KFSM_Stumble'.static.PackBodyHitSMFlags(KFPOwner, HitDir));
		}
	}
}

/** Notification from the pawn that a medium (aka gun) or heavy (aka melee) affliction has been activated */
function NotifyHitReactionInterrupt()
{
	local vector HitDir;

	if ( KFPOwner.SpecialMoveFlags == EGS_GrabAttempt )
	{
		if ( bCanBeInterrupted )
		{
			// Force stumble.  Cannot simple exit this move without aborting/overriding the animation
			if ( KFPOwner.CanDoSpecialMove(SM_Stumble) )
			{
				HitDir = Normal(KFPOwner.HitFxInfo.EncodedHitDirection);
				KFPOwner.DoSpecialMove(SM_Stumble,,, class'KFSM_Stumble'.static.PackBodyHitSMFlags(KFPOwner, HitDir));
			}
		}
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

    // Wait out the initial grab attempt + minimum grab duration
    if( Follower == none || KFPOwner.IsTimerActive(nameOf(CheckIfPlayerReleasedGrapple), self) )
    {
        return;
    }

	KFPOwner.EndSpecialMove();
	if( KFPOwner.Role < ROLE_Authority && KFPOwner.IsLocallyControlled() )
	{
		KFPOwner.ServerDoSpecialMove( SM_None, true );
	}
}

/** Called when aborting the move due to player input */
function CheckIfPlayerReleasedGrapple()
{
	if( bPendingStopFire )
	{
		KFPOwner.EndSpecialMove();
		if( KFPOwner.Role < ROLE_Authority && KFPOwner.IsLocallyControlled() )
		{
			KFPOwner.ServerDoSpecialMove( SM_None, true );
		}
	}
}

defaultproperties
{
	Handle=SM_GrappleAttack
	FollowerSpecialMove=SM_GrappleVictim

	// ---------------------------------------------
	// Animation
	GrappleAnims=(Grab_Attack_V1, Grab_Attack_V2, Grab_Attack_V3)
	GrabStartAnimName=Grab
	bStopFullBodyWhenMoveEnds=true

	// ---------------------------------------------
	// Alignment
    bServerOnlyPhysics=true
	bAlignPawns=true
	AlignDistance=92

	// @deprecated: see ForceLookAtPawn
	bAlignFollowerRotation=false
	bAlignHumanFollowerControllerRotation=false
	bStopAlignFollowerRotationAtGoal=true
	AlignFollowerInterpSpeed=22.f

	// ---------------------------------------------
	// Movement
	bDisableLook=false
	bDisableMovement=true
	bLockPawnRotation=false

	// ---------------------------------------------
	// Combat
	MaxGrabDistance=210.f
	MaxVictimZOffset=128.f
	bCanBeBlocked=true
	bCanBeInterrupted=true
	MinPlayerGrabTime=3.f
}