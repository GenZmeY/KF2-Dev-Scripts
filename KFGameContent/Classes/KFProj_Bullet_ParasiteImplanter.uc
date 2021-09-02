//=============================================================================
// KFProj_Bullet_ParasiteImplanter
//=============================================================================
// Bullet class for the Parasite Implanter
//=============================================================================
// Killing Floor 2
// Copyright (C) 2021 Tripwire Interactive LLC
//=============================================================================

class KFProj_Bullet_ParasiteImplanter extends KFProj_Bullet
	hidedropdown;

defaultproperties
{
	MaxSpeed=24000.0
	Speed=24000.0

	DamageRadius=0

	ProjFlightTemplate=ParticleSystem'WEP_1P_L85A2_EMIT.FX_L85A2_Tracer_ZEDTime'
}

