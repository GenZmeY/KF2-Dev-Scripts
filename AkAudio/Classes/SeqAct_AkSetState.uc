class SeqAct_AkSetState extends SequenceAction
	native;

cpptext
{
	void Activated();
};

var() string StateGroup;
var() string State;

defaultproperties
{
	ObjName="AkSetState"
	ObjCategory="AkAudio"

	VariableLinks.Empty

	InputLinks(0)=(LinkDesc="Set")
}
