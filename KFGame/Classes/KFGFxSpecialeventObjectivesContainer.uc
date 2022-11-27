//=============================================================================
// KFGFxSpecialEventObjectivesContainer
//=============================================================================
// This will be the parent container for the weekly and special event container
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//  - Zane Gholson 3/31/2017
//=============================================================================

class KFGFxSpecialEventObjectivesContainer extends KFGFxObject_Container;

var localized string CurrentSpecialEventString;
var localized string CurrentSpecialEventDescriptionString;

struct SSpecialEventObjectiveInfo
{
    var localized string TitleString;
    var localized string DescriptionString;
	var localized string TierEventRewardName;
};

var localized array<SSpecialEventObjectiveInfo> SpecialEventObjectiveInfoList;
var array<string>ObjectiveIconURLs;

var string AllCompleteRewardIconURL;
var localized string AllCompleteRewardDescriptionString;  

var array<string>ChanceDropIconURLs;
var localized array<string> ChanceDropDescriptionStrings;  

var string IconURL;

var array<ObjectiveProgress> ObjectiveStatusList;

var array<bool> UsesProgressList;

var array<int> ObjectLastValue;

var KFPlayerController KFPC;

function Initialize( KFGFxObject_Menu NewParentMenu )
{
    super.Initialize( NewParentMenu );
    
	KFPC = KFPlayerController(GetPC());

    LocalizeMenu(); 
    PopulateData();
    PopulateReward();
    PopulateChanceDrops();
}

function LocalizeMenu()
{
    local GFxObject TextObject;
    TextObject = CreateObject("Object");
    // Localize static text
    TextObject.SetString("title",			default.CurrentSpecialEventString);  
    TextObject.SetString("reward",			class'KFMission_LocalizedStrings'.default.RewardsString);    
    TextObject.SetString("granted", 		class'KFMission_LocalizedStrings'.default.GrantedSpecialEventString);  
    TextObject.SetString("chanceOfDrop",	class'KFMission_LocalizedStrings'.default.SpecialEventChanceDropString);  
    SetObject("localizedText", TextObject);
}


function bool PopulateData()
{
    local GFxObject DataObject;
    local GFxObject DataProvider; //array containing the data objects 
    local int i;
	local int CurrentProgressValue, MaxProgressValue;
	local float ProgressCompletePercentage;

    if(HasObjectiveStatusChanged())
    {
        DataProvider = CreateArray();

        for (i = 0; i < SpecialEventObjectiveInfoList.length; i++)
        {
            DataObject = CreateObject("Object");
            
			if (DataObject != none)
			{
				DataObject.SetString("label", default.SpecialEventObjectiveInfoList[i].TitleString);
				DataObject.SetString("description", default.SpecialEventObjectiveInfoList[i].DescriptionString);
				DataObject.SetString("iconPath", "img://"$default.ObjectiveIconURLs[i]);
				DataObject.SetBool("complete", ObjectiveStatusList[i].bComplete);
				DataObject.SetInt("rewardValue", KFPC.GetSpecialEventRewardValue());
				DataObject.SetBool("showProgress", UsesProgressList[i]);
				if (UsesProgressList[i])
				{
					GetObjectiveProgressValues(i, CurrentProgressValue, MaxProgressValue, ProgressCompletePercentage);
					DataObject.SetFloat("progress", ProgressCompletePercentage);
					DataObject.SetString("textValue", CurrentProgressValue $"/" $MaxProgressValue);

				}

				DataProvider.SetElementObject(i, DataObject); //add it to the array
			}
        }

        if(default.IconURL != "")
        {
            DataProvider.SetString("iconPath", "img://"$default.IconURL);
        }    
        
        SetObject("objectives", DataProvider);
        return true;
    }

    return false;
}

