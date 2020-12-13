//=============================================================================
// KFDT_Ballistic_Minigun
//=============================================================================
// Container class for the Minigun damage types
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//=============================================================================

class KFDT_Ballistic_Minigun extends KFDT_Ballistic_AssaultRifle
	abstract
	hidedropdown;

defaultproperties
{
	GoreDamageGroup=DGT_AssaultRifle

	StumblePower=10
	LegStumblePower=20
	GunHitPower=10

	WeaponDef=class'KFWeapDef_Minigun'
	
	//Perk
	ModifierPerkList(0)=class'KFPerk_Commando'
}

