//=============================================================================
// KFEmoteCameraMode
//=============================================================================
// Camera mode for third person emotes
//=============================================================================
// Killing Floor 2
// Copyright (C) 2016 Tripwire Interactive LLC
// - Christian "schneidzekk" Schneider
//=============================================================================

class KFEmoteCameraMode extends KFThirdPersonCameraMode
	config(Camera);

defaultproperties
{
	ViewOffset={(
		OffsetHigh=(X=-240,Y=56,Z=16),
		OffsetLow=(X=-240,Y=48,Z=16),
		OffsetMid=(X=-240,Y=48,Z=0),
		)}

	bDirectLook=false
	bLockedToViewTarget=true
	bFollowTarget=false
}