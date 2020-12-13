//=============================================================================
// KFGoreJoint_Chest
//=============================================================================
// Preset for Spine2 gore joint
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//  - Sakib Saikia 6/10/2014
//=============================================================================

class KFGoreJoint_Chest extends KFGoreJointInfo;

defaultproperties
{
	//----------------  Joint Name ---------------------------------
	HitBoneName=Spine2

	//----------------  Primary Dismemberment ----------------------
	bNonBreakableJoint=TRUE

    //----------------  Auxiliary Dismemberment --------------------
    HitExplosionGore(0)={(  ConstrainToDamageGroups=(DGT_Shotgun,DGT_Explosive),
							BreakBones=(
    							(BoneName=LeftShoulder,
    							BloodTrails=((ParticleSystemTemplate=ParticleSystem'FX_Gore_EMIT.FX_CH_Blood_Dismemberment_Trail')),
    							BloodMICParamName=(VerticleSlice)),

    							(BoneName=Gore_Abdomen,
    							BloodTrails=((ParticleSystemTemplate=ParticleSystem'FX_Gore_EMIT.FX_CH_Blood_Dismemberment_Trail')),
    							BloodMICParamName=(abdomen))) )}
}
