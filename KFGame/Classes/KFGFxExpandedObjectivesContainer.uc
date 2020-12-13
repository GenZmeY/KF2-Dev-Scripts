//=============================================================================
// KFGFxExpandedObjectivesContainer
//=============================================================================
// This will be the parent container for the weekly and special event container
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//  - Zane Gholson 3/28/2017
//=============================================================================

class KFGFxExpandedObjectivesContainer extends KFGFxObject_Container;

var KFGFxSpecialeventObjectivesContainer 	SpecialEventsContainer;
var KFGFxWeeklyObjectivesContainer 			WeeklyEventContainer;
var KFGFxDailyObjectivesContainer           DailyObjectiveContainer;

var KFGfxMenu_StartGame StartMenu;

function Initialize( KFGFxObject_Menu NewParentMenu )
{
    super.Initialize( NewParentMenu );

    StartMenu = KFGfxMenu_StartGame(NewParentMenu);
    
    LocalizeMenu(); //if need be
    StartMenu.MissionObjectiveContainer.UpdateSpecialEventActive();
}

//returns true is data is changed
function bool Refresh(optional bool bForceRefresh)
{   
	local bool bRefreshedSpecialEvents, bRefreshedWeeklyEvent, bRefreshedDailyObjective;

	if(SpecialEventsContainer != none && WeeklyEventContainer != none)
    {
		bRefreshedSpecialEvents = SpecialEventsContainer.PopulateData();
		bRefreshedWeeklyEvent = WeeklyEventContainer.PopulateData();
		bRefreshedDailyObjective = DailyObjectiveContainer.PopulateData(bForceRefresh);
		return bRefreshedSpecialEvents || bRefreshedWeeklyEvent || bRefreshedDailyObjective;
    }

    return false;
}

function FullRefresh()
{
	if (SpecialEventsContainer != None)
	{
		SpecialEventsContainer.Initialize(StartMenu);
	}

	if (WeeklyEventContainer != None)
	{
		WeeklyEventContainer.Initialize(StartMenu);
	}

	if (DailyObjectiveContainer  != None)
	{
		DailyObjectiveContainer.Initialize(StartMenu);
	}
}

function LocalizeMenu()
{
    local GFxObject TextObject;
    TextObject = CreateObject("Object");
    // Localize static text
    TextObject.SetString("specialEvent",	class'KFMission_LocalizedStrings'.default.SeasonalString);  
    TextObject.SetString("daily",			class'KFMission_LocalizedStrings'.default.DailyObjectiveString);  
    TextObject.SetString("weekly",          class'KFMission_LocalizedStrings'.default.ShortWeeklyString);  
    SetObject("localizedText", TextObject);
}