//=============================================================================
// KFSM_Matriarch_PlasmaCannon
//=============================================================================
// Flamethrower-style attack, lasts 5 seconds, interruptable with big damage.
//=============================================================================
// Killing Floor 2
// Copyright (C) 2016 Tripwire Interactive LLC
// - Dan Weiss
//=============================================================================

class KFSM_Matriarch_PlasmaCannon extends KFSM_PlaySingleAnim;

/** Max distance between the Matriarch and the current victim target */
var float MaxVictimDistance;

/** Name of socket that shooting originates from.  Used for both visual attach and damage trace */
var name ShootingSocketName;

/** Size of the beam being fired */
var Vector BeamSize;

/** Amount of time between attempted damage ticks */
var float DamageTickRate;

/** Per-tick damage amount.  Done to each target in the beam */
var float DamagePerTick;

/** Damage type class */
var class<DamageType> CannonDamageType;

/** Template for the plasma beam */
var ParticleSystem BeamPSCTemplate;

/** PSC generated from the beam template.  Gets recycled in and out of the emitter pool as needed. */
var ParticleSystemComponent BeamPSC;

/** Template for beam hit location FX */
var const ParticleSystem BeamHitPSCTemplate;

/** PSC for the hit location. On when the beam is hitting anything, off when missing everything */
var ParticleSystemComponent BeamHitPSC;

var ParticleSystem MuzzleFlashPSCTemplate;
var ParticleSystemComponent MuzzleFlashPSC;

/** Amount of time that's passed since the last damage tick occurred */
var float SinceLastDamage;

/** AK Event for start of beam charge */
var AkEvent BeamStartSFX;

/** AK Event for end of special move */
var AkEvent BeamEndSFX;

/** Looping sound for beam hit */
var AkEvent BeamHitSFX;
var AkEvent BeamHitStopSFX;


/** Wind Up animation name */
var Name WindUpAnimName;

/** Wind Down animation name */
var Name WindDownAnimName;

var bool bTickDamage;

var KFPawn_ZedMatriarch MyMatPawn;

/*
	Targeting
*/

/** Time to check before firing if an enemy is still visible */
var float VisibilityCheckTime, VisibilityCheckTimer;
var float AngleCheckDot;
var bool bLogTargeting;

function SpecialMoveStarted( bool bForced, Name PrevMove )
{
    super.SpecialMoveStarted(bForced, PrevMove);

	PlayWindUpAnimation();

	MyMatPawn = KFPawn_ZedMatriarch(KFPOwner);
	MyMatPawn.PlayPlasmaCannonDialog();
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
	    PlayWindDownAnim();
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
				KFPOwner.DoSpecialMove(SM_HoseWeaponAttack, true,, 1);
			}
			else
			{
				KFPOwner.DoSpecialMove(SM_HoseWeaponAttack, true,, 2);
			}
		}
		break;

	case AnimName:
		PlayWindDownAnim();
		break;

	case WindDownAnimName:
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
	PlaySpecialMoveAnim(WindUpAnimName, EAS_FullBody, BlendInTime, BlendOutTime, 1.f);

	KFPOwner.ZeroMovementVariables();
}

/** Plays our fire animation, starts weapon fire */
function PlayFireAnim()
{
	MyMatPawn.SetGunTracking(true);

	PlaySpecialMoveAnim(AnimName, EAS_FullBody, 0.1f, 0.2f);

	ActivateFX();
	KFPOwner.ZeroMovementVariables();
	KFPOwner.SetWeaponAmbientSound(BeamStartSFX);
	bTickDamage = true;

	if (KFPOwner.Role == ROLE_Authority)
	{
		VisibilityCheckTimer = VisibilityCheckTime;
	}

	//bUseCustomRotationRate = true;
	PawnOwner.RotationRate = CustomRotationRate;
}

/** Plays our wind down animation, stops firing, disables barrel spin skel controller */
function PlayWindDownAnim()
{
	MyMatPawn.SetGunTracking(false);

	PlaySpecialMoveAnim(WindDownAnimName, EAS_FullBody, BlendInTime, BlendOutTime, 1.f);

	KFPOwner.ZeroMovementVariables();
	bTickDamage = false;
	DeactivateFX();
}

