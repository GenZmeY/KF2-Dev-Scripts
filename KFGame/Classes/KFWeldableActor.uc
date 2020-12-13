//=============================================================================
// KFWeldableActor
//=============================================================================
// Base class or any placeable actor that can be welded.
//=============================================================================
// Killing Floor 2
// Copyright (C) 2018 Tripwire Interactive LLC
//=============================================================================
class KFWeldableActor extends Actor
	abstract
	implements(Interface_NavigationHandle)
	native
	nativeReplication;

/** Basic template for Particle Systems that contain relative offsets. */
struct native FXTemplate
{
	/** Particle system template to spawn */
	var() ParticleSystem ParticleTemplate;
	/** Offset from base location that particle system should spawn from. */
	var() vector RelativeOffset;
	/** Offset from base rotation that particle system should spawn from. */
	var() rotator RelativeRotation;
};

/*********************************************************************************************
* @name Weld Health
********************************************************************************************* */

// WeldIntegrity, RepairProgress, and DemoWeld are now replicated through this KFWeldableComponent
var repnotify transient KFWeldableComponent WeldableComponent;

var MaterialInstanceConstant IntegrityMIC;

/** Whether or not to start welded */
var() bool bStartWelded;
/** Amount of damage a welded door can take */
var() int MaxWeldIntegrity;
/** Current integrity of a welded door */
var transient int WeldIntegrity;

/** The minimum weld scalar a door can have so a weld will always be visible */
var const float MinWeldScalar;

/** Last time door weld integrity increased */
var transient float LastWeldTime;
/** Last time door weld integrity decreased */
var transient float LastUnweldTime;

/** Pawn currently welding */
var transient KFPawn WelderPawn;

/** True if the door has health less than 0 and is off its hinges */
var repnotify transient bool bIsDestroyed;

/** Amount of "explosive" weld needed */
var int DemoWeldRequired;
/** Current amount of "explosive" weld */
var transient int DemoWeld;

/*********************************************************************************************
* @name	Repair
********************************************************************************************* */

/** Percent of repair complete from 0-255 */
var byte RepairProgress;

/** When set to TRUE, notifies clients that door needs to be repaired */
var repnotify transient bool bWasRepaired;

/** Particle effect spawned when a door has been fully repaired */
var() FXTemplate RepairFXTemplate;

/** Repair sound event */
var() AkEvent RepairSound;

/*********************************************************************************************
* @name	UI
********************************************************************************************* */

/** UI icon used for welder */
var protected Texture2D WelderIcon;

/** Offset from door location (bottom) to closer to eye level for UI, FX, sounds, etc */
var transient vector WeldUILocation;

/** Localized strings */
var localized string WeldIntegrityString;
var localized string RepairProgressString;

replication
{
	if ( bNetDirty )
		bIsDestroyed, bWasRepaired, WeldableComponent;
}

simulated event ReplicatedEvent(name VarName)
{
	if (VarName == nameof(bIsDestroyed))
	{
		if (bIsDestroyed)
		{
			PlayDestroyed();
		}
	}
	else if (VarName == nameOf(bWasRepaired))
	{
		if (bWasRepaired)
		{
			CompleteRepair();
		}
	}
	else if (VarName == nameof(WeldableComponent))
	{
		InitializeWeldableComponent();
	}
	else
	{
		super.ReplicatedEvent(VarName);
	}
}

cpptext
{
	INT* GetOptimizedRepList(BYTE* InDefault, FPropertyRetirement* Retire, INT* Ptr, UPackageMap* Map, UActorChannel* Channel);

	/** IMPLEMENT Interface_NavigationHandle */
	virtual UBOOL	CanCoverSlip(ACoverLink* Link, INT SlotIdx);
	virtual void SetupPathfindingParams( FNavMeshPathParams& out_ParamCache );
	virtual void InitForPathfinding() {}
	virtual INT ExtraEdgeCostToAddWhenActive(FNavMeshEdgeBase* Edge) { return 0; }
	virtual FVector GetEdgeZAdjust(FNavMeshEdgeBase* Edge);
}

simulated event PostBeginPlay()
{
	super.PostBeginPlay();

	WeldUILocation = Location + (vect(0, 0, 1) * 164.f);

	if (Role == ROLE_Authority)
	{
		WeldableComponent = Spawn(class'KFWeldableComponent', self);
		InitializeWeldableComponent();
	}
}

simulated function InitializeWeldableComponent();
function FastenWeld(int Amount, optional KFPawn Welder);

simulated function UpdateWeldIntegrity(int Amount)
{
	WeldIntegrity = Clamp(WeldIntegrity + Amount, 0, MaxWeldIntegrity);
	UpdateIntegrityMIC();
}

function Repair(float Amount, optional KFPawn Welder);
simulated function CompleteRepair();
simulated function UpdateIntegrityMIC();
simulated function PlayDestroyed();

function bool BeingWelded()
{
	return (LastWeldTime > LastUnweldTime) && (`TimeSince(LastWeldTime) < 0.75f);
}

function bool BeingUnwelded()
{
	return (LastUnweldTime > LastWeldTime) && (`TimeSince(LastUnweldTime) < 0.75f);
}

function bool CanExplosiveWeld()
{
	return false;
}

function AddExplosiveWeld(int Amount, KFPlayerController PC)
{
	DemoWeld = Min(DemoWeld + Amount, DemoWeldRequired);
}

event NotifyPathChanged();

defaultproperties
{

}
