//=============================================================================
// KFInterface_MinigameTarget
//=============================================================================
// Interface for any code-facing minigame targets.
//=============================================================================
// Killing Floor 2
// Copyright (C) 2017 Tripwire Interactive LLC
// - Dan Weiss
//=============================================================================

interface KFInterface_MinigameTarget;

function ValidHit(Controller EventInstigator, Actor HitActor);
function InvalidHit(Controller EventInstigator, Actor HitActor);
simulated function bool IsAlive();