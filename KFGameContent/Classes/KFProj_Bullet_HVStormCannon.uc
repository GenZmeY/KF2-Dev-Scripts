//=============================================================================
// KFProj_Bullet_HVStormCannon
//=============================================================================
//=============================================================================
// Killing Floor 2
// Copyright (C) 2022 Tripwire Interactive LLC
//=============================================================================

class KFProj_Bullet_HVStormCannon extends KFProj_Bullet
	hidedropdown;

defaultproperties
{
	MaxSpeed=22500.0
	Speed=22500.0

	ProjEffectsFadeOutDuration=0

	DamageRadius=0

	ProjFlightTemplate = ParticleSystem'WEP_HVStormCannon_EMIT.FX_HVStormCannon_Projectile'  
	ImpactEffects = KFImpactEffectInfo'WEP_HVStormCannon_ARCH.Wep_HVStormCannon_Impact'
}

