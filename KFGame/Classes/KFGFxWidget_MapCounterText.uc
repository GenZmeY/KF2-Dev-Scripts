//=============================================================================
// KFGFxWidget_MapCounterText
//=============================================================================
//
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//=============================================================================

class KFGFxWidget_MapCounterText extends GFxObject;

var GFxObject counterMapTextField;

var KFPlayerController KFPC;

var transient float CurrentDisplayTime;
var transient float ControlTime;

function InitializeHUD()
{
    KFPC = KFPlayerController(GetPC());
    counterMapTextField = GetObject("counterMapText");
    SetVisible(false);
}

function DisplayMapText(string CountText, float DisplayTime)
{
	if(counterMapTextField != none)
	{
		ControlTime = DisplayTime;
		CurrentDisplayTime = DisplayTime;
        counterMapTextField.SetText(CountText);
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
	counterMapTextField.SetText("");
	SetVisible(false);
}

DefaultProperties
{ }