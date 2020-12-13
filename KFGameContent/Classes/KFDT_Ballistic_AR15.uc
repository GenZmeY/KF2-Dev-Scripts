//=============================================================================
// KFDT_Ballistic_AR15
//=============================================================================
// Class Description
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//  - Author 10/30/2013
//=============================================================================

class KFDT_Ballistic_AR15 extends KFDT_Ballistic_AssaultRifle
	abstract
	hidedropdown;

defaultproperties
{
	KDamageImpulse=900
	KDeathUpKick=-300
	KDeathVel=100
	
	StumblePower=5
	GunHitPower=0

	WeaponDef=class'KFWeapDef_AR15'

	//Perk
	ModifierPerkList(0)=class'KFPerk_Commando'
}
