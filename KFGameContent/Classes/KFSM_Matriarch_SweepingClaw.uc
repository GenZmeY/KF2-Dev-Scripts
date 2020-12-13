//=============================================================================
// KFSM_Matriarch_SweepingClaw
//=============================================================================
//
//=============================================================================
// Killing Floor 2
// Copyright (C) 2019 Tripwire Interactive LLC
//=============================================================================

class KFSM_Matriarch_SweepingClaw extends KFSM_PlaySingleAnim;

/** Max distance between the Matriarch and the current victim target */
var float MaxVictimDistance;

function SpecialMoveStarted( bool bForced, Name PrevMove )
{
    super.SpecialMoveStarted(bForced, PrevMove);

	KFPawn_ZedMatriarch(KFPOwner).PlaySweepingClawDialog();
}

function SpecialMoveEnded(Name PrevMove, Name NextMove)
{
    super.SpecialMoveEnded(PrevMove, NextMove);
}

defaultproperties
{
	Handle=KFSM_Matriarch_SweepingClaw

	MaxVictimDistance=100.f
	AnimName=Sweeping_Claw_V1
	AnimStance=EAS_FullBody
	bUseRootMotion=true
}