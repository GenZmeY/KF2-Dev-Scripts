//=============================================================================
// KFDT_Explosive_SealSqueal
//=============================================================================
// Explosive damage type for the Seal Squeal
//=============================================================================
// Killing Floor 2
// Copyright (C) 2019 Tripwire Interactive LLC
//=============================================================================

class KFDT_Explosive_SealSqueal extends KFDT_Explosive
	abstract
	hidedropdown;

defaultproperties
{
	bShouldSpawnPersistentBlood = true

	// physics impact
	RadialDamageImpulse = 2000
	GibImpulseScale = 0.15
	KDeathUpKick = 1000
	KDeathVel = 300

	KnockdownPower = 150
	StumblePower = 400

	SelfDamageReductionValue = 0.25f

	//Perk
	ModifierPerkList(0) = class'KFPerk_Demolitionist'

	WeaponDef = class'KFWeapDef_SealSqueal'
}
