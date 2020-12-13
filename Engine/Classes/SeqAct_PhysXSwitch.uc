// NVCHANGE_BEGIN_RS: Kismet PhysX switch
class SeqAct_PhysXSwitch extends SequenceAction
	native(Sequence);

cpptext
{
	void Activated()
	{
		if( !InputLinks(0).bHasImpulse )
		{
			return;
		}

		INT PhysXLevel = GEngine->GetPhysXLevel();
		for( INT i = 0; i < 3; ++i )
		{
			if( PhysXLevel == i )
			{
				if( !OutputLinks(i).bDisabled && !(OutputLinks(i).bDisabledPIE && GIsEditor) )
				{
					OutputLinks(i).bHasImpulse = TRUE;
				}
			}
		}
	}
}

defaultproperties
{
	ObjName="PhysX Switch"

	ObjCategory="Physics"

	bAutoActivateOutputLinks=false

	InputLinks(0)=(LinkDesc="In")
	OutputLinks(0)=(LinkDesc="PhysXLevel 0")
	OutputLinks(1)=(LinkDesc="PhysXLevel 1")
	OutputLinks(2)=(LinkDesc="PhysXLevel 2")

	VariableLinks.Empty
}
// NVCHANGE_END_RS: Kismet PhysX switch
