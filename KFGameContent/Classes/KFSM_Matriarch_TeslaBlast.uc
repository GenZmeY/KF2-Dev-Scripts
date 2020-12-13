//=============================================================================
// KFSM_Matriarch_TeslaBlast
//=============================================================================
//
//=============================================================================
// Killing Floor 2
// Copyright (C) 2019 Tripwire Interactive LLC
//=============================================================================

class KFSM_Matriarch_TeslaBlast extends KFSM_PlaySingleAnim;

/** Wind Up animation name */
var Name WindUpAnimName;

/** Wind Down animation name */
var Name WindDownAnimName;

/** Max distance between the Matriarch and the current victim target */
var float MaxVictimDistance;

var name ShootingSocketName;

var KFPawn_ZedMatriarch MyMatPawn;

/** Notification called when Special Move starts */
function SpecialMoveStarted(bool bForced, Name PrevMove)
{
	super.SpecialMoveStarted(bForced, PrevMove);

	PlayWindUpAnimation();

	MyMatPawn = KFPawn_ZedMatriarch(KFPOwner);
	MyMatPawn.SetGunTracking(true);
	MyMatPawn.PlayTeslaBlastDialog();
}

/** Play the wind down if we have to */
function SpecialMoveFlagsUpdated()
{
	switch (KFPOwner.SpecialMoveFlags)
	{
	case 1:
        PlayFireAnim();
       	break;

	case 2:
	    KFPOwner.EndSpecialMove();
	    break;
	}
}

function AnimEndNotify(AnimNodeSequence SeqNode, float PlayedTime, float ExcessTime)
{
	switch (DeferredSeqName)
	{
	case WindUpAnimName:
		if (KFPOwner.Role == ROLE_Authority)
		{
			// Do the beam check on the authority and then re-do the special move with new flags,
			// which will cause the flags to be replicated and caught by SpecialMoveFlagsUpdated

			if (PrefireBeamCheck())
			{
				KFPOwner.DoSpecialMove(SM_StandAndShootAttack, true,, 1);
			}
			else
			{
				KFPOwner.DoSpecialMove(SM_StandAndShootAttack, true,, 2);
			}
		}
		break;

	case AnimName:
		KFPOwner.EndSpecialMove();
		break;
	}
}

function bool PrefireBeamCheck()
{
	local Actor HitActor;
	local vector SocketLocation, HitLocation, HitNormal, ToEnemy, TraceEnd, GunTargetBoneLocation;
	local rotator SocketRotation;

	PawnOwner.Mesh.GetSocketWorldLocationAndRotation(ShootingSocketName, SocketLocation, SocketRotation);
	GunTargetBoneLocation = KFPOwner.Controller.Enemy.Mesh.GetBoneLocation(MyMatPawn.GunTargetBoneName);
	ToEnemy = Normal(GunTargetBoneLocation - SocketLocation);
	TraceEnd = SocketLocation + ToEnemy * MaxVictimDistance;

	HitActor = PawnOwner.Trace(HitLocation, HitNormal, TraceEnd, SocketLocation, true);
	return KFPawn(HitActor) != none;
}

/** Overridden to do nothing */
function PlayAnimation();

/** Plays our wind up anim, starts the barrel spin skel controller */
function PlayWindUpAnimation()
{
	// bUseRootMotion = true; ?
	// EnableRootMotion(); ??

	// Zero movement
	KFPOwner.ZeroMovementVariables();

	PlaySpecialMoveAnim(WindUpAnimName, EAS_FullBody, BlendInTime, BlendOutTime, 1.f);
}

/** Plays our fire animation, starts weapon fire */
function PlayFireAnim()
{
	PlaySpecialMoveAnim(AnimName, EAS_FullBody, 0.1f, 0.2f);

	// Zero movement
	KFPOwner.ZeroMovementVariables();

	// Start firing
	if (KFPOwner.Role == ROLE_Authority || KFPOwner.IsLocallyControlled())
	{
		KFPOwner.Weapon.StartFire(0);
	}
}

/** Plays our wind down animation, stops firing, disables barrel spin skel controller */
function PlayWindDownAnim()
{
	// Sync weapon state
	if( KFPOwner.Weapon != none && !KFPOwner.Weapon.IsInState('Active') )
	{
		KFPOwner.StopFiring();
		KFPOwner.Weapon.GotoState('Active');
	}

	// Zero movement
	KFPOwner.ZeroMovementVariables();

	PlaySpecialMoveAnim(WindDownAnimName, EAS_FullBody, BlendInTime, BlendOutTime, 1.f);
}

function SpecialMoveEnded(Name PrevMove, Name NextMove)
{
	super.SpecialMoveEnded(PrevMove, NextMove);

	MyMatPawn.SetGunTracking(false);
}

defaultproperties
{
	MaxVictimDistance=2500.f

	// SpecialMove
	Handle=KFSM_Matriarch_TeslaBlast
	bDisableSteering=false
	bDisableMovement=true
   	bCanBeInterrupted=false
	bAllowFireAnims=true
    bShouldDeferToPostTick=true // enables AnimEndNotify

	ShootingSocketName=Hand_FX_End_L

	// Animation
	WindUpAnimName=Tesla_Blast_TO_Load
	WindDownAnimName=Tesla_Blast_TO_Idle
	AnimName=Tesla_Blast_Shoot
}