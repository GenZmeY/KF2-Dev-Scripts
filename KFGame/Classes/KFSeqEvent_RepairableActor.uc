//=============================================================================
// KFSeqEvent_RepairableActor
//=============================================================================
// Events telling Kismet of various happenings to a KFRepairableActor
//=============================================================================
// Killing Floor 2
// Copyright (C) 2016 Tripwire Interactive LLC
//=============================================================================
class KFSeqEvent_RepairableActor extends SequenceEvent;

enum ERepairableActorEvent
{
	ERepairableActorEvent_Activated,
	ERepairableActorEvent_Repaired
};

defaultproperties
{
	ObjCategory="KF"
	ObjName="Repairable Actor Events"
	VariableLinks.Empty
	bPlayerOnly=false
	MaxTriggerCount=0

	OutputLinks(ERepairableActorEvent_Activated)=(LinkDesc="Activated")
	OutputLinks(ERepairableActorEvent_Repaired)=(LinkDesc="Repaired")
}