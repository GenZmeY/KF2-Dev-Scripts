//=============================================================================
// KFDT_Ballistic_SMG_Medic
//=============================================================================
// Damage class for the medic SMG
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
// John "Ramm-Jaeger" Gibson
//=============================================================================

class KFDT_Ballistic_SMG_Medic extends KFDT_Ballistic_Submachinegun
	abstract
	hidedropdown;

defaultproperties
{
    KDamageImpulse=900
	KDeathUpKick=-300
	KDeathVel=100

	GunHitPower=45

	WeaponDef=class'KFWeapDef_MedicSMG'

    //Perk
    ModifierPerkList(0)=class'KFPerk_FieldMedic'
    ModifierPerkList(1)=class'KFPerk_Swat'
}
