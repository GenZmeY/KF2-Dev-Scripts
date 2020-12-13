//=============================================================================
// KFDT_Bludgeon_FireAxeBash
//=============================================================================
// Killing Floor 2
// Copyright (C) 2017 Tripwire Interactive LLC
//=============================================================================

class KFDT_Bludgeon_FireAxeBash extends KFDT_Bludgeon
	abstract
	hidedropdown;

defaultproperties
{
	KDamageImpulse=1600
	KDeathUpKick=0
	KDeathVel=500

	StumblePower=150
	MeleeHitPower=100

	WeaponDef=class'KFWeapDef_FireAxe'

	ModifierPerkList(0)=class'KFPerk_Berserker'
}
