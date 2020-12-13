//=============================================================================
// KFSeqEvent_HoldZoneProgress
//=============================================================================
// Event telling Kismet that hold zone objective progress has been made
//=============================================================================
// Killing Floor 2
// Copyright (C) 2018 Tripwire Interactive LLC
//=============================================================================
class KFSeqEvent_HoldZoneProgress extends KFSeqEvent_ObjectiveProgress;

enum EHoldZoneProgressEvent
{
	EHoldZoneProgressEvent_ZoneDisabled,
	EHoldZoneProgressEvent_ZoneEnabled
};

defaultproperties
{
	ObjName="Hold Zone Progress"

	OutputLinks(EHoldZoneProgressEvent_ZoneDisabled)=(LinkDesc="Zone Disabled")
	OutputLinks(EHoldZoneProgressEvent_ZoneEnabled)=(LinkDesc="Zone Enabled")
	ProgressOutputStartIndex=EHoldZoneProgressEvent_MAX

	OutputLinkText="Progress Pct"
}