//=============================================================================
// KFDT_Explosive_M32
//=============================================================================
// Explosive damage type for the M32 Grenade launcher grenade
//=============================================================================
// Killing Floor 2
// Copyright (C) 2017 Tripwire Interactive LLC
//=============================================================================

class KFDT_Explosive_M32 extends KFDT_Explosive
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

	//Perk
	ModifierPerkList(0) = class'KFPerk_Demolitionist'

	WeaponDef = class'KFWeapDef_M32'
}
