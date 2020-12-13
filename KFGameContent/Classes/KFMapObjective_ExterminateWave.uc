//=============================================================================
// KFMapObjective_ExterminateWave
//=============================================================================
// Objective type for exterminating zeds, including bosses. This objective
// simulates a typical Killing Floor "survival" wave.
//=============================================================================
// Killing Floor 2
// Copyright (C) 2018 Tripwire Interactive LLC
//=============================================================================

class KFMapObjective_ExterminateWave extends KFMapObjective_ActorBase;

//=============================================================================
// KFMapObjective_ExterminateWave variables
//=============================================================================

var() bool bBossWave;
var() EBossAIType BossType<EditCondition=bBossWave>;
var() bool bShowBossSpawnTheatrics<EditCondition=bBossWave>;
var() bool bRandomBoss<EditCondition=bBossWave>;

var repnotify float BossHealthPct;
var transient repnotify int WaveProgressIdx, BossProgressIdx;

replication
{
	if (bNetInitial)
		bBossWave, bShowBossSpawnTheatrics;

	if (bNetDirty && !bBossWave)
		WaveProgressIdx;

	if (bNetDirty && bBossWave)
		BossProgressIdx, BossHealthPct;
}

simulated event ReplicatedEvent(name VarName)
{
	switch (VarName)
	{
	case nameof(WaveProgressIdx):
		TriggerWavePctProgress();
		break;

	case nameof(BossProgressIdx):
		TriggerBossHealthPctProgress();
		break;

	default:
		super.ReplicatedEvent(VarName);
	}
}

//=============================================================================
// KFMapObjective_ExterminateWave functions
//=============================================================================

function NotifyZedKilled(Controller Killer, Pawn KilledPawn, bool bIsBoss)
{
	local float OldWavePct, NewWavePct;
	local KFGameReplicationInfo KFGRI;
	local int PrevWaveProgressIdx, GenEvtIdx, i;
	local KFSeqEvent_ExterminateWavePct GenEvt;

	PrevWaveProgressIdx = WaveProgressIdx;

	// the killed zed is a boss, so set the boss health to zero
	// if this isn't done, the objective won't know that it was successfully completed when deactivated
	if (bIsBoss)
	{
		BossHealthPct = 0.0f;
	}

	// check the first applicable generated event (assumes all applicable events are identical)
	for (GenEvtIdx = 0; GenEvtIdx < GeneratedEvents.Length; GenEvtIdx++)
	{
		GenEvt = KFSeqEvent_ExterminateWavePct(GeneratedEvents[GenEvtIdx]);
		if (GenEvt != None)
		{
			KFGRI = KFGameReplicationInfo(WorldInfo.GRI);
			OldWavePct = float(KFGRI.WaveTotalAICount - (KFGRI.AIRemaining + 1)) / float(KFGRI.WaveTotalAICount);
			NewWavePct = float(KFGRI.WaveTotalAICount - KFGRI.AIRemaining) / float(KFGRI.WaveTotalAICount);

			for (i = 0; i < GenEvt.ProgressThresholds.Length; i++)
			{
				if (OldWavePct < GenEvt.ProgressThresholds[i] &&
					NewWavePct >= GenEvt.ProgressThresholds[i])
				{
					WaveProgressIdx = GenEvt.ProgressOutputStartIndex + i;
					break;
				}
			}
			break;
		}
	}

	if (WaveProgressIdx != PrevWaveProgressIdx)
	{
		TriggerWavePctProgress();
	}
}

simulated function TriggerWavePctProgress()
{
	local int GenEvtIdx;
	local KFSeqEvent_ExterminateWavePct GenEvt;
	local array<int> ActivateIndices;

	ActivateIndices.AddItem(WaveProgressIdx);

	// notify all applicable generated events (assumes all applicable events are identical)
	for (GenEvtIdx = 0; GenEvtIdx < GeneratedEvents.Length; GenEvtIdx++)
	{
		GenEvt = KFSeqEvent_ExterminateWavePct(GeneratedEvents[GenEvtIdx]);
		if (GenEvt != None)
		{
			GenEvt.Reset();
			GenEvt.CheckActivate(self, self,, ActivateIndices);
		}
	}
}

function NotifyBossDamaged(KFPawn_Monster Boss, int Damage)
{
	local float OldHealthPct, NewHealthPct;
	local int PrevBossProgressIdx, GenEvtIdx, i;
	local KFSeqEvent_ExterminateBossHealthPct GenEvt;

	PrevBossProgressIdx = BossProgressIdx;

	OldHealthPct = float(Boss.Health + Damage) / float(Boss.HealthMax);
	NewHealthPct = float(Boss.Health) / float(Boss.HealthMax);
	BossHealthPct = NewHealthPct;

	// check the first applicable generated event (assumes all applicable events are identical)
	for(GenEvtIdx = 0; GenEvtIdx < GeneratedEvents.Length; GenEvtIdx++)
	{
		GenEvt = KFSeqEvent_ExterminateBossHealthPct(GeneratedEvents[GenEvtIdx]);
		if(GenEvt != None)
		{
			for (i = 0; i < GenEvt.ProgressThresholds.Length; i++)
			{
				if (OldHealthPct >= GenEvt.ProgressThresholds[i] &&
					NewHealthPct < GenEvt.ProgressThresholds[i])
				{
					BossProgressIdx = GenEvt.ProgressOutputStartIndex + i;
					break;
				}
			}

			break;
		}
	}

	if (BossProgressIdx != PrevBossProgressIdx)
	{
		TriggerBossHealthPctProgress();
	}
}

simulated function TriggerBossHealthPctProgress()
{
	local int GenEvtIdx;
	local KFSeqEvent_ExterminateBossHealthPct GenEvt;
	local array<int> ActivateIndices;

	ActivateIndices.AddItem(BossProgressIdx);

	// notify all applicable generated events (assumes all applicable events are identical)
	for(GenEvtIdx = 0; GenEvtIdx < GeneratedEvents.Length; GenEvtIdx++)
	{
		GenEvt = KFSeqEvent_ExterminateBossHealthPct(GeneratedEvents[GenEvtIdx]);
		if(GenEvt != None)
		{
			GenEvt.Reset();
			GenEvt.CheckActivate(self, self,, ActivateIndices);
		}
	}
}

//=============================================================================
// KFInterface_MapObjective functions
//=============================================================================

// Status
simulated function ActivateObjective()
{
	super.ActivateObjective();

	if (Role == ROLE_Authority)
	{
		BossHealthPct = 1.0f;
		bIsActive = true;

		if (bBossWave)
		{
			if (KFGameInfo_Objective(WorldInfo.Game) != none)
			{
				KFGameInfo_Objective(WorldInfo.Game).SetBossIndex();
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
		// failed the objective
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

		bIsActive = false;
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
	local KFGameReplicationInfo KFGRI;

	KFGRI = KFGameReplicationInfo(WorldInfo.GRI);

	if (bBossWave)
	{
		return FClamp(1.0f - BossHealthPct, 0.0f, 1.0f);
	}

	return FClamp(float(KFGRI.WaveTotalAICount - KFGRI.AIRemaining) / float(KFGRI.WaveTotalAICount), 0.0f, 1.0f);
}

simulated function bool IsComplete()
{
	return false;
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
	local KFGameReplicationInfo KFGRI;

	KFGRI = KFGameReplicationInfo(WorldInfo.GRI);
	return Localize("Objectives", default.RequirementsLocKey, "KFGame") @ KFGRI.WaveTotalAICount;
}

simulated function bool GetIsMissionCritical()
{
	return bIsMissionCriticalObjective;
}

// HUD
simulated function bool ShouldDrawIcon()
{
	return false;
}

simulated function Vector GetIconLocation();
simulated function DrawHUD(KFHUDBase hud, Canvas drawCanvas);

defaultproperties
{
	Begin Object Class=SpriteComponent Name=Sprite
		Sprite=Texture2D'EditorResources.S_Actor'
		HiddenGame=True
		AlwaysLoadOnClient=False
		AlwaysLoadOnServer=False
	End Object
	Components.Add(Sprite)

	GameModeBlacklist.Add(class'KFGameInfo_Survival')
	GameModeBlacklist.Add(class'KFGameInfo_VersusSurvival')
	GameModeBlacklist.Add(class'KFGameInfo_Endless')
	GameModeBlacklist.Add(class'KFGameInfo_WeeklySurvival')

	LocalizationPackageName="KFGame"
	LocalizationKey="ExterminateWaveObjective"
	DescriptionLocKey="ExterminateWaveDescription"
	NameShortLocKey="ExterminateWaveObjective"
	DescriptionShortLocKey="ExterminateWaveDescriptionShort"
	RequirementsLocKey="ExterminateWaveRequired"

	//DefaultIcon=Texture2D'Objectives_UI.UI_Objectives_ObjectiveMode'
	ObjectiveIcon=Texture2D'Objectives_UI.UI_Objectives_ObjectiveMode'
	PerPlayerSpawnRateMod = (1.f, 1.f, 1.f, 1.f, 1.f, 1.f)

	bAlwaysRelevant=true
	RemoteRole=ROLE_SimulatedProxy

	SupportedEvents.Add(class'KFSeqEvent_ExterminateWavePct')
	SupportedEvents.Add(class'KFSeqEvent_ExterminateBossHealthPct')

	WaveProgressIdx=-1
	BossProgressIdx=-1
	BossHealthPct=1.0f
}