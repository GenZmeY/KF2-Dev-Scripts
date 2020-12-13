//=============================================================================
// KFSeqEvent_MinigameStateChanged
//=============================================================================
// Called when a minigame trigger is activated or deactivated via generator
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
// - Dan Weiss
//=============================================================================

class KFSeqEvent_MinigameStateChanged extends SequenceEvent;

function StateChanged(Actor InInstigator, Actor InTrigger, bool bIsActive)
{
    if (bIsActive)
    {
        ActivateOutputLink(0);
    }
    else
    {
        ActivateOutputLink(1);
    }
}

defaultproperties
{
    ObjName = "Minigame State Changed"

    OutputLinks.Empty
    OutputLinks(0) = (LinkDesc = "Active")
    OutputLinks(1) = (LinkDesc = "Inactive")

    VariableLinks.Empty

    bPlayerOnly = false
    MaxTriggerCount = 0
}