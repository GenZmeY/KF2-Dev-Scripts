//=============================================================================
// KFDT_Ballistic_MosinNagantSpecial
//=============================================================================
// Ballistic damage with light impact energy, but stronger hit reactions
// For use with the Mosin Nagant "bullet stab"
//=============================================================================
// Killing Floor 2
// Copyright (C) 2019 Tripwire Interactive LLC
//=============================================================================

class KFDT_Ballistic_MosinNagantSpecial extends KFDT_Ballistic_Rifle
	abstract
	hidedropdown;

defaultproperties
{
	// Physics
	KDamageImpulse=2500
	KDeathUpKick=450
	KDeathVel=300
	
	// Afflictions
	KnockdownPower=200
	StumblePower=150
	GunHitPower=150

	//defaults
	WeaponDef=class'KFWeapDef_MosinNagant'

	ModifierPerkList(0)=class'KFPerk_Sharpshooter'
}
