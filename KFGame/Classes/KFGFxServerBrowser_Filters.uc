//=============================================================================
// KFGFxServerBrowser_Filters
//=============================================================================
// Class Description
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//  - Zane 8/19/2014
//=============================================================================

class KFGFxServerBrowser_Filters extends KFGFxObject_Container
	native(UI)
	config(UI);

var KFGFxMenu_ServerBrowser ServerMenu;
var localized string NoPasswordString, NoMutatorsString, NotFullString, NotEmptyString, NoRankedStandardString, NoRankedCustomString, NoUnrankedString, DedicatedString, VACSecureString, InLobbyString, InProgressString, OnlyStockMapsString, OnlyCustomMapsString, LimitServerResultsString, NotServerExiledString, NoSeasonalSkinsString;
var array<string> FilterStrings;

var config Bool bNoPassword, bNoMutators, bNotFull, bNotEmpty, bUsesStats, bCustom, bDedicated, bVAC_Secure, bInLobby, bInProgress, bOnlyStockMaps, bOnlyCustomMaps, bLimitServerResults, bNoLocalAdmin, bNoSeasonalSkins;
var config byte SavedGameModeIndex, SavedMapIndex, SavedDifficultyIndex, SavedLengthIndex, SavedPingIndex, SavedWeeklySelectorIndex;

var  Bool bNoPasswordPending, bNoMutatorsPending, bNotFullPending, bNotEmptyPending, bUsesStatsPending, bCustomPending, bDedicatedPending, bVAC_SecurePending, bInLobbyPending, bInProgressPending, bOnlyStockMapsPending, bOnlyCustomMapsPending, bLimitServerResultsPending, bNoLocalAdminPending, bNoSeasonalSkinsPending;
var  byte SavedGameModeIndexPending, SavedMapIndexPending, SavedDifficultyIndexPending, SavedLengthIndexPending, SavedPingIndexPending, SavedWeeklySelectorIndexPending;

var transient string CachedMapName, CachedModeName;
var transient int CachedDifficulty, CachedLength;

var transient array<string> MapList;

var int NumDifficultyStrings;
var int MaxNumberMapList;

// if you change this also update ServerBrowserFilterContainer.as -> NUM_OF_FILTERS

enum EFilter_Key
{
	NO_PASSWORD,
	NO_MUTATORS,
	NOT_FULL,
	NOT_EMPTY,
	//NO_RANKED_STANDARD,  	//Not using for EA
	CUSTOM,
	//NO_UNRANKED,			//Not using for EA
	DEDICATED,
	//VAC_SECURE,			//Not using for EA
	IN_LOBBY,
	IN_PROGRESS,
	LIMIT_SERVER_RESULTS,
	/*ONLY_STOCK_MAPS,		//Not using for EA
	ONLY_CUSTOM_MAPS,*/		//Not using for EA
	NO_LOCAL_ADMIN,
	NO_SEASONAL_SKINS,
	FILTERS_MAX,
};

function Initialize( KFGFxObject_Menu NewParentMenu )
{
	super.Initialize( NewParentMenu );
	
	ServerMenu = KFGFxMenu_ServerBrowser(NewParentMenu);
	
	if (SavedGameModeIndex < 0 || SavedGameModeIndex >= class'KFGameInfo'.default.GameModes.length)
	{
		SavedGameModeIndex = 255;
	}
	
	SavedGameModeIndexPending = SavedGameModeIndex;
	
	NumDifficultyStrings = class'KFCommon_LocalizedStrings'.static.GetDifficultyStringsArray().Length;
	
	AdjustSavedFiltersToMode();

	MaxNumberMapList = -1;

	UpdateMapList();

	InitFiltersArray();
	LocalizeText();
	ClearPendingValues();
}

function int GetUsableGameMode(int ModeIndex)
{
	if (ModeIndex >= class'KFGameInfo'.default.GameModes.length || ModeIndex < 0)
	{
		return 0;
	}
	else
	{
		return ModeIndex;
	}
}

