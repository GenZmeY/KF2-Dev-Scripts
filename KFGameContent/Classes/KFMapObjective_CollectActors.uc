//=============================================================================
// KFMapObjective_CollectActors
//=============================================================================
// Objective class for keeping track of collectibles found by players
//=============================================================================
// Killing Floor 2
// Copyright (C) 2018 Tripwire Interactive LLC
//=============================================================================
class KFMapObjective_CollectActors extends KFMapObjective_VolumeBase;

/** A delay from the the start of an objective, so the player can't automatically activate the first actor */
var() float ActivationDelay;
/** How long until the next actor can be activated. */
var() float TimeUntilNextActivation;
/** A sound to play when the objective is fully complete */
var() AkEvent SuccessSoundEvent;
/** How many actors needs to be activated for the objective to be completed. */
var() array<int> NumRequired;
/** How many actors have been activated. */
var repnotify int NumAccomplished;
/** An actor that visually represents the delivery volume*/
var() SkeletalMeshActor DeliveryMeshActor;
/** An animation to play on the DeliveryMeshActor when this objective activates*/
var() name DeliveryOpenAnimName;
/** An animation to play on the DeliveryMeshActor when this objective deactivates*/
var() name DeliveryCloseAnimName;
/** How long to delay the playing of the close anim after the objective is complete (to give Kismet time to finish things) */
var() float DeliveryCloseAnimDelay;
/** Amount of timer since last collectible was reset to consider "recent" in terms of UI messaging to the player*/
var float CollectibleResetTimerLength;
/** Whether a collectible has been reset recently*/
var repnotify bool bCollectibleReset;

struct CollectibleActorInfo
{
	// Collectible actor
	var() KFObjectiveCollectActor Collectible;
	// Trigger for collectible actor
	var() KFUsableTrigger CollectibleTrigger;
};

// All collectible actors associated with this objective
var() array<CollectibleActorInfo> CollectibleInfo;
// Whether the sequence of collectibles should be randomized
var() bool bRandomSequence;
// The number of collectible actors that should be active at the same time
var() array<int> NumDesiredActiveCollectibles;

var transient array<int> AvailableCollectibleIndices;

var transient class DeliveryClass;

var float CollectActorIconSize;
var const color CollectibleIconAvailableColor;
var const color CollectibleIconCarriedColor;

var float UpdateTrailActorInterval;

enum ESoundSelectionType
{
	ESoundSelectionType_Random,
	ESoundSelectionType_Location,
	ESoundSelectionType_Ordered,
	ESoundSelectionType_Progress
};

struct KFSoundEventGroup
{
	var() ESoundSelectionType SoundType;
	var() array<AKEvent> SoundEvents;
	var int CurrentEvent;
};

// AUDIO EVENTS
/** Sounds to play when one of the collectibles is dropped on the ground */
var() KFSoundEventGroup CollectibleDroppedSoundEvents;
/** Sounds to play when one of the collectibles is successfully delivered */
var() KFSoundEventGroup CollectibleDeliveredSoundEvents;
/** Sounds to play when one of the collect actors is activated */
var() KFSoundEventGroup CollectibleActivateSoundEvents;
/** Sounds to play when one of the players picks up an object from its original spawn */
var() KFSoundEventGroup CollectibleCollectSoundEvents;
/** A sound to play when the players have not collected in object in some time */
var() AkEvent		 CollectActorReminderSoundEvent;

/** How frequently to play audio when a collectible is dropped on the ground */
var() float CollectibleDroppedInterval;
/** How frequently to play audio when the player picks up an object from the collect actor */
var() float CollectibleCollectInterval;
/** How frequently to remind players that they need to pick up a collectible */
var() float CollectActorReminderInterval;

replication
{
	if (bNetDirty)
		NumAccomplished, bCollectibleReset;
}

simulated function ReplicatedEvent(name VarName)
{
	if (VarName == nameof(NumAccomplished))
	{
		if (NumAccomplished != 0)
		{
			TriggerObjectiveProgressEvent(, float(NumAccomplished)/float(GetNumRequired()));
		}
	}
	else
	{
		super.ReplicatedEvent(VarName);
	}
}

//////////////////////////////////////////////////////////////////////////////////////////////////////
// KFInterface_MapObjective
simulated function ActivateObjective()
{
	local int i;

	super.ActivateObjective();

	// every few seconds check whether a new trail actor has been set
	SetTimer(UpdateTrailActorInterval, true, nameof(UpdateTrailActor));

	if (DeliveryMeshActor != none)
	{
		DeliveryMeshActor.SkeletalMeshComponent.PlayAnim(DeliveryOpenAnimName);
	}

	if (Role == ROLE_Authority)
	{
		// initialize the array of collectibles to choose from
		for (i = 0; i < CollectibleInfo.Length; ++i)
		{
			CollectibleInfo[i].Collectible.ObjectiveOwner = self;
			AvailableCollectibleIndices.AddItem(i);
		}

		NumAccomplished = 0;
		bActive = true;
		bForceNetUpdate = true;

		if (ActivationDelay > 0.f)
		{
			SetTimer(ActivationDelay, false, nameof(ChooseNextCollectible));
		}
		else
		{
			ChooseNextCollectible();
		}
	}
}

