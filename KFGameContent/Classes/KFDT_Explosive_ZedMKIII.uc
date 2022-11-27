//=============================================================================
// KFDT_Explosive_ZedMKIII
//=============================================================================
//=============================================================================
// Killing Floor 2
// Copyright (C) 2022 Tripwire Interactive LLC
//=============================================================================
class KFDT_Explosive_ZedMKIII extends KFDT_Explosive
	abstract
	hidedropdown;

defaultproperties
{
	bShouldSpawnPersistentBlood=true

	// physics impact
	RadialDamageImpulse=10000
	KDeathUpKick=2000
	KDeathVel=500

	KnockdownPower=150
	StumblePower=350

	//Perk
	ModifierPerkList(0)=class'KFPerk_Demolitionist'

	ObliterationHealthThreshold=-500
	ObliterationDamageThreshold=500
	WeaponDef=class'KFWeapDef_ZedMKIII'
}
