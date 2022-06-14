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

var bool bInitialDataPopulated;
var bool bLastWeeklyComplete;
var KFPlayerController KFPC;

function Initialize( KFGFxObject_Menu NewParentMenu )
{
    super.Initialize( NewParentMenu );
    
    KFPC = KFPlayerController(GetPC());
    if(KFPC != none)
    {
    	LocalizeMenu();
    	PopulateData();
    }
}

function bool PopulateData()
{
	local GFxObject DataObject;
	local KFWeeklyOutbreakInformation WeeklyInfo;
	local bool bWeeklyComplete;
	local int WeeklyIndex;

	bWeeklyComplete = KFPC.IsWeeklyEventComplete();
	WeeklyIndex = -1;

	if(bWeeklyComplete != bLastWeeklyComplete || !bInitialDataPopulated)
	{
		if (KFPC.WorldInfo.NetMode == NM_Client)
		{
			if (KFPC != none && KFGameReplicationInfo(KFPC.WorldInfo.GRI) != none)
			{
				WeeklyIndex = KFGameReplicationInfo(KFPC.WorldInfo.GRI).CurrentWeeklyIndex;
				WeeklyInfo = class'KFMission_LocalizedStrings'.static.GetWeeklyOutbreakInfoByIndex(WeeklyIndex);
			}
			else
			{
				GetPC().SetTimer(0.5f, false, nameof(PopulateData));
			}
		}
		else
		{
			WeeklyInfo = class'KFMission_LocalizedStrings'.static.GetCurrentWeeklyOutbreakInfo();
		}

		DataObject = CreateObject("Object");
		if(WeeklyInfo == none)
		{
			return false;
		}
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
		PopulateRewards(WeeklyInfo, WeeklyIndex);

		bLastWeeklyComplete = bWeeklyComplete;
		bInitialDataPopulated = true;
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

function PopulateRewards(KFWeeklyOutbreakInformation WeeklyInfo, int WeeklyIndex)
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

	SetObject("rewards", DataProvider); //pass to SWF
	UpdateDoshVaultRewardValue();
}

function UpdateDoshVaultRewardValue()
{
	SetInt("vaultDoshReward", class'KFOnlineStatsWrite'.static.GetWeeklyEventReward());
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

function LocalizeMenu()
{
    local GFxObject TextObject;
//    local KFWeeklyOutbreakInformation WeeklyInfo;

//    WeeklyInfo = class'KFMission_LocalizedStrings'.static.GetCurrentWeeklyOutbreakInfo();
    TextObject = CreateObject("Object");
    // Localize static text
    TextObject.SetString("currentModifier",	class'KFMission_LocalizedStrings'.default.CurrentWeeklySettingsString);  
    TextObject.SetString("reward",			class'KFMission_LocalizedStrings'.default.RewardsString);    
    TextObject.SetString("granted", 		class'KFMission_LocalizedStrings'.default.GrantedWeeklyString);  
    TextObject.SetString("weekly",			class'KFMission_LocalizedStrings'.default.WeeklyString);  
    TextObject.SetString("overview",		class'KFMission_LocalizedStrings'.default.WeeklyOverview);  
    TextObject.SetString("vaultDosh",		class'KFMission_LocalizedStrings'.default.VaultDoshString);  
/*
    if(WeeklyInfo != none && WeeklyInfo.ModifierDescriptions.length > 0)
    {
    	TextObject.SetString("description",		WeeklyInfo.ModifierDescriptions[0]);  
    }
*/  
    SetObject("localizedText", TextObject);
}
