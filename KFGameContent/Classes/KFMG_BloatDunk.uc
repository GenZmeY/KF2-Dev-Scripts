//=============================================================================
// KFMG_BloatDunk
//=============================================================================
// Extension of target game with specifics tied to bloat dunk.  Uses a more
//      complicated two rig setup for the wheels, each manually rotated, with
//      independent attachment points on each.  Every x seconds, picks a random
//      light from each rig to enable to be shot.
//=============================================================================
// Killing Floor 2
// Copyright (C) 2016 Tripwire Interactive LLC
// - Dan Weiss
//=============================================================================

class KFMG_BloatDunk extends KFMG_TargetGame;

/** Archetype of target actor that will be spawned per-bone */
var() Actor TargetArchetype;

/** Two rigs used for alternately rotating wheels */
var() KFMGA_TargetGame OuterWheel;
var() KFMGA_TargetGame InnerWheel;

/** Dunk tank rig for handling curtain/dunk board */
var() SkeletalMeshActor DunkTankRig;

/** Bloat being dunked */
var() SkeletalMeshActor BloatRig;

/** How often to activate a new set of targets */
var() float TargetActivationDelay;

/** How fast to begin rotation */
var() float StartingRotationRate;

/** How much to increase rotation per-target hit */
var() float PerHitRotationIncrease;

/** How many targets to activate per attempt */
var() int NumActiveTargets;

/** Current rotation rate */
var float CurrentRotationRate;

/** How many targets have not been hit */
var int TargetsRemaining;

enum eBloatGameState
{
    BGS_Off,
    BGS_On,
    BGS_Victory,
    BGS_Defeat,
};

/** What state the game is currently in */
var repnotify eBloatGameState BloatGameState;

//-------------------
// Animation

/** Standard idle while game is off */
var() name IdleClosedAnim;

/** Standard idle while game is being played */
var() name IdleOpenAnim;

/** Animation played on game start */
var() name OpenAnim;

/** Played on victory to dunk the bloat */
var() name DunkVictoryAnim;

/** Victory close animation */
var() name VictoryCloseAnim;

/** Defeat close animation */
var() name DefeatCloseAnim;

replication
{
    if (bNetInitial)
        OuterWheel, InnerWheel, DunkTankRig, BloatRig;

    if (bNetDirty)
        CurrentRotationRate, BloatGameState;
}

simulated event ReplicatedEvent(name VarName)
{
    super.ReplicatedEvent(VarName);

    if (VarName == 'bGameRunning')
    {
        if (bGameRunning)
        {
            HandleDelayedStartup();
        }
    }

    if (VarName == 'bGameRunning' || VarName == 'BloatGameState')
    {
        if (!bGameRunning && BloatGameState > BGS_On)
        {
            FinalizeGame();
        }
    }
}

simulated event Tick(float DeltaTime)
{
    local Rotator NewRotation;
    super.Tick(DeltaTime);

    if (bGameRunning)
    {
        NewRotation = OuterWheel.Rotation;
        NewRotation.Pitch = (NewRotation.Pitch + (CurrentRotationRate * DeltaTime)) % 65536;
        OuterWheel.SetRotation(NewRotation);

        NewRotation = InnerWheel.Rotation;
        NewRotation.Pitch = (NewRotation.Pitch - (CurrentRotationRate * DeltaTime)) % 65536;
        InnerWheel.SetRotation(NewRotation);
    }    
}

/** Spawn a target per-bone and hide actor.  They will be reset and unhidden on
*     activation of the mini-game.
*/
event PostBeginPlay()
{
    local name BoneName;
    super.PostBeginPlay();

    if (InnerWheel != none && OuterWheel != none && TargetArchetype != none)
    {
        foreach InnerWheel.TargetBones(BoneName)
        {
            SpawnTarget(InnerWheel, BoneName);
        }

        foreach OuterWheel.TargetBones(BoneName)
        {
            SpawnTarget(OuterWheel, BoneName);
        }
    }

    Reset();
}

function SpawnTarget(KFMGA_TargetGame Wheel, name BoneName)
{
    local Actor NewTarget;
    local KFMGA_Target RiggedTarget;

    NewTarget = spawn(TargetArchetype.class, self, , , , TargetArchetype);
    if (NewTarget != none)
    {
        MinigameTargets.AddItem(NewTarget);
        NewTarget.SetBase(Wheel, , Wheel.SkeletalMeshComponent, BoneName);

        RiggedTarget = KFMGA_Target(NewTarget);
        if (RiggedTarget != none)
        {
            RiggedTarget.SetInactive();
            RiggedTarget.SpawnerOwner = self;
            RiggedTarget.SpawnerOwnerIndex = MinigameTargets.Length - 1;
            UpdateBase(RiggedTarget);
        }
    }
}

//Activate target game.  All authority stuff should be done here.  Generic stuff should be done in StartupGame
function Activated(KFTrigger_MinigameButton ActivationSource)
{
    if (MinigameTargets.Length == (OuterWheel.TargetBones.Length + InnerWheel.TargetBones.Length))
    {
        super.Activated(ActivationSource);

        BloatGameState = BGS_On;
        TargetsRemaining = MinigameTargets.Length;
        HandleDelayedStartup();
    }
}