function SpecialMoveEnded(Name PrevMove, Name NextMove)
{
    super.SpecialMoveEnded(PrevMove, NextMove);

	KFPOwner.RotationRate = KFPOwner.default.RotationRate;

	bTickDamage = false;
	DeactivateFX();
}

function ActivateFX()
{
	local ParticleSysParam SourceParam;

	if (KFPOwner.WorldInfo.NetMode != NM_DedicatedServer)
	{
		if (BeamPSCTemplate != none)
		{
			BeamPSC = PawnOwner.WorldInfo.MyEmitterPool.SpawnEmitterMeshAttachment(
				BeamPSCTemplate, PawnOwner.Mesh, 'LeftHand');
			if (BeamPSC != none)
			{
				SourceParam.Name = 'SourceActor';
				SourceParam.ParamType = PSPT_Actor;
				SourceParam.Actor = PawnOwner;

				BeamPSC.InstanceParameters.AddItem(SourceParam);
			}
		}

		if (MuzzleFlashPSCTemplate != none)
		{
			MuzzleFlashPSC = PawnOwner.WorldInfo.MyEmitterPool.SpawnEmitterMeshAttachment(
				MuzzleFlashPSCTemplate, PawnOwner.Mesh, 'LeftHand');
			if (MuzzleFlashPSC != none)
			{
				SourceParam.Name = 'SourceActor';
				SourceParam.ParamType = PSPT_Actor;
				SourceParam.Actor = PawnOwner;

				MuzzleFlashPSC.InstanceParameters.AddItem(SourceParam);
			}
		}
	}
}

function DeactivateFX()
{
	if (BeamPSC != none)
    {
        BeamPSC.DeactivateSystem();
        BeamPSC = none;
		KFPOwner.SetWeaponAmbientSound(BeamEndSFX);
    }

	if (BeamHitPSC != none)
    {
        BeamHitPSC.DeactivateSystem();
        BeamHitPSC = none;
		MyMatPawn.BeamHitAC.PlayEvent(BeamHitStopSFX);
    }

	if (MuzzleFlashPSC != none)
	{
		MuzzleFlashPSC.DeactivateSystem();
		MuzzleFlashPSC = none;
	}

    if (MyMatPawn.BeamHitAC != none)
    {
        MyMatPawn.BeamHitAC.StopEvents();
    }
}

function Actor GetBeamTarget(out vector HitLocation)
{
	local Actor HitActor;
	local vector SocketLocation, HitNormal, TraceEnd;
	local rotator SocketRotation;

	// force the beam vfx on the client to hit the pawn that the server is hitting
	if (PawnOwner.Role < ROLE_Authority && MyMatPawn.BeamTarget != none)
	{
		HitLocation = MyMatPawn.BeamTarget.Mesh.GetBoneLocation(MyMatPawn.GunTargetBoneName);
		return MyMatPawn.BeamTarget;
	}

	PawnOwner.Mesh.GetSocketWorldLocationAndRotation(ShootingSocketName, SocketLocation, SocketRotation);
	TraceEnd = SocketLocation + vector(SocketRotation) * MaxVictimDistance;

	foreach PawnOwner.TraceActors(
		class'Actor', HitActor, HitLocation, HitNormal, TraceEnd, SocketLocation, BeamSize)
	{
		if (IsValidBeamTarget(HitActor))
		{
			break;
		}
		else
		{
			HitActor = none;
		}
	}

	return HitActor;
}

function bool IsValidBeamTarget(Actor HitActor)
{
    //If we're a pawn or we're a non-resettable static mesh actor
    return Pawn(HitActor) != none || (StaticMeshActor(HitActor) != none && !StaticMeshActor(HitActor).bResetCapable) || SkeletalMeshActor(HitActor) != none || StaticMeshCollectionActor(HitActor) != none;
}

