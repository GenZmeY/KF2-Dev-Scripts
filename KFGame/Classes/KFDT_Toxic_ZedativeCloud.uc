//=============================================================================
// KFDT_Toxic_ZedativeCloud
//=============================================================================
// Toxic Cloud DamageType
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//=============================================================================

class KFDT_Toxic_ZedativeCloud extends KFDT_Toxic
	abstract
	hidedropdown;

defaultproperties
{
	ModifierPerkList(0)=class'KFPerk_FieldMedic'

	DoT_Type=DOT_Toxic
	DoT_Duration=1.0
	DoT_Interval=1.0
	DoT_DamageScale=0.1

	PoisonPower=60 //20.f
}
