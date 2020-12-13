//=============================================================================
// KFGFxHUD_PostRoundMenu
//=============================================================================
// Displays a list of teams on the server prints out a summar of the previous 
// round(s)
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//  - Zane Gholson 5/2/2016
//=============================================================================

class KFGFxHUD_PostRoundMenu extends GfxObject;

var KFGFxPostRoundContainer_Team TeamOneContainer;
var KFGFxPostRoundContainer_Team TeamTwoContainer;

var localized string RoundResultsString;
var localized string MatchResultsString;

var localized string SurvivorVictory;
var localized string ZEDVictory;

var localized string TieString;
var localized string YourTeamString;
var localized string OpposingTeamString;
var localized string MatchOnGoingString;

var KFTeamInfo_Human WinningTeam;

var KFGameReplicationInfo KFGRI;

function InitializeHUD()
{
	KFGRI = KFGameReplicationInfo(GetPC().WorldInfo.GRI);
	LocalizeText();
	DisplayProgress();
}

function LocalizeText()
{
	local GfxObject TextObject;

	TextObject = CreateObject("Object");

	TextObject.SetString("roundResultsTitle", RoundResultsString);
	TextObject.SetString("matchResultsTitle", MatchResultsString);

	SetObject("localizedText", TextObject);	
}

/** Ties the GFxClikWidget variables to the .swf components and handles events */
event bool WidgetInitialized(name WidgetName, name WidgetPath, GFxObject Widget)
{
	switch(WidgetName)
	{
		case 'roundOneContainer':
		if ( TeamOneContainer == none )
		{
			TeamOneContainer = KFGFxPostRoundContainer_Team(Widget);
			TeamOneContainer.TeamValue = 1;
			TeamOneContainer.TeamID = 1;
			TeamOneContainer.Initialize();
		}
		break;
		case 'roundTwoContainer':
		if ( TeamTwoContainer == none )
		{
			TeamTwoContainer = KFGFxPostRoundContainer_Team(Widget);
			TeamTwoContainer.TeamValue = 2;
			TeamTwoContainer.TeamID = 0;
			TeamTwoContainer.Initialize();
		}
		break;
	}
	return true;
}


function DisplayProgress()
{
	local GfxObject TextObject;
	
	local KFTeamInfo_Human Team1;
	local KFTeamInfo_Human Team2;

	Team1 = KFTeamInfo_Human(KFGRI.Teams[1]); //humans on final round
	Team2 = KFTeamInfo_Human(KFGRI.Teams[0]); //zeds  on final round

	TextObject = CreateObject("Object");

	if(KFGRI.bMatchVictory)
	{
		TextObject.SetString("roundResults", SurvivorVictory);
	}
	else
	{
		TextObject.SetString("roundResults", ZEDVictory);
		
	}

	if(KFGRI.GetCurrentRoundNumber() < 2 )
	{
		TextObject.SetString("matchResults", MatchOnGoingString);
	}
	else
	{
		if(Team1.TeamScoreDataPacket.RoundScore > Team2.TeamScoreDataPacket.RoundScore)
		{
			WinningTeam = Team1;
		}
		else if(Team1.TeamScoreDataPacket.RoundScore < Team2.TeamScoreDataPacket.RoundScore)
		{
			WinningTeam = Team2;
		}
		else
		{
			WinningTeam = none;
		}

		if(WinningTeam == none)
		{
			TextObject.SetString("matchResults", TieString);		
		}
		else
		{
			if(GetPC().PlayerReplicationInfo.GetTeamNum() == WinningTeam.TeamIndex)
			{
				TextObject.SetString("matchResults", YourTeamString);		
			}
			else
			{
				TextObject.SetString("matchResults", OpposingTeamString);		
			}
		}
	}
	
	

	SetObject("Data", TextObject);	
}

DefaultProperties
{
	//defaults
	SubWidgetBindings.Add((WidgetName="roundOneContainer",WidgetClass=class'KFGFxPostRoundContainer_Team'))
	SubWidgetBindings.Add((WidgetName="roundTwoContainer",WidgetClass=class'KFGFxPostRoundContainer_Team'))
}