function Tick(float DeltaTime)
{
	local Actor HitActor;
	local vector SocketLocation, HitLocation;
	local rotator SocketRotation;

    super.Tick(DeltaTime);

	if (bTickDamage)
	{
		HitActor = GetBeamTarget(HitLocation);

		if (PawnOwner.Role == ROLE_Authority)
		{
			SinceLastDamage += DeltaTime;
			while (SinceLastDamage > DamageTickRate)
			{
				if (HitActor != none)
				{
					HitActor.TakeDamage(
						DamagePerTick, PawnOwner.Controller, HitActor.Location, vect(0,0,0), CannonDamageType);

					if (KFPawn(HitActor) != none && !KFPawn(HitActor).IsAliveAndWell())
					{
						HitActor = none;
					}
				}
				MyMatPawn.BeamTarget = Pawn(HitActor);
				SinceLastDamage -= DamageTickRate;
			}

			if (bLogTargeting)
			{
				`log("(PLASMA BEAM TARGETING) "$self$"::Tick - HitActor: "$HitActor$"; VisibilityCheckTimer: "$VisibilityCheckTimer);
			}

			if (CanHitEnemy())
			{
				VisibilityCheckTimer = VisibilityCheckTime;
			}
			else
			{
				VisibilityCheckTimer -= DeltaTime;
				if (VisibilityCheckTimer <= 0)
				{
					FindNewEnemy();
					VisibilityCheckTimer = VisibilityCheckTime;
				}
			}
		}

		if (PawnOwner.WorldInfo.NetMode != NM_DedicatedServer)
		{
			if (HitActor != none)
			{
				if (BeamPSC != none)
				{
					BeamPSC.SetBeamTargetPoint(0, HitLocation, 0);
				}

				if (BeamHitPSC == none)
				{
					BeamHitPSC = KFPOwner.WorldInfo.MyEmitterPool.SpawnEmitter(BeamHitPSCTemplate, HitLocation);
					MyMatPawn.BeamHitAC.PlayEvent(BeamHitSFX);
				}

				if (BeamHitPSC != none)
				{
					PawnOwner.Mesh.GetSocketWorldLocationAndRotation(ShootingSocketName, SocketLocation, SocketRotation);
					BeamHitPSC.SetAbsolute(true, true, false);
					BeamHitPSC.SetTranslation(HitLocation);
					BeamHitPSC.SetRotation(SocketRotation);
				}
			}
			else
			{
				if (BeamHitPSC != none && BeamHitPSC.bIsActive)
				{
					BeamHitPSC.DeactivateSystem();
					BeamHitPSC = none;
					MyMatPawn.BeamHitAC.PlayEvent(BeamHitStopSFX);
				}
			}
		}
	}
}

function bool CanHitEnemy()
{
	local Actor HitActor;
	local vector SocketLocation, HitLocation, HitNormal, ToEnemy, TraceEnd, GunTargetBoneLocation;
	local rotator SocketRotation;

	PawnOwner.Mesh.GetSocketWorldLocationAndRotation(ShootingSocketName, SocketLocation, SocketRotation);
	GunTargetBoneLocation = KFPOwner.Controller.Enemy.Mesh.GetBoneLocation(MyMatPawn.GunTargetBoneName);
	ToEnemy = Normal(GunTargetBoneLocation - SocketLocation);
	TraceEnd = SocketLocation + ToEnemy * MaxVictimDistance;

	HitActor = PawnOwner.Trace(HitLocation, HitNormal, TraceEnd, SocketLocation, true);
	return HitActor == KFPOwner.Controller.Enemy;
}

function FindNewEnemy()
{
	local KFPawn_Human KFPH, BestTarget;
	local vector StartTrace, EndTrace, ToTarget;
	local rotator SocketRotation;
	local float TargetDot, BestDot, MaxVictimDistanceSq;

	local vector HitLocation, HitNormal;
	local actor HitActor;

	KFPOwner.Mesh.GetSocketWorldLocationAndRotation(ShootingSocketName, StartTrace, SocketRotation);
	MaxVictimDistanceSq = MaxVictimDistance * MaxVictimDistance;

	foreach KFPOwner.WorldInfo.AllPawns(class'KFPawn_Human', KFPH)
	{
		if (bLogTargeting)
		{
			`log("(PLASMA BEAM TARGETING) "$self$"::FindNewEnemy - Potential target: "$KFPH);
		}

		ToTarget = KFPH.Location - StartTrace;
		if (VSizeSq(ToTarget) > MaxVictimDistanceSq)
		{
			if (bLogTargeting)
			{
				`log("(PLASMA BEAM TARGETING) "$self$"::FindNewEnemy - too far");
			}
			continue;
		}

		ToTarget = Normal(ToTarget);
		TargetDot = ToTarget dot (vector(SocketRotation));
		if (TargetDot < AngleCheckDot || TargetDot < BestDot)
		{
			if (bLogTargeting)
			{
				`log("(PLASMA BEAM TARGETING) "$self$"::FindNewEnemy - bad angle");
			}
			continue;
		}

		EndTrace = StartTrace + (ToTarget * MaxVictimDistance);
		HitActor = KFPOwner.Trace(HitLocation, HitNormal, EndTrace, StartTrace, true,,, 1);
		if (bLogTargeting)
		{
			`log("(PLASMA BEAM TARGETING) "$self$"::FindNewEnemy - HitActor: "$HitActor);
		}

		if (HitActor != KFPH)
		{
			if (bLogTargeting)
			{
				`log("(PLASMA BEAM TARGETING) "$self$"::FindNewEnemy - obstructed");
			}
			continue;
		}

		if (bLogTargeting)
		{
			`log("(PLASMA BEAM TARGETING) "$self$"::FindNewEnemy - okay!");
		}

		BestTarget = KFPH;
		BestDot = TargetDot;
	}

	if (bLogTargeting)
	{
		`log("(PLASMA BEAM TARGETING) "$self$"::FindNewEnemy - BestTarget: "$BestTarget);
	}

	if (BestTarget != none)
	{
		if (BestTarget != KFPOwner.Controller.Enemy)
		{
			KFAIController(KFPOwner.Controller).ChangeEnemy(BestTarget, false);
		}
	}
	else
	{
		KFPOwner.DoSpecialMove(SM_HoseWeaponAttack, true,, 2);
	}
}

defaultproperties
{
    //Special Move
    Handle = KFSM_Matriarch_PlasmaCannon
    bDisableSteering = false
    bDisableMovement = true
	bDisableTurnInPlace=true
    bCanBeInterrupted=false
	bShouldDeferToPostTick=true
    bUseCustomRotationRate=false // we will manually turn to true after wind-up
    CustomRotationRate=(Pitch=50000, Yaw=4500, Roll=50000)

    //Plasma Cannon
    MaxVictimDistance = 2500.f
	BeamSize = (X=15.0,Y=15.0,Z=15.0)
	DamageTickRate = 0.1f
    ShootingSocketName = Hand_FX_End_L
    DamagePerTick = 7.0f
    CannonDamageType = class'KFDT_EMP_MatriarchPlasmaCannon'
    BeamPSCTemplate = ParticleSystem'ZED_Matriarch_EMIT.FX_Plasma_Cannon_Beam_01'
	BeamHitPSCTemplate=ParticleSystem'ZED_Matriarch_EMIT.FX_Plasma_Cannon_Impact_01'
	MuzzleFlashPSCTemplate=ParticleSystem'ZED_Matriarch_EMIT.FX_Plasma_Cannon_Muzzleflash_01'
	VisibilityCheckTime=0.8f
	AngleCheckDot=0.500f // 60 degrees in front, type cos(X degrees) into google, replacing "X" with a number 0-90, lower is narrower FOV
	bLogTargeting=false

	//Sounds
    BeamStartSFX=AkEvent'WW_ZED_Matriarch.Play_Matriarch_Plasma_Cannon_Loop_01'
    BeamEndSFX=AkEvent'WW_ZED_Matriarch.Play_Matriarch_Plasma_Cannon_End_01'
	BeamHitSFX=AkEvent'WW_ZED_Matriarch.Play_Matriarch_SFX_Attack_PulseCannon_Beam_Hit_LP'
	BeamHitStopSFX=AkEvent'WW_ZED_Matriarch.Stop_Matriarch_SFX_Attack_PulseCannon_Beam_Hit_LP'

    //Animation
	WindUpAnimName=Plasma_Cannon_TO_Load
    AnimName=Plasma_Cannon_Idle
	WindDownAnimName=Plasma_Cannon_TO_Idle
    AnimStance=EAS_UpperBody
}