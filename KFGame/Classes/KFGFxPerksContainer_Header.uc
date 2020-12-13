//=============================================================================
// KFGFxPerksContainer_Header
//=============================================================================
// Class Description
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//  - Author 10/1/2013
//=============================================================================

class KFGFxPerksContainer_Header extends KFGFxPerksContainer;

var GFxObject PerkTextField, LevelTextField;
var localized string PrestigeLevelString;
var localized string ExperienceString;


function Initialize( KFGFxObject_Menu NewParentMenu )
{
	local KFPlayerController KFPC;

	super.Initialize( NewParentMenu );
	KFPC = KFPlayerController(GetPC());
	UpdatePerkHeader( KFPC.PerkList[KFPC.SavedPerkIndex].PerkClass );
}


//@todo: change to grab data from PC.CurrentPerk
function UpdatePerkHeader( class<KFPerk> PerkClass)
{	
	local GFxObject PerkDataProvider, PerkIconObject;
	local KFPlayerController KFPC;
	local int NextEXP, CurrentEXP;
	local float EXPPercent;
	local byte 	PerkLevel, PrestigeLevel;

	KFPC = KFPlayerController(GetPC());

	EXPPercent = KFPC.GetPerkLevelProgressPercentage(PerkClass, CurrentEXP, NextEXP);
	PerkLevel = KFPC.GetPerkLevelFromPerkList(PerkClass);
	PrestigeLevel = KFPC.GetPerkPrestigeLevelFromPerkList(PerkClass);

	PerkDataProvider = CreateObject( "Object" );

	PerkIconObject = CreateObject("Object");
	PerkIconObject.SetString("perkIcon", "img://"$PerkClass.static.GetPerkIconPath());
	
	PerkIconObject.SetString("prestigeIcon", PerkClass.static.GetPrestigeIconPath(PrestigeLevel));

	PerkDataProvider.SetObject("perkData", PerkIconObject);
    PerkDataProvider.SetString( "perkTitle", PerkClass.default.PerkName );
    PerkDataProvider.SetString( "perkLevel", LevelString@PerkLevel);
	PerkDataProvider.SetString("prestigeLevel", class'KFGFxMenu_Perks'.default.CurrentPrestigeLevelString @PrestigeLevel);
    PerkDataProvider.SetString( "xpString",  CurrentEXP $"/" $NextEXP );
    PerkDataProvider.SetFloat( "xpPercent", EXPPercent / 100 );
	SetObject( "perkData", PerkDataProvider );
}


