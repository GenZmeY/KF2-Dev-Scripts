//=============================================================================
// KFProj_MicrowaveImpact
//=============================================================================
// Projectile class for ground impact from the microwave gun
// Really only here for decal effects for now
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
// - John "Ramm-Jaeger" Gibson
//=============================================================================

class KFProj_MicrowaveImpact extends KFProjectile;

/**
 * Set the initial velocity and cook time
 */
simulated function PostBeginPlay()
{
	Super.PostBeginPlay();

	TriggerExplosion(Location,vector(Rotation), None);
}

/*********************************************************************************************
* Collision
********************************************************************************************* */
simulated event Touch( Actor Other, PrimitiveComponent OtherComp, vector HitLocation, vector HitNormal )
{
	Super(Projectile).Touch(Other, OtherComp, HitLocation, HitNormal);
}

/**
 * Force the fire not to burn the instigator, since setti ng it in the default props is not working for some reason - Ramm
 */
simulated protected function PrepareExplosionTemplate()
{
	ExplosionTemplate.bIgnoreInstigator=true;
}

defaultproperties
{
	PostExplosionLifetime=1.5

	bStopAmbientSoundOnExplode=false
    bAutoStartAmbientSound=true
    bAmbientSoundZedTimeOnly=false

	ExplosionActorClass=class'KFExplosion_GroundFire'

	// explosion
	Begin Object Class=KFGameExplosion Name=ExploTemplate0
		Damage=0
		DamageRadius=0.0
		DamageFalloffExponent=1.f
		DamageDelay=0.f
		MyDamageType=class'KFDT_Microwave_Beam'
		// Don't burn the guy with the flamethrower
        bIgnoreInstigator=true

		// Damage Effects
		KnockDownStrength=0
		KnockDownRadius=0
		FractureMeshRadius=0
		FracturePartVel=0
	    ExplosionEffects=KFImpactEffectInfo'WEP_Microwave_Gun_ARCH.Beam_Impacts'
		ExplosionSound=none
		MomentumTransferScale=0
		bAllowPerMaterialFX=true

		// Camera Shake
		CamShake=none
	End Object
	ExplosionTemplate=ExploTemplate0
}