function AdjustSavedFiltersToMode()
{
	if (SavedDifficultyIndex >= class'KFGameInfo'.default.GameModes[GetUsableGameMode(SavedGameModeIndex)].DifficultyLevels)
	{
		SavedDifficultyIndex = 255;
	}
	SavedDifficultyIndexPending = SavedDifficultyIndex;
	
	if (SavedLengthIndex >= class'KFGameInfo'.default.GameModes[GetUsableGameMode(SavedGameModeIndex)].Lengths)
	{
		SavedLengthIndex = 255;
	}
	SavedLengthIndexPending = SavedLengthIndex;

	if (SavedGameModeIndex != 1)
	{
		SavedWeeklySelectorIndex = 0;
	}
	SavedWeeklySelectorIndexPending = SavedWeeklySelectorIndex;
}

exec native function string GetSelectedMap() const;

exec native function int GetSelectedDifficulty() const;

exec native function int GetSelectedGameLength() const;

//@SABER_BEGIN - Getting current value for ping filtering
native function int GetMaxPing() const;
//@SABER_END

exec native function int GetWeeklySelectorIndex() const;

function InitFiltersArray()
{
	FilterStrings[NO_PASSWORD] 			= NoPasswordString;
	FilterStrings[NO_MUTATORS] 			= NoMutatorsString;
	FilterStrings[NOT_FULL] 			= NotFullString;
	FilterStrings[NOT_EMPTY] 			= NotEmptyString;
	//FilterStrings[NO_RANKED_STANDARD] 	= NoRankedStandardString;
	FilterStrings[CUSTOM] 	= NoRankedCustomString;
	//FilterStrings[NO_UNRANKED] 			= NoUnrankedString;
	FilterStrings[DEDICATED] 			= DedicatedString;
	//FilterStrings[VAC_SECURE] 			= VACSecureString;
	FilterStrings[IN_LOBBY] 			= InLobbyString;
	FilterStrings[IN_PROGRESS] 			= InProgressString;
	FilterStrings[LIMIT_SERVER_RESULTS] 	= LimitServerResultsString @class'KFGFxServerBrowser_ServerList'.default.MaxSearchResults;
	FilterStrings[NO_LOCAL_ADMIN]			= NotServerExiledString;
	/*FilterStrings[ONLY_STOCK_MAPS] 		= OnlyStockMapsString;
	FilterStrings[ONLY_CUSTOM_MAPS] 	= OnlyCustomMapsString;*/
	FilterStrings[NO_SEASONAL_SKINS]		= NoSeasonalSkinsString;
}

function LocalizeText()
{
	local GFxObject LocalizedObject;

	LocalizedObject = CreateObject( "Object" );

	LocalizedObject.SetString("back", ServerMenu.BackString);
	LocalizedObject.SetString("reset", ServerMenu.ResetString);
	LocalizedObject.SetString("apply", ServerMenu.ApplyString);
	LocalizedObject.SetString("filters", ServerMenu.FiltersString);

	LocalizedObject.SetString("gameMode", ServerMenu.GameModeString);
	LocalizedObject.SetString("map", ServerMenu.MapString);
	LocalizedObject.SetString("difficulty", ServerMenu.DifficultyString);
	LocalizedObject.SetString("length", ServerMenu.LengthString);
	LocalizedObject.SetString("ping", ServerMenu.PingString);
	LocalizedObject.SetString("weeklyIndex", ServerMenu.WeeklyIndexString);

	SetObject("localizedText", LocalizedObject);

	CreateList("gameModeScrollingList", class'KFCommon_LocalizedStrings'.static.GetGameModeStringsArray(), (SavedGameModeIndex == 255) ? class'KFGameInfo'.default.GameModes.length : int(SavedGameModeIndex));
	CreateList("mapScrollingList", MapList, savedMapIndex);
	SetModeMenus("difficultyScrollingList", "lengthScrollingList", SavedGameModeIndexPending);
	CreateList("difficultyScrollingList", class'KFCommon_LocalizedStrings'.static.GetDifficultyStringsArray(), SavedDifficultyIndex);
	CreateList("lengthScrollingList", class'KFCommon_LocalizedStrings'.static.GetLengthStringsArray(), SavedLengthIndex);
	CreateList("pingScrollingList", ServerMenu.PingOptionStrings, SavedPingIndex);
	CreateList("weeklyIndexScrollingList", class'KFCommon_LocalizedStrings'.static.GetWeeklySelectorStringsArray(), SavedWeeklySelectorIndex, -1, true, SavedGameModeIndexPending == 1);

	LocalizeCheckBoxes();
}