simulated function PlayDeliveryMeshCloseAnim()
{
	if (DeliveryMeshActor != none)
	{
		DeliveryMeshActor.SkeletalMeshComponent.PlayAnim(DeliveryCloseAnimName);
	}
}

simulated function DeactivateObjective()
{
	local CollectibleActorInfo Info;
	local KFPawn_Human KFPH;
	local KFDroppedPickup_Carryable DroppedCarryable;
	local KFCarryableObject_Collectible CarryableObject;
	local Inventory InventoryItem;

	super.DeactivateObjective();

	if (DeliveryCloseAnimDelay > 0.f)
	{
		SetTimer(DeliveryCloseAnimDelay, false, nameof(PlayDeliveryMeshCloseAnim));
	}
	else
	{
		PlayDeliveryMeshCloseAnim();
	}

	if (Role == ROLE_Authority)
	{
		bActive = false;
		bForceNetUpdate = true;

		if (GetProgress() >= 1.f)
		{
			PlaySoundBase(SuccessSoundEvent, false, WorldInfo.NetMode == NM_DedicatedServer);
		}
		else
		{
			PlaySoundBase(FailureSoundEvent, false, WorldInfo.NetMode == NM_DedicatedServer);
		}

		ClearTimer(nameof(ChooseNextCollectible));

		// also disable all of the actor collectors
		foreach CollectibleInfo(Info)
		{
			Info.CollectibleTrigger.bActive = false;
			Info.Collectible.SetEnabled(false);
			Info.Collectible.SetActive(false);
			Info.Collectible.bForceNetUpdate = true;
		}

		// grant the players' rewards
		// remove the remaining carryables in the world from players' hands
		foreach WorldInfo.AllPawns(class'KFPawn_Human', KFPH)
		{
			GrantReward(KFPlayerReplicationInfo(KFPH.PlayerReplicationInfo), KFPlayerController(KFPH.Controller));

			if (KFPH != none && KFPH.InvManager != none)
			{
				InventoryItem = KFPH.InvManager.FindInventoryType(class<Inventory>(DeliveryClass), true);
				if (InventoryItem != none)
				if (InventoryItem != none)
				{
					KFPH.InvManager.RemoveFromInventory(InventoryItem);

					CarryableObject = KFCarryableObject_Collectible(InventoryItem);
					if (CarryableObject != none)
					{
						CarryableObject.UpdateReplicationInfo(false);
					}
				}
			}
		}

		// destroy all pickups sitting on the ground
		foreach AllActors(class'KFDroppedPickup_Carryable', DroppedCarryable)
		{
			if (DroppedCarryable != none)
			{
				DroppedCarryable.Destroy();
			}
		}
	}

	ClearTimer(nameof(Timer_CollectibleCollectCooldown));
	ClearTimer(nameof(Timer_CollectibleDroppedCooldown));
	ClearTimer(nameof(CollectActorReminder));
	ClearTimer(nameof(UpdateTrailActor));

	if (WorldInfo.NetMode != NM_DedicatedServer)
	{
		if (TrailActor != none)
		{
			TrailActor.Destroy();
			TrailActor = none;
		}
	}
}

simulated function bool IsActive()
{
	return bActive;
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
	return float(NumAccomplished) / float(GetNumRequired());
}

simulated function bool IsComplete()
{
	return GetProgress() >= 1.f;
}

simulated function float GetActivationPctChance()
{
	return 1.f;
}

simulated function string GetLocalizedRequirements()
{
	return Localize("Objectives", default.RequirementsLocKey, "KFGame") @ GetNumRequired();
}

