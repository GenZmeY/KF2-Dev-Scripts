//=============================================================================
// KFDT_Piercing_MosinNagant
//=============================================================================
// Killing Floor 2
// Copyright (C) 2019 Tripwire Interactive LLC
//=============================================================================

class KFDT_Piercing_MosinNagant extends KFDT_Piercing
	abstract
	hidedropdown;

DefaultProperties
{
	// Physics
	KDamageImpulse=300
	KDeathUpKick=300
	
	// Afflictions
	MeleeHitPower=150

	//defaults
	WeaponDef=class'KFWeapDef_MosinNagant'

	ModifierPerkList(0)=class'KFPerk_Sharpshooter'
}