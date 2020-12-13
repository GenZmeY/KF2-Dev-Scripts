//=============================================================================
// KFGFxPopup_InputPrompt
//=============================================================================
// Class Description
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//  - Zane Gholson 11/25/2014
//=============================================================================

class KFGFxPopup_InputPrompt extends KFGFxObject_Popup;

var localized string ConfirmButtonString,DeclineButtonString;
var string PlayerInputString;

function AssignLeftButtonDelegate( delegate<LeftButtonPress> ConfirmDelegate)
{
	LeftButtonPress = ConfirmDelegate;
}

function AssignRightButtonDelegate( delegate<RightButtonPress> CancelDelegate)
{
	RightButtonPress = CancelDelegate;
}

function ClearDelegates()
{
	LeftButtonPress = none;
	RightButtonPress = none;
}

function Callback_ClickedConfirm(string InputString)
{
	PlayerInputString = InputString;
	if( LeftButtonPress != none )
	{
		LeftButtonPress();
	}	
	ClosePopUp();
}


function Callback_ClosedPopup()
{
    if( RightButtonPress != none )
	{
		RightButtonPress();
	}
//@SABER_EGS_BEGIN 
	ClosePopUp();
//@SABER_EGS_END
}

defaultproperties
{
}
