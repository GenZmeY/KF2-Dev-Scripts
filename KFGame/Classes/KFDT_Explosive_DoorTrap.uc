//=============================================================================
// KFDT_Explosive_DoorTrap
//=============================================================================
// Ballistic damage with light impact energy, but stronger hit reactions
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
// by Jeff Robinson
//=============================================================================

class KFDT_Explosive_DoorTrap extends KFDT_Explosive
	abstract
	hidedropdown;

defaultproperties
{
	bShouldSpawnPersistentBlood=true

	// physics impact
	RadialDamageImpulse=3000
	KDeathUpKick=1000
	KDeathVel=300

	KnockdownPower=300 // 400 
	StumblePower=500
	StunPower=0 // stun any non-boss zed in one hit

	//Perk
	ModifierPerkList(0)=class'KFPerk_Demolitionist'
}