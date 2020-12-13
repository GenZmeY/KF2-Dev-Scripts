//=============================================================================
// KFTrigger_ObjectiveLever
//=============================================================================
// Minigame button that is used by map objective. This lever both needs the
// approval of the trigger and the objective in order to be activated.
//=============================================================================
// Killing Floor 2
// Copyright (C) 2018 Tripwire Interactive LLC
//=============================================================================
class KFTrigger_ObjectiveLever extends KFTrigger_MinigameButton
	config(Game);

/** If the owning Map Objective says we can be activated or not. */
var repnotify bool bFathersBlessing;

/** Reference to owning map objective. */
var KFMapObjective_ActivateTrigger OwningObjective;

replication
{
	if (bNetDirty)
		bFathersBlessing;
}

simulated event ReplicatedEvent(name VarName)
{
	if (VarName == nameof(bFathersBlessing))
	{
		if (OwningObjective != none)
		{
			OwningObjective.TriggerObjectiveProgressEvent(bFathersBlessing ? EActivateTriggerProgressEvent_ZoneEnabled : EActivateTriggerProgressEvent_ZoneDisabled);
		}
	}

	super.ReplicatedEvent(VarName);
}

simulated function bool ReadyToActivate()
{
	local bool bReadyToActivate;

	bReadyToActivate = super.ReadyToActivate();
	return bReadyToActivate && bFathersBlessing;
}

function ActivateGame()
{
	if (OwningObjective != none && ReadyToActivate() && bActiveGame && !bInProgress)
	{
		OwningObjective.OnTriggerActivated();
	}

	super.ActivateGame();
}

function AllowReactivation()
{
	super.AllowReactivation();

	if (OwningObjective != none)
	{
		OwningObjective.OnTriggerReactivated();
	}
}

simulated function SetFathersBlessing(bool bNewBlessing)
{
	if (bNewBlessing != bFathersBlessing)
	{
		bFathersBlessing = bNewBlessing;
		bForceNetUpdate = true;

		if (OwningObjective != none)
		{
			OwningObjective.TriggerObjectiveProgressEvent(bFathersBlessing ? EActivateTriggerProgressEvent_ZoneEnabled : EActivateTriggerProgressEvent_ZoneDisabled);
		}
	}
}
defaultproperties
{
	bFathersBlessing=true
}
