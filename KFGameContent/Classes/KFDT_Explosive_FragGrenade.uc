//=============================================================================
// KFDT_Explosive_FragGrenade
//=============================================================================
// Ballistic damage with light impact energy, but stronger hit reactions
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//=============================================================================

class KFDT_Explosive_FragGrenade extends KFDT_Explosive
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
	MeleeHitPower=100
	StumblePower=500


	WeaponDef=class'KFWeapDef_Grenade_Support'
}
