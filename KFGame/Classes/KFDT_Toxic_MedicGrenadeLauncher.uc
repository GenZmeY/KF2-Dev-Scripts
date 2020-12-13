//=============================================================================
// KFDT_Toxic_MedicGrenadeLauncher
//=============================================================================
// Medic GL gas dmg type
//=============================================================================
// Killing Floor 2
// Copyright (C) 2018 Tripwire Interactive LLC
// Jonathan B
//=============================================================================

class KFDT_Toxic_MedicGrenadeLauncher extends KFDT_Toxic_MedicGrenade
	abstract
	hidedropdown;

defaultproperties
{
	ModifierPerkList(0)=class'KFPerk_FieldMedic'

	WeaponDef=class'KFWeapDef_MedicRifleGrenadeLauncher'
}