simulated function GetLocalizedStatus(out string statusMessage, out int bWarning, out int bNotification)
{
	local int i;
	local bool bDropped, bCarried, bReadyForPickup;

	statusMessage = "";

	if (GetProgress() >= 1.f)
	{
		statusMessage = Localize("Objectives", "KillRemainingZeds", LocalizationPackageName);
		bWarning = 0;
		bNotification = 0;
		return;
	}

	for (i = 0; i < CollectibleInfo.Length; ++i)
	{
		if (CollectibleInfo[i].Collectible != none)
		{
			switch (CollectibleInfo[i].Collectible.CollectibleState)
			{
			case ECollectibleState_None:
				if (CollectibleInfo[i].Collectible.bActive)
				{
					bReadyForPickup = true;
				}
				break;
			case ECollectibleState_Carried:
				bCarried = true;
				break;
			case ECollectibleState_Dropped:
				bDropped = true;
				break;
			}
		}
	}

	if (bDropped)
	{
		statusMessage = Localize("Objectives", "Dropped", LocalizationPackageName);
		bWarning = 1;
		return;
	}

	if (bCarried)
	{
		statusMessage = Localize("Objectives", "PickedUp", LocalizationPackageName);
		bNotification = 1;
		return;
	}

	if (bCollectibleReset)
	{
		statusMessage = Localize("Objectives", "Reset", LocalizationPackageName);
		bWarning = 1;
		return;
	}

	if (bReadyForPickup)
	{
		statusMessage = Localize("Objectives", "PickupTransportItem", LocalizationPackageName);
		bNotification = 1;
		return;
	}
}

simulated function bool ShouldDrawIcon()
{
	return true;
}

simulated function Vector GetIconLocation()
{
	return Location;
}


simulated function DrawHUDActiveCollectibles(KFHUDBase hud, Canvas drawCanvas, bool bDropShadow)
{
	local KFDroppedPickup_Carryable droppedCarryable;
	local int i;
	local float DropShadowModifier;

	DropShadowModifier = bDropShadow ? 1.0f : 0.0f;

	for (i = 0; i < CollectibleInfo.Length; i++)
	{
		if (CollectibleInfo[i].CollectibleTrigger.bActive && CollectibleInfo[i].Collectible != none)
		{
			DrawIconAtLocation(hud, drawCanvas, GetCollectibleIcon(), CollectibleInfo[i].Collectible.Location, -16.f + DropShadowModifier, -50.f + DropShadowModifier);
		}
	}

	// at the location of all of the dropped collectible objects
	foreach AllActors(class'KFDroppedPickup_Carryable', droppedCarryable)
	{
		if (droppedCarryable != none)
		{
			DrawIconAtLocation(hud, drawCanvas, GetCollectibleIcon(), droppedCarryable.Location, -16.f + DropShadowModifier, -50.f + DropShadowModifier);
		}
	}
}

