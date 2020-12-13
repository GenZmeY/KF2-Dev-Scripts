//=============================================================================
// KFGFxPerksContainer_Selection
//=============================================================================
// Class Description
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//  - Author 9/26/2013
//=============================================================================

class KFGFxPerksContainer_Selection extends KFGFxPerksContainer;

struct PerkData
{
	var string PerkTitle;
 	var int PerkLevel;
 	var int PerkPercent;
};

var localized string HeaderTitle;
var localized string EndOfWaveString;
var localized string ChangesAppliedOnCloseString;
var localized string OncePerWaveString;

var array<PerkData> PerksData;

var KFGFxMenu_Perks PerksMenu;

var KFGameReplicationInfo KFGRI;
var KFPlayerReplicationInfo KFPRI;

function Initialize( KFGFxObject_Menu NewParentMenu )
{
	local KFPlayerController KFPC;

	KFPC = KFPlayerController(GetPC());
	KFPRI = KFPlayerReplicationInfo(KFPC.PlayerReplicationInfo);
	PerksMenu = KFGFxMenu_Perks(NewParentMenu);
	KFGRI = KFGameReplicationInfo(GetPC().WorldInfo.GRI);

	super.Initialize( NewParentMenu );
	LocalizeText();
	if(KFPC != none)
	{
		UpdatePerkSelection( KFPC.SavedPerkIndex );
	}

	SetPerkListEnabled(!KFPRI.bReadyToPlay);
}

function LocalizeText()
{
	local GFxObject LocalizedObject;

	LocalizedObject = CreateObject( "Object" );
	
	LocalizedObject.SetString("header", 					HeaderTitle); 
	LocalizedObject.SetString("oncePerkWave", 				OncePerWaveString);
	//LocalizedObject.SetString("endOfWave", 					EndOfWaveString);
	
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
		    TempObj.SetString( "Title",  PerkClass.default.PerkName );	
			TempObj.SetString( "iconSource",  "img://"$PerkClass.static.GetPerkIconPath() );
			TempObj.SetBool("bTierUnlocked", bool(bTierUnlocked) && KFPC.PerkList[i].PerkLevel >= UnlockedPerkLevel);
			
		    DataProvider.SetElementObject( i, TempObj );
		}	
		SetObject( "perkData", DataProvider );
		SetInt("SelectedIndex", SelectedPerkIndex);
		SetInt("ActiveIndex", SelectedPerkIndex); //Separated active index from the selected index call. This way the 'selected' index can be different from the active perk...mainly for navigation. (Shows the dark red button for the choosen perk) - HSL

		UpdatePendingPerkInfo(SelectedPerkIndex);
    }
}

function SetPerkListEnabled(bool bValue)
{
	local KFPlayerController KFPC;

	KFPC = KFPlayerController(GetPC());
	SetBool("perkListEnabled", bValue || KFPC.MyGFxManager.bAfterLobby);
}

function UpdatePendingPerkInfo(byte SelectedPerkIndex)
{
	local string PerkName;
	local KFPlayerController KFPC;

	KFPC = KFPlayerController( GetPC() );
	
	if( KFPC != none && KFGRI != none )
	{
		if(!class'WorldInfo'.static.IsMenuLevel())
		{
			if( (!KFPC.CanUpdatePerkInfo() && !KFGRI.CanChangePerks()) || (KFGRI.CanChangePerks() && PerksMenu.bModifiedPerk) && KFPC.PlayerReplicationInfo.bReadyToPlay && KFPC.WorldInfo.GRI.bMatchHasBegun)
			{
				PerkName = KFPC.PerkList[SelectedPerkIndex].PerkClass.default.PerkName;
			}
			else
			{
				PerkName = "";
			}
		}	
		
		if(KFGRI.CanChangePerks() && KFPC.CanUpdatePerkInfo())
		{
			SetPendingPerkChanges(PerkName, "img://"$KFPC.PerkList[SelectedPerkIndex].PerkClass.static.GetPerkIconPath(), ChangesAppliedOnCloseString);
		}
		else
		{
			SetPendingPerkChanges(PerkName, "img://"$KFPC.PerkList[SelectedPerkIndex].PerkClass.static.GetPerkIconPath(), EndOfWaveString);
		}
	}
}

function SetPendingPerkChanges(string PerkClassName, string PerkIconPath, string Message)
{
	ActionScriptVoid("setPendingPerkChanges");
}

function SavePerk(int PerkID)
{
	local KFPlayerController KFPC;

    KFPC = KFPlayerController(GetPC());
	if ( KFPC != none )
	{
		KFPC.RequestPerkChange( PerkID );

		if( KFPC.CanUpdatePerkInfo() )
		{
			KFPC.SetHaveUpdatePerk(true);
		}
	}
}
