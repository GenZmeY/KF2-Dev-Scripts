//=============================================================================
// KFDT_Bludgeon_G18Shield
//=============================================================================
//
//=============================================================================
// Killing Floor 2
// Copyright (C) 2019 Tripwire Interactive LLC
//=============================================================================

class KFDT_Bludgeon_G18Shield_Impulse extends KFDT_Bludgeon
	abstract;

defaultproperties
{
	//Bash Attack
	KDamageImpulse=1500
	KDeathUpKick=600
	KDeathVel=450

	//Afflictions
	StumblePower=350
	MeleeHitPower=100

	WeaponDef=class'KFWeapDef_G18'
	ModifierPerkList(0)=class'KFPerk_Swat'
}