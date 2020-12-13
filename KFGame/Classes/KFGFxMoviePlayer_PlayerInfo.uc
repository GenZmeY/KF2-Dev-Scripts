//=============================================================================
// KFGFxMoviePlayer_PlayerInfo
//=============================================================================
// Player health, armor etc information shown above their heads
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//  - Christian "schneidzekk" Schneider
//=============================================================================
class KFGFxMoviePlayer_PlayerInfo extends GFxMoviePlayer;

var KFPawn_Human 					MyKFPH;
var KFPlayerReplicationInfo			MyKFPRI;

var	GFxObject						PartyMemberHudMC;
var GFxObject						PlayerName;
var	GFxObject						IconMC;
var	GFxObject						Icon;

var	GFxObject						ArmorMeter;
var	GFxObject						HealthMeter;

var int								LastPerkIndex;
var float 							LastHealthPct;
var int								LastArmor;
var string							LastPlayerName;
var bool							bVisible;

var	vector2d						MovieSize;

var vector							ScreenPosition;

function Init(optional LocalPlayer LocPlay)
{
	super.Init(LocPlay);

    SetViewScaleMode(SM_NoScale);
    SetAlignment(Align_TopLeft);

	LastPerkIndex = INDEX_NONE;
	LastHealthPct = INDEX_NONE;
	LastArmor = INDEX_NONE;
	LastPlayerName = "";
}

/** Ties the GFxClikWidget variables to the .swf components and handles events */
event bool WidgetInitialized(name WidgetName, name WidgetPath, GFxObject Widget)
{
	switch(WidgetName)
	{
		case ('partyMemberHud'):
			if ( PartyMemberHudMC == none )
			{
			    PartyMemberHudMC = Widget;
			    // default PartyMemberHudMC to invisible and make visible once it is in view
			    PartyMemberHudMC.SetVisible(false);
			    PlayerName = PartyMemberHudMC.GetObject("txtName");
		    }
       		break;
		case ('iconSection'):
			if ( IconMC == none )
			{
			    IconMC = Widget;
			    Icon = IconMC.GetObject("icon");
		    }
       		break;
		case ('armorMeterMC'):
			if ( ArmorMeter == none )
			{
			    ArmorMeter = Widget;
		    }
       		break;
       	case ('healthMeterMC'):
			if ( HealthMeter == none )
			{
			    HealthMeter = Widget;
		    }
       		break;
    }
	return true;
}

function TickHud(float DeltaTime)
{
	if ( bVisible )
	{
		if ( MyKFPRI == none )
		{
		    MyKFPRI = KFPlayerReplicationInfo(MyKFPH.PlayerReplicationInfo);
		}

		// SetPosition is an expensive call that takes up about 10 ms per tick
		PartyMemberHudMC.SetPosition(ScreenPosition.X - GetMovieWitdth() / 2, ScreenPosition.Y - GetMovieHeight() / 2);

		UpdatePerk();
		UpdateHealth();
		UpdateArmor();
		UpdatePlayerName();
	}
}

function SetVisible(bool bNewVisible)
{
	if ( bVisible != bNewVisible )
	{
		PartyMemberHudMC.SetVisible(bNewVisible);
		bVisible = bNewVisible;
	}
}

function float GetMovieWitdth()
{
  	return MovieSize.X;
}

function float GetMovieHeight()
{
  	return MovieSize.Y;
}

function UpdatePerk()
{
	if ( MyKFPRI != none )
	{
		Icon.SetString("source", "img://" $MyKFPRI.CurrentPerkClass.static.GetPerkIconPath());
	}
}

function UpdateHealth()
{
	local float HealthPct;

	if ( MyKFPH == none )
	{
		LastHealthPct = 0;
		IconMC.GotoAndStopI(100);
		HealthMeter.GotoAndStopI(100);
		return;
	}

	HealthPct = (100.f / float(MyKFPH.HealthMax)) * MyKFPH.Health;
	if ( LastHealthPct != HealthPct )
	{
		LastHealthPct = HealthPct;
		// The hud uses frame 1 as full health
		IconMC.GotoAndStopI(Max(100 - LastHealthPct, 1));
		HealthMeter.GotoAndStopI(Min(LastHealthPct, 100));
	}
}

function UpdateArmor()
{
	if ( MyKFPH == none )
	{
		LastArmor = 0;
		ArmorMeter.GotoAndStopI(100);
	}
	else if ( LastArmor != MyKFPH.Armor )
	{
		LastArmor = MyKFPH.Armor;
		// The hud uses frame 1 as full armor
		ArmorMeter.GotoAndStopI(Min(LastArmor, 100));
	}
}

function UpdatePlayerName()
{
	if ( MyKFPRI == none )
	{
		LastPlayerName = "";
		PlayerName.SetText("");
	}
	else if ( LastPlayerName != MyKFPRI.PlayerName )
	{
		LastPlayerName = MyKFPRI.PlayerName;
		PlayerName.SetText(MyKFPRI.PlayerName);
	}
}

function SetPlayerPawn(KFPawn_Human KFPH)
{
	MyKFPH = KFPH;
    MyKFPRI = KFPlayerReplicationInfo(KFPH.PlayerReplicationInfo);
}

/**
  *Callbacks from AS
  */
function Callback_MovieSize(int MovieWith, int MovieHeight)
{
	MovieSize.X = MovieWith;
	MovieSize.Y = MovieHeight;
}

defaultproperties
{
    Priority=0

	bAutoPlay=true
	//MovieInfo=SwfMovie'PartyMemberHUD_UI.PartyMemberHUD_SWF' swf not in use
	bAllowFocus=false
	bAllowInput=false
	bDisplayWithHudOff=false
}

