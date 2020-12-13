//=============================================================================
// KFSeqAct_ShowPath
//=============================================================================
// Action that creates a trail path to any actor.
//=============================================================================
// Killing Floor 2
// Copyright (C) 2016 Tripwire Interactive LLC
//=============================================================================
class KFSeqAct_ShowPath extends SequenceAction;

enum eVolumeCheckType
{
	VCT_None,
	VCT_InVolume,
	VCT_NotInVolume
};

var transient bool bPathActive;
var transient KFReplicatedShowPathActor ReplicatedPathActor;

/**
 * Leave at VCT_None to always show the path to all human players.
 * If this is set to VCT_InVolume, it will only show the path to players inside the linked volume.
 * If this is set to VCT_NotInVolume, it will only show the path to players NOT in the linked volume.
 */
var() eVolumeCheckType VolumeCheckType;

/** Team number to display path to. 0 = Survivors, 255 = Zeds */
var() byte TeamToDisplayPathTo;

var() ParticleSystem TrailParticleSystem;

event Activated()
{
	local SeqVar_Object ObjVar;
	local Actor Target;
	local Volume Volume;

	// Check for a start/stop
	if( InputLinks[0].bHasImpulse )
	{
		bPathActive = true;
	}
	else if( InputLinks[1].bHasImpulse )
	{
		bPathActive = false;
		if( ReplicatedPathActor != none && !ReplicatedPathActor.bDeleteMe )
		{
			ReplicatedPathActor.Destroy();
		}
		ReplicatedPathActor = none;
	}

	if( bPathActive )
	{
		// Grab our destination actor
		foreach LinkedVariables( class'SeqVar_Object', ObjVar, "Destination Actor" )
		{
			Target = Actor( ObjVar.GetObjectValue() );
			break;
		}

		// Sanity check
		if( Target == none )
		{
			bPathActive = false;
			return;
		}

		// Grab our destination actor
		if( VolumeCheckType != VCT_None )
		{
			foreach LinkedVariables( class'SeqVar_Object', ObjVar, "Volume" )
			{
				Volume = Volume( ObjVar.GetObjectValue() );
				break;
			}
		}

		// Spawn our replicated actor and set its target
		ReplicatedPathActor = class'WorldInfo'.static.GetWorldInfo().Spawn( class'KFReplicatedShowPathActor', none );
		if( ReplicatedPathActor != none )
		{
			if (TrailParticleSystem != none)
			{
				ReplicatedPathActor.SetEmitterTemplate(TrailParticleSystem);
			}
			ReplicatedPathActor.SetPathTarget( Target, Volume, (VolumeCheckType != VCT_None && Volume == none) ? VCT_None : VolumeCheckType, TeamToDisplayPathTo );
		}
		else
		{
			bPathActive = false;
		}
	}
}

defaultproperties
{
	ObjCategory="Killing Floor"
	ObjName="Display Path To Actor"

	InputLinks(0)=(LinkDesc="Start")
	InputLinks(1)=(LinkDesc="Stop")
	VariableLinks.Empty()
	VariableLinks(0)=(ExpectedType=class'SeqVar_Object',LinkDesc="Destination Actor",MaxVars=1)
	VariableLinks(1)=(ExpectedType=class'SeqVar_Object',LinkDesc="Volume",MaxVars=1)

	VolumeCheckType=VCT_None
	TeamToDisplayPathTo=0
	bCallHandler=false
}