//=============================================================================
// KFMapObjective_ActivateTrigger
//=============================================================================
// Objective for Biodome for Airship. The player has to activate a trigger n
// times for the objective to be complete. Zeds in the volume will stop the
// trigger from being activated.
//=============================================================================
// Killing Floor 2
// Copyright (C) 2018 Tripwire Interactive LLC
//=============================================================================
class KFMapObjective_ActivateTrigger extends KFMapObjective_AreaDefense;

/** How many times the players have pulled the trigger. */
var repnotify int TriggerPulls;

/** How many times a trigger has to be pulled until the objective is complete, per number of players */
var() const int TriggerPullsRequiredForPlayerCount[6];

/** How many times a trigger has to be pulled until the objective is complete. */
var int TriggerPullsRequired;

/** Reference to the trigger that we may need to override. */
var() KFTrigger_ObjectiveLever ObjectiveLever;

/** A delay from the the start of an objective, so the player can't automatically pull the lever. */
var() float ActivationDelay;

/** A sound to play when the trigger is ready to be triggered (e.g. after activation delay or trigger reset delay) */
var() array<AkEvent> TriggerReadySoundEvents;

/** A sound to play when the trigger is pulled */
var() array<AkEvent> TriggerPulledSoundEvents;

/** A sound to play when the objective is fully complete */
var() AkEvent SuccessSoundEvent100pct;

/** A sound to play when the objective is mostly complete */
var() AkEvent SuccessSoundEvent85pct;

/** A sound to play when the objective is adequately complete */
var() AkEvent SuccessSoundEvent50pct;

/** A sound to play when the objective is barely complete */
var() AkEvent SuccessSoundEvent25pct;

/** Sound event to play when players are engaged with too many zeds in the zone */
var() AkEvent TooManyZedsSoundEvent;

/** Sound event to play when too few players are in the zone */
var() AkEvent TooFewPlayersSoundEvent;

/** How often to remind players about the objective if they aren't engaged in completing it */
var() float RemindPlayersTime;

/** A sound to play when enough players are in the zone, few enough zeds are in the zone, and players are still not pulling the readied trigger */
var() array<AkEvent> TriggerReminderSoundEvents;

/** How often to remind players that the trigger is ready to be pulled */
var() float ReadyTriggerReminderTime;

var transient bool bObjectiveLeverActiveBefore;
var transient bool bObjectiveLeverBlessedBefore;

/** Incremented whenever the lever gets activated, used to kick off a kismet node */
var repnotify int nNumLeversActivated;
/** Set to true whenever the lever is ready to be pulled */
var bool bLeverReady;
/** Whether any players are on the objective */
var repnotify bool bNoPlayers;

/** Color for the objective progress icon when it is ready/not ready */
var const color ReadyIconColor;
var const color NotReadyIconColor;

/** Whether the trigger is allowed to be interacted with */
var bool bInteractable;

replication
{
	if(bNetDirty)
		TriggerPulls, TriggerPullsRequired, nNumLeversActivated, bNoPlayers, bInteractable;
}

simulated event ReplicatedEvent(name VarName)
{
	if (VarName == nameof(TriggerPulls))
	{
		if (TriggerPulls != 0)
		{
			TriggerObjectiveProgressEvent(EActivateTriggerProgressEvent_TriggerPulled, float(TriggerPulls)/float(TriggerPullsRequired));
			bLeverReady = false;
		}
	}
	else if (VarName == nameof(nNumLeversActivated))
	{
		TriggerObjectiveProgressEvent(EActivateTriggerProgressEvent_TriggerReady);
		bLeverReady = true;
	}
	else
	{
		super.ReplicatedEvent(VarName);
	}
}

