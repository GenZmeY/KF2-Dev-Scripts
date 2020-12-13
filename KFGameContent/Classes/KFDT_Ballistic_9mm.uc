//=============================================================================
// KFDT_Ballistic_9mm
//=============================================================================
// Base pistol damage type
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
// John "Ramm-Jaeger" Gibson
//=============================================================================

class KFDT_Ballistic_9mm extends KFDT_Ballistic_Handgun
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

	WeaponDef=class'KFWeapDef_9mm'
}
