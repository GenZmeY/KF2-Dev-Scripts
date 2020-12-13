//=============================================================================
// KFSeqAct_SetMonsterProperties
//=============================================================================
// Settings that apply to current and/or future zeds
//=============================================================================
// Killing Floor 2
// Copyright (C) 2018 Tripwire Interactive LLC
//=============================================================================
class KFSeqAct_SetMonsterProperties extends SequenceAction;

struct SMonsterProperty
{
	/** Type of Property to be modified */
	var() EMonsterProperties Type;
	/** Whether this should effects all zeds that are spawned after this is enabled */
	var() bool bFutureZeds;
	/** Whether this should immediately affect all alive zeds when enabled */
	var() bool bCurrentZeds;
};

/** List of properties that should be modified on all zeds when this node is enabled */
var() array<SMonsterProperty> MonsterProperties;

event Activated()
{
	local bool bEnable;
	local int i;
	local KFGameInfo KFGI;
	local KFPawn_Monster KFPM;
	local WorldInfo KFWorldInfo;

	// determine whether turning on or off based on what input was called
	if (InputLinks[0].bHasImpulse)
	{
		bEnable = true;
	}
	else if (InputLinks[1].bHasImpulse)
	{
		bEnable = false;
	}
	else
	{
		// should never get hit
		return;
	}

	KFWorldInfo = class'WorldInfo'.static.GetWorldInfo();
	KFGI = KFGameInfo(KFWorldInfo.Game);
	for (i = 0; i < MonsterProperties.length; i++)
	{
		// let KFGameInfo know whether spawned zeds should automatically have this property
		if (MonsterProperties[i].bFutureZeds && KFGI != none)
		{
			KFGI.SpawnedMonsterProperties[MonsterProperties[i].Type] = int(bEnable);
		}

		// go through and apply/remove this effect for all currently existing zeds
		if (MonsterProperties[i].bCurrentZeds)
		{
			foreach KFWorldInfo.AllPawns(class'KFPawn_Monster', KFPM)
			{
				switch (MonsterProperties[i].Type)
				{
				case EMonsterProperties_Enraged: // enable/disable enrage
					KFPM.SetEnraged(bEnable);
					break;
				case EMonsterProperties_Sprinting:
					KFPM.bSprintOverride = bEnable;
					break;
				}
			}
		}
	}
}

DefaultProperties
{
	ObjCategory="Killing Floor"
	ObjName="Set Monster Properties"

	InputLinks(0)=(LinkDesc="Enable")
	InputLinks(1)=(LinkDesc="Disable")
	bCallHandler=false
}