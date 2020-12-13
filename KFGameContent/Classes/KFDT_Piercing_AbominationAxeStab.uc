//=============================================================================
// KFDT_Piercing_AbominationAxeStab 
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//=============================================================================

class KFDT_Piercing_AbominationAxeStab extends KFDT_Piercing
	abstract
	hidedropdown;

defaultproperties
{
	KDamageImpulse = 200
	KDeathUpKick = 250

	KnockdownPower = 0
	StunPower = 0
	StumblePower = 50
	MeleeHitPower = 100

	WeaponDef = class'KFWeapDef_AbominationAxe'
	ModifierPerkList(0) = class'KFPerk_Berserker'
}
