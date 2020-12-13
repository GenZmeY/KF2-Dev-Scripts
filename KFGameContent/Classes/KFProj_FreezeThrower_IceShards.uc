//=============================================================================
// KFProj_FreezeThrower_IceShards
//=============================================================================
// Ice shards projectile class
//=============================================================================
// Killing Floor 2
// Copyright (C) 2017 Tripwire Interactive LLC
//=============================================================================
class KFProj_FreezeThrower_IceShards extends KFProj_Bullet_Pellet
	hidedropdown;

defaultproperties
{
	MaxSpeed=7000.0
	Speed=7000.0

	bWarnAIWhenFired=true

	DamageRadius=0

	ProjFlightTemplate=ParticleSystem'WEP_CryoGun_EMIT.FX_Cryogun_Projectile_alt'
	ProjFlightTemplateZedTime=ParticleSystem'WEP_CryoGun_EMIT.FX_Cryogun_Projectile_alt'

	AmbientSoundPlayEvent=none
    AmbientSoundStopEvent=none

    //ProjEffectsFadeOutDuration=0
    ImpactEffects=KFImpactEffectInfo'WEP_CryoGun_ARCH.Cryo_Alt_Impacts' 
}