//=============================================================================
// KFSeqEvent_LevelLoaded
//=============================================================================
// This event adds game length / type information to SeqEvent_LevelLoaded
//=============================================================================
// Killing Floor 2
// Copyright (C) 2017 Tripwire Interactive LLC
//=============================================================================
class KFSeqEvent_LevelLoaded extends SeqEvent_LevelLoaded;

var bool bWaitingForGRI;

static event int GetObjClassVersion()
{
	return Super.GetObjClassVersion() + 2;
}

event VersionUpdated(int OldVersion, int NewVersion)
{
	local int SuperVersion;
	local SeqOpOutputLink NewOutputLink;
	
	SuperVersion = Super.GetObjClassVersion();
	if (NewVersion >= SuperVersion + 1)
	{
		NewOutputLink.LinkDesc = "Loaded and Visible - Weekly";
		OutputLinks[7]=NewOutputLink;
	}
	
	if (NewVersion >= SuperVersion + 2)
	{
		NewOutputLink.LinkDesc = "Loaded and Visible - Objective";
		OutputLinks[8]=NewOutputLink;
	}
}

event RegisterEvent()
{
	local WorldInfo WI;
	local KFGameReplicationInfo KFGRI;
	local array<int> ActivateIndices;

	Super.RegisterEvent();

	WI = GetWorldInfo();
	if (WI == none)
	{
		return;
	}

	KFGRI = KFGameReplicationInfo(WI.GRI);
	if (KFGRI == none)
	{
		// We need the GRI to be able to activate the correct index (based on game length / type).
		// Remember to activate this event when we get the GRI (in GRI::PostBeginPlay).
		bWaitingForGRI = true;
		return;
	}

	ActivateIndices = KFGRI.GetKFSeqEventLevelLoadedIndices();
	if (ActivateIndices.Length == 0)
	{
		return;
	}

	CheckActivate(WI, None, false, ActivateIndices);
}

simulated function DoActivation()
{
}

defaultproperties
{
	ObjCategory="KF"
	OutputLinks(3)=(LinkDesc="Loaded and Visible - Short")
	OutputLinks(4)=(LinkDesc="Loaded and Visible - Medium")
	OutputLinks(5)=(LinkDesc="Loaded and Visible - Long")
	OutputLinks(6)=(LinkDesc="Loaded and Visible - Endless")
	OutputLinks(7)=(LinkDesc="Loaded and Visible - Weekly")
	OutputLinks(8)=(LinkDesc="Loaded and Visible - Objective")
}