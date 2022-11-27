

//=============================================================================
// KFShotgunJumpEndVolume
//=============================================================================
// Barmwich volume used tracking the start of shotgun jumps.
//=============================================================================
// Killing Floor 2
// Copyright (C) 2022 Tripwire Interactive LLC
//=============================================================================

class KFShotgunJumpEndVolume extends PhysicsVolume
    placeable;

/** Objective index for the event this is tied to */
var() int ObjectiveIndex;

/** Index of the event this is tied to */
var() int EventIndex;

/** All volumes that track the begin of a shotgun jump in the area */
var() array<KFShotgunJumpStartVolume> LinkedVolumes;

var transient bool bIsDataValid;

var array<KFPlayerController> SucceededControllers;

simulated event PostBeginPlay()
{
	Super.PostBeginPlay();

	bIsDataValid = IsObjectiveDataValid();

    if (LinkedVolumes.Length == 0)
    {
        `warn("Volume [" $self $"] has no linked volumes (KFShotgunJumpStartVolume).");
    }
}

simulated event Touch( Actor Other, PrimitiveComponent OtherComp, vector HitLocation, vector HitNormal )
{
    local KFPawn_Human KFPH;
    local KFPlayerController KFPC;
    local KFShotgunJumpStartVolume StartVolume;

    KFPH = KFPawn_Human(Other);
    if (KFPH == none)
    {
        return;
    }

    KFPC = KFPlayerController(KFPH.Controller);

    if (KFPC == none || IsCompletedByController(KFPC))
        return;

    foreach LinkedVolumes(StartVolume)
    {
        if (StartVolume.IsPlayerTracked(KFPC))
        {
            StartVolume.RemoveTrackedPlayer(KFPC);
            if (KFPC.bShotgunJumping)
            {
                SucceededControllers.AddItem(KFPC);
                KFPC.ClientOnTryCompleteObjective(ObjectiveIndex, EventIndex);
            }
            return;
        }
    }
}

simulated function bool IsCompletedByController(KFPlayerController Controller)
{
    local KFPlayerController Current;

    foreach SucceededControllers(Current)
    {
        if (Controller == Current)
        {
            return true;
        }
    }

    return false;
}

simulated function bool IsObjectiveDataValid()
{
    return ObjectiveIndex >= 0 && ObjectiveIndex < 5 && EventIndex > SEI_None && EventIndex < SEI_MAX;
}

DefaultProperties
{
    bIsDataValid = false
}