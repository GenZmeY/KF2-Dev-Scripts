//=============================================================================
// KFGoreJoint_Head
//=============================================================================
// Preset for Head gore joint
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//  - Sakib Saikia 6/6/2014
//=============================================================================

class KFGoreJoint_Head extends KFGoreJointInfo;

defaultproperties
{
	//----------------  Joint Name ---------------------------------
	HitBoneName=Head

	//----------------  Primary Dismemberment ----------------------
	BloodJets(0)={( bAttachToSocket=TRUE,
					SocketName=NeckSocket,
					ParticleSystemTemplate=ParticleSystem'FX_Gore_EMIT.FX_Gore_neck_01'
				 )}
	BloodTrails(0)={( ParticleSystemTemplate=ParticleSystem'FX_Gore_EMIT.FX_CH_Blood_Dismemberment_Trail' )}
	BloodMICParamName=(Decap)

	//----------------  Auxiliary Dismemberment --------------------
	BoneShrinkGore (0)={(   ConstrainToDamageGroups=(DGT_Shotgun),
							KillingBlowDamageGroups=(DGT_AssaultRifle,DGT_Rifle,DGT_Submachinegun,DGT_Handgun),
							PartialBreakBones=(
								(BoneName=Head,
							 	 BloodJets=(
							 		(bAttachToSocket=TRUE,
								 	 SocketName=NeckSocket,
								 	 ParticleSystemTemplate=ParticleSystem'FX_Gore_EMIT.FX_Gore_neck_01')),
								 BloodMICParamName=(Decap),
							 	 ParticleSystemTemplate=ParticleSystem'FX_Gore_EMIT.FX_HeadExplode_01')) )}

	BoneShrinkGore (1)={(   ConstrainToDamageGroups=(DGT_AssaultRifle,DGT_Rifle,DGT_Submachinegun,DGT_Handgun),
							PartialBreakBones=(
								(BoneName=Gore_FrontL,
								BloodJets=(
							 		(bAttachToSocket=TRUE,
								 	 SocketName=Gore_FrontLsocket,
								 	 ParticleSystemTemplate=ParticleSystem'FX_Gore_EMIT.FX_Gore_chunk_01')),
								BloodMICParamName=(FaceChunk),
								ParticleSystemTemplate=ParticleSystem'FX_Gore_EMIT.FX_Blood_hit_01_mic'),

								(BoneName=Gore_FrontR,
								BloodJets=(
							 		(bAttachToSocket=TRUE,
								 	 SocketName=Gore_FrontRsocket,
								 	 ParticleSystemTemplate=ParticleSystem'FX_Gore_EMIT.FX_Gore_chunk_01')),
								 BloodMICParamName=(FaceChunk),
							 	 ParticleSystemTemplate=ParticleSystem'FX_Gore_EMIT.FX_Blood_hit_01_mic'),

								(BoneName=Gore_BackR,
								BloodJets=(
							 		(bAttachToSocket=TRUE,
								 	 SocketName=Gore_BackRsocket,
								 	 ParticleSystemTemplate=ParticleSystem'FX_Gore_EMIT.FX_Gore_chunk_01')),
								 BloodMICParamName=(FaceChunk,Decap),
							 	 ParticleSystemTemplate=ParticleSystem'FX_Gore_EMIT.FX_Blood_hit_01_mic'),

								(BoneName=Gore_BackL,
								BloodJets=(
							 		(bAttachToSocket=TRUE,
								 	 SocketName=Gore_BackLsocket,
								 	 ParticleSystemTemplate=ParticleSystem'FX_Gore_EMIT.FX_Gore_chunk_01')),
								 BloodMICParamName=(FaceChunk,Decap),
							 	 ParticleSystemTemplate=ParticleSystem'FX_Gore_EMIT.FX_Blood_hit_01_mic'),

								(BoneName=Gore_Jaw,
								BloodJets=(
							 		(bAttachToSocket=TRUE,
								 	 SocketName=Gore_Jawsocket,
								 	 ParticleSystemTemplate=ParticleSystem'FX_Gore_EMIT.FX_Gore_Jaw_01')),
								 BloodMICParamName=(FaceChunk,Decap),
							 	 ParticleSystemTemplate=ParticleSystem'FX_Gore_EMIT.FX_Blood_hit_01_mic')) )}
}
