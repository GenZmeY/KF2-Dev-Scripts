/**
 * Copyright 1998-2013 Epic Games, Inc. All Rights Reserved.
 */
class AnimNotify_Footstep extends AnimNotify
	native(Anim);

`if(`__TW_)
/** 0 = left foot, 1 = right foot, 2 = left hand, 3 = right hand */
`else
/** 0=left 1=right */
`endif
var() int FootDown;

cpptext
{
	// AnimNotify interface.
	virtual void Notify( class UAnimNodeSequence* NodeSeq );
#if __TW_
    virtual FString GetEditorComment() { switch(FootDown){ case 0: return TEXT("Left Footstep"); case 1: return TEXT("Right Footstep"); case 2: return TEXT("Left Handstep"); case 3: return TEXT("Right Handstep"); default: return TEXT("");}; }
#else
	virtual FString GetEditorComment() { return (FootDown == 0) ? TEXT("Left Footstep") : TEXT("Right Footstep"); }
#endif // __TW_
}

defaultproperties
{
	 FootDown=0
}
