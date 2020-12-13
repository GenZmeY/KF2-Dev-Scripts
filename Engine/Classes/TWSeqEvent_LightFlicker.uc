//=============================================================================
// TWSeqEvent_LightFlicker
//=============================================================================
// Custom event activated from light actor animation (LightAnim_Flicker only)
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
// - Andrew "Strago" Ladenberger
//=============================================================================

class TWSeqEvent_LightFlicker extends SequenceEvent;

defaultproperties
{
	ObjCategory="KF"
	ObjName="Light Flicker"
	bPlayerOnly=false
	bClientSideOnly=true
	ReTriggerDelay=0.2f
}
