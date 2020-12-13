//=============================================================================
// KFSeqEvent_CollectTrigger
//=============================================================================
// Events telling Kismet of various progress that has occurred during
// an ActivateTrigger objective
//=============================================================================
// Killing Floor 2
// Copyright (C) 2016 Tripwire Interactive LLC
//=============================================================================
class KFSeqEvent_CollectTrigger extends SequenceEvent;

enum ECollectTriggerEvent
{
	ECollectTriggerEvent_Activated,
	ECollectTriggerEvent_ObjectDropped,
	ECollectTriggerEvent_ObjectPickedUp,
	ECollectTriggerEvent_ObjectDelivered
};

defaultproperties
{
	ObjCategory="KF"
	ObjName="Collect Trigger Event"
	VariableLinks.Empty
	bPlayerOnly=false
	MaxTriggerCount=0

	OutputLinks(ECollectTriggerEvent_Activated)=(LinkDesc="Activated")
	OutputLinks(ECollectTriggerEvent_ObjectDropped)=(LinkDesc="Object Dropped")
	OutputLinks(ECollectTriggerEvent_ObjectPickedUp)=(LinkDesc = "Object Picked Up")
	OutputLinks(ECollectTriggerEvent_ObjectDelivered)=(LinkDesc = "Object Delivered")
}