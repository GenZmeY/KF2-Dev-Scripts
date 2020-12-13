//=============================================================================
// KFExplosion_HuskCannonFireballGroundFire
//=============================================================================
// Spawns ground fire for the husk cannon fireball
//=============================================================================
// Killing Floor 2
// Copyright (C) 2017 Tripwire Interactive LLC
//=============================================================================
class KFExplosion_HuskCannonFireballGroundFire extends KFExplosion_HuskFireballGroundFire;

struct CachedExplosionInfo
{
	var GameExplosion ExplosionTemplate;
	var vector Direction;
};

/** Cached information about the explosion in case we need to delay it. */
var CachedExplosionInfo CachedExplosion;

/** How long should the explosion be delayed after initial impact. */
var float ExplosionDelay;

simulated function Explode(GameExplosion NewExplosionTemplate, optional vector Direction)
{
	if (ExplosionDelay > 0)
	{
		CachedExplosion.ExplosionTemplate = NewExplosionTemplate;
		CachedExplosion.Direction = Direction;
		SetTimer(ExplosionDelay, false, 'Timer_DelayExplosion');
	}
	else
	{
		super.Explode(NewExplosionTemplate, Direction);
	}
}

simulated function Timer_DelayExplosion()
{
	super.Explode(CachedExplosion.ExplosionTemplate, CachedExplosion.Direction);
}

defaultproperties
{
	LoopingParticleEffect =ParticleSystem'WEP_HuskCannon_EMIT.FX_Huskcannon_groundfire_L3'

	ExplosionDelay=0.f
}
