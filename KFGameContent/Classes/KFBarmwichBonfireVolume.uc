//=============================================================================
// KFBarmwichBonfireVolume
//=============================================================================
// Barmwich volume used for bonfires. Triggers seasonal progression.
//=============================================================================
// Killing Floor 2
// Copyright (C) 2022 Tripwire Interactive LLC
//=============================================================================

class KFBarmwichBonfireVolume extends KFPhysicsDamageByPawnVolume
    placeable;

/** Objective index for the event this is tied to */
var() int ObjectiveIndex;

/** Index of the event this is tied to */
var() int EventIndex;

var array<Actor> AffectedActors;

var transient bool bIsDataValid;

simulated event PostBeginPlay()
{
	Super.PostBeginPlay();

	bIsDataValid = IsObjectiveDataValid();
}

function CausePainTo(Actor Other)
{
    Super.CausePainTo(Other);

    if (bIsDataValid && KFPawn_Monster(Other) != none && KFPawn_Monster(Other).IsAliveAndWell())
    {
        if (AffectedActors.Find(Other) == INDEX_NONE)
        {
            AffectedActors.AddItem(Other);
            NotifyProgression();
        }  
    }
}

function NotifyProgression()
{
    local KFPlayerController KFPC;

    if (!bIsDataValid)
    {
        return;
    }

    foreach WorldInfo.AllControllers(class'KFPlayerController', KFPC)
    {
        KFPC.ClientOnTryCompleteObjective(ObjectiveIndex, EventIndex);
    }
}

function ClearAllActors()
{
    AffectedActors.Remove(0, AffectedActors.Length);
}

function ClearActor(Actor Other)
{
    AffectedActors.RemoveItem(Other);
}

simulated function bool IsObjectiveDataValid()
{
    return ObjectiveIndex >= 0 && ObjectiveIndex < 5 && EventIndex > SEI_None && EventIndex < SEI_MAX;
}

DefaultProperties
{
    bIsDataValid = false;
}