/**
 *
 */
class AnimNotify_AkEvent extends AnimNotify
	native(Anim);

var()	AkEvent		AkEvent;
var()	bool		bFollowActor;
var()	Name		BoneName;

`if(`__TW_WWISE_)
var()   bool        bIgnoreIfActorHidden;
/** Useful to ensure it won't activate while blending from this anim into a death anim */
var()   bool        bIgnoreIfActorDead;
/** This is the percent to play this Sound.  Defaults to 100% (aka 1.0f) **/
var()   float       PercentToPlay;
`endif

cpptext
{
	// AnimNotify interface.
	virtual void Notify( class UAnimNodeSequence* NodeSeq );

#if __TW_WWISE_
	virtual UAkEvent* PickEventToPlay( AActor* in_pOwner );
	virtual UBOOL CanPlay( AActor* in_pOwner, USkeletalMeshComponent* in_pSkelComp, UAkEvent* in_pEvent );
	virtual void GetSoundLocation( AActor* in_pOwner, USkeletalMeshComponent* in_pSkelComp, UAkEvent* in_pEvent, FVector& in_SoundLocation, INT& in_bEventIsOccluded, UBOOL& in_bEventIsAudible );
	virtual void Play( AActor* in_pOwner, UAkEvent* in_pEvent, const FVector& in_SoundLocation, UBOOL in_bEventIsOccluded );
#endif // __TW_WWISE_
}

defaultproperties
{
	bFollowActor=true

`if(`__TW_WWISE_)
    PercentToPlay=1.0
    bIgnoreIfActorDead=true
`endif
}
