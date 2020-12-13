//=============================================================================
// KFMapObjective_EscortPawns
//=============================================================================
// Objective type for escorting pawns. Pawns can be spawned in sequence or at
// the same time and need to be defended.
//=============================================================================
// Killing Floor 2
// Copyright (C) 2018 Tripwire Interactive LLC
//=============================================================================

class KFMapObjective_EscortPawns extends KFMapObjective_ActorBase;

// Scripted pawn spawners that will spawn the escorts related to this objective
var() array<KFScriptedPawnSpawner> EscortPawnSpawners;
/** How many escorts need to be escorted successfully for the objective to be completed. */
var() int NumEscortsRequired;
var int NumEscortsAccomplished;
var int NumEscortsFinished;
var float Progress;
var repnotify transient Actor ActiveEscortActor;
var float CompletionPct;

// Sound to play when escort is 100% done and in perfect health
var() AkEvent ProgressSoundEvent100pctPerfect;
// Sound to play when escort is 100% done
var() AkEvent ProgressSoundEvent100pct;
// Sound to play when escort is 100% done and in poor health
var() AkEvent ProgressSoundEvent100pctPoor;
// Sound to play when escort is 85% done and in perfect health
var() AkEvent ProgressSoundEvent85pctPerfect;
// Sound to play when escort is 85% done
var() AkEvent ProgressSoundEvent85pct;
// Sound to play when escort is 85% done and in poor health
var() AkEvent ProgressSoundEvent85pctPoor;
// Sound to play when escort is 50% done and in perfect health
var() AkEvent ProgressSoundEvent50pctPerfect;
// Sound to play when escort is 50% done
var() AkEvent ProgressSoundEvent50pct;
// Sound to play when escort is 50% done and in poor health
var() AkEvent ProgressSoundEvent50pctPoor;
// Sound to play when escort is 25% done and in perfect health
var() AkEvent ProgressSoundEvent25pctPerfect;
// Sound to play when escort is 25% done
var() AkEvent ProgressSoundEvent25pct;
// Sound to play when escort is 25% done and in poor health
var() AkEvent ProgressSoundEvent25pctPoor;
// Percentage of escort health considered to be "poor," used for the "poor" progress sound events
var() float PoorHealthPctThreshold;

// Sound to play when escort takes damage
var() AkEvent EscortPawnTakeDamageEvent;
// Cooldown period for the "take damage" sound event
var() float EscortPawnTakeDamageEventCooldown;
// Sound to play to remind players that escort is in critical condition
var() AkEvent EscortPawnCriticalReminderEvent;
// How frequently to remind players that escort is in critical condition
var() float EscortPawnCriticalReminderEventInterval;

var repnotify int CompletionProgressIdx, HealthProgressIdx;

replication
{
	if (bNetDirty)
		Progress, ActiveEscortActor, CompletionPct, CompletionProgressIdx, HealthProgressIdx;
}

simulated function ReplicatedEvent(name VarName)
{
	switch (VarName)
	{
	case nameof(ActiveEscortActor):
		UpdateTrailActor();
		break;

	case nameof(CompletionProgressIdx):
		TriggerCompletionPctProgress();
		break;

	case nameof(HealthProgressIdx):
		TriggerHealthPctProgress();
		break;

	default:
		super.ReplicatedEvent(VarName);
	};
}

