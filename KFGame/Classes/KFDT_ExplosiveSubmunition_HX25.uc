//=============================================================================
// KFDT_ExplosiveSubmunition_HX25
//=============================================================================
// Explosive damage type for the HX25 Grenade launcher grenade submunitions
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
// John "Ramm-Jaeger" Gibson
//=============================================================================

class KFDT_ExplosiveSubmunition_HX25 extends KFDT_Explosive
	abstract
	hidedropdown;

defaultproperties
{
	bShouldSpawnPersistentBlood=true

	// physics impact
	RadialDamageImpulse=2500  //2000
	KDeathUpKick=350   //350
	KDeathVel=250    //250

	KnockdownPower=5
	StumblePower=10

	//Perk
	ModifierPerkList(0)=class'KFPerk_Demolitionist'

	WeaponDef=class'KFWeapDef_HX25'
}
