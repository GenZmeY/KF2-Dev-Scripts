//=============================================================================
// KFMGVolume_SwingHit
//=============================================================================
// Volume for the swing minigame. Does some shenanigans above our normal
//      systems to throw both a ragdolled Zed, as well as human momentum.
//
// Note: Maintained class after rename/refactor to avoid needing to update
//      the Tragic Kingdom functionality.
//=============================================================================
// Killing Floor 2
// Copyright (C) 2017 Tripwire Interactive LLC
// Dan Weiss
//=============================================================================

class KFMGVolume_SwingHit extends KFVolume_RagdollThrow
    placeable;

defaultproperties
{
    bFixedThrowVector=false
}