//=============================================================================
// KFDT_Ballistic_M16M203
//=============================================================================
// Class Description
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//  - Author 10/30/2013
//=============================================================================

class KFDT_Ballistic_M16M203 extends KFDT_Ballistic_AssaultRifle
	abstract
	hidedropdown;

defaultproperties
{
    KDamageImpulse=900
	KDeathUpKick=-300
	KDeathVel=100
	
	StumblePower=10
	GunHitPower=0

	WeaponDef=class'KFWeapDef_M16M203'

	//Perk
	ModifierPerkList(0)=class'KFPerk_Demolitionist'
	ModifierPerkList(1)=class'KFPerk_Commando'
}
