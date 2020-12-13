//=============================================================================
// KFSM_Matriarch_LightningStorm
//=============================================================================
//
//=============================================================================
// Killing Floor 2
// Copyright (C) 2019 Tripwire Interactive LLC
//=============================================================================

class KFSM_Matriarch_LightningStorm extends KFSM_PlaySingleAnim;

/** Max distance between the Matriarch and the current victim target */
var float MaxVictimDistance;

/** Wind Up animation name */
var Name WindUpAnimName;

/** Wind Down animation name */
var Name WindDownAnimName;

var KFGameExplosion ExplosionTemplate;

/** Notification called when Special Move starts */
function SpecialMoveStarted(bool bForced, Name PrevMove)
{
	super.SpecialMoveStarted(bForced, PrevMove);

	PlayWindUpAnimation();

	KFPawn_ZedMatriarch(KFPOwner).PlayLightningStormDialog();
}

/** Overridden to do nothing */
function PlayAnimation();

/** Plays our wind up anim, starts the barrel spin skel controller */
function PlayWindUpAnimation()
{
	// bUseRootMotion = true; ?
	// EnableRootMotion(); ??
	// SetGunTracking ???

	// Zero movement
	KFPOwner.ZeroMovementVariables();

	PlaySpecialMoveAnim(WindUpAnimName, EAS_FullBody, BlendInTime, BlendOutTime, 1.f);
}

/** Plays our fire animation, starts weapon fire */
function PlayFireAnim()
{
	local KFExplosionActor ExplosionActor;

	PlaySpecialMoveAnim(AnimName, EAS_FullBody, 0.1f, 0.2f);

	// Zero movement
	KFPOwner.ZeroMovementVariables();

	// Do damage
    ExplosionActor = KFPOwner.Spawn(
		class'KFExplosionActor', KFPOwner,, KFPOwner.Mesh.GetBoneLocation('Root'), rotator(vect(0,0,1)));
    if (ExplosionActor != none)
    {
        ExplosionActor.Explode(ExplosionTemplate);
    }
}

/** Plays our wind down animation, stops firing, disables barrel spin skel controller */
function PlayWindDownAnim()
{
	// Zero movement
	KFPOwner.ZeroMovementVariables();

	PlaySpecialMoveAnim(WindDownAnimName, EAS_FullBody, BlendInTime, BlendOutTime, 1.f);
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
			PlayWindDownAnim();
			break;

		case WindDownAnimName:
			KFPOwner.EndSpecialMove();
			break;
	}
}

function SpecialMoveEnded(Name PrevMove, Name NextMove)
{
	super.SpecialMoveEnded(PrevMove, NextMove);
}

defaultproperties
{
	Handle=KFSM_Matriarch_LightningStorm
	bDisableSteering=false
	bDisableMovement=true
   	bCanBeInterrupted=false
	bAllowFireAnims=true
    bShouldDeferToPostTick=true // enables AnimEndNotify

	// Animation
	// NOTE: Yes, the animation names are "Lighting," not "LightNing"
	WindUpAnimName=Lighting_Storm_In
	AnimName=Lighting_Storm_Loop
	WindDownAnimName=Lighting_Storm_Out

	MaxVictimDistance=400.f


    Begin Object Class=KFGameExplosion Name=ExploTemplate1
        Damage=65
        DamageRadius=800
        DamageFalloffExponent=0.f
        DamageDelay=0.f
        MyDamageType=class'KFDT_EMP_MatriarchLightningStorm'

        // Damage Effects
        KnockDownStrength=0
        KnockDownRadius=0
        FractureMeshRadius=0
        FracturePartVel=0
        ExplosionEffects=KFImpactEffectInfo'ZED_Matriarch_ARCH.Lightning_Storm_Explosion_Arch'
        ExplosionSound=AkEvent'WW_ZED_Matriarch.Play_Matriarch_Storm_Attack_01'
        MomentumTransferScale=0

        // Camera Shake
        CamShake=CameraShake'FX_CameraShake_Arch.Grenades.Default_Grenade'
        CamShakeInnerRadius=450
        CamShakeOuterRadius=900
        CamShakeFalloff=1.f
        bOrientCameraShakeTowardsEpicenter=true
    End Object
    ExplosionTemplate=ExploTemplate1
}