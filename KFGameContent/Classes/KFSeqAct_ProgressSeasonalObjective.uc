//=============================================================================
// KFSeqAct_ProgressSeasonalObjective
//=============================================================================
// Sequence action to allow a map to have add progress to seasonal objectives
//=============================================================================
// Killing Floor 2
// Copyright (C) 2020 Tripwire Interactive LLC
//=============================================================================

class KFSeqAct_ProgressSeasonalObjective extends SequenceAction;

/** Objective index for the event this is tied to */
var() int ObjectiveIndex;

/** Index of the event this is tied to */
var() int EventIndex;

/** Increment progress for all players? */
var() bool bAllPlayersAffected;

event Activated()
{
    local KFPlayercontroller KFPC;
	local bool bIsObjectiveDataValid;

	bIsObjectiveDataValid = ObjectiveIndex >= 0 && ObjectiveIndex < 5 && EventIndex > SEI_None && EventIndex < SEI_MAX;

    if (bAllPlayersAffected)
    {
        foreach GetWorldInfo().AllControllers(class'KFPlayerController', KFPC)
        {
            if(bIsObjectiveDataValid)
            {
                KFPC.ClientOnTryCompleteObjective(ObjectiveIndex, EventIndex);
            }
        }
    }
    else
    {
        KFPC = KFPlayerController(GetWorldInfo().GetALocalPlayerController());
        if(bIsObjectiveDataValid)
        {
            KFPC.ClientOnTryCompleteObjective(ObjectiveIndex, EventIndex);
        }
    }
}

defaultproperties
{
    ObjName="Progress Seasonal Objective"
    ObjCategory="Killing Floor"

    ObjectiveIndex=-1
    EventIndex=-1
    bAllPlayersAffected=true
}