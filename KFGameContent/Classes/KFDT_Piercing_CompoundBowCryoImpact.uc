//=============================================================================
// KFDT_Piercing_CompoundBowCryoImpact
//=============================================================================
// Damage class for the compound bow cryo arrows impact
//=============================================================================
// Killing Floor 2
// Copyright (C) 2019 Tripwire Interactive LLC
//	- Tulio Beloqui (Saber Interactive)
//=============================================================================

class KFDT_Piercing_CompoundBowCryoImpact extends KFDT_Piercing
	abstract
	hidedropdown;

defaultproperties
{
	KDamageImpulse=1500
	KDeathUpKick=250
	KDeathVel=150

	GunHitPower=100

	WeaponDef=class'KFWeapDef_CompoundBow'
	ModifierPerkList(0)=class'KFPerk_Sharpshooter'
}

