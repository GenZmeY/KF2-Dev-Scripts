//=============================================================================
// KFSeqEvent_EscortPawnsCompletionPct
//=============================================================================
// Event telling Kismet that escort objective progress has been made
//=============================================================================
// Killing Floor 2
// Copyright (C) 2018 Tripwire Interactive LLC
//=============================================================================
class KFSeqEvent_EscortPawnsCompletionPct extends KFSeqEvent_ObjectiveProgress;

defaultproperties
{
	ObjName="Escort Completion Pct"

	OutputLinkText="Completion Percent"
}