//=============================================================================
// KFStaticMeshActor_TrackLocalPC
//=============================================================================
// Custom visual class that tracks and rotates to look towards the local PC.
//      Used for map effects.
//=============================================================================
// Killing Floor 2
// Copyright (C) 2017 Tripwire Interactive LLC
// - Dan Weiss
//=============================================================================

class KFStaticMeshActor_TrackLocalPC extends DynamicSMActor
    placeable;

simulated event Tick(float DeltaTime)
{
    local PlayerController PC;
    super.Tick(DeltaTime);

    if (WorldInfo.NetMode != NM_DedicatedServer)
    {
        PC = GetALocalPlayerController();
        if (PC != none && PC.Pawn != none)
        {
            StaticMeshComponent.SetRotation(Rotator(PC.Pawn.Location - Location));
        }
    }
}

defaultproperties
{
    bUpdateSimulatedPosition=true
}