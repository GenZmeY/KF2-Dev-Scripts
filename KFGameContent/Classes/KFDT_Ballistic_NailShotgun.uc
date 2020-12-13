//=============================================================================
// KFDT_Ballistic_NailShotgun
//=============================================================================
// Ballistic damage for nails fired from the Nail Shotgun
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//=============================================================================

class KFDT_Ballistic_NailShotgun extends KFDT_Ballistic_Shotgun
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

	KDamageImpulse=400
	KDeathUpKick=120
	KDeathVel=15

    KnockdownPower=0
	StunPower=0
	StumblePower=24
	GunHitPower=0

	WeaponDef=class'KFWeapDef_NailGun'

	ModifierPerkList(0)=class'KFPerk_Berserker'
	ModifierPerkList(1)=class'KFPerk_Support'
}