simulated function DrawHUDCarriedCollectibles(KFHUDBase hud, Canvas drawCanvas, bool bDropShadow)
{
	local int i;
	local KFPawn_Human KFPH;
	local float BarLength, FontScale, ResModifier, DropShadowModifier;
	local PlayerController LocalPC;
	local KFPlayerReplicationInfo KFPRI;
	local PlayerReplicationInfo PRI;
	local array<Controller> PawnPlayerControllers;

	LocalPC = GetALocalPlayerController();
	ResModifier = WorldInfo.static.GetResolutionBasedHUDScale() * hud.FriendlyHudScale;
	BarLength = FMin(hud.PlayerStatusBarLengthMax * (drawCanvas.ClipX / 1024.f), hud.PlayerStatusBarLengthMax) * ResModifier;
	FontScale = class'KFGameEngine'.Static.GetKFFontScale() * hud.FriendlyHudScale;
	DropShadowModifier = bDropShadow ? 1.0f : 0.0f;

	foreach WorldInfo.AllPawns(class'KFPawn_Human', KFPH)
	{
		// don't show the icon above the local player's head
		if (LocalPC == none || LocalPC != KFPH.Controller)
		{
			if (KFPH.Mesh != none && KFPH.CylinderComponent != none && KFPH.Mesh.SkeletalMesh != none && KFPH.Mesh.bAnimTreeInitialised && `TimeSince(KFPH.Mesh.LastRenderTime) < 0.2f)
			{
				PawnPlayerControllers.AddItem(KFPH.Controller);

				if (ClassIsChildOf(KFPH.WeaponClassForAttachmentTemplate, DeliveryClass))
				{
					DrawIconAtLocation(hud, drawCanvas, GetCollectibleIcon(),
						KFPH.Mesh.GetPosition() + (KFPH.CylinderComponent.CollisionHeight * vect(0, 0, 2.5f)),
						(BarLength * -0.5f) - (hud.PlayerStatusIconSize * ResModifier) - (CollectActorIconSize * ResModifier) + DropShadowModifier,		// to the left of the perk icon
						CollectActorIconSize * FontScale * ResModifier * 0.5f + DropShadowModifier);													// centered vertically
				}
			}
		}
	}

	for (i = 0; i < WorldInfo.GRI.PRIArray.Length; i++)
	{
		PRI = WorldInfo.GRI.PRIArray[i];
		KFPRI = KFPlayerReplicationInfo(PRI);

		if (KFPRI != none && KFPRI.bCarryingCollectible)
		{
			if (PawnPlayerControllers.Find(KFPRI.Owner) == INDEX_NONE && PRI != LocalPC.PlayerReplicationInfo)
			{
				DrawIconAtLocation(hud, drawCanvas, GetCollectibleIcon(),
					KFPRI.GetSmoothedPawnIconLocation(hud.HumanPlayerIconInterpMult) + class'KFPawn_Human'.default.CylinderComponent.CollisionHeight * vect(0, 0, 2),
					-1 * (hud.PlayerStatusIconSize * ResModifier) - (CollectActorIconSize * ResModifier) + DropShadowModifier,					// to the left of the perk icon
					-1 * CollectActorIconSize * ResModifier + DropShadowModifier);																// centered vertically
			}
		}
	}
}

simulated function DrawHUD(KFHUDBase hud, Canvas drawCanvas)
{
	// at the location of all the active locations out in the world
	if (!IsLocalPlayerCarryingACollectible())
	{
		if (drawCanvas != none)
		{
			drawCanvas.SetDrawColorStruct(hud.PlayerBarShadowColor);
			DrawHUDActiveCollectibles(hud, drawCanvas, true);
			drawCanvas.SetDrawColorStruct(CollectibleIconAvailableColor);
			DrawHUDActiveCollectibles(hud, drawCanvas, false);
		}
	}

	// at the location of all the collectible objects being carried by players
	if (drawCanvas != none)
	{
		drawCanvas.SetDrawColorStruct(hud.PlayerBarShadowColor);
		DrawHUDCarriedCollectibles(hud, drawCanvas, true);
		drawCanvas.SetDrawColorStruct(CollectibleIconCarriedColor);
		DrawHUDCarriedCollectibles(hud, drawCanvas, false);
	}
}

// don't show the objective HUD unless the local player is carrying a collectible
simulated function bool ShouldShowObjectiveHUD()
{
	return IsLocalPlayerCarryingACollectible();
}

// always show the objective progress regardless of draw distance
simulated function bool HasObjectiveDrawDistance()
{
	return false;
}

simulated function Texture2D GetCollectibleIcon()
{
	return ObjectiveIcon;
}

simulated function string GetProgressText()
{
	if (!bActive)
	{
		return "";
	}

	return NumAccomplished $ "/" $ GetNumRequired();
}

simulated function bool GetIsMissionCritical()
{
	return bIsMissionCriticalObjective;
}
// end KFInterface_MapObjective
//////////////////////////////////////////////////////////////////////////////////////////////////////

simulated function PlaySoundEvent(out KFSoundEventGroup SoundGroup, int nSpecificIndex)
{
	local int nIndex;

	switch (SoundGroup.SoundType)
	{
	case ESoundSelectionType_Random:
		nIndex = Rand(SoundGroup.SoundEvents.Length);
		break;
	case ESoundSelectionType_Location:
		nIndex = nSpecificIndex;
		break;
	case ESoundSelectionType_Ordered:
		nIndex = SoundGroup.CurrentEvent;

		SoundGroup.CurrentEvent++;
		//loop back to the beginning
		if (SoundGroup.CurrentEvent >= SoundGroup.SoundEvents.length)
		{
			SoundGroup.CurrentEvent = 0;
		}
		break;
	case ESoundSelectionType_Progress:
		nIndex = NumAccomplished;
		break;
	}

	if (nIndex >= 0 && nIndex < SoundGroup.SoundEvents.Length && SoundGroup.SoundEvents[nIndex] != none)
	{
		PlaySoundBase(SoundGroup.SoundEvents[nIndex], false, WorldInfo.NetMode == NM_DedicatedServer);
	}
}

simulated function ResetOrderedSoundEventsForRespawn()
{
	if (CollectibleActivateSoundEvents.SoundType == ESoundSelectionType_Ordered)
	{
		CollectibleActivateSoundEvents.CurrentEvent--;
	}

	if (CollectibleCollectSoundEvents.SoundType == ESoundSelectionType_Ordered)
	{
		CollectibleCollectSoundEvents.CurrentEvent--;
	}

	if (CollectibleDroppedSoundEvents.SoundType == ESoundSelectionType_Ordered)
	{
		CollectibleDroppedSoundEvents.CurrentEvent--;
	}
}

simulated function OnCollectActor(KFObjectiveCollectActor Collectible)
{
	if (!bActive)
	{
		return;
	}

	if (!IsTimerActive(nameof(Timer_CollectibleCollectCooldown)))
	{
		//play the matching "collected" sound for that collect actor
		PlaySoundEvent(CollectibleCollectSoundEvents, GetCollectibleIndexFromCollectActor(Collectible));
		SetTimer(CollectibleCollectInterval, false, nameof(Timer_CollectibleCollectCooldown));
	}
}

simulated function ProgressObjective()
{
	local KFGameReplicationInfo KFGRI;

	if (Role == ROLE_Authority)
	{
		NumAccomplished++;
		bForceNetUpdate = true;

		if (GetProgress() >= 1.f)
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
				SetTimer(TimeUntilNextActivation, false, nameof(ChooseNextCollectible));
			}
			else
			{
				ChooseNextCollectible();
			}
		}

		TriggerObjectiveProgressEvent(, float(NumAccomplished) / float(GetNumRequired()));
	}
}

simulated function ChooseNextCollectible()
{
	local int i, j, RandAvailableIdx, RandCollectibleIdx, NumActiveCollectibles;
	local bool NeedsAvailableInit;

	if (Role == ROLE_Authority)
	{
		if (CollectibleInfo.Length == 0)
		{
			return;
		}

		// if there are more required deliveries than there are spawn locations,
		// then enter a mode where whenever a collectible is delivered it gets respawned back where it came from
		NeedsAvailableInit = AvailableCollectibleIndices.Length == 0 && CollectibleInfo.Length < GetNumRequired();
		for (i = 0; i < CollectibleInfo.Length; ++i)
		{
			// check number of active (non-completed) collectibles
			if (CollectibleInfo[i].CollectibleTrigger.bActive)
			{
				NumActiveCollectibles++;
			}
			// initialize the array of collectibles to choose from
			else if (NeedsAvailableInit)
			{
				AvailableCollectibleIndices.AddItem(i);
			}
		}

		// if less than the desired amount
		for(j = 0; j < GetNumDesiredActive() - NumActiveCollectibles; j++)
		{
			if (AvailableCollectibleIndices.Length <= 0) break;

			// choose another (random or ordered) and spawn it
			RandAvailableIdx = bRandomSequence ? Rand(AvailableCollectibleIndices.Length) : 0;
			RandCollectibleIdx = AvailableCollectibleIndices[RandAvailableIdx];
			AvailableCollectibleIndices.Remove(RandAvailableIdx, 1);

			// unhide the chosen collectible and set the trigger and collect actor  as active
			CollectibleInfo[RandCollectibleIdx].Collectible.SetEnabled(true);
			CollectibleInfo[RandCollectibleIdx].Collectible.SetActive(true);
			CollectibleInfo[RandCollectibleIdx].Collectible.bForceNetUpdate = true;

			CollectibleInfo[RandCollectibleIdx].CollectibleTrigger.bActive = true;

			// play audio event for activating object
			PlaySoundEvent(CollectibleActivateSoundEvents, RandCollectibleIdx);
		}
	}
}

simulated function Actor FindClosestActiveCollector()
{
	local CollectibleActorInfo Info;
	local float shortestDistance, currentDistance;
	local Actor closestActor;
	local PlayerController LocalPC;

	LocalPC = GetALocalPlayerController();
	closestActor = none;
	shortestDistance = -1.f;

	if (LocalPC != none && LocalPC.Pawn != none)
	{
		foreach CollectibleInfo(Info)
		{
			if (Info.Collectible != none && Info.Collectible.bActive)
			{
				// measure the distance from the local player to the object and choose the closest one
				currentDistance = VSize(Info.Collectible.Location - LocalPC.Pawn.Location);
				if (shortestDistance < 0 || currentDistance < shortestDistance)
				{
					shortestDistance = currentDistance;
					closestActor = Info.CollectibleTrigger;
				}
			}
		}
	}

	return closestActor;
}

simulated function bool GetClosestPlayerCarryingACollectible(out vector CarrierLocation)
{
	local KFPawn_Human KFPH;
	local PlayerController LocalPC;
	local array<Controller> PawnPlayerControllers;
	local int i;
	local PlayerReplicationInfo PRI;
	local KFPlayerReplicationInfo KFPRI;
	local bool bFoundCarrier;
	local float CurrentDistance;

	LocalPC = GetALocalPlayerController();
	bFoundCarrier = false;

	// carried by players within replication range
	foreach WorldInfo.AllPawns(class'KFPawn_Human', KFPH)
	{
		if (LocalPC == none || LocalPC != KFPH.Controller)
		{
			if (KFPH.Mesh != none && KFPH.CylinderComponent != none && KFPH.Mesh.SkeletalMesh != none && KFPH.Mesh.bAnimTreeInitialised && `TimeSince(KFPH.Mesh.LastRenderTime) < 0.2f)
			{
				PawnPlayerControllers.AddItem(KFPH.Controller);

				// carrying the current objective type
				if (ClassIsChildOf(KFPH.WeaponClassForAttachmentTemplate, DeliveryClass))
				{
					if (LocalPC.Pawn != none)
					{
						if (!bFoundCarrier || VSize(KFPH.Mesh.GetPosition() - LocalPC.Pawn.Location) < CurrentDistance)
						{
							CarrierLocation = KFPH.Mesh.GetPosition();
							CurrentDistance = VSize(CarrierLocation - LocalPC.Pawn.Location);
							bFoundCarrier = true;
						}
					}
				}
			}
		}
	}

	// using the replication info to get the smoothed position of players outside of range
	for (i = 0; i < WorldInfo.GRI.PRIArray.Length; i++)
	{
		PRI = WorldInfo.GRI.PRIArray[i];
		KFPRI = KFPlayerReplicationInfo(PRI);

		if (KFPRI != none && KFPRI.bCarryingCollectible)
		{
			if (PawnPlayerControllers.Find(KFPRI.Owner) == INDEX_NONE && PRI != LocalPC.PlayerReplicationInfo)
			{
				if (!bFoundCarrier || VSize(KFPRI.GetSmoothedPawnIconLocation(0.0f) - LocalPC.Pawn.Location) < CurrentDistance)
				{
					CarrierLocation = KFPRI.GetSmoothedPawnIconLocation(0.0f);
					CurrentDistance = VSize(CarrierLocation - LocalPC.Pawn.Location);
					bFoundCarrier = true;
				}
			}
		}
	}

	return bFoundCarrier;
}

