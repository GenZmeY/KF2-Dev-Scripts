//=============================================================================
// KFSeqEvent_MinigameEndCondition
//=============================================================================
// Called when a winnable minigame ends.  Notifies kismet of victory or defeat.
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
// - Dan Weiss
//=============================================================================

class KFSeqEvent_MinigameEndCondition extends SequenceEvent;

var int LevelCompleted;

function MinigameComplete(Actor InInstigator, bool bVictory, optional int CompletedLevel = 0)
{
    local array<int> ActiveIndices;

    if (bVictory)
    {
        ActiveIndices[0] = 0;
    }
    else
    {
        ActiveIndices[0] = 1;
    }

    LevelCompleted = CompletedLevel;
    CheckActivate(InInstigator, InInstigator, false, ActiveIndices);
}

/** Only called in a multi-level game that is completely finished */
function AllLevelsComplete(Actor InInstigator)
{
    local array<int> ActiveIndices;
    ActiveIndices[0] = 2;
    CheckActivate(InInstigator, InInstigator, false, ActiveIndices);
}

defaultproperties
{
    ObjName = "Minigame End Condition"

    OutputLinks.Empty
    OutputLinks(0) = (LinkDesc = "Victory")
    OutputLinks(1) = (LinkDesc = "Defeat")
    OutputLinks(2) = (LinkDesc = "All Levels Victory")

    VariableLinks.Empty
    VariableLinks(0) = (ExpectedType=class'SeqVar_Int',LinkDesc="CompletedLevel",PropertyName=LevelCompleted)

    bPlayerOnly = false
    MaxTriggerCount = 0
}