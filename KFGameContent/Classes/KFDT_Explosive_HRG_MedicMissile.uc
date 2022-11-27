//=============================================================================
// KFDT_Explosive_HRG_MedicMissile
//=============================================================================
// Killing Floor 2
// Copyright (C) 2022 Tripwire Interactive LLC
//=============================================================================

class KFDT_Explosive_HRG_MedicMissile extends KFDT_Explosive
	abstract
	hidedropdown;

defaultproperties
{
	bShouldSpawnPersistentBlood=false

	RadialDamageImpulse=2500
	GibImpulseScale=0.15
	KDeathUpKick=1500
	KDeathVel=500

	KnockdownPower=50
	StumblePower=200

	bExtraMomentumZ=false

	bCanObliterate=false

	//Perk
	ModifierPerkList(0)=class'KFPerk_FieldMedic'

	WeaponDef=class'KFWeapDef_HRG_MedicMissile'
}
