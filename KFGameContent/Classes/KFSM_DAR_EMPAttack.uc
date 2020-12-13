//=============================================================================
// KFSM_DAR_EMPAttack
//=============================================================================
//
//=============================================================================
// Killing Floor 2
// Copyright (C) 2018 Tripwire Interactive LLC
//=============================================================================
class KFSM_DAR_EMPAttack extends KFSM_RangedAttack;

struct EMPBlastHitInfo
{
	var Actor HitActor;
	var vector HitLocation;
	var TraceHitInfo HitInfo;
};

/** Template for the EMP */
var const ParticleSystem EMPPSCTemplate;

/** PSC generated from the EMP template.  Gets recycled in and out of the emitter pool as needed. */
var ParticleSystemComponent EMPPSC;

/** Template for EMP hit location FX */
var const ParticleSystem EMPHitPSCTemplate;

/** PSC for the hit location. On when the EMP is hitting anything, off when missing everything */
var ParticleSystemComponent EMPHitPSC;

/** AK Event for start of EMP charge */
var AkEvent EMPStartSFX;

/** AK Event for end of special move */
var AkEvent EMPEndSFX;

/** Looping sound for EMP hit */
var AkEvent EMPHitSFX;
var AkEvent EMPHitStopSFX;

/** Camera shake impact */
var CameraShake EMPHitShake;

/** Socket to attach origin of EMP */
var const name EMPSocketName;

/** Damagetype used for beam attack */
var const class<KFDamageType> EMPDamageType;

/** The maximum length the beam can be (used both for FX and damage) */
var const float MaxEMPLength;

/** The width, height, and depth of the beam, used for damage traces */
var const vector EMPExtent;

/** The total amount of damage an EMP blast will do. */
var int EMPDamage;

/** Cached list of all pawns hit by the EMP Blast. */
var array<EMPBlastHitInfo> Victims;

/** The amount of time after the beam is created before we apply damage. */
var float ApplyDamageDelay;

/** Draws a debug line between the beam's start and end points */
var const bool bDrawDebugEMP;

/** How long will a victim be grappled. */
var float GrappleTime;

function SpecialMoveStarted(bool bForced, name PrevMove)
{
	super(KFSM_PlaySingleAnim).SpecialMoveStarted(bForced, PrevMove);

	KFPOwner.UpdateGameplayMICParams();
	KFPOwner.SetWeaponAmbientSound(EMPStartSFX);

	Victims.length = 0;
}

function SpecialMoveEnded(name PrevMove, name NextMove)
{
	super.SpecialMoveEnded(PrevMove, NextMove);

	DisableEMP();

	if (KFPOwner != none && KFPOwner.IsAliveAndWell())
	{
		KFPOwner.UpdateGameplayMICParams();
		if( KFPOwner.IsWeaponAmbientSoundPlaying(EMPStartSFX) )
		{
			KFPOwner.SetWeaponAmbientSound(EMPEndSFX);
		}
	}

	KFPOwner.FlushPersistentDebugLines();
}

function ToggleEMP(bool bEnabled)
{
	local ParticleSysParam SourceParam;
	local vector EMPEnd;
	local int bHitTarget;

	if (bEnabled)
	{
		DoEMPHit(EMPEnd, bHitTarget);
		if (KFPOwner.WorldInfo.NetMode != NM_DedicatedServer)
		{
			if (EMPPSCTemplate != none)
			{
				EMPPSC = KFPOwner.WorldInfo.MyEmitterPool.SpawnEmitterMeshAttachment(EMPPSCTemplate, KFPOwner.Mesh, EMPSocketName, true);
				if (EMPPSC != none)
				{
					SourceParam.Name = 'SourceActor';
					SourceParam.ParamType = PSPT_Actor;
					SourceParam.Actor = KFPOwner;
					EMPPSC.InstanceParameters.Length = 0;
					EMPPSC.InstanceParameters.AddItem(SourceParam);

					DoEMPEffects(EMPEnd, bool(bHitTarget));
				}
			}
		}
	}
	else
	{
		DisableEMP();
		KFPOwner.SetWeaponAmbientSound(EMPEndSFX);
	}
}

