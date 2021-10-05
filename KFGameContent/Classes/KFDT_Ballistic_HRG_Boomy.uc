//=============================================================================
// KFDT_Ballistic_HRG_Boomy
//=============================================================================
//
//=============================================================================
// Killing Floor 2
// Copyright (C) 2021 Tripwire Interactive LLC
//=============================================================================

class KFDT_Ballistic_HRG_Boomy extends KFDT_Ballistic_Submachinegun
	abstract
	hidedropdown;

defaultproperties
{
    KDamageImpulse=900
	KDeathUpKick=-300
	KDeathVel=100

	StumblePower=35
	GunHitPower=25

	WeaponDef=class'KFWeapDef_HRG_Boomy'

	//Perk
	ModifierPerkList(0)=class'KFPerk_Demolitionist'
}
