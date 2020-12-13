//=============================================================================
// KFGFxWorld_C4Screen
//=============================================================================
// Class Description
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//  - Author 4/9/2014
//=============================================================================

class KFGFxWorld_C4Screen extends KFGFxMoviePlayer_World;


var int CurrentMaxCharges;
var int CurrenActiveCharges;

/** Ties the GFxClikWidget variables to the .swf components and handles events */
event bool WidgetInitialized(name WidgetName, name WidgetPath, GFxObject Widget)
{
	switch(WidgetName)
	{
		case ('c4WorldMC'):
			if ( MainComponent == none )
			{
				MainComponent = Widget;
		    }
       		break;
    }

	return true;
}

function SetMaxCharges(int MaxCharges)
{
	if(MainComponent != none)
	{
		MainComponent.SetInt("maxCharges", MaxCharges);
	}
	
}

function SetActiveCharges(int ActiveCharges)
{
	if ( MainComponent != none )
	{	
		MainComponent.SetInt("activeCharges", ActiveCharges);
	}
}

function SetReadOut( string newValue )
{
	if ( MainComponent != none )
	{
		MainComponent.SetString("readOut", newValue);
	}
}

defaultproperties
{
	RenderTexture=TextureRenderTarget2D'Wep_1P_C4_TEX.Wep_1stP_C4_Screen_R2T'
	MovieInfo=SwfMovie'UI_World.C4World'
	bAutoPlay=false
}
