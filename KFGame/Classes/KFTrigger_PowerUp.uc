//=============================================================================
// KFTrigger_PowerUp
//=============================================================================
// Trigger used to activate a power up
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//=============================================================================

class KFTrigger_PowerUp extends Trigger_PawnsOnly
    config(Game)
    implements(KFInterface_Usable);
	
/** True when the powerup is activated */
var repnotify bool bPowerUpActivated;

/** True when the trigger is reactivated */
var repnotify bool bTriggerReactivated;

/** Can the trigger be activated to gain a power up */
var bool bCanBeActivated;

/** Use on all clients to spawn particles when the status changes */
var bool bCurrentActiveStatus;

/** Amount of time until the trigger can be reactivated */
var() float ReactivationTime;

/** Objective index for the event this is tied to */
var() int ObjectiveIndex;

/** Index of the event this is tied to */
var() int EventIndex;

/** Actor reference showing status */
var() InterpActor MeshActor;

/** Material index to change in the static mesh */
var() int MaterialIndex;

/** Material color parameter to change in the static mesh */
var() name MaterialParameterName;

/** Initial color for the actor reference */
var() LinearColor InitialColor;

/** Actvated color for the actor reference */
var() LinearColor ActivatedColor;

/** Delay for changing the material in the reactivation */
var() float ReactivationMaterialChangeDelay;

/** Sound to play upon activation */
var() AkEvent ActivationPowerUpSoundEvent;

/** Sound to play upon reactivation */
var() AkEvent ReactivationSoundEvent;

/** Particle effect to play upon activation */
var() ParticleSystem ActivationEffectTemplate;

/** Particle effect to play upon reactivation */
var() ParticleSystem ReactivationEffectTemplate;

/** Particle effect of the trigger that will be activated during the idle state */
var() Emitter IdleActiveParticleEffect;

/** Particle effect of the trigger that will be activated during the inactive state */
var() Emitter IdleInactiveParticleEffect;

enum EPowerUp_Type
{
	EPowerUp_HellishRage,
};

var() EPowerUp_Type PowerUpOnActivation;

var() bool GivePowerUpToAllPlayers;

replication
{
    if (bNetDirty)
        bPowerUpActivated;

	if(!bNetInitial && bNetDirty)
		bTriggerReactivated;
}

simulated event ReplicatedEvent(name VarName)
{
    if (VarName == 'bPowerUpActivated')
    {
        UpdateStatus();
    }
    else if (VarName == 'bTriggerReactivated')
    {
        ReactivateTrigger();
    }
    else
    {
        super.ReplicatedEvent(VarName);
    }
}

simulated function PostBeginPlay()
{
    super.PostBeginPlay();

    if (WorldInfo.NetMode != NM_DedicatedServer)
    {
		if (MaterialIndex < MeshActor.StaticMeshComponent.Materials.Length)
		{
		    MeshActor.StaticMeshComponent.CreateAndSetMaterialInstanceConstant(MaterialIndex);
		}  

		if( IdleInactiveParticleEffect != None )
		{
			IdleInactiveParticleEffect.ParticleSystemComponent.SetActive(false);
		}
        
        UpdateStatus();
    }
}

simulated function UpdateStatus()
{
    local LinearColor ParamColor;

    if ( WorldInfo.NetMode == NM_DedicatedServer )
    {
		return;
	}

	ParamColor = bPowerUpActivated ? ActivatedColor : InitialColor;

	if(ReactivationMaterialChangeDelay > 0 && ParamColor == InitialColor)
	{
		SetTimer(ReactivationMaterialChangeDelay, false, nameof(ApplyInitialMaterial));
	}
	else if (MaterialInstance(MeshActor.StaticMeshComponent.GetMaterial(MaterialIndex)) != none)
	{
		MaterialInstance(MeshActor.StaticMeshComponent.GetMaterial(MaterialIndex)).SetVectorParameterValue(MaterialParameterName, ParamColor);
	}

	if( bCurrentActiveStatus != bPowerUpActivated )
	{
		bCurrentActiveStatus = bPowerUpActivated;
		if( bCurrentActiveStatus && ActivationEffectTemplate != None )
		{
			WorldInfo.MyEmitterPool.SpawnEmitter(ActivationEffectTemplate, Location);
		}
		else if ( !bCurrentActiveStatus && ReactivationEffectTemplate != None )
		{
			WorldInfo.MyEmitterPool.SpawnEmitter(ReactivationEffectTemplate, Location);
		}

		if( IdleActiveParticleEffect != None )
		{
			IdleActiveParticleEffect.ParticleSystemComponent.SetActive(!bCurrentActiveStatus);
		}

		if( IdleInactiveParticleEffect != None )
		{
			IdleInactiveParticleEffect.ParticleSystemComponent.SetActive(bCurrentActiveStatus);
		}
	}
}

simulated function ApplyInitialMaterial()
{
	MaterialInstance(MeshActor.StaticMeshComponent.GetMaterial(MaterialIndex)).SetVectorParameterValue(MaterialParameterName, InitialColor);
}

/** KFInterface_Usable */
simulated function bool GetIsUsable(Pawn User)
{
    return bCanBeActivated && !KFGameReplicationInfo(KFGameInfo(WorldInfo.Game).GameReplicationInfo).bTraderIsOpen;
}

