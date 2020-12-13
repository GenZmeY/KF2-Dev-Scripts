//=============================================================================
// KFDT_Toxic_MedicBatDoT
//=============================================================================
// Killing Floor 2
// Copyright (C) 2019 Tripwire Interactive LLC
//=============================================================================

// Toxic Weapon with added Bludgeon functionality
class KFDT_Toxic_MedicBatDoT extends KFDT_Toxic
	abstract
	hidedropdown;

defaultproperties
{
	//DoT
	DoT_Duration=5.0
	DoT_Interval=1.0
	DoT_DamageScale=0.2

	//Afflictions
	PoisonPower=5.f

	WeaponDef=class'KFWeapDef_MedicBat'

	ModifierPerkList(0)=class'KFPerk_FieldMedic'
	//ModifierPerkList(1)=class'KFPerk_Berserker'
}
