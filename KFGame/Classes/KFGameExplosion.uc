//=============================================================================
// KFGameExplosion
//=============================================================================
// Explosion Template
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//  - Author 9/16/2013
//=============================================================================

class KFGameExplosion extends GameExplosion
	native;

/** When this projectile explodes, this is the shard to spawn, if any **/
var() class<Projectile> ShardClass;
/** If the projectile is going to explode with shards, this is number of shards to spawn **/
var() int NumShards;

/** Impact info (decal, vfx, etc.), so that each explosion type on various surfaces can have different effects if desired. Doesn't do anything with the sound */
var() KFImpactEffectInfo    ExplosionEffects;

/** Amount to heal humans on impact */
var() float HealingAmount;
/** The damage type for healing humans on impact */
var class<DamageType> HealingDamageType;

native function KFGameExplosion Duplicate();

defaultproperties
{
	Damage=200
	DamageRadius=500
	DamageFalloffExponent=1.f
	DamageDelay=0.f

	// Damage Effects
	MyDamageType=class'KFDT_Explosive'
	KnockDownStrength=100
	MomentumTransferScale=50000.0
	FractureMeshRadius=200.0
	FracturePartVel=500.0
	HealingAmount=0;

	// Camera Shake
	CamShake=CameraShake'FX_CameraShake_Arch.Misc_Explosions.Default_Misc'
	CamShakeInnerRadius=450
	CamShakeOuterRadius=900
	CamShakeFalloff=1.f
	bOrientCameraShakeTowardsEpicenter=true

	HealingDamageType=class'KFDT_Healing'
}
