//=============================================================================
// KFDT_Explosive_HRG_Kaboomstick
//=============================================================================
// Explosive damage type for the HRG Kaboomstick explosive pellets
//=============================================================================
// Killing Floor 2
// Copyright (C) 2019 Tripwire Interactive LLC
// Tulio Beloqui (Saber Interactive)
//=============================================================================

class KFDT_Explosive_HRG_Kaboomstick extends KFDT_Explosive
	abstract
	hidedropdown;

defaultproperties
{
	bShouldSpawnPersistentBlood=true

	// physics impact
	RadialDamageImpulse=500//1500
	GibImpulseScale=0.77
	KDeathUpKick=250//500
	KDeathVel=250

	KnockdownPower=5
	StumblePower=10
    //MeleeHitPower=100

	//Perk
	ModifierPerkList(0)=class'KFPerk_Demolitionist'
	
	WeaponDef=class'KFWeapDef_HRG_Kaboomstick'
}
 