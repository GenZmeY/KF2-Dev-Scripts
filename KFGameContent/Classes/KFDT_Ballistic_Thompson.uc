//=============================================================================
// KFDT_Ballistic_Thompson
//=============================================================================
//
//=============================================================================
// Killing Floor 2
// Copyright (C) 2017 Tripwire Interactive LLC
//=============================================================================

class KFDT_Ballistic_Thompson extends KFDT_Ballistic_Submachinegun
	abstract
	hidedropdown;

defaultproperties
{
    KDamageImpulse=900
	KDeathUpKick=-300
	KDeathVel=100

	StumblePower=24
	GunHitPower=24

	WeaponDef=class'KFWeapDef_Thompson'

	//Perk
	ModifierPerkList(0)=class'KFPerk_SWAT'
	ModifierPerkList(1)=class'KFPerk_Commando'
}
