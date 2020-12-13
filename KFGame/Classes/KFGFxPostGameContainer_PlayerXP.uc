//=============================================================================
// KFGFxPostGameContainer_PlayerXP
//=============================================================================
// Class Description
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//  - Zane Gholson 07/10/2015
//=============================================================================

class KFGFxPostGameContainer_PlayerXP extends KFGFxObject_Container;

var int ItemCount;

//==============================================================
// Initialization
//==============================================================
function Initialize( KFGFxObject_Menu NewParentMenu )
{
	super.Initialize( NewParentMenu );
	SetXPList();
}

function SetXPList()
{
	local GFxObject ObjectArray;
	local KFPlayerReplicationInfo KFPRI;
	local KFPlayerController KFPC;
	local int i;
	local EphemeralMatchStats StatCollector;

	ItemCount = 0;

	KFPRI = KFPlayerReplicationInfo(GetPC().PlayerReplicationInfo);

	KFPC = KFPlayerController(GetPC());

	if(KFPRI != none && KFPC != none)
	{
		StatCollector = KFPC.MatchStats;

		ObjectArray = CreateArray();

		StatCollector.PerkXPList.Sort(StatCollector.SortXP);
		//Temp XP Print out on AAR player stats
		for (i = 0; i < StatCollector.PerkXPList.length; i++)
		{
			// Only show perks with progress this match
			if ( StatCollector.PerkXPList[i].XPDelta > 0 )
			{
				ObjectArray.SetElementObject(ItemCount, MakePerkXPObject(StatCollector.PerkXPList[i]));
			}
		}
	}

	SetObject("xpList", ObjectArray);
}

function GFxObject MakePerkXPObject(PerkXPGain PerkXPObject)
{
	local GFxObject TempGFxObject;
	local KFPlayerController KFPC; 
	local float BonusXPMultiplier;
	

	KFPC = KFPlayerController(GetPC());
	TempGFxObject = CreateObject("Object");

	BonusXPMultiplier = KFPC.GetPerkPrestigeXPMultiplier(PerkXPObject.PerkClass);

	TempGFxObject.SetInt("bonusXP", PerkXPObject.BonusXP); 
	TempGFxObject.SetString("bonusXPMultiplier", int(BonusXPMultiplier * 100) $"%" @class'KFCommon_LocalizedStrings'.default.PrestigeBonusString );
	TempGFxObject.SetFloat("startXP", 		PerkXPObject.StartXPPercentage);	
	TempGFxObject.SetFloat("finishXP", 		Min(KFPC.GetPerkLevelProgressPercentage(PerkXPObject.PerkClass), 100 ));	
	TempGFxObject.SetFloat("xpDelta", 		PerkXPObject.XPDelta);	
	TempGFxObject.SetInt("perkLevel", 		PerkXPObject.StartLevel);	
	TempGFxObject.SetInt("finishLevel", 	KFPC.GetPerkLevelFromPerkList(PerkXPObject.PerkClass));	
	TempGFxObject.SetString("perkName", 	PerkXPObject.PerkClass.default.PerkName);	
	TempGFxObject.SetString("perkIcon",		"img://" $PerkXPObject.PerkClass.static.GetPerkIconPath());
	TempGFxObject.SetString("objective1", 	PerkXPObject.PerkClass.default.EXPAction1);
	TempGFxObject.SetInt("objective1Value", PerkXPObject.XPDelta - PerkXPObject.SecondaryXPGain - PerkXPObject.BonusXP);
	TempGFxObject.SetString("objective2", 	PerkXPObject.PerkClass.default.EXPAction2);
	TempGFxObject.SetInt("objective2Value", PerkXPObject.SecondaryXPGain );

	ItemCount++;

	return TempGFxObject;
}

DefaultProperties
{
	ItemCount=-1
}