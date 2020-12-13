//=============================================================================
// KFSeqEvent_PowerUpActivated
//=============================================================================
// Called when a power up is activated or the trigger is reactivated
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//=============================================================================

class KFSeqEvent_PowerUpActivated extends SequenceEvent;

function ActivatePowerUp(Actor InInstigator, Actor InTrigger)
{
    local array<int> ActiveIndices;
    ActiveIndices[0] = 0;
    CheckActivate(InInstigator, InTrigger, false, ActiveIndices);
}

function ReactivateTrigger(Actor InInstigator, Actor InTrigger)
{
    local array<int> ActiveIndices;
    ActiveIndices[0] = 1;
    CheckActivate(InInstigator, InTrigger, false, ActiveIndices);
}

defaultproperties
{
    ObjName = "PowerUp Activated"

    OutputLinks.Empty
    OutputLinks(0)=(LinkDesc="PowerUpActivated")
    OutputLinks(1)=(LinkDesc="TriggerReactivated")

    VariableLinks.Empty

    bPlayerOnly = false
    MaxTriggerCount = 0
}