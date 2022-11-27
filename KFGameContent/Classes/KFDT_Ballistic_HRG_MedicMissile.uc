//=============================================================================
// KFDT_Ballistic_HRG_MedicMissile
//=============================================================================
// Killing Floor 2
// Copyright (C) 2022 Tripwire Interactive LLC
//=============================================================================

class KFDT_Ballistic_HRG_MedicMissile extends KFDT_Ballistic_Shell
	abstract
	hidedropdown;

defaultproperties
{
	KDamageImpulse=3000
	KDeathUpKick=1000
	KDeathVel=500

	StumblePower=10
	GunHitPower=45

	ModifierPerkList(0)=class'KFPerk_FieldMedic'

	WeaponDef=class'KFWeapDef_HRG_MedicMissile'
}
