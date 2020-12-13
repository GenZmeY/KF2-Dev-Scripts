//=============================================================================
// KFDT_Fire_CaulkBurn
//=============================================================================
// Damage caused by heat and combustion
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//=============================================================================

class KFDT_Fire_CaulkBurn extends KFDT_Fire
	abstract;

static function int GetKillerDialogID()
{
	return 86;//KILL_Fire
}

static function int GetDamagerDialogID()
{
	return 102;//DAMZ_Fire
}

static function int GetDamageeDialogID()
{
	return 116;//DAMP_Fire
}

defaultproperties
{
	WeaponDef=class'KFWeapDef_CaulkBurn'

	DoT_Type=DOT_Fire
	DoT_Duration=1.7 //5.0
	DoT_Interval=0.4 //1.0
	DoT_DamageScale=0.8 //1.5
	bIgnoreSelfInflictedScale=true

	BurnPower=10.5 //2.5
	StumblePower=20
}

