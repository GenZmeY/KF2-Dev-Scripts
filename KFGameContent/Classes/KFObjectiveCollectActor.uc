//=============================================================================
// KFObjectiveCollectActor
//=============================================================================
// An actor that plays FX and disappears when collected through a KFUsableTrigger
//=============================================================================
// Killing Floor 2
// Copyright (C) 2018 Tripwire Interactive LLC
//=============================================================================
class KFObjectiveCollectActor extends Actor
	implements(KFInterface_UsableTriggerTarget)
	placeable;

var transient repnotify KFMapObjective_CollectActors ObjectiveOwner;

var() StaticMeshComponent CollectActorMesh;
var() AkEvent CollectedSoundEvent;
var() ParticleSystem CollectedParticleSystem;

// Carryable object to give the player upon collecting this actor. Carryable collectibles must be
// delivered to be considered collected.
var() class<KFCarryableObject> CarryableClass;

var transient repnotify bool bCollected;
var transient repnotify bool bActive;

enum ECollectibleState
{
	ECollectibleState_None,
	ECollectibleState_Carried,
	ECollectibleState_Dropped,
	ECollectibleState_Delivered
};

var transient repnotify ECollectibleState CollectibleState;

replication
{
	if (bNetDirty)
		bCollected, bActive, ObjectiveOwner, CollectibleState;
}

simulated function UpdateActivity()
{
	if (bActive && ObjectiveOwner != none)
	{
		// once in a while check whether the players have not picked up an objective and prompt them again
		ObjectiveOwner.ResetCollectReminder();
	}

	// hide or unhide this based on whether the collect actor is active
	SetEnabled(bActive);
}

simulated function SetEnabled(bool bEnabled)
{
	SetHidden(!bEnabled);
	SetCollision(bEnabled, bEnabled);
}

simulated function SetActive(bool shouldBeActive)
{
	if (shouldBeActive != bActive)
	{
		bActive = shouldBeActive;
		
		if (bActive)
		{
			if (ObjectiveOwner != none)
			{
				// once in a while check whether the players have not picked up an objective and prompt them again
				ObjectiveOwner.ResetCollectReminder();
			}

			OnKismetEvent(ECollectTriggerEvent_Activated);
		}
	}
}

//////////////////////////////////////////////////////////////////////////////////////////////////////
// KFInterface_UsableTriggerTarget

simulated function TriggerTarget(KFUsableTrigger Trigger, Pawn Triggerer)
{
	local KFCarryableObject_Collectible itemCreated;
	local KFInventoryManager KFIM;
	local Inventory existingCarryable;
	
	if (Role == ROLE_Authority)
	{
		KFIM = KFInventoryManager(Triggerer.InvManager);
		if (CarryableClass != none && KFIM != none)
		{
			// don't let the player carry more than one of the same carryable
			if (!KFIM.ClassIsInInventory(CarryableClass, existingCarryable))
			{
				ObjectiveOwner.OnCollectActor(self);

				itemCreated = KFCarryableObject_Collectible(Triggerer.CreateInventory(CarryableClass));
				if (itemCreated != none)
				{
					itemCreated.ParentCollectActor = self;
					itemCreated.UpdateReplicationInfo(true);
					SetCollectibleState(ECollectibleState_Carried);

					OnCollected();
					bCollected = true;
					bActive = false;
					bForceNetUpdate = true;

					// if the max triggered count is 0, waiting until a successful trigger before shutting off
					if (Trigger.MaxTriggeredCount == 0)
					{
						Trigger.bActive = false;
					}
				}
			}
		}
	}
}

// end KFInterface_UsableTriggerTarget
//////////////////////////////////////////////////////////////////////////////////////////////////////

simulated event ReplicatedEvent(name VarName)
{
	if (VarName == nameof(bCollected))
	{
		if (bCollected)
		{
			OnCollected();
		}
	}
	else if (VarName == nameof(bActive))
	{
		UpdateActivity();

		if (bActive)
		{
			OnKismetEvent(ECollectTriggerEvent_Activated);
		}
	}
	else if (VarName == nameof(CollectibleState))
	{
		CollectibleStateUpdated();
	}
	else
	{
		super.ReplicatedEvent(VarName);
	}
}

