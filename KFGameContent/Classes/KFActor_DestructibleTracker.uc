//=============================================================================
// KFActor_DestructibleTracker
//=============================================================================
// One-off actor for tracking the status of multiple KFDestructibleActors
//		and triggering event objective completion when they're all dead.
//=============================================================================
// Killing Floor 2
// Copyright (C) 2017 Tripwire Interactive LLC
//=============================================================================
class KFActor_DestructibleTracker extends Actor
	placeable;

//List of destructibles to kill.  When this is empty, trigger event completion
var() const array<KFDestructibleActor> ActorList;
var array<KFDestructibleActor> CurrentActorList;

//Event-specific information
var() SeasonalEventIndex EventIndex;
var() int ObjectiveIndex;

simulated event SetInitialState()
{
	super.SetInitialState();
	SetupActorDelegates();
}

function SetupActorDelegates()
{
	local KFDestructibleActor DActor;

	CurrentActorList = ActorList;
	foreach CurrentActorList(DActor)
	{
		DActor.OnDestroyed = OnDestroyed;
	}
}

event Destroyed()
{
	local KFDestructibleActor DActor;
	super.Destroyed();

	foreach ActorList(DActor)
	{
		DActor.OnDestroyed = none;
	}
}

function OnDestroyed(KFDestructibleActor DActor)
{
	local KFPlayerController KFPC;

	if (CurrentActorList.Find(DActor) != INDEX_NONE)
	{
		CurrentActorList.RemoveItem(DActor);
	}

	if (CurrentActorList.Length == 0)
	{
		foreach WorldInfo.AllControllers(class'KFPlayerController', KFPC)
		{
			// @todo: hook up seasonal event here if/when desired
		}
	}
}

defaultproperties
{
	Begin Object Class=SpriteComponent Name=Sprite
        Sprite=Texture2D'EditorResources.S_Trigger'
        HiddenGame=true
        AlwaysLoadOnClient=False
        AlwaysLoadOnServer=False
        SpriteCategoryName="Triggers"
    End Object
    Components.Add(Sprite)
}