//=============================================================================
// KFDT_Ballistic_HRG_Vampire_BloodBallHeavyImpact
//=============================================================================
//
//=============================================================================
// Killing Floor 2
// Copyright (C) 2019 Tripwire Interactive LLC
//=============================================================================

class KFDT_Ballistic_HRG_Vampire_BloodBallHeavyImpact extends KFDT_Ballistic_HRG_Vampire_BloodBallImpact
	abstract
	hidedropdown;

defaultproperties
{
	PoisonPower=30 //80
	StumblePower=350
	KnockdownPower=140
	GunHitPower=350

	ModifierPerkList(0)=class'KFPerk_FieldMedic'
	WeaponDef=class'KFWeapDef_HRG_Vampire'
}
