//=============================================================================
// KFDT_Explosive_FleshpoundKingRage_Light
//=============================================================================
// Explosive damage type for Fleshpound King's light rage pound
//=============================================================================
// Killing Floor 2
// Copyright (C) 2017 Tripwire Interactive LLC
//  - Matt 'Squirrlz' Farber
//=============================================================================
class KFDT_Explosive_FleshpoundKingRage_Light extends KFDT_Explosive
	abstract
	hidedropdown;

defaultproperties
{
	bNoInstigatorDamage=true
	bShouldSpawnPersistentBlood=true

	// Physics impact
	RadialDamageImpulse=200
	KDeathUpKick=300
	KDeathVel=100

	//Afflictions
	KnockdownPower=0
	StumblePower=400
	MeleeHitPower=0
	GunHitPower=0
	StunPower=0

	ObliterationHealthThreshold=-7
	ObliterationDamageThreshold=15
}