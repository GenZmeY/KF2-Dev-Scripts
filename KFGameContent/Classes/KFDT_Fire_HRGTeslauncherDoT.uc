//=============================================================================
// KFDT_Fire_HRGTeslauncherDoT
//=============================================================================
// Damage caused by burning from being hit by a microwave assault rifle round
//=============================================================================
// Killing Floor 2
// Copyright (C) 2018 Tripwire Interactive LLC
//=============================================================================

class KFDT_Fire_HRGTeslauncherDoT extends KFDT_Fire
	abstract
	hidedropdown;


defaultproperties
{
	WeaponDef = class'KFWeapDef_HRGTeslauncher'

	DoT_Type = DOT_Fire
	DoT_Duration = 2.0
	DoT_Interval = 0.5
	DoT_DamageScale = 0.3
	bIgnoreSelfInflictedScale = true

	BurnPower = 8.5

	ModifierPerkList(0)=class'KFPerk_Berserker'
}

