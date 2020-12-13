//=============================================================================
// KFExplosion_MedicGrenadeMini
//=============================================================================
// Used by projectiles and kismet to spawn an explosion
//=============================================================================
// Killing Floor 2
// Copyright (C) 2018 Tripwire Interactive LLC
//=============================================================================

class KFExplosion_MedicGrenadeMini extends KFExplosion_MedicGrenade;

DefaultProperties
{
	HealingDamageType=class'KFDT_Healing_MedicGrenade'
	HealingAmount=10 //5
	Interval=1 //0.75
	MaxTime=8

	bExplodeMoreThanOnce=true
	bDoFullDamage=true
	bSkipLineCheckForPawns=true

	LoopStartEvent=AkEvent'WW_WEP_Medic_GrenadeLauncher.Play_WEP_Medic_GrenadeLauncher_Grenade_Smoke_Loop'
	LoopStopEvent=AkEvent'WW_WEP_Medic_GrenadeLauncher.Stop_WEP_Medic_GrenadeLauncher_Grenade_Smoke_Loop'
}
