//=============================================================================
// KFDT_Ballistic_G18
//=============================================================================
//
//=============================================================================
// Killing Floor 2
// Copyright (C) 2019 Tripwire Interactive LLC
//=============================================================================

class KFDT_Ballistic_G18 extends KFDT_Ballistic_Handgun
	abstract
	hidedropdown;

defaultproperties
{
	KDamageImpulse=900
	KDeathUpKick=-300
	KDeathVel=100

	StumblePower=12
	GunHitPower=12

	WeaponDef=class'KFWeapDef_G18'
	ModifierPerkList(0)=class'KFPerk_SWAT'
}
