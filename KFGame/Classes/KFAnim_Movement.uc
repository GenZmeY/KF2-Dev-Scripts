//=============================================================================
// KFAnim_MovementNode
//=============================================================================
// Anim Node used to determine movement state
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
// - Andrew "Strago" Ladenberger
//=============================================================================

class KFAnim_Movement extends AnimNodeBlendBySpeed
	native(Anim);

/** Scale Animations Play Rate using Constraints as base speed */
var() bool	bScaleAnimPlayRateBySpeed;
/** Position of the movement cycle when starting to move */
var() float	MoveCycleFirstStepStartPosition;

/** Synchronization node info. To access normalized movement info */
var	  const transient AnimTree	RootNode;
var() Name						SynchGroupName;

/** When moving the slider, keep nodes with same property in sync. */
var() bool	bSynchronizeNodesInEditor;

/** If set, calculate speed from owner's base instead of owner */
var() bool  bUseOwnersBase;

/** If set, ignore z-axis velocity/acceleration */
var() bool  bUse2DMovement;

cpptext
{
	/** for MoveCycleFirstStepStartPosition */
	virtual void InitAnim(USkeletalMeshComponent* meshComp, UAnimNodeBlendBase* Parent);

	/** for bScaleAnimPlayRateBySpeed */
	virtual	void TickAnim(FLOAT DeltaSeconds);

	/** for bSynchronizeNodesInEditor */
	virtual void HandleSliderMove(INT SliderIndex, INT ValueIndex, FLOAT NewSliderValue);

	/** for bUseOwnersBase */
	virtual FLOAT CalcSpeed();
}

/** for MoveCycleFirstStepStartPosition */
native function SetActiveChild( INT ChildIndex, FLOAT BlendTime );

defaultproperties
{	
	//bFixNumChildren=TRUE

	Children(0)=(Name="Idle")
	Children(1)=(Name="Walk")
	Children(2)=(Name="Run")

	bScaleAnimPlayRateBySpeed=FALSE
	bSynchronizeNodesInEditor=TRUE
	bUse2DMovement=TRUE

	BlendUpTime=0.3f
    BlendDownTime=0.3f
	MoveCycleFirstStepStartPosition=0.3f

	SynchGroupName="RunWalk"

	Constraints=(0,300,500);
}
	