//=============================================================================
// KFGFxMoviePlayer_Manager_Tutorial
//=============================================================================
// Notify the game info when the player selects a menu we may want
// to assign a tutorial
//=============================================================================
// Killing Floor 2
// Copyright (C) 2016 Tripwire Interactive LLC
//=============================================================================

class KFGFxMoviePlayer_Manager_Tutorial extends KFGFxMoviePlayer_Manager;

function OpenMenu( byte NewMenuIndex, optional bool bShowWidgets = true )
{
	local KFGameInfo_Tutorial GI;

	Super.OpenMenu(NewMenuIndex, bShowWidgets);

	if ( CurrentMenuIndex == NewMenuIndex )
	{
		GI = KFGameInfo_Tutorial(class'WorldInfo'.static.GetWorldInfo().Game);
		if ( GI != None )
		{
			GI.NotifyMenuOpened(NewMenuIndex);
		}
	}
}