function LocalizeCheckBoxes()
{
	local byte i;
	local GFxObject FiltersArray;
	local GFxObject TempObject;
	local bool bShowAllowSeasonalSkins;

	bShowAllowSeasonalSkins = true;

	if (ServerMenu.Manager.StartMenu.GetStartMenuState() == EMatchmaking
		|| class'KFGameEngine'.static.GetSeasonalEventIDForZedSkins() == SEI_None
		|| class'KFGameEngine'.static.GetSeasonalEventIDForZedSkins() == SEI_Spring)
	{
		bShowAllowSeasonalSkins = false; // Default if we don't have a season or it's find a match menu
	}

	SetBool("SetAllowSkinsVisibility", bShowAllowSeasonalSkins);

	FiltersArray = CreateArray();

	// If you plan to disable a filter don't do it here, do it on ServerBrowserFilterContainer.as

	for ( i = 0; i < FILTERS_MAX; i++ )
	{
		TempObject = CreateObject( "Object" );
		TempObject.SetString("label", FilterStrings[i] );
		TempObject.SetInt("key", i);
		TempObject.SetBool("selected", GetBoolByEFilter_Key(EFilter_Key(i)));
		FiltersArray.SetElementObject(i, TempObject);
    }

	SetObject("filterLabels", FiltersArray);
}

function SetModeMenus(string DifficultyListString, string LengthListString, int ModeIndex)
{
	local int NewDifficultyIndex, NewLengthIndex;
	local int UseModeIndex;
	local GFxObject DifficultyDataProvider, LengthDataProvider;
	local int i;

	DifficultyDataProvider = GetObject(DifficultyListString).GetObject("dataProvider");
	LengthDataProvider = GetObject(LengthListString).GetObject("dataProvider");
	for (i = 0; i < 5; ++i)
	{
		DifficultyDataProvider.SetElementObject(i, None);
		if (i < 4)	// prevents a blank option from being added to the Length list
		{
			LengthDataProvider.SetElementObject(i, None);
		}
	}
	if (SavedDifficultyIndexPending >= class'KFGameInfo'.default.GameModes[UseModeIndex].DifficultyLevels)
	{
		NewDifficultyIndex = 255;
	}
	else
	{
		NewDifficultyIndex = SavedDifficultyIndexPending;
	}
	if (SavedLengthIndexPending >= class'KFGameInfo'.default.GameModes[UseModeIndex].Lengths)
	{
		NewLengthIndex = 255;
	}
	else
	{
		NewLengthIndex = SavedLengthIndexPending;
	}
	UseModeIndex = GetUsableGameMode(ModeIndex);
	//`log("ModeIndex:"$ModeIndex$", UseModeIndex:"$UseModeIndex);
	CreateList(DifficultyListString, class'KFCommon_LocalizedStrings'.static.GetDifficultyStringsArray(), NewDifficultyIndex, class'KFGameInfo'.default.GameModes[UseModeIndex].DifficultyLevels);
	CreateList(LengthListString, class'KFCommon_LocalizedStrings'.static.GetLengthStringsArray(), NewLengthIndex, class'KFGameInfo'.default.GameModes[UseModeIndex].Lengths);
}

