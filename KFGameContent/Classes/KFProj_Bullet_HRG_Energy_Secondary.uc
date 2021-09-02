//=============================================================================
// KFProj_Bullet_HRG_Energy_Secondary
//=============================================================================
//=============================================================================
// Killing Floor 2
// Copyright (C) 2021 Tripwire Interactive LLC
//=============================================================================

class KFProj_Bullet_HRG_Energy_Secondary extends KFProj_Bullet;

defaultproperties
{
	MaxSpeed=7500.0
	Speed=7500.0

	DamageRadius=0

	ProjFlightTemplateZedTime=ParticleSystem'WEP_HRG_Energy_EMIT.FX_Energy_Alt_Tracer_Instant'
	ImpactEffects = KFImpactEffectInfo'WEP_HRG_Energy_ARCH.Wep_HRG_Energy_Impact_Alt'

}