function CheckCompletionPctProgress(float PrevCompletionPct, float CurrCompletionPct)
{
	local int PrevCompletionProgressIdx, GenEvtIdx, i;
	local KFSeqEvent_EscortPawnsCompletionPct GenEvt;

	PrevCompletionProgressIdx = CompletionProgressIdx;

	// check the first applicable generated event (assumes all applicable events are identical)
	for (GenEvtIdx = 0; GenEvtIdx < GeneratedEvents.Length; GenEvtIdx++)
	{
		GenEvt = KFSeqEvent_EscortPawnsCompletionPct(GeneratedEvents[GenEvtIdx]);
		if (GenEvt != None)
		{
			for (i = 0; i < GenEvt.ProgressThresholds.Length; i++)
			{
				if (PrevCompletionPct < GenEvt.ProgressThresholds[i] &&
					CurrCompletionPct >= GenEvt.ProgressThresholds[i])
				{
					CompletionProgressIdx = GenEvt.ProgressOutputStartIndex + i;
					break;
				}
			}
			break;
		}
	}

	if (CompletionProgressIdx != PrevCompletionProgressIdx)
	{
		TriggerCompletionPctProgress();
	}
}

simulated function TriggerCompletionPctProgress()
{
	local int GenEvtIdx;
	local KFSeqEvent_EscortPawnsCompletionPct GenEvt;
	local array<int> ActivateIndices;

	ActivateIndices.AddItem(CompletionProgressIdx);

	// notify all applicable generated events (assumes all applicable events are identical)
	for (GenEvtIdx = 0; GenEvtIdx < GeneratedEvents.Length; GenEvtIdx++)
	{
		GenEvt = KFSeqEvent_EscortPawnsCompletionPct(GeneratedEvents[GenEvtIdx]);
		if (GenEvt != None)
		{
			GenEvt.Reset();
			GenEvt.CheckActivate(self, self,, ActivateIndices);
		}
	}
}

function CheckHealthPctProgress(float PrevHealthPct, float CurrHealthPct)
{
	local int PrevHealthProgressIdx, GenEvtIdx, i;
	local KFSeqEvent_EscortPawnsHealthPct GenEvt;

	PrevHealthProgressIdx = HealthProgressIdx;

	// check the first applicable generated event (assumes all applicable events are identical)
	for (GenEvtIdx = 0; GenEvtIdx < GeneratedEvents.Length; GenEvtIdx++)
	{
		GenEvt = KFSeqEvent_EscortPawnsHealthPct(GeneratedEvents[GenEvtIdx]);
		if (GenEvt != None)
		{
			if (GenEvt.bUseReverseProgress)
			{
				for (i = 0; i < GenEvt.ProgressThresholds.Length; i++)
				{
					if (PrevHealthPct >= GenEvt.ProgressThresholds[i] &&
						CurrHealthPct < GenEvt.ProgressThresholds[i])
					{
						// set idx negative for reverse progress
						// add 1 to keep idx from being 0, since 0 is ambiguous
						HealthProgressIdx = -(GenEvt.ProgressOutputStartIndex + i + 1);
						break;
					}
				}
			}
			else
			{
				for (i = 0; i < GenEvt.ProgressThresholds.Length; i++)
				{
					if (PrevHealthPct < GenEvt.ProgressThresholds[i] &&
						CurrHealthPct >= GenEvt.ProgressThresholds[i])
					{
						// add 1 to keep idx from being 0, since 0 is ambiguous
						HealthProgressIdx = GenEvt.ProgressOutputStartIndex + i + 1;
						break;
					}
				}
			}

			if (HealthProgressIdx != PrevHealthProgressIdx)
			{
				TriggerHealthPctProgress();
				break;
			}
		}
	}
}

simulated function TriggerHealthPctProgress()
{
	local int GenEvtIdx;
	local KFSeqEvent_EscortPawnsHealthPct GenEvt;
	local array<int> ActivateIndices;

	// subtract the 1 that we added in CheckHealthPctProgress
	ActivateIndices.AddItem(Max(HealthProgressIdx, -HealthProgressIdx) - 1);

	// notify all applicable generated events (assumes all applicable events are identical)
	for (GenEvtIdx = 0; GenEvtIdx < GeneratedEvents.Length; GenEvtIdx++)
	{
		GenEvt = KFSeqEvent_EscortPawnsHealthPct(GeneratedEvents[GenEvtIdx]);
		if (GenEvt != None)
		{
			if ((GenEvt.bUseReverseProgress && HealthProgressIdx < 0) ||
				(!GenEvt.bUseReverseProgress && HealthProgressIdx > 0))
			{
				GenEvt.Reset();
				GenEvt.CheckActivate(self, self,, ActivateIndices);
			}
		}
	}
}

// Interface functions

simulated function ActivateObjective()
{
	local KFScriptedPawnSpawner EscortPawnStart;

	super.ActivateObjective();

	if (Role == ROLE_Authority)
	{
		bIsActive = true;
		NumEscortsAccomplished = 0;
		NumEscortsFinished = 0;

		// set delegates to help keep track of objective progress
		foreach EscortPawnSpawners(EscortPawnStart)
		{
			EscortPawnStart.Delegate_OnPawnStartedRoute = OnEscortStarted;
			EscortPawnStart.Delegate_OnPawnReachedRouteMarker = OnEscortReachedRouteMarker;
			EscortPawnStart.Delegate_OnPawnReachedGoal = OnEscortReachedGoal;
			EscortPawnStart.Delegate_OnPawnEndedRoute = OnEscortEndedRoute;

			// reset progress goals if this has already been completed once
			if (EscortPawnStart.bReachedGoal)
			{
				EscortPawnStart.bReachedStart = false;
				EscortPawnStart.bReachedGoal = false;
				EscortPawnStart.RouteDistTraversed = 0;
			}

			// make sure to set up any scripted pawns that were spawned before the objective started
			if (EscortPawnStart.Pawn != none && EscortPawnStart.bReachedStart)
			{
				OnEscortStarted(EscortPawnStart.Pawn);
			}
		}
	}
}

simulated function DeactivateObjective()
{
	local KFPawn_Human KFPH;

	super.DeactivateObjective();

	if (Role == ROLE_Authority)
	{
		bIsActive = false;

		if (NumEscortsAccomplished >= NumEscortsRequired)
		{
			foreach WorldInfo.AllPawns(class'KFPawn_Human', KFPH)
			{
				GrantReward(KFPlayerReplicationInfo(KFPH.PlayerReplicationInfo), KFPlayerController(KFPH.Controller));
			}
		}
		else
		{
			if (FailureSoundEvent != none)
			{
				PlaySoundBase(FailureSoundEvent, false, WorldInfo.NetMode == NM_DedicatedServer);
			}
		}
	}

	if (WorldInfo.NetMode != NM_DedicatedServer)
	{
		if (TrailActor != none)
		{
			TrailActor.Destroy();
			TrailActor = none;
		}

		if (ActiveEscortActor != none)
		{
			KFPawn_Scripted(ActiveEscortActor).RemoveEscortPawnOnHud();
		}
	}
}

simulated function bool IsActive()
{
	return bIsActive;
}

simulated function bool UsesProgress()
{
	return true;
}

simulated function bool IsBonus();

function bool CanActivateObjective()
{
	return !IsCurrentGameModeBlacklisted();
}

function bool IsCurrentGameModeBlacklisted()
{
	local class<KFGameInfo> CurrGameClass;

	foreach GameModeBlacklist(CurrGameClass)
	{
		if (CurrGameClass == WorldInfo.GRI.GameClass)
		{
			return true;
		}
	}

	return false;
}

simulated function float GetProgress()
{
	return FClamp(Progress, 0.f, 1.f);
}

simulated function bool IsComplete()
{
	return GetProgress() >= 1.f;
}

simulated function float GetActivationPctChance()
{
	return 1.f;
}

simulated function string GetProgressText()
{
	return int(GetProgress() * 100) $ "%";
}

simulated function string GetLocalizedRequirements()
{
	return "";
}

simulated function GetLocalizedStatus(out string statusMessage, out int bWarning, out int bNotification)
{
	local KFPawn_Scripted ActiveScriptedPawn;

	statusMessage = "";
	if (GetProgress() >= 1.f)
	{
		statusMessage = Localize("Objectives", "KillRemainingZeds", LocalizationPackageName);
		bWarning = 0;
		bNotification = 0;
		return;
	}

	ActiveScriptedPawn = KFPawn_Scripted(ActiveEscortActor);
	if (ActiveScriptedPawn != none)
	{
		if (ActiveScriptedPawn.GetHealthPercent() <= 0.01f)
		{
			statusMessage = Localize("Objectives", "NeedsRepair", LocalizationPackageName);
			bWarning = 1;
			return;
		}
		else if (ActiveScriptedPawn.GetHealthPercent() <= 0.25f)
		{
			statusMessage = Localize("Objectives", "LowHealth", LocalizationPackageName);
			bWarning = 1;
			return;
		}

		if (ActiveScriptedPawn.SpeedScalarForObstacles <= 0.0f)
		{
			statusMessage = Localize("Objectives", "Stopped", LocalizationPackageName);
			bWarning = 1;
			return;
		}

		if (ActiveScriptedPawn.IsBlockedByZed())
		{
			statusMessage = Localize("Objectives", "Blocked", LocalizationPackageName);
			bWarning = 1;
			return;
		}

		if (ActiveScriptedPawn.WasAttackedRecently())
		{
			statusMessage = Localize("Objectives", "BeingAttacked", LocalizationPackageName);
			bWarning = 1;
			return;
		}
	}
}

simulated function bool ShouldDrawIcon(){}

simulated function Vector GetIconLocation(){}

simulated function Texture2D GetIcon()
{
	if (ActiveEscortActor != none)
	{
		return KFPawn_Scripted(ActiveEscortActor).GetStateIconTexture();
	}
	return DefaultIcon;
}

// Non-interface functions

function OnEscortStarted(KFPawn_Scripted StartedPawn)
{
	ActiveEscortActor = StartedPawn;
	StartedPawn.SetActive(true);
	UpdateTrailActor();

	StartedPawn.Delegate_OnTakeDamage = OnEscortTakeDamage;
	StartedPawn.Delegate_OnHealDamage = OnEscortHealDamage;
	StartedPawn.Delegate_OnChangeState = OnEscortChangeState;

	OnEscortChangeState(0, 0);
}

function OnEscortReachedRouteMarker(int MarkerIdx, SplineActor Marker, int SubIdx)
{
	local float PawnsProgress;
	local KFScriptedPawnSpawner EscortPawnSpawner;
	local float ActivePawnHealthPct;

	foreach EscortPawnSpawners(EscortPawnSpawner)
	{
		PawnsProgress += EscortPawnSpawner.GetProgress() / float(EscortPawnSpawners.Length);
	}

	ActivePawnHealthPct = float(KFPawn_Scripted(ActiveEscortActor).Health) / float(KFPawn_Scripted(ActiveEscortActor).HealthMax);

	CheckCompletionPctProgress(Progress, PawnsProgress);

	CompletionPct = ActivePawnHealthPct;

	if (Progress < 0.25 && PawnsProgress >= 0.25)
	{
		if (ActivePawnHealthPct > 0.99 && ProgressSoundEvent25pctPerfect != none)
		{
			PlaySoundBase(ProgressSoundEvent25pctPerfect, false, WorldInfo.NetMode == NM_DedicatedServer);
		}
		else if (ActivePawnHealthPct > PoorHealthPctThreshold && ProgressSoundEvent25pct != none)
		{
			PlaySoundBase(ProgressSoundEvent25pct, false, WorldInfo.NetMode == NM_DedicatedServer);
		}
		else if (ProgressSoundEvent25pctPoor != none)
		{
			PlaySoundBase(ProgressSoundEvent25pctPoor, false, WorldInfo.NetMode == NM_DedicatedServer);
		}
	}
	else if (Progress < 0.5 && PawnsProgress >= 0.5)
	{
		if (ActivePawnHealthPct > 0.99 && ProgressSoundEvent50pctPerfect != none)
		{
			PlaySoundBase(ProgressSoundEvent50pctPerfect, false, WorldInfo.NetMode == NM_DedicatedServer);
		}
		else if (ActivePawnHealthPct > PoorHealthPctThreshold && ProgressSoundEvent50pct != none)
		{
			PlaySoundBase(ProgressSoundEvent50pct, false, WorldInfo.NetMode == NM_DedicatedServer);
		}
		else if (ProgressSoundEvent50pctPoor != none)
		{
			PlaySoundBase(ProgressSoundEvent50pctPoor, false, WorldInfo.NetMode == NM_DedicatedServer);
		}
	}
	else if (Progress < 0.85 && PawnsProgress >= 0.85)
	{
		if (ActivePawnHealthPct > 0.99 && ProgressSoundEvent85pctPerfect != none)
		{
			PlaySoundBase(ProgressSoundEvent85pctPerfect, false, WorldInfo.NetMode == NM_DedicatedServer);
		}
		else if (ActivePawnHealthPct > PoorHealthPctThreshold && ProgressSoundEvent85pct != none)
		{
			PlaySoundBase(ProgressSoundEvent85pct, false, WorldInfo.NetMode == NM_DedicatedServer);
		}
		else if (ProgressSoundEvent85pctPoor != none)
		{
			PlaySoundBase(ProgressSoundEvent85pctPoor, false, WorldInfo.NetMode == NM_DedicatedServer);
		}
	}
	else if (Progress < 1.0 && PawnsProgress >= 1.0)
	{
		if (ActivePawnHealthPct > 0.99 && ProgressSoundEvent100pctPerfect != none)
		{
			PlaySoundBase(ProgressSoundEvent100pctPerfect, false, WorldInfo.NetMode == NM_DedicatedServer);
		}
		else if (ActivePawnHealthPct > PoorHealthPctThreshold && ProgressSoundEvent100pct != none)
		{
			PlaySoundBase(ProgressSoundEvent100pct, false, WorldInfo.NetMode == NM_DedicatedServer);
		}
		else if (ProgressSoundEvent100pctPoor != none)
		{
			PlaySoundBase(ProgressSoundEvent100pctPoor, false, WorldInfo.NetMode == NM_DedicatedServer);
		}
	}

	Progress = PawnsProgress;
}

function OnEscortReachedGoal()
{
	OnEscortEndedRoute(true);
}

function OnEscortEndedRoute(bool bSuccess)
{
	local KFGameReplicationInfo KFGRI;

	++NumEscortsFinished;

	if (bSuccess)
	{
		++NumEscortsAccomplished;
		TriggerObjectiveProgressEvent();
	}

	if ((NumEscortsAccomplished >= NumEscortsRequired) ||
		(NumEscortsFinished == EscortPawnSpawners.Length) ||
		(((EscortPawnSpawners.Length - NumEscortsFinished) + NumEscortsAccomplished) < NumEscortsRequired))
	{
		KFGRI = KFGameReplicationInfo(WorldInfo.GRI);
		if (KFGRI != none)
		{
			Progress = 1.0f; // ensure this is set to completed
			KFGRI.DeactivateObjective();
		}
	}

	ActiveEscortActor = none;
	UpdateTrailActor();

	ClearTimer(nameof(Timer_EscortPawnTakeDamageEventCooldown));
	ClearTimer(nameof(Timer_EscortPawnCriticalReminderEventInterval));
}

function OnEscortTakeDamage(int Damage)
{
	local KFPawn_Scripted KFPS;
	local float PrevHealthPct, CurrHealthPct;

	if (EscortPawnTakeDamageEvent != none && !IsTimerActive(nameof(Timer_EscortPawnTakeDamageEventCooldown)))
	{
		PlaySoundBase(EscortPawnTakeDamageEvent,, WorldInfo.NetMode == NM_DedicatedServer);
		SetTimer(EscortPawnTakeDamageEventCooldown, false, nameof(Timer_EscortPawnTakeDamageEventCooldown));
	}

	KFPS = KFPawn_Scripted(ActiveEscortActor);
	PrevHealthPct = float(KFPS.Health + Damage) / float(KFPS.HealthMax);
	CurrHealthPct = float(KFPS.Health) / float(KFPS.HealthMax);

	CheckHealthPctProgress(PrevHealthPct, CurrHealthPct);
}

function Timer_EscortPawnTakeDamageEventCooldown()
{
	// this function is just here to allow us to set a timer, which we check the activity of
}

function OnEscortHealDamage(int HealAmount)
{
	local KFPawn_Scripted KFPS;
	local float PrevHealthPct, CurrHealthPct;

	KFPS = KFPawn_Scripted(ActiveEscortActor);
	PrevHealthPct = float(KFPS.Health - HealAmount) / float(KFPS.HealthMax);
	CurrHealthPct = float(KFPS.Health) / float(KFPS.HealthMax);

	CheckHealthPctProgress(PrevHealthPct, CurrHealthPct);
}

function OnEscortChangeState(int CurrState, int PrevState)
{
	if (KFPawn_Scripted(ActiveEscortActor).IsInCriticalCondition())
	{
		if (EscortPawnCriticalReminderEvent != none && !IsTimerActive(nameof(Timer_EscortPawnCriticalReminderEventInterval)))
		{
			SetTimer(EscortPawnCriticalReminderEventInterval, true, nameof(Timer_EscortPawnCriticalReminderEventInterval));
		}
	}
	else
	{
		ClearTimer(nameof(Timer_EscortPawnCriticalReminderEventInterval));
	}
}

function Timer_EscortPawnCriticalReminderEventInterval()
{
	PlaySoundBase(EscortPawnCriticalReminderEvent,, WorldInfo.NetMode == NM_DedicatedServer);
}

simulated function UpdateTrailActor()
{
	if (bUseTrailToObjective && WorldInfo.NetMode != NM_DedicatedServer)
	{
		if (TrailActor == none)
		{
			TrailActor = class'WorldInfo'.static.GetWorldInfo().Spawn(class'KFReplicatedShowPathActor', none);
			TrailActor.SetEmitterTemplate(ParticleSystem'FX_Gameplay_EMIT.FX_Objective_White_Trail');
		}

		TrailActor.SetPathTarget(ActiveEscortActor);
	}
}

simulated function bool GetIsMissionCritical()
{
	return bIsMissionCriticalObjective;
}

defaultproperties
{
	bIsMissionCriticalObjective=true
	LocalizationKey="EscortPawnsObjective"
	DescriptionLocKey="EscortPawnsDescription"
	NameShortLocKey="EscortPawnsObjective"
	DescriptionShortLocKey="EscortPawnsDescriptionShort"

	bAlwaysRelevant=true
	RemoteRole=ROLE_SimulatedProxy

	Begin Object Class=SpriteComponent Name=Sprite
		Sprite=Texture2D'EditorResources.S_Actor'
		HiddenGame=True
		AlwaysLoadOnClient=False
		AlwaysLoadOnServer=False
	End Object
	Components.Add(Sprite)

	GameModeBlacklist.Add(class'KFGameInfo_Endless')
	GameModeBlacklist.Add(class'KFGameInfo_WeeklySurvival')

	PerPlayerSpawnRateMod=(1.f, 1.f, 1.f, 1.f, 1.f, 1.f)

	DefaultIcon=Texture2D'Objectives_UI.UI_Objectives_ObjectiveMode'

	PoorHealthPctThreshold=0.5

	LocalizationPackageName="KFGame"

	CompletionProgressIdx=999
	HealthProgressIdx=999

	SupportedEvents.Add(class'KFSeqEvent_EscortPawnsCompletionPct')
	SupportedEvents.Add(class'KFSeqEvent_EscortPawnsHealthPct')
}