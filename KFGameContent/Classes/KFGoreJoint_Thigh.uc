//=============================================================================
// KFGoreJoint_Thigh
//=============================================================================
// Preset for Thigh gore joint
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//  - Sakib Saikia 6/6/2014
//=============================================================================

class KFGoreJoint_Thigh extends KFGoreJointInfo;

defaultproperties
{
	//----------------  Joint Name ---------------------------------
	HitBoneName=LeftUpLeg

	//----------------  Primary Dismemberment ----------------------
	BloodJets(0)={( bAttachToSocket=TRUE,
					SocketName=Hipsleftsocket,
					ParticleSystemTemplate=ParticleSystem'FX_Gore_EMIT.FX_CH_Blood_stream_01'
				 )}
	BloodTrails(0)={( ParticleSystemTemplate=ParticleSystem'FX_Gore_EMIT.FX_CH_Blood_Dismemberment_Trail' )}
	BloodMICParamName=(LLegUpper)
}
