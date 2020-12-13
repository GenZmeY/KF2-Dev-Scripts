//=============================================================================
// KFDT_Explosive_HEGrenade
//=============================================================================
// Explosive damage type for high explosive grenades
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
// John "Ramm-Jaeger" Gibson
//=============================================================================

class KFDT_Explosive_HEGrenade extends KFDT_Explosive
	abstract
	hidedropdown;

defaultproperties
{
	bShouldSpawnPersistentBlood=true

	// physics impact
	RadialDamageImpulse=2000//3000
	GibImpulseScale=0.15
	KDeathUpKick=1000
	KDeathVel=300

	KnockdownPower=0
	StumblePower=50
	MeleeHitPower=200

	ObliterationHealthThreshold=-80
	ObliterationDamageThreshold=160

	WeaponDef=class'KFWeapDef_Grenade_Commando'
}
