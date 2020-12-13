//=============================================================================
// KFProj_Bullet_MicrowaveRifle
//=============================================================================
// Class Description
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//=============================================================================

class KFProj_Bullet_MicrowaveRifle extends KFProj_Bullet
	hidedropdown;

defaultproperties
{
	MaxSpeed=22500.0
	Speed=22500.0

	DamageRadius=0

	ProjFlightTemplate = ParticleSystem'WEP_Microwave_Assault_EMIT.FX_Microwave_Rifle_Projectile'
	ImpactEffects = KFImpactEffectInfo'WEP_Microwave_Assault_ARCH.Microwave_Assault_bullet_impact'
}

