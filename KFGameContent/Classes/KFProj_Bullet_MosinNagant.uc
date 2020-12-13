//=============================================================================
// KFProj_Bullet_MosinNagant
//=============================================================================
// Bullet class for the MosinNagant
//=============================================================================
// Killing Floor 2
// Copyright (C) 2019 Tripwire Interactive LLC
//=============================================================================

class KFProj_Bullet_MosinNagant extends KFProj_Bullet
	hidedropdown;

defaultproperties
{
	MaxSpeed=24000.0
	Speed=24000.0

	DamageRadius=0

	ProjFlightTemplate=ParticleSystem'WEP_1P_L85A2_EMIT.FX_L85A2_Tracer_ZEDTime'
}

