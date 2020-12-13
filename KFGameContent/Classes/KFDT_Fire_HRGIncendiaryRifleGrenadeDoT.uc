//=============================================================================
// KFDT_Fire_HRGIncendiaryRifleGrenadeDoT
//=============================================================================
//=============================================================================
// Killing Floor 2
// Copyright (C) 2019 Tripwire Interactive LLC
//=============================================================================

class KFDT_Fire_HRGIncendiaryRifleGrenadeDoT extends KFDT_Fire
	abstract
	hidedropdown;

defaultproperties
{
	WeaponDef = class'KFWeapDef_HRGIncendiaryRifle'

	DoT_Type = DOT_Fire
	DoT_Duration = 3.0
	DoT_Interval = 0.5
	DoT_DamageScale = 0.25

	BurnPower = 8
}
