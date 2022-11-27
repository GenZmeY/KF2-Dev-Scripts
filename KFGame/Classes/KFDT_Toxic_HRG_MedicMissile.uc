//=============================================================================
// KFDT_Toxic_HRG_MedicMissile
//=============================================================================
// Killing Floor 2
// Copyright (C) 2022 Tripwire Interactive LLC
//=============================================================================
class KFDT_Toxic_HRG_MedicMissile extends KFDT_Toxic
	abstract
	hidedropdown;

defaultproperties
{
	DoT_Type=DOT_Toxic
	DoT_Duration=4.0
	DoT_Interval=1.0
	DoT_DamageScale=0.2

	PoisonPower=100
	
	ModifierPerkList(0)=class'KFPerk_FieldMedic'

	WeaponDef=class'KFWeapDef_HRG_MedicMissile'
}