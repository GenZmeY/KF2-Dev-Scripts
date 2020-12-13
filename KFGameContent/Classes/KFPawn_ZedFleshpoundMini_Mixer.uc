//=============================================================================
// KFPawn_ZedFleshpoundMini_Mixer
//=============================================================================
// Mixer spawned QP variant.  Handles glow coloring similar to the Vs FP.
//=============================================================================
// Killing Floor 2
// Copyright (C) 2017 Tripwire Interactive LLC
//=============================================================================

class KFPawn_ZedFleshpoundMini_Mixer extends KFPawn_ZedFleshpoundMini;

simulated event bool UsePlayerControlledZedSkin()
{
    return true;
}

defaultproperties
{
}