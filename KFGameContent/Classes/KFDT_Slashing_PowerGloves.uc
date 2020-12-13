//=============================================================================
// KFDT_Slashing_PowerGloves
//=============================================================================
// Killing Floor 2
// Copyright (C) 2017 Tripwire Interactive LLC
//=============================================================================

class KFDT_Slashing_PowerGloves extends KFDT_Slashing
	abstract
	hidedropdown;

defaultproperties
{
	KDamageImpulse=2500 //1250
	KDeathUpKick=500
	KDeathVel=400 //250

	MeleeHitPower=200 //100
	StunPower=0
	StumblePower=150

	WeaponDef=class'KFWeapDef_PowerGloves'
	ModifierPerkList(0)=class'KFPerk_Berserker'
}
