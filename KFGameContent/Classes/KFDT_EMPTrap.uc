//=============================================================================
// KFDT_EMPTrap
//=============================================================================
// Damage caused by EMP Traps
//=============================================================================
// Killing Floor 2
// Copyright (C) 2018 Tripwire Interactive LLC
// Zane Gholson
//=============================================================================

class KFDT_EMPTrap extends KFDamageType;

defaultproperties
{
    KDamageImpulse=150
    bArmorStops=false

	GoreDamageGroup=DGT_EMP
	
	CameraLensEffectTemplate=class'KFCameraLensEmit_EMP'

	EMPPower=100.0
	bIsTrapDamage=true
}
