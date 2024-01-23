//=============================================================================
// KFDT_Ballistic_HRG_Locust
//=============================================================================
// HRG Locust bullet impact
//=============================================================================
// Killing Floor 2
// Copyright (C) 2022 Tripwire Interactive LLC
//=============================================================================
class KFDT_Toxic_HRG_Locust extends KFDT_Bleeding
	abstract
	hidedropdown;

// Damage dealt when zeds touch each other and spread the afflictions
var int SpreadOnTouchDamage;

static function int GetSpreadOnTouchDamage()
{
	return default.SpreadOnTouchDamage;
}

defaultproperties
{
	DoT_Type=DOT_Bleeding
	DoT_Duration=3.0
	DoT_Interval=0.5
	DoT_DamageScale=0.5

	BleedPower = 15
	PoisonPower = 20
	
	ModifierPerkList(0)=class'KFPerk_Survivalist'

	WeaponDef=class'KFWeapDef_HRG_Locust'

	SpreadOnTouchDamage=25
	
	SelfDamageReductionValue=0.f
}