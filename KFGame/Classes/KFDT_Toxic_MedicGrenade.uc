//=============================================================================
// KFDT_Toxic_MedicGrenade
//=============================================================================
// Toxic Dart DamageType
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
// Greg Felber
//=============================================================================

class KFDT_Toxic_MedicGrenade extends KFDT_Toxic
	abstract
	hidedropdown;

defaultproperties
{
	ModifierPerkList(0)=class'KFPerk_FieldMedic'

	WeaponDef=class'KFWeapDef_Grenade_Medic'
}