function DisableEMP()
{
	ReleaseVictims();

	DeactivatePSC();

	DeactivateHitPSC();
}

function bool IsValidTarget(Actor HitActor)
{
	return (Pawn(HitActor) != none || (StaticMeshActor(HitActor) != none && !StaticMeshActor(HitActor).bResetCapable) || SkeletalMeshActor(HitActor) != none) && WithinRange(HitActor);
}

function bool WithinRange(Actor HitActor)
{
	return VSizeSq(HitActor.Location - KFPOwner.Location) <= Square(MaxEMPLength);
}

function DoEMPHit(out vector out_EMPEnd, out int out_bHitTarget)
{
	local vector SocketLocation;
	local EMPBlastHitInfo BlastHitInfo;
	local rotator SocketRot;
	local array<EMPBlastHitInfo> HitList;

	local vector HitLoc, HitNrm;
	local Actor HitActor;

	KFPOwner.Mesh.GetSocketWorldLocationAndRotation(EMPSocketName, SocketLocation, SocketRot);
	out_bHitTarget = int(false);
	out_EMPEnd = SocketLocation + vector(SocketRot) * MaxEMPLength;

	// We set the InteractionPawn for this move specifically, by implementing GetInteractionPawn() in
	// AICommand_DAR_EMPAttack:Command_SpecialMove

	if (KFPOwner.InteractionPawn != none)
	{
		if (IsValidTarget(KFPOwner.InteractionPawn))
		{
			BlastHitInfo.HitActor = KFPOwner.InteractionPawn;
			BlastHitInfo.HitLocation = KFPOwner.InteractionPawn.Location;
			HitList.AddItem(BlastHitInfo);
		}
	}
	else
	{
		GetEnemyByTrace(HitList, SocketLocation, out_EMPEnd);
	}

	foreach HitList(BlastHitInfo)
	{
		if (IsValidTarget(BlastHitInfo.HitActor))
		{
			HitActor = KFPOwner.Trace(HitLoc, HitNrm, BlastHitInfo.HitLocation, SocketLocation);
			if (HitActor != BlastHitInfo.HitActor)
			{
				BlastHitInfo.HitLocation = HitLoc;
			}
			else
			{
				out_bHitTarget = int(true);
				Victims.AddItem(BlastHitInfo);
			}
		}
	}

	if (HitList.length == 1)
	{
		out_EMPEnd = HitList[0].HitLocation - vect(0, 0, 64);
	}

	if (KFPOwner.Role == ROLE_Authority)
	{
		if (Victims.length > 0)
		{
			if (ApplyDamageDelay > 0)
			{
				KFPOwner.SetTimer(ApplyDamageDelay, false, 'ApplyDamage', self);
			}
			else
			{
				ApplyDamage();
			}
		}
	}
}

function GetEnemyByTrace(out array<EMPBlastHitInfo> out_EMPBlastHitInfo, vector StartLocation, vector EndLocation)
{
	local vector HitLocation, HitNormal;
	local Actor HitActor;
	local TraceHitInfo HitInfo;
	local EMPBlastHitInfo BlastHitInfo;

	out_EMPBlastHitInfo.length = 0;

	HitActor = KFPOwner.Trace(HitLocation, HitNormal, EndLocation, StartLocation, , EMPExtent, HitInfo, KFPOwner.TRACEFLAG_Bullet);
	if (HitActor != none)
	{
		if (IsValidTarget(HitActor))
		{
			BlastHitInfo.HitActor = HitActor;
			BlastHitInfo.HitLocation = HitLocation;
			BlastHitInfo.HitInfo = HitInfo;
			out_EMPBlastHitInfo.AddItem(BlastHitInfo);
		}
	}
}