/** KFInterface_Usable */
simulated function int GetInteractionIndex(Pawn User)
{
    return IMT_UsePowerUp;
}

/** HUD */
event Touch(Actor Other, PrimitiveComponent OtherComp, vector HitLocation, vector HitNormal)
{
    super.Touch(Other, OtherComp, HitLocation, HitNormal);
    class'KFPlayerController'.static.UpdateInteractionMessages(Other);
}

/** HUD */
event UnTouch(Actor Other)
{
    super.UnTouch(Other);
    class'KFPlayerController'.static.UpdateInteractionMessages(Other);
}

/** Handles trigger interaction */
function bool UsedBy(Pawn User)
{
    if (bCanBeActivated)
    {
        //Set reactivation timer to prevent button spam
        bCanBeActivated = false;
		bPowerUpActivated = true;

		UpdateStatus();
        ActivatePowerUp(User);
        SetTimer(ReactivationTime, false, 'ReactivateTrigger');

		if(ActivationPowerUpSoundEvent != none)
		{
			PlaySoundBase(ActivationPowerUpSoundEvent, false, WorldInfo.NetMode == NM_DedicatedServer);
		}

        //Activate objective completion for turning on generator
        TriggerObjectiveCompletion();
    }    

    return true;
}

/** Handles trigger reactivation */
function ReactivateTrigger()
{
	bPowerUpActivated = false;
    bCanBeActivated = true;
	UpdateStatus();
	
	bTriggerReactivated = true;
	bForceNetUpdate = true;
	
    //Notify Kismet that the power up has been reactivated
    NotifyTriggerReactivated();

	if(ReactivationSoundEvent != none && WorldInfo.NetMode != NM_Client)
	{
		PlaySoundBase(ReactivationSoundEvent, false, WorldInfo.NetMode == NM_DedicatedServer);
	}
}

function TriggerObjectiveCompletion()
{
    local KFPlayercontroller KFPC;
	local bool bIsObjectiveDataValid;

	bIsObjectiveDataValid = ObjectiveIndex >= 0 && ObjectiveIndex < 5 && EventIndex > SEI_None && EventIndex < SEI_MAX;

    foreach WorldInfo.AllControllers(class'KFPlayerController', KFPC)
    {
		KFPC.ClientOnTriggerUsed(class'KFTrigger_PowerUp');
		if(bIsObjectiveDataValid)
		{
			KFPC.ClientOnTryCompleteObjective(ObjectiveIndex, EventIndex);
		}
    }
}

/** Handle activation of the power up */
function ActivatePowerUp(Pawn user)
{
	local KFPlayerController KFPC;

    //Notify Kismet that the power up has been activated
    NotifyPowerUpActivated();
	
	if(!GivePowerUpToAllPlayers)
	{
		if( user != none )
		{
			KFPC = KFPlayerController(user.Controller);
			if( KFPC != none )
			{
				switch( PowerUpOnActivation )
				{
					case EPowerUp_HellishRage:
					KFPC.ReceiveLocalizedMessage( class'KFLocalMessage_Game', GMT_PowerUpHellishRageActivated );
					KFPC.ReceivePowerUp(class'KFPowerUp_HellishRage');
					break;
				}

			}
		}
	}
	else
	{
		foreach WorldInfo.AllControllers(class'KFPlayerController', KFPC)
		{
			switch( PowerUpOnActivation )
			{
				case EPowerUp_HellishRage:
				KFPC.ReceiveLocalizedMessage( class'KFLocalMessage_Game', GMT_PowerUpHellishRageActivated );
				KFPC.ReceivePowerUp(class'KFPowerUp_HellishRage');
				break;
			}
		}
	}
}

function NotifyPowerUpActivated()
{
    local KFSeqEvent_PowerUpActivated PowerUpEvent;
    local int i;

    //Notify Kismet that the power up has been activated
    for (i = 0; i < GeneratedEvents.Length; i++)
    {
        PowerUpEvent = KFSeqEvent_PowerUpActivated(GeneratedEvents[i]);
        if (PowerUpEvent != none)
        {
            PowerUpEvent.ActivatePowerUp(self, self);
        }
    }
}

function NotifyTriggerReactivated()
{
    local KFSeqEvent_PowerUpActivated PowerUpEvent;
    local int i;

    //Notify Kismet that the power up has been activated
    for (i = 0; i < GeneratedEvents.Length; i++)
    {
        PowerUpEvent = KFSeqEvent_PowerUpActivated(GeneratedEvents[i]);
        if (PowerUpEvent != none)
        {
            PowerUpEvent.ReactivateTrigger(self, self);
        }
    }
}

defaultproperties
{
    SupportedEvents.Empty
    SupportedEvents.Add(class'KFSeqEvent_PowerUpActivated')

    RemoteRole=ROLE_SimulatedProxy
    NetPriority=+00002.500000
    bAlwaysRelevant=true

    bCanBeActivated=true
    ReactivationTime=20.0f

	ReactivationMaterialChangeDelay=0.7f

    EventIndex=-1
    ObjectiveIndex=-1
}