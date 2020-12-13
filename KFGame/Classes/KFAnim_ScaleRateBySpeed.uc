//=============================================================================
// KFAnim_ScaleRateBySpeed
//=============================================================================
// Adds the ability set per owner class and to preview in the AnimTree
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
// - Andrew "Strago" Ladenberger
//=============================================================================

class KFAnim_ScaleRateBySpeed extends AnimNodeScaleRateBySpeed
	native(Anim);

struct native KFScaleRateInfo
{
	/** Owner class name (to avoid obj ref) */
	var() Name OwnerClassName;
	/** New base speed */
	var() float BaseSpeed;

	structdefaultproperties
	{
		BaseSpeed=350
	}
};

/** If owner matches pawn entry, then override BaseSpeed */
var(AnimNodeScaleRateBySpeed) Array<KFScaleRateInfo> PawnList;

/** Use base's velocity instead.  Useful for weapon anim trees */
var() bool bUseBaseVelocity;

cpptext
{
	virtual void	InitAnim(USkeletalMeshComponent* MeshComp, UAnimNodeBlendBase* Parent);
	virtual FLOAT	GetScaleValue();
}

defaultproperties
{
}