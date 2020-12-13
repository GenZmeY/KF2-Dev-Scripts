//=============================================================================
// KFSeqAct_SetPathnodeExtraCost
//=============================================================================
// Action that will set Extra Cost for the path node. Used to bypass ModifyProperty.
//=============================================================================
// Killing Floor 2
// Copyright (C) 2018 Tripwire Interactive LLC
//=============================================================================
class KFSeqAct_SetPathnodeExtraCost extends SequenceAction;

var() int ExtraCost;

event Activated()
{
	local Object ObjVar;
	local NavigationPoint NavPoint;

	foreach Targets(ObjVar)
	{
		NavPoint = NavigationPoint(ObjVar);
		if (NavPoint != none)
		{
			NavPoint.ExtraCost = ExtraCost;
		}
	}
}

defaultproperties
{
	ObjCategory="Killing Floor"
	ObjName="Modify Extra Cost for Pathnode(s)"

	bCallHandler=FALSE
}
