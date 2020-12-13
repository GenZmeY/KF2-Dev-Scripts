//=============================================================================
// KFSeqAct_StartObjectiveWave
//=============================================================================
// Action that starts the next wave if on an Objective map
//=============================================================================
// Killing Floor 2
// Copyright (C) 2018 Tripwire Interactive LLC
//=============================================================================
class KFSeqAct_StartObjectiveWave extends SequenceAction;

event Activated()
{
	local KFGameInfo_Objective KFGI;

	KFGI = KFGameInfo_Objective(class'WorldInfo'.static.GetWorldInfo().Game);
	if (KFGI != none)
	{
		KFGI.SeqActStartWave();
	}
}

DefaultProperties
{
	bCallHandler=false
	ObjCategory="Killing Floor"
	ObjName="Start Objective Wave"
}