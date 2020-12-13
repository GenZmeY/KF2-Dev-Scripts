//=============================================================================
// KFMG_MultilevelTargetGame
//=============================================================================
// Extension of target game that allows for multiple difficulty levels that 
//      have to be cleared to achieve victory.
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
// - Dan Weiss
//=============================================================================

class KFMG_MultilevelTargetGame extends KFMG_RiggedTargetGame;

/** List of starter buttons.  Once all of these are cleared, the game is "won" */
var() array<KFTrigger_MinigameButton> StarterButtons;

var array<bool> LevelsCleared;

/** Other than the spawning handled in super, make sure we've got our level clear
 *      tracking all setup to match 1:1 with the starter buttons array.
*/
event PostBeginPlay()
{
    super.PostBeginPlay();

    LevelsCleared.Length = StarterButtons.Length;
}

/** Updated activation check with some changes beyond basic super version*/
function bool CanBeActivated(KFTrigger_MinigameButton ActivationSource)
{
    local int Idx;
    Idx = StarterButtons.Find(ActivationSource);

    //Don't activate if this is not hooked up properly
    if (Idx == INDEX_NONE)
    {
        return false;
    }
    //Don't activate if this has already been cleared
    else if (LevelsCleared[Idx])
    {
        return false;
    }

    return !bGameRunning;
}

/** Verify rig index is set prior to calling into super.  That will handle the rest of the target hookups. */
function Activated(KFTrigger_MinigameButton ActivationSource)
{
    RigIndex = StarterButtons.Find(ActivationSource);
    super.Activated(ActivationSource);
}

/** Reset rig index for multilevel game */
function Deactivated()
{
    RigIndex = -1;
    super.Deactivated();
}

/** Reimplementation. Sets current level to complete, and triggers sequence event with the extra info.  Then verifies full completion. */
function MinigameComplete(bool bVictory)
{
    local int Idx;
    local KFSeqEvent_MinigameEndCondition EndCondEvent;
    local int i;

    EndGameState = bVictory ? 0 : 1;
    FinalizeGame();

    Idx = StarterButtons.Find(Activator);
    if (Idx >= 0)
    {
        //Notify Kismet that minigame state has been changed
        for (i = 0; i < GeneratedEvents.Length; i++)
        {
            EndCondEvent = KFSeqEvent_MinigameEndCondition(GeneratedEvents[i]);
            if (EndCondEvent != none)
            {
                EndCondEvent.MinigameComplete(self, bVictory, Idx);
            }
        }

        if (Role == ROLE_Authority && bVictory && Activator != none)
        {
            Activator.Deactivate();
        }

        LevelsCleared[Idx] = bVictory;
        CheckFullCompletion();
    }
}

/** Check that the entire game is complete */
/** @TODO: Prize acquisition tied to full completion here */
function CheckFullCompletion()
{
    local bool bComplete;
    local KFSeqEvent_MinigameEndCondition EndCondEvent;
    local int i;

    foreach LevelsCleared(bComplete)
    {
        if (!bComplete)
        {
            return;
        }
    }

    //If we've gotten this far, all levels are complete
    `log("*** Complete victory!");

    //Notify Kismet that minigame state has been changed
    for (i = 0; i < GeneratedEvents.Length; i++)
    {
        EndCondEvent = KFSeqEvent_MinigameEndCondition(GeneratedEvents[i]);
        if (EndCondEvent != none)
        {
            EndCondEvent.AllLevelsComplete(self);
        }
    }

    //@TODO - Prize acquisition here
    ResetGame();
}

function ResetGame()
{
    super.ResetGame();
    LevelsCleared.Length = 0;
    LevelsCleared.Length = StarterButtons.Length;
}

defaultproperties
{
    bClearControllerOnCompletion = false
    RigIndex = -1
}