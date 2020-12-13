//=============================================================================
// KFGFxPerksContainer_Selection
//=============================================================================
// Class Description
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//  - Zane Gholson 9/16/2015
//=============================================================================

class KFGFxGearContainer_PerksSelection extends KFGFxObject_Container;

struct PerkData
{
	var string PerkTitle;
 	var int PerkLevel;
 	var int PerkPercent;
};

var array<PerkData> PerksData;

function Initialize( KFGFxObject_Menu NewParentMenu )
{
	local KFPlayerController KFPC;

	KFPC = KFPlayerController(GetPC());

	super.Initialize( NewParentMenu );
	LocalizeText();
	if(KFPC != none)
	{
		UpdatePerkSelection( 0 );
	}
}

function LocalizeText()
{
	local GFxObject LocalizedObject;

	LocalizedObject = CreateObject( "Object" );
	
	LocalizedObject.SetString("back", 					Class'KFCommon_LocalizedStrings'.default.BackString); 

	SetObject("localizedText", LocalizedObject);
}

function UpdatePerkSelection(byte SelectedPerkIndex)
{
 	local int i;
	local GFxObject DataProvider;
	local GFxObject TempObj;
	local KFPlayerController KFPC;
	local class<KFPerk> PerkClass;	
	local byte bTierUnlocked;
	local int UnlockedPerkLevel;

	KFPC = KFPlayerController( GetPC() );

	if ( KFPC != none )
	{
	   	DataProvider = CreateArray();

		for (i = 0; i < KFPC.PerkList.Length; i++)
		{
			PerkClass = KFPC.PerkList[i].PerkClass;
			class'KFPerk'.static.LoadTierUnlockFromConfig(PerkClass, bTierUnlocked, UnlockedPerkLevel);
		    TempObj = CreateObject( "Object" );
		    TempObj.SetInt( "PerkLevel", KFPC.PerkList[i].PerkLevel );
			TempObj.SetInt("prestigeLevel", KFPC.PerkList[i].PrestigeLevel);
		    TempObj.SetString( "Title",  PerkClass.default.PerkName );	
			TempObj.SetString( "iconSource",  "img://"$PerkClass.static.GetPerkIconPath() );
			TempObj.SetBool("bTierUnlocked", bool(bTierUnlocked) && KFPC.PerkList[i].PerkLevel >= UnlockedPerkLevel);
			

		    DataProvider.SetElementObject( i, TempObj );
		}	
		SetObject( "perkData", DataProvider );
		SetInt("SelectedIndex", SelectedPerkIndex);
    }
}