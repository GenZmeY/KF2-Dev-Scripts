//=============================================================================
// KFExplosion_HansNerveGasGrenade
//=============================================================================
// Explosion info for Hans' Nerve Gas Grenade
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
// - John "Ramm-Jaeger" Gibson
//=============================================================================

class KFExplosion_HansNerveGasGrenade extends KFExplosionActorLingering;

DefaultProperties
{
	Interval=1
	MaxTime=8
	DamageScalePerStack=0.f

	bExplodeMoreThanOnce=true
	bDoFullDamage=true

	LoopStartEvent=AkEvent'WW_WEP_EXP_Grenade_Medic.Play_WEP_EXP_Grenade_Medic_Smoke_Loop'
	LoopStopEvent=AkEvent'WW_WEP_EXP_Grenade_Medic.Stop_WEP_EXP_Grenade_Medic_Smoke_Loop'
}
