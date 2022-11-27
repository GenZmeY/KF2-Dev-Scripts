//=============================================================================
// KFDT_Ballistic_ZedMKIII_Rocket
//=============================================================================
//=============================================================================
// Killing Floor 2
// Copyright (C) 2022 Tripwire Interactive LLC
//=============================================================================
class KFDT_Ballistic_ZedMKIII_Rocket extends KFDT_Ballistic_Shell
	abstract
	hidedropdown;

defaultproperties
{
	KDamageImpulse=3000
	KDeathUpKick=1000
	KDeathVel=500

	KnockdownPower=50
	StumblePower=100
	GunHitPower=70

	ModifierPerkList(0)=class'KFPerk_Demolitionist'

	WeaponDef=class'KFWeapDef_ZedMKIII'
}
