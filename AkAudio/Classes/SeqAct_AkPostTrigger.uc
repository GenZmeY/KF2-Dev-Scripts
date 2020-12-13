class SeqAct_AkPostTrigger extends SequenceAction
	native;

cpptext
{
	void Activated();
};

var() string Trigger;

defaultproperties
{
	ObjName="AkPostTrigger"
	ObjCategory="AkAudio"

	InputLinks(0)=(LinkDesc="Post")
}
