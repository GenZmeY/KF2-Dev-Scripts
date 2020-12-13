//=============================================================================
// KFGFxWidget_MusicNotification
//=============================================================================
// This element will display the track title and artist name of the current 
// music on music change
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//  - Zane Gholson 11/10/2014
//=============================================================================

class KFGFxWidget_MusicNotification extends GFxObject;

function InitializeHUD()
{
    
}

function ShowSongInfo(string SongInfoString)
{
	local KFGameEngine KFEngine;

	KFEngine = KFGameEngine(Class'Engine'.static.GetEngine());
	if(KFEngine != none && KFEngine.MusicVolumeMultiplier > 0)
	{
		SetString("text", SongInfoString);
	}
}

DefaultProperties
{
    
}
