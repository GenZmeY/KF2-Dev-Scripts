//=============================================================================
// KFSFXVolume
//=============================================================================
// A placeable volume that plays sounds at random location within it at random 
// intervals
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
// - Jeff Robinson
//=============================================================================

class KFSFXVolume extends Volume
	placeable
	dontsortcategories(ReverbVolume)
	hidecategories(Advanced, Attachment, Collision, Volume, Toggle, Mobile, Physics, Debug );

// Minimum amount of time to pass before playing next sfx event
var() float MinInterval<ClampMin=0>;
// Maximum amount of time to pass before playing next sfx event
var() float MaxInterval<ClampMin=0>;
// List of possible sfx events to play (chosen from randomly)
var() array<AkEvent> SFXEvents;

simulated event PostBeginPlay()
{
	if( SFXEvents.Length == 0 )
	{
		`log("*** "$self$" does not have any SFXEvents!");
		return;
	}

	if( MaxInterval < MinInterval )
	{
		MaxInterval = MinInterval;
	}

	// volumes are static and don't tick, so set timer on a local player controller
	if( WorldInfo.NetMode != NM_DedicatedServer )
	{
		WorldInfo.GetALocalPlayerController().SetTimer( GetRandomInterval(), false, nameof(PlaySFX), self );
	}
}

// Picks random position and event and plays event at position
simulated function PlaySFX()
{
	local int SFXIdx;
	local AkEvent SFXEvent;
	local vector SFXLocation, RandVect, BoxExtent;

	SFXIdx = Rand( SFXEvents.Length );
	SFXEvent = SFXEvents[ SFXIdx ];

	RandVect = VRand();
	BoxExtent = BrushComponent.Bounds.BoxExtent;
	SFXLocation = BrushComponent.Bounds.Origin;
	SFXLocation.X += RandVect.X * BoxExtent.X;
	SFXLocation.Y += RandVect.Y * BoxExtent.Y;
	SFXLocation.Z += RandVect.Z * BoxExtent.Z;
	PlayAkEvent( SFXEvent, true,,, SFXLocation );

	// volumes are static and don't tick, so set timer on GRI
	WorldInfo.GetALocalPlayerController().SetTimer( GetRandomInterval(), false, nameof(PlaySFX), self );
}

// Returns random interval between min and max
simulated function float GetRandomInterval()
{
	return MinInterval + Rand(MaxInterval-MinInterval);
}

defaultproperties
{
	Begin Object Name=BrushComponent0
		CollideActors=false
		bAcceptsLights=false
		BlockActors=false
		BlockZeroExtent=false
		BlockNonZeroExtent=false
		BlockRigidBody=false
		AlwaysLoadOnClient=true
		AlwaysLoadOnServer=false
		bDisableAllRigidBody=true
	End Object

	bCollideActors=False
}