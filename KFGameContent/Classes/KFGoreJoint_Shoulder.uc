//=============================================================================
// KFGoreJoint_Shoulder
//=============================================================================
// Preset for Shoulder gore joint
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//  - Sakib Saikia 6/6/2014
//=============================================================================

class KFGoreJoint_Shoulder extends KFGoreJointInfo;

defaultproperties
{
	//----------------  Joint Name ---------------------------------
	HitBoneName=LeftShoulder

	//----------------  Primary Dismemberment ----------------------
	BloodTrails(0)={( bAttachToSocket=TRUE,
                      SocketName=Spinal_Attach,
                      ParticleSystemTemplate=ParticleSystem'FX_Gore_EMIT.FX_CH_Blood_Dismemberment_Trail' )}
	BloodMICParamName=(VerticleSlice)
	DismembermentEffects(0)={( ParticleSystemTemplate=ParticleSystem'FX_Gore_EMIT.FX_Chest_explode' )}

	//----------------  Auxiliary Dismemberment --------------------
	DependentBreakGore(0)={(ConstrainToDamageGroups=(DGT_MeleeSlash),
							DependentBones=(
								(BoneName=Gore_FrontL,
								BloodJets=(
									(bAttachToSocket=TRUE,
								 	 SocketName=Gore_FrontLsocket,
								 	 ParticleSystemTemplate=ParticleSystem'FX_Gore_EMIT.FX_Gore_chunk_01')),
								BloodMICParamName=(FaceChunk)),

								(BoneName=Gore_BackL,
								BloodJets=(
									(bAttachToSocket=TRUE,
								 	 SocketName=Gore_BackLsocket,
								 	 ParticleSystemTemplate=ParticleSystem'FX_Gore_EMIT.FX_Gore_chunk_01')),
								BloodMICParamName=(FaceChunk)),

								(BoneName=gore_jaw,
								BloodJets=(
									(bAttachToSocket=TRUE,
								 	 SocketName=Gore_Jawsocket,
								 	 ParticleSystemTemplate=ParticleSystem'FX_Gore_EMIT.FX_Gore_Jaw_01')),
								BloodMICParamName=(FaceChunk)),

                                (BoneName=Gore_Abdomen,
								BloodMICParamName=(abdomen))) )}
}
