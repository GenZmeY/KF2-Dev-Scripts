//=============================================================================
// KFProj_Bullet_RailGun
//=============================================================================
// Bullet class for the RailGun
//=============================================================================
// Killing Floor 2
// Copyright (C) 2017 Tripwire Interactive LLC
//=============================================================================

class KFProj_Bullet_RailGun extends KFProj_Bullet
    hidedropdown;

defaultproperties
{
    MaxSpeed=30000.0
    Speed=30000.0

    DamageRadius=0

    ProjFlightTemplate=ParticleSystem'wep_railgun_emit.FX_Railgun_Projectile_01'
}

