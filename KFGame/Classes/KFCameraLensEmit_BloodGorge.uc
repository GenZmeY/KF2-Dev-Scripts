//=============================================================================
// KFCameraLensEmit_BloodGorge
//=============================================================================
// Generic blood spray emitter for BK Gorge (Lens effect)
//=============================================================================
// Killing Floor 2
// Copyright (C) 2017 Tripwire Interactive LLC
//=============================================================================

class KFCameraLensEmit_BloodGorge extends KFCameraLensEmit_BloodBase;

defaultproperties
{
	PS_CameraEffect=ParticleSystem'FX_Camera_EMIT.FX_Camera_Blood_Gorge'
	bAllowMultipleInstances=TRUE
	LifeSpan=1.5
	bDepthTestEnabled=false
}