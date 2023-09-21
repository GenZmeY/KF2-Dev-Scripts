//=============================================================================
// KFDT_Ballistic_MedicRifleGrenadeLauncher
//=============================================================================
//
//=============================================================================
// Killing Floor 2
// Copyright (C) 2017 Tripwire Interactive LLC
//=============================================================================

class KFDT_Ballistic_MedicRifleGrenadeLauncher extends KFDT_Ballistic_AssaultRifle
	abstract
	hidedropdown;

defaultproperties
{
	KDamageImpulse=900
	KDeathUpKick=-300
	KDeathVel=100
	
	StumblePower=10
	GunHitPower=45

	WeaponDef=class'KFWeapDef_MedicRifleGrenadeLauncher'

	//Perk
	ModifierPerkList(0)=class'KFPerk_FieldMedic'
	ModifierPerkList(1)=class'KFPerk_Commando'
}
