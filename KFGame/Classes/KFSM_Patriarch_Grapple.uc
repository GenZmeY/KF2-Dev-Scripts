//=============================================================================
// KFSM_Patriach_Grapple
//=============================================================================
// Patriach tentacle grapple
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
// - Andrew "Strago" Ladenberger
//=============================================================================
class KFSM_Patriarch_Grapple extends KFSM_TentacleGrappleBase;

DefaultProperties
{
    Handle=KFSM_Patriarch_Grapple
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
    MaxRange=600.f
    MaxClawReach=50.f
    DetachDistance=20.f
    RetractAirSpeed=1000.f

	TentacleStartCtrlName=TentacleAnchor
	TentacleControlNames=(Tentacle3, Tentacle4, Tentacle5, Tentacle6, Tentacle7)
    TentacleStartBone=FrontTentacle2
    TentacleEndBone=FrontTentacle7
    TentacleEndBoneOffset=-10
    TentacleBlendOutTime=0.33f
    CurveExponent=1.25f
}