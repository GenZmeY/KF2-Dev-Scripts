//=============================================================================
// KFAnimNotify_ZedVoiceSound
//=============================================================================
// Notify class for zed voice sounds, which need to be played differently if the
// zed has no mouth/head.
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
// - Jeff Robinson
//=============================================================================
class KFAnimNotify_ZedVoiceAkEvent extends AnimNotify_AkEvent
	native(Anim);

/** Alternate event to play in the case that the zed has no mouth/head */
var() AkEvent					MouthlessAkEvent; 

/** Will cause MouthlessAkEvent to be played when the "play" button is pressed in the editor */
var() transient editoronly bool bTestMouthlessAkEvent;

/** Will attempt to play through the dialog/chatter manager, obeying dialog rules such as priority and cooldown */
var() bool						bTreatAsDialog;

cpptext
{
	// AnimNotify interface.
	virtual UAkEvent* PickEventToPlay( AActor* in_pOwner );
	virtual UBOOL CanPlay( AActor* in_pOwner, USkeletalMeshComponent* in_pSkelComp, UAkEvent* in_pEvent );
	virtual void Play( AActor* in_pOwner, UAkEvent* in_pEvent, const FVector& in_SoundLocation, UBOOL in_bEventIsOccluded );
}

defaultproperties
{
	BoneName=head
}