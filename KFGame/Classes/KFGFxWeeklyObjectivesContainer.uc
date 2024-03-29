//=============================================================================
// KFGFxWeeklyObjectivesContainer
//=============================================================================
// This will be the parent container for the weekly and special event container
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//  - Zane Gholson 3/28/2017
//=============================================================================

class KFGFxWeeklyObjectivesContainer extends KFGFxObject_Container
dependson(KFMission_LocalizedStrings);

var int LastWeeklyPopulated;
var bool bLastWeeklyComplete;
var KFPlayerController KFPC;

var KFGFxMenu_StartGame StartGameMenu;

function Initialize( KFGFxObject_Menu NewParentMenu )
{
    super.Initialize( NewParentMenu );
    
	StartGameMenu = KFGFxMenu_StartGame(NewParentMenu);

    KFPC = KFPlayerController(GetPC());
    if(KFPC != none)
    {
		PopulateData();
    }
}

function bool PopulateData()
{
	local int IntendedWeeklyIndex, WeeklyIndex, OverrideWeeklyIndex;
	local GFxObject DataObject;
	local KFWeeklyOutbreakInformation WeeklyInfo;
	local byte CurrentMenuState;
	local bool bWeeklyComplete, bIsCustomWeekly;

	IntendedWeeklyIndex = class'KFGameEngine'.static.GetIntendedWeeklyEventIndexMod();
	WeeklyIndex = -1;
	OverrideWeeklyIndex = -1;

	// If the Start Game Menu is opened and in some of the next states,.. we can read a different weekly selection
	if (StartGameMenu != none)
	{
		CurrentMenuState = StartGameMenu.GetStartMenuState();

		Switch (EStartMenuState(CurrentMenuState))
		{
			case ECreateGame:
			case ESoloGame:
				if (StartGameMenu.OptionsComponent.GetWeeklySelectorIndex() != 0)
				{
					OverrideWeeklyIndex = StartGameMenu.OptionsComponent.GetWeeklySelectorIndex() - 1;
				}

				break;
		}
	}

	if (KFPC.WorldInfo.NetMode == NM_Client)
	{
		if (KFPC != none && KFGameReplicationInfo(KFPC.WorldInfo.GRI) != none)
		{
			WeeklyIndex = KFGameReplicationInfo(KFPC.WorldInfo.GRI).CurrentWeeklyIndex;
		}	
		else
		{
			GetPC().SetTimer(0.5f, false, nameof(PopulateData));
		}
	}
	else
	{
		if (OverrideWeeklyIndex >= 0)
		{
			WeeklyIndex = OverrideWeeklyIndex;
		}
		else
		{
			WeeklyIndex = class'KFGameEngine'.static.GetWeeklyEventIndexMod();
		}
	}

	if (WeeklyIndex != -1)
	{
		bIsCustomWeekly = IntendedWeeklyIndex != WeeklyIndex;
	}

	bWeeklyComplete = KFPC.IsWeeklyEventComplete();

	if (bWeeklyComplete != bLastWeeklyComplete || LastWeeklyPopulated != WeeklyIndex)
	{
		LastWeeklyPopulated = WeeklyIndex;
		bLastWeeklyComplete = bWeeklyComplete;

		LocalizeMenu(bIsCustomWeekly);

		if (WeeklyIndex >= 0)
		{
			WeeklyInfo = class'KFMission_LocalizedStrings'.static.GetWeeklyOutbreakInfoByIndex(WeeklyIndex);
		}
		else
		{
			WeeklyInfo = class'KFMission_LocalizedStrings'.static.GetCurrentWeeklyOutbreakInfo();
		}

		if (WeeklyInfo == none)
		{
			return false;
		}

		DataObject = CreateObject("Object");
		
		DataObject.SetString("label", WeeklyInfo.FriendlyName);

		if(WeeklyInfo.ModifierDescriptions.length > 0)
    	{
			DataObject.SetString("description", WeeklyInfo.DescriptionStrings[0]);
		}

		DataObject.SetString("iconPath", "img://"$WeeklyInfo.IconPath);

		DataObject.SetBool("complete", bWeeklyComplete);
		DataObject.SetBool("showProgres", false);
		DataObject.SetFloat("progress", 0);
		DataObject.SetString("textValue", "");
		
		SetObject("weeklyObjectiveData", DataObject);

		if (WeeklyInfo.ModifierDescriptions.Length > 0)
		{
			SetString("weeklyDescription", WeeklyInfo.ModifierDescriptions[0]);
		}

		PopulateModifiers(WeeklyInfo);
		PopulateRewards(WeeklyInfo, WeeklyIndex, bIsCustomWeekly);

		return true;
	}

	return false;
}

