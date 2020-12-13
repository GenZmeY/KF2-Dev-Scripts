//=============================================================================
// KFSM_DAR_RocketAttack
//=============================================================================
//
//=============================================================================
// Killing Floor 2
// Copyright (C) 2018 Tripwire Interactive LLC
//=============================================================================
class KFSM_DAR_RocketAttack extends KFSM_RangedAttack;

defaultproperties
{
	Handle=KFSM_DAR_RocketAttack

	// Animation
	AnimNames.Add(Atk_Rocket_V1)
	AnimStance=EAS_FullBody

	FireOffsets(0)=(X=0.f,Y=0,Z=0)
}
