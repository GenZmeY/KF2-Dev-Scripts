//=============================================================================
// KFGfxObject_Popup
//=============================================================================
// Base class for all things pop-upable in KF2
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//  - Alex Quick 6/16/2014
//=============================================================================

class KFGFxObject_Popup extends GFxObject;

var KFGFxMoviePlayer_Manager Manager;

function Callback_ClosedPopup()
{
//@SABER_EGS_BEGIN 
    `log("KFGfxObject_Popup::"$GetFuncName()@"invoke ClosePopUp()");
//@SABER_EGS_END
   ClosePopUp();
}

function ClosePopUp()
{
	ClearDelegates();
	Manager.UnloadCurrentPopup();
}

delegate LeftButtonPress();
delegate MiddleButtonPress();
delegate RightButtonPress();

function AssignLeftButtonDelegate( delegate<LeftButtonPress> LeftDelegate);
function AssignMiddleButtonDelegate( delegate<MiddleButtonPress> MiddleDelegate);
function AssignRightButtonDelegate( delegate<RightButtonPress> RightDelegate);
function ClearDelegates();

function UpdateDescritionText(string newDescription)
{
	SetString("descriptionText", newDescription);
}

function OnClosed()
{
    if(Manager.CurrentMenu != none)
    {
        Manager.SetExternalInterface(Manager.CurrentMenu);
    }
}

function InitializePopup( KFGFxMoviePlayer_Manager InManager )
{
    Manager = InManager;
}


defaultproperties
{
}

