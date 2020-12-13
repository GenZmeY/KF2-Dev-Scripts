//=============================================================================
// KFEmitter
//=============================================================================
// Custom placeable emitter class
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
// - Andrew "Strago" Ladenberger
//=============================================================================
class KFEmitter extends Emitter
	placeable;

/** If set, will toggle the emitter clientside instead of replicating */
var() bool bClientsideKismetToggle;

/**
 * Handling Toggle event from Kismet.
 */
simulated function OnToggle(SeqAct_Toggle action)
{
	if ( !bClientsideKismetToggle )
	{
		Super.OnToggle(Action);
		return;
	}

	// Turn ON
	if (action.InputLinks[0].bHasImpulse)
	{
		ParticleSystemComponent.ActivateSystem();
		bCurrentlyActive = TRUE;
	}
	// Turn OFF
	else if (action.InputLinks[1].bHasImpulse)
	{
		ParticleSystemComponent.DeactivateSystem();
		bCurrentlyActive = FALSE;
	}
	// Toggle
	else if (action.InputLinks[2].bHasImpulse)
	{
		// If spawning is suppressed or we aren't turned on at all, activate.
		if (ParticleSystemComponent.bSuppressSpawning || !bCurrentlyActive)
		{
			ParticleSystemComponent.ActivateSystem();
			bCurrentlyActive = TRUE;
		}
		else
		{
			ParticleSystemComponent.DeactivateSystem();
			bCurrentlyActive = FALSE;
		}
	}
}

defaultproperties
{
}
