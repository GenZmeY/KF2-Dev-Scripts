//=============================================================================
// GFxHudWrapper
//=============================================================================
// The Killing Floor 2 HUD wrapper class
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//  - Christian "schneidzekk" Schneider 8/23/2012
//=============================================================================

class KFGFxHudWrapper extends KFHUDBase;

/** Class of HUD Movie object */
var class<KFGFxMoviePlayer_HUD> HUDClass;

/** Main Heads Up Display Flash movie */
var KFGFxMoviePlayer_HUD   HudMovie;

/** Cached reference to the boss pawn */
var KFInterface_MonsterBoss BossRef;

/*********************************************************************************************
`* Initialization
********************************************************************************************* */
/**
  * Create and initialize the HUDMovie.
  */
function CreateHUDMovie(optional bool bForce)
{
	if(HudMovie != none && !bForce)
    {
        return;
    }

	HudMovie = new HUDClass;
	HudMovie.SetTimingMode(TM_Real);
	HudMovie.Init(class'Engine'.static.GetEngine().GamePlayers[HudMovie.LocalPlayerOwnerIndex]);
}


function class<KFGFxMoviePlayer_HUD> GetHUDClass()
{
	return HUDClass;
}


singular event Destroyed()
{
	RemoveMovies();
	Super.Destroyed();
}

/**
  * Destroy existing Movies
  */
function RemoveMovies()
{
	if ( HUDMovie != None )
	{
		HudMovie.CleanUp();
		HUDMovie.Close(true);
		HUDMovie = None;
	}

	Super.RemoveMovies();
}


/**
  * Returns the index of the local player that owns this HUD
  */
function int GetLocalPlayerOwnerIndex()
{
	return HudMovie.LocalPlayerOwnerIndex;
}

/*********************************************************************************************
`* Drawing
********************************************************************************************* */
/**
 *  Toggles visibility of normal in-game HUD
 */
function SetVisible(bool bNewVisible)
{
	Super.SetVisible(bNewVisible);
	if (HudMovie != none)
	{
		HudMovie.SetPause(!bNewVisible);
		HudMovie.NotifyVisibilityChange(bNewVisible);
	}
}

/**
  * Recreate movies since resolution changed (also creates them initially)
  */
function ResolutionChanged()
{
	super.ResolutionChanged();

	CreateHUDMovie(true);
}

/**
 * PostRender is the main draw loop.
 */
event PostRender()
{
	super.PostRender();
	if ( HudMovie != none )
	{
		HudMovie.TickHud(0);
	}
}

/** sets bShowScores to a specific value (not toggle) */
exec function SetShowScores(bool bNewValue)
{
	super.SetShowScores(bNewValue);
    if(HUDMovie != none)
    {
        HUDMovie.ShowScoreboard(bNewValue);
    }
}

/**
  * Call PostRenderFor() on actors that want it.
  */
event DrawHUD()
{
	//local vector ViewPoint;
	//local rotator ViewRotation;
	local float XL, YL, YPos;

	super.DrawHUD();

	/*if ( KFGRI != None && !KFGRI.bMatchIsOver )
	{
		Canvas.Font = GetFontSizeIndex(0);
		PlayerOwner.GetPlayerViewPoint(ViewPoint, ViewRotation);
		DrawActorOverlays(Viewpoint, ViewRotation);
	}*/

    // Don't draw canvas HUD in cinematic mode
    if( KFPlayerOwner != none && KFPlayerOwner.bCinematicMode )
    {
        return;
    }

	if ( bCrosshairOnFriendly )
	{
		// verify that crosshair trace might hit friendly
		bGreenCrosshair = CheckCrosshairOnFriendly();
		bCrosshairOnFriendly = false;
	}
	else
	{
		bGreenCrosshair = false;
	}

	if ( bShowDebugInfo )
	{
		Canvas.Font = GetFontSizeIndex(0);
		Canvas.DrawColor = ConsoleColor;
		Canvas.StrLen("X", XL, YL);
		YPos = 0;
		PlayerOwner.ViewTarget.DisplayDebug(self, YL, YPos);

		if (ShouldDisplayDebug('AI') && (Pawn(PlayerOwner.ViewTarget) != None))
		{
			DrawRoute(Pawn(PlayerOwner.ViewTarget));
		}
		return;
	}
}

/*********************************************************************************************
`* Updating
********************************************************************************************* */


/*********************************************************************************************
Close / Died
********************************************************************************************* */

function PlayerOwnerDied()
{
	super.PlayerOwnerDied();
	if(HudMovie != none)
	{
		HudMovie.PlayerOwnerDied();
	}
}

/*********************************************************************************************
GFx Local messaging
********************************************************************************************* */

function LocalizedMessage
(
	class<LocalMessage>		InMessageClass,
	PlayerReplicationInfo	RelatedPRI_1,
	PlayerReplicationInfo	RelatedPRI_2,
	string					MessageString,
	int						Switch,
	float					Position,
	float					LifeTime,
	int						FontSize,
	color					DrawColor,
	optional object			OptionalObject
)
{
	local KFPlayerController KFPC;
	local string HexClr;
	local class<KFLocalMessage>  KFLocalMessageClass;

    if( MessageString == "" )
	{
		return;
	}

	KFPC = KFPlayerController(PlayerOwner);

    if( !InMessageClass.default.bIsSpecial )
    {
	    AddConsoleMessage( MessageString, InMessageClass, RelatedPRI_1 );
		return;
    }

	if( bMessageBeep && InMessageClass.default.bBeep )
		PlayerOwner.PlayBeepSound();


    KFLocalMessageClass = class<KFLocalMessage>(InMessageClass);
    if(KFLocalMessageClass != none)
    {
        HexClr = KFLocalMessageClass.static.GetHexColor(Switch);
    }
    else if(InMessageClass == class'GameMessage')
    {
        HexClr = class 'KFLocalMessage'.default.ConnectionColor ;
    }
    if( HudMovie != none && HudMovie.HudChatBox != none )
    {
    	HudMovie.HudChatBox.AddChatMessage(MessageString, HexClr);
	}
    //Todo: Try to separate this from the HUD.
    if(KFPC.MyGFxManager != none && KFPC.MyGFxManager.PartyWidget != none)
    {
    	KFPC.MyGFxManager.PartyWidget.ReceiveMessage(MessageString, HexClr);
    }
}

defaultproperties
{
	HUDClass=class'KFGFxMoviePlayer_HUD'
}