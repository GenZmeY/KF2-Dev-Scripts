//=============================================================================
// KFGFxTraderContainer_PlayerInfo
//=============================================================================
// HOlds dosh and perk info
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//  - Greg Felber 8/12/2013
//=============================================================================

class KFGFxTraderContainer_PlayerInfo extends KFGFxObject_Container;

var localized string PlayerHeaderString;
var localized string SelectPerkString;

function Initialize( KFGFxObject_Menu NewParentMenu )
{
	super.Initialize( NewParentMenu );
	LocalizeText();
	UpdatePlayerInfo();
}

function LocalizeText()
{
	local GFxObject LocalizedObject;

	LocalizedObject = CreateObject("Object");

	LocalizedObject.SetString("PlayerHeader", PlayerHeaderString);
	LocalizedObject.SetString("Cancel", Class'KFCommon_LocalizedStrings'.Default.CancelString);
	LocalizedObject.SetString("SelectPerk", SelectPerkString);
	LocalizedObject.SetString("oncePerWave", class'KFGFxPerksContainer_Selection'.default.OncePerWaveString);
	
	SetObject("LocalizedText", LocalizedObject);
}

function UpdatePlayerInfo()
{
	SetPerkInfo();
	SetCharacterImage();
	SetPerkList();
}

function SetPerkInfo()
{
	local KFPerk CurrentPerk;
	local KFPlayerController KFPC;
	local GFxObject PerkIconObject;

	KFPC = KFPlayerController(GetPC());
	if (KFPC != none)
	{
		CurrentPerk = KFPC.CurrentPerk;
 		SetString("perkName", CurrentPerk.PerkName);
 		//SetString("perkIconPath", "img://"$CurrentPerk.GetPerkIconPath());
 		SetInt("perkLevel", CurrentPerk.GetLevel());
 		SetInt("xpBarValue", KFPC.GetPerkLevelProgressPercentage(CurrentPerk.Class));


		PerkIconObject = CreateObject("Object");
		PerkIconObject.SetString("perkIcon", "img://"$CurrentPerk.GetPerkIconPath());
		PerkIconObject.SetString("prestigeIcon", CurrentPerk.GetPrestigeIconPath(KFPC.GetPerkPrestigeLevelFromPerkList(CurrentPerk.class)));

		SetObject("perkImageSource", PerkIconObject);
	}
}

function SetPerkList()
{
	local GFxObject PerkObject;
	local GFxObject DataProvider;
	local KFPlayerController KFPC;
	local byte i;
	local int PerkPercent;

	KFPC = KFPlayerController(GetPC());
	if (KFPC != none)
	{
    	DataProvider = CreateArray();

		for (i = 0; i < KFPC.PerkList.Length; i++)
		{


			PerkObject = CreateObject( "Object" );
			PerkObject.SetString("name", KFPC.PerkList[i].PerkClass.default.PerkName);
			PerkObject.SetString("perkIconSource",  "img://"$KFPC.PerkList[i].PerkClass.static.GetPerkIconPath());
			PerkObject.SetInt("level", KFPC.PerkList[i].PerkLevel);

			PerkPercent = KFPC.GetPerkLevelProgressPercentage(KFPC.PerkList[i].PerkClass);
			
			PerkObject.SetInt("perkXP", PerkPercent);

			DataProvider.SetElementObject(i, PerkObject);
		}

		SetObject("perkList", DataProvider);
	}
}

function SetCharacterImage()
{
	local KFPlayerReplicationInfo KFPRI;
	local string CharacterImage;
	local byte CharacterIndex;

	KFPRI = KFPlayerReplicationInfo( GetPC().PlayerReplicationInfo );
	if (KFPRI != none)
	{
		CharacterIndex = KFPRI.RepCustomizationInfo.CharacterIndex;
		CharacterImage = PathName(KFPRI.CharacterArchetypes[CharacterIndex].DefaultHeadPortrait);
		CharacterImage = "img://"$CharacterImage;	
 		SetString("characterImage", CharacterImage);
	}
}