simulated event PostBeginPlay()
{
	Super.PostBeginPlay();
	
	// start hidden
	SetEnabled(bActive);
}

simulated function OnCollected()
{
	PlaySoundBase(CollectedSoundEvent, true);

	if (WorldInfo.NetMode != NM_DedicatedServer)
	{
		WorldInfo.MyEmitterPool.SpawnEmitter(CollectedParticleSystem, Location);
	}

	SetEnabled(false);
}

simulated function OnCarryableDropped()
{
	if (ObjectiveOwner != none)
	{
		ObjectiveOwner.OnCarryableDropped(self);
	}

	SetCollectibleState(ECollectibleState_Dropped);

	OnKismetEvent(ECollectTriggerEvent_ObjectDropped);
}

simulated function DestroyingChildCarryable()
{
	if (ObjectiveOwner != none)
	{
		SetCollectibleState(ECollectibleState_None);
		ObjectiveOwner.RespawnCollectible(self);
	}
}

simulated function OnKismetEvent(int EventType)
{
	local int i;
	local array<int> OutputLinksToActivate;
	local KFSeqEvent_CollectTrigger ProgressEvent;

	OutputLinksToActivate.AddItem(EventType);
	for (i = 0; i < GeneratedEvents.Length; i++)
	{
		ProgressEvent = KFSeqEvent_CollectTrigger(GeneratedEvents[i]);
		if (ProgressEvent != none)
		{
			ProgressEvent.Reset();
			ProgressEvent.CheckActivate(self, self, , OutputLinksToActivate);
		}
	}
}

simulated function CollectibleStateUpdated()
{
	switch (CollectibleState)
	{
	case ECollectibleState_Carried:
		if (ObjectiveOwner != none)
		{
			ObjectiveOwner.ClearCollectReminder();
		}
		OnKismetEvent(ECollectTriggerEvent_ObjectPickedUp);
		break;
	case ECollectibleState_Dropped:
		if (ObjectiveOwner != none)
		{
			ObjectiveOwner.ResetCollectReminder();
		}
		OnKismetEvent(ECollectTriggerEvent_ObjectDropped);
		break;
	case ECollectibleState_Delivered:
		OnKismetEvent(ECollectTriggerEvent_ObjectDelivered);
		break;
	}
}

simulated function SetCollectibleState(ECollectibleState ColState)
{
	CollectibleState = ColState;
	bForceNetUpdate = true;

	CollectibleStateUpdated();
}

defaultproperties
{
	Physics=PHYS_None
	bEdShouldSnap=true
	bStatic=true
	bNoDelete=true
	bTickIsDisabled=true

	RemoteRole=ROLE_SimulatedProxy
	bAlwaysRelevant=true
	bOnlyDirtyReplication=true
	bSkipActorPropertyReplication=true
	bIgnoreNetRelevancyCollision=true
	NetUpdateFrequency=0.1
	bReplicateRigidBodyLocation=true

	bCollideActors=true
	bBlockActors=true
	bWorldGeometry=true
	bCollideWorld=false
	bNoEncroachCheck=false
	bProjTarget=false
	bCanStepUpOn=false
	bMovable=false

	Begin Object Class=StaticMeshComponent Name=StaticMeshComponent0
		StaticMesh=StaticMesh'ENV_Collectible_MESH.Env_Dosh_Collectible'
		bAllowApproximateOcclusion=TRUE
		bForceDirectLightMap=TRUE
		bUsePrecomputedShadows=TRUE
		LightingChannels=(Indoor=TRUE,Outdoor=TRUE,bInitialized=TRUE)
		// Collision
		CollideActors=TRUE
		BlockActors=TRUE
		BlockRigidBody=TRUE
		RBChannel=RBCC_GameplayPhysics
		RBCollideWithChannels=(Default=TRUE,GameplayPhysics=TRUE,EffectPhysics=TRUE,DeadPawn=FALSE,Pickup=TRUE,FlexAsset=FALSE)
	End Object
	CollectActorMesh=StaticMeshComponent0
	Components.Add(StaticMeshComponent0)

	bCanBeDamaged=false
	bActive=false

	SupportedEvents.Add(class'KFSeqEvent_CollectTrigger')
}