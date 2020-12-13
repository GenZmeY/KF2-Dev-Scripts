//=============================================================================
// KFVolume_DisableZedJump
//=============================================================================
// Volume for toggling off Zed jump capabilities.  Used to fix areas where we
//      want to force zeds to not be able to jump over obstacles in the event
//      they are straight lining.
//=============================================================================
// Killing Floor 2
// Copyright (C) 2017 Tripwire Interactive LLC
// Dan Weiss
//=============================================================================

class KFVolume_DisableZedJump extends Volume
    placeable;

simulated event Touch(Actor Other, PrimitiveComponent OtherComp, vector HitLocation, vector HitNormal)
{
    super.Touch(Other, OtherComp, HitLocation, HitNormal);

    if (KFPawn_Monster(Other) != None && !KFPawn_Monster(Other).bVersusZed)
    {
        KFPawn_Monster(Other).bCanJump = false;
    }
}

simulated event Untouch(Actor Other)
{
    super.untouch(Other);

    if (KFPawn_Monster(Other) != None && !KFPawn_Monster(Other).bVersusZed)
    {
        KFPawn_Monster(Other).bCanJump = true;
    }
}