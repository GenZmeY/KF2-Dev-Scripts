//=============================================================================
// KFProj_Bullet_HRG_CranialPopper
//=============================================================================
// Bullet class for the HRG CranialPopper
//=============================================================================
// Killing Floor 2
// Copyright (C) 2022 Tripwire Interactive LLC
//=============================================================================

class KFProj_Bullet_HRG_CranialPopper extends KFProj_Bullet
    hidedropdown;

defaultproperties
{
    MaxSpeed=30000.0
    Speed=30000.0

    DamageRadius=0

    ProjFlightTemplate=ParticleSystem'WEP_HRG_CranialPopper_EMIT.FX_CranialPopper_Projectile'
	ImpactEffects=KFImpactEffectInfo'WEP_HRG_CranialPopper_ARCH.Bleeder_bullet_impact'
}

