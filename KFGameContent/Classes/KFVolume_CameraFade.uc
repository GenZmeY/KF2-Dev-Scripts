//=============================================================================
// KFVolume_CameraFade
//=============================================================================
// Volume that can be used to trigger client camera fades, rather than using
//          a more complicated Kismet setup.
//=============================================================================
// Killing Floor 2
// Copyright (C) 2017 Tripwire Interactive LLC
// - Dan Weiss
//=============================================================================

class KFVolume_CameraFade extends Volume
    placeable;

/** Opacity at the start and end of the fade process */
var() float FadeOpacityStart<ClampMin = 0.0 | ClampMax = 1.0>;
var() float FadeOpacityEnd<ClampMin = 0.0 | ClampMax = 1.0>;

/** Time to use to achieve the fade */
var() float FadeTime;

simulated event Touch(Actor Other, PrimitiveComponent OtherComp, vector HitLocation, vector HitNormal)
{
    local Pawn OtherPawn;
    local KFPlayerController KFPC;

    OtherPawn = Pawn(Other);
    if (OtherPawn != none)
    {
        KFPC = KFPlayerController(OtherPawn.Controller);
        if (KFPC != none && KFPC.IsLocalController())
        {
            if (KFPC.PlayerCamera != none && KFPC.PlayerCamera.FadeAmount == FadeOpacityEnd)
            {
                return;
            }
            KFPC.ClientSetCameraFade(true, MakeColor(0, 0, 0, 255), vect2d(FadeOpacityStart, FadeOpacityEnd), FadeTime);
        }
    }
}

defaultproperties
{
    bCollideActors = true
    SupportedEvents.Empty

    FadeOpacityStart=0.0
    FadeOpacityEnd=0.0
    FadeTime=0.5
}