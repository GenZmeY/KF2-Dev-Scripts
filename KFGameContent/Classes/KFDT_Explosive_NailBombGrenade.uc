//=============================================================================
// KFDT_Explosive_NailBombGrenade
//=============================================================================
// Ballistic damage with light impact energy, but stronger hit reactions
//=============================================================================
// Copyright (C) 2015 Tripwire Interactive LLC
// - Christian "schneidzekk" Schneider
//=============================================================================

class KFDT_Explosive_NailBombGrenade extends KFDT_Explosive
	abstract
	hidedropdown;

defaultproperties
{
	bShouldSpawnPersistentBlood=true

	// physics impact
	RadialDamageImpulse=3000
	KDeathUpKick=1000
	KDeathVel=300

    StunPower=200   //125
	MeleeHitPower=100
	StumblePower=500

	WeaponDef=class'KFWeapDef_Grenade_Gunslinger'
}