//=============================================================================
// KFExplosion_HRGIncendiaryRifleGroundFire
//=============================================================================
// Explosion actor class for incendiary rifle grenade ground fire
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//	- Tulio Beloqui (Saber Interactive)
//=============================================================================

class KFExplosion_HRGIncendiaryRifleGroundFire extends KFExplosionActorLingering;

/** Replacement particles to play when hitting surfaces at different angles */
var() ParticleSystem LoopingParticleEffectCeiling;
var() ParticleSystem LoopingParticleEffectWall;

defaultproperties
{
	bDoFullDamage=true
	
	// How often, in seconds, we should apply burn
	Interval=0.5
	// How long the ground fire should stick around
	MaxTime=10.0

	LoopingParticleEffect=ParticleSystem'WEP_3P_Molotov_EMIT.FX_Molotov_ground_fire_01'

	LoopingParticleEffectCeiling=ParticleSystem'WEP_3P_Molotov_EMIT.FX_Molotov_Grenade_Spread_Ceiling_01'
	LoopingParticleEffectWall=ParticleSystem'WEP_3P_Molotov_EMIT.FX_Molotov_Grenade_Spread_Wall_01'

	LoopStartEvent=AkEvent'WW_WEP_SA_Flamethrower.Play_WEP_SA_Flamethrower_Residual_Fire_Loop'
    LoopStopEvent=AkEvent'WW_WEP_SA_Flamethrower.Stop_WEP_SA_Flamethrower_Residual_Fire_Loop'
}
