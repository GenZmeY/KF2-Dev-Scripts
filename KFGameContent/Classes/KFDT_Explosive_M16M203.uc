//=============================================================================
// KFDT_Explosive_M16M203
//=============================================================================
// Explosive damage type for the M16M203 Grenade launcher grenade
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
// -Brooks Butler
//=============================================================================

class KFDT_Explosive_M16M203 extends KFDT_Explosive
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

	KnockdownPower=150
	StumblePower=400


	//Perk
	ModifierPerkList(0)=class'KFPerk_Demolitionist'
	
	WeaponDef=class'KFWeapDef_M16M203'
}
