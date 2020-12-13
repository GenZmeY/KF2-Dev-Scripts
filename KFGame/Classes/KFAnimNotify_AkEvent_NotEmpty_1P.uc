//=============================================================================
// KFAnimNotify_AkEvent_NotEmpty_1P
//=============================================================================
// A situational sound notify that is skipped when the first person weapon
// is empty.  This is tied directly to the empty anim blend node rather than
// ammo count, because empty means different things for different weapons.
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
// - Jeff Robinson
//=============================================================================
class KFAnimNotify_AkEvent_NotEmpty_1P extends AnimNotify_AkEvent
	native(Anim);

cpptext
{
	virtual UBOOL CanPlay( AActor* in_pOwner, USkeletalMeshComponent* in_pSkelComp, UAkEvent* in_pEvent );

	virtual FString GetEditorComment() 
	{ 
		return TEXT("SFX");
	}
}

defaultproperties
{
	bIgnoreIfActorHidden=true
	NotifyColor=(R=200,G=200,B=255)
}