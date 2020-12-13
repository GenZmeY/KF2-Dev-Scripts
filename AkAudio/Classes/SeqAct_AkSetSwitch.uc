class SeqAct_AkSetSwitch extends SequenceAction
	native;

cpptext
{
	void Activated();
};

var() string SwitchGroup;
var() string Switch;

defaultproperties
{
	ObjName="AkSetSwitch"
	ObjCategory="AkAudio"

	InputLinks(0)=(LinkDesc="Set")
}
