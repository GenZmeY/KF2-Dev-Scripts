//=============================================================================
// KFDT_Fire_Mac10DoT
//=============================================================================
// Damage caused by burning from being hit by a mac10 round
//=============================================================================
// Killing Floor 2
// Copyright (C) 2018 Tripwire Interactive LLC
//  - Zane
//=============================================================================

class KFDT_Fire_Mac10DoT extends KFDT_Fire
	abstract
	hidedropdown;


defaultproperties
{
	WeaponDef = class'KFWeapDef_Mac10'

	DoT_Type = DOT_Fire
	DoT_Duration = 2.0 //5.0 //1.0 //2.7
	DoT_Interval = 0.5
	DoT_DamageScale = 0.4 //0.3 //1.0 //0.7

	BurnPower = 4 //8.5 //1.0 //18.5
}

