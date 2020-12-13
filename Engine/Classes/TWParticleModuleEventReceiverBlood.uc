//=============================================================================
// TWParticleModuleEventReceiverBlood
//=============================================================================
// Event receiver to spawn persistent blood
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//  - Sakib Saikia 7/22/2014
//=============================================================================

class TWParticleModuleEventReceiverBlood extends ParticleModuleEventReceiverBase
	native(Particle)
	editinlinenew
	hidecategories(Object);

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
	bUpdateModule=true

	EventGeneratorType=EPET_Collision
	EventName=Blood
}
