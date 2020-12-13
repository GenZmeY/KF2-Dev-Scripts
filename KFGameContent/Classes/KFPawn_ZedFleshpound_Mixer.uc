//=============================================================================
// KFPawn_ZedFleshpound_Mixer
//=============================================================================
// Mixer spawned FP variant.  Handles glow coloring similar to the Versus FP.
//=============================================================================
// Killing Floor 2
// Copyright (C) 2017 Tripwire Interactive LLC
//=============================================================================

class KFPawn_ZedFleshpound_Mixer extends KFPawn_ZedFleshpound;

simulated event bool UsePlayerControlledZedSkin()
{
    return true;
}

defaultproperties
{
}