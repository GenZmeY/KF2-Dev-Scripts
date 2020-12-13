//=============================================================================
// KFGFxWorld_WelderScreen
//=============================================================================
// Class Description
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//  - Author 4/9/2014
//=============================================================================

class KFGFxWorld_WelderScreen extends KFGFxMoviePlayer_World;


var byte		CurrentCharge;
var byte		IntegrityPercentage;

/** Ties the GFxClikWidget variables to the .swf components and handles events */
event bool WidgetInitialized(name WidgetName, name WidgetPath, GFxObject Widget)
{
	switch(WidgetName)
	{
		case ('welderMC'):
			if ( MainComponent == none )
			{
				MainComponent = Widget;
		    }
       		break;
    }

	return true;
}

function SetCharge( byte NewCharge )
{
	if ( MainComponent != none )
	{
		MainComponent.ActionScriptVoid("SetCharge");
		CurrentCharge = NewCharge;
	}
}

function SetIntegrity( byte NewIntegrityPercentage )
{
	if ( MainComponent != none )
	{
		MainComponent.ActionScriptVoid("SetIntegrity");
		IntegrityPercentage = NewIntegrityPercentage;
	}
}

defaultproperties
{
	RenderTexture=TextureRenderTarget2D'WEP_1P_Welder_TEX.Wep_1stP_Welder_Screen_R2T'
	MovieInfo=SwfMovie'UI_World.WelderWorld'
	bAutoPlay=false
}
