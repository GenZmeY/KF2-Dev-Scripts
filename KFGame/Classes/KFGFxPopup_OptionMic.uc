//=============================================================================
// KFGFxPopup_OptionMic
//=============================================================================
// Class Description
//=============================================================================
// Killing Floor 2
// Copyright (C) 2019 SABER Interactive
//  - Author Pavel Rodionov 14/11/2019
//=============================================================================

//@SABER_EGS_BEGIN
class KFGFxPopup_OptionMic extends KFGFxObject_Popup
config(Microphone);
`include(KFProfileSettings.uci)

var float micVolume;
var config int deviceIndex;

var OnlineSubsystemSteamworks SubSystem;

function InitializePopup( KFGFxMoviePlayer_Manager InManager )
{
    Super.InitializePopup(InManager);

    SubSystem = OnlineSubsystemSteamworks(class'GameEngine'.static.GetOnlineSubsystem());

    setLocalizedText();

    getDevicesListFromVivox();
    selectDevice();
    setMicVolume();
}

function setLocalizedText()
{
    local GFxObject LocalizedStringsObject;

    LocalizedStringsObject = CreateObject("Object");

    LocalizedStringsObject.SetString("devicesTextField", Class'KFCommon_LocalizedStrings'.default.MicrophonePopupSelectDeviceString);
    LocalizedStringsObject.SetString("sliderTextField", Class'KFCommon_LocalizedStrings'.default.MicrophonePopupVolumeString);
    LocalizedStringsObject.SetString("checkMicButton", Class'KFCommon_LocalizedStrings'.default.MicrophonePopupCheckString);
    LocalizedStringsObject.SetString("stopMicButton", Class'KFCommon_LocalizedStrings'.default.MicrophonePopupStopString);
    LocalizedStringsObject.SetString("refreshButton", Class'KFCommon_LocalizedStrings'.default.MicrophonePopupRefreshString);

    SetObject("setTextLocalized", LocalizedStringsObject);
}

function getDevicesListFromVivox()
{
    local array<string> audioDevices;
    local int i;
    local GFxObject DataProvider;
    DataProvider = CreateArray();

    if( SubSystem != none )
	{
		audioDevices = Subsystem.GetVivoxAudioDevices();

        for (i = 0; i < audioDevices.length; i++)
        {
            DataProvider.SetElementString(i, audioDevices[i]);
        }

        SetObject("fillDevicesList", DataProvider);
	}
}

function selectDevice()
{
    `log(getFuncName()@"deviceIndex:"@deviceIndex);
    SetInt("selectDevices", deviceIndex);
}

function setMicVolume()
{
    micVolume = Manager.CachedProfile.GetProfileFloat(KFID_VOIPMicVolumeMultiplier);
    `log(getFuncName()@"micVolume:"@micVolume);		
    SetFloat("setMicVolume", micVolume);
}


//Action scripts callbacks
function Callback_onBtnAcceptClick()
{
    if( SubSystem != none )
    {
        Subsystem.VivoxEchoTestStop();
    }
    Manager.CachedProfile.SetProfileSettingValueFloat(KFID_VOIPMicVolumeMultiplier, micVolume);
    SaveConfig();
    ClosePopUp();
}

function Callback_onBtnDeclineClick()
{
    if( SubSystem != none )
    {
        Subsystem.VivoxEchoTestStop();
    }
    ClosePopUp();
}

function Callback_DeviceSelect(int newDeviceIndex)
{
    `log(getFuncName()@"deviceIndex:"@newDeviceIndex);
     deviceIndex = newdeviceIndex;
    if( SubSystem != none )
	{
		Subsystem.SetVivoxMicDevice(deviceIndex);
	}
}

function Callback_onRefreshButtonClick()
{
    `log(getFuncName());
    getDevicesListFromVivox();
}

function Callback_MicVolumeChanged(float NewVolume)
{
    `log(getFuncName()@"volume:"@NewVolume);
    micVolume = NewVolume;
    OSS_SetVoIPMicVolume(newVolume);
}

function OSS_SetVoIPMicVolume(float NewVolume)
{
	if( SubSystem != none )
	{
		Subsystem.SetVoIPMicVolume(NewVolume);
	}
}

function Callback_onCheckMicClick()
{
    `log(getFuncName());
    if( SubSystem != none )
	{
		Subsystem.VivoxEchoTestStart();
	}
}

function Callback_onStopMicClick()
{
    `log(getFuncName());
    if( SubSystem != none )
	{
		Subsystem.VivoxEchoTestStop();
	}
}

defaultproperties
{
}
//@SABER_EGS_END