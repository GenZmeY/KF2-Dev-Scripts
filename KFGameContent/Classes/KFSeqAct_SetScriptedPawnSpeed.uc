//=============================================================================
// KFSeqAct_SetScriptedPawnSpeed
//=============================================================================
// Changes a modifier to the scripted pawn speed
//=============================================================================
// Killing Floor 2
// Copyright (C) 2019 Tripwire Interactive LLC
//=============================================================================
class KFSeqAct_SetScriptedPawnSpeed extends SequenceAction;

var() float SpeedModifier;

event Activated()
{
	local KFGameReplicationInfo KFGRI;
	local KFMapObjective_EscortPawns EscortObjective;
	local KFPawn_Scripted ScriptedPawn;

	KFGRI = KFGameReplicationInfo(GetWorldInfo().GRI);
	if (KFGRI != none && KFGRI.CurrentObjective != none)
	{
		// find the scripted pawn via the escort objective
		EscortObjective = KFMapObjective_EscortPawns(KFGRI.CurrentObjective);
		if (EscortObjective != none && EscortObjective.ActiveEscortActor != none)
		{
			ScriptedPawn = KFPawn_Scripted(EscortObjective.ActiveEscortActor);
			if (ScriptedPawn != none)
			{
				ScriptedPawn.SpeedScalarForObstacles = SpeedModifier;
				ScriptedPawn.UpdatePawnSpeed();
			}
		}
	}
}

DefaultProperties
{
	ObjCategory="Killing Floor"
	ObjName="Set Scripted Pawn Speed"
}