function CreateList( string ListString
					, array<string> TextArray
					, int SelectedIndex
					, optional int MaxListLength = 0
					, optional bool bAnyIsFirst = false
					, optional bool bEnabled = true)
{
	local int i;
	local GFxObject OptionList;
	local GFxObject DataProvider;
	local GFxObject ItemSlot;
	local string 	TempString, ButtonLabel;
	local int ListLength;

	OptionList = GetObject(ListString);

	DataProvider = OptionList.GetObject("dataProvider");

	//`log("MaxListLength:"$MaxListLength$", Length:"$TextArray.length);

	if (MaxListLength > 0)
	{
		ListLength = Min(MaxListLength, TextArray.length);
	}
	else
	{
		ListLength = TextArray.length;
	}

	if (MaxListLength >= ListLength)
	{
		SelectedIndex = 255;
	}

	if (bAnyIsFirst)
	{
		//Add the any choice
		ItemSlot = CreateObject( "Object" );
		ItemSlot.SetString("label", class'KFCommon_LocalizedStrings'.default.NoPreferenceString);
		DataProvider.SetElementObject(0, ItemSlot);		
	}

	for ( i = 0; i < ListLength; i++ )
	{
		ItemSlot = CreateObject( "Object" );
		TempString = TextArray[i];
		ItemSlot.SetString("label", TempString );
		DataProvider.SetElementObject(bAnyIsFirst ? i + 1 : i, ItemSlot);
	}

	if (bAnyIsFirst == false)
	{
		//Add the any choice
		ItemSlot = CreateObject( "Object" );
		ItemSlot.SetString("label", class'KFCommon_LocalizedStrings'.default.NoPreferenceString);
		DataProvider.SetElementObject(i, ItemSlot);
	}

	if(SelectedIndex != 255)
	{
		OptionList.SetInt("selectedIndex", SelectedIndex);
	}

	OptionList.SetObject("dataProvider", DataProvider);

	if (bEnabled)
	{
		if (bAnyIsFirst)
		{
			ButtonLabel = class'KFCommon_LocalizedStrings'.default.NoPreferenceString;
		}
		else
		{
			if(SelectedIndex < ListLength)
			{
				ButtonLabel = TextArray[SelectedIndex];
			}
			else
			{
				ButtonLabel = "-";
			}
		}
	}
	else
	{
		ButtonLabel = "-";
	}

	OptionList.GetObject("associatedButton").SetString("label", ButtonLabel);

	OptionList.ActionScriptVoid("invalidateData");

	if (bEnabled )
	{
		OptionList.GetObject("associatedButton").SetBool("enabled", true);
	}
	else
	{
		OptionList.GetObject("associatedButton").SetBool("enabled", false);
	}
}

function UpdateMapList()
{
	ServerMenu.Manager.StartMenu.GetMapList(MapList, SavedGameModeIndexPending);

	if (MapList.Length > MaxNumberMapList)
	{
		MaxNumberMapList = MapList.Length + 1;
	}
}

function ClearExtraMaps()
{
	local int i;
	local GFxObject OptionList;
	local GFxObject DataProvider;
	local GFxObject TempObj;

	OptionList = GetObject("mapScrollingList");

	DataProvider = OptionList.GetObject("dataProvider");

	for ( i = 0 ; i < MaxNumberMapList; i++ )
	{
		TempObj = DataProvider.GetElementObject(i);
		if (TempObj == none)
		{
			break;
		}

		DataProvider.SetElementObject(i, none);
	}

	OptionList.SetInt("selectedIndex", 0);

	OptionList.SetObject("dataProvider", DataProvider);

	OptionList.GetObject("associatedButton").SetString("label", "-");

	OptionList.ActionScriptVoid("invalidateData");
}

