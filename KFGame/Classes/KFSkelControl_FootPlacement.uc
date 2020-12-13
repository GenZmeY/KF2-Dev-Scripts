//=============================================================================
// KFSkelControl_FootPlacement
//=============================================================================
// Based SkelControlFootPlacement, but with a few improvements (see vars)
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
// -- Andrew "Strago" Ladenberger
//=============================================================================

class KFSkelControl_FootPlacement extends SkelControlFootPlacement
	native(Anim);

/** Project foot onto floor.  Avoids breaking the animation and allows for IK during walk */
var(KFFootPlacement) bool	bProjectOntoPlane;

/** Interpolation speed when IK adjusted changes */
var(KFFootPlacement) float	InterpUpSpeed, InterpDownSpeed;

/** Floor Normal, to do the traces for the feet. */
var(KFFootPlacement) Vector	FloorNormal;

/** When LegAdjust is small ignore IK.  Ideally, this should always trigger on flat surfaces */
var(Performance) float MinAdjustment;
/** If leg adjust from last frame is small, apply skip rate for traces */
var(Performance) float MaxLegAdjustForSkipRate;

/** <2 means no skip, 2 means every other frame, 3 means 1 out of three frames, etc  */
var const transient int SkipRateForLineTrace;
/** How many times this component was ticked. */
var const transient int	UpdateTransformsCount;
/** Most recent hit normal */
var const transient vector HitNormal;

/** Target Effector Location to interpolate to smoothly */
var	const transient float LegAdjust, LegAdjustInterp;

/** Internal cached pointer to Owner */
var	const transient KFPawn PawnOwner;

// debug
var transient editoronly vector DebugStartLoc, DebugEndLoc, DebugIKLoc;

cpptext
{
	// USkelControlBase interface
	virtual void TickSkelControl(FLOAT DeltaSeconds, USkeletalMeshComponent* SkelComp);
	virtual void CalculateNewBoneTransforms(INT BoneIndex, USkeletalMeshComponent* SkelComp, TArray<FBoneAtom>& OutBoneTransforms);
	virtual void DrawSkelControl3D(const FSceneView* View, FPrimitiveDrawInterface* PDI, USkeletalMeshComponent* SkelComp, INT BoneIndex);

	virtual UBOOL LegLineCheckFast(const FVector& Start, const FVector& End, FVector& HitLocation, FVector& HitNormal, AActor* SourceActor);
}

defaultproperties
{
	bProjectOntoPlane=true
	InterpUpSpeed=128.f
	InterpDownSpeed=128.f
	FloorNormal=(Z=1.f)

	EffectorLocationSpace=BCS_WorldSpace
	JointTargetLocationSpace=BCS_ParentBoneSpace
	JointAxis=AXIS_X

	MaxDownAdjustment=60.0

	// Lift the foot off the ground a bit (<= MAXFLOORDIST) to reduce clipping.
	// If set properly, UpdateFloorConform will choose not to pull down the mesh on even floor.
	//	aka: the LegAdjust will be ~= 0 (erroring on neg)
	FootOffset=1.9f

	// performance
	MinAdjustment=1.8f
	MaxLegAdjustForSkipRate=100.f
	SkipRateForLineTrace=2

	// This is the value that GOW3 uses for its stretch limits
	StretchLimits=(X=0.95f,Y=1.33f)
}
