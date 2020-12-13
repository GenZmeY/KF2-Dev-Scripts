//=============================================================================
// KFGFxInGameHUD_TraderCompass
//=============================================================================
// HUD container that stores information about the player's Weapon & Equipment, dosh, etc.
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//  - Alex Quick 5/15/2014
//=============================================================================

class KFGFxHUD_TraderCompass extends GFxObject;

/** Cached KFPlayerController */
var PlayerController 				MyPC;
var KFGameReplicationInfo           MyKFGRI;
//
var private GfxObject               TraderPing;
//
var float                           LastDistToTrader;
//
var byte                            LastArrowDirection;

var float                           LastViewAngleDotProduct;

var localized string                TraderString;

const TraderPing_LeftSide         = -1.0f;
const TraderPing_RightSide        = 1.0f;
// Don't render the ping on the compass if the player is this distance or closer to the trader.
const PingMinRenderDistSq        = 100000.f;

/**
 *  Callback when a child widget is initialized within the path bound to this widget via GFxMoviePlayer::SetWidgetPathBinding().  Allows for GFxObject subclasses that encapsulate
 *  functionality to handle their own initialization for child widgets, instead of the GFxMoviePlayer.  Returns TRUE if the widget was handled, FALSE if not.
 */
event bool WidgetInitialized(name WidgetName, name WidgetPath, GFxObject Widget)
{
    Super.Widgetinitialized(WidgetName,WidgetPath,Widget);

    switch(WidgetName)
    {
        case 'CompassPingAnimContainer' :
        if ( TraderPing == none )
        {
       	    TraderPing = Widget;
        }
        break;
    }

    return true;
}


function InitializeHUD()
{
	MyPC = GetPC();
    SetString("traderText", TraderString);
}

function TickHud(float DeltaTime)
{
    UpdateTraderCompassPosition();
    UpdateDistanceToTrader();
}

function vector GetCurrentTraderLocation()
{
    local vector TraderLoc;

    if( MyPC == none )
    {
        return Vect(0,0,0);
    }

    if( MyKFGRI == none )
    {
        MyKFGRI = KFGameReplicationInfo( MyPC.WorldInfo.GRI );
    }
    if(MyKFGRI != none && (MyKFGRI.OpenedTrader != none || MyKFGRI.NextTrader != none))
    {
        TraderLoc = MyKFGRI.OpenedTrader != none ? MyKFGRI.OpenedTrader.Location : MyKFGRI.NextTrader.Location;
    }

    return TraderLoc;
}

function UpdateDistanceToTrader()
{
    local float CurrentDistToTrader;
    local vector TraderLoc;
    local Actor LocActor;

    if(MyPC != none)
    {
        LocActor = MyPC.ViewTarget != none ? MyPC.ViewTarget : MyPC;

        TraderLoc = GetCurrentTraderLocation();
        CurrentDistToTrader = IsZero(TraderLoc) ? -1.f : VSize(TraderLoc - LocActor.Location) / 100.f  ;
        if (CurrentDistToTrader != LastDistToTrader )
        {
            SetInt("distanceToTrader" ,CurrentDistToTrader);
            LastDistToTrader = CurrentDistToTrader;
        }
    }
}

function UpdateTraderCompassPosition()
{
    local vector CameraLoc;
    local rotator CameraRot;
    local vector TraderLocation;
    local float TraderAngle;
    local vector NormalizedViewDir;
    local float ViewAngleDotProduct;
    local bool ShowPing;
    local byte CurrentArrowdirection;

    if( MyPC != none )
    {
        TraderLocation = GetCurrentTraderLocation();

        // No active trader, or returning  bad world location.
        if(IsZero(TraderLocation))
        {
            return;
        }

        MyPC.GetPlayerViewPoint(CameraLoc, CameraRot);

        CameraRot.Yaw = CameraRot.Yaw & 65535;
        CameraRot.Roll = 0;
        CameraRot.Pitch = 0;
        CurrentArrowDirection = 0;

        NormalizedViewDir = Normal(TraderLocation - Cameraloc << CameraRot)  ;
        ViewAngleDotProduct = Normal(TraderLocation - CameraLoc) Dot vector(CameraRot);

        if(ViewAngleDotProduct != LastViewAngleDotProduct)
        {
            LastViewAngleDotProduct = ViewAngleDotProduct;
            if(NormalizedViewDir.Y > 0)  // Target is to the right of our camera.
            {
                if(ViewAngleDotProduct < 0.f)
                {
                    TraderAngle = TraderPing_RightSide;
                    CurrentArrowDirection = 4;
                }
                else
                {
                    TraderAngle = TraderPing_RightSide * (1.f-ViewAngleDotProduct);
                }
            }
            else    // To the left.
            {
                if(ViewAngleDotProduct < 0.f)
                {
                    TraderAngle = TraderPing_LeftSide;
                    CurrentArrowDirection = 3;
                }
                else
                {
                    TraderAngle = TraderPing_LeftSide * (1.f-ViewAngleDotProduct);
                }
            }

            if(TraderPing != none)
            {
                ShowPing = VSizeSq(TraderLocation - CameraLoc) > PingMinRenderDistSq;
                TraderPing.SetVisible(ShowPing);
                if(ShowPing)
                {
                    SetFloat("traderAngle", TraderAngle);
                }
            }
        }

        if(Abs(TraderLocation.Z - CameraLoc.Z) > 86.f) //Collisionheight
        {
            CurrentArrowDirection = TraderLocation.Z > CameraLoc.Z ? 1 : 2 ;
        }

        if(CurrentArrowDirection != LastArrowDirection)
        {
            SetInt("arrowDirection" ,CurrentArrowDirection);
            LastArrowDirection = CurrentArrowDirection;
        }
    }
}


DefaultProperties
{
}

