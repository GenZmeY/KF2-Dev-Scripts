//=============================================================================
// KFEmoteCamera
//=============================================================================
// Camera for third person emote viewing
//=============================================================================
// Killing Floor 2
// Copyright (C) 2016 Tripwire Interactive LLC
// - Christian "schneidzekk" Schneider
//=============================================================================

class KFEmoteCamera extends KFThirdPersonCamera
	config(Camera);

defaultproperties
{
	ThirdPersonCamDefaultClass=class'KFEmoteCameraMode'
}
