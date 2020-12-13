//=============================================================================
// KFProj_FreezeThrower_GroundIce
//=============================================================================
// Projectile class for ground fire from flamethrowers, etc
//=============================================================================
// Killing Floor 2
// Copyright (C) 2016 Tripwire Interactive LLC
//=============================================================================
class KFProj_FreezeThrower_GroundIce extends KFProj_GroundIce;

defaultproperties
{
	bWarnAIWhenFired=true
	DamageInterval=0.25f

	// explosion
	Begin Object Name=ExploTemplate0
		Damage=7
		DamageRadius=180
		DamageFalloffExponent=1.f
		DamageDelay=0.f
		MyDamageType=class'KFDT_Freeze_Ground_FreezeThrower'
		// Don't freeze the guy with the freezethrower
        bIgnoreInstigator=true

		// Damage Effects
		KnockDownStrength=0
		KnockDownRadius=0
		FractureMeshRadius=0
		FracturePartVel=0
	    ExplosionEffects=KFImpactEffectInfo'WEP_CryoGun_ARCH.GroundCryo_Impacts'
		ExplosionSound=none
		MomentumTransferScale=0.1
		bAllowPerMaterialFX=true

		// Camera Shake
		CamShake=none
	End Object
	ExplosionTemplate=ExploTemplate0
}