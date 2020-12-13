//=============================================================================
// KFSM_Matriarch_WarningSiren
//=============================================================================
//
//=============================================================================
// Killing Floor 2
// Copyright (C) 2019 Tripwire Interactive LLC
//=============================================================================

class KFSM_Matriarch_WarningSiren extends KFSM_ScreamBase;

/** Max distance between the Matriarch and the current victim target */
var float MaxVictimDistance;

var name WindUpAnimName;

function SpecialMoveStarted(bool bForced, name PrevMove)
{
	super.SpecialMoveStarted(bForced, PrevMove);

	PlayWindUpAnimation();

	KFPawn_ZedMatriarch(KFPOwner).PlayWarningSirenDialog();
}

/** Plays subsequent animations in the barrage */
function AnimEndNotify(AnimNodeSequence SeqNode, float PlayedTime, float ExcessTime)
{
	switch (DeferredSeqName)
	{
	case WindUpAnimName:
		PlayFireAnim();
		break;

	case AnimName:
		KFPOwner.EndSpecialMove();
		break;
	}
}

/** Overridden to do nothing */
function PlayAnimation();

/** Plays our wind up anim, starts the barrel spin skel controller */
function PlayWindUpAnimation()
{
	PlaySpecialMoveAnim(WindUpAnimName, EAS_FullBody, BlendInTime, BlendOutTime, 1.f);
	KFPOwner.ZeroMovementVariables();
}

/** Plays our fire animation, starts weapon fire */
function PlayFireAnim()
{
	PlaySpecialMoveAnim(AnimName, EAS_FullBody, 0.1f, 0.2f);
	KFPOwner.ZeroMovementVariables();

	ScreamBegan(); // @todo: for the siren, this is called in an anim notify
}

function SpecialMoveEnded(Name PrevMove, Name NextMove)
{
	super.SpecialMoveEnded(PrevMove, NextMove);
}

defaultproperties
{
	Handle=KFSM_Matriarch_WarningSiren
	WindUpAnimName=Warning_Siren_In
	AnimName=Warning_Siren

	MaxVictimDistance=300.f

	bCanBeInterrupted=false
	bDisableSteering=true
	bDisableMovement=true

	bShouldDeferToPostTick=true

	ScreamDamage=35

	// explosion
	Begin Object Name=ExploTemplate0
		DamageRadius=1000 //800
		DamageFalloffExponent=0.5f
		DamageDelay=0.f

		MomentumTransferScale=100//-100000 Reactivate this to add siren pull

		ActorClassToIgnoreForDamage=class'KFPawn_Monster'

		// Damage Effects
		MyDamageType=class'KFDT_Sonic_MatriarchWarningSiren'
		KnockDownStrength=0
		FractureMeshRadius=200.0
		FracturePartVel=500.0
		ExplosionEffects=none
		ExplosionSound=none

		// Camera Shake
		CamShake=CameraShake'FX_CameraShake_Arch.Misc_Explosions.SirenScream'
		CamShakeInnerRadius=450
		CamShakeOuterRadius=700 //900
		CamShakeFalloff=1.f
		bOrientCameraShakeTowardsEpicenter=true
	End Object
}