//=============================================================================
// KFDT_Ballistic_Colt1911
//=============================================================================
// Colt 1911 pistol damage type
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
// Jeff Robinson
//=============================================================================

class KFDT_Ballistic_Colt1911 extends KFDT_Ballistic_Handgun
	abstract
	hidedropdown;

defaultproperties
{
	KDamageImpulse=1500
	KDeathUpKick=-450
	KDeathVel=200

	KnockdownPower=15
	StumblePower=20
	GunHitPower=100

	WeaponDef=class'KFWeapDef_Colt1911'

	ModifierPerkList(0)=class'KFPerk_Gunslinger'
}
