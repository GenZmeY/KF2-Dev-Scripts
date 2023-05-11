//=============================================================================
// KFDT_Ballistic_HRG_Warthog
//=============================================================================
// Class Description
//=============================================================================
// Killing Floor 2
// Copyright (C) 2023 Tripwire Interactive LLC
//=============================================================================

class KFDT_Ballistic_HRG_Warthog extends KFDT_Ballistic_Shell
	abstract
	hidedropdown;

defaultproperties
{
	KDamageImpulse=2000
	KDeathUpKick=750
	KDeathVel=350

	KnockdownPower=125
	StumblePower=340
	GunHitPower=275

	WeaponDef=class'KFWeapDef_HRG_Warthog'

	//Perk
	ModifierPerkList(0)=class'KFPerk_Demolitionist'

	bCanZedTime=false
}
