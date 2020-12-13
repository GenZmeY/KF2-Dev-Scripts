class KFSeqAct_UnlockAchievement extends SequenceAction
	native;

var() const int AchievementID;

cpptext
{
	virtual void Activated();
}

defaultproperties
{
	ObjCategory="Killing Floor"
	ObjName="Unlock Achievement"

	InputLinks(0)=(LinkDesc="Unlock")
	OutputLinks.Empty
	VariableLinks.Empty
	EventLinks.Empty
}