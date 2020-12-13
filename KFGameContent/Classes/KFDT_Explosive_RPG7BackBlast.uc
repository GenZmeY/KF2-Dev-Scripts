//=============================================================================
// KFDT_Explosive_RPG7BackBlast
//=============================================================================
// Explosive back blast damage type for the RPG rocket launcher
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
// John "Ramm-Jaeger" Gibson
//=============================================================================

class KFDT_Explosive_RPG7BackBlast extends KFDT_Explosive
	abstract
	hidedropdown;

defaultproperties
{
	bShouldSpawnPersistentBlood=true

	// physics impact
	RadialDamageImpulse=3000
	KDeathUpKick=1000
	KDeathVel=300

	KnockdownPower=300
	StumblePower=500

	//Perk
	ModifierPerkList(0)=class'KFPerk_Demolitionist'

	WeaponDef=class'KFWeapDef_RPG7'
}
