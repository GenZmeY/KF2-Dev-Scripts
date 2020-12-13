//=============================================================================
// KFDT_Explosive_PlayerZedTakeover
//=============================================================================
// Ballistic damage with light impact energy, but stronger hit reactions
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//=============================================================================
class KFDT_Explosive_PlayerZedTakeover extends KFDT_Explosive
	abstract
	hidedropdown;

defaultproperties
{
	bShouldSpawnPersistentBlood=true

	// physics impact
	RadialDamageImpulse=3000
	KDeathUpKick=1000
	KDeathVel=0

	KnockdownPower=0
	StumblePower=0

	ObliterationHealthThreshold=0
	ObliterationDamageThreshold=1	
}