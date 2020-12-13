//=============================================================================
// KFAnimNotify_HideBone
//=============================================================================
// Hide/Unhide a given bone
// NOTE: Notifies are not always triggered (e.g. interrupted anim), so be
//		 careful when toggling things on/off within an animation
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
// - Andrew "Strago" Ladenberger
//=============================================================================

class KFAnimNotify_HideBone extends AnimNotify
	native(Anim);

/** Bone to spawn this actor on */
var() name BoneName;
/** If set, unhide instead of hide */
var() bool bUnhideBone;

cpptext
{
	// AnimNotify interface.
	virtual void Notify( class UAnimNodeSequence* NodeSeq );
}

defaultproperties
{
	NotifyColor=(R=255,G=0,B=255)
	BoneName=RW_Magazine1
}