function ApplyDamage()
{
	local EMPBlastHitInfo BlastHitInfo;

	foreach Victims(BlastHitInfo)
	{
		if(BlastHitInfo.HitActor != none)
		{
			BlastHitInfo.HitActor.TakeDamage(EMPDamage, KFPOwner.Controller, BlastHitInfo.HitLocation, vector(KFPOwner.Rotation), EMPDamageType, BlastHitInfo.HitInfo, KFPOwner);
			if (KFPawn(BlastHitInfo.HitActor) != none)
			{
				KFPawn(BlastHitInfo.HitActor).DoSpecialMove(SM_DARGrappleVictim, true, PawnOwner);
			}
		}
	}

	if (Victims.length > 0)
	{
		KFPOwner.SetTimer(GrappleTime, false, 'ReleaseVictims', self);
	}
}

function ReleaseVictims()
{
	local EMPBlastHitInfo BlastHitInfo;

	foreach Victims(BlastHitInfo)
	{
		if (BlastHitInfo.HitActor != none && KFPawn(BlastHitInfo.HitActor) != none)
		{
			KFPawn(BlastHitInfo.HitActor).EndSpecialMove(SM_DARGrappleVictim);
		}
	}

	Victims.length = 0;
}

function DoEMPEffects(vector EMPEnd, bool bHitTarget)
{
	local vector SocketLoc;
	local rotator SocketRot;

	EMPPSC.SetBeamTargetPoint(0, EMPEnd, 0);
	KFPOwner.Mesh.GetSocketWorldLocationAndRotation(EMPSocketName, SocketLoc, SocketRot);

	if (bHitTarget)
	{
		if (EMPHitPSC == none && EMPHitPSCTemplate != none)
		{
			EMPHitPSC = KFPOwner.WorldInfo.MyEmitterPool.SpawnEmitter(EMPHitPSCTemplate, EMPEnd);
		}

		if (EMPHitPSC != none)
		{
			EMPHitPSC.SetAbsolute(true, true, false);
			EMPHitPSC.SetTranslation(EMPEnd);
			EMPHitPSC.SetRotation(Rotator(EMPEnd - SocketLoc));
		}
	}
	else
	{
		DeactivateHitPSC();
	}

	if (bDrawDebugEMP)
	{
		KFPOwner.FlushPersistentDebugLines();
		KFPOwner.DrawDebugLine(SocketLoc, EMPEnd, 100, 128, 255, true);
	}
}

function bool DeactivatePSC()
{
	if (EMPPSC != none && EMPPSC.bIsActive)
	{
		EMPPSC.DeactivateSystem();
		EMPPSC = none;
		return true;
	}

	return false;
}

function bool DeactivateHitPSC()
{
	if (EMPHitPSC != none && EMPHitPSC.bIsActive)
	{
		EMPHitPSC.DeactivateSystem();
		EMPHitPSC = none;
		return true;
	}

	return false;
}

defaultproperties
{
	Handle=KFSM_DAR_EMPAttack

	// Animation
	AnimNames.Add(Atk_Shoot_EMP_V1)
	AnimStance=EAS_FullBody

	bDisableSteering=false
	bDisableMovement=true
    bDisableTurnInPlace=true

	bUseCustomRotationRate=true
    CustomRotationRate=(Pitch=50000, Yaw=25000, Roll=50000)

	EMPPSCTemplate=ParticleSystem'ZED_EvilDAR_EMIT.FX_EvilDar_Empblast_Beam'
    EMPHitPSCTemplate=ParticleSystem'ZED_EvilDAR_EMIT.FX_EvilDar_Empblast_Impact'
    EMPSocketName=EMP_Blast
    EMPStartSFX=AkEvent'WW_ZED_Evil_DAR.Play_ZED_EvilDAR_SFX_EMP_LP'
    EMPEndSFX=AkEvent'WW_ZED_Evil_DAR.Stop_ZED_EvilDAR_SFX_EMP_LP'
	EMPHitSFX=none
	EMPHitStopSFX=none

	EMPDamage=10;
	EMPDamageType=class'KFDT_DAR_EMPBlast'
	EMPExtent=(X=15.f, Y=15.f, Z=15.f)
	MaxEMPLength = 2500.f

	GrappleTime=2.5f //1.5

	FireOffsets(0)=(X=0.f,Y=0,Z=0)
}