simulated function bool GetClosestDroppedCollectible(out Actor DroppedCarryable)
{
	local KFDroppedPickup_Carryable CurrentCarryable;
	local float CurrentDistance, ShortestDistance;
	local PlayerController LocalPC;

	LocalPC = GetALocalPlayerController();

	if (LocalPC != none && LocalPC.Pawn != none)
	{
		foreach AllActors(class'KFDroppedPickup_Carryable', CurrentCarryable)
		{
			if (CurrentCarryable != none)
			{
				CurrentDistance = VSize(CurrentCarryable.Location - LocalPC.Pawn.Location);
				if (DroppedCarryable == none || CurrentDistance < ShortestDistance)
				{
					ShortestDistance = CurrentDistance;
					DroppedCarryable = CurrentCarryable;
				}
			}
		}
	}

	return DroppedCarryable != none;
}

simulated function UpdateTrailActor()
{
	local Actor pathTarget;
	local vector CarrierLocation;
	local PlayerController LocalPC;
	local float AnchorDist;

	// only set a trail actor if this map objective is active
	if (bActive && WorldInfo.NetMode != NM_DedicatedServer)
	{
		if (TrailActor == none)
		{
			TrailActor = class'WorldInfo'.static.GetWorldInfo().Spawn(class'KFReplicatedShowPathActor', none);
		}

		if (IsLocalPlayerCarryingACollectible())
		{
			//TrailActor.SetEmitterTemplate(ParticleSystem'FX_Objective_Temp.FX_Objective_Temp_Transport_Trail');
			TrailActor.SetEmitterTemplate(ParticleSystem'FX_Gameplay_EMIT.FX_Objective_White_Trail');
		}
		else
		{
			//TrailActor.SetEmitterTemplate(ParticleSystem'FX_Objective_Temp.FX_Objective_Temp_Collect_Trail');
			TrailActor.SetEmitterTemplate(ParticleSystem'FX_Gameplay_EMIT.FX_Objective_White_Trail');
		}

		if (IsLocalPlayerCarryingACollectible()) // local player carrying an object
		{
			pathTarget = self;
		}
		else
		{
			if (GetClosestPlayerCarryingACollectible(CarrierLocation)) // any player carrying an object
			{
				// getting the anchor from the carrier location so the same type of pathfinding can be used
				LocalPC = GetALocalPlayerController();
				if (LocalPC.Pawn != none)
				{
					pathTarget = LocalPC.Pawn.GetBestAnchor(none, CarrierLocation, false, false, AnchorDist);
				}
			}
			else if (!GetClosestDroppedCollectible(pathTarget)) // any dropped collectible
			{
				// any active collectible
				pathTarget = FindClosestActiveCollector();
			}
		}

		if (pathTarget != TrailActor.Target)
		{
			TrailActor.SetPathTarget(pathTarget);
		}
	}
}

