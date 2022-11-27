//=============================================================================
// KFExplosion_HRG_Locust
//=============================================================================
// Explosion actor class for HRG Locust
//=============================================================================
// Killing Floor 2
// Copyright (C) 2022 Tripwire Interactive LLC
//=============================================================================

class KFExplosion_HRG_Locust extends KFExplosionActorLingering;

DefaultProperties
{
	Interval=0.5f
	MaxTime=3.0

	bOnlyDamagePawns=true
	bDoFullDamage=false

	LoopStartEvent=AkEvent'WW_WEP_HRG_Locust.Play_WEP_HRG_Locust_Insects'
	LoopStopEvent=AkEvent'WW_WEP_HRG_Locust.Stop_WEP_HRG_Locust_Insect'
}
