//=============================================================================
// KFDT_Explosive_FleshpoundKingRage_Heavy
//=============================================================================
// Explosive damage type for Fleshpound King's light rage pound
//=============================================================================
// Killing Floor 2
// Copyright (C) 2017 Tripwire Interactive LLC
//  - Matt 'Squirrlz' Farber
//=============================================================================
class KFDT_Explosive_FleshpoundKingRage_Heavy extends KFDT_Explosive
	abstract
	hidedropdown;

defaultproperties
{
	bNoInstigatorDamage=true
	bShouldSpawnPersistentBlood=true

	// Physics impact
	RadialDamageImpulse=2500
	KDeathUpKick=1000
	KDeathVel=300

	// Afflictions
	KnockdownPower=400
	StumblePower=0
	MeleeHitPower=0
	GunHitPower=0
	StunPower=0

	ObliterationHealthThreshold=-10
	ObliterationDamageThreshold=15
}