function ModeChanged(int index)
{
	if (index >= 0 && index < class'KFGameInfo'.default.GameModes.length)
	{
		SavedGameModeIndexPending = index;
	}
	else
	{
		SavedGameModeIndexPending = 255;
	}

	// Reset Saved Map
	SavedMapIndexPending = 255;

	UpdateMapList();

	// Reset Map Filter List (we need to do because the previous ElementObject are still there, we have to clear their state and then feed with new data)
	ClearExtraMaps();

	//`log("Adjusting difficulty");
	AdjustSavedFiltersToMode();

	//`log("Localizing text");
	LocalizeText();
}

function MapChanged(int index)
{
	SavedMapIndexPending = index;
}

function DifficultyChanged(int index)
{
	SavedDifficultyIndexPending = index;
}

function LengthChanged(int index)
{
	SavedLengthIndexPending = index;
}

function PingChanged(int index)
{
	SavedPingIndexPending = index;
}

function WeeklySelectorChanged(int index)
{
	SavedWeeklySelectorIndexPending = index;
}

function ApplyFilters()
{
	bNoPassword 	= bNoPasswordPending;
	bNoMutators 	= bNoMutatorsPending;
	bNotFull 		= bNotFullPending;
	bNotEmpty 		= bNotEmptyPending;
	//bUsesStats 		= bUsesStatsPending;
	bCustom 		= bCustomPending;
	bDedicated 		= bDedicatedPending;
	bVAC_Secure 	= bVAC_SecurePending;
	bInLobby 		= bInLobbyPending;
	bInProgress 	= bInProgressPending;
	bOnlyStockMaps 	= bOnlyStockMapsPending;
	bOnlyCustomMaps = bOnlyCustomMapsPending;
	bLimitServerResults = bLimitServerResultsPending;
	bNoLocalAdmin 	= bNoLocalAdminPending;
	bNoSeasonalSkins = bNoSeasonalSkinsPending;

	SavedGameModeIndex 		= SavedGameModeIndexPending;
	SavedMapIndex 			= SavedMapIndexPending;
	SavedDifficultyIndex 	= SavedDifficultyIndexPending;
	SavedLengthIndex 		= SavedLengthIndexPending;
	SavedPingIndex 			= SavedPingIndexPending;
	SavedWeeklySelectorIndex = SavedWeeklySelectorIndexPending;
	
	//`Log("ApplyFilters");
	
	SaveConfig();
}

function ClearPendingValues()
{
	bNoPasswordPending 				= bNoPassword;
	bNoMutatorsPending 				= bNoMutators;
	bNotFullPending 				= bNotFull;
	bNotEmptyPending 				= bNotEmpty;
	bUsesStatsPending 				= bUsesStats;
	bCustomPending 					= bCustom;
	bDedicatedPending 				= bDedicated;
	bVAC_SecurePending 				= bVAC_Secure;
	bInLobbyPending 				= bInLobby;
	bInProgressPending 				= bInProgress;
	bOnlyStockMapsPending 			= bOnlyStockMaps;
	bOnlyCustomMapsPending 			= bOnlyCustomMaps;
	bLimitServerResultsPending 		= bLimitServerResults;
	bNoLocalAdminPending			= bNoLocalAdmin;
	bNoSeasonalSkinsPending			= bNoSeasonalSkins;
 	SavedGameModeIndexPending 		= SavedGameModeIndex;
	SavedMapIndexPending 			= SavedMapIndex;
	SavedDifficultyIndexPending 	= SavedDifficultyIndex;
	SavedLengthIndexPending 		= SavedLengthIndex;
	SavedPingIndexPending 			= SavedPingIndex;
	SavedWeeklySelectorIndexPending	= SavedWeeklySelectorIndex;
	
	//`Log("ClearPendingValues");
}

