//=============================================================================
// KFAnim_Slot
//=============================================================================
// Adds bDelayedAnimSetsUpdate
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
// - Andrew "Strago" Ladenberger
//=============================================================================

class KFAnim_Slot extends AnimNodeSlot
	deprecated
	native(Anim);

/** While playing, delay the call to AnimSetsUpdated() */
var() const bool	bDelayedAnimSetsUpdate;

/** Next time PlayCustomAnim/SelectedActiveSequence is called also call AnimSetsUpdated */
var transient bool	bPendingAnimSetsUpdate;

cpptext
{
	virtual void AnimSetsUpdated();
	virtual void SelectedActiveSequence( UAnimNodeSequence* Seq );
}

defaultproperties
{
	bDelayedAnimSetsUpdate=true
}