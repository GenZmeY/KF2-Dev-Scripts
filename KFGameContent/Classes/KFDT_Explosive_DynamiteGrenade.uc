//=============================================================================
// KFDT_Explosive_DynamiteGrenade
//=============================================================================
// Ballistic damage with light impact energy, but stronger hit reactions
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
// by Jeff Robinson
//=============================================================================

class KFDT_Explosive_DynamiteGrenade extends KFDT_Explosive
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

	KnockdownPower=100 // knockdown any non-boss zed in one hit
	MeleeHitPower=100
	StumblePower=300
	StunPower=200 // stun any non-boss zed in one hit

	//Perk
	ModifierPerkList(0)=class'KFPerk_Demolitionist'
	
	WeaponDef=class'KFWeapDef_Grenade_Demo'
}
