//=============================================================================
// KFGFxWidget_MapText
//=============================================================================
//
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//=============================================================================

class KFGFxWidget_MapText extends GFxObject;

var GFxObject mapTextField;

var KFPlayerController KFPC;

var transient float CurrentDisplayTime;
var transient float ControlTime;

struct MapStoredMessage
{
	var string Text;
	var float DisplayTime;
};
var array<MapStoredMessage> StoredMessageList;

function InitializeHUD()
{
    KFPC = KFPlayerController(GetPC());
    mapTextField = GetObject("mapText");
    SetVisible(false);
}

function DisplayMapText(string MapText, float DisplayTime, bool bWaitForTheNextMessageToFinish)
{
	Local MapStoredMessage StoredMessage;

	if(mapTextField != none)
	{
		if(ControlTime > 0 && bWaitForTheNextMessageToFinish)
		{
			StoredMessage.Text = MapText;
			StoredMessage.DisplayTime = DisplayTime;
			StoredMessageList.AddItem(StoredMessage);
			return;
		}
		ControlTime = DisplayTime;
		CurrentDisplayTime = DisplayTime;
        mapTextField.SetText(MapText);
		SetVisible(true);
	}
}

function TickHud(float DeltaTime)
{
	if(ControlTime > 0)
	{
		ControlTime -= DeltaTime;
		if(ControlTime <= 0)
		{
			HideMessage();
		}
	}
}

function HideMessage()
{
	if(StoredMessageList.Length > 0)
	{
		ControlTime += StoredMessageList[0].DisplayTime;
		CurrentDisplayTime = StoredMessageList[0].DisplayTime;
        mapTextField.SetText(StoredMessageList[0].Text);
		SetVisible(true);
		StoredMessageList.Remove(0, 1);
		return;
	}
	mapTextField.SetText("");
	SetVisible(false);
}

DefaultProperties
{ }