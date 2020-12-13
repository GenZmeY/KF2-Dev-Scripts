//=============================================================================
// KFDT_Fire_FlareGunDoT
//=============================================================================
// Damage caused by burning from being hit by a dragon's breath round
//=============================================================================
// Killing Floor 2
// Copyright (C) 2017 Tripwire Interactive LLC
//  - John "Ramm-Jaeger" Gibson
//=============================================================================
class KFDT_Fire_FlareGunDoT extends KFDT_Fire
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
	WeaponDef=class'KFWeapDef_FlareGun'

	DoT_Type=DOT_Fire
	DoT_Duration=1.7 //5.0
	DoT_Interval=0.4 //1.0
	DoT_DamageScale=0.8 //1.5

	BurnPower=12 //15.5

    ModifierPerkList(0) = class'KFPerk_Firebug'
    ModifierPerkList(1) = class'KFPerk_Gunslinger'
    ModifierPerkList(2) = class'KFPerk_Sharpshooter'
}