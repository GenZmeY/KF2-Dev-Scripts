//=============================================================================
// KFDT_Ballistic_Pistol_Medic
//=============================================================================
// Medic Pistol Damage Type
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
// John "Ramm-Jaeger" Gibson
//=============================================================================

class KFDT_Ballistic_Pistol_Medic extends KFDT_Ballistic_Handgun
	abstract
	hidedropdown;

defaultproperties
{
	KDamageImpulse=900
	KDeathUpKick=-300
	KDeathVel=100

	StumblePower=0
	GunHitPower=45

	WeaponDef=class'KFWeapDef_MedicPistol'

	//Perk
	ModifierPerkList(0)=class'KFPerk_FieldMedic'
}
