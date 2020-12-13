//=============================================================================
// KFDT_Ice_CompoundBowCryExplosion
//=============================================================================
// Damage type for the cryo arrow explosion of the Compound Bow.
//=============================================================================
// Killing Floor 2
// Copyright (C) 2019 Tripwire Interactive LLC
//	- Tulio Beloqui (Saber Interactive)
//=============================================================================

class KFDT_Freeze_CompoundBowCryExplosion extends KFDT_Freeze;

defaultproperties
{
	KDamageImpulse=1500
	KDeathUpKick=250
	KDeathVel=150

	FreezePower=100

	WeaponDef=class'KFWeapDef_CompoundBow'
	ModifierPerkList(0)=class'KFPerk_Sharpshooter'
}

