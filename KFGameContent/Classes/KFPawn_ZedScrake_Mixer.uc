//=============================================================================
// KFPawn_ZedScrake_Mixer
//=============================================================================
// Mixer spawned Scrake variant.  Handles glow coloring similar to the Vs FP.
//=============================================================================
// Killing Floor 2
// Copyright (C) 2017 Tripwire Interactive LLC
//=============================================================================

class KFPawn_ZedScrake_Mixer extends KFPawn_ZedScrake;

simulated event bool UsePlayerControlledZedSkin()
{
    return true;
}

defaultproperties
{
}