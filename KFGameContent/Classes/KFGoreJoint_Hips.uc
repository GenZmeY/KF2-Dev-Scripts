//=============================================================================
// KFGoreJoint_Hips
//=============================================================================
// Preset for Hips gore joint
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//  - Sakib Saikia 6/6/2014
//=============================================================================

class KFGoreJoint_Hips extends KFGoreJointInfo;

defaultproperties
{
		//----------------  Joint Name ---------------------------------
	HitBoneName=Hips

	//----------------  Primary Dismemberment ----------------------
	BloodJets(0)={( ParticleSystemTemplate=ParticleSystem'FX_Gore_EMIT.FX_CH_Blood_stream_01' )}
	BloodTrails(0)={( ParticleSystemTemplate=ParticleSystem'FX_Gore_EMIT.FX_CH_Blood_Dismemberment_Trail' )}
	BloodMICParamName=(Decap)
}
