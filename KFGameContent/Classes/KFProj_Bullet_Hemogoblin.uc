//=============================================================================
// KFProj_Bullet_Hemogoblin
//=============================================================================
// Bullet class for the Hemogoblin
//=============================================================================
// Killing Floor 2
// Copyright (C) 2017 Tripwire Interactive LLC
//=============================================================================

class KFProj_Bullet_Hemogoblin extends KFProj_Bullet
    hidedropdown;

defaultproperties
{
    MaxSpeed=30000.0
    Speed=30000.0

    DamageRadius=0

    ProjFlightTemplate=ParticleSystem'WEP_Bleeder_EMIT.FX_Bleeder_Projectile'
	ImpactEffects=KFImpactEffectInfo'WEP_Bleeder_ARCH.Bleeder_bullet_impact'
}

