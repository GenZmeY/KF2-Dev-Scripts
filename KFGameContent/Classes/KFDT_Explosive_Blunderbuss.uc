//=============================================================================
// KFDT_Explosive_Blunderbuss
//=============================================================================
// Explosive damage type for the Blunderbuss Cannonball explosion
//=============================================================================
// Killing Floor 2
// Copyright (C) 2020 Tripwire Interactive LLC
//	- Tulio Beloqui (Saber Interactive)
//=============================================================================

class KFDT_Explosive_Blunderbuss extends KFDT_Explosive
	abstract
	hidedropdown;

defaultproperties
{
	bShouldSpawnPersistentBlood=true

	// physics impact
	RadialDamageImpulse=2000
	GibImpulseScale=0.15
	KDeathUpKick=1000
	KDeathVel=300

	KnockdownPower=150
	StumblePower=400

	//Perk
	ModifierPerkList(0)=class'KFPerk_Demolitionist'
	
	WeaponDef=class'KFWeapDef_Blunderbuss'
}
