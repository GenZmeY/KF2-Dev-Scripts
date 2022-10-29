//=============================================================================
// KFGFxOptionsMenu_Controls
//=============================================================================
// Class Description
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//  Greg Felber -  9/10/2014
//=============================================================================

class KFGFxOptionsMenu_Controls extends KFGFxObject_Menu;

`include(KFProfileSettings.uci)

var KFGFxControlsContainer_Keybinding KeybindingsContainer;
var KFGFxControlsContainer_Input InputContainer;
var KFGFxControlsContainer_ControllerPresets ControllerPresetsContainer;

var const float MinControllerLookSensitivity;
var const float MaxControllerLookSensitivity;
var const float MinControllerZoomLookSensitivity;
var const float MaxControllerZoomLookSensitivity;
var const float MinControllerDeadzone;
var const float MaxControllerDeadzone;
var const float MinControllerAccelerationJump;
var const float MaxControllerAccelerationJump;
var const float MinMouseLookSensitivity;
var const float MaxMouseLookSensitivity;
var const float MinMouseLookZoomSensitivity;
var const float MaxMouseLookZoomSensitivity;
var const float MinMouseLookUpScale;
var const float MaxMouseLookUpScale;
var const float MinMouseLookRightScale;
var const float MaxMouseLookRightScale;

var localized array<string> TabStrings;
var localized string HeaderText;
function InitializeMenu( KFGFxMoviePlayer_Manager InManager )
{
	super.InitializeMenu( InManager );
	LocalizeText();
}

function LocalizeText()
{
	local byte i;
	local GFxObject DataProvider, DataObject;
	local GFxObject LocalizedObject;
	local array<string> DisplayedStrings;
	
	DataProvider = CreateArray();
	DisplayedStrings = TabStrings;

	// Removing the keybindings option.
	if( GetPC().WorldInfo.IsConsoleBuild() )
	{
		DisplayedStrings.Remove(1,1);
	}
	for( i = 0; i < DisplayedStrings.length; i++ )
	{
		DataObject = CreateObject( "Object" );
		DataObject.SetString( "label", DisplayedStrings[i] );
		DataProvider.SetElementObject( i, DataObject );
	}

	SetObject("tabStrings", DataProvider);

	LocalizedObject = CreateObject("Object");

	LocalizedObject.SetString("header", Caps(class'KFGFxOptionsMenu_Selection'.default.OptionStrings[OM_Controls]));
	LocalizedObject.SetString("close", Class'KFCommon_LocalizedStrings'.default.BackString);

	SetObject("localizedText", LocalizedObject);

}

function OnInputTypeChanged(bool bGamePad)
{
	if(KeybindingsContainer != none)
	{
		KeybindingsContainer.UpdateAllBindings();
	}
}

/** Ties unrealscript variables to the .swf components */
event bool WidgetInitialized(name WidgetName, name WidgetPath, GFxObject Widget)
{
	//`log("Frontend Widget: " @WidgetName @" : " @WidgetPath);

	switch(WidgetName)
	{
        case ('keybindingsContainer'):
			if ( KeybindingsContainer == none )
			{
			    KeybindingsContainer = KFGFxControlsContainer_Keybinding( Widget );
			    KeybindingsContainer.Initialize( self );
		    }
        break;
        case ('controllerPresetsContainer'):
			if ( ControllerPresetsContainer == none )
			{
			    ControllerPresetsContainer = KFGFxControlsContainer_ControllerPresets( Widget );
			    ControllerPresetsContainer.Initialize( self );
		    }
        break;
        case ('inputContainer'):
			if ( InputContainer == none )
			{
				//`log(`location@" case ('inputContainer') ");
			    InputContainer = KFGFxControlsContainer_Input( Widget );
			    InputContainer.Initialize( self );
		    }
        break;
	}

	return true;
}

function OnOpen()
{
 	if( KeybindingsContainer != none )
 	{
 		KeybindingsContainer.UpdateAllBindings();
 	}
}

event OnClose()
{
	if( KeybindingsContainer != none )
 	{
 		KeybindingsContainer.ClearInputOnContainer();
 	}	
 	SaveConfigValues();
}

//Do this when we close the menu so that we do not constantly write to the config.
function SaveConfigValues()
{
	local KFPlayerInput KFPI;

	KFPI = KFPlayerInput(GetPC().PlayerInput);	
	KFPI.SaveConfig();
}

/** Detects any input and passes it to the active view*/
event bool FilterButtonInput(int ControllerId, name ButtonName, EInputEvent InputEvent)
{
	if( KeybindingsContainer != none )
 	{
 		KeybindingsContainer.BindKey( ButtonName, InputEvent );
 	}
	return super.FilterButtonInput( ControllerId, ButtonName, InputEvent );
}


