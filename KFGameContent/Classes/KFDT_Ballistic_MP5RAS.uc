//=============================================================================
// KFDT_Ballistic_MP5RAS
//=============================================================================
// Class Description
//=============================================================================
// Killing Floor 2
// Copyright (C) 2016 Tripwire Interactive LLC
//  - Brooks Butler
//=============================================================================

class KFDT_Ballistic_MP5RAS extends KFDT_Ballistic_Submachinegun
	abstract
	hidedropdown;

defaultproperties
{
	KDamageImpulse=900
	KDeathUpKick=-300
	KDeathVel=100

	StumblePower=12
	GunHitPower=12

	WeaponDef=class'KFWeapDef_MP5RAS'
	ModifierPerkList(0)=class'KFPerk_SWAT'
}
