//=============================================================================
// KFDT_Ballistic_HRG_93R
//=============================================================================
// Base pistol damage type
//=============================================================================
// Killing Floor 2
// Copyright (C) 2023 Tripwire Interactive LLC
//=============================================================================

class KFDT_Ballistic_HRG_93R extends KFDT_Ballistic_Handgun
	abstract
	hidedropdown;

defaultproperties
{
	KDamageImpulse=900
	KDeathUpKick=-300
	KDeathVel=100

	KnockdownPower=12
	StumblePower=0
	GunHitPower=10

	WeaponDef=class'KFWeapDef_HRG_93R'
}
