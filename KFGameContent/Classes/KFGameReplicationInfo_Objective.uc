//=============================================================================
// KFGameReplicationInfo_Objective
//=============================================================================
//
//=============================================================================
// Killing Floor 2
// Copyright (C) 2018 Tripwire Interactive LLC
//=============================================================================

class KFGameReplicationInfo_Objective extends KFGameReplicationInfo;

var KFMapInfo MyKFMI;
var bool bIsBossWave;

replication
{
	if (bNetDirty)
		bIsBossWave;
};

simulated event PostBeginPlay()
{
	super.PostBeginPlay();
	MyKFMI = KFMapInfo(WorldInfo.GetMapInfo());
}

simulated function bool ShouldSetBossCamOnBossSpawn()
{
	local KFMapObjective_ExterminateWave ExterminateObj;

	ExterminateObj = KFMapObjective_ExterminateWave(CurrentObjective);
	if (ExterminateObj != none && ExterminateObj.bBossWave)
	{
		return ExterminateObj.bShowBossSpawnTheatrics;
	}

	return false;
}

simulated function bool ShouldSetBossCamOnBossDeath()
{
	return WaveNum == WaveMax;
}

simulated function bool IsObjectiveMode()
{
	return true;
}

//*****************************************************************************
//  Objectives
//*****************************************************************************

// Objective mode doesn't need to choose early
// will just start the predetermined objective in StartNextObjective below
function ChooseNextObjective(int NextWaveNum);

function bool StartNextObjective()
{
	return StartNextPresetObjective(MyKFMI);
}

function bool StartNextPresetObjective(KFMapInfo KFMI)
{
    local array<KFInterface_MapObjective> PossibleObjectives;
	local bool bUseEndlessSpawning;

	PossibleObjectives = KFMI.ObjectiveModeObjectives[WaveNum-1].PossibleObjectives;
	bUseEndlessSpawning = KFMI.ObjectiveModeObjectives[WaveNum-1].bUseEndlessSpawning;

    return SetNextObjective(PossibleObjectives, bUseEndlessSpawning, true) != INDEX_NONE;
}

function ActivateObjective(KFInterface_MapObjective NewObjective, bool bUseEndlessSpawning = false)
{
	local KFMapObjective_ExterminateWave ExterminateObj;

	bIsBossWave = false;
    if (NewObjective != none)
	{
		ExterminateObj = KFMapObjective_ExterminateWave(NewObjective);
		if (ExterminateObj != none)
		{
			bIsBossWave = ExterminateObj.bBossWave;
		}
	}

	super.ActivateObjective(NewObjective, bUseEndlessSpawning);
}

function int GetPresetObjectiveLength(KFMapInfo KFMI)
{
	return 0;
}

function bool StartNextRandomObjective(KFMapInfo KFMI)
{
    return false;
}

//*****************************************************************************
//  Waves
//*****************************************************************************

simulated function bool IsFinalWave()
{
	return false;
}

simulated function bool IsBossWave()
{
	return bIsBossWave;
}

simulated function bool IsInfiniteWave()
{
	return true;
}

simulated function bool IsBossWaveNext()
{
	return false;
}

simulated function int GetFinalWaveNum()
{
	return WaveMax;
}

//*****************************************************************************
//  Kismet
//*****************************************************************************

simulated function array<int> GetKFSeqEventLevelLoadedIndices()
{
	local array<int> ActivateIndices;

	ActivateIndices[0] = 8;

	return ActivateIndices;
}

defaultproperties
{
	bObjectiveMode=true
}