function Callback_ControllerSensitivity( float NewSensitivity )
{
	local KFPlayerInput KFPI;

	KFPI = KFPlayerInput(GetPC().PlayerInput);

	KFPI.GamepadSensitivityScale = NewSensitivity / 100;
	Manager.CachedProfile.SetProfileSettingValueFloat(KFID_GamepadSensitivityScale, KFPI.GamepadSensitivityScale);
}

function Callback_ControllerZoomSensitivity( float NewSensitivity )
{
	local KFPlayerInput KFPI;

	KFPI = KFPlayerInput(GetPC().PlayerInput);

	KFPI.GamepadZoomedSensitivityScale = NewSensitivity / 100;
	Manager.CachedProfile.SetProfileSettingValueFloat(KFID_GamepadZoomedSensitivityScale, KFPI.GamepadZoomedSensitivityScale);
}

function Callback_ControllerDeadzone( float NewDeadzone )
{
	local KFPlayerInput KFPI;

	KFPI = KFPlayerInput(GetPC().PlayerInput);

	KFPI.GamepadDeadzoneScale = NewDeadzone / 100;
	Manager.CachedProfile.SetProfileSettingValueFloat(KFID_GamepadDeadzoneScale, KFPI.GamepadDeadzoneScale);
}

function Callback_ControllerAccelerationJump( float NewAccelerationJump )
{
	local KFPlayerInput KFPI;

	KFPI = KFPlayerInput(GetPC().PlayerInput);

	KFPI.GamepadAccelerationJumpScale = NewAccelerationJump / 100;
	Manager.CachedProfile.SetProfileSettingValueFloat(KFID_GamepadAccelerationJumpScale, KFPI.GamepadAccelerationJumpScale);
}

function Callback_ControllerInvertChanged( bool bInvertController )
{
	local KFPlayerInput KFPI;

	KFPI = KFPlayerInput(GetPC().PlayerInput);
	KFPI.bInvertController = bInvertController;
	Manager.CachedProfile.SetProfileSettingValueInt(KFID_InvertController, KFPI.bInvertController ? 1: 0);
}

function Callback_MouseSensitivity( float NewSensitivity )
{
	GetPC().PlayerInput.SetSensitivity( NewSensitivity );
}

function Callback_MouseZoomSensitivity( float NewSensitivity )
{
	KFPlayerInput(GetPC().PlayerInput).SetZoomedSensitivity( NewSensitivity / 100 );
}

function Callback_InvertChanged( bool bInvertMouse )
{
	GetPC().PlayerInput.bInvertMouse = bInvertMouse;
}

function Callback_MouseSmoothingChanged( bool NewValue )
{
	local KFPlayerInput KFPI;

	KFPI = KFPlayerInput(GetPC().PlayerInput);

	KFPI.bEnableMouseSmoothing = NewValue;
}

function Callback_AimAssistZoomLockOnChanged( bool NewValue )
{
	local KFPlayerInput KFPI;

	KFPI = KFPlayerInput(GetPC().PlayerInput);

	KFPI.bAutoTargetEnabled = NewValue;

	Manager.CachedProfile.SetProfileSettingValueInt(KFID_AutoTargetEnabled, KFPI.bAutoTargetEnabled ? 1: 0);
}

function Callback_AimAssistRotationChanged( bool NewValue )
{
	local KFPlayerInput KFPI;

	KFPI = KFPlayerInput(GetPC().PlayerInput);

	KFPI.bTargetAdhesionEnabled = NewValue;
	Manager.CachedProfile.SetProfileSettingValueInt(KFID_TargetAdhesionEnabled, KFPI.bTargetAdhesionEnabled ? 1: 0);
}

function Callback_AimAssistSlowDownChanged( bool NewValue )
{
	local KFPlayerInput KFPI;

	KFPI = KFPlayerInput(GetPC().PlayerInput);

	KFPI.bTargetFrictionEnabled = NewValue;
	Manager.CachedProfile.SetProfileSettingValueInt(KFID_TargetFrictionEnabled, KFPI.bTargetFrictionEnabled ? 1: 0);

}

function Callback_ForceFeedbackChanged( bool NewValue )
{
	local KFPlayerInput KFPI;

	KFPI = KFPlayerInput(GetPC().PlayerInput);
	KFPI.bForceFeedbackEnabled = NewValue;	
	Manager.CachedProfile.SetProfileSettingValueInt(KFID_ForceFeedbackEnabled , KFPI.bForceFeedbackEnabled ? 1: 0);
}


function Callback_ChangeBind( string ChangedCommand, byte SelectedSection )
{
	if( KeybindingsContainer != none )
 	{
 		KeybindingsContainer.ChangeBind( ChangedCommand, SelectedSection );
 	}
}

