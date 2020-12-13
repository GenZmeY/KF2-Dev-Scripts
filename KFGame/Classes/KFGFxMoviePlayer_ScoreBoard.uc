class KFGFxMoviePlayer_ScoreBoard extends GFxMoviePlayer;

// Widget for the in-game Scoreboard
var KFGFxHUD_ScoreboardWidget ScoreboardWidget;
var KFGFxHUD_ScoreboardVersusWidget ZEDScoreboardWidget;

// Interval between updates.  Higher values mean less frequent updates.
var const float UpdateInterval;
// Last time we performed an update.
var Protected float LastUpdateTime;

var SwfMovie MovieInfoStandard;
var SwfMovie MovieInfoVersus;

function Init(optional LocalPlayer LocPlay)
{
	LocalPlayerOwnerIndex = class'Engine'.static.GetEngine().GamePlayers.Find(LocPlay);
	if(LocalPlayerOwnerIndex == INDEX_NONE)
	{
		LocalPlayerOwnerIndex = 0;
	}
	if(KFGameReplicationInfo(GetPC().WorldInfo.GRI) != none)
	{
		MovieInfo = GetMovieInfo();

		if( MovieInfo != None )
		{
			if( bAutoPlay )
			{
				Start();
				Advance(0.f);
			}
		}
	}
}

function SwfMovie GetMovieInfo()
{
	if(KFGameReplicationInfo(GetPC().WorldInfo.GRI).bVersusGame)
	{
		return MovieInfoVersus;
	}
	
	return MovieInfoStandard;
}

/** Ties the GFxClikWidget variables to the .swf components and handles events */
event bool WidgetInitialized(name WidgetName, name WidgetPath, GFxObject Widget)
{
	switch(WidgetName)
	{
		case 'ScoreboardWidgetMC':
		if ( ScoreboardWidget == none )
		{
			ScoreboardWidget = KFGFxHUD_ScoreboardWidget(Widget);
			ScoreboardWidget.InitializeHUD();
			SetWidgetPathBinding( Widget, WidgetPath );
		}
		break;
		case 'ZEDScoreboardWidgetMC':
		if ( ZEDScoreboardWidget == none )
		{
			ZEDScoreboardWidget = KFGFxHUD_ScoreboardVersusWidget(Widget);
			ZEDScoreboardWidget.InitializeHUD();
			SetWidgetPathBinding( Widget, WidgetPath );
		}
		break;
	}
	return true;
}

/** Update all the unique HUD pieces */
function TickHud(float DeltaTime)
{
	local PlayerController PC;

	PC = GetPC();

	if(PC == none || PC.WorldInfo.TimeSeconds - LastUpdateTime < UpdateInterval )
    {
    	return;
    }

    if(!PC.MyHUD.bShowHUD)
    {
    	return;
    }

    LastUpdateTime = PC.WorldInfo.TimeSeconds;   // throttle the updates so we're not spamming Actionscript with data.

	if(ScoreboardWidget != none && ScoreboardWidget.bUpdateScoreboard )
	{
		ScoreboardWidget.TickHUD(DeltaTime);
	} 
	if(ZEDScoreboardWidget != none && ZEDScoreboardWidget.bUpdateScoreboard )
	{
		ZEDScoreboardWidget.TickHUD(DeltaTime);
	} 
}

function ShowScoreboard(bool newShowScoreboard)
{
	if(ScoreboardWidget  != none)
	{
		ScoreboardWidget.SetOpen(newShowScoreboard);
		ScoreboardWidget.bUpdateScoreboard = newShowScoreboard;
	}
	if(ZEDScoreboardWidget  != none)
	{
		ZEDScoreboardWidget.SetOpen(newShowScoreboard);
		ZEDScoreboardWidget.bUpdateScoreboard = newShowScoreboard;
	}
}

function UpdateWaveCount()
{
	if(ScoreboardWidget != none && ScoreboardWidget.MatchInfoContainer != none)
	{
		
	}
}

DefaultProperties
{
	MovieInfoStandard=SwfMovie'UI_HUD.ScoreBoard_Standard_SWF'
	MovieInfoVersus=SwfMovie'UI_HUD.ScoreBoard_Versus_SWF'

	Priority = 2

	bAllowFocus=false
	bCaptureInput=false
	bAllowInput=false
	bDisplayWithHudOff=false
	bAutoPlay=true

	WidgetBindings.Add((WidgetName="ScoreboardWidgetMC",WidgetClass=class'KFGFxHUD_ScoreboardWidget'))
	WidgetBindings.Add((WidgetName="ZEDScoreboardWidgetMC",WidgetClass=class'KFGFxHUD_ScoreboardVersusWidget'))
}