static function GetObjectiveProgressValues(int ObjectiveID, out int CurrentValue, out int MaxValue, out float PercentComplete)
{
	local KFPlayerController LocalKFPC;
	local int TempCurrentValue, TempMaxValue;
	
    TempCurrentValue = 0;
    TempMaxValue = 0;

	LocalKFPC = KFPlayerController(class'WorldInfo'.static.GetWorldInfo().GetALocalPlayerController());
	LocalKFPC.GetSeasonalEventStatInfo(ObjectiveID, TempCurrentValue, TempMaxValue);

	MaxValue = TempMaxValue;
	CurrentValue = Clamp(TempCurrentValue, 0, MaxValue);
	PercentComplete = MaxValue > 0 ? FClamp((float(CurrentValue) / float(MaxValue)), 0, 1.0f) : 0.f;
}

function bool HasObjectiveStatusChanged()
{
    local int i;
    local bool bHasChanged;
    local bool bTempStatus;
	local int ProgressValue, MaxValue;
	local float PercentageValue;

    if(SpecialEventObjectiveInfoList.length != ObjectiveStatusList.length)
    {
        ObjectiveStatusList.length = SpecialEventObjectiveInfoList.length;
        for (i = 0; i < SpecialEventObjectiveInfoList.length; i++)
        {
			GetObjectiveProgressValues(i, ProgressValue, MaxValue, PercentageValue);
            ObjectiveStatusList[i].bComplete = KFPC.IsEventObjectiveComplete(i);
			ObjectiveStatusList[i].NumericValue = ProgressValue;
        }
        bHasChanged = true;
    }
    else
    {
        for (i = 0; i < SpecialEventObjectiveInfoList.length; i++)
        {
            bTempStatus = KFPC.IsEventObjectiveComplete(i);
			GetObjectiveProgressValues(i, ProgressValue, MaxValue, PercentageValue);
            if(ObjectiveStatusList[i].bComplete != bTempStatus || ObjectiveStatusList[i].NumericValue != ProgressValue)
            {
                bHasChanged = true;
                ObjectiveStatusList[i].bComplete = bTempStatus;
				ObjectiveStatusList[i].numericValue = KFPC.GetSpecialEventRewardValue();
            }
        }
    }

    return bHasChanged;
}

function PopulateReward()
{
    local GFxObject DataObject;
    
    DataObject = CreateObject("Object");
    DataObject.SetString("label", default.AllCompleteRewardDescriptionString);
    DataObject.SetString("iconPath", "img://"$default.AllCompleteRewardIconURL); //add reward icon here  

    SetObject("allCompleteReward", DataObject); //pass to SWF
}

function PopulateChanceDrops()
{
    local int i;
    local GFxObject DataObject;
    local GFxObject DataProvider; //array containing the data objects 

    DataProvider = CreateArray();
        
    for (i = 0; i <  ChanceDropDescriptionStrings.length; i++)
    {
        DataObject = CreateObject("Object");
        DataObject.SetString("label", ChanceDropDescriptionStrings[i]);
        DataObject.SetString("iconPath", "img://"$ChanceDropIconURLs[i]); //add reward icon here  

        DataProvider.SetElementObject(i, DataObject); //add it to the array
    }

    SetObject("chanceDrops", DataProvider); //pass to SWF
}

DefaultProperties
{
    ObjectiveIconURLs[0]="UI_PerkIcons_TEX.UI_PerkIcon_Berserker"
    ObjectiveIconURLs[1]="UI_PerkIcons_TEX.UI_PerkIcon_Berserker"
    ObjectiveIconURLs[2]="UI_PerkIcons_TEX.UI_PerkIcon_Berserker"
    ObjectiveIconURLs[3]="UI_PerkIcons_TEX.UI_PerkIcon_Berserker"
    //ObjectiveIconURLs[4]="UI_PerkIcons_TEX.UI_PerkIcon_Berserker"
    //defaults
    AllCompleteRewardIconURL="UI_PerkIcons_TEX.UI_PerkIcon_Berserker"
    ChanceDropIconURLs[0]="UI_PerkIcons_TEX.UI_PerkIcon_Berserker"
    ChanceDropIconURLs[1]="UI_PerkIcons_TEX.UI_PerkIcon_Berserker"

	UsesProgressList[0]=false
	UsesProgressList[1]=false
	UsesProgressList[2]=false
	UsesProgressList[3]=false
	UsesProgressList[4]=false
}