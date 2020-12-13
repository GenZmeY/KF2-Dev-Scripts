//=============================================================================
// KFCameraLensEmit_Puke
//=============================================================================
// Class Description
//=============================================================================
// Killing Floor 2
// Copyright (C) 2016 Tripwire Interactive LLC
//  - Christian "schneidzekk" Schneider
//=============================================================================
class KFCameraLensEmit_Puke_Light extends KFEmit_CameraEffect;

defaultproperties
{
	PS_CameraEffect=ParticleSystem'FX_Camera_EMIT.FX_Puke_screen_light_01'
	bAllowMultipleInstances=false
	LifeSpan=10.f
	bDepthTestEnabled=false
}
