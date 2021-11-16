//=============================================================================
// KFDT_Bludgeon_Doshinegun_Shot
//=============================================================================
// Bills hit hard
//=============================================================================
// Killing Floor 2
// Copyright (C) 2021 Tripwire Interactive LLC
//=============================================================================

class KFDT_Bludgeon_Doshinegun_Shot extends KFDT_Bludgeon
	abstract
	hidedropdown;

defaultproperties
{
    KDamageImpulse=900
	KDeathUpKick=-300
	KDeathVel=100
	
	StumblePower=120
	StunPower=40
	GunHitPower=150

	WeaponDef=class'KFWeapDef_Doshinegun'
}
