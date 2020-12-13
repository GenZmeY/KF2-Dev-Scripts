//=============================================================================
// KFSeqEvent_MapObjectiveActivated
//=============================================================================
// Called when a map objective is activated or deactivated.
//=============================================================================
// Killing Floor 2
// Copyright (C) 2018 Tripwire Interactive LLC
//=============================================================================
class KFSeqEvent_MapObjectiveActivated extends SequenceEvent;

function NotifyActivation(Actor InInstigator, Actor InMapObjective)
{
	local array<int> ActiveIndices;

	ActiveIndices[0] = 0;
	CheckActivate(InInstigator, InMapObjective, false, ActiveIndices);
}

function NotifyDeactivation(Actor InInstigator, Actor InMapObjective)
{
	local array<int> ActiveIndices;

	ActiveIndices[0] = 1;
	CheckActivate(InInstigator, InMapObjective, false, ActiveIndices);
}

defaultproperties
{
	ObjName="Map Objective Activated"

	OutputLinks.Empty()
	OutputLinks(0)=(LinkDesc="Activated")
	OutputLinks(1)=(LinkDesc="Deactivated")

	bPlayerOnly=false
	MaxTriggerCount=0
}
