//=============================================================================
// KFDT_Ballistic_M32Impact
//=============================================================================
// Shell impact damage type for the M32 Grenade launcher
//=============================================================================
// Killing Floor 2
// Copyright (C) 2017 Tripwire Interactive LLC
//=============================================================================

class KFDT_Ballistic_M32Impact extends KFDT_Ballistic_Shell
	abstract
	hidedropdown;

defaultproperties
{
	KDamageImpulse=2000
	KDeathUpKick=750
	KDeathVel=350

	KnockdownPower=125
	StumblePower=340
	GunHitPower=275

	WeaponDef=class'KFWeapDef_M32'

	ModifierPerkList(0)=class'KFPerk_Demolitionist'
}
