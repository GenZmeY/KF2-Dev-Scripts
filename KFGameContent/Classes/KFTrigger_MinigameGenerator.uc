//=============================================================================
// KFTrigger_MinigameGenerator
//=============================================================================
// Trigger used to activate all minigames in a level
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
// - Dan Weiss
//=============================================================================

class KFTrigger_MinigameGenerator extends Trigger_PawnsOnly
    config(Game)
    implements(KFInterface_Usable);

/** Amount of time (in seconds) that the generator should remain running */
var() float ActiveTime;

/** Amount of time until the generator can be reactivated */
var() float ReactivationTime;

var bool bActiveGenerator;
var bool bCanBeActivated;

var array<KFTrigger_MinigameButton> LevelButtons;

/** Objective index for the event this is tied to */
var() int ObjectiveIndex;

/** Index of the event this is tied to */
var() int EventIndex;

/** Amount of time remaining until the generator shuts off */
var repnotify byte GeneratorTimeRemaining;
var float PreviousTimeRemaining;

/** Actor reference showing status indicator */
var() array<StaticMeshActor> GeneratorStatusIndicators;

/** Material slot to use for the status modification */
var() int GlowIndex;

struct GeneratorStatus
{
    var() float MinTimeRemaining;
    var() LinearColor StatusColor;
};

var() array<GeneratorStatus> StatusIndicator;
var int CurrentStatusIndex;

struct EmissiveActor
{
    var() Actor EmissiveActor;
    var float GeneratorOnValue;
    var float GeneratorOffValue;

    structdefaultproperties
    {
        GeneratorOnValue=0.f
        GeneratorOffValue=0.f
    }
};

struct EmissiveUpdateActorList
{
    var() float ActivationDelay;
    var() array<Actor> ActorList;
    var array<EmissiveActor> CachedActorList;
};

var() array<EmissiveUpdateActorList> MapEmissiveActorList;
var int CurrentEmissiveActorListIndex;

replication
{
    if (bNetDirty)
        GeneratorTimeRemaining;
}

simulated event ReplicatedEvent(name VarName)
{
    if (VarName == 'GeneratorTimeRemaining')
    {
        UpdateGeneratorStatus();
    }
    else
    {
        super.ReplicatedEvent(VarName);
    }
}

function Tick(float DeltaTime)
{
    super.Tick(DeltaTime);

    if (bActiveGenerator)
    {
        GeneratorTimeRemaining = FloatToByte(GetRemainingTimeForTimer('DeactivateMinigames') / ActiveTime);
        UpdateGeneratorStatus();
    }
}

simulated function UpdateGeneratorStatus()
{
    local float CurrentTimeRemaining;
    local LinearColor ParamColor;
    local bool bStatusChange;
    local int CurIndex;
    local int i;

    if (WorldInfo.NetMode != NM_DedicatedServer && StatusIndicator.Length > 0)
    {
        CurIndex = CurrentStatusIndex;
        CurrentTimeRemaining = ByteToFloat(GeneratorTimeRemaining);

        //Reset or first startup
        if (PreviousTimeRemaining < CurrentTimeRemaining)
        {
            CurrentStatusIndex = 0;
            if (CurrentTimeRemaining > 0)
            {
                EnableEmissiveActors();
            }            
        }

        //Update if we've gone past the time required for current color
        if (StatusIndicator[CurrentStatusIndex].MinTimeRemaining > CurrentTimeRemaining)
        {
            for (CurrentStatusIndex = 0; CurrentStatusIndex < StatusIndicator.Length; ++CurrentStatusIndex)
            {
                if (StatusIndicator[CurrentStatusIndex].MinTimeRemaining < CurrentTimeRemaining)
                {
                    break;
                }
            }
        }
        CurrentStatusIndex = Min(CurrentStatusIndex, StatusIndicator.Length - 1);

        //Check for change and update color if necessary
        bStatusChange = CurrentStatusIndex != CurIndex;
        if (bStatusChange && GeneratorStatusIndicators.Length > 0 )
        {
            ParamColor = StatusIndicator[CurrentStatusIndex].StatusColor;
            for (i = 0; i < GeneratorStatusIndicators.Length; ++i)
            {
                if (MaterialInstance(GeneratorStatusIndicators[i].StaticMeshComponent.GetMaterial(GlowIndex)) != none)
                {
                    MaterialInstance(GeneratorStatusIndicators[i].StaticMeshComponent.GetMaterial(GlowIndex)).SetVectorParameterValue('Scalar_Glow_color', ParamColor);
                }
            }            
        }

        PreviousTimeRemaining = CurrentTimeRemaining;

        if (CurrentTimeRemaining <= 0)
        {
            DisableEmissiveActors();
        }
    }
}

