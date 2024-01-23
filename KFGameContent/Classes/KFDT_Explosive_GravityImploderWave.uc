//=============================================================================
// KFDT_Explosive_GravityImploderWave
//=============================================================================
// Explosive damage type for the Gravity Imploder shockwave
//=============================================================================
// Killing Floor 2
// Copyright (C) 2020 Tripwire Interactive LLC
//=============================================================================

class KFDT_Explosive_GravityImploderWave extends KFDT_Explosive
	abstract
	hidedropdown;

defaultproperties
{
	bShouldSpawnPersistentBlood=true

	// physics impact
	RadialDamageImpulse=3000 //5000 //20000
	GibImpulseScale=0.15
	KDeathUpKick=1000
	KDeathVel=300

	KnockdownPower=400

	SelfDamageReductionValue=0.075f 
	//Perk
	ModifierPerkList(0)=class'KFPerk_Demolitionist'	
	WeaponDef=class'KFWeapDef_GravityImploder'
}
