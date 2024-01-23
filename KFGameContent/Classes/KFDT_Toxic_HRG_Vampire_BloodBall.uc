//=============================================================================
// KFDT_Toxic_HRG_Vampire_BloodBall
//=============================================================================
// Toxic Cloud DamageType
//=============================================================================
// Killing Floor 2
// Copyright (C) 2020 Tripwire Interactive LLC
//=============================================================================

class KFDT_Toxic_HRG_Vampire_BloodBall extends KFDT_Toxic
	abstract
	hidedropdown;

defaultproperties
{
	PoisonPower=16
	StumblePower=40 //200
	KnockdownPower=0 //40

	DoT_Type=DOT_Toxic
	DoT_Duration=2.0 //1.0
	DoT_Interval=0.5 //1.0
	DoT_DamageScale=0.1
	
	SelfDamageReductionValue=0.1f

	ModifierPerkList(0)=class'KFPerk_FieldMedic'
	WeaponDef=class'KFWeapDef_HRG_Vampire'
}
