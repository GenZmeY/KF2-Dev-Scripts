//=============================================================================
// KFMapObjective_HoldZone
//=============================================================================
// Objective type for the hold objective.  While this is active, players
//      have to keep zeds out of an area while standing in the area themselves.
//      They must do this for a certain period of time to complete the objective.
//=============================================================================
// Killing Floor 2
// Copyright (C) 2017 Tripwire Interactive LLC
//=============================================================================
class KFMapObjective_HoldZone extends KFMapObjective_AreaDefense;

var() float RequiredTime; // in seconds
var float ProgressCheckInterval;
var float CurrentProgressTime;

var transient int TrackProgressTimerIdx;
var transient repnotify int ZoneProgressEnabledIdx, ZoneProgressIdx;

/** Sound event to play when players are engaged with too many zeds in the zone */
var() AkEvent TooManyZedsSoundEvent;

/** Sound event to play when too few players are in the zone */
var() AkEvent TooFewPlayersSoundEvent;

/** How often to remind players about the objective if they aren't engaged in completing it */
var() float RemindPlayersTime;

replication
{
	if (bNetDirty)
		CurrentProgressTime, ZoneProgressEnabledIdx, ZoneProgressIdx;
}

simulated function ReplicatedEvent(name VarName)
{
	switch (VarName)
	{
	case nameof(ZoneProgressEnabledIdx):
		TriggerZoneProgressEvent(ZoneProgressEnabledIdx);
		break;

	case nameof(ZoneProgressIdx):
		TriggerZoneProgressEvent(ZoneProgressIdx);
		break;

	default:
		super.ReplicatedEvent(VarName);
	};
}

simulated function ActivateObjective()
{
	local int PlayerCount;

	super.ActivateObjective();

	if (Role == ROLE_AUTHORITY)
	{
		CurrentProgressTime = 0.0f;

		SetTimer(ProgressCheckInterval, true, nameof(Timer_CheckProgress));
		SetTimer(RequiredTime, false, nameof(Timer_TrackProgress));
		SetTimer(RemindPlayersTime, false, nameof(Timer_TooFewPlayersReminderCooldown));

		TrackProgressTimerIdx = Timers.Find('FuncName', nameof(Timer_TrackProgress));

		PlayerCount = Clamp(KFGameInfo(WorldInfo.Game).GetLivingPlayerCount(), 1, 6) - 1;
		if (TouchingHumans.Length < PlayerThresholds[PlayerCount] && TouchingZeds.Length >= ZedThresholds[PlayerCount])
		{
			PauseTimer(true, nameof(Timer_TrackProgress));
		}

		bActive = true;
		bForceNetUpdate = true;
	}
}

simulated function DeactivateObjective()
{
	local KFPawn_Human KFPH;

	super.DeactivateObjective();

	if (Role == ROLE_AUTHORITY)
	{
		ClearTimer(nameof(Timer_CheckProgress));
		ClearTimer(nameof(Timer_TrackProgress));

		if (GetProgress() < 1.0f)
		{
			if (FailureSoundEvent != none)
			{
				PlaySoundBase(FailureSoundEvent, false, WorldInfo.NetMode == NM_DedicatedServer);
			}
		}
		else
		{
			foreach WorldInfo.AllPawns(class'KFPawn_Human', KFPH)
			{
				GrantReward(KFPlayerReplicationInfo(KFPH.PlayerReplicationInfo), KFPlayerController(KFPH.Controller));
			}
		}

		bActive = false;
		bForceNetUpdate = true;
	}
}

simulated function Timer_TrackProgress();
simulated function Timer_TooFewPlayersReminderCooldown();
simulated function Timer_TooManyZedsReminderCooldown();

