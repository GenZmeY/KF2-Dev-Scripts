//=============================================================================
// KFGFxOptionsMenu_Selection
//=============================================================================
// Class Description
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//  Greg Felber -  9/10/2014
//=============================================================================

class KFGFxOptionsMenu_Selection extends KFGFxObject_Menu;

enum OptionMenus
{
	OM_Video,
	OM_Audio,
	OM_Controls,
	OM_Gameplay,
	OM_Credits,
	OM_Max,
};

var KFGFxControlsContainer_Keybinding KeybindingsContainer;
var KFGFxControlsContainer_Input InputContainer;

var localized string HeaderString;
var localized array<string> OptionStrings;

function InitializeMenu( KFGFxMoviePlayer_Manager InManager )
{
	local byte i;
	local GFxObject DataProvider, DataObject;
	local array<string> DisplayedOptions;
	local PlayerController PC;

	super.InitializeMenu( InManager );
	
	PC = GetPC();
	DataProvider = CreateArray();
	DataProvider.SetString( "header", HeaderString );
	DisplayedOptions = OptionStrings;
	if ( PC != None && PC.WorldInfo != None )
	{
		// On console we combine video and audio options so make sure the string shows that correctly.
		if ( PC.WorldInfo.IsConsoleBuild() )
		{
			// No Video
			DisplayedOptions.Remove(OM_Video,1);
			DisplayedOptions[0] = OptionStrings[1]$"/"$OptionStrings[0];
		}

		// Remove the Credits option when in game instead of disabling it.
		if ( !PC.WorldInfo.IsMenuLevel() )
		{
			DisplayedOptions.Remove(DisplayedOptions.length-1,1);
		}
	}

	for( i = 0; i < DisplayedOptions.length; i++ )
	{
		DataObject = CreateObject( "Object" );
		DataObject.SetString( "label", DisplayedOptions[i] );
		DataProvider.SetElementObject( i, DataObject );		
	}
	SetObject("buttonNames", DataProvider);
}


function Callback_MenuSelected( int MenuIndex )
{
	// Since the console doesn't have Video we need to increase the menuIndex to account for that.
	if(class'WorldInfo'.static.IsConsoleBuild())
	{
		MenuIndex++;
	}
	switch( MenuIndex )
	{
		case OM_Video:
			Manager.OpenMenu( UI_OptionsGraphics );
		break;
		case OM_Audio:
			Manager.OpenMenu( UI_OptionsAudio );
		break;
		case OM_Controls:
			Manager.OpenMenu( UI_OptionsControls );
		break;
		case OM_Gameplay:
			Manager.OpenMenu( UI_OPtionsGameSettings );
		break;
		case OM_Credits:
			//selectContainer is called in AS3 and to give mouse input back to this menu since a bink movie is opened instead or another menu.
			ActionScriptVoid("selectContainer");
			class'KFGameEngine'.static.PlayFullScreenMovie("Credits"); //"Credits" refers to Credits.bink.  This is added in DefaultEngine.ini [FullScreeMovies]
		break;
	}
}

defaultproperties
{
	SubWidgetBindings.Add((WidgetName="keybindingsContainer",WidgetClass=class'KFGFxControlsContainer_Keybinding'))
	SubWidgetBindings.Add((WidgetName="inputContainer",WidgetClass=class'KFGFxControlsContainer_Input'))
}