function ResetFilters()
{
	bNoPassword 		= false;
	bNoMutators 		= false;
	bNotFull 			= false;
	bNotEmpty 			= false;
	bUsesStats 			= true;
	bCustom 			= true;
	bDedicated 			= false;
	bVAC_Secure 		= false;
	bInLobby 			= false;
	bInProgress 		= false;
	bOnlyStockMaps 		= false;
	bOnlyCustomMaps 	= false;
	bLimitServerResults = true;
	bNoLocalAdmin 		= true;
	bNoSeasonalSkins	= false;

	SavedGameModeIndex = 255;
	SavedMapIndex = 255;
	SavedDifficultyIndex = 255;
	SavedLengthIndex = 255;
	SavedPingIndex = 255;
	SavedWeeklySelectorIndex = 0;
	//`log("ResetFilters:"@bCustom);

	ClearPendingValues();
	SaveConfig();

	UpdateMapList();

	//reinit values
	LocalizeCheckBoxes();
	LocalizeText();
}

function SetBoolByEFilter_Key(EFilter_Key Filter, bool FilterValue)
{
	switch (Filter)
	{
		case NO_PASSWORD:
			bNoPasswordPending 		= FilterValue;
			break;
		case NO_MUTATORS:
			bNoMutatorsPending 		= FilterValue;
			break;
		case NOT_FULL:
			bNotFullPending 		= FilterValue;
			break;
		case NOT_EMPTY:
			bNotEmptyPending 		= FilterValue;
			break;
		/*case NO_RANKED_STANDARD:
			bNoRankedStandard 		= FilterValue;
			break;*/
		case CUSTOM:
			bCustomPending 			= FilterValue;
			//`log("SetBoolByEFilter_Key:bCustomPending="$bCustomPending);
			break;
		/*case NO_UNRANKED:
			bNoUnranked 			= FilterValue;
			break;*/
		case DEDICATED:
			bDedicatedPending 		= FilterValue;
			break;
		/*case VAC_SECURE:
			bVAC_SecurePending 		= FilterValue;
			break;*/
		case IN_LOBBY:
			bInLobbyPending 		= FilterValue;
			break;
		case IN_PROGRESS:
			bInProgressPending 		= FilterValue;
			break;
		case LIMIT_SERVER_RESULTS:
			bLimitServerResultsPending = FilterValue;
			break;
		case NO_LOCAL_ADMIN:
			bNoLocalAdminPending = FilterValue;
			break;
		case NO_SEASONAL_SKINS:
			bNoSeasonalSkinsPending = FilterValue;
			break;
		/*case ONLY_STOCK_MAPS:
			bOnlyStockMapsPending 	= FilterValue;
			break;
		case ONLY_CUSTOM_MAPS:
			bOnlyCustomMapsPending 	= FilterValue;
			break;*/
	}
}

function bool GetBoolByEFilter_Key(EFilter_Key Filter)
{
	switch (Filter)
	{
		case NO_PASSWORD:
			return bNoPassword;

		case NO_MUTATORS:
			return bNoMutators;

		case NOT_FULL:
			return bNotFull;

		case NOT_EMPTY:
			return bNotEmpty;

		/*case RANKED:
			return bUsesStats;*/

		case CUSTOM:
		//`log("GetBoolByEFilter_Key:"@bCustom);

			return bCustom;

		case DEDICATED:
			return bDedicated;

		/*case VAC_SECURE:
			return bVAC_Secure;*/

		case IN_LOBBY:
			return bInLobby;

		case IN_PROGRESS:
			return bInProgress;

		case LIMIT_SERVER_RESULTS:
			return bLimitServerResults;
		
		case NO_LOCAL_ADMIN:
			return bNoLocalAdmin;

		case NO_SEASONAL_SKINS:
			return bNoSeasonalSkins;

		/*case ONLY_STOCK_MAPS:
			return bOnlyStockMaps;

		case ONLY_CUSTOM_MAPS:
			return bOnlyCustomMaps;*/
	}
}

cpptext
{
	UBOOL CheckPingRange(INT index, INT ping) const;

}
