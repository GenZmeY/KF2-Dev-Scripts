//=============================================================================
// KFUsableTrigger
//=============================================================================
// A generic trigger that can be activated by players and can send notifications
// to objects that can receive notification of activation
//=============================================================================
// Killing Floor 2
// Copyright (C) 2018 Tripwire Interactive LLC
//=============================================================================
class KFUsableTrigger extends Trigger_PawnsOnly
	implements(KFInterface_Usable)
	placeable;

var bool bActive;
var int TriggeredCount;

/* The type of interaction message that appears when standing in the trigger */
var() EInteractionMessageType InteractionType;
/* The number of times this trigger can be used before being deactivated */
var() int MaxTriggeredCount<ClampMin=0>;
/* Objects that can receive a notification when this trigger is used */
var() array<KFInterface_UsableTriggerTarget> Targets;

replication
{
	if (bNetDirty)
		bActive;
}

//////////////////////////////////////////////////////////////////////////////////////////////////////
// KFInterface_Usable

/** Checks if this actor is presently usable */
simulated function bool GetIsUsable(Pawn User)
{
	return bActive;
}

/** Return the index for our interaction message. */
function int GetInteractionIndex(Pawn User)
{
	return InteractionType;
}

// end KFInterface_Usable
//////////////////////////////////////////////////////////////////////////////////////////////////////

simulated event Touch(Actor Other, PrimitiveComponent OtherComp, vector HitLocation, vector HitNormal)
{
	Super.Touch(Other, OtherComp, HitLocation, HitNormal);
	if (Role == ROLE_Authority)
	{
		class'KFPlayerController'.static.UpdateInteractionMessages(Other);
	}
}

simulated event UnTouch(Actor Other)
{
	super.UnTouch( Other );
	if (Role == ROLE_Authority)
	{
		class'KFPlayerController'.static.UpdateInteractionMessages(Other);
	}
}

function bool UsedBy(Pawn User)
{
	local KFInterface_UsableTriggerTarget Target;

	// MaxTriggeredCount is 0 when this should always be usable
	if (MaxTriggeredCount == 0 || TriggeredCount < MaxTriggeredCount)
	{
		foreach Targets(Target)
		{
			Target.TriggerTarget(self, User);
		}

		// Check whether the UsableTrigger should be disabled because it has reached its limit on activations
		if (++TriggeredCount == MaxTriggeredCount)
		{
			bActive = false;
		}

		return true;
	}

	return false;
}

function AddTriggerHook(KFInterface_UsableTriggerTarget Target)
{
	Targets.AddItem(Target);
}

defaultproperties
{
	RemoteRole=ROLE_SimulatedProxy
	bAlwaysRelevant=true
}