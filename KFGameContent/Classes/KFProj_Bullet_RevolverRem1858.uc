//=============================================================================
// KFProj_Bullet_RevolverRem1858
//=============================================================================
// Bullet class for Remington 1858 revolver
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
// John "Ramm-Jaeger" Gibson
//=============================================================================

class KFProj_Bullet_RevolverRem1858 extends KFProj_Bullet
	hidedropdown;

defaultproperties
{
	MaxSpeed=15000.0
	Speed=15000.0

	DamageRadius=0

	ProjFlightTemplate=ParticleSystem'FX_Projectile_EMIT.FX_Tracer_9MM_ZEDTime'
}

