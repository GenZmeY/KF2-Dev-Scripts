//=============================================================================
// KFGFxHUD_ChatBoxWidget
//=============================================================================
// HUD container that displays chat between system and players.
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//  - Zane Gholson & Alex Quick 6/06/2014
//=============================================================================

class KFGFxHUD_ChatBoxWidget extends GFxObject;

var bool bChatBoxVisible;

function Init()
{
    local KFPlayerController KFPC;

    SetVisible(false);
    //sync chat systems
    KFPC = KFPlayerController(GetPC());
    if(KFPC != none && KFPC.MyGFxHUD != none && KFPC.MyGFxHUD.HudChatBox != none && KFPC.MyGFxHUD.HudChatBox != self )
    {
        SetDataObjects(KFPC.MyGFxHUD.HudChatBox.GetDataObjects());  
    }   
}

function AddChatMessage(string NewMessage, string HexVal)
{
	ActionScriptVoid("addChatMessage");
}

function OpenInputField()
{
	ActionScriptVoid("onOpenInput");
}

function array<GFxObject> GetDataObjects()
{
    local array<GFxObject> retVal;
    retVal = ActionScriptArray("getDataObjects");
    return retVal;
}

function SetDataObjects( array<GFxObject> DataObjects)
{
    local GFxObject DataProvider,TempObj;
    local byte i;
    DataProvider = CreateArray();
    for ( i = 0; i < DataObjects.length; i++ )
    {
        TempObj = CreateObject( "Object" );
        TempObj.SetString("label", dataObjects[i].GetString("label"));
        TempObj.SetString("messageClr", dataObjects[i].GetString("messageClr"));
        TempObj.SetFloat("timeStamp", dataObjects[i].GetFloat("timeStamp"));
        DataProvider.SetElementObject( i, TempObj );
    }

    SetObject("dataObjects", DataProvider);
}

function SetLobbyChatVisible(bool bIsVisible)
{
    if(bIsVisible != bChatBoxVisible)
    {
		// Only show if we aren't on console.
		if( !GetPC().WorldInfo.IsConsoleBuild() )
		{
			SetVisible(bIsVisible);    
			bChatBoxVisible = bIsVisible;  
		}
    }   
}

/** Clears the current chat message and closes the chat box */
function ClearAndCloseChat()
{
    ActionScriptVoid("ClearAndCloseChat");
}

defaultproperties
{
}

