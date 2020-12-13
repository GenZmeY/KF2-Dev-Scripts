//=============================================================================
// KFDT_Toxic_AcidicRounds
//=============================================================================
// The medic's Acidic Round damage type
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//=============================================================================

class KFDT_Toxic_AcidicRounds extends KFDT_Toxic
	abstract;

`include(KFGameDialog.uci)

static function bool AlwaysPoisons()
{
	return true;
}

defaultproperties
{
	KDamageImpulse=0

	DoT_Type=DOT_Toxic
	DoT_Duration=5.0
	DoT_Interval=1.0 //1.0
	DoT_DamageScale=2.0 //0.1 0.15

	PoisonPower=200 //33
}
