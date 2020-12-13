//=============================================================================
// KFExplosion_GroundFire
//=============================================================================
// Explosion actor class for ground fire
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
// John "Ramm-Jaeger" Gibson
//=============================================================================

class KFExplosion_GroundFire extends KFExplosionActorLingering;


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
	LoopStartEvent=AkEvent'WW_WEP_SA_Flamethrower.Play_WEP_SA_Flamethrower_Residual_Fire_Loop'
    LoopStopEvent=AkEvent'WW_WEP_SA_Flamethrower.Stop_WEP_SA_Flamethrower_Residual_Fire_Loop'
}
