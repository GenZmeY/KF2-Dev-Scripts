//=============================================================================
// KFSeqEvent_EscortPawnsHealthPct
//=============================================================================
// Event telling Kismet that escort objective health progress has been made
//=============================================================================
// Killing Floor 2
// Copyright (C) 2018 Tripwire Interactive LLC
//=============================================================================
class KFSeqEvent_EscortPawnsHealthPct extends KFSeqEvent_ObjectiveProgress;

defaultproperties
{
	ObjName="Escort Health Pct"

	OutputLinkText="Health Percent"
	bUseReverseProgress=true
}