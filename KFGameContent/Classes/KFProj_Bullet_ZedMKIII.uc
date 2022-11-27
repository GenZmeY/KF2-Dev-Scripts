//=============================================================================
// KFProj_Bullet_ZedMKIII
//=============================================================================
//=============================================================================
// Killing Floor 2
// Copyright (C) 2022 Tripwire Interactive LLC
//=============================================================================

class KFProj_Bullet_ZedMKIII extends KFProj_Bullet
	hidedropdown;

defaultproperties
{
	MaxSpeed=22500.0
	Speed=22500.0

	DamageRadius=0

	ProjFlightTemplate = ParticleSystem'WEP_ZEDMKIII_EMIT.FX_ZEDMKIII_Bullet_Projectile'
	ImpactEffects = KFImpactEffectInfo'WEP_ZEDMKIII_ARCH.FX_ZEDMKIII_Bullet_Impact'
}

