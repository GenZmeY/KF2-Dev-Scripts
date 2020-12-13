//=============================================================================
// KFAnimSeq_ByWeaponClass
//=============================================================================
// AnimNodeSequence which chooses an animation based on the equipped weapon
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
// - Andrew "Strago" Ladenberger
//=============================================================================
// Based on GearAnim_SequenceByWeaponClass 
// Copyright 1998-2011 Epic Games, Inc. All Rights Reserved.
//=============================================================================

class KFAnimSeq_ByWeaponClass extends AnimNodeSequence
	deprecated
	native(Anim);

struct native WeaponClassNameInfo
{
	/** Weapon class */
	var() Class<KFWeapon> WeaponClass<AllowAbstract>;
	/** Animation to use */
	var() Name AnimName;
};

/** List of weapons, class and animation name.*/
var() Array<WeaponClassNameInfo> WeaponList;

/** Default, when no match can be made, or weapon is holstered */
var() Name  WeaponDefaultAnimName;

/** When moving the slider, keep nodes with same property in sync. */
var() bool	bSynchronizeNodesInEditor;

/** Slider position for weapon list */
var editoronly const FLOAT WeaponListSliderPosition;

/** Internal cached pointer to GearPawn Owner */
var const	transient	Pawn		PawnOwner;
/** Internal cached pointer to owner's weapon */
var const	transient	Weapon		CurrentWeapon;
/** Cached bool to track holstering changes */
var const   transient   bool        bTemporaryHolster;

cpptext
{
	virtual void InitAnim(USkeletalMeshComponent* MeshComp, UAnimNodeBlendBase* Parent);
	virtual void TickAnim(FLOAT DeltaSeconds);
	/**
	 * @return	TRUE if this object is of the specified type.
	 * If SomeBase is a parent class of CheckClass, then Depth will tell how many generations between both.
	 */
	UBOOL IsA_AndDepth(UClass* CheckClass, const UClass* SomeBase, INT& Depth) const;

	/** Looks at current weapon, and default classes, and makes a suggestion on Channel to use. */
	INT SuggestTargetChannelForClass(UClass* CheckClass) const;

	/** 
	 * Utility function to update animation to use based on weapon carried.
	 * Optimized version that updates the animation only when the node is relevant in the tree,
	 * and otherwise will defer the update until the node comes into relevancy.
	 */
	void SetWeaponAnim(FName NewAnimName);

	// AnimTree editor interface
	virtual INT GetNumSliders() const { return bShowTimeLineSlider ? 2 : 1; }
	virtual FLOAT GetSliderPosition(INT SliderIndex, INT ValueIndex);
	virtual void HandleSliderMove(INT SliderIndex, INT ValueIndex, FLOAT NewSliderValue);
	virtual FString GetSliderDrawValue(INT SliderIndex);
};

defaultproperties
{
	bSynchronizeNodesInEditor=TRUE
}
