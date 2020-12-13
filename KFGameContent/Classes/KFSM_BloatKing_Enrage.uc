//=============================================================================
// KFSM_BloatKing_Enrage
//=============================================================================
// Simple move to force an enrage transition for the Bloat King.
//=============================================================================
// Killing Floor 2
// Copyright (C) 2017 Tripwire Interactive LLC
//=============================================================================
class KFSM_BloatKing_Enrage extends KFSM_PlaySingleAnim;

defaultproperties
{
	AnimName=Rage_V1
	AnimStance=EAS_FullBody
	bDisableSteering=true
    bDisableMovement=true
    bDisableTurnInPlace=true
	bLockPawnRotation=true
    bCanBeInterrupted=false
	CustomRotationRate=(Pitch=0, Yaw=0, Roll=0)
}