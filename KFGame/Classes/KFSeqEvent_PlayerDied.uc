//=============================================================================
// KFSeqEvent_PlayerDied
//=============================================================================
// Event telling Kismet a playercontroller controlled pawn died
//=============================================================================
// Killing Floor 2
// Copyright (C) 2018 Tripwire Interactive LLC
//=============================================================================
class KFSeqEvent_PlayerDied extends SequenceEvent;

DefaultProperties
{
	ObjName="Player Died"
	ObjCategory="KF"
	VariableLinks.Empty
	bPlayerOnly=false
	MaxTriggerCount=0
	InputLinks.Empty
	VariableLinks.Empty
	OutputLinks(0)=(LinkDesc="Player Died")
	OutputLinks(1)=(LinkDesc="Last Player Died")
}