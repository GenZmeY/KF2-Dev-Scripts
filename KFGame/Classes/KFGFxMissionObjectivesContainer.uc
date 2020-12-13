//=============================================================================
// KFGFxMissionObjectivesContainer
//=============================================================================
// This container has the collapsed and expanded holders for the objectives.
// The expanded will contain the weekly and special event containers. 
// instead of using a subwidget bind, we are going to use get child here.
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//  - Zane Gholson 3/28/2017
//=============================================================================

class KFGFxMissionObjectivesContainer extends KFGFxObject_Container;

var KFGFxCollapsedObjectivesContainer CollapsedObjectiveContainer;

var KFGFxExpandedObjectivesContainer ExpandedObjectiveContainer;

var bool bInitialAutoExpandCheckComplete;
var bool bLastShowSpecialEvent;
var bool bLastShowWeekly;
var KFPlayerController KFPC;

function Initialize( KFGFxObject_Menu NewParentMenu )
{
    super.Initialize( NewParentMenu );

    KFPC = KFPlayerController(GetPC());
    //expanded on delay to ensure all widget are initialized
    KFPC.SetTimer( 0.25f, true, nameof(UpdateMissionObjectiveState), self );
}

function UpdateMissionObjectiveState()
{
    local bool bShouldShow;
    local bool bShouldExpand;
    local int TargetPage;
    local bool bShowWeekly;
    local bool bShowSpecialEvent;    

    bShouldExpand = false;
    TargetPage = 0;
    bShouldShow = true;

    bShowWeekly = KFPC != none && KFPC.isA('KFPlayerController_WeeklySurvival') || class'WorldInfo'.static.IsMenuLevel();
    bShowSpecialEvent = ShowShouldSpecialEvent();

    if(!bInitialAutoExpandCheckComplete || bShowWeekly != bLastShowWeekly)
    {
        if(bShowWeekly)
        {
            //auto expand to weekly1
            bShouldExpand = true;
            
            TargetPage = 1;
            SetBool("expanded", true);
        }
        else //shows by default. 
        {
            UpdateWeeklyUIActive(false);
        }    
        bLastShowWeekly = bShowWeekly;
    }

    if(bShowSpecialEvent != bLastShowSpecialEvent || !bInitialAutoExpandCheckComplete )//on seasonal map and seasonal active
    {
        if(bShowSpecialEvent)
        {
            bShouldExpand = true;
            TargetPage = 2;
        }
        
        bLastShowSpecialEvent = bShowSpecialEvent;
        UpdateSpecialEventActive();
    }

    if(class'WorldInfo'.static.IsMenuLevel()) //main menu
    {
        bShouldExpand = false;
        TargetPage = 0;
    }

    if(!bInitialAutoExpandCheckComplete)
    {
        ExpandedObjectiveContainer.SetInt("pageIndex", TargetPage);
        SetVisible(bShouldShow);
        SetBool("expanded", bShouldExpand);
        SetString("buttonPromptString", class'KFMission_LocalizedStrings'.default.ObjectivesString);
    }
    
    bInitialAutoExpandCheckComplete = true;
    Refresh();
}

function UpdateWeeklyUIActive(bool bShow)
{
    SetBool("weeklyEventActive", bShow);
}

function UpdateSpecialEventActive()
{
    setbool("seasonalEventActive" , ShowShouldSpecialEvent());
}

function bool ShowShouldSpecialEvent()
{
    return class'KFGameEngine'.static.GetSeasonalEventId() != SEI_None 
            && class'KFGameEngine'.static.GetSeasonalEventId() != INDEX_NONE 
            && class'KFGfxMenu_StartGame'.static.GetSpecialEventClass(class'KFGameEngine'.static.GetSeasonalEventId()) != class'KFGFxSpecialEventObjectivesContainer'
            && ( KFPC.SeasonalEventIsValid() || class'WorldInfo'.static.IsMenuLevel() );
}

function Refresh(optional bool bForceRefresh)
{
    if(KFPC.MyGFxManager.bMenusOpen)
    {
        if(ExpandedObjectiveContainer.Refresh(bForceRefresh))
        {
            CollapsedObjectiveContainer.PopulateData();
        }
    }
}

function FullRefresh()
{
	ExpandedObjectiveContainer.FullRefresh();
	CollapsedObjectiveContainer.PopulateData();
}

/*function LocalizeMenu()
{
    local GFxObject TextObject;
    TextObject = CreateObject("Object");
    // Localize static text
    TextObject.SetString("home",StartMenu.FindGameString);  
    TextObject.SetString("multiplayer",MultiplayerString);  
    TextObject.SetString("serverBrowser",StartMenu.ServerBrowserString);    
    TextObject.SetString("solo",SoloString);    
    TextObject.SetString("tutorial",TutorialString);
    SetObject("localizedText", TextObject);
}*/

DefaultProperties
{
	
}