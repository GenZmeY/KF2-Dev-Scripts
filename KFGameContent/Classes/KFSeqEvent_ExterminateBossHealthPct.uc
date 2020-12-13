//=============================================================================
// KFSeqEvent_ExterminateBossHealthPct
//=============================================================================
// Event telling Kismet that exterminate objective boss progress has been made
//=============================================================================
// Killing Floor 2
// Copyright (C) 2018 Tripwire Interactive LLC
//=============================================================================
class KFSeqEvent_ExterminateBossHealthPct extends KFSeqEvent_ObjectiveProgress;

defaultproperties
{
	ObjName="Exterminate Boss Health Pct"

	OutputLinkText="Boss Health Percent"
	bUseReverseProgress=true
}