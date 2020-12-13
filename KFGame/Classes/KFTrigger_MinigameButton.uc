//=============================================================================
// KFTrigger_MinigameButton
//=============================================================================
// Trigger used to start triggerable minigames
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
// - Dan Weiss
//=============================================================================

class KFTrigger_MinigameButton extends Trigger_PawnsOnly
    config(Game)
    implements(KFInterface_Usable)
    native;

/** Whether or not this game is able to be activated. Can be toggled via level generator or left on by default. */
var() bool bActiveGame;

/** Allow deactivation via another button press */
var() bool bDeactivateOnPress;

/** Amount of time until the minigame is deactivated.  Should be <= ReactivationTime */
var() float DeactivationTime;

/** Amount of time until the minigame can be reactivated */
var() float ReactivationTime;

/** If code was needed, custom actors that we're tied to */
var() array<KFInterface_MinigameActor> MinigameActors;

/** Any linked buttons (used to prevent multi-activation in things like rollercoaster) */
var() array<KFTrigger_MinigameButton> LinkedButtons;

/** Whether or not the game is in progress */
var bool bInProgress;

/** Whether or not reactivation is available */
var bool bAllowActivation;

/** Amount of delay between button press and activation of the game */
var() float ActivationDelay;

/** Player that last activated the button */
var Pawn LastActivatingUser;

/** Sound to play upon activation */
var() AkEvent ActivationSoundEvent;

/** KFInterface_Usable */
simulated function bool GetIsUsable(Pawn User)
{
    return ReadyToActivate();
}

simulated function bool ReadyToActivate()
{
    return bAllowActivation && ((bActiveGame && !bInProgress) || (bInProgress && bDeactivateOnPress)) && ActorsAllowActivation() && LinkedButtonsAllowActivation();
}

/** KFInterface_Usable */
simulated function int GetInteractionIndex(Pawn User)
{
    return IMT_UseMinigame;
}

/** HUD */
event Touch(Actor Other, PrimitiveComponent OtherComp, vector HitLocation, vector HitNormal)
{
    super.Touch(Other, OtherComp, HitLocation, HitNormal);
    class'KFPlayerController'.static.UpdateInteractionMessages(Other);
}

/** HUD */
event UnTouch(Actor Other)
{
    super.UnTouch(Other);
    class'KFPlayerController'.static.UpdateInteractionMessages(Other);
}

/** Handles trigger interaction */
function bool UsedBy(Pawn User)
{
    local KFSeqEvent_MinigameActivated ActivationEvent;
    local int i;

    if (IsTimerActive('ActivateGame'))
    {
        return false;
    }

    LastActivatingUser = User;
    if (ActivationDelay > 0 && !(bInProgress && bDeactivateOnPress))
    {
        SetTimer(ActivationDelay, false, 'ActivateGame');

        //Notify Kismet that minigame has been activated by the user
        for (i = 0; i < GeneratedEvents.Length; i++)
        {
            ActivationEvent = KFSeqEvent_MinigameActivated(GeneratedEvents[i]);
            if (ActivationEvent != none)
            {
                ActivationEvent.NotifyDelayedActivation(LastActivatingUser, self);
            }
        }
    }
    else
    {
        ActivateGame();
    }

    //Notify Kismet that minigame has been activated by the user
    for (i = 0; i < GeneratedEvents.Length; i++)
    {
        ActivationEvent = KFSeqEvent_MinigameActivated(GeneratedEvents[i]);
        if (ActivationEvent != none)
        {
            ActivationEvent.NotifyStartup(LastActivatingUser, self);
        }
    }

    return true;
}