function PopulateModifiers(KFWeeklyOutbreakInformation WeeklyInfo)
{
	local int i;
	local GFxObject DataObject;
	local GFxObject DataProvider; //array containing the data objects 

	if (WeeklyInfo == none || (GetPC().WorldInfo.NetMode == NM_Client && KFPC.WorldInfo.GRI == none))
	{
		return;
	}

	DataProvider = CreateArray();

	for (i = 0; i <  WeeklyInfo.ModifierDescriptions.length; i++)
	{
		DataObject = CreateObject("Object");
		DataObject.SetString("label", ""); //no lable at the moment

		DataObject.SetString("description", WeeklyInfo.ModifierDescriptions[i]);

		//DataObject.SetString("iconPath", "img://"$WeeklyInfo.ModifierIconPaths[i]);

		DataProvider.SetElementObject(i, DataObject); //add it to the array
	}

	SetObject("modifiers", DataProvider); //pass to SWF
}

function PopulateRewards(KFWeeklyOutbreakInformation WeeklyInfo, int WeeklyIndex, bool bIsCustomWeekly)
{
	local int i, ItemCount;
	local GFxObject DataProvider; //array containing the data objects 
	local GFxObject GfxRewardItem;

	if (WeeklyInfo == none)
	{
		return;
	}

	ItemCount = 0;
	DataProvider = CreateArray();
	
	WeeklyInfo.RewardIDs = class'KFOnlineStatsWrite'.static.GetWeeklyOutbreakRewards(WeeklyIndex);
	for (i = 0; i <  WeeklyInfo.RewardIDs.length; i++)
	{
		GfxRewardItem = CreateRewardItem(WeeklyInfo, WeeklyInfo.RewardIDs[i]);
		if(GfxRewardItem != none)			
		{
			DataProvider.SetElementObject(ItemCount, GfxRewardItem); //add it to the array
			ItemCount++;
		}		
	}

	if (bIsCustomWeekly == false)
	{
		SetObject("rewards", DataProvider); //pass to SWF
		SetInt("vaultDoshReward", class'KFOnlineStatsWrite'.static.GetWeeklyEventReward());
	}
	else
	{
		SetInt("setHideRewards", 1);
	}
}

function GFxObject CreateRewardItem(KFWeeklyOutbreakInformation WeeklyInfo,int ItemID)
{
	local GFxObject DataObject;
	local int ItemIndex;
	local ItemProperties RewardItem;
	local OnlineSubsystem	OnlineSub;

	OnlineSub =  Class'GameEngine'.static.GetOnlineSubsystem();

	if(OnlineSub == none)
	{
		return none;
	}
	
	ItemIndex = OnlineSub.ItemPropertiesList.Find('Definition',ItemID);
	
	if( ItemIndex == INDEX_NONE ) 
	{
		`log("ItemID not found: " @ItemID);
		return none;
	}

	RewardItem = OnlineSub.ItemPropertiesList[ItemIndex];

	DataObject = CreateObject( "Object" );
				
	DataObject.SetString("label", RewardItem.Name);
	DataObject.SetString("iconPath", "img://"$RewardItem.IconURL);

	return DataObject;
}

function LocalizeMenu(bool bIsCustomWeekly)
{
    local GFxObject TextObject;

    TextObject = CreateObject("Object");

    // Localize static text
    TextObject.SetString("currentModifier",	class'KFMission_LocalizedStrings'.default.CurrentWeeklySettingsString);  
    TextObject.SetString("reward",			class'KFMission_LocalizedStrings'.default.RewardsString);    
    TextObject.SetString("granted", 		class'KFMission_LocalizedStrings'.default.GrantedWeeklyString);

	if (bIsCustomWeekly)
	{
		TextObject.SetString("weekly",		class'KFMission_LocalizedStrings'.default.WeeklyString $class'KFMission_LocalizedStrings'.default.WeeklyCustomString);
	}
	else
	{
		TextObject.SetString("weekly",		class'KFMission_LocalizedStrings'.default.WeeklyString);
	}

    TextObject.SetString("overview",		class'KFMission_LocalizedStrings'.default.WeeklyOverview);  
    TextObject.SetString("vaultDosh",		class'KFMission_LocalizedStrings'.default.VaultDoshString);  

    SetObject("localizedText", TextObject);
}

defaultproperties
{
	LastWeeklyPopulated = -1
	bLastWeeklyComplete = false
}