//=============================================================================
// KFDT_Piercing_KnifeStab
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//=============================================================================

class KFDT_Piercing_KnifeStab extends KFDT_Piercing
	abstract
	hidedropdown;

defaultproperties
{
	KDamageImpulse=200
	KDeathUpKick=250

	// Hit reactions	
	StumblePower=0
	StunPower=0
	MeleeHitPower=25

	WeaponDef=class'KFWeapDef_Knife_Base'
}
