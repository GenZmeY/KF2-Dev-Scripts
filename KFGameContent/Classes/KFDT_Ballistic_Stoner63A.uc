//=============================================================================
// KFDT_Ballistic_Stoner63A
//=============================================================================
// Class Description
//=============================================================================
// Killing Floor 2
// Copyright (C) 2016 Tripwire Interactive LLC
//=============================================================================
class KFDT_Ballistic_Stoner63A extends KFDT_Ballistic_AssaultRifle
	abstract
	hidedropdown;

defaultproperties
{
    KDamageImpulse=900
	KDeathUpKick=-300
	KDeathVel=100
	
	StumblePower=10
	GunHitPower=50

	WeaponDef=class'KFWeapDef_Stoner63A'

	//Perk
	ModifierPerkList(0)=class'KFPerk_Commando'
}