simulated function ResetCollectReminder()
{
	SetTimer(CollectActorReminderInterval, true, nameof(CollectActorReminder));
}

simulated function ClearCollectReminder()
{
	ClearTimer(nameof(CollectActorReminder));
}

simulated function CollectActorReminder()
{
	if (CollectActorReminderSoundEvent != none)
	{
		PlaySoundBase(CollectActorReminderSoundEvent, false, WorldInfo.NetMode == NM_DedicatedServer);
	}
}

simulated function int GetCollectibleIndexFromCollectActor(KFObjectiveCollectActor collectActor)
{
	local int i;

	for (i = 0; i < CollectibleInfo.Length; ++i)
	{
		if (CollectibleInfo[i].Collectible == collectActor)
		{
			return i;
		}
	}

	return INDEX_NONE;
}

// This event is received from a volume that has this actor as its AssociatedActor
event Touch(Actor Other, PrimitiveComponent OtherComp, vector HitLocation, vector HitNormal)
{
	local KFDroppedPickup Pickup;
	local KFPawn_Human KFPH;
	local bool bShouldProgress;
	local KFCarryableObject_Collectible carryableObject;
	local Inventory InventoryItem;
	local KFInventoryManager KFInvManager;

	super.Touch(Other, OtherComp, HitLocation, HitNormal);

	if (bActive)
	{
		bShouldProgress = false;

		Pickup = KFDroppedPickup(Other);
		if (Pickup != none && Pickup.Inventory != none)
		{
			if (ClassIsChildOf(Pickup.Inventory.Class, DeliveryClass))
			{
				// find which collectible this belongs to; needs to happen before the object gets destroyed below
				carryableObject = KFCarryableObject_Collectible(Pickup.Inventory);
				if (carryableObject != none && carryableObject.ParentCollectActor != none)
				{
					//play the matching "dropped off" sound for that collect actor
					PlaySoundEvent(CollectibleDeliveredSoundEvents, GetCollectibleIndexFromCollectActor(carryableObject.ParentCollectActor));
				}

				Pickup.Destroy();
				bShouldProgress = true;
			}
		}

		KFPH = KFPawn_Human(Other);
		if (KFPH != none)
		{
			InventoryItem = KFPH.InvManager.FindInventoryType(class<Inventory>(DeliveryClass), true);
			if (InventoryItem != none)
			{
				// find which collectible this belongs to; needs to happen before the object gets destroyed below
				carryableObject = KFCarryableObject_Collectible(InventoryItem);
				if (carryableObject != none && carryableObject.ParentCollectActor != none)
				{
					//play the matching "dropped off" sound for that collect actor
					PlaySoundEvent(CollectibleDeliveredSoundEvents, GetCollectibleIndexFromCollectActor(carryableObject.ParentCollectActor));
					carryableObject.UpdateReplicationInfo(false);
				}

				KFInvManager = KFInventoryManager(KFPH.InvManager);
				if (KFInvManager != none && KFInvManager.ItemIsInInventory(InventoryItem))
				{
					KFPH.InvManager.RemoveFromInventory(InventoryItem);
					InventoryItem.Destroy();
					bShouldProgress = true;
				}
			}
		}

		if (bShouldProgress)
		{
			if (carryableObject != none && carryableObject.ParentCollectActor != none)
			{
				carryableObject.ParentCollectActor.SetCollectibleState(ECollectibleState_Delivered);
			}

			ProgressObjective();
		}
	}
}

