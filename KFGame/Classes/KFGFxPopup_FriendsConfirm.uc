//=============================================================================
// KFGFxPopup_FriendsConfirm
//=============================================================================
// Class Description
//=============================================================================
// Killing Floor 2
// Copyright (C) 2019 SPL
//  - Pavel Rodionov 10/09/2019
//=============================================================================

class KFGFxPopup_FriendsConfirm extends KFGFxObject_Popup;

function AssignLeftButtonDelegate( delegate<LeftButtonPress> LeftDelegate)
{
	LeftButtonPress = LeftDelegate;
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


function Callback_onBtnAcceptClick()
{
        `log(getFuncName());
        if( LeftButtonPress != none )
	{
	       `log("LeftButtonPress");
		LeftButtonPress();
	}	
	ClosePopUp();
}


function Callback_onBtnDeclineClick()
{
        `log(getFuncName());
        if( RightButtonPress != none )
	{
	       `log("RightButtonPress");
		RightButtonPress();
	}
        ClosePopUp();
}

defaultproperties
{
}

