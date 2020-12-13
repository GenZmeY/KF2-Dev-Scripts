//=============================================================================
// KFDT_Piercing_CompoundBowSharpImpact
//=============================================================================
// Damage type for the Compound Bow Sharp Arrows
//=============================================================================
// Killing Floor 2
// Copyright (C) 2019 Tripwire Interactive LLC
//	- Tulio Beloqui (Saber Interactive)
//=============================================================================

class KFDT_Piercing_CompoundBowSharpImpact extends KFDT_Piercing
	abstract
	hidedropdown;

defaultproperties
{
	KDamageImpulse=1500
	KDeathUpKick=250
	KDeathVel=150

	StunPower=101
	StumblePower=250
	GunHitPower=100

	ModifierPerkList(0)=class'KFPerk_Sharpshooter'
	WeaponDef=class'KFWeapDef_CompoundBow'
}
