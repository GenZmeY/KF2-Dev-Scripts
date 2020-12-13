//=============================================================================
// KFSeqAct_ShowPath
//=============================================================================
// Action that creates a trail path to any actor.
//=============================================================================
// Killing Floor 2
// Copyright (C) 2016 Tripwire Interactive LLC
//=============================================================================
class KFSeqAct_SetTeleporterURLNum extends SequenceAction;

defaultproperties
{
	ObjName="Set Teleporter URL Num"
	ObjCategory="Killing Floor"
	HandlerName="OnSetURLNum"

	VariableLinks(1)=(ExpectedType=class'SeqVar_Int',LinkDesc="Value",MaxVars=1)
}