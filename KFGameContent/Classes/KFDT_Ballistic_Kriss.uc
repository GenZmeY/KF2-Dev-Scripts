//=============================================================================
// KFDT_Ballistic_Kriss
//=============================================================================
// Class Description
//=============================================================================
// Killing Floor 2
// Copyright (C) 2016 Tripwire Interactive LLC
//  - Brooks Butler
//=============================================================================

class KFDT_Ballistic_Kriss extends KFDT_Ballistic_Submachinegun
	abstract
	hidedropdown;

defaultproperties
{
	KDamageImpulse=900
	KDeathUpKick=-300
	KDeathVel=100

	StumblePower=15
	GunHitPower=15

	WeaponDef=class'KFWeapDef_Kriss'
	ModifierPerkList(0)=class'KFPerk_SWAT'
}
