//=============================================================================
// KFGFxCollapsedObjectivesContainer
//=============================================================================
// This will be a ticker to display basic info on quests
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//  - Zane Gholson 3/28/2017
//=============================================================================

class KFGFxCollapsedObjectivesContainer extends KFGFxObject_Container
dependson (KFOnlineStatsWrite);

function Initialize( KFGFxObject_Menu NewParentMenu )
{
    super.Initialize( NewParentMenu );
    PopulateData();    
}

function PopulateData()
{
	local int ItemIndex,i;
	local GFxObject DataObject;
	local GFxObject DataProvider;
	local class<KFGFxSpecialeventObjectivesContainer> SpecialEventClass;
	local KFPlayerController KFPC; 

	local int CurrentProgressValue, MaxProgressValue;
	local float ProgressCompletePercentage;

	KFPC = KFPlayerController(GetPC());
	DataProvider = CreateArray();
	ItemIndex = 0;

	if(DataProvider == none)
	{
		return;
	}
	//DAILY ITEMS
	for (i = 0; i < 3; i++)
	{
		DataObject = CreateObject("Object");
		if(DataObject != none)
		{
			class'KFGFxDailyObjectivesContainer'.static.MakeDailyDataObject(KFPC.GetDailyObjective(i), i, KFPC, DataObject);
			if (DataObject == none)
			{
				continue;
			}
			DataProvider.SetElementObject(ItemIndex, DataObject);
			ItemIndex++;
		}
		
	}
	//end DAILY
	
	//get weekly
	if( KFPC.isA('KFPlayerController_WeeklySurvival') ||  class'WorldInfo'.static.IsMenuLevel())
	{
		DataObject = GetWeeklyDataObject();
		if (DataObject != none)
		{
			DataProvider.SetElementObject(ItemIndex, DataObject);
			ItemIndex++;
		}
	}

	//get special event
	SpecialEventClass = class'KFGfxMenu_StartGame'.static.GetSpecialEventClass(class'KFGameEngine'.static.GetSeasonalEventId());
	if(SpecialEventClass != none && SpecialEventClass != class'KFGFxSpecialeventObjectivesContainer')
	{
		for (i = 0; i < SpecialEventClass.default.SpecialEventObjectiveInfoList.length; i++)
		{
			DataObject = CreateObject("Object");
	        
	        DataObject.SetString("label", SpecialEventClass.default.SpecialEventObjectiveInfoList[i].TitleString);
	        DataObject.SetString("description", SpecialEventClass.default.SpecialEventObjectiveInfoList[i].DescriptionString);
	        
	        DataObject.SetString("iconPath", "img://"$SpecialEventClass.default.ObjectiveIconURLs[i]);

	        DataObject.SetBool("complete", KFPC.IsEventObjectiveComplete(i));
	        DataObject.SetBool("showProgress", SpecialEventClass.default.UsesProgressList[i]);
			
			if (SpecialEventClass.default.UsesProgressList[i])
			{
				SpecialEventClass.Static.GetObjectiveProgressValues(i, CurrentProgressValue, MaxProgressValue, ProgressCompletePercentage);
				DataObject.SetFloat("progress", ProgressCompletePercentage);
				DataObject.SetString("textValue", CurrentProgressValue $"/" $MaxProgressValue);
			}
	        DataProvider.SetElementObject(ItemIndex, DataObject); //add it to the array
	        ItemIndex++;
		}
	}
	SetObject("objectives", DataProvider);
}

function GFxObject GetWeeklyDataObject()
{
	local GFxObject DataObject;
	local KFWeeklyOutbreakInformation WeeklyInfo;
	local KFPlayerController KFPC;
	KFPC = KFPlayerController(GetPC());
	WeeklyInfo = class'KFMission_LocalizedStrings'.static.GetCurrentWeeklyOutbreakInfo();

	DataObject = CreateObject("Object");
	if(WeeklyInfo == none)
	{
		return DataObject;
	}
	DataObject.SetString("label", WeeklyInfo.FriendlyName);
	if(WeeklyInfo.DescriptionStrings.length > 0)
	{
		DataObject.SetString("description", WeeklyInfo.DescriptionStrings[0]@"\n"@WeeklyInfo.DescriptionStrings[1]);
	}
	DataObject.SetString("iconPath", "img://"$WeeklyInfo.IconPath);

	DataObject.SetBool("complete", KFPC.IsWeeklyEventComplete());
	DataObject.SetBool("showProgres", false);
	DataObject.SetFloat("progress", 0);
	DataObject.SetString("textValue", "");

	return DataObject;
}