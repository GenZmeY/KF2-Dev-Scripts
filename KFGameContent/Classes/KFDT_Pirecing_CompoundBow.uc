//=============================================================================
// KFDT_Piercing_CompoundBow
//=============================================================================
// Damage type for the compound bow melee knife attack
//=============================================================================
// Killing Floor 2
// Copyright (C) 2019 Tripwire Interactive LLC
//	- Tulio Beloqui (Saber Interactive)
//=============================================================================

class KFDT_Pirecing_CompoundBow extends KFDT_Piercing
	abstract
	hidedropdown;

DefaultProperties
{
	StumblePower=200
	MeleeHitPower=100

	WeaponDef=class'KFWeapDef_CompoundBow'
}
