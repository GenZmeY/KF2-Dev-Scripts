//=============================================================================
// GFxView
//=============================================================================
// Class Description
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//  - Author 11/6/2012
//=============================================================================

class KFGFxObject_Container extends GFxObject
	native(UI);

var KFGFxObject_Menu ParentMenu;

function Initialize( KFGFxObject_Menu NewParentMenu )
{
	ParentMenu = NewParentMenu;
}

function OneSecondLoop();

function string ConsoleLocalize( string Key, optional string SectionName )
{
	return Localize( SectionName != "" ? SectionName : string(self.Class.Name), Key, "KFGameConsole" );
}

//==============================================================
// Calls to ActionScript
//==============================================================

// Make this component able to receive all the controller input
function SetMainComponent( bool bForceSelectFirstItem )
{
	ActionScriptVoid("setMainComponent");
}

// Make this component unable to receive any controller input
function SetComponentInactive()
{
	ActionScriptVoid("setComponentInactive");
}

// Add the new message to our string of all sent messages
function bool SetChatWindowMessage( string Message )
{
	return false;
}

defaultproperties
{
}

