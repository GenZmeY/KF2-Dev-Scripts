//=============================================================================
// KFGoreJoint_Hand
//=============================================================================
// Preset for Hand gore joint
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//  - Sakib Saikia 6/6/2014
//=============================================================================

class KFGoreJoint_Hand extends KFGoreJointInfo;

defaultproperties
{
	defaultproperties
{
	//----------------  Joint Name ---------------------------------
	HitBoneName=LeftHand

	//----------------  Primary Dismemberment ----------------------
	BloodTrails(0)={( ParticleSystemTemplate=ParticleSystem'FX_Gore_EMIT.FX_CH_Blood_Dismemberment_Trail' )}
	BloodMICParamName=(LArmLower)
}
}
