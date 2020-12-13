//=============================================================================
// KFAnim_BlendFacialExpression
//=============================================================================
// Facial expression blend node. Could be modified to extend
// AnimNode_MultiBlendPerBone which would add several features without a
// significant performance cost. For now just use the lightweight version.
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
// - Andrew "Strago" Ladenberger
//=============================================================================

class KFAnim_BlendFacialExpression extends AnimNodeBlendPerBone
	native(Anim);

/** If the LOD of this skeletal mesh is at or above this LOD, then this BlendNode will not be applied. */
var(Performance) int IgnoreAtOrAboveLOD;

cpptext
{
	virtual void GetBoneAtoms(FBoneAtomArray& Atoms, const TArray<BYTE>& DesiredBones, FBoneAtom& RootMotionDelta, INT& bHasRootMotion, FCurveKeyArray& CurveKeys);
};

defaultproperties
{	
	NodeName="Blend Facial Expression"

	Children(1)=(Name="Face")
	IgnoreAtOrAboveLOD=2

	// AnimNodeBlendPerBone settings
	bForceLocalSpaceBlend=true
	BranchStartBoneName={(Center_Lip_Upper, Left_Eyebrow, Right_Eyebrow, Left_Lip_Corner,
					Right_Lip_Corner, Eyelid_Lower, Eyelid_Upper, Jaw)}

	// AnimNode_MultiBlendPerBone settings
	//MaskList(0)={(
	//	BranchList={((BoneName=Center_Lip_Upper), (BoneName=Left_Eyebrow), (BoneName=Right_Eyebrow), (BoneName=Left_Lip_Corner), 
	//			(BoneName=Right_Lip_Corner), (BoneName=Eyelid_Lower), (BoneName=Eyelid_Upper), (BoneName=Jaw))}
	//		)}
}
