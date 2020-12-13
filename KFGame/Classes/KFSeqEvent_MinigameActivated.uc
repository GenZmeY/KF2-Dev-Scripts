//=============================================================================
// KFSeqEvent_MinigameActivated
//=============================================================================
// Called when a minigame is activated by the user or deactivated by timer
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
// - Dan Weiss
//=============================================================================

class KFSeqEvent_MinigameActivated extends SequenceEvent;

//Activated when the game starts.  Immediate on no-delay, post-delay when that's active.
function NotifyActivation(Actor InInstigator, Actor InTrigger)
{
    local array<int> ActiveIndices;

    ActiveIndices[0] = 0;
    CheckActivate(InInstigator, InTrigger, false, ActiveIndices);
}

//Activated when the game starts if the delay option is eanbled.
function NotifyDelayedActivation(Actor InInstigator, Actor InTrigger)
{
    local array<int> ActiveIndices;

    ActiveIndices[0] = 2;
    CheckActivate(InInstigator, InTrigger, false, ActiveIndices);
}

//Activate when the game is shutting down
function NotifyDeactivation(Actor InInstigator, Actor InTrigger)
{
    local array<int> ActiveIndices;

    ActiveIndices[0] = 1;
    CheckActivate(InInstigator, InTrigger, false, ActiveIndices);
}

//Activate when the game is being started.  Immediate on delayed or non-delayed
function NotifyStartup(Actor InInstigator, Actor InTrigger)
{
    local array<int> ActiveIndices;

    ActiveIndices[0] = 3;
    CheckActivate(InInstigator, InTrigger, false, ActiveIndices);
}

defaultproperties
{
    ObjName = "Minigame Activation"

    OutputLinks.Empty
    OutputLinks(0) = (LinkDesc = "Activated")
    OutputLinks(1) = (LinkDesc = "Deactivated")
    OutputLinks(2) = (LinkDesc = "Delayed Activation")
    OutputLinks(3) = (LinkDesc = "Game Startup")

    bPlayerOnly = false
    MaxTriggerCount = 0
}