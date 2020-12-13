//=============================================================================
// KFCameraLensEmit_Puke
//=============================================================================
// Class Description
//=============================================================================
// Killing Floor 2
// Copyright (C) 2016 Tripwire Interactive LLC
//=============================================================================
class KFCameraLensEmit_Puke extends KFEmit_CameraEffect;

defaultproperties
{
	PS_CameraEffect=ParticleSystem'FX_Camera_EMIT.FX_Puke_screen_01'
	bAllowMultipleInstances=false
	LifeSpan=10.f
	bDepthTestEnabled=false
}
