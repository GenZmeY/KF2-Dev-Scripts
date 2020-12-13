//=============================================================================
// KFEmit_CameraEffect
//=============================================================================
// Base class for emitters which should be attached to the camera 
// e.g. blood effects across the screen
//=============================================================================
// Killing Floor 2
// Copyright (C) 2016 Tripwire Interactive LLC
// - Matt "Squirrlz" Farber
//=============================================================================
class KFEmit_CameraEffect extends EmitterCameraLensEffectBase
	abstract;

defaultproperties
{
	// Camera lens effects are updated after FOV is changed, so it's safe to run this code during our async work
	TickGroup=TG_DuringAsyncWork
}