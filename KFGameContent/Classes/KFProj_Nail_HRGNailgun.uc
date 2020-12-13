//=============================================================================
// KFProj_Nail_HRGNailgun
//=============================================================================
// Nail class for the the HRG Nailgun
//=============================================================================
// Killing Floor 2
// Copyright (C) 2019 Tripwire Interactive LLC
//=============================================================================

class KFProj_Nail_HRGNailgun extends KFProj_Nail_Nailgun
	hidedropdown;

defaultproperties
{
	MaxSpeed=22500.0
	Speed=22500.0

    bWarnAIWhenFired=true

	DamageRadius=0

	LifeSpan = 2.0

    BouncesLeft=1
    DampingFactor=0.65
    RicochetEffects=KFImpactEffectInfo'WEP_Nail_Shotgun_ARCH.NailBulletImpacts'

	ProjFlightTemplate=ParticleSystem'WEP_1P_Nail_Shotgun_EMIT.FX_Nail_Shotgun_Tracer'
	ProjFlightTemplateZedTime=ParticleSystem'WEP_1P_Nail_Shotgun_EMIT.FX_Nail_Shotgun_Tracer_ZEDTime'
}