simulated function ActivateObjective()
{
	local int PlayerCount;

	if (ObjectiveLever != none)
	{
		ObjectiveLever.OwningObjective = self;
	}

	super.ActivateObjective();

	if (Role == ROLE_Authority)
	{
		TriggerPulls = 0;

		PlayerCount = Clamp(KFGameInfo(WorldInfo.Game).GetLivingPlayerCount(), 1, 6) - 1;
		TriggerPullsRequired = TriggerPullsRequiredForPlayerCount[PlayerCount];

		`log(self @ "-" @ GetFuncName() @ "- ActivationDelay:" @ ActivationDelay);
		if (ObjectiveLever != none)
		{
			ObjectiveLever.SetFathersBlessing(false);
		}

		bInteractable = false;
		if (ActivationDelay > 0.f)
		{
			SetTimer(ActivationDelay, false, 'ActivateTrigger');
		}
		else
		{
			ActivateTrigger();
		}

		CurrentRewardAmount = 0;
		bObjectiveLeverActiveBefore = false;
		bObjectiveLeverBlessedBefore = false;

		// don't allow "too few players" reminder to be played right away
		SetTimer(RemindPlayersTime, false, nameof(Timer_TooFewPlayersReminderCooldown));
	}

	if (WorldInfo.NetMode != NM_DedicatedServer)
	{
		CheckTriggerActivation();
	}
}

simulated function DeactivateObjective()
{
	local KFPlayerController KFPC;
	local KFPawn_Human KFPH;

	super.DeactivateObjective();

	if (Role == ROLE_Authority)
	{
		ClearTimer('Timer_CheckObjective');

		bInteractable = false;

		if (ObjectiveLever != none)
		{
			// Lever should work as trap outside of objective.
			ObjectiveLever.SetFathersBlessing(true);
		}

		if (CurrentRewardAmount > 0)
		{
			foreach WorldInfo.AllPawns(class'KFPawn_Human', KFPH)
			{
				GrantReward(KFPlayerReplicationInfo(KFPH.PlayerReplicationInfo), KFPlayerController(KFPH.Controller));
			}
		}

		PlayDeactivationDialog();
	}

	KFPC = KFPlayerController(GetALocalPlayerController());
	if (KFPC != none && KFPC.MyGFxHUD != none)
	{
		KFPC.MyGFxHUD.WaveInfoWidget.ObjectiveContainer.SetFailState(CurrentRewardAmount <= 0);
	}
}

function PlayDeactivationDialog()
{
	if (CurrentRewardAmount <= 0)
	{
		PlaySoundBase(FailureSoundEvent, false, WorldInfo.NetMode == NM_DedicatedServer);
		BroadcastLocalizedMessage(class'KFLocalMessage_Priority', GMT_ObjectiveLost);
	}
	else
	{
		if (GetProgress() <= JustWinThreshold)
		{
			PlaySoundBase(SuccessSoundEvent25pct, false, WorldInfo.NetMode == NM_DedicatedServer);
		}
		else if (GetProgress() <= StandardWinThreshold)
		{
			PlaySoundBase(SuccessSoundEvent50pct, false, WorldInfo.NetMode == NM_DedicatedServer);
		}
		else if (GetProgress() <= GoodWinThreshold)
		{
			PlaySoundBase(SuccessSoundEvent85pct, false, WorldInfo.NetMode == NM_DedicatedServer);
		}
		else
		{
			PlaySoundBase(SuccessSoundEvent100pct, false, WorldInfo.NetMode == NM_DedicatedServer);
		}
	}
}

simulated function ActivateTrigger()
{
	local int PlayerCount;
	`log(self @ "-" @ GetFuncName());

	bInteractable = true;

	if (ObjectiveLever != none)
	{
		PlayerCount = Clamp(KFGameInfo(WorldInfo.Game).GetLivingPlayerCount(), 1, 6) - 1;
		ObjectiveLever.SetFathersBlessing(TouchingZeds.length < ZedThresholds[PlayerCount] && TouchingHumans.Length >= PlayerThresholds[PlayerCount]);
	}

	nNumLeversActivated++;
	TriggerObjectiveProgressEvent(EActivateTriggerProgressEvent_TriggerReady);

	SetTimer(0.25f, true, 'Timer_CheckObjective');

	// don't allow "trigger ready" reminder to play right away
	SetTimer(ReadyTriggerReminderTime, false, nameof(Timer_TriggerReadyReminderCooldown));
}

//-----------------------------------------------------------------------------
// Volume
//-----------------------------------------------------------------------------
event Touch(Actor Other, PrimitiveComponent OtherComp, vector HitLocation, vector HitNormal)
{
	local int PlayerCount;

	super.Touch(Other, OtherComp, HitLocation, HitNormal);

	PlayerCount = Clamp(KFGameInfo(WorldInfo.Game).GetLivingPlayerCount(), 1, 6) - 1;
	if (TouchingZeds.Length >= ZedThresholds[PlayerCount])
	{
		if (ObjectiveLever != none && bActive && bInteractable)
		{
			ObjectiveLever.SetFathersBlessing(false);
			CheckTriggerActivation();
		}
	}
	else if (TouchingHumans.Length >= PlayerThresholds[PlayerCount])
	{
		if (ObjectiveLever != none && bActive && bInteractable)
		{
			ObjectiveLever.SetFathersBlessing(true);
			CheckTriggerActivation();
		}
	}
}

event UnTouch(Actor Other)
{
	local int PlayerCount;

	super.UnTouch(Other);

	PlayerCount = Clamp(KFGameInfo(WorldInfo.Game).GetLivingPlayerCount(), 1, 6) - 1;
	if (TouchingHumans.Length < PlayerThresholds[PlayerCount])
	{
		if (ObjectiveLever != none && bActive && bInteractable)
		{
			ObjectiveLever.SetFathersBlessing(false);
			CheckTriggerActivation();
		}
	}
	else if (TouchingZeds.Length < ZedThresholds[PlayerCount])
	{
		if (ObjectiveLever != none && bActive && bInteractable)
		{
			ObjectiveLever.SetFathersBlessing(true);
			CheckTriggerActivation();
		}
	}
}

simulated function Timer_CheckObjective()
{
	local int i, PlayerCount;

	for (i = 0; i < TouchingZeds.length; i++)
	{
		if (!IsValidZed(TouchingZeds[i]))
		{
			TouchingZeds.Remove(i, 1);
		}
	}

	PlayerCount = Clamp(KFGameInfo(WorldInfo.Game).GetLivingPlayerCount(), 1, 6) - 1;
	if (bActive && bInteractable && ObjectiveLever != none)
	{
		ObjectiveLever.SetFathersBlessing(TouchingZeds.length < ZedThresholds[PlayerCount] && TouchingHumans.Length >= PlayerThresholds[PlayerCount]);
		CheckTriggerActivation();
	}

	if(ObjectiveLever != none && ObjectiveLever.bAllowActivation && !bObjectiveLeverActiveBefore)
	{
		// reset reminder when the lever becomes ready again
		SetTimer(ReadyTriggerReminderTime, false, nameof(Timer_TriggerReadyReminderCooldown));

		if (TriggerReadySoundEvents.Length > TriggerPulls)
		{
			PlaySoundBase(TriggerReadySoundEvents[TriggerPulls], , WorldInfo.NetMode == NM_DedicatedServer);
		}
	}

	bObjectiveLeverActiveBefore = ObjectiveLever.bAllowActivation;

	if (Role == ROLE_Authority)
	{
		bNoPlayers = TouchingHumans.Length <= 0;

		if (bActive && bInteractable)
		{
			PlayerCount = Clamp(KFGameInfo(WorldInfo.Game).GetLivingPlayerCount(), 1, 6) - 1;
			if (TouchingHumans.Length < PlayerThresholds[PlayerCount])
			{
				if (!IsTimerActive(nameof(Timer_TooFewPlayersReminderCooldown)))
				{
					// trigger sound event
					if (TooFewPlayersSoundEvent != none)
					{
						PlaySoundBase(TooFewPlayersSoundEvent, , WorldInfo.NetMode == NM_DedicatedServer);
					}

					SetTimer(RemindPlayersTime, false, nameof(Timer_TooFewPlayersReminderCooldown));
				}
			}

			if (TouchingZeds.Length > ZedThresholds[PlayerCount])
			{
				if (!IsTimerActive(nameof(Timer_TooManyZedsReminderCooldown)))
				{
					if (TooManyZedsSoundEvent != none)
					{
						PlaySoundBase(TooManyZedsSoundEvent, , WorldInfo.NetMode == NM_DedicatedServer);
					}

					SetTimer(RemindPlayersTime, false, nameof(Timer_TooManyZedsReminderCooldown));
				}
			}

			bTooFewPlayers = TouchingHumans.Length < PlayerThresholds[PlayerCount];
			bTooManyZeds = TouchingZeds.Length > ZedThresholds[PlayerCount];

			if (ObjectiveLever != none && ObjectiveLever.bAllowActivation)
			{
				if (TriggerPulls < TriggerReminderSoundEvents.Length && TriggerReminderSoundEvents[TriggerPulls] != none && !IsTimerActive(nameof(Timer_TriggerReadyReminderCooldown)))
				{
					if (TriggerReminderSoundEvents[TriggerPulls] != none)
					{
						PlaySoundBase(TriggerReminderSoundEvents[TriggerPulls], , WorldInfo.NetMode == NM_DedicatedServer);
					}

					SetTimer(ReadyTriggerReminderTime, false, nameof(Timer_TriggerReadyReminderCooldown));
				}
			}
		}
	}
}

// These timer functions don't definitions, they just need to exist for SetTimer
simulated function Timer_TooFewPlayersReminderCooldown();
simulated function Timer_TooManyZedsReminderCooldown();
simulated function Timer_TriggerReadyReminderCooldown();

simulated function OnTriggerActivated()
{
	local KFGameReplicationInfo KFGRI;

	if (!bActive || !bInteractable)
	{
		return;
	}

	TriggerPulls++;
	TriggerObjectiveProgressEvent(EActivateTriggerProgressEvent_TriggerPulled, float(TriggerPulls) / float(TriggerPullsRequired));

	if (Role == ROLE_Authority)
	{
		CurrentRewardAmount = GetMaxDoshReward() * GetProgress();
		if (TriggerPulls <= TriggerPulledSoundEvents.Length)
		{
			PlaySoundBase(TriggerPulledSoundEvents[TriggerPulls-1],, WorldInfo.NetMode == NM_DedicatedServer);
		}
	}

	if (GetProgress() >= 1.f)
	{
		KFGRI = KFGameReplicationInfo(WorldInfo.GRI);
		if (KFGRI != none)
		{
			KFGRI.DeactivateObjective();
		}
	}
}

simulated function OnTriggerReactivated()
{
	CheckTriggerActivation();
	nNumLeversActivated++;
	TriggerObjectiveProgressEvent(EActivateTriggerProgressEvent_TriggerReady);
}

simulated function CheckTriggerActivation()
{
	bDangerState = false;
	if (ObjectiveLever != none)
	{
		bDangerState = !ObjectiveLever.bFathersBlessing;
		UpdateMeshArrayState();
		ObjectiveLever.BroadcastInteractionMessages();
	}
}

simulated function float GetProgress()
{
	if (TriggerPullsRequired == 0)
	{
		return 0;
	}

	return float(TriggerPulls) / float(TriggerPullsRequired);
}

simulated function bool IsComplete()
{
	return GetProgress() >= 1.f;
}

simulated function string GetLocalizedRequirements()
{
	return Localize("Objectives", default.RequirementsLocKey, "KFGame") @ TriggerPullsRequired;
}

simulated function string GetProgressText()
{
	if (!bActive)
	{
		return "";
	}

	return TriggerPulls $ "/" $ TriggerPullsRequired;
}

simulated function GetLocalizedStatus(out string statusMessage, out int bWarning, out int bNotification)
{
	statusMessage = "";

	super.GetLocalizedStatus(statusMessage, bWarning, bNotification);

	if (statusMessage == "")
	{
		if (ObjectiveLever.ReadyToActivate() || bLeverReady)
		{
			statusMessage = Localize("Objectives", "Ready", LocalizationPackageName);
			bNotification = 1;
			bWarning = 0;
			return;
		}
		else
		{
			statusMessage = Localize("Objectives", "NotReady", LocalizationPackageName);
			bNotification = 0;
			bWarning = 1;
			return;
		}
	}
}

simulated function color GetIconColor()
{
	// want to show the not ready color if stopped for some reason
	if (bTooManyZeds || (bTooFewPlayers && !bNoPlayers))
	{
		return NotReadyIconColor;
	}

	// but want to show the normal color if exactly zero players on the objective
	if ((ROLE == ROLE_Authority && TouchingHumans.Length <= 0) || bNoPlayers)
	{
		return ObjectiveIconColor;
	}

	//otherwise if the lever is ready, choose that color
	if (ObjectiveLever.ReadyToActivate() || bLeverReady)
	{
		return ReadyIconColor;
	}

	return ObjectiveIconColor;
}

defaultproperties
{
	DescriptionLocKey="DescriptionActivateTrigger"
	DescriptionShortLocKey = "DescriptionActivateTriggerShort"
	RequirementsLocKey="RequiredActivateTrigger"
	LocalizationKey="ActivateTrigger"
	NameShortLocKey="ActivateTrigger"

	GameModeBlacklist.Add(class'KFGameInfo_Endless')
	GameModeBlacklist.Add(class'KFGameInfo_WeeklySurvival')

	SupportedEvents.Add(class'KFSeqEvent_ActivateTriggerProgress')

	TriggerPullsRequired=6

	ActivationDelay=5.f

	PlayerThresholds[0]=1
	PlayerThresholds[1]=1
	PlayerThresholds[2]=2
	PlayerThresholds[3]=2
	PlayerThresholds[4]=3
	PlayerThresholds[5]=3

	ZedThresholds[0]=6
	ZedThresholds[1]=5
	ZedThresholds[2]=4
	ZedThresholds[3]=3
	ZedThresholds[4]=2
	ZedThresholds[5]=1

	RemindPlayersTime=30.f

	ObjectiveIcon=Texture2D'Objectives_UI.UI_Objectives_ObjectiveMode'
	ReadyIconColor=(R=0, G=255, B=0, A=255);
	NotReadyIconColor=(R=255, G=0, B=0, A=255);
}
