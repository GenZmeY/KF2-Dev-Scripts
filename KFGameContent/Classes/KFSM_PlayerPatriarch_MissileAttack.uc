//=============================================================================
// KFSM_PlayerPatriarch_MissileAttack
//=============================================================================
// Player-controlled Patriarch's missile attack
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//=============================================================================
class KFSM_PlayerPatriarch_MissileAttack extends KFSM_Patriarch_MissileAttack;

defaultproperties
{
	Handle=KFSM_Patriarch_MissileAttack
	AnimName=Rocket_Shoot
	LoadAnimNames[0]=Rocket_TO_LoadP
	//WindDownAnimName=Rocket_TO_Idle	

	bUseCustomThirdPersonViewOffset=true
	CustomThirdPersonViewOffset={(
		OffsetHigh=(X=-140,Y=90,Z=45),
		OffsetLow=(X=-160,Y=130,Z=55),
		OffsetMid=(X=-125,Y=110,Z=45),
		)}
	ViewOffsetInterpTime=0.4f
	CustomCameraFOV=60.f
	CameraFOVTransitionTime=0.5f
}