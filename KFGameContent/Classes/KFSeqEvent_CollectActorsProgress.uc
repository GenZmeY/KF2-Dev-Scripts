//=============================================================================
// KFSeqEvent_CollectActorsProgress
//=============================================================================
// Event telling Kismet that collect actor objective progress has been made
//=============================================================================
// Killing Floor 2
// Copyright (C) 2018 Tripwire Interactive LLC
//=============================================================================
class KFSeqEvent_CollectActorsProgress extends KFSeqEvent_ObjectiveProgress;

defaultproperties
{
	ObjName="Collect Actors Progress"

	OutputLinkText="Total Collection %"
}