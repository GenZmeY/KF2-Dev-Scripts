//=============================================================================
// KFProj_Bullet_MatriarchTeslaBlast
//=============================================================================
// Killing Floor 2
// Copyright (C) 2019 Tripwire Interactive LLC
//=============================================================================

class KFProj_Bullet_MatriarchTeslaBlast extends KFProj_Bullet
	hidedropdown;

var ParticleSystem BeamPS, BeamHitPS;
var transient ParticleSystemComponent BeamPSC, BeamHitPSC;
var transient repnotify Pawn SourcePawn;
var transient repnotify Pawn TargetPawn;

replication
{
	if (bNetInitial)
		SourcePawn, TargetPawn;
}

simulated event ReplicatedEvent(name VarName)
{
	switch (VarName)
	{
	case nameof(SourcePawn):
	case nameof(TargetPawn):
		ActivateVFX();
		break;

	default:
		super.ReplicatedEvent(VarName);
	};
}

simulated event PostBeginPlay()
{
	super.PostBeginPlay();
	StopSimulating();
	SetTickIsDisabled(true);
}

simulated function ActivateVFX()
{
	local vector TargetLocation;

	if (BeamPSC == none)
	{
		if (KFPawn_ZedMatriarch(SourcePawn) != none)
		{
			BeamPSC = WorldInfo.MyEmitterPool.SpawnEmitterMeshAttachment(BeamPS, SourcePawn.Mesh, 'Hand_FX_End_L', true);
		}
		else
		{
			BeamPSC = WorldInfo.MyEmitterPool.SpawnEmitter(BeamPS, Location,, SourcePawn);
		}

		TargetLocation = TargetPawn.Mesh.GetBoneLocation(class'KFPawn_ZedMatriarch'.default.GunTargetBoneName);
		BeamHitPSC = WorldInfo.MyEmitterPool.SpawnEmitter(BeamHitPS, TargetLocation,, TargetPawn);

		BeamPSC.SetBeamTargetPoint(0, TargetLocation, 0);
		SetTickIsDisabled(false);
	}
}

simulated function DeactivateVFX()
{
	if (BeamPSC != none)
	{
		BeamPSC.DeactivateSystem();
		BeamPSC = none;
	}

	if (BeamHitPSC != none)
	{
		BeamHitPSC.DeactivateSystem();
		BeamHitPSC = none;
	}
}

simulated function Tick(float DeltaTime)
{
	super.Tick(DeltaTime);

	if (BeamPSC != none)
	{
		BeamPSC.SetBeamTargetPoint(0, TargetPawn.Mesh.GetBoneLocation(class'KFPawn_ZedMatriarch'.default.GunTargetBoneName), 0);
	}
}

simulated function Destroyed()
{
	super.Destroyed();
	DeactivateVFX();
}

defaultproperties
{
	MaxSpeed=0
	Speed=0

	DamageRadius=0

	BeamPS=ParticleSystem'ZED_Matriarch_EMIT.FX_Teslablast_Beam_01'
	BeamHitPS=ParticleSystem'ZED_Matriarch_EMIT.FX_Tesla_Blast_Impact_01'

	ProjFlightTemplate=none
	ImpactEffects=none

	ProjEffectsFadeOutDuration=0.5f

	bSyncToOriginalLocation=true
	bSyncToThirdPersonMuzzleLocation=true
	bRotationFollowsVelocity=false
	bNoReplicationToInstigator=true
	bUseClientSideHitDetection=false
}