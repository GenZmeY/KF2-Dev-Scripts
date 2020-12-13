//=============================================================================
// KFDT_Explosive_FlashBangGrenade
//=============================================================================
// Explosive damage type for high explosive grenades
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
// Chris "schneidzekk" Schneider
//=============================================================================

class KFDT_Explosive_FlashBangGrenade extends KFDT_Explosive
	abstract
	hidedropdown;

defaultproperties
{
	bNoInstigatorDamage=true
	bShouldSpawnPersistentBlood=true
	ScreenMaterialName=Effect_Flashbang

	// physics impact
	RadialDamageImpulse=3000
	KDeathUpKick=1000
	KDeathVel=300

	//Afflictions
	KnockdownPower=0
	StumblePower=200
	MeleeHitPower=0
	GunHitPower=0
	StunPower=400

	ObliterationHealthThreshold=-80
	ObliterationDamageThreshold=160

	WeaponDef=class'KFWeapDef_Grenade_Swat'
	ModifierPerkList(0)=class'KFPerk_SWAT'
}