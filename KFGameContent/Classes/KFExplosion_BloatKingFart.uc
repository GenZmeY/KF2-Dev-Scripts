//=============================================================================
// KFExplosion_KingBloatFart
//=============================================================================
// Explosion info king bloat fart attack. Spawned by animnotify
//=============================================================================
// Killing Floor 2
// Copyright (C) 2016 Tripwire Interactive LLC
//=============================================================================
class KFExplosion_BloatKingFart extends KFExplosionActorLingering;

DefaultProperties
{
	Interval=1
	MaxTime=5 //15
	DamageScalePerStack=0.f

	bExplodeMoreThanOnce=true
	bDoFullDamage=true

	LoopStartEvent=AkEvent'WW_WEP_EXP_Grenade_Medic.Play_WEP_EXP_Grenade_Medic_Smoke_Loop'
	LoopStopEvent=AkEvent'WW_WEP_EXP_Grenade_Medic.Stop_WEP_EXP_Grenade_Medic_Smoke_Loop'
}
