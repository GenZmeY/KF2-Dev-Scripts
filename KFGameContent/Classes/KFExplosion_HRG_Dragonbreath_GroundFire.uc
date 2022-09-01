//=============================================================================
// KFExplosion_HRG_Dragonbreath_GroundFire
//=============================================================================
// Explosion actor class for ground fire
//=============================================================================
// Killing Floor 2
// Copyright (C) 2022 Tripwire Interactive LLC
//=============================================================================

class KFExplosion_HRG_Dragonbreath_GroundFire extends KFExplosionActorLingering;


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
	LoopStartEvent=AkEvent'ww_wep_hrg_megadragonbreath.Play_WEP_HRG_MegaDragonbreath_Flame_LP'
    LoopStopEvent=AkEvent'ww_wep_hrg_megadragonbreath.Stop_WEP_HRG_MegaDragonbreath_End_Flame_LP'
}
