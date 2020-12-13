//=============================================================================
// KFSeqAct_FlickerLightning
//=============================================================================
// Action that starts animation on KFDominantDirectionalLightning
//=============================================================================
// Killing Floor 2
// Copyright (C) 2018 Tripwire Interactive LLC
//=============================================================================
class KFSeqAct_FlickerLightning extends SequenceAction;

event Activated()
{
	local SeqVar_Object ObjVar;
	local KFDominantDirectionalLightning Lightning;
	
	if (InputLinks[0].bHasImpulse)
	{
		// Grab our trader
		foreach LinkedVariables(class'SeqVar_Object', ObjVar, "KF Dominant Directional Lightning")
		{
			Lightning = KFDominantDirectionalLightning(ObjVar.GetObjectValue());
			break;
		}

		// Sanity
		if (Lightning == none)
		{
			return;
		}

		Lightning.TriggerAnimation();
	}
}

DefaultProperties
{
	ObjCategory="Killing Floor"
	ObjName="Flicker Lightning"

	InputLinks(0)=(LinkDesc="Start")
	VariableLinks(0)=(ExpectedType=class'SeqVar_Object',LinkDesc="KF Dominant Directional Lightning",PropertyName="",MaxVars=1)
	bCallHandler=false
}