//=============================================================================
// KFProj_Bullet_HRG_Energy
//=============================================================================
//=============================================================================
// Killing Floor 2
// Copyright (C) 2021 Tripwire Interactive LLC
//=============================================================================

class KFProj_Bullet_HRG_Energy extends KFProj_Bullet
	hidedropdown;

defaultproperties
{
	MaxSpeed=15000.0
	Speed=15000.0

	DamageRadius=0

	ProjFlightTemplateZedTime=ParticleSystem'WEP_HRG_Energy_EMIT.FX_Energy_Tracer_Instant'
	ImpactEffects = KFImpactEffectInfo'WEP_HRG_Energy_ARCH.Wep_HRG_Energy_Impact'

}

