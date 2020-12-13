//=============================================================================
// KFDT_Fire_IonThrusterDoT
//=============================================================================
// Damage caused by burning from being hit by a dragon's breath round
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//  - John "Ramm-Jaeger" Gibson
//=============================================================================

class KFDT_Fire_IonThrusterDoT extends KFDT_Fire
	abstract
	hidedropdown;

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
	WeaponDef=class'KFWeapDef_IonThruster'

	DoT_Type=DOT_Fire
	DoT_Duration=3.0
	DoT_Interval=0.5
	DoT_DamageScale=0.2
	BurnPower=15

	ModifierPerkList(0)=class'KFPerk_Berserker'
}

