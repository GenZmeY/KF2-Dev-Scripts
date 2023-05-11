//=============================================================================
// KFDT_WeeklyContamination
//=============================================================================
// Killing Floor 2
// Copyright (C) 2022 Tripwire Interactive LLC
//=============================================================================
class KFDT_WeeklyContamination extends KFDT_Bleeding
	abstract
	hidedropdown;

var int Damage;

static function int GetDamage()
{
	return default.Damage;
}

defaultproperties
{
	// CameraLensEffectTemplate=class'KFCameraLensEmit_Puke'

	DoT_Type=DOT_Bleeding
	DoT_Duration=3.0
	DoT_Interval=0.5
	DoT_DamageScale=0.5

	BleedPower = 2
	PoisonPower = 0

	Damage=7
}