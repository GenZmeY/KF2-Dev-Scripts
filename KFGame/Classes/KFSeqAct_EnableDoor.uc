//=============================================================================
// KFSeqAct_EnableDoor
//=============================================================================
// Enables one or more KFDoorActors, meaning they can be interacted
// with or damaged
//=============================================================================
// Killing Floor 2
//=============================================================================


class KFSeqAct_EnableDoor extends SequenceAction;

event Activated()
{
	local SeqVar_Object ObjVar;
	local KFDoorActor Door;

	if (InputLinks[0].bHasImpulse)
	{
		foreach LinkedVariables(class'SeqVar_Object',ObjVar,"KFDoorActor(s)")
		{
			Door = KFDoorActor(ObjVar.GetObjectValue());
			Door.SetInteractive(true);
		}
	}
}

defaultProperties
{
	ObjCategory="Killing Floor"
	ObjName="Enable Door"

	InputLinks(0)=(LinkDesc="Enable")
	VariableLinks(0)=(ExpectedType=class'SeqVar_Object',LinkDesc="KFDoorActor(s)",PropertyName="")
	bCallHandler=false
}