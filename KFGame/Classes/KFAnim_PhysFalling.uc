//=============================================================================
// KFAnim_PhysFalling
//=============================================================================
// AnimNodeBlendList for Jump/Fall/Land animations
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
// - Andrew "Strago" Ladenberger
//=============================================================================

class KFAnim_PhysFalling extends AnimNodeBlendList
	native(Anim);

enum EJumpBlendChild
{
	EJBC_Walk,
	EJBC_Jump,
	EJBC_Fall,
	EJBC_Land
};

/** Custom blend in time for each child */
var() editfixedsize array<float> ChildBlendInTime;

/** If > 0, then always play the land anim (move/slide) for a short time */
var() float MinLandPlayTime;

/** Set when fall is started.  If time passed is small don't play land */
var transient float SkipLandTimeLeft;

/** Set by InitAnimTree if land child is valid */
var transient AnimNodeSequence LandNodeSeq;

cpptext
{
	virtual void InitAnim(USkeletalMeshComponent* MeshComp, UAnimNodeBlendBase* Parent);
	virtual	void TickAnim(FLOAT DeltaSeconds);
	virtual void OnChildAnimEnd(UAnimNodeSequence* Child, FLOAT PlayedTime, FLOAT ExcessTime);
}

defaultproperties
{
	bFixNumChildren=true
	bPlayActiveChild=true
	bSkipBlendWhenNotRendered=TRUE
	// Need to disable this (particularly for PHYS_Falling) to avoid a .33s 
	// blend back to walk whenever we get an 'instant' walk->fall->walk loop
	bForceChildFullWeightWhenBecomingRelevant=FALSE

	Children(0)=(Name="Walking")
	Children(1)=(Name="Jump Up")
	Children(2)=(Name="Falling")
	Children(3)=(Name="Land")

	ChildBlendInTime(0)=0.33f
	ChildBlendInTime(1)=0.33f
	ChildBlendInTime(2)=0.33f
	ChildBlendInTime(3)=0.1f
	MinLandPlayTime=0.0f
}
	