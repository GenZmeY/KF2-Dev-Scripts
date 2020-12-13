//=============================================================================
// KFGFxMoviePlayer_Tutorial
//=============================================================================
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//  - Zane Gholson 4/21/2016
//=============================================================================

class KFGFxMoviePlayer_Tutorial extends GFxMoviePlayer;

var name SoundThemeName;
var KFGFxTutorialContainer TutorialContainer;
var Array<STutorialSlide> TargetTutorialArray;
var KFGameInfo_Tutorial KFGI;
var KFTutorialSectionInfo TutorialSectionInfo;

var bool bUsingGamepad;
var GFxObject ManagerObject;

function Init(optional LocalPlayer LocPlay)
{
	super.Init(LocPlay);
	KFGI = KFGameInfo_Tutorial(GetPC().WorldInfo.Game);
}


/** Ties the GFxClikWidget variables to the .swf components and handles events */
event bool WidgetInitialized(name WidgetName, name WidgetPath, GFxObject Widget)
{
	local bool bHandled;

	bHandled = true;

	switch ( WidgetName )
	{
		case ( 'root1' ):
			if ( ManagerObject == none )
			{
				ManagerObject = Widget;
				// Let the menuManager know if we are on console.
				if ( class'WorldInfo'.static.IsConsoleBuild() )
				{
					ManagerObject.SetBool("bUsingGamepad", true);
				}
			}
		break;
		case ( 'tutorialPopup' ):
			if ( TutorialContainer == none )
			{
				TutorialContainer = KFGFxTutorialContainer(Widget);
				TutorialContainer.InitMenu();
				if(TargetTutorialArray.length > 0)
				{
					TutorialContainer.SetPopUpData(TargetTutorialArray);
				}
			}
		break;
		default:
			bHandled = false;
	}

	return bHandled;
}


/* This is only used for the controller to switch between different components in the trader menu
 and open / close the perk selector */
event bool FilterButtonInput(int ControllerId, name ButtonName, EInputEvent InputEvent)
{
	if ( !class'WorldInfo'.static.IsConsoleBuild() )
	{
		CheckIfUsingGamepad();
	}

 	return false;
}

// Checks if our form of input has changed
function CheckIfUsingGamepad()
{
	local bool bGamepad;
	
    bGamepad = GetUsingGamepad();
	if ( bUsingGamepad != bGamepad )
	{
		OnInputTypeChanged(bGamepad);
	}
}

function OnInputTypeChanged(bool bGamePad)
{
	bUsingGamepad = bGamepad;
	if(ManagerObject != none)
	{
		ManagerObject.SetBool("bUsingGamepad", bGamePad);
	}	
}

/** Return whether the player input says we are currently using the gamepad */
function bool GetUsingGamepad()
{
	local PlayerController PC;
	PC = GetPC();

	if( class'WorldInfo'.static.IsConsoleBuild() )
	{
		return true;
	}

    if ( PC == none || PC.PlayerInput == none )
	{
		return false;
	}
	// Always using the gamepad if we are on console.
    return PC.PlayerInput.bUsingGamepad;
}

function Callback_Done()
{
	if(KFGI != none)
	{
		KFGI.RemoveTutorialHud();
	}
}

function Callback_Skip()
{
	if(KFGI != none)
	{
		KFGI.RemoveTutorialHud();
	}
}

defaultproperties
{
    MovieInfo=SwfMovie'UI_Tutorial.TutorialManager_SWF'
	bAutoPlay=true

	bCaptureInput=true
	bCaptureMouseInput=true
	CaptureKeys=(XboxTypeS_A, XboxTypeS_B, XboxTypeS_DPad_Left, XboxTypeS_DPad_Right, XboxTypeS_LeftTrigger, XboxTypeS_RightTrigger)

	SoundThemeName=ButtonSoundTheme
	SoundThemes.Add((ThemeName="ButtonSoundTheme",Theme=UISoundTheme'SoundsShared_UI.SoundTheme_Buttons'))
	SoundThemes.Add((ThemeName="UI",Theme=UISoundTheme'SoundsShared_UI.SoundTheme_UI'))

	// Widgets
	WidgetBindings.Add((WidgetName="tutorialPopup",WidgetClass=class'KFGFxTutorialContainer'))
}