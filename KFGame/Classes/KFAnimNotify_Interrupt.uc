//=============================================================================
// KFAnimNotify_Interrupt
//=============================================================================
// Notify to mark when an animation can be interrupted for gameplay. Used in
// place of AnimNotify_Script when we want to get a specific time without
// having to play the anim. (see KFSkeletalMeshComponent.GetAnimNotifyTime)
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
// - Andrew "Strago" Ladenberger
//=============================================================================

class KFAnimNotify_Interrupt extends AnimNotify;

defaultproperties
{
	NotifyColor=(R=64,G=255,B=255)
}