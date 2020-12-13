/**
 * Copyright 1998-2011 Epic Games, Inc. All Rights Reserved.
 *
 * Handles dynamic scaling for the Gears 2 flamethrower.
 */
class KFSkelControl_SprayScaling extends SkelControlBase
	native(Anim);

struct native SprayScaleInParams
{
	/** Will scale from ScaleRange.X to ScaleRange.Y over this time range. */
	var() vector2d ScaleInTimeRange;
	/** */
	var() vector2d ScaleRange;
	/** Exponent used to control the mapping curve. */
	var() float Pow;

	structdefaultproperties
	{
		Pow=1.f
	}
};

/** Information to describe how a bone scales with velocity. */
struct native SprayVelocityScaleParams
{
	/** Range of velocities that is mapped to ScaleRange */
	var() vector2d	VelocityRange;
	/** Range of scales that is mapped to VelocityRange. */
	var() vector2d	ScaleRange;
	/** Exponent used to control the mapping curve. */
	var() float Pow;

	structdefaultproperties
	{
		Pow=1.f
	}
};

struct native SprayBoneScaleParams
{
	/** which bone we're setting params for. */
	var() name						BoneName;
	var float						CachedBoneIndex;

	var() bool						bScaleIn;
	var() SprayScaleInParams		ScaleInParams;

	var() bool						bScaleWithVelocity;
	var() SprayVelocityScaleParams	VelocityScaleParams;
};

// transient properties
var() transient float	CurrentAge;
var() transient float	CurrentVel;
var transient float		LastVel;

/** Velocity is smoothed over time.  This controls how tightly it adheres to the actual velocity. */
var() protected float VelocitySmoothingInterpSpeed;

var() protected array<SprayBoneScaleParams>	ScaleParams;

cpptext
{
public:
	// USkelControlBase interface
	virtual void TickSkelControl(FLOAT DeltaSeconds, USkeletalMeshComponent* SkelComp);
	virtual void GetAffectedBones(INT BoneIndex, USkeletalMeshComponent* SkelComp, TArray<INT>& OutBoneIndices);
	virtual void CalculateNewBoneScales(INT BoneIndex, USkeletalMeshComponent* SkelComp, TArray<FLOAT>& OutBoneScales);
}

simulated function ResetTransients()
{
	CurrentAge = 0.f;
	CurrentVel = 0.f;
	LastVel = 0.f;
}

defaultproperties
{
	VelocitySmoothingInterpSpeed=8.f
}
