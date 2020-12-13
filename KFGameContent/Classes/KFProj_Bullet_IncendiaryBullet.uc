//=============================================================================
// KFProj_Bullet_IncendiaryBullet
//=============================================================================
// Class Description
//=============================================================================
// Killing Floor 2
// Copyright (C) 2018 Tripwire Interactive LLC
// -Zane Gholson
//=============================================================================

class KFProj_Bullet_IncendiaryBullet extends KFProj_Bullet_AssaultRifle
	hidedropdown;


defaultproperties
{
	ProjFlightTemplate= ParticleSystem'WEP_DragonsBreath_EMIT.Tracer.FX_DragonsBreath_Tracer'
	ProjFlightTemplateZedTime = ParticleSystem'WEP_DragonsBreath_EMIT.Tracer.FX_DragonsBreath_Tracer_ZEDTime'
	ImpactEffects= KFImpactEffectInfo'WEP_DragonsBreath_ARCH.DragonsBreath_bullet_impact'

	AmbientSoundPlayEvent = AkEvent'WW_WEP_SA_DragonsBreath.Play_SA_DragonsBreath_Projectile_Loop'
	AmbientSoundStopEvent = AkEvent'WW_WEP_SA_DragonsBreath.Stop_SA_DragonsBreath_Projectile_Loop'
}