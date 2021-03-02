//=============================================================================
// KFDT_Piercing_Crossbow
//=============================================================================
// Damage type for crossbow
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//=============================================================================

class KFDT_Piercing_Crossbow extends KFDT_Piercing
	abstract
	hidedropdown;

var float HeadStunPower;

defaultproperties
{
	KDamageImpulse=1500
	KDeathUpKick=250
	KDeathVel=150

    KnockdownPower=20
	HeadStunPower=1000 // Stun ensured when hit in the head
	StunPower=30       // Stun used otherwise
	StumblePower=250
	GunHitPower=100
	MeleeHitPower=40

	ModifierPerkList(0)=class'KFPerk_Sharpshooter'
	WeaponDef=class'KFWeapDef_Crossbow'
}
