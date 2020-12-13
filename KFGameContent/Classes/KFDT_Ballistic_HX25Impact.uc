//=============================================================================
// KFDT_Ballistic_HX25Impact
//=============================================================================
// Shell impact damage type for the HX25 Grenade pistol
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
// John "Ramm-Jaeger" Gibson
//=============================================================================

class KFDT_Ballistic_HX25Impact extends KFDT_Ballistic_Shell
	abstract
	hidedropdown;

defaultproperties
{
	KDamageImpulse=1500
	KDeathUpKick=500
	KDeathVel=250
	
	KnockdownPower=12
	StumblePower=14
	LegStumblePower=14
	GunHitPower=39

	WeaponDef=class'KFWeapDef_HX25'

	ModifierPerkList(0)=class'KFPerk_Demolitionist'
}
