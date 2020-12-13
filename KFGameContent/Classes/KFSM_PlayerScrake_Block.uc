//=============================================================================
// KFSM_PlayerScrake_Block
//=============================================================================
// Player-controlled scrake block move
//=============================================================================
// Killing Floor 2
// Copyright (C) 2016 Tripwire Interactive LLC
//=============================================================================
class KFSM_PlayerScrake_Block extends KFSM_PlayerZedBlockBase;

defaultproperties
{
	AnimName=Block_Idle

	// ---------------------------------------------
	// Camera
	bUseCustomThirdPersonViewOffset=true
	CustomThirdPersonViewOffset={(
		OffsetHigh=(X=-175,Y=60,Z=60),
		OffsetLow=(X=-220,Y=100,Z=50),
		OffsetMid=(X=-160,Y=50,Z=0),
		)}
	ViewOffsetInterpTime=0.3f
	CustomCameraFOV=64.f
	CameraFOVTransitionTime=0.3f		
}