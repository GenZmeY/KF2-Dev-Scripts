//=============================================================================
// KFMG_TargetGame
//=============================================================================
// Base target game functionality.  Basic code for any win/lose style minigame
//      where a target has to be hit to win.
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
// - Dan Weiss
//=============================================================================

class KFMG_TargetGame extends Actor
    placeable
    implements(KFInterface_MinigameActor);

/** Active game flag */
var repnotify bool bGameRunning;

/** Button or cash box that activated the game */
var KFTrigger_MinigameButton Activator;

/** List of controllers that have killed at least one target in any of the linked levels of this game */
var array<Controller> KillerControllers;

/** Whether or not controller list should be cleared on round finish */
var() bool bClearControllerOnCompletion;

/** Actors spawned for tracking purposes */
var array<Actor> MinigameTargets;

/** Event index (Ex: 1 = Summer sideshow) for stat tracking */
var() int EventIndex;

/** Objective index (Ex: 1 = pop the clot) for stat tracking */
var() int ObjectiveIndex;

replication
{
    if (bNetDirty)
        bGameRunning;
}

function Activated(KFTrigger_MinigameButton ActivationSource)
{
    bGameRunning = true;
    Activator = ActivationSource;
}

function Deactivated()
{
    if (bGameRunning)
    {
        MinigameComplete(false);
    }    
}

/** Don't allow activation while the game is running */
function bool CanBeActivated(KFTrigger_MinigameButton ActivationSource)
{
    return !bGameRunning;
}

/** Called on clients to fixup the object's base after first replication */
simulated function UpdateBase(KFMGA_Target Target);

/** Called on rigged games to check whether a target at a specific bone can be played */
simulated event bool CanPlayAkEvent(Actor inOwner, name BoneName)
{
    return true;
}

/** Called by target when it's been hit by a valid damage source */
function TargetHit(Actor Target, Controller HitInstigator)
{
    if (bGameRunning)
    {
        if (HitInstigator != none && KillerControllers.Find(HitInstigator) == INDEX_NONE)
        {
            KillerControllers.AddItem(HitInstigator);
        }

        MinigameComplete(true);
    }
}

/** Do any cleanup that happens for either victory or defeat */
simulated function FinalizeGame()
{
    if (Role == ROLE_Authority)
    {
        bGameRunning = false;

        if (bClearControllerOnCompletion)
        {
            KillerControllers.Length = 0;
        }
    }    
}

/** Do any full reset cleanup here */
function ResetGame()
{
    KillerControllers.Length = 0;
}

/** End Conditions */
function MinigameComplete(bool bVictory)
{
    local KFSeqEvent_MinigameEndCondition EndCondEvent;
    local int i;

    if (bVictory && Role == ROLE_Authority)
    {
        NotifyWinners();
    }

    FinalizeGame();

    //Notify Kismet that minigame state has been changed
    for (i = 0; i < GeneratedEvents.Length; i++)
    {
        EndCondEvent = KFSeqEvent_MinigameEndCondition(GeneratedEvents[i]);
        if (EndCondEvent != none)
        {
            EndCondEvent.MinigameComplete(self, bVictory);
        }
    }

    if (Role == ROLE_Authority && Activator != none)
    {
        Activator.Deactivate();
    }
}

private final function NotifyWinners()
{
    local Controller Controller;

    foreach KillerControllers(Controller)
    {
        if (KFPlayerController(Controller) != none)
        {
            // @todo: hook up seasonal event here if/when desired
        }
    }
}

defaultproperties
{
    Begin Object Class=SpriteComponent Name=Sprite
        Sprite = Texture2D'EditorResources.S_Trigger'
        HiddenGame = true
        AlwaysLoadOnClient = False
        AlwaysLoadOnServer = False
        SpriteCategoryName = "Triggers"
    End Object
    Components.Add(Sprite)

    SupportedEvents.Empty
    SupportedEvents.Add(class'KFSeqEvent_MinigameEndCondition')

    RemoteRole = ROLE_SimulatedProxy
    NetPriority = +00002.500000

    bClearControllerOnCompletion = true

    ObjectiveIndex = -1
    EventIndex = -1

    bAlwaysRelevant=true
}