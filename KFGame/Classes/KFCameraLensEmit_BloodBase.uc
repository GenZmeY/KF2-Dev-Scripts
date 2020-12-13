//=============================================================================
// KFCameraLensEmit_BloodBase
//=============================================================================
// Generic blood spray emitter (Lens effect)
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//  - Sakib Saikia 10/31/2013
//=============================================================================

class KFCameraLensEmit_BloodBase extends KFEmit_CameraEffect;

defaultproperties
{
	PS_CameraEffect=ParticleSystem'FX_Camera_EMIT.FX_Camera_Blood'
	bAllowMultipleInstances=TRUE
	LifeSpan=1.5
	bDepthTestEnabled=false
}