simulated function EnableEmissiveActors()
{
    CurrentEmissiveActorListIndex = 0;
    if (MapEmissiveActorList.Length > 0)
    {
        if (MapEmissiveActorList[0].ActivationDelay > 0.f)
        {
            SetTimer(MapEmissiveActorList[0].ActivationDelay, false, nameof(EnableNextEmissiveList));
        }
        else
        {
            EnableNextEmissiveList();
        }
    }
}

simulated function EnableNextEmissiveList()
{
    local EmissiveActor CurrentActor;
    local int i;
    local StaticMeshActor Smesh;
    local SkeletalMeshActor Skmesh;
    local MaterialInstance MatInst;

    if (MapEmissiveActorList[CurrentEmissiveActorListIndex].ActorList.Length > 0)
    {
        foreach MapEmissiveActorList[CurrentEmissiveActorListIndex].CachedActorList(CurrentActor)
        {
            Smesh = StaticMeshActor(CurrentActor.EmissiveActor);
            Skmesh = SkeletalMeshActor(CurrentActor.EmissiveActor);
            if (Smesh != none)
            {
                for (i = 0; i < Smesh.StaticMeshComponent.Materials.Length; ++i)
                {
                    MatInst = MaterialInstance(Smesh.StaticMeshComponent.GetMaterial(i));
                    if (MatInst != None)
                    {
                        MatInst.SetScalarParameterValue('Scalar_Emissive_Intensity', CurrentActor.GeneratorOnValue);
                    }
                }
            }
            else if (Skmesh != none)
            {
                for (i = 0; i < Skmesh.SkeletalMeshComponent.Materials.Length; ++i)
                {
                    MatInst = MaterialInstance(Skmesh.SkeletalMeshComponent.GetMaterial(i));
                    if (MatInst != None)
                    {
                        MatInst.SetScalarParameterValue('Scalar_Emissive_Intensity', CurrentActor.GeneratorOnValue);
                    }
                }
            }
        }
    }

    CurrentEmissiveActorListIndex++;
    if (CurrentEmissiveActorListIndex < MapEmissiveActorList.Length)
    {
        if (MapEmissiveActorList[CurrentEmissiveActorListIndex].ActivationDelay > 0.f)
        {
            SetTimer(MapEmissiveActorList[CurrentEmissiveActorListIndex].ActivationDelay - MapEmissiveActorList[CurrentEmissiveActorListIndex - 1].ActivationDelay, false, nameof(EnableNextEmissiveList));
        }
        else
        {
            EnableNextEmissiveList();
        }
    }
}

simulated function DisableEmissiveActors()
{
    local EmissiveUpdateActorList CurrentList;
    local EmissiveActor CurrentActor;
    local int i;
    local StaticMeshActor Smesh;
    local SkeletalMeshActor Skmesh;
    local MaterialInstance MatInst;

    foreach MapEmissiveActorList(CurrentList)
    {
        foreach CurrentList.CachedActorList(CurrentActor)
        {
            Smesh = StaticMeshActor(CurrentActor.EmissiveActor);
            Skmesh = SkeletalMeshActor(CurrentActor.EmissiveActor);
            if (Smesh != none)
            {
                for (i = 0; i < Smesh.StaticMeshComponent.Materials.Length; ++i)
                {
                    MatInst = MaterialInstance(Smesh.StaticMeshComponent.GetMaterial(i));
                    if (MatInst != None)
                    {
                        MatInst.SetScalarParameterValue('Scalar_Emissive_Intensity', CurrentActor.GeneratorOffValue);
                    }                    
                }
            }
            else if (Skmesh != none)
            {
                for (i = 0; i < Skmesh.SkeletalMeshComponent.Materials.Length; ++i)
                {
                    MatInst = MaterialInstance(Skmesh.SkeletalMeshComponent.GetMaterial(i));
                    if (MatInst != None)
                    {
                        MatInst.SetScalarParameterValue('Scalar_Emissive_Intensity', CurrentActor.GeneratorOffValue);
                    }
                }
            }
        }
    }
}

