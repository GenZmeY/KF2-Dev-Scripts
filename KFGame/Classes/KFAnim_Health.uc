//=============================================================================
// KFAnim_Health
//=============================================================================
// Anim Node used to determine state based on health
//=============================================================================
// Killing Floor 2
// Copyright (C) 2019 Tripwire Interactive LLC
//=============================================================================

class KFAnim_Health extends AnimNodeBlendList
	native(Anim);

/** Current percent health of the actor */
var float HealthPct;

/** List of Health Pcts to switch between channels*/
var() array<float>	Constraints;

/** If set, calculate speed from owner's base instead of owner */
var() bool  bUseOwnersBase;

/** The last selected child index */
var int LastChannel;

/** Amount of time to blend between these anims */
var() float BlendTime;

cpptext
{
	virtual	void TickAnim(FLOAT DeltaSeconds);
	virtual void HandleSliderMove(INT SliderIndex, INT ValueIndex, FLOAT NewSliderValue);
	virtual float GetSliderPosition(INT SliderIndex, INT ValueIndex);
	virtual FString GetSliderDrawValue(INT SliderIndex);
}

defaultproperties
{
	Children(0)=(Name="Broken")
	Children(1)=(Name="Damaged")
	Children(2)=(Name="Normal")

	bSkipBlendWhenNotRendered=true
	bFixNumChildren=true
	bPlayActiveChild=true
	Constraints=(0.01f,0.5f,1.0f)
	LastChannel=-1
	BlendTime=0.3f
}
	