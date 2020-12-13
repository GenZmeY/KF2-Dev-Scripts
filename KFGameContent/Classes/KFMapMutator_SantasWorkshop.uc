//=============================================================================
// KFMapMutator_SantasWorkshop
//=============================================================================
// Contains mutator code for Santa's Workshop
//=============================================================================
// Killing Floor 2
// Copyright (C) 2018 Tripwire Interactive LLC
//=============================================================================

class KFMapMutator_SantasWorkshop extends KFMapMutator;

var float EndlessWaveDoshScalar;

static simulated function ModifyGameClassBossAIClassList(out array< class<KFPawn_Monster> > GameClassBossAIClassList)
{
	local int i;

	if (class'WorldInfo'.static.GetWorldInfo().GRI.GameClass == class'KFGameInfo_Survival')
	{
		for (i = 0; i < GameClassBossAIClassList.Length; ++i)
		{
			if (GameClassBossAIClassList[i] == class'KFPawn_ZedBloatKing')
			{
				GameClassBossAIClassList[i] = class'KFPawn_ZedBloatKing_SantasWorkshop';
			}
		}
	}
}

static simulated function ModifyAIDoshValue(out float AIDoshValue)
{
	local KFGameReplicationInfo KFGRI;

	KFGRI = KFGameReplicationInfo(class'WorldInfo'.static.GetWorldInfo().GRI);
	if (KFGRI.GameClass == class'KFGameInfo_Survival')
	{
		if (KFGRI.bWaveIsEndless)
		{
			AIDoshValue *= default.EndlessWaveDoshScalar;
		}
	}
}

defaultproperties
{
	EndlessWaveDoshScalar=0.5
}