simulated function Reset()
{
    super.Reset();
    CurrentRotationRate = 0;
    BloatRig.SkeletalMeshComponent.StopAnim();
}

simulated function HandleDelayedStartup()
{
    local float AnimLength;
    local int i;
    local Vector NewLocation;
    local Rotator NewRotation;

    //Disable server optimization for the minigame rig
    InnerWheel.SetTickIsDisabled(false);

    //For each of the targets, reset and set the base to a specified bone.  Gives us clean a target per-bone
    //      without the need to spin up a new actor per-bone every time we start the minigame.
    for (i = 0; i < InnerWheel.TargetBones.Length; ++i)
    {
        MinigameTargets[i].Reset();
        MinigameTargets[i].SetBase(InnerWheel, , InnerWheel.SkeletalMeshComponent, InnerWheel.TargetBones[i]);
    }

    //Disable server optimization for the minigame rig
    OuterWheel.SetTickIsDisabled(false);

    //For each of the targets, reset and set the base to a specified bone.  Gives us clean a target per-bone
    //      without the need to spin up a new actor per-bone every time we start the minigame.
    for (i = 0; i < OuterWheel.TargetBones.Length; ++i)
    {
        MinigameTargets[InnerWheel.TargetBones.Length + i].Reset();
        MinigameTargets[InnerWheel.TargetBones.Length + i].SetBase(OuterWheel, , OuterWheel.SkeletalMeshComponent, OuterWheel.TargetBones[i]);
    }

    if (WorldInfo.NetMode != NM_DedicatedServer && BloatRig != none)
    {
        if (DunkTankRig.SkeletalMeshComponent.GetSocketWorldLocationAndRotation('BloatAttach', NewLocation, NewRotation))
        {
            BloatRig.SetLocation(NewLocation);
            BloatRig.SetRotation(NewRotation);
        }
        BloatRig.SetPhysics(PHYS_None);
        BloatRig.SetBase(DunkTankRig, , DunkTankRig.SkeletalMeshComponent, 'Root');
        BloatRig.SkeletalMeshComponent.PlayAnim('BloatDunk_Idle', , true);
    }    

    //If we have a rig and animation, delay activation of the game startup until after the open animation has been kicked
    //  Otherwise, simply skip to start
    if (DunkTankRig != none)
    {
        AnimLength = DunkTankRig.SkeletalMeshComponent.GetAnimLength(OpenAnim);
        if (AnimLength > 0.f)
        {
            SetTimer(AnimLength, false, 'StartupGame');
            if (WorldInfo.NetMode != NM_DedicatedServer)
            {
                DunkTankRig.SkeletalMeshComponent.PlayAnim(OpenAnim);
            }            
        }
        else
        {
            StartupGame();
        }
    }
    else
    {
        StartupGame();
    }
}

simulated function StartupGame()
{
    if (WorldInfo.NetMode != NM_DedicatedServer)
    {
        DunkTankRig.SkeletalMeshComponent.PlayAnim(IdleOpenAnim, , true);
    }    

    if (Role == ROLE_Authority)
    {
        CurrentRotationRate = StartingRotationRate;
        ActivateTargets();
        SetTimer(TargetActivationDelay, true, 'ActivateTargets');
    }
}

/** Find a random target per wheel and activate it.  Deactivate */
function ActivateTargets()
{
    local int i, Activated;
    local array<Actor> RandLookupList;

    //Deactivate old targets
    for (i = 0; i < MinigameTargets.Length; ++i)
    {
        if (KFMGA_Target(MinigameTargets[i]) != none)
        {
            KFMGA_Target(MinigameTargets[i]).SetInactive();
        }
    }

    //Get two random targets for now
    RandLookupList = MinigameTargets;
    while (RandLookupList.Length > 0 && Activated < NumActiveTargets)
    {
        i = Rand(RandLookupList.Length);
        if (KFMGA_Target(RandLookupList[i]).IsAlive())
        {
            Activated++;
            KFMGA_Target(RandLookupList[i]).SetActive();
        }
        RandLookupList.Remove(i, 1);
    }
}

/** Called by target when it's been hit by a valid damage source */
function TargetHit(Actor Target, Controller HitInstigator)
{
    if (bGameRunning && MinigameTargets.Find(Target) != INDEX_NONE)
    {
        TargetsRemaining--;
        CurrentRotationRate += PerHitRotationIncrease;

        if (HitInstigator != none && KillerControllers.Find(HitInstigator) == INDEX_NONE)
        {
            KillerControllers.AddItem(HitInstigator);
        }

        if (TargetsRemaining <= 0)
        {
            MinigameComplete(true);
        }
    }
}

/** Called on clients to fixup the object's base after first replication */
simulated function UpdateBase(KFMGA_Target Target)
{
    if (Target.SpawnerOwnerIndex < InnerWheel.TargetBones.Length)
    {
        Target.SetBase(InnerWheel, , InnerWheel.SkeletalMeshComponent, InnerWheel.TargetBones[Target.SpawnerOwnerIndex]);
    }
    else
    {
        Target.SetBase(OuterWheel, , OuterWheel.SkeletalMeshComponent, OuterWheel.TargetBones[Target.SpawnerOwnerIndex - InnerWheel.TargetBones.Length]);
    }    
}

function MinigameComplete(bool bVictory)
{
    BloatGameState = bVictory ? BGS_Victory : BGS_Defeat;
    super.MinigameComplete(bVictory);
}

/** Do any cleanup that happens for either victory or defeat */
simulated function FinalizeGame()
{
    local Actor Target;

    super.FinalizeGame();

    ClearTimer('ActivateTargets');

    foreach MinigameTargets(Target)
    {
        if (KFMGA_Target(Target) != none)
        {
            KFMGA_Target(Target).SetInactive();
        }        
    }

    //Enable server optimization for the minigame rig while it's not running
    InnerWheel.SetTickIsDisabled(false);
    OuterWheel.SetTickIsDisabled(false);

    HandleDelayedShutdown();
}

/** Animation handling for delayed shutdown */
simulated function HandleDelayedShutdown()
{
    local float DelayTime;
    local name DelayedShutdownAnim;

    switch (BloatGameState)
    {
    case BGS_Victory:
        DelayTime = DunkTankRig.SkeletalMeshComponent.GetAnimLength(DunkVictoryAnim);
        DelayedShutdownAnim = DunkVictoryAnim;
        SetTimer(DelayTime * 2.f, false, 'FinalizeVictory');
        break;
    case BGS_Defeat:
        DelayTime = DunkTankRig.SkeletalMeshComponent.GetAnimLength(DefeatCloseAnim);
        DelayedShutdownAnim = DefeatCloseAnim;
        SetTimer(DelayTime, false, 'Reset');
        break;
    }

    if (WorldInfo.NetMode != NM_DedicatedServer)
    {
        DunkTankRig.SkeletalMeshComponent.PlayAnim(DelayedShutdownAnim);
        if (BloatGameState == BGS_Victory)
        {
            SetBloatRagdoll();
        }
    }    
}

simulated function SetBloatRagdoll()
{
    if (BloatRig == none)
    {
        return;
    }

    BloatRig.SkeletalMeshComponent.StopAnim();

    //PrepareRagdoll
    BloatRig.SkeletalMeshComponent.bUpdateSkelWhenNotRendered = true;
    if (BloatRig.SkeletalMeshComponent.bNotUpdatingKinematicDueToDistance)
    {
        BloatRig.SkeletalMeshComponent.ForceSkelUpdate();
        BloatRig.SkeletalMeshComponent.UpdateRBBonesFromSpaceBases(TRUE, TRUE);
        BloatRig.SkeletalMeshComponent.SetBlockRigidBody(TRUE);
    }

    //InitRagdoll
    BloatRig.SkeletalMeshComponent.PhysicsWeight = 1.0f;
    BloatRig.SkeletalMeshComponent.SetHasPhysicsAssetInstance(true);
    BloatRig.SetPhysics(PHYS_RigidBody);
    BloatRig.SkeletalMeshComponent.PhysicsAssetInstance.SetAllBodiesFixed(false);
    BloatRig.SkeletalMeshComponent.WakeRigidBody();

    //PlayRagdollDeath
    BloatRig.SkeletalMeshComponent.SetActorCollision(TRUE, FALSE);
    BloatRig.SkeletalMeshComponent.bUpdateJointsFromAnimation = FALSE;
    BloatRig.SkeletalMeshComponent.SetRBChannel(RBCC_KnockedDownPawn);
    BloatRig.SkeletalMeshComponent.SetRBCollidesWithChannel(RBCC_KnockedDownPawn, TRUE);
    BloatRig.SkeletalMeshComponent.SetRBCollidesWithChannel(RBCC_Pawn, FALSE);
    BloatRig.SkeletalMeshComponent.SetRBCollidesWithChannel(RBCC_DeadPawn, FALSE);
}

simulated function FinalizeVictory()
{
    local float ResetTime;
    
    ResetTime = DunkTankRig.SkeletalMeshComponent.GetAnimLength(VictoryCloseAnim);
    if (ResetTime > 0.f)
    {
        SetTimer(ResetTime, false, 'Reset');
    }
    else
    {
        Reset();
    }

    if (WorldInfo.NetMode != NM_DedicatedServer)
    {
        DunkTankRig.SkeletalMeshComponent.PlayAnim(VictoryCloseAnim);
    }
}

defaultproperties
{
    TargetActivationDelay = 2.f

    StartingRotationRate = 500
    PerHitRotationIncrease = 100
    NumActiveTargets = 2

    BloatGameState = BGS_Off

    //-------------------
    // Animation
    IdleClosedAnim = Idle_Close
    IdleOpenAnim = Idle_Open
    OpenAnim = Open
    DunkVictoryAnim = Dunk
    VictoryCloseAnim = Close_Win
    DefeatCloseAnim = Close_lost
}