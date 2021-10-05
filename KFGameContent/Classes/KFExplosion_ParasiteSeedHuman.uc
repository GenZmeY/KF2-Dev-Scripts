//=============================================================================
// KFExplosion_ParasiteSeedHuman
//=============================================================================
// Explosion created when hitting a human
//=============================================================================
// Killing Floor 2
// Copyright (C) 2021 Tripwire Interactive LLC
//=============================================================================

class KFExplosion_ParasiteSeedHuman extends KFExplosion_MedicGrenade;

DefaultProperties
{
	HealingDamageType=class'KFDT_Healing_ParasiteSeed'
	HealingAmount=30 //10
	Interval=1.0 //1
	MaxTime=0.5 //6.5 //8

	bExplodeMoreThanOnce=false
	bDoFullDamage=false //true
	bSkipLineCheckForPawns=true

	LoopingParticleEffect=ParticleSystem'WEP_3P_Medic_Grenade_EMIT.FX_Medic_Grenade_Explosion'
	LoopStartEvent=AkEvent'WW_WEP_Medic_GrenadeLauncher.Play_WEP_Medic_GrenadeLauncher_Grenade_Smoke_Loop'
	LoopStopEvent=AkEvent'WW_WEP_Medic_GrenadeLauncher.Stop_WEP_Medic_GrenadeLauncher_Grenade_Smoke_Loop'
}
