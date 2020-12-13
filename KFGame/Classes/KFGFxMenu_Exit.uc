//=============================================================================
// KFGFxMenu_Exit
//=============================================================================
// This menu is used to show the player's options for leaving the game.
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//  Zane Gholson -  01/22/2015
//=============================================================================

class KFGFxMenu_Exit extends KFGFxObject_Menu;

enum ExitOptions
{
	EO_TO_Main_Menu,
	EO_TO_OS,
};

var localized string HeaderString;
var localized string ExitToMainDescription;
var localized string ExitToMainMenu;
var localized string ExitKF2;

var array<string> OptionStrings;

function InitializeMenu( KFGFxMoviePlayer_Manager InManager )
{
	super.InitializeMenu( InManager );
}

function OnOpen()
{
	SetExitOptions();
	HandleAutoExit();
}

function SetExitOptions()
{
	OptionStrings.Length = 0;
	OptionStrings.AddItem(ExitToMainMenu);
	if ( !class'WorldInfo'.static.IsConsoleBuild(CONSOLE_Orbis))
	{
		if( class'WorldInfo'.static.IsConsoleBuild( CONSOLE_Durango ) )
		{
			// XB1 has this option only for the menu level
			if( class'WorldInfo'.static.IsMenuLevel() )
			{
				OptionStrings.AddItem(ConsoleLocalize("LogoutKF2"));
			}
		}
		else
		{
			// Console shouldn't have exit to desktop option.
			OptionStrings.AddItem(ExitKF2);
		}
	}

	SetMenuText();
}

function SetMenuText()
{
	local byte i, ButtonCount;
	local GFxObject DataProvider, DataObject;
	local bool bMenuLevel;

	bMenuLevel =  class'WorldInfo'.static.IsMenuLevel();

	ButtonCount = 0;
	DataProvider = CreateArray();

	// XB1 change text to LOGOUT for menu level
	if( class'WorldInfo'.static.IsConsoleBuild(CONSOLE_Durango) && bMenuLevel )
	{
		DataProvider.SetString( "header",  ConsoleLocalize("HeaderStringXB1") );
	}
	else
	{
		DataProvider.SetString( "header",  HeaderString );
	}

	for( i = 0; i < OptionStrings.length; i++ )
	{
		DataObject = CreateObject( "Object" );
		DataObject.SetString( "label", OptionStrings[i] );
		DataObject.SetInt( "buttonID", i );
		if(OptionStrings[i] == ExitToMainMenu && bMenuLevel)
		{
			continue;
		}
		
		DataProvider.SetElementObject( ButtonCount, DataObject );
		ButtonCount++;
	}
	SetObject("buttonNames", DataProvider);
}

function Callback_MenuSelected( int MenuIndex )
{
	switch( MenuIndex )
	{
		case EO_TO_OS:
			ShowExitToOSPopUp();
		break;
		case EO_TO_Main_Menu:
			if(class'WorldInfo'.static.IsMenuLevel())
			{
				ShowExitToOSPopUp();
			}
			else
			{
				ShowLeaveGamePopUp();
			}
			
		break;
	}
}

function HandleAutoExit()
{
	if(Manager != none && !Manager.bUsingGamepad && class'WorldInfo'.static.IsMenuLevel())
	{
		ShowExitToOSPopUp();
	}
}

function ShowExitToOSPopUp()
{
	if(Manager != none && Manager.MenuBarWidget != none )
	{
		if( class'WorldInfo'.static.IsConsoleBuild(CONSOLE_Durango) )
		{
			Manager.MenuBarWidget.OpenLogoutPopup();
		}
		else
		{
			Manager.MenuBarWidget.OpenQuitPopUp();
		}
	}
}

function ShowLeaveGamePopUp()
{
	if(Manager != none )
	{
		Manager.DelayedOpenPopup(EConfirmation, EDPPID_Misc, ExitToMainMenu, ExitToMainDescription,
	 		Class'KFCommon_LocalizedStrings'.default.ConfirmString, Class'KFCommon_LocalizedStrings'.default.CancelString, OnLeaveGameConfirm);
	}	
}

function OnLeaveGameConfirm()
{
	if(!class'WorldInfo'.static.IsConsoleBuild())
	{
		ConfirmLeaveParty();
	}
	else if (!class'WorldInfo'.static.IsMenuLevel())
	{
		ConsoleCommand("Disconnect");
	}
}

defaultproperties
{

}