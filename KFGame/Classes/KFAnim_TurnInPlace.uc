//=============================================================================
// KFAnim_TurnInPlace
//=============================================================================
// Blender to handle turning in place transitions
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//=============================================================================
// Based on GearAnim_TurnInPlace 
// Copyright 1998-2011 Epic Games, Inc. All Rights Reserved.
//=============================================================================

class KFAnim_TurnInPlace extends AnimNodeBlend
	native(Anim);

/** Node needs to be initialized to track Pawn rotations */
var		const transient bool		bInitialized;
/** Track Pawn rotation changes */
var		const transient int			LastPawnYaw;
/** Pawn rotation rate for this frame */
var		const transient float		PawnRotationRate;
/** Current Yaw offset between camera and Pawn */
var()		  transient	int			YawOffset;

/**
 * If TRUE, this node will try to delay his parent from blending to another child,
 * So the turn in place animation can play fully.
 */
var()	bool					bDelayBlendOutToPlayAnim;

/** Internal cached pointer to Owner */
var const transient KFPawn	PawnOwner;
var const transient Actor   CachedBase;

struct native RotTransitionInfo
{
	var()	Float	RotationOffset;
	var()	Name	TransName;
};

var()	Array<RotTransitionInfo>	RotTransitions;

var()	float						TransitionBlendInTime;
var		const bool					bPlayingTurnTransition;
var		const INT					CurrentTransitionIndex;
var()	float						TransitionThresholdAngle;

/**
 * Internal, cached array of player nodes.
 * Used to play different types of transition animations.
 */
var	duplicatetransient array<KFAnimSeq_TurnInPlace>	PlayerNodes;
//var	duplicatetransient KFAnimSeq_TurnInPlace PlayerNodeSeq;

cpptext
{
	// AnimNode interface
	virtual void InitAnim(USkeletalMeshComponent* MeshComp, UAnimNodeBlendBase* Parent);
	virtual void PostAnimNodeInstance(UAnimNode* SourceNode, TMap<UAnimNode*,UAnimNode*>& SrcToDestNodeMap);
	virtual	void TickAnim(FLOAT DeltaSeconds);
	virtual void GetBoneAtoms(FBoneAtomArray& Atoms, const TArray<BYTE>& DesiredBones, FBoneAtom& RootMotionDelta, INT& bHasRootMotion, FCurveKeyArray& CurveKeys);
	virtual void OnBecomeRelevant();
	virtual void OnCeaseRelevant();

	/** Get an AnimNodeSequence playing a transition animation */
	UAnimNodeSequence* GetAPlayerNode();

	/** Parent node is requesting a blend out. Give node a chance to delay that. */
	virtual UBOOL	CanBlendOutFrom();

	virtual FLOAT GetSliderPosition(INT SliderIndex, INT ValueIndex);
	virtual void HandleSliderMove(INT SliderIndex, INT ValueIndex, FLOAT NewSliderValue);
	virtual FString GetSliderDrawValue(INT SliderIndex);
}

simulated native function ResetRotation();

defaultproperties
{
	TransitionBlendInTime=0.15f
	BlendType=ABT_Cubic

	Children(0)=(Name="Source",Weight=1.0)
	Children(1)=(Name="TurnTransition")

	TransitionThresholdAngle=4096.f
	RotTransitions(0)=(RotationOffset=+16384.f,TransName="Rt_90")
	RotTransitions(1)=(RotationOffset=+32768.f,TransName="Rt_180")
	RotTransitions(2)=(RotationOffset=-16384.f,TransName="Lt_90")
	RotTransitions(3)=(RotationOffset=-32768.f,TransName="Lt_180")

	CategoryDesc = "TurnInPlace"
}
