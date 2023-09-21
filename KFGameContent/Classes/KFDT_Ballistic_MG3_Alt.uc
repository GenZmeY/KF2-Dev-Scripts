//=============================================================================
// KFDT_Ballistic_MG3_Alt
//=============================================================================
// Class Description
//=============================================================================
// Killing Floor 2
// Copyright (C) 2023 Tripwire Interactive LLC
//=============================================================================
class KFDT_Ballistic_MG3_Alt extends KFDT_Ballistic_AssaultRifle
	abstract
	hidedropdown;

defaultproperties
{
    KDamageImpulse=900
	KDeathUpKick=-300
	KDeathVel=100
	
	StumblePower=10
	GunHitPower=50

	WeaponDef=class'KFWeapDef_MG3'

	//Perk
	ModifierPerkList(0)=class'KFPerk_Commando'
}