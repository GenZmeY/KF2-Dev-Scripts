//=============================================================================
// KFSM_PlayerGorefast_Block
//=============================================================================
// Player-controlled gorefast block move
//=============================================================================
// Killing Floor 2
// Copyright (C) 2016 Tripwire Interactive LLC
//=============================================================================
class KFSM_PlayerGorefast_Block extends KFSM_PlayerZedBlockBase;

defaultproperties
{
	AnimName=Block_Idle

	// ---------------------------------------------
	// Camera
	bUseCustomThirdPersonViewOffset=true
	CustomThirdPersonViewOffset={(
		OffsetHigh=(X=-175,Y=50,Z=25),
		OffsetLow=(X=-220,Y=50,Z=50),
		OffsetMid=(X=-140,Y=50,Z=-10),
		)}
	ViewOffsetInterpTime=0.3f
	CustomCameraFOV=64.f
	CameraFOVTransitionTime=0.3f		
}