function ActivateGame()
{
    local KFSeqEvent_MinigameActivated ActivationEvent;
    local int i;
    local KFInterface_MinigameActor MinigameActor;

    if (ReadyToActivate())
    {
        //Only allow if minigame is active
        if (bActiveGame && !bInProgress)
        {
            //Notify Kismet that minigame has been activated by the user
            for (i = 0; i < GeneratedEvents.Length; i++)
            {
                ActivationEvent = KFSeqEvent_MinigameActivated(GeneratedEvents[i]);
                if (ActivationEvent != none)
                {
                    ActivationEvent.NotifyActivation(LastActivatingUser, self);
                }
            }

            bInProgress = true;
            bAllowActivation = false;
            if (DeactivationTime > 0.f)
            {
                SetTimer(DeactivationTime, false, 'Deactivate');
            }

            //Trigger any custom code if the actor exists
            if (MinigameActors.Length > 0)
            {
                foreach MinigameActors(MinigameActor)
                {
					MinigameActor.Activated(self);
                }
            }

			//Button spam prevention
			SetTimer(ReactivationTime, false, 'AllowReactivation');

			PlaySoundBase(ActivationSoundEvent, false, WorldInfo.NetMode == NM_DedicatedServer);
        }
        else if (bInProgress && bDeactivateOnPress)
        {
            Deactivate();
        }
    }
}

/** Handle cleanup after minigame comes back for reactivation */
function AllowReactivation()
{
    bAllowActivation = true;

    BroadcastInteractionMessages();
}

function BroadcastInteractionMessages()
{
	local int i;

	for (i = 0; i < Touching.Length; ++i)
	{
		class'KFPlayerController'.static.UpdateInteractionMessages(Touching[i]);
	}
}

/** Whether or not all attached minigame actors are allowing activation */
function bool ActorsAllowActivation()
{
    local KFInterface_MinigameActor MinigameActor;
    if (MinigameActors.Length > 0)
    {
        foreach MinigameActors(MinigameActor)
        {
            if (!MinigameActor.CanBeActivated(self))
            {
                return false;
            }
        }
    }

    //No actors, or all actors were valid
    return true;
}

/** Whether or not any linked buttons allow activation */
function bool LinkedButtonsAllowActivation()
{
    local KFTrigger_MinigameButton Button;

    foreach LinkedButtons(Button)
    {
        if (Button.bInProgress || Button.IsTimerActive('ActivateGame'))
        {
            return false;
        }
    }

    return true;
}

/** Run anything related to deactivation of the mini game */
function Deactivate()
{
    local KFInterface_MinigameActor MinigameActor;
    local KFSeqEvent_MinigameActivated ActivationEvent;
    local int i;

    //Cleanup in case this was triggered from non-timer sources
    if (ReactivationTime <= DeactivationTime)
    {
        AllowReactivation();
        ClearTimer('AllowReactivation');
    }
    ClearTimer('Deactivate');

    bInProgress = false;
	bAllowActivation = false;

	//Button spam prevention
	SetTimer(ReactivationTime, false, 'AllowReactivation');

    //Notify Kismet that minigame has been deactivated by timer
    for (i = 0; i < GeneratedEvents.Length; i++)
    {
        ActivationEvent = KFSeqEvent_MinigameActivated(GeneratedEvents[i]);
        if (ActivationEvent != none)
        {
            ActivationEvent.NotifyDeactivation(self, self);
        }
    }

    //Trigger any custom code if the actor exists
    if (MinigameActors.Length > 0)
    {
        foreach MinigameActors(MinigameActor)
        {
            MinigameActor.Deactivated();
        }
    }
}

/** Handle state changes and trigger Kismet/actor notifications */
function SetMinigameActive()
{
    if (!bActiveGame)
    {
        bActiveGame = true;
        MinigameStateUpdated();
    }
}

function SetMinigameInactive()
{
    if (bActiveGame)
    {
        bActiveGame = false;
        Deactivate();
        MinigameStateUpdated();
    }
}

function MinigameStateUpdated()
{
    local KFSeqEvent_MinigameStateChanged StateChangeEvent;
    local int i;

    //Notify Kismet that minigame state has been changed
    for (i = 0; i < GeneratedEvents.Length; i++)
    {
        StateChangeEvent = KFSeqEvent_MinigameStateChanged(GeneratedEvents[i]);
        if (StateChangeEvent != none)
        {
            StateChangeEvent.StateChanged(none, self, bActiveGame);
        }
    }
}

defaultproperties
{
    SupportedEvents.Empty
    SupportedEvents.Add(class'KFSeqEvent_MinigameStateChanged')
    SupportedEvents.Add(class'KFSeqEvent_MinigameActivated')

    ReactivationTime = 5.0f
    bAllowActivation = true
}