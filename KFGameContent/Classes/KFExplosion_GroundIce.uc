//=============================================================================
// KFExplosion_GroundIce
//=============================================================================
// Explosion actor class for ground ice
//=============================================================================
// Killing Floor 2
// Copyright (C) 2016 Tripwire Interactive LLC
//=============================================================================
class KFExplosion_GroundIce extends KFExplosionActorLingering;

simulated function SpawnExplosionParticleSystem(ParticleSystem Template)
{
	// If the template is none, grab the default
    if( !ExplosionTemplate.bAllowPerMaterialFX && Template == none )
	{
	   Template = KFGameExplosion(ExplosionTemplate).ExplosionEffects.DefaultImpactEffect.ParticleTemplate;
	}

	// Use custom pool
    WorldInfo.GroundFireEmitterPool.SpawnEmitter(Template, Location, rotator(ExplosionTemplate.HitNormal), None);
}

DefaultProperties
{
	//Interval=0.25f INTERVAL IS OVERRIDDEN BY ITS PROJECTILE
	MaxTime=2.0

	ExplosionLightPriority=LPP_Low
	//LoopStartEvent=AkEvent'WW_WEP_SA_Flamethrower.Play_WEP_SA_Flamethrower_Residual_Fire_Loop'
	//LoopStopEvent=AkEvent'WW_WEP_SA_Flamethrower.Stop_WEP_SA_Flamethrower_Residual_Fire_Loop'
}
