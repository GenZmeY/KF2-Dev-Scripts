class KFGFxMoviePlayer_PostRoundMenu extends GFxMoviePlayer;

// Widget for the in-game Scoreboard
var KFGFxHUD_PostRoundMenu PostRoundMenu;

function Init(optional LocalPlayer LocPlay)
{
	SetTimingMode(TM_Real);
	LocalPlayerOwnerIndex = class'Engine'.static.GetEngine().GamePlayers.Find(LocPlay);
	if(LocalPlayerOwnerIndex == INDEX_NONE)
	{
		LocalPlayerOwnerIndex = 0;
	}
	if( MovieInfo != None )
	{
		if( bAutoPlay )
		{
			Start();
			Advance(0.f);
		}
	}
}

/** Ties the GFxClikWidget variables to the .swf components and handles events */
event bool WidgetInitialized(name WidgetName, name WidgetPath, GFxObject Widget)
{
	switch(WidgetName)
	{
		case 'midGameMenuMC':
		if ( PostRoundMenu == none )
		{
			PostRoundMenu = KFGFxHUD_PostRoundMenu(Widget);
			PostRoundMenu.InitializeHUD();
			SetWidgetPathBinding( Widget, WidgetPath );
		}
		break;
	}
	return true;
}

function Callback_WinnerAnimationComplete()
{
	if(PostRoundMenu.WinningTeam == none)		
	{
		return;
	}
	if(PostRoundMenu.WinningTeam.TeamIndex == GetPC().PlayerReplicationInfo.GetTeamNum())
	{
		class'KFMusicStingerHelper'.static.PlayMatchWonStinger( GetPC() );
	}
	else
	{
		class'KFMusicStingerHelper'.static.PlayMatchLostStinger( GetPC() );
	}
}

DefaultProperties
{
	MovieInfo=SwfMovie'UI_Managers.MidGameMenuManager_SWF'

	Priority = 2

	bAllowFocus=true
	bCaptureInput=false
	bAllowInput=true
	bDisplayWithHudOff=true
	bAutoPlay=true

	WidgetBindings.Add((WidgetName="midGameMenuMC",WidgetClass=class'KFGFxHUD_PostRoundMenu'))
	//WidgetBindings.Add((WidgetName="ZEDScoreboardWidgetMC",WidgetClass=class'KFGFxHUD_ScoreboardVersusWidget'))
}