//=============================================================================
// KFProj_Bullet_LazerCutter
//=============================================================================
// Killing Floor 2
// Copyright (C) 2017 Tripwire Interactive LLC
//=============================================================================

class KFProj_Bullet_LazerCutter extends KFProj_Bullet
	hidedropdown;

defaultproperties
{
	MaxSpeed=22500.0
	Speed=22500.0

	DamageRadius=0

	ProjFlightTemplate=ParticleSystem'WEP_Laser_Cutter_EMIT.FX_Laser_Rifle_Tracer_ZedTime'
	ImpactEffects = KFImpactEffectInfo'WEP_Laser_Cutter_ARCH.Laser_Cutter_bullet_impact'
}
