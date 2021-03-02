//=============================================================================
// KFDT_Ballistic_GravityImploderImpactAlt
//=============================================================================
// Killing Floor 2
// Copyright (C) 2020 Tripwire Interactive LLC
//=============================================================================

class KFDT_Ballistic_GravityImploderImpactAlt extends KFDT_Ballistic_Shell
	abstract
	hidedropdown;

defaultproperties
{
	KDamageImpulse=2000
	KDeathUpKick=750
	KDeathVel=1500
	StumblePower=250
	GunHitPower=150

	WeaponDef=class'KFWeapDef_GravityImploder'

	ModifierPerkList(0)=class'KFPerk_Demolitionist'
}
