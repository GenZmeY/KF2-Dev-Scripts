//=============================================================================
// KFDT_Ballistic_RPG7Impact
//=============================================================================
// Rocket impact damage type for the RPG-7 rocket launcher
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
// John "Ramm-Jaeger" Gibson
//=============================================================================

class KFDT_Ballistic_RPG7Impact extends KFDT_Ballistic_Shell
	abstract
	hidedropdown;

defaultproperties
{
	KDamageImpulse=3000
	KDeathUpKick=1000
	KDeathVel=500

	KnockdownPower=200
	StumblePower=340
	GunHitPower=275

	ModifierPerkList(0)=class'KFPerk_Demolitionist'

	WeaponDef=class'KFWeapDef_RPG7'
}
