//=============================================================================
// KFGoreJoint_Spine1
//=============================================================================
// Preset for Spine1 gore joint
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//  - Sakib Saikia 6/6/2014
//=============================================================================

class KFGoreJoint_Spine1 extends KFGoreJointInfo;

defaultproperties
{
	//----------------  Joint Name ---------------------------------
	HitBoneName=Spine1

	//----------------  Primary Dismemberment ----------------------
	BloodJets(0)={( ParticleSystemTemplate=ParticleSystem'FX_Gore_EMIT.FX_Spine_Jet_01' )}
	BloodTrails(0)={( ParticleSystemTemplate=ParticleSystem'FX_Gore_EMIT.FX_CH_Blood_Dismemberment_Trail' )}
	BloodMICParamName=(abdomen)

	//----------------  Auxiliary Dismemberment --------------------
	BoneShrinkGore (0)={(   ConstrainToDamageGroups=(DGT_Shotgun),
							PartialBreakBones=(
								(BoneName=Gore_Abdomen,
								 BloodMICParamName=(abdomen))) )}

	HitExplosionGore(0)={(  ConstrainToDamageGroups=(DGT_Shotgun,DGT_Explosive),
							BreakBones=(
    							(BoneName=LeftShoulder,
    							BloodTrails=((ParticleSystemTemplate=ParticleSystem'FX_Gore_EMIT.FX_CH_Blood_Dismemberment_Trail')),
    							BloodMICParamName=(VerticleSlice)),

    							(BoneName=Gore_Abdomen,
    							BloodTrails=((ParticleSystemTemplate=ParticleSystem'FX_Gore_EMIT.FX_CH_Blood_Dismemberment_Trail')),
    							BloodMICParamName=(abdomen))) )}

	DependentBreakGore(0)={(ConstrainToDamageGroups=(DGT_MeleeSlash),
							DependentBones=(
								(BoneName=Gore_Abdomen,
								BloodTrails=((ParticleSystemTemplate=ParticleSystem'FX_Gore_EMIT.FX_CH_Blood_Dismemberment_Trail')),
								BloodMICParamName=(abdomen))) )}

}