simulated function Timer_CheckProgress()
{
	local int PlayerCount, i, PrevZoneProgressIdx, GenEvtIdx;
	local float PrevProgress, CurrProgress;
	local KFSeqEvent_HoldZoneProgress GenEvt;
	local KFGameReplicationInfo KFGRI;

	PrevProgress = GetProgress();

	if (bActive)
	{
		for (i = 0; i < TouchingZeds.length; i++)
		{
			if (!IsValidZed(TouchingZeds[i]))
			{
				TouchingZeds.Remove(i, 1);
			}
		}

		PlayerCount = Clamp(KFGameInfo(WorldInfo.Game).GetLivingPlayerCount(), 1, 6) - 1;
		if (TouchingHumans.Length >= PlayerThresholds[PlayerCount] && TouchingZeds.Length <= ZedThresholds[PlayerCount])
		{
			if (Timers[TrackProgressTimerIdx].bPaused)
			{
				ZoneProgressEnabledIdx = EHoldZoneProgressEvent_ZoneEnabled;
				TriggerZoneProgressEvent(ZoneProgressEnabledIdx);
			}

			PauseTimer(false, nameof(Timer_TrackProgress));
			CurrentProgressTime = GetTimerCount(nameof(Timer_TrackProgress));
			bDangerState=false;

			if (IsComplete())
			{
				KFGRI = KFGameReplicationInfo(WorldInfo.GRI);
				if (KFGRI != none)
				{
					KFGRI.DeactivateObjective();
				}
			}
		}
		else
		{
			if (Role == ROLE_Authority)
			{
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
			}

			if (!Timers[TrackProgressTimerIdx].bPaused)
			{
				ZoneProgressEnabledIdx = EHoldZoneProgressEvent_ZoneDisabled;
				TriggerZoneProgressEvent(ZoneProgressEnabledIdx);
			}

			PauseTimer(true, nameof(Timer_TrackProgress));
			bDangerState=true;
		}

		UpdateMeshArrayState();

		bTooFewPlayers = TouchingHumans.Length < PlayerThresholds[PlayerCount];
		bTooManyZeds = TouchingZeds.Length > ZedThresholds[PlayerCount];
	}

	CurrProgress = GetProgress();

	if (Role == ROLE_Authority)
	{
		PrevZoneProgressIdx = ZoneProgressIdx;

		// check the first applicable generated event (assumes all applicable events are identical)
		for (GenEvtIdx = 0; GenEvtIdx < GeneratedEvents.Length; GenEvtIdx++)
		{
			GenEvt = KFSeqEvent_HoldZoneProgress(GeneratedEvents[GenEvtIdx]);
			if (GenEvt != None)
			{
				for (i = 0; i < GenEvt.ProgressThresholds.Length; i++)
				{
					if (PrevProgress < GenEvt.ProgressThresholds[i] &&
						CurrProgress >= GenEvt.ProgressThresholds[i])
					{
						ZoneProgressIdx = GenEvt.ProgressOutputStartIndex + i;
						break;
					}
				}
				break;
			}
		}

		if (ZoneProgressIdx != PrevZoneProgressIdx)
		{
			TriggerZoneProgressEvent(ZoneProgressIdx);
		}
	}
}

simulated function TriggerZoneProgressEvent(int Idx)
{
	local int GenEvtIdx;
	local KFSeqEvent_HoldZoneProgress GenEvt;
	local array<int> ActivateIndices;

	ActivateIndices.AddItem(Idx);

	// notify all applicable generated events (assumes all applicable events are identical)
	for (GenEvtIdx = 0; GenEvtIdx < GeneratedEvents.Length; GenEvtIdx++)
	{
		GenEvt = KFSeqEvent_HoldZoneProgress(GeneratedEvents[GenEvtIdx]);
		if (GenEvt != None)
		{
			GenEvt.Reset();
			GenEvt.CheckActivate(self, self,, ActivateIndices);
		}
	}
}

simulated function float GetProgress()
{
	if (CurrentProgressTime == -1.0f)
	{
		return 1.0f;
	}

	return FClamp(CurrentProgressTime / RequiredTime, 0.0f, 1.0f);
}

simulated function bool IsComplete()
{
	return GetProgress() >= 1.f;
}

simulated function bool IsActive()
{
	return bActive;
}

simulated function bool ShouldDrawIcon()
{
	return true;
}

simulated function Vector GetIconLocation()
{
	return Location;
}

simulated function string GetProgressText()
{
	local float TotalTime;
	local int MinutesRemaining, SecondsRemaining;
	local string TimeString;

	if (!bActive || RequiredTime <= 0.0f || CurrentProgressTime < 0.0f)
	{
		return "";
	}

	TotalTime = FMax(RequiredTime - CurrentProgressTime, 0.0f);
	MinutesRemaining = int(TotalTime / 60);
	SecondsRemaining = int(TotalTime % 60);

	if (MinutesRemaining < 10)
	{
		TimeString $= "0";
	}

	TimeString $= MinutesRemaining;
	TimeString $= ":";

	if (SecondsRemaining < 10)
	{
		TimeString $= "0";
	}

	TimeString $= SecondsRemaining;

	return TimeString;
}

simulated function string GetLocalizedRequirements()
{
	return Localize("Objectives", default.RequirementsLocKey, "KFGame") @ GetProgressText();
}

defaultproperties
{
	bAlwaysRelevant = true
	RemoteRole = ROLE_SimulatedProxy

	LocalizationPackageName = "KFGame"
	LocalizationKey = "HoldZoneObjective"
	DescriptionLocKey = "HoldZoneDescription"
	NameShortLocKey = "HoldZoneObjective"
	DescriptionShortLocKey = "HoldZoneDescriptionShort"
	RequirementsLocKey = "HoldZoneRequired"

	RequiredTime = 300.f;
	ProgressCheckInterval = .25f;
	CurrentProgressTime = 0.0f;

	PlayerThresholds[0]=1
	PlayerThresholds[1]=1
	PlayerThresholds[2]=2
	PlayerThresholds[3]=2
	PlayerThresholds[4]=3
	PlayerThresholds[5]=3

	ZedThresholds[0]=4
	ZedThresholds[1]=4
	ZedThresholds[2]=4
	ZedThresholds[3]=3
	ZedThresholds[4]=2
	ZedThresholds[5]=2

	ZoneProgressEnabledIdx=EHoldZoneProgressEvent_ZoneDisabled
	ZoneProgressIdx=-1

	SupportedEvents.Add(class'KFSeqEvent_HoldZoneProgress')

	RemindPlayersTime=30.f
}
