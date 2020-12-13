//=============================================================================
// KFDynamicPhysicsVolume
//=============================================================================
// Replacement for DynamicPhysicsVolume extended from our KFPhysicsVolume.
//=============================================================================
// Killing Floor 2
// Copyright (C) 2017 Tripwire Interactive LLC
// Dan Weiss
//=============================================================================
class KFDynamicPhysicsVolume extends KFPhysicsVolume
    showcategories(Movement)
    placeable;

/** Is the volume enabled by default? */
var() bool bEnabled;

/**
* Overriden to set the default collision state.
*/
simulated event PostBeginPlay()
{
    Super.PostBeginPlay();

    SetCollision(bEnabled, bBlockActors);
}

defaultproperties
{
    Physics=PHYS_Interpolating
    bStatic=false

    bAlwaysRelevant=true
    bReplicateMovement=true
    bOnlyDirtyReplication=true
    RemoteRole=ROLE_None

    bColored=true
    BrushColor=(R=100,G=255,B=255,A=255)

    bEnabled=true
}
