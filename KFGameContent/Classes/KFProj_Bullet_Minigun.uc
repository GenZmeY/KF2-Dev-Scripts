//=============================================================================
// KFProj_Bullet_Minigun
//=============================================================================
// Bullet class for Minigun
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//=============================================================================

class KFProj_Bullet_Minigun extends KFProj_Bullet
	hidedropdown;

var ParticleSystem AddedImpactEffect;

simulated static function PlayAddedImpactEffect(Vector HitLocation, Vector HitNormal)
{
	local WorldInfo WI;
	if( default.AddedImpactEffect != none )
	{
		WI = Class'WorldInfo'.static.GetWorldInfo();
		WI.MyEmitterPool.SpawnEmitter(default.AddedImpactEffect, HitLocation, rotator(HitNormal));
	}
}

defaultproperties
{
	MaxSpeed=22500.0
	Speed=22500.0

	DamageRadius=0
	
	ProjFlightTemplate=ParticleSystem'WEP_1P_L85A2_EMIT.FX_L85A2_Tracer_ZEDTime'
	ImpactEffects=KFImpactEffectInfo'FX_Impacts_ARCH.Heavy_bullet_impact'

	AddedImpactEffect=ParticleSystem'WEP_Minigun_EMIT.FX_Minigun_Impact_Extra'
}

