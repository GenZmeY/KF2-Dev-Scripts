//=============================================================================
// KFGFxPopup_Confirmation
//=============================================================================
// Class Description
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//  - Author 1/10/2014
//=============================================================================

class KFGFxPopup_Confirmation extends KFGFxObject_Popup;

var localized string ConfirmButtonString,DeclineButtonString;

function AssignLeftButtonDelegate( delegate<LeftButtonPress> LeftDelegate)
{
	LeftButtonPress = LeftDelegate;
}

function AssignMiddleButtonDelegate( delegate<MiddleButtonPress> MiddleDelegate)
{
	MiddleButtonPress = MiddleDelegate;
}

function AssignRightButtonDelegate( delegate<RightButtonPress> RightDelegate)
{
	RightButtonPress = RightDelegate;
}

function ClearDelegates()
{
	LeftButtonPress = none;
	MiddleButtonPress = none;
	RightButtonPress = none;
}

function Callback_ClickedLeftOption()
{
	if( LeftButtonPress != none )
	{
		LeftButtonPress();
	}	
	ClosePopUp();
}

function Callback_ClickedMiddleOption()
{
    if( MiddleButtonPress != none )
	{
		MiddleButtonPress();
	}
	ClosePopUp();
}

function Callback_ClickedRightOption()
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