function Callback_ResetControls()
{
	if( KeybindingsContainer != none )
 	{
 		KeybindingsContainer.ResetControls();
 	}
}

function Callback_AcceptBind()
{
	if( KeybindingsContainer != none )
 	{
 		KeybindingsContainer.AcceptBind();
 	}
}

function Callback_CloseMenu()
{
	Manager.OpenMenu( UI_OptionsSelection );

	Manager.CachedProfile.Save( GetLP().ControllerId );
}

function Callback_UpdateControllerPreset(int PresetIndex)
{
	if(ControllerPresetsContainer != none)
	{
		ControllerPresetsContainer.UpdateCurrentPresetArray(PresetIndex);
		Manager.CachedProfile.SetProfileSettingValueInt(KFID_CurrentLayoutIndex, PresetIndex);
	}
}

function CallBack_ResetPresetOptions()
{
	if(ControllerPresetsContainer != None)
	{
		Manager.DelayedOpenPopup( EConfirmation, EDPPID_Misc,
			Localize("KFGFxOptionsMenu_Graphics","WarningPromptString","KFGame"), 
			Localize("KFGFxObject_Menu","ResetDefaults","KFGameConsole"),
			Localize("KFGFxOptionsMenu_Graphics","OKString","KFGame"),
			Localize("KFGFxOptionsMenu_Graphics","CancelString","KFGame"),
			controllerPresetsContainer.ResetPresetOptions);
	}
}

function CallBack_ResetInputOptions()
{
	if(InputContainer != None)
	{
		Manager.DelayedOpenPopup( EConfirmation, EDPPID_Misc,
			Localize("KFGFxOptionsMenu_Graphics","WarningPromptString","KFGame"), 
			Localize("KFGFxObject_Menu","ResetDefaults","KFGameConsole"),
			Localize("KFGFxOptionsMenu_Graphics","OKString","KFGame"),
			Localize("KFGFxOptionsMenu_Graphics","CancelString","KFGame"),
			InputContainer.ResetInputOptions);
	}
}

function Callback_MouseLookUpScale(float NewValue)
{
	local KFPlayerInput KFPI;

	NewValue = -NewValue;

	KFPI = KFPlayerInput(GetPC().PlayerInput);
	KFPI.MouseLookUpScale = NewValue;
	KFPI.SaveConfig();

	//Manager.CachedProfile.SetProfileSettingValueFloat(KFID_MouseLookUpScale, NewValue);
}

function Callback_MouseLookRightScale(float NewValue)
{
	local KFPlayerInput KFPI;

	KFPI = KFPlayerInput(GetPC().PlayerInput);
	KFPI.MouseLookRightScale = NewValue;
	KFPI.SaveConfig();

	// Manager.CachedProfile.SetProfileSettingValueFloat(KFID_MouseLookRightScale, NewValue);
}

function Callback_ViewSmoothingChanged(bool bActive)
{
	local KFPlayerInput KFPI;
	
	KFPI = KFPlayerInput(GetPC().PlayerInput);
	KFPI.bViewSmoothingEnabled = bActive;
	
	Manager.CachedProfile.SetProfileSettingValueInt(KFID_ViewSmoothingEnabled, bActive ? 1 : 0);
}

function Callback_ViewAccelerationChanged(bool bActive)
{
	local KFPlayerInput KFPI;
		
	KFPI = KFPlayerInput(GetPC().PlayerInput);
	KFPI.bViewAccelerationEnabled = bActive;

	Manager.CachedProfile.SetProfileSettingValueInt(KFID_ViewAccelerationEnabled, bActive ? 1 : 0);
}

defaultproperties
{
	MinControllerLookSensitivity=.4 
	MaxControllerLookSensitivity=3.5
	MinControllerZoomLookSensitivity=.1
	MaxControllerZoomLookSensitivity=1
	MinControllerDeadzone=.0
	MaxControllerDeadzone=.3
	MinControllerAccelerationJump=.0
	MaxControllerAccelerationJump=1
	MinMouseLookSensitivity=.01
	MaxMouseLookSensitivity=.7
	MinMouseLookZoomSensitivity=.2
	MaxMouseLookZoomSensitivity=1

	MinMouseLookUpScale=20
	MaxMouseLookUpScale=500
	MinMouseLookRightScale=20
	MaxMouseLookRightScale=500

	SubWidgetBindings.Add((WidgetName="keybindingsContainer",WidgetClass=class'KFGFxControlsContainer_Keybinding'))
	SubWidgetBindings.Add((WidgetName="inputContainer",WidgetClass=class'KFGFxControlsContainer_Input'))
	SubWidgetBindings.Add((WidgetName="controllerPresetsContainer",WidgetClass=class'KFGFxControlsContainer_ControllerPresets'))	
}