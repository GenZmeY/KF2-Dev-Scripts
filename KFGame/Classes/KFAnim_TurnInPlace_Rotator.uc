//=============================================================================
// KFAnim_TurnInPlace_Rotator
//=============================================================================
// Node to to rotate mesh, paired with KFAnim_TurnInPlace
// This could be done in the TurnInPlace node, except that the TurnInPlace node
// is often placed after an upper body blend.  This rotator component should
// be placed before blend by bone nodes so that the entire body is effected.
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//=============================================================================
// Based on GearAnim_TurnInPlace_Rotator 
// Copyright 1998-2011 Epic Games, Inc. All Rights Reserved.
//=============================================================================

class KFAnim_TurnInPlace_Rotator extends AnimNodeBlendBase
	native(Anim);

/** Internal cached pointers */
var const duplicatetransient KFAnim_TurnInPlace TurnInPlaceNode;

cpptext
{
	// AnimNode interface
	virtual void PostAnimNodeInstance(UAnimNode* SourceNode, TMap<UAnimNode*,UAnimNode*>& SrcToDestNodeMap);
	virtual void InitAnim(USkeletalMeshComponent* MeshComp, UAnimNodeBlendBase* Parent);
	virtual void GetBoneAtoms(FBoneAtomArray& Atoms, const TArray<BYTE>& DesiredBones, FBoneAtom& RootMotionDelta, INT& bHasRootMotion, FCurveKeyArray& CurveKeys);
}

defaultproperties
{
	Children(0)=(Name="Input",Weight=1.0)
	bFixNumChildren=TRUE

	CategoryDesc = "TurnInPlace"
}
