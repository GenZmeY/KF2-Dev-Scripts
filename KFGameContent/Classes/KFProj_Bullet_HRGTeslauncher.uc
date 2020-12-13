//=============================================================================
// KFProj_Bullet_HRGTeslauncher
//=============================================================================
//=============================================================================
// Killing Floor 2
// Copyright (C) 2019 Tripwire Interactive LLC
//=============================================================================

class KFProj_Bullet_HRGTeslauncher extends KFProj_Bullet_AssaultRifle;

defaultproperties
{
	MaxSpeed=22500.0
	Speed=22500.0

	DamageRadius=0

	ProjFlightTemplate = ParticleSystem'WEP_Microwave_Assault_EMIT.FX_Microwave_Rifle_Projectile'
	ImpactEffects = KFImpactEffectInfo'WEP_Microwave_Assault_ARCH.Microwave_Assault_bullet_impact'
}
