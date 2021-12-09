//=============================================================================
// KFDT_Bludgeon_G18Shield
//=============================================================================
//
//=============================================================================
// Killing Floor 2
// Copyright (C) 2019 Tripwire Interactive LLC
//=============================================================================

class KFDT_Bludgeon_G18Shield extends KFDT_Bludgeon
	abstract;

defaultproperties
{
	//Bash Attack
	KDamageImpulse=2000
	KDeathUpKick=750
	KDeathVel=500

	//Afflictions
	MeleeHitPower=100

	WeaponDef=class'KFWeapDef_G18'
	ModifierPerkList(1)=class'KFPerk_Swat'
}