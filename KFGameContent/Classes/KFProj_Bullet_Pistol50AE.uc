//=============================================================================
// KFProj_Bullet_Pistol50AE
//=============================================================================
// Bullet class for 50 caliber Action Express pistols
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
// John "Ramm-Jaeger" Gibson
//=============================================================================

class KFProj_Bullet_Pistol50AE extends KFProj_Bullet
	hidedropdown;

defaultproperties
{
	MaxSpeed=18000.0
	Speed=18000.0

	DamageRadius=0

	ProjFlightTemplate=ParticleSystem'FX_Projectile_EMIT.FX_Tracer_9MM_ZEDTime'
}

