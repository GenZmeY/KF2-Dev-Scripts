//=============================================================================
// KFGameReplicationInfo_WeeklySurvival
//=============================================================================
//
//=============================================================================
// Killing Floor 2
// Copyright (C) 2019 Tripwire Interactive LLC
//=============================================================================

class KFGameReplicationInfo_WeeklySurvival extends KFGameReplicationInfo;

simulated function array<int> GetKFSeqEventLevelLoadedIndices()
{
	local array<int> ActivateIndices;

	ActivateIndices[0] = 7;

	return ActivateIndices;
}