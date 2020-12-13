//=============================================================================
// KFProj_Bullet_PistolAF2011
//=============================================================================
// Bullet class for AF2011-A1 pistols
//=============================================================================
// Killing Floor 2
// Copyright (C) 2017 Tripwire Interactive LLC
//=============================================================================

class KFProj_Bullet_PistolAF2011 extends KFProj_Bullet
    hidedropdown;

defaultproperties
{
	MaxSpeed=18000.0
	Speed=18000.0

	DamageRadius=0

	ProjFlightTemplate=ParticleSystem'FX_Projectile_EMIT.FX_Tracer_9MM_ZEDTime'
}

