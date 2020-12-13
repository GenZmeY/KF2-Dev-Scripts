//=============================================================================
// KFExplosion_HuskFireballGroundFire
//=============================================================================
// Spawns ground fire for the husk fireball
//=============================================================================
// Killing Floor 2
// Copyright (C) 2016 Tripwire Interactive LLC
//=============================================================================
class KFExplosion_HuskFireballGroundFire extends KFExplosionActorLingering;

/** Replacement particles to play when hitting surfaces at different angles */
var() ParticleSystem LoopingParticleEffectCeiling;
var() ParticleSystem LoopingParticleEffectWall;

DefaultProperties
{
	bDoFullDamage=true

	LoopingParticleEffect=ParticleSystem'WEP_3P_Molotov_EMIT.FX_Molotov_ground_fire_01'

	LoopingParticleEffectCeiling=ParticleSystem'WEP_3P_Molotov_EMIT.FX_Molotov_Grenade_Spread_Ceiling_01'
	LoopingParticleEffectWall=ParticleSystem'WEP_3P_Molotov_EMIT.FX_Molotov_Grenade_Spread_Wall_01'

	LoopStartEvent=AkEvent'WW_WEP_SA_Flamethrower.Play_WEP_SA_Flamethrower_Residual_Fire_Loop'
    LoopStopEvent=AkEvent'WW_WEP_SA_Flamethrower.Stop_WEP_SA_Flamethrower_Residual_Fire_Loop'
}