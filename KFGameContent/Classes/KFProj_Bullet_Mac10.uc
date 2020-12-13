//=============================================================================
// KFProj_Bullet_Mac10
//=============================================================================
// Bullet projectile for Mac10.
//=============================================================================
// Killing Floor 2
// Copyright (C) 2018 Tripwire Interactive LLC
//=============================================================================

class KFProj_Bullet_Mac10 extends KFProj_Bullet_AssaultRifle
	hidedropdown;

defaultproperties
{
	//ProjFlightTemplate = ParticleSystem'WEP_DragonsBreath_EMIT.Tracer.FX_DragonsBreath_Tracer'
	ProjFlightTemplate = ParticleSystem'FX_Projectile_EMIT.FX_Tracer_9MM_ZEDTime'
	ImpactEffects = KFImpactEffectInfo'WEP_MAC10_ARCH.Mac10_bullet_impact'

	//AmbientSoundPlayEvent = AkEvent'WW_WEP_SA_DragonsBreath.Play_SA_DragonsBreath_Projectile_Loop'
	//AmbientSoundStopEvent = AkEvent'WW_WEP_SA_DragonsBreath.Stop_SA_DragonsBreath_Projectile_Loop'
}
