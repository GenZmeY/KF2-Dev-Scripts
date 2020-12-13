//=============================================================================
// KFGFxWorld_HealerScreen
//=============================================================================
// Class Description
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//  - Author 1/15/2014
//=============================================================================

class KFGFxWorld_HealerScreen extends KFGFxMoviePlayer_World;

var byte		CurrentCharge;

/** Ties the GFxClikWidget variables to the .swf components and handles events */
event bool WidgetInitialized(name WidgetName, name WidgetPath, GFxObject Widget)
{
	switch(WidgetName)
	{
		case ('healerMC'):
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
		MainComponent.SetInt( "Charge", NewCharge );
		CurrentCharge = NewCharge;
	}
}

defaultproperties
{
	RenderTexture=TextureRenderTarget2D'wep_1p_healer_tex.Wep_1stP_Healer_Screen_R2T'
	MovieInfo=SwfMovie'UI_World.HealerWorld'
	bAutoPlay=false
}
