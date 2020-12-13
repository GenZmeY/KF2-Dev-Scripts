//=============================================================================
// KFGFxWidget_BackendStatusIndicatorWidget
//=============================================================================
// UI element to show backend connection status
//=============================================================================
// Killing Floor 2
// Copyright (C) 2020 Tripwire Interactive LLC
//  - Roberto Moreno (Saber)
//=============================================================================

class KFGFxWidget_BackendStatusIndicatorWidget extends KFGFxObject_Container;

var localized string BackendStatusIndicatorString;

var bool bConnectedToItemGrantingServer; //[rmoreno@Saber] Item Granting Server should be the same as Tweak Server.

//TODO [rmoreno@Saber] We should clear any timer initialized. Search for WidgetUnloaded and implement it in KFGfxMoviePlayer_Manager.uc
function Init()
{
    //`TimerHelper.SetTimer(5.0, true, nameof(Timer_TestingFlickering), self);
    `TimerHelper.SetTimer(60.0, true, nameof(Timer_CheckIsConnectedToItemGrantingServer), self);
    Timer_CheckIsConnectedToItemGrantingServer();//we call it once as initialization
    LocalizeText();
}

function StartFlickeringConnectionLost()
{
	ActionScriptVoid("startDisconnectionAnimation");
}

function StopFlickeringConnectionLost()
{
	ActionScriptVoid("stopDisconnectionAnimation");
}

function Timer_CheckIsConnectedToItemGrantingServer()
{
    bConnectedToItemGrantingServer = class'KFGameEngine'.static.IsLastRefreshTweakParamsSuccessful(); //[rmoreno@Saber] This function does not make any ping or request just check a variable from TWTweak.cpp which is set when initalizing game and exiting ingame matches.
    //[rmoreno@Saber] In case we want to check playfab we could add to the above condition: && class'GameEngine'.static.GetPlayfabInterface().CachedPlayfabId
    if (bConnectedToItemGrantingServer)
    {
        StopFlickeringConnectionLost();
    }
    else {
        StartFlickeringConnectionLost();
    }

}

function LocalizeText()
{
	local GFxObject LocalizedObject;

    LocalizedObject = CreateObject( "Object" );
	LocalizedObject.SetString("backendStatusIndicatorString", BackendStatusIndicatorString);

	SetObject("localizedText", LocalizedObject);
}


defaultproperties
{
    bConnectedToItemGrantingServer = FALSE
}

