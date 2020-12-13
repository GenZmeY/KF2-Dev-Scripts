//=============================================================================
// KFProj_Flame_HRGIncendiaryRifle
//=============================================================================
// Projectile class for the residual flames from the rifle's grenade.
// It behaves like the molotov residual flames.
//=============================================================================
// Killing Floor 2
// Copyright (C) 2019 Tripwire Interactive LLC
//	- Tulio Beloqui (Saber Interactive)
//=============================================================================

class KFProj_Flame_HRGIncendiaryRifle extends KFProj_MolotovSplash;

/** Overridden to adjust particle system for different surface orientations (wall, ceiling)
  * and nudge location
  */
simulated protected function PrepareExplosionActor(GameExplosionActor GEA)
{
	local KFExplosion_HRGIncendiaryRifleGroundFire KFEM;
	local vector ExplosionDir;

	super.PrepareExplosionActor( GEA );

	// KFProjectile::Explode gives GEA a "nudged" location of 32 units, but it's too much, so use a smaller nudge
	GEA.SetLocation( Location + vector(GEA.Rotation) * 10 );

	KFEM = KFExplosion_HRGIncendiaryRifleGroundFire( GEA );
	if( KFEM != none )
	{
		ExplosionDir = vector( KFEM.Rotation );

		if( ExplosionDir.Z < -0.95 )
		{
			// ceiling
			KFEM.LoopingParticleEffect = KFEM.default.LoopingParticleEffectCeiling;
		}
		else if( ExplosionDir.Z < 0.05 )
		{
			// wall
			KFEM.LoopingParticleEffect = KFEM.default.LoopingParticleEffectWall;
		}
		// else floor
	}
}

defaultproperties
{	
    Begin Object Name=ExploTemplate0
		Damage=4
		MomentumTransferScale=1
        MyDamageType=class'KFDT_Fire_Ground_HRGIncendiaryRifle'
    End Object

    ExplosionActorClass=class'KFExplosion_HRGIncendiaryRifleGroundFire'
}
	
