//=============================================================================
// KFSM_Matriarch_ScorpionWhip
//=============================================================================
//
//=============================================================================
// Killing Floor 2
// Copyright (C) 2019 Tripwire Interactive LLC
//=============================================================================

class KFSM_Matriarch_ScorpionWhip extends KFSM_TentacleGrappleBase;

function SpecialMoveStarted(bool bForced, Name PrevMove)
{
	super.SpecialMoveStarted(bForced, PrevMove);

	KFPawn_ZedMatriarch(KFPOwner).PlayScorpionWhipDialog();
}

function SpecialMoveEnded(Name PrevMove, Name NextMove)
{
	super.SpecialMoveEnded(PrevMove, NextMove);
}

event vector GetSourceLocation()
{
	return PawnOwner.Mesh.GetBoneLocation(TentacleStartBone);
}

defaultproperties
{
	Handle=KFSM_Matriarch_ScorpionWhip
    FollowerSpecialMove=SM_HansGrappleVictim
    GrabStartAnimName=Atk_Tentical_V1

    AlignDistance=108.f
    AlignFollowerInterpSpeed=22.f
    bStopAlignFollowerRotationAtGoal=false
    bAlignFollowerZ=true
    bAlignLeaderLocation=false
    bRetryCollisionCheck=false
    AlignSpeedModifier=0.2f

    TentacleStartTime=0.83f
    MaxRange=1500.f
    MaxClawReach=50.f
    DetachDistance=20.f
    RetractAirSpeed=5000.f

	TentacleStartCtrlName=TentacleAnchor
	TentacleControlNames=(Tentacle3, Tentacle4, Tentacle5, Tentacle6, Tentacle7)
    TentacleStartBone=Tentacle2
    TentacleEndBone=Tentacle7
    TentacleEndBoneOffset=-10
    TentacleBlendOutTime=0.33f
    CurveExponent=1.25f
}