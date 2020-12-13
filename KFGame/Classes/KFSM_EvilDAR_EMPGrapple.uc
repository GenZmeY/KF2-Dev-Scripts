//=============================================================================
// KFSM_EvilDAR_EMPGrapple
//=============================================================================
// Killing Floor 2
// Copyright (C) 2018 Tripwire Interactive LLC
//=============================================================================
class KFSM_EvilDAR_EMPGrapple extends KFSM_GrappleVictim;

function SpecialMoveStarted(bool bForced, Name PrevMove )
{
	super.SpecialMoveStarted(bForced, PrevMove);
	PawnOwner.Velocity = vect(0,0,0);
}

function SetGrabEffect(KFPlayerController KFPC, bool bValue)
{
	KFPC.SetGrabEffectEMP(bValue, (Leader != none && Leader.IsHumanControlled()));
}

defaultproperties
{
	// Audio
	GrabbedSoundModeStartEvent=AkEvent'WW_ZED_Evil_DAR.Play_ZED_EvilDAR_EMP_PlayerGrabbed_LP'
	GrabbedSoundModeEndEvent=AkEvent'WW_ZED_Evil_DAR.Stop_ZED_EvilDAR_EMP_PlayerGrabbed_LP'
}