simulated function InitEmissiveActors()
{
    local EmissiveActor NewActor;
    local int i, j, k;
    local StaticMeshActor Smesh;
    local SkeletalMeshActor Skmesh;
    local float CurValue;

    for (i = 0; i < MapEmissiveActorList.Length; ++i)
    {
        for (j = 0; j < MapEmissiveActorList[i].ActorList.Length; ++j)
        {
            Smesh = StaticMeshActor(MapEmissiveActorList[i].ActorList[j]);
            Skmesh = SkeletalMeshActor(MapEmissiveActorList[i].ActorList[j]);
            NewActor.EmissiveActor = MapEmissiveActorList[i].ActorList[j];
            k = 0;
            if (Smesh != none)
            {
                while (Smesh.StaticMeshComponent.GetMaterial(k) != none)
                {
                    Smesh.StaticMeshComponent.CreateAndSetMaterialInstanceConstant(k);
                    MaterialInstance(Smesh.StaticMeshComponent.GetMaterial(k)).Parent.GetScalarParameterValue('Scalar_Emissive_Intensity', CurValue);
                    ++k;
                    NewActor.GeneratorOnValue = Max(CurValue, NewActor.GeneratorOnValue);
                }
            }
            else if (Skmesh != none)
            {
                while (Skmesh.SkeletalMeshComponent.GetMaterial(k) != none)
                {
                    Skmesh.SkeletalMeshComponent.CreateAndSetMaterialInstanceConstant(k);
                    MaterialInstance(Skmesh.SkeletalMeshComponent.GetMaterial(k)).Parent.GetScalarParameterValue('Scalar_Emissive_Intensity', NewActor.GeneratorOnValue);
                    ++k;
                    NewActor.GeneratorOnValue = Max(CurValue, NewActor.GeneratorOnValue);
                }
            }
            MapEmissiveActorList[i].CachedActorList.AddItem(NewActor);
        }
    }
}

/** KFInterface_Usable */
simulated function bool GetIsUsable(Pawn User)
{
    return true;
}

