//=============================================================================
// KFSeqAct_BloodRain
//=============================================================================
// Action that activates or deactivates KFBloodRainVolumes
//=============================================================================
// Killing Floor 2
// Copyright (C) 2018 Tripwire Interactive LLC
//=============================================================================
class KFSeqAct_BloodRain extends SequenceAction;

event Activated()
{
	local WorldInfo WI;
	local SeqVar_Object ObjVar;
	local KFBloodRainVolume BRV;
	local bool bVolumesAreActive;

	WI = GetWorldInfo();

	if (WI == none || WI.NetMode == NM_DedicatedServer)
	{
		return;
	}
	
	if (InputLinks[0].bHasImpulse)
	{
		bVolumesAreActive = true;
	}
	else if (InputLinks[1].bHasImpulse)
	{
		bVolumesAreActive = false;
	}
	else
	{
		return;
	}

	if (VariableLinks[0].LinkedVariables.Length == 0)
	{
		// if we haven't specified any volumes, (de)activate them all

		foreach WI.AllActors(class'KFBloodRainVolume', BRV)
		{
			BRV.SetActive(bVolumesAreActive);
		}
	}
	else
	{
		// otherwise, (de)activate the specified volumes

		foreach LinkedVariables(class'SeqVar_Object', ObjVar, "Specific Blood Rain Volumes (if none are specified, all are used)")
		{
			BRV = KFBloodRainVolume(ObjVar.GetObjectValue());
			if (BRV != none)
			{
				BRV.SetActive(bVolumesAreActive);
			}
		}
	}
}

defaultproperties
{
	ObjCategory="Killing Floor"
	ObjName="Blood Rain"

	InputLinks(0)=(LinkDesc="Start")
	InputLinks(1)=(LinkDesc="Stop")
	VariableLinks(0)=(ExpectedType=class'SeqVar_Object',LinkDesc="Specific Blood Rain Volumes (if none are specified, all are used)",PropertyName="",MaxVars=255)
	OutputLinks.Empty
	EventLinks.Empty
}