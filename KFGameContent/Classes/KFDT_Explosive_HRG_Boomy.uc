//=============================================================================
// KFDT_Explosive_GravityImploderWave
//=============================================================================
// Explosive damage type for the Gravity Imploder shockwave
//=============================================================================
// Killing Floor 2
// Copyright (C) 2020 Tripwire Interactive LLC
//=============================================================================

class KFDT_Explosive_HRG_Boomy extends KFDT_Explosive
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

	KnockdownPower=7
	StumblePower=20

	//Perk
	ModifierPerkList(0)=class'KFPerk_Demolitionist'	
	WeaponDef=class'KFWeapDef_HRG_Boomy'
}
