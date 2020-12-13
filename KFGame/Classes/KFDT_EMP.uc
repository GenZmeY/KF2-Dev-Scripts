//=============================================================================
// KFDT_EMP
//=============================================================================
// Damage caused by EMP weapons
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
// John "Ramm-Jaeger" Gibson
//=============================================================================

class KFDT_EMP extends KFDamageType
	abstract;

`include(KFGameDialog.uci)

/** Returns ID of dialog event for killer to speak after killing a zed using this damage type */
static function int GetKillerDialogID()
{
	return `KILL_Electro;
}

/** Returns ID of dialog event for damager to speak after damaging a zed using this damage type */
static function int GetDamagerDialogID()
{
	return `DAMZ_Electro;
}

defaultproperties
{
    KDamageImpulse=150
    bArmorStops=false

	GoreDamageGroup=DGT_EMP
	
	CameraLensEffectTemplate=class'KFCameraLensEmit_EMP'

	EMPPower=100.0
}
