//=============================================================================
// KFAnim_BlendByTargetingMode
//=============================================================================
// Chooses blend child from weapon aim/stance
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//=============================================================================

class KFAnim_BlendByTargetingMode extends AnimNodeBlendList
	native(Anim);

enum ETargetingBlendChild
{
	ETBC_Idle,
	ETBC_Aiming,
	ETBC_DownSights,
};

/** Internal cached pointer to KFPawn Owner */
var const transient	KFPawn	PawnOwner;

// OnChildAnimChange registers valid target child nodes
var() editconst bool bAllowDownSightsChild;
var() editconst bool bAllowAimingChild;

/** Custom blend in time for each child */
var() editfixedsize array<float> ChildBlendInTime;

/** Time Pawn is going to keep aiming after firing a weapon, before returning to idle/ready pose */
var() float AimTimeAfterFiring;

/** When moving the slider, keep nodes with same property in sync. */
var(Editor)	bool	bSynchronizeNodesInEditor;

cpptext
{
	virtual void InitAnim(USkeletalMeshComponent* MeshComp, UAnimNodeBlendBase* Parent);
	virtual void TickAnim(FLOAT DeltaSeconds);
	virtual void HandleSliderMove(INT SliderIndex, INT ValueIndex, FLOAT NewSliderValue);

	/** A child Anim has been modified */
	virtual void OnChildAnimChange(INT ChildNum);
};

native function SetActiveChild(INT ChildIndex, FLOAT BlendTime);

defaultproperties
{
	bSynchronizeNodesInEditor=TRUE
	AimTimeAfterFiring=2.f

	Children(0)=(Name="Idle/Default")
	Children(1)=(Name="Aim/Ready")
	Children(2)=(Name="DownSights")
	NodeName="Blend Targeting Mode"

	ChildBlendInTime(0)=0.33f
	ChildBlendInTime(1)=0.20f
	ChildBlendInTime(2)=0.20f

	bFixNumChildren=TRUE
	bForceChildFullWeightWhenBecomingRelevant=TRUE
	BlendType=ABT_EaseInOutExponent3
}
