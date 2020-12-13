//=============================================================================
// TWParticleModuleEventReceiverSFX
//=============================================================================
// Event receiver to play sounds
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//  - Jeff Robinson
//=============================================================================

class TWParticleModuleEventReceiverSFX extends ParticleModuleEventReceiverBase
	native(Particle)
	editinlinenew
	hidecategories(Object);

var() AkEvent SFXEvent;

cpptext
{
	// UObject functionality

	// Event Receiver functionality
	/**
	 *	Process the event...
	 *
	 *	@param	Owner		The FParticleEmitterInstance this module is contained in.
	 *	@param	InEvent		The FParticleEventData that occurred.
	 *	@param	DeltaTime	The time slice of this frame.
	 *
	 *	@return	UBOOL		TRUE if the event was processed; FALSE if not.
	 */
	virtual UBOOL ProcessParticleEvent(FParticleEmitterInstance* Owner, FParticleEventData& InEvent, FLOAT DeltaTime);
}

defaultproperties
{
	bSpawnModule=true

	EventGeneratorType=EPET_Spawn
	EventName=SFX
}