/** KFInterface_Usable */
simulated function int GetInteractionIndex(Pawn User)
{
    return IMT_UseMinigameGenerator;
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

/** Cache all minigame triggers at startup so we don't have to do all actors every activation */
simulated function PostBeginPlay()
{
    local KFTrigger_MinigameButton MinigameTrigger;
    local int i;

    super.PostBeginPlay();

    if (Role == ROLE_Authority)
    {
        foreach WorldInfo.AllActors(class'KFTrigger_MinigameButton', MinigameTrigger)
        {
            LevelButtons.AddItem(MinigameTrigger);
        }
    }

    if (WorldInfo.NetMode != NM_DedicatedServer)
    {
        if (GeneratorStatusIndicators.Length > 0 && GlowIndex >= 0)
        {
            for (i = 0; i < GeneratorStatusIndicators.Length; ++i)
            {
                if (GlowIndex < GeneratorStatusIndicators[i].StaticMeshComponent.Materials.Length)
                {
                    GeneratorStatusIndicators[i].StaticMeshComponent.CreateAndSetMaterialInstanceConstant(GlowIndex);
                }
            }
        }        
        
        InitEmissiveActors();
        UpdateGeneratorStatus();
    }
}

/** Handles trigger interaction */
function bool UsedBy(Pawn User)
{
    if (bCanBeActivated)
    {
        //Clear any timer that was already started, treat this as a full reactivation of minigames
        ClearTimer('DeactivateMinigames');
        SetTimer(ActiveTime, false, 'DeactivateMinigames');

        //Set reactivation timer to prevent button spam
        bCanBeActivated = false;
        SetTimer(ReactivationTime, false, 'AllowActivation');

        ActivateMinigames();

        //Activate objective completion for turning on generator
        TriggerObjectiveCompletion();
    }    

    return true;
}

function TriggerObjectiveCompletion()
{
    local KFPlayercontroller KFPC;
	local bool bIsObjectiveDataValid;

	bIsObjectiveDataValid = ObjectiveIndex >= 0 && ObjectiveIndex < 5 && EventIndex > SEI_None && EventIndex < SEI_MAX;

    foreach WorldInfo.AllControllers(class'KFPlayerController', KFPC)
    {
		KFPC.ClientOnTriggerUsed(class'KFTrigger_MinigameGenerator');
		if(bIsObjectiveDataValid)
		{
			KFPC.ClientOnTryCompleteObjective(ObjectiveIndex, EventIndex);
		}
    }
}

function AllowActivation()
{
    local int i;

    bCanBeActivated = true;

    for (i = 0; i < Touching.Length; ++i)
    {
        class'KFPlayerController'.static.UpdateInteractionMessages(Touching[i]);
    }
}

/** Handle activation of the generator and minigames in the level */
function ActivateMinigames()
{
    local KFTrigger_MinigameButton MinigameButton;

    //Don't activate if we're simply updating the timer
    if (!bActiveGenerator)
    {
        foreach LevelButtons(MinigameButton)
        {
            MinigameButton.SetMinigameActive();
        }

        bActiveGenerator = true;
        UpdateGeneratorState();
    }
    else
    {
        GeneratorReactivated();
    }
}

/** Handle deactivation of the generator and minigames in the level */
function DeactivateMinigames()
{
    local KFTrigger_MinigameButton MinigameButton;

    //Don't deactivate if we're already inactive
    if (bActiveGenerator)
    {
        foreach LevelButtons(MinigameButton)
        {
            MinigameButton.SetMinigameInactive();
        }

        bActiveGenerator = false;
        UpdateGeneratorState();
        GeneratorTimeRemaining = 0;
        UpdateGeneratorStatus();
    }
}

function GeneratorReactivated()
{
    local KFSeqEvent_MinigameGeneratorStateChanged StateChangeEvent;
    local int i;

    //Notify Kismet that minigame state has been changed
    for (i = 0; i < GeneratedEvents.Length; i++)
    {
        StateChangeEvent = KFSeqEvent_MinigameGeneratorStateChanged(GeneratedEvents[i]);
        if (StateChangeEvent != none)
        {
            StateChangeEvent.StateChanged(self, self, bActiveGenerator, true);
        }
    }
}

function UpdateGeneratorState()
{
    local KFSeqEvent_MinigameGeneratorStateChanged StateChangeEvent;
    local int i;

    //Notify Kismet that minigame state has been changed
    for (i = 0; i < GeneratedEvents.Length; i++)
    {
        StateChangeEvent = KFSeqEvent_MinigameGeneratorStateChanged(GeneratedEvents[i]);
        if (StateChangeEvent != none)
        {
            StateChangeEvent.StateChanged(self, self, bActiveGenerator, false);
        }
    }
}

defaultproperties
{
    SupportedEvents.Empty
    SupportedEvents.Add(class'KFSeqEvent_MinigameGeneratorStateChanged')

    RemoteRole=ROLE_SimulatedProxy
    NetPriority=+00002.500000
    bAlwaysRelevant=true

    ActiveTime=300.0f
    ReactivationTime=10.0f
    bCanBeActivated=true
    CurrentStatusIndex=-1
    GlowIndex=1
    PreviousTimeRemaining=-1.f
    CurrentEmissiveActorListIndex=-1

    EventIndex=-1
    ObjectiveIndex=-1
}