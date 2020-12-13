//=============================================================================
// KFGFxWidget_NonCriticalGameMessage
//=============================================================================
// HUD Widget that displays messages to the player
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//  - Zane Gholson 01/14/2015
//=============================================================================

class KFGFxWidget_NonCriticalGameMessage extends GFxObject;

function ShowMessage( string LocalizedMessage )
{
	SetString("message", LocalizedMessage);
}
