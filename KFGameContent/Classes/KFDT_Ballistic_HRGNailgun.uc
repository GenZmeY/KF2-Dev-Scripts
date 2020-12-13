//=============================================================================
// KFDT_Ballistic_HRGNailgun
//=============================================================================
// Ballistic damage for nails fired from the HRG Nailgun
//=============================================================================
// Killing Floor 2
// Copyright (C) 2019 Tripwire Interactive LLC
//=============================================================================

class KFDT_Ballistic_HRGNailgun extends KFDT_Piercing
	abstract
	hidedropdown;

/**
 * Returns the class of the projectile to spawn if the weapon using this damage
 * type can pin a zed when it kills it
 */
static simulated function class<KFProj_PinningBullet> GetPinProjectileClass()
{
    return class'KFProj_Nail_Nailgun';
}

defaultproperties
{
	BloodSpread=0.4
	BloodScale=0.6

	KDamageImpulse=600
	KDeathUpKick=200
	KDeathVel=150

	StumblePower=20
	GunHitPower=20

	WeaponDef=class'KFWeapDef_Nailgun_HRG'

	ModifierPerkList(0)=class'KFPerk_SWAT'
}
