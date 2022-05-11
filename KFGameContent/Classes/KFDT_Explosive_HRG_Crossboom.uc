//=============================================================================
// KFDT_Explosive_HRG_Crossboom
//=============================================================================
// Explosive damage type for the HRG Crossboom
//=============================================================================
// Killing Floor 2
// Copyright (C) 2022 Tripwire Interactive LLC
//=============================================================================

class KFDT_Explosive_HRG_Crossboom extends KFDT_Explosive
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

	WeaponDef = class'KFWeapDef_HRG_Crossboom'
}
