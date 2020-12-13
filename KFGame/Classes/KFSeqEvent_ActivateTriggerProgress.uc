//=============================================================================
// KFSeqEvent_ActivateTriggerProgress
//=============================================================================
// Events telling Kismet of various progress that has occurred during
// an ActivateTrigger objective
//=============================================================================
// Killing Floor 2
// Copyright (C) 2016 Tripwire Interactive LLC
//=============================================================================
class KFSeqEvent_ActivateTriggerProgress extends KFSeqEvent_ObjectiveProgress;

enum EActivateTriggerProgressEvent
{
	EActivateTriggerProgressEvent_TriggerPulled,
	EActivateTriggerProgressEvent_TriggerReady,
	EActivateTriggerProgressEvent_ZoneEnabled,
	EActivateTriggerProgressEvent_ZoneDisabled,
	EActivateTriggerProgressEvent_MAX,
};

defaultproperties
{
	ObjName="Activate Trigger Progress"
	VariableLinks.Empty
	bPlayerOnly=false
	MaxTriggerCount=0

	OutputLinks(EActivateTriggerProgressEvent_TriggerPulled)=(LinkDesc="Trigger Pulled")
	OutputLinks(EActivateTriggerProgressEvent_TriggerReady)=(LinkDesc="Trigger Ready")
	OutputLinks(EActivateTriggerProgressEvent_ZoneEnabled)=(LinkDesc="Zone Enabled")
	OutputLinks(EActivateTriggerProgressEvent_ZoneDisabled)=(LinkDesc="Zone Disabled")

	ProgressOutputStartIndex=EActivateTriggerProgressEvent_MAX
}