//=============================================================================
// KFMapObjective_RepairActors
//=============================================================================
// Objective type for the repair panels. Player must weld n number of actors in
// order to repair them. After one actor is repaired, another will break.
//=============================================================================
// Killing Floor 2
// Copyright (C) 2018 Tripwire Interactive LLC
//=============================================================================
class KFMapObjective_RepairActors extends KFMapObjective_ActorBase;

/** How many actors needs to be repaired for the objective to be completed, per number of players */
var() const int ActivationsRequiredForPlayerCount[6];

/** A delay from the the start of an objective, so the player can't automatically repair the first actor */
var() float ActivationDelay;

/** A sound to play when each repair actor is activated */
var() array<AkEvent> ActorActivationSoundEvents;

/** A sound to play when each repair actor is repaired */
var() array<AkEvent> ActorRepairedSoundEvents;

/** How many actors needs to be repaired for the objective to be completed. */
var int ActivationsRequired;

/** How many actors have been repaired. */
var repnotify int ActorsRepaired;

/** List of all the actors that must be repaired by the user. */
var() array<KFRepairableActor> RepairableActors;

/** List of Repairable Actors we haven't repaired yet. This will ensure we cycle through all actors before repeating. */
var array<KFRepairableActor> UnusedRepairableActors;

/** Reference to last actor repaired so we don't fix the same actor one after the other. */
var KFRepairableActor LastRepairedActor;

/** Current Actor that needs to be repaired. */
var repnotify KFRepairableActor CurrentActorToRepair;

/** How long until the next repairable actor can be activated. */
var() float TimeUntilNextActivation;

/** A sound to play when the objective is fully complete */
var() AkEvent SuccessSoundEvent100pct;

/** A sound to play when the objective is mostly complete */
var() AkEvent SuccessSoundEvent85pct;

/** A sound to play when the objective is adequately complete */
var() AkEvent SuccessSoundEvent50pct;

/** A sound to play when the objective is barely complete */
var() AkEvent SuccessSoundEvent25pct;

/** Win thresholds - Named to match the VO tracks*/
var float JustWinThreshold;
var float StandardWinThreshold;
var float GoodWinThreshold;

/** Whether the sequence of repairables should be randomized */
var() bool bRandomSequence;

replication
{
	if(bNetDirty)
		CurrentActorToRepair, ActorsRepaired, ActivationsRequired;
}

simulated event ReplicatedEvent(name VarName)
{
	if (VarName == nameof(CurrentActorToRepair))
	{
		UpdateTrailActor();
	}
	else if (VarName == nameof(ActorsRepaired))
	{
		if (ActorsRepaired != 0)
		{
			TriggerObjectiveProgressEvent(, float(ActorsRepaired)/float(ActivationsRequired));
		}
	}
	else
	{
		super.ReplicatedEvent(VarName);
	}
}

simulated function ActivateObjective()
{
	local int PlayerCount;
	local KFRepairableActor CurrActor;

	super.ActivateObjective();

	foreach RepairableActors(CurrActor)
	{
		CurrActor.OnRepairCompelete = OnActorRepaired;
	}

	if (WorldInfo.NetMode != NM_DedicatedServer)
	{
		if (bUseTrailToObjective)
		{
			TrailActor = class'WorldInfo'.static.GetWorldInfo().Spawn(class'KFReplicatedShowPathActor', none);
			TrailActor.SetEmitterTemplate(ParticleSystem'FX_Gameplay_EMIT.FX_Objective_White_Trail');
		}
	}

	if (Role == ROLE_Authority)
	{
		PlayerCount = Clamp(KFGameInfo(WorldInfo.Game).GetLivingPlayerCount(), 1, 6) - 1;
		ActivationsRequired = ActivationsRequiredForPlayerCount[PlayerCount];

		ActorsRepaired = 0;
		bIsActive = true;

		if (ActivationDelay > 0.f)
		{
			SetTimer(ActivationDelay, false, 'ActivateNextRepairableActor');
		}
		else
		{
			ActivateNextRepairableActor();
		}
	}
}

simulated function DeactivateObjective()
{
	local KFPlayerController KFPC;
	local KFPawn_Human KFPH;
	local KFRepairableActor CurrActor;

	super.DeactivateObjective();

	if(Role == ROLE_Authority)
	{
		bIsActive = false;

		if (!HasFailedObjective())
		{
			foreach WorldInfo.AllPawns(class'KFPawn_Human', KFPH)
			{
				GrantReward(KFPlayerReplicationInfo(KFPH.PlayerReplicationInfo), KFPlayerController(KFPH.Controller));

				if (KFPlayerController(KFPH.Controller) != none)
				{
					if (GetTotalProgress() >= 1.0f)
					{
						// @todo: hook up seasonal event here if/when desired
					}
				}
			}
		}
		else
		{
			`log("objective failed");
		}

		PlayDeactivationDialog();

		ClearTimer(nameof(ActivateNextRepairableActor));
	}

	foreach RepairableActors(CurrActor)
	{
		CurrActor.Reset();
	}

	if(WorldInfo.NetMode != NM_DedicatedServer)
	{
		if (TrailActor != none)
		{
			TrailActor.Destroy();
			TrailActor = none;
		}
	}

	KFPC = KFPlayerController(GetALocalPlayerController());
	if (KFPC != none && KFPC.MyGFxHUD != none)
	{
		KFPC.MyGFxHUD.WaveInfoWidget.ObjectiveContainer.SetFailState(HasFailedObjective());
	}
}

function PlayDeactivationDialog()
{
	if (GetTotalProgress() <= 0.0f)
	{
		PlaySoundBase(FailureSoundEvent, false, WorldInfo.NetMode == NM_DedicatedServer);
		BroadcastLocalizedMessage(class'KFLocalMessage_Priority', GMT_ObjectiveLost);
	}
	else
	{
		if (GetTotalProgress() <= JustWinThreshold)
		{
			PlaySoundBase(SuccessSoundEvent25pct, false, WorldInfo.NetMode == NM_DedicatedServer);
		}
		else if (GetTotalProgress() <= StandardWinThreshold)
		{
			PlaySoundBase(SuccessSoundEvent50pct, false, WorldInfo.NetMode == NM_DedicatedServer);
		}
		else if (GetTotalProgress() <= GoodWinThreshold)
		{
			PlaySoundBase(SuccessSoundEvent85pct, false, WorldInfo.NetMode == NM_DedicatedServer);
		}
		else
		{
			PlaySoundBase(SuccessSoundEvent100pct, false, WorldInfo.NetMode == NM_DedicatedServer);
		}
	}
}

function ActivateNextRepairableActor()
{
	if(Role == ROLE_Authority)
	{
		LastRepairedActor = CurrentActorToRepair;
		CurrentActorToRepair = ChooseNextActorToRepair();
		if (CurrentActorToRepair != none)
		{
			CurrentActorToRepair.PlayDestroyed();
		}

		if (ActorsRepaired < ActorActivationSoundEvents.Length)
		{
			PlaySoundBase(ActorActivationSoundEvents[ActorsRepaired], false, WorldInfo.NetMode == NM_DedicatedServer);
		}
	}

	UpdateTrailActor();
}

simulated function UpdateTrailActor()
{
	if (WorldInfo.NetMode != NM_DedicatedServer)
	{
		if (TrailActor != none)
		{
			TrailActor.SetPathTarget(CurrentActorToRepair.RepairTrigger);
		}
	}
}

function KFRepairableActor ChooseNextActorToRepair()
{
	local int ChosenActorIndex;
	local KFRepairableActor ChosenActor;
	local array<KFRepairableActor> ValidActors;

	if (RepairableActors.length == 0)
	{
		return none;
	}

	if (UnusedRepairableActors.length == 0)
	{
		UnusedRepairableActors = RepairableActors;
	}

	ValidActors = UnusedRepairableActors;
	if(ValidActors.length > 1)
	{
		ValidActors.RemoveItem(LastRepairedActor);
	}

	if (bRandomSequence)
	{
		ChosenActorIndex = RandRange(0, ValidActors.length - 1);
	}
	else
	{
		// if not random choose the next actor in the sequence
		ChosenActorIndex = 0;
	}

	ChosenActor = ValidActors[ChosenActorIndex];
	UnusedRepairableActors.Remove(ChosenActorIndex, 1);

	return ChosenActor;
}

function OnActorRepaired(KFRepairableActor RepairedActor)
{
	local KFGameReplicationInfo KFGRI;

	if (!bIsActive)
	{
		return;
	}

	if (Role == ROLE_Authority)
	{
		if (ActorsRepaired < ActorRepairedSoundEvents.Length)
		{
			PlaySoundBase(ActorRepairedSoundEvents[ActorsRepaired], false, WorldInfo.NetMode == NM_DedicatedServer);
		}
	}

	ActorsRepaired++;
	TriggerObjectiveProgressEvent(, float(ActorsRepaired) / float(ActivationsRequired));

	if (GetTotalProgress() >= 1.f)
	{
		KFGRI = KFGameReplicationInfo(WorldInfo.GRI);
		if (KFGRI != none)
		{
			KFGRI.DeactivateObjective();
		}
	}
	else
	{
		if (TimeUntilNextActivation > 0.f)
		{
			SetTimer(TimeUntilNextActivation, false, nameof(ActivateNextRepairableActor));
			CurrentActorToRepair = none;
			UpdateTrailActor();
		}
		else
		{
			ActivateNextRepairableActor();
		}
	}
}

simulated function bool IsActive()
{
	return bIsActive;
}

simulated function bool IsBonus()
{
	return true;
}

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

simulated function bool UsesProgress()
{
	return false;
}

simulated function bool ShouldShowObjectiveHUD()
{
	return false;
}

simulated function float GetProgress()
{
	if (!HasFailedObjective())
	{
		return float(ActorsRepaired) / float(ActivationsRequired);
	}

	return 0.f;
}

simulated function bool IsComplete()
{
	return GetProgress() >= 1.f;
}

simulated function float GetTotalProgress()
{
	if (ActivationsRequired == 0)
	{
		return 0.f;
	}

	return float(ActorsRepaired) / float(ActivationsRequired);
}

simulated function float GetActivationPctChance()
{
	return 1.f;
}

simulated function string GetLocalizedRequirements()
{
	return Localize("Objectives", default.RequirementsLocKey, "KFGame") @ ActivationsRequired;
}

simulated function bool ShouldDrawIcon()
{
	return CurrentActorToRepair != none;
}

simulated function Vector GetIconLocation()
{
	if (CurrentActorToRepair != none)
	{
		return CurrentActorToRepair.Location + CurrentActorToRepair.IconLocationOffset;
	}

	return Location;
}

simulated function int GetVoshReward()
{
	local int MaxDosh;

	MaxDosh = GetMaxVoshReward();
	if (MaxDosh == 0)
	{
		return MaxDosh;
	}

	return int(MaxDosh * GetTotalProgress());
}

simulated function int GetXPReward()
{
	local int MaxXP;

	MaxXP = GetMaxXPReward();
	if (MaxXP == 0)
	{
		return MaxXP;
	}

	return int(MaxXP * GetTotalProgress());
}

simulated function string GetProgressText()
{
	if (!bIsActive)
	{
		return "";
	}

	return ActorsRepaired $ "/" $ ActivationsRequired;
}

simulated function bool GetIsMissionCritical()
{
	return bIsMissionCriticalObjective;
}

// this is currently a copy of DrawObjectiveHUD, 
// except it uses the individual repairable weld completion instead of the overall objective completion
simulated function DrawHUD(KFHUDBase hud, Canvas drawCanvas)
{
	local float Percentage;
	local float BarHeight, BarLength;
	local vector ScreenPos, TargetLocation;
	local float ResModifier;
	local float ThisDot;
	local KFGameReplicationInfo KFGRI;
	local vector ViewLocation, ViewVector;
	local rotator ViewRotation;
	local KFPlayerController KFPC;

	ResModifier = WorldInfo.static.GetResolutionBasedHUDScale() * hud.FriendlyHudScale;
	KFGRI = KFGameReplicationInfo(WorldInfo.GRI);
	KFPC = KFPlayerController(GetALocalPlayerController());

	if (!ShouldDrawIcon() || KFGRI.bHidePawnIcons)
	{
		return;
	}

	if (KFPC != none)
	{
		KFPC.GetPlayerViewPoint(ViewLocation, ViewRotation);
	}

	ViewVector = vector(ViewRotation);
	ThisDot = Normal(GetIconLocation()  - ViewLocation) dot ViewVector;

	if (ThisDot <= 0)
	{
		return;
	}

	BarLength = FMin(hud.PlayerStatusBarLengthMax * (drawCanvas.ClipX / 1024.f), hud.PlayerStatusBarLengthMax) * ResModifier;
	BarHeight = FMin(8.f * (drawCanvas.ClipX / 1024.f), 8.f) * ResModifier;
	TargetLocation = GetIconLocation();
	ScreenPos = drawCanvas.Project(TargetLocation);

	// Make sure that the entire health bar is on screen
	ScreenPos.X = FClamp(ScreenPos.X, BarLength * 0.5f + hud.PlayerStatusIconSize, drawCanvas.ClipX - BarLength * 0.5f);
	ScreenPos.Y = FClamp(ScreenPos.Y, hud.PlayerStatusIconSize * 0.5f, drawCanvas.ClipY - hud.PlayerStatusIconSize * 0.5f);

	//Draw progress bar
	Percentage = FMin(FClamp(float(CurrentActorToRepair.WeldIntegrity) / float(CurrentActorToRepair.MaxWeldIntegrity), 0.f, 1.f), 1);
	hud.DrawKFBar(Percentage, BarLength, BarHeight, ScreenPos.X - (BarLength * 0.5f), ScreenPos.Y, hud.NonPlayerHealth);

	//draw objective icon
	if (GetIcon() != none)
	{
		drawCanvas.SetDrawColorStruct(hud.PlayerBarShadowColor);
		drawCanvas.SetPos((ScreenPos.X - (BarLength * 0.75)) + 1, (ScreenPos.Y - BarHeight * 2.0) + 1);
		drawCanvas.DrawTile(GetIcon(), hud.PlayerStatusIconSize * ResModifier, hud.PlayerStatusIconSize * ResModifier, 0, 0, 256, 256);

		drawCanvas.SetDrawColorStruct(GetIconColor());
		drawCanvas.SetPos(ScreenPos.X - (BarLength * 0.75), ScreenPos.Y - BarHeight * 2.0);
		drawCanvas.DrawTile(GetIcon(), hud.PlayerStatusIconSize * ResModifier, hud.PlayerStatusIconSize * ResModifier, 0, 0, 256, 256);
	}
}

defaultproperties
{
	LocalizationKey="RepairObjective"
	DescriptionLocKey="UseWelderToRepair"
	NameShortLocKey="RepairObjective"
	DescriptionShortLocKey="UseWelderToRepairShort"
	RequirementsLocKey="RepairObjectiveRequired"
	bAlwaysRelevant=true
	RemoteRole=ROLE_SimulatedProxy

	TimeUntilNextActivation=5.f

	SupportedEvents.Add(class'KFSeqEvent_ObjectiveProgress')

	GameModeBlacklist.Add(class'KFGameInfo_Endless')
	GameModeBlacklist.Add(class'KFGameInfo_WeeklySurvival')

	Begin Object Class=SpriteComponent Name=Sprite
		Sprite=Texture2D'EditorResources.S_Actor'
		HiddenGame=True
		AlwaysLoadOnClient=False
		AlwaysLoadOnServer=False
	End Object
	Components.Add(Sprite)

	ActivationsRequired=6
	bUseTrailToObjective=true

	PerPlayerSpawnRateMod=(1.f, 1.f, 1.f, 1.f, 1.f, 1.f)

	ObjectiveIcon=Texture2D'Objectives_UI.UI_Objectives_ObjectiveMode'

	//These are basically range caps.  For example:
	//		Just win would be 0% - 25%
	//		Standard win would be 25% - 50%
	//		Good win would be 50% - 85%
	//		Perfect win then assumes everything above good win
	JustWinThreshold=0.25
	StandardWinThreshold=0.5
	GoodWinThreshold=0.85
	LocalizationPackageName="KFGame"

	bRandomSequence=true
}
