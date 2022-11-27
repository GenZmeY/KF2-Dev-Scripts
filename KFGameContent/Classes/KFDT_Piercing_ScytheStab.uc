//=============================================================================
// KFDT_Piercing_ScytheStab
//=============================================================================
// Killing Floor 2
// Copyright (C) 2022 Tripwire Interactive LLC
//=============================================================================

class KFDT_Piercing_ScytheStab extends KFDT_Piercing
	abstract
	hidedropdown;

defaultproperties
{
	KDamageImpulse=200
	KDeathUpKick=250
	
	StumblePower=50
	MeleeHitPower=100

	WeaponDef=class'KFWeapDef_Scythe'

	ModifierPerkList(0)=class'KFPerk_Berserker'
}