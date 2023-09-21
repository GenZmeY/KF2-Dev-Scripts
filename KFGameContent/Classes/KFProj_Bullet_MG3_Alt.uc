//=============================================================================
// KFProj_Bullet_MG3_Alt
//=============================================================================
// Class Description
//=============================================================================
// Killing Floor 2
// Copyright (C) 2023 Tripwire Interactive LLC
//=============================================================================

class KFProj_Bullet_MG3_Alt extends KFProj_Bullet
	hidedropdown;

defaultproperties
{
	MaxSpeed=22500.0
	Speed=22500.0

	DamageRadius=0

	ProjFlightTemplate=ParticleSystem'WEP_MG3_EMIT.FX_MG3_Tracer_ZEDTime' 
	ImpactEffects=KFImpactEffectInfo'WEP_MG3_ARCH.MG3_ALT_impact' 
}

