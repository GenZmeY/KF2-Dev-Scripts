class KFGFxMoviePlayer_Manager_Versus extends KFGFxMoviePlayer_Manager;

function ClientRecieveNewTeam()
{
	if(bMenusOpen)
	{
		if(CurrentMenu != none && CurrentMenu == GearMenu)
		{
			OpenMenu(UI_Start);
		}
		UpdateMenuBar();
	}
}


event bool WidgetInitialized(name WidgetName, name WidgetPath, GFxObject Widget)
{
	switch (WidgetName)
	{
		case ( 'MenuBarWidget' ):
			if ( MenuBarWidget == none )
			{
		        MenuBarWidget = KFGFxWidget_MenuBarVersus( Widget );
		        MenuBarWidget.InitializeMenu( self );
		        MenuBarWidget.InitializeCurrentMenu(UI_Start);
			}
		break;
		case ( 'partyWidget' ):
			if ( PartyWidget == none )
			{
	        	PartyWidget = KFGFxWidget_PartyInGame_Versus( Widget );
	        	if(GetPC().WorldInfo.GRI != none)
	        	{
	        		PartyWidget.StartCountdown(KFGameReplicationInfo(GetPC().WorldInfo.GRI).RemainingTime, false);
	        	}
		    	PartyWidget.Manager = self;
		        PartyWidget.InitializeWidget();
			}
		break;				
	}
	
	return super.WidgetInitialized(WidgetName, WidgetPath, Widget);
}

DefaultProperties
{
	InGamePartyWidgetClass=class'KFGFxWidget_PartyInGame_Versus'
	WidgetPaths.Remove("../UI_Widgets/PartyWidget_SWF.swf")
	WidgetPaths.Add("../UI_Widgets/VersusLobbyWidget_SWF.swf")
	WidgetBindings.Remove((WidgetName="MenuBarWidget",WidgetClass=class'KFGFxWidget_MenuBar'))
	WidgetBindings.Add((WidgetName="MenuBarWidget",WidgetClass=class'KFGFxWidget_MenuBarVersus'))
}