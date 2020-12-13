//=============================================================================
// KFGFxMoviePlayer_Tutorial
//=============================================================================
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//  - Zane Gholson 4/21/2016
//=============================================================================

class KFGFxMoviePlayer_ScreenSize extends GFxMoviePlayer;

`include(KFProfileSettings.uci)

var name SoundThemeName;
var bool bUsingGamepad;
var GFxObject ManagerObject;
var KFGFxMoviePlayer_Manager GFxMenuManager;
var KFPlayerController KFPC;
var const float AdjustMovePercentage;
var const float SafeFrameMinScale;
var KFGameEngine KFEngine;
var KFProfileSettings Profile;

var KFGFxScreenSizeContainer ScreenSizeContainer;

function Init(optional LocalPlayer LocPlay)
{
	super.Init(LocPlay);
	
	KFPC = KFPlayerController(GetPC());
	GFxMenuManager = KFPC.MyGFxManager;
	KFEngine = KFGameEngine(class'Engine'.static.GetEngine());
	Profile = GFxMenuManager.CachedProfile;
}


/** Ties the GFxClikWidget variables to the .swf components and handles events */
event bool WidgetInitialized(name WidgetName, name WidgetPath, GFxObject Widget)
{
	local bool bHandled;
	`log("widgetname: " @WidgetName);
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
		case ( 'screenSizePopup' ):
			if ( ScreenSizeContainer == none )
			{
				ScreenSizeContainer = KFGFxScreenSizeContainer(Widget);
				ScreenSizeContainer.InitMenu();
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


function NotifyControllerDisconnected()
{
	SetVisibility(false);
	SetPriority(1);
	GFxMenuManager.SetPriority(2);
}


function NotifyControllerReconnected()
{
	SetVisibility(true);
	SetPriority(2);
	GFxMenuManager.SetPriority(1);
}

function Callback_Enlarge()
{
	KFEngine.SafeFrameScale += AdjustMovePercentage;
	KFEngine.SafeFrameScale = FClamp( KFEngine.SafeFrameScale, SafeFrameMinScale, 1.0f );
}

function Callback_Shrink()
{
	KFEngine.SafeFrameScale -= AdjustMovePercentage;
	KFEngine.SafeFrameScale = FClamp(KFEngine.SafeFrameScale, SafeFrameMinScale, 1.0f);
}

function Callback_Confirm()
{
	SaveAndClose();
}

function Callback_Cancel()
{
	//SaveAndClose(); //do not want to use B button
}


function SaveAndClose()
{
	Profile.SetProfileSettingValueFloat(KFID_SafeFrameScale, KFEngine.SafeFrameScale);
	Profile.Save( GetLP().ControllerId );
	GFxMenuManager.CloseScreenSizeMovie();
}

defaultproperties
{
    MovieInfo=SwfMovie'UI_ScreenSize.ScreenSizeManager_SWF'
	bAutoPlay=true

	AdjustMovePercentage=0.005
	SafeFrameMinScale=0.85

	bCaptureInput=true
	bCaptureMouseInput=true
	CaptureKeys=(XboxTypeS_A, XboxTypeS_B, XboxTypeS_DPad_Left, XboxTypeS_DPad_Up, XboxTypeS_DPad_Down, XboxTypeS_DPad_Right, XboxTypeS_LeftTrigger, XboxTypeS_RightTrigger)

	SoundThemeName=ButtonSoundTheme
	SoundThemes.Add((ThemeName="ButtonSoundTheme",Theme=UISoundTheme'SoundsShared_UI.SoundTheme_Buttons'))
	SoundThemes.Add((ThemeName="UI",Theme=UISoundTheme'SoundsShared_UI.SoundTheme_UI'))

	// Widgets
	WidgetBindings.Add((WidgetName="screenSizePopup",WidgetClass=class'KFGFxScreenSizeContainer'))
}