

//=============================================================================
// KFShotgunJumpStartVolume
//=============================================================================
// Barmwich volume used tracking the start of shotgun jumps.
//=============================================================================
// Killing Floor 2
// Copyright (C) 2022 Tripwire Interactive LLC
//=============================================================================

class KFShotgunJumpStartVolume extends PhysicsVolume
    placeable;

/** Max time we keep track of players */
var() float TrackedPlayerLifetime;

var	Info ShotgunJumpVolumeTimer;

struct KFTrackedController
{
    var KFPlayerController KFPC;
    var float ExitTimestamp;
    var bool bInVolume;

    structdefaultproperties
    {
        KFPC=none
        ExitTimestamp=0
        bInVolume=false
    }
};

var transient array<KFTrackedController> TrackedControllers;

simulated event PostBeginPlay()
{
	Super.PostBeginPlay();

	if ( Role < ROLE_Authority )
		return;

    ShotgunJumpVolumeTimer = Spawn(class'VolumeTimer', self);
}

simulated event Touch( Actor Other, PrimitiveComponent OtherComp, vector HitLocation, vector HitNormal )
{
    local KFPawn_Human KFPH;
    local KFPlayerController KFPC;
    local KFTrackedController NewTrackedController;
    local int i;
    
    KFPH = KFPawn_Human(Other);
    if (KFPH == none)
    {
        return;
    }

    KFPC = KFPlayerController(KFPH.Controller);
    if (KFPC == none)
        return;

    for (i = 0; i < TrackedControllers.Length; ++i)
    {
        if (TrackedControllers[i].KFPC == KFPC)
        {
            TrackedControllers[i].bInVolume = true;
            return;
        }
    }

    // Update current time
    NewTrackedController.KFPC = KFPC;
    NewTrackedController.bInVolume = true;
    
    TrackedControllers.AddItem(NewTrackedController);
}

simulated event Untouch(Actor Other)
{
    local KFPawn_Human KFPH;
    local int i;
    local KFPlayerController KFPC;

    KFPH = KFPawn_Human(Other);
    if (KFPH == none)
    {
        return;
    }

    KFPC = KFPlayerController(KFPH.Controller);
    if (KFPC == none)
        return;
    
    for (i = 0; i < TrackedControllers.Length; ++i)
    {
        if (TrackedControllers[i].KFPC == KFPC)
        {
            TrackedControllers[i].ExitTimestamp = WorldInfo.TimeSeconds;
            TrackedControllers[i].bInVolume = false;

            return;
        }
    }
}

function TimerPop(VolumeTimer T)
{
    local int i;

    for (i = TrackedControllers.Length-1; i >= 0 ; --i)
    {
        if (!TrackedControllers[i].bInVolume && (`TimeSince(TrackedControllers[i].ExitTimestamp) >= TrackedPlayerLifetime) )
        {
            TrackedControllers.Remove(i, 1);
        }
    }
}

function RemoveTrackedPlayer(KFPlayerController KFPC)
{
    local int i;

    for (i = TrackedControllers.Length-1; i >= 0 ; --i)
    {
        if (TrackedControllers[i].KFPC == KFPC)
        {
            TrackedControllers.Remove(i, 1);
            return;
        }
    }
}

function bool IsPlayerTracked(KFPlayerController KFPC)
{
    local KFTrackedController TrackedController;
    foreach TrackedControllers(TrackedController)
    {
        if (TrackedController.KFPC == KFPC)
        {
            return true;
        }
    }

    return false;
}

DefaultProperties
{
    TrackedPlayerLifetime = 1.0f; 
}