//=============================================================================
// KFMapObjective_ActorBase
//=============================================================================
// Parent class for all actor-based objectives
//=============================================================================
// Killing Floor 2
// Copyright (C) 2018 Tripwire Interactive LLC
//=============================================================================
class KFMapObjective_ActorBase extends Actor
	implements(KFInterface_MapObjective)
	placeable
	abstract;

//=============================================================================
// Common objective variables
//=============================================================================

`include(KFMapObjective_CommonVars.uci)

//=============================================================================
// KFMapObjective_ActorBase variables
//=============================================================================

var bool bIsActive;

/** Whether or not to use the trader trail to lead players to the objective */
var() bool bUseTrailToObjective;

/** Max reward if users (theoretically) did the objective perfectly */
var() const array<int> DoshRewards;

/** XP reward if user compeletes the objective. */
var const array<int> XPRewards;

/** Multipliers for the Max XP/Dosh Amount given at the end of an objective*/
var const array<float> DoshDifficultyScalars;
var const array<float> XPDifficultyScalars;

/** Modifies the Dosh value gained for killing zeds while this objective is active*/
var() const float DoshValueModifier;

replication
{
	if (bNetInitial)
		bUseTrailToObjective;

	if (bNetDirty)
		bIsActive;
}

//=============================================================================
// KFInterface_MapObjective functions
//=============================================================================

simulated function PlayActivationSoundEvent()
{
	if (Role == ROLE_AUTHORITY)
	{
		if (ActivationSoundEvent != none)
		{
			PlaySoundBase(ActivationSoundEvent, false, WorldInfo.NetMode == NM_DedicatedServer);
		}
	}
}

simulated function bool CanActivateObjectiveByWeekly()
{
	return true;
}

// Status
simulated function ActivateObjective()
{
	local KFSeqEvent_MapObjectiveActivated ActivationEvent;
	local int i;

	bIsActive = true;

	for (i = 0; i < GeneratedEvents.Length; i++)
	{
		ActivationEvent = KFSeqEvent_MapObjectiveActivated(GeneratedEvents[i]);
		if (ActivationEvent != none)
		{
			ActivationEvent.NotifyActivation(self, self);
		}
	}

	// delay this sound event by a little bit so that the unreliable RPC doesn't get lost
	SetTimer(1.0f, false, nameof(PlayActivationSoundEvent));
}

simulated function DeactivateObjective()
{
	local KFSeqEvent_MapObjectiveActivated ActivationEvent;
	local int i;

	bIsActive = false;

	for (i = 0; i < GeneratedEvents.Length; i++)
	{
		ActivationEvent = KFSeqEvent_MapObjectiveActivated(GeneratedEvents[i]);
		if (ActivationEvent != none)
		{
			ActivationEvent.NotifyDeactivation(self, self);
		}
	}
}

simulated function GrantReward(KFPlayerReplicationInfo KFPRI, KFPlayerController KFPC)
{
	if (KFPRI == none)
	{
		return;
	}

	if (KFPRI.bOnlySpectator)
	{
		return;
	}

	KFPRI.AddDosh(GetDoshReward());

	if (KFPC != none)
	{
		// @todo: hook up seasonal event here if/when desired
		KFPC.ClientMapObjectiveCompleted(GetXPReward());
	}
}

simulated function int GetMaxXPReward()
{
	local KFGameReplicationInfo KFGRI;
	local int ArrayEnd;

	KFGRI = KFGameReplicationInfo(WorldInfo.GRI);
	if (KFGRI != none)
	{
		// Since we're using a static array for rewards, we need to know the true end of the array.
		ArrayEnd = Clamp(KFGRI.WaveMax - 2, 0, XPRewards.Length - 1);
		return XPRewards[Clamp(KFGRI.WaveNum - 1, 0, ArrayEnd)] * XPDifficultyScalars[KFGRI.GameDifficulty];
	}

	if (XPRewards.Length > 0)
	{
		return XPRewards[0];
	}

	return 0;
}

simulated function int GetMaxDoshReward()
{
	local KFGameReplicationInfo KFGRI;
	local int ArrayEnd;

	KFGRI = KFGameReplicationInfo(WorldInfo.GRI);
	if (KFGRI != none)
	{
		// Since we're using a static array for rewards, we need to know the true end of the array.
		ArrayEnd = Clamp(KFGRI.WaveMax - 2, 0, DoshRewards.Length - 1);
		return DoshRewards[Clamp(KFGRI.WaveNum - 1, 0, ArrayEnd)] * DoshDifficultyScalars[KFGRI.GameDifficulty];
	}

	if (DoshRewards.Length > 0)
	{
		return DoshRewards[0];
	}

	return 0;
}

simulated function int GetMaxVoshReward()
{
	local KFGameReplicationInfo KFGRI;

	KFGRI = KFGameReplicationInfo(WorldInfo.GRI);
	if (KFGRI != none)
	{
		return class'KFOnlineStatsWrite'.static.GetMapObjectiveVoshReward(KFGRI.GameDifficulty, KFGRI.WaveNum);
	}

	return 0;
}

simulated function int GetDoshReward()
{
	return GetMaxDoshReward();
}

simulated function int GetVoshReward()
{
	local int MaxVosh;

	MaxVosh = GetMaxVoshReward();
	if (MaxVosh == 0)
	{
		return MaxVosh;
	}

	return int(MaxVosh * GetProgress());
}

simulated function int GetXPReward()
{
	local int MaxXP;

	MaxXP = GetMaxXPReward();
	if (MaxXP == 0)
	{
		return MaxXP;
	}

	return int(MaxXP * GetProgress());
}

simulated function string GetLocalizedName()
{
	if (LocalizationKey != "")
	{
		return Localize("Objectives", LocalizationKey, LocalizationPackageName);
	}

	return "";
}

simulated function string GetLocalizedShortName()
{
	if (NameShortLocKey != "")
	{
		return Localize("Objectives", NameShortLocKey, LocalizationPackageName);
	}

	return "";
}

simulated function string GetLocalizedDescription()
{
	if (DescriptionLocKey != "")
	{
		return Localize("Objectives", DescriptionLocKey, LocalizationPackageName);
	}
	
	return "";
}

simulated function string GetLocalizedShortDescription()
{
	if (DescriptionShortLocKey != "")
	{
		return Localize("Objectives", DescriptionShortLocKey, LocalizationPackageName);
	}

	return "";
}

simulated function GetLocalizedStatus(out string statusMessage, out int bWarning, out int bNotification)
{
	statusMessage = "";

	if (GetProgress() >= 1.f)
	{
		statusMessage = Localize("Objectives", "KillRemainingZeds", LocalizationPackageName);
		bWarning = 0;
		bNotification = 0;
	}
}

simulated function float GetSpawnRateMod()
{
	local KFGameReplicationInfo KFGRI;
	local int NumPlayersAlive;

	KFGRI = KFGameReplicationInfo(WorldInfo.GRI);
	if (KFGRI != none)
	{
		NumPlayersAlive = Clamp(KFGRI.GetNumPlayersAlive(), 1, PerPlayerSpawnRateMod.length) - 1;
		if (NumPlayersAlive >= 0 && NumPlayersAlive < PerPlayerSpawnRateMod.Length)
		{
			return PerPlayerSpawnRateMod[NumPlayersAlive];
		}
	}

	return 1.f;
}


simulated function bool HasFailedObjective()
{
	return GetLivingPlayerCount() <= 0;
}

simulated function int GetLivingPlayerCount()
{
	local KFGameReplicationInfo KFGRI;

	KFGRI = KFGameReplicationInfo(WorldInfo.GRI);
	if (KFGRI != none)
	{
		return KFGRI.GetNumPlayersAlive();
	}

	return 0;
}

simulated function bool IsActive() { return bIsActive; }
simulated function bool UsesProgress();
simulated function bool IsBonus();
function bool CanActivateObjective();
simulated function float GetProgress();
simulated function bool IsComplete();
simulated function float GetActivationPctChance();
simulated function string GetProgressText();
simulated function bool GetProgressTextIsDosh() { return false; }
simulated function string GetLocalizedRequirements();
simulated function bool GetIsMissionCritical();
simulated function float GetDoshValueModifier() { return DoshValueModifier; }
function NotifyZedKilled(Controller Killer, Pawn KilledPawn, bool bIsBoss);
simulated function NotifyObjectiveSelected();

// HUD
simulated function bool ShouldDrawIcon();
simulated function Vector GetIconLocation();
simulated function DrawHUD(KFHUDBase hud, Canvas drawCanvas);
simulated function bool HasObjectiveDrawDistance() { return true; }
simulated function bool ShouldShowObjectiveHUD() { return true; }
simulated function bool ShouldShowObjectiveContainer() { return true; }
simulated function Texture2D GetIcon()
{
	return ObjectiveIcon;
}
simulated function color GetIconColor()
{
	return ObjectiveIconColor;
}

// Kismet
simulated function TriggerObjectiveProgressEvent(optional int EventType = -1, optional float ProgressMade = -1.f)
{
	local int i, j;
	local array<int> OutputLinksToActivate;
	local KFSeqEvent_ObjectiveProgress ProgressEvent;

	if (EventType >= 0)
	{
		OutputLinksToActivate.AddItem(EventType);
	}

	for (i = 0; i < GeneratedEvents.Length; i++)
	{
		ProgressEvent = KFSeqEvent_ObjectiveProgress(GeneratedEvents[i]);
		if (ProgressEvent != none)
		{
			if (ProgressMade >= 0.0f)
			{
				for (j = 0; j < ProgressEvent.ProgressThresholds.Length; j++)
				{
					if (ProgressEvent.ProgressThresholds[j] == ProgressMade)
					{
						OutputLinksToActivate.AddItem(ProgressEvent.ProgressOutputStartIndex + j);
						break;
					}
				}
			}

			ProgressEvent.Reset();
			ProgressEvent.CheckActivate(self, self, , OutputLinksToActivate);
		}
	}
}

defaultproperties
{
	bNoDelete=True
	bSkipActorPropertyReplication=True

	SupportedEvents.Add(class'KFSeqEvent_MapObjectiveActivated')

	XPDifficultyScalars=(1.0f,1.3f,1.75f,2.0f)
	DoshDifficultyScalars=(1.2f,1.0f,1.0f,0.9f)

	DoshRewards = (200,250,300,350,400,450,500,500,500,500,500)
	XPRewards = (100,100,150,150,200,200,250,250,300,300,300)

	DoshValueModifier=0.5f

	ObjectiveIcon=Texture2D'Objectives_UI.UI_Objectives_ObjectiveMode'
	ObjectiveIconColor=(R=185, G=70, B=255, A=255);
}