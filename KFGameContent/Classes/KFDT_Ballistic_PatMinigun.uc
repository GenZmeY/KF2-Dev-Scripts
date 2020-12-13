//=============================================================================
// KFDT_Ballistic_PatMinigun
//=============================================================================
// Patriarch Minigun ballistic damagetype
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//=============================================================================

class KFDT_Ballistic_PatMinigun extends KFDT_Ballistic_AssaultRifle
	abstract
	hidedropdown;

`include(KFGame/KFGameDialog.uci)

static function int GetKillerDialogID()
{
	return `PATTY_MinigunKill;
}

defaultproperties
{
	KDamageImpulse=500
	KDeathUpKick=50
	KDeathVel=75

    CameraLensEffectTemplate=class'KFCameraLensEmit_BloodBase'
}