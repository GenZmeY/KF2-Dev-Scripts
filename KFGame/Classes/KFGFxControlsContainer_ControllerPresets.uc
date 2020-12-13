//=============================================================================
// KFGFxControlsContainer_ControllerPresets
//=============================================================================
// Class Description
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
// Zane Gholson -  11/19/2014
//=============================================================================

class KFGFxControlsContainer_ControllerPresets extends KFGFxObject_Container
    config(UI);

`include(KFProfileSettings.uci);

var const string InputSectionName;
var const string PackageName;

var localized string MovementString;
var localized string LookString;
var localized string ShowScoardBoardString;
var localized string ShowIngameMenuString;
var localized string HoldString;
var localized string TapString;
var localized string CurrentControllerPresetString;

var localized array<string> PresetStrings;

var int numGamepadLayouts;

struct KeyBinding
{
    var string Key;
    var string Command;
    var string HoldCommand;
};

var byte CurrentLocalizedIndex;
var byte CurrentPresetIndex;

function Initialize( KFGFxObject_Menu NewParentMenu )
{
    super.Initialize( NewParentMenu );
    CurrentPresetIndex = KFPlayerInput(GetPC().PlayerInput).CurrentLayoutIndex;
    UpdateCurrentPresetArray(CurrentPresetIndex);
}

/**
*   This is function will tell KFPlayerInput to update gamepad button mappings
*   and then update the UI.
*
*   PresetIndex - the index of the controller layout we want applied to the game.
*/
function UpdateCurrentPresetArray(byte PresetIndex)
{
    local KFPlayerInput kfPlayerInput;
    local KFPlayerInput KFPI;

    CurrentPresetIndex = PresetIndex;
    numGamepadLayouts = class'KFGamepadLayoutManager'.static.GetNumLayouts();

    // Wrap around for the index.
    if(CurrentPresetIndex >= numGamepadLayouts)
    {
        CurrentPresetIndex = 0;
    }
    else if( CurrentPresetIndex < 0)
    {
        CurrentPresetIndex = numGamepadLayouts -1;
    }

    // Tell the player input to update the actual controls.
    KFPlayerInput = KFPlayerInput(GetPC().PlayerInput);
    KFPlayerInput.SetGamepadLayout(CurrentPresetIndex);

    // Update the GUI with the new button layout descriptions.
    LocalizeText();
    UpdateButtonDescriptions();
    KFPI = KFPlayerInput(GetPC().PlayerInput);

    KFPI.CurrentLayoutIndex = CurrentPresetIndex;
    KFPI.SaveConfig();  
}

function LocalizeText()
{
    local GfxObject TextField;
    local GFxObject PresetArray;
    local GfxObject StepperOption;
    local GFxObject defaultButton;
    local int i;

    TextField = GetObject("CurrentPresetTextfield");

    PresetArray = CreateArray();

    for (i = 0; i < numGamepadLayouts; i++)
    {
        StepperOption = CreateObject("Object");
        StepperOption.SetString("label", PresetStrings[i]);
        PresetArray.SetElementObject(i, StepperOption);
    }
    SetObject("presetOptions",PresetArray);
    SetInt("currentPreset", CurrentPresetIndex);

    if(TextField != none)
    {
        Textfield.SetText(CurrentControllerPresetString);
    }

    defaultButton = GetObject("defaultButton");
    if ( defaultButton != None )
    {
        defaultButton.SetString("label",Localize("KFGFxOptionsMenu_Graphics","DefaultString","KFGame"));
    }
}

/**
*   This is function updates all the button descriptions based off of the
*   current key bindings in KFPlayerInput.
*/
function UpdateButtonDescriptions( )
{
    local GFxObject LocalizedObject;
    local name gamepadButtonNames[20];
    local KFPlayerInput kfPlayerInput;
    local byte i;
    local string bindCommand;
    local GfxObject TempTextField;
    local string TextFieldName;
    local string localizedCommand;
    //local string localizedLayoutName;

    CurrentLocalizedIndex = 0;

    LocalizedObject = CreateObject( "Object" );
    
    LocalizedObject.SetString("leftThumbstick",                 MovementString);
    LocalizedObject.SetString("rightThumbstick",                LookString);
    LocalizedObject.SetString("back",                           ShowScoardBoardString);
    LocalizedObject.SetString("start",                          ShowIngameMenuString);

    kfPlayerInput = KFPlayerInput(GetPC().PlayerInput);
    class'KFGamepadLayoutManager'.static.GetGamepadButtonNames(gamepadButtonNames);

    //localizedLayoutName = class'KFGamepadLayoutManager'.static.GetLayoutName(CurrentPresetIndex);

    for (i = 0; i < 20; i++)
    {
        TextFieldName = gamepadButtonNames[i]  $"Textfield";
        TempTextField = GetObject(TextFieldName);
        
        if(TempTextField != none)
        {
            // Find out the localized display name of the action assigned to this button.
            bindCommand = kfPlayerInput.GetGameBindableAction( gamepadButtonNames[i]);
            localizedCommand = Localize(InputSectionName,  bindCommand,  PackageName);

            TempTextField.SetText(localizedCommand);
        }
    }
}

function AddBindingToGFxObject(out GFxObject ObjectArray, string Key, string Command, string HoldCommand, byte i)
{
    local GFxObject TempObject;
    local string CommandString, HoldCommandString;

    TempObject = CreateObject("Object");

    CommandString = Localize(InputSectionName,  Command,  PackageName);

    if(HoldCommand != "")
    {

        HoldCommandString = Localize(InputSectionName,  HoldCommand,  PackageName);
        HoldCommandString -= HoldString;
        CommandString = CommandString $"\n" $HoldCommandString @HoldString;
    }
    TempObject.SetString("Key",             Key);
    TempObject.SetString("Command",         CommandString);

    ObjectArray.SetElementObject(i, TempObject);
}

function ResetPresetOptions()
{
    CurrentPresetIndex = ParentMenu.Manager.CachedProfile.GetDefaultInt(KFID_CurrentLayoutIndex);
    ParentMenu.Manager.CachedProfile.SetProfileSettingValueInt(KFID_CurrentLayoutIndex, CurrentPresetIndex);

    UpdateCurrentPresetArray(CurrentPresetIndex);
}

DefaultProperties
{
    InputSectionName="LocalizedControls"
    PackageName="KFGame"
    CurrentPresetIndex=0
}