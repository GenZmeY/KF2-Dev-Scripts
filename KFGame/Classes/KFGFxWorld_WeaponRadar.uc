//=============================================================================
// KFGFxHUD_WeaponRadar
//=============================================================================
//=============================================================================
// Killing Floor 2
// Copyright (C) 2022 Tripwire Interactive LLC
//=============================================================================

class KFGFxWorld_WeaponRadar extends GFxMoviePlayer;

struct RadarObject
{
	var vector Location;
	var string IconPath;
};

var array<RadarObject> ObjectsInRadar;

var GFxObject RadarContainer;

/** Ties the GFxClikWidget variables to the .swf components and handles events */
event bool WidgetInitialized(name WidgetName, name WidgetPath, GFxObject Widget)
{
	switch(WidgetName)
	{
		case ('radarContainer'):
			if ( RadarContainer == none )
			{
				RadarContainer = Widget;
		    }
       	break;
    }
    
	return true;
}

simulated function AddRadarElements(array<vector> Elements)
{
    local int i;
    local GFxObject DataObject;
    local GFxObject DataProvider;

    if (Elements.Length == 0 || RadarContainer == none)
    {
        return;
    }

    DataProvider = CreateArray();
    for (i = 0; i < Elements.Length; ++i)
    {
		DataObject = CreateObject( "Object" );
		DataObject.SetFloat("UIX", Elements[i].X);
		DataObject.SetFloat("UIY", Elements[i].Y);

        DataProvider.SetElementObject(i, DataObject);
    }

    RadarContainer.SetObject("RadarElements", DataProvider);
}

simulated function Clear()
{
	if (RadarContainer != none)
	{
		RadarContainer.ActionScriptVoid("Clear");	
	}
}

simulated function PrintLog(string text)
{
    `Log("ActionScript Log: " $text);
}

defaultproperties
{
	RenderTexture=TextureRenderTarget2D'WEP_1P_Optics_TEX.Wep_1stP_Optics_R2T'
	MovieInfo=SwfMovie'UI_World.RadarWorld_SWF'
	bAutoPlay=false
}
