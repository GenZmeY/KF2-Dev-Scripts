//=============================================================================
// KFDT_Explosive_GravityImploder
//=============================================================================
// Explosive damage type for the Gravity Imploder explosion
//=============================================================================
// Killing Floor 2
// Copyright (C) 2020 Tripwire Interactive LLC
//=============================================================================

class KFDT_Explosive_GravityImploder extends KFDT_Explosive
	abstract
	hidedropdown;

defaultproperties
{
	bShouldSpawnPersistentBlood=true

	// physics impact
	//GibImpulseScale=0.9
	//KDeathUpKick=1000
	//KDeathVel=300
	//RadialDamageImpulse=-1000
	//KDamageImpulse=550
	RadialDamageImpulse=-200
	GibImpulseScale=0.85
	KDeathUpKick=-200
	KDeathVel=200
	StumblePower=200
	
	ModifierPerkList(0)=class'KFPerk_Demolitionist'
	
	WeaponDef=class'KFWeapDef_GravityImploder'
}