simulated function Timer_CollectibleReset()
{
	bCollectibleReset = false;
}

simulated function RespawnCollectible(KFObjectiveCollectActor collectActor)
{
	local int i;

	bCollectibleReset = true;
	SetTimer(CollectibleResetTimerLength, false, nameof(Timer_CollectibleReset));

	ResetOrderedSoundEventsForRespawn();

	for (i = 0; i < CollectibleInfo.Length; i++)
	{
		if (CollectibleInfo[i].Collectible == collectActor)
		{
			AvailableCollectibleIndices.InsertItem(0, i);
			CollectibleInfo[i].Collectible.SetEnabled(false);
			CollectibleInfo[i].Collectible.SetActive(false);
			CollectibleInfo[i].CollectibleTrigger.bActive = false;
			ChooseNextCollectible();
			break;
		}
	}
}

simulated function OnCarryableDropped(KFObjectiveCollectActor collectActor)
{
	if (!IsTimerActive(nameof(Timer_CollectibleDroppedCooldown)))
	{
		PlaySoundEvent(CollectibleDroppedSoundEvents, GetCollectibleIndexFromCollectActor(collectActor));
		SetTimer(CollectibleDroppedInterval, false, nameof(Timer_CollectibleDroppedCooldown));
	}
}

simulated function DrawIconAtLocation(KFHUDBase hud, Canvas drawCanvas, Texture2D icon, vector iconLocation, float xOffset, float yOffset)
{
	local vector ScreenPos;
	local float ResModifier;

	local float ViewDot;
	local vector ViewLocation, ViewVector;
	local rotator ViewRotation;
	local PlayerController LocalPC;

	// determine whether that object is within the player's view
	LocalPC = GetALocalPlayerController();
	if (LocalPC != none)
	{
		LocalPC.GetPlayerViewPoint(ViewLocation, ViewRotation);
		ViewVector = vector(ViewRotation);
	}
	ViewDot = Normal((iconLocation + (class'KFPawn_Human'.default.CylinderComponent.CollisionHeight * vect(0, 0, 1))) - ViewLocation) dot ViewVector;

	if (icon != none && ViewDot > 0)
	{
		ResModifier = WorldInfo.static.GetResolutionBasedHUDScale() * hud.FriendlyHudScale;
		ScreenPos = drawCanvas.Project(iconLocation);
		ScreenPos.X += xOffset;
		ScreenPos.Y += yOffset;

		if (ScreenPos.X < 0 || ScreenPos.X > drawCanvas.ClipX || ScreenPos.Y < 0 || ScreenPos.Y > drawCanvas.ClipY)
		{
			//if it is off screen, do not render
			return;
		}


		//draw icon
		drawCanvas.SetPos(ScreenPos.X, ScreenPos.Y + 12); //offset to better align with the other icons in the player's name tag
		drawCanvas.DrawTile(icon, CollectActorIconSize * ResModifier, CollectActorIconSize * ResModifier, 0, 0, 256, 256);
	}
}

simulated function bool IsLocalPlayerCarryingACollectible()
{
	local PlayerController LocalPC;
	local KFPawn_Human KFPH;
	local Inventory InventoryItem;

	LocalPC = GetALocalPlayerController();

	if (LocalPC != none && LocalPC.Pawn != none)
	{
		KFPH = KFPawn_Human(LocalPC.Pawn);

		InventoryItem = KFPH.InvManager.FindInventoryType(class<Inventory>(DeliveryClass), true);
		return (KFPH != none && InventoryItem != none);
	}

	return false;
}

simulated function int GetNumRequired()
{
	local int PlayerCount;
	local KFGameReplicationInfo KFGRI;

	KFGRI = KFGameReplicationInfo(WorldInfo.GRI);
	PlayerCount = Clamp(KFGRI.GetNumPlayers(), 1, 6) - 1;

	if (PlayerCount < NumRequired.Length)
	{
		return NumRequired[PlayerCount];
	}
	else if (NumRequired.Length > 0)
	{
		// if there weren't enough entries, use the last one
		return NumRequired[NumRequired.Length - 1];
	}

	return 1;
}

simulated function int GetNumDesiredActive()
{
	local int PlayerCount;
	local KFGameReplicationInfo KFGRI;

	KFGRI = KFGameReplicationInfo(WorldInfo.GRI);
	PlayerCount = Clamp(KFGRI.GetNumPlayers(), 1, 6) - 1;

	if (PlayerCount < NumDesiredActiveCollectibles.Length)
	{
		return NumDesiredActiveCollectibles[PlayerCount];
	}
	else if (NumDesiredActiveCollectibles.Length > 0)
	{
		// if there weren't enough entries, use the last one
		return NumDesiredActiveCollectibles[NumDesiredActiveCollectibles.Length - 1];
	}

	return 1;
}

function Timer_CollectibleCollectCooldown() {}
function Timer_CollectibleDroppedCooldown() {}

defaultproperties
{
	LocalizationPackageName = "KFGame"
	DescriptionLocKey="TransportWaveDescription"
	DescriptionShortLocKey = "TransportWaveDescriptionShort"
	RequirementsLocKey="RequiredCollectActor"
	LocalizationKey="TransportWaveObjective"
	NameShortLocKey="TransportWaveObjective"

	Physics=PHYS_None
	bStatic=false
	bNoDelete=true
	bTickIsDisabled=false

	RemoteRole=ROLE_SimulatedProxy
	bAlwaysRelevant=true
	bOnlyDirtyReplication=true
	bSkipActorPropertyReplication=true
	bIgnoreNetRelevancyCollision=true
	NetUpdateFrequency=0.1
	bReplicateRigidBodyLocation=false

	bBlockActors=false
	bWorldGeometry=false
	bCollideWorld=false
	bNoEncroachCheck=false
	bProjTarget=false
	bCanStepUpOn=false
	bMovable=false

	bRandomSequence=true
	NumDesiredActiveCollectibles=(1)

	CollectActorIconSize=32.f;
	CollectibleIconAvailableColor=(R=0, G=255, B=0, A=255);
	CollectibleIconCarriedColor=(R=185, G=70, B=255, A=255);

	DeliveryClass = class'KFCarryableObject_Collectible'
	UpdateTrailActorInterval = 1.f;

	CollectActorReminderInterval = 40.f;
	CollectibleDroppedInterval = 20.f;
	CollectibleCollectInterval = 20.f;

	SupportedEvents.Add(class'KFSeqEvent_ObjectiveProgress')

	NumRequired=(1)

	PerPlayerSpawnRateMod=(1.f, 1.f, 1.f, 1.f, 1.f, 1.f)

	ObjectiveIcon=Texture2D'Objectives_UI.UI_Objectives_ObjectiveMode'

	CollectibleResetTimerLength=60.0f;

	DeliveryCloseAnimDelay=7.f
}