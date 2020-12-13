//=============================================================================
// KFMG_RiggedTargetGame
//=============================================================================
// Extension of target game that uses a rigged animation and series of other
//      subactors to handle the individual target hits.
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
// - Dan Weiss
//=============================================================================

class KFMG_RiggedTargetGame extends KFMG_TargetGame;

/** Archetype of target actor that will be spawned per-bone */
var() Actor TargetArchetype;

/** SKL actor used to drive animation of the minigame */
var() repnotify KFMGA_TargetGame MinigameRig;

/** How many targets have not been hit */
var int TargetsRemaining;

/** Which animation index to use (determined by server) */
var repnotify int AnimationIndex;

/** Which rig index to use for grabbing animation data (always 0 in base game, 0...n in multilevel extension) */
var repnotify int RigIndex;

/** Local track variable for the state of the game.  Primarily used for repnotify check to make sure all info has come down */
var bool bLocalStarted;

/** End game state - 0 victory, 1 defeat */
var repnotify int EndGameState;

enum eAnimationState
{
    EAS_Closed, //Inactive state
    EAS_Open,   //Transition to active
    EAS_Active, //Active state
    EAS_Idle,   //Pre-close transition
    EAS_Close,  //Transition to inactive state
};

/** Time to take to blend to new animations (if using an AnimTree) */
var() array<float> BlendToTimes;

replication
{
    if (bNetDirty)
        AnimationIndex, RigIndex, EndGameState;

    if (bNetInitial)
        MinigameRig;
}

simulated event ReplicatedEvent(name VarName)
{
    super.ReplicatedEvent(VarName);

    if (VarName == 'EndGameState')
    {
        if (EndGameState >= 0)
        {
            FinalizeGame();
        }
    }
    else if (VarName == 'AnimationIndex')
    {
        if (!bLocalStarted && AnimationIndex >= 0 && RigIndex >= 0)
        {
            StartupGame();
        }
    }
    else if (VarName == 'RigIndex')
    {
        if (!bLocalStarted && AnimationIndex >= 0 && RigIndex >= 0)
        {
            StartupGame();
        }
    }
    else if (VarName == 'MinigameRig')
    {
        MinigameRig.ParentGame = self;
    }
}

/** Spawn a target per-bone and hide actor.  They will be reset and unhidden on
*     activation of the mini-game.
*/
event PostBeginPlay()
{
    local name BoneName;
    local Actor NewTarget;
    local KFMGA_Target RiggedTarget;
    super.PostBeginPlay();

    MinigameRig.ParentGame = self;
    if (MinigameRig != none && TargetArchetype != none)
    {
        foreach MinigameRig.TargetBones(BoneName)
        {
            NewTarget = spawn(TargetArchetype.class, self, , , , TargetArchetype);
            if (NewTarget != none)
            {
                MinigameTargets.AddItem(NewTarget);
                NewTarget.SetBase(MinigameRig, , MinigameRig.SkeletalMeshComponent, BoneName);

                RiggedTarget = KFMGA_Target(NewTarget);
                if (RiggedTarget != none)
                {
                    RiggedTarget.SetInactive();
                    RiggedTarget.SpawnerOwner = self;
                    RiggedTarget.SpawnerOwnerIndex = MinigameTargets.Length - 1;
                }
            }
        }
    }
}

simulated function Reset()
{
    local int i;

    super.Reset();

    SwitchAnim(EAS_Closed);
    if (!MinigameRig.SkeletalMeshComponent.Animations.IsA('AnimTree'))
    {
        MinigameRig.SkeletalMeshComponent.StopAnim();
    }

    //Enable server optimization for the minigame rig while it's not running
    MinigameRig.SetTickIsDisabled(true);

    bLocalStarted = false;

    for (i = 0; i < MinigameTargets.Length; ++i)
    {
        MinigameTargets[i].Reset();
    }
}

//Activate target game.  All authority stuff should be done here.  Generic stuff should be done in StartupGame
function Activated(KFTrigger_MinigameButton ActivationSource)
{
    if (RigIndex >= 0 && MinigameRig != none && (MinigameRig.MinigameAnimData.Length > 0 || MinigameRig.SkeletalMeshComponent.AnimTreeTemplate != none) && MinigameTargets.Length == MinigameRig.TargetBones.Length)
    {
        super.Activated(ActivationSource);

        TargetsRemaining = MinigameTargets.Length;
        AnimationIndex = MinigameRig.MinigameAnimData[RigIndex].MinigameAnimations.Length > 0 ? Rand(MinigameRig.MinigameAnimData[RigIndex].MinigameAnimations.Length) : -1;
        StartupGame();
        EndGameState = -1;
    }
}

/** Handles animation functionality for a rigged target game.  If the base is an animtree, sets a blend list.
 *      If the rig uses straight animations, calls a playanim.
 */
simulated function SwitchAnim(eAnimationState SelectedState)
{
    local name AnimName;
    local bool bLoop;
    local AnimNodeBlendList BlendList;

    //Set blend node in the animtree
    if (MinigameRig.SkeletalMeshComponent.Animations.IsA('AnimTree'))
    {
        BlendList = AnimNodeBlendList(MinigameRig.SkeletalMeshComponent.FindAnimNode('StateBlend'));
        if (BlendList != none)
        {
            BlendList.SetActiveChild(SelectedState, BlendToTimes[SelectedState]);
        }
    }
    //Play animations directly
    else
    {
        bLoop = false;
        switch(SelectedState)
        {
        case EAS_Closed:
            AnimName = MinigameRig.IdleClosedAnim;
            bLoop = true;
            break;
        case EAS_Open:
            AnimName = MinigameRig.GameStartAnim;
            break;
        case EAS_Active:
            AnimName = MinigameRig.MinigameAnimData[RigIndex].MinigameAnimations[AnimationIndex];
            bLoop = true;
            break;
        case EAS_Idle:
            AnimName = MinigameRig.IdleOpenAnim;
            break;
        case EAS_Close:
            AnimName = MinigameRig.GameEndAnim;
            break;
        }

        if (AnimName != 'none')
        {
            MinigameRig.SkeletalMeshComponent.PlayAnim(AnimName, , bLoop);
        }        
    }
}

simulated function StartupGame()
{
    local float StartupTime;

    //Disable server optimization for the minigame rig
    MinigameRig.SetTickIsDisabled(false);
    StartupTime = MinigameRig.SkeletalMeshComponent.GetAnimLength(MinigameRig.GameStartAnim);

    if (MinigameRig.SkeletalMeshComponent.AnimTreeTemplate != none && !MinigameRig.SkeletalMeshComponent.Animations.IsA('AnimTree'))
    {
        MinigameRig.SkeletalMeshComponent.SetAnimTreeTemplate(MinigameRig.SkeletalMeshComponent.AnimTreeTemplate);
    }

    if (StartupTime > 0)
    {
        SetTimer(StartupTime, false, 'DelayedStart');
        if (WorldInfo.NetMode != NM_DedicatedServer)
        {
            SwitchAnim(EAS_Open);
        }        
    }
    else
    {
        DelayedStart();
    }

    EndGameState = -1;
    bLocalStarted = true;
}

simulated function DelayedStart()
{
    local int i;
    SwitchAnim(EAS_Active);

    //For each of the targets, reset and set the base to a specified bone.  Gives us clean a target per-bone
    //      without the need to spin up a new actor per-bone every time we start the minigame.
    for (i = 0; i < MinigameTargets.Length; ++i)
    {
        MinigameTargets[i].SetBase(MinigameRig, , MinigameRig.SkeletalMeshComponent, MinigameRig.TargetBones[i]);
        MinigameTargets[i].Reset();
        if (KFMGA_Target(MinigameTargets[i]) != none)
        {
            KFMGA_Target(MinigameTargets[i]).AttachBoneName = MinigameRig.TargetBones[i];
            KFMGA_Target(MinigameTargets[i]).SetActive();
        }
    }
}

/** Called by target when it's been hit by a valid damage source */
function TargetHit(Actor Target, Controller HitInstigator)
{
    if (bGameRunning && MinigameTargets.Find(Target) != INDEX_NONE)
    {
        TargetsRemaining--;

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
    Target.SetBase(MinigameRig, , MinigameRig.SkeletalMeshComponent, MinigameRig.TargetBones[Target.SpawnerOwnerIndex]);
}

/** Called on rigged games to check whether a target at a specific bone can be played */
simulated event bool CanPlayAkEvent(Actor inOwner, name BoneName)
{
    local KFMGA_Target Target;
    local int i;

    for (i = 0; i < MinigameTargets.Length; ++i)
    {
        Target = KFMGA_Target(MinigameTargets[i]);
        if (Target != none && Target.AttachBoneName == BoneName)
        {
            return Target.IsAlive();
        }
    }

    return false;
}

function MinigameComplete(bool bVictory)
{
    EndGameState = bVictory ? 0 : 1;
    super.MinigameComplete(bVictory);
}

/** Do any cleanup that happens for either victory or defeat */
simulated function FinalizeGame()
{
    local Actor Target;

    super.FinalizeGame();

    AnimationIndex = -1;
    foreach MinigameTargets(Target)
    {
        if (KFMGA_Target(Target) != none)
        {
            KFMGA_Target(Target).SetInactive();
        }
    }

    HandleDelayedShutdown();
}

simulated function HandleDelayedShutdown()
{
    local float DelayTime;

    switch (EndGameState)
    {
    case 0: //victory
        DelayTime = MinigameRig.PostVictoryIdleTime;     
        break;
    case 1: //defeat
        DelayTime = MinigameRig.PostDefeatIdleTime;    
        break;
    }

    if (DelayTime > 0)
    {
        SetTimer(DelayTime, false, 'Finalize');
        if (WorldInfo.NetMode != NM_DedicatedServer)
        {
            SwitchAnim(EAS_Idle);
        }
    }
    else
    {
        Finalize();
    }   
}

simulated function Finalize()
{
    local int i;
    local float ResetTime;

    for (i = 0; i < MinigameTargets.Length; ++i)
    {
        if (KFMGA_Target(MinigameTargets[i]) != none)
        {
            KFMGA_Target(MinigameTargets[i]).Finalize();
        }
    }

    ResetTime = MinigameRig.SkeletalMeshComponent.GetAnimLength(MinigameRig.GameEndAnim);
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
        SwitchAnim(EAS_Close);
    }
}

defaultproperties
{
    AnimationIndex = -1

    BlendToTimes=(0.f,0.f,0.f,0.5f,0.f)
}