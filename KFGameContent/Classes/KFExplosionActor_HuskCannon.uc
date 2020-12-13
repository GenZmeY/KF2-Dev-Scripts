//=============================================================================
// KFExplosionActor_HuskCannon
//=============================================================================
// Specialized explosion actor for the player-based Husk Cannon.
//=============================================================================
// Killing Floor 2
// Copyright (C) 2017 Tripwire Interactive LLC
//=============================================================================

class KFExplosionActor_HuskCannon extends KFExplosionActor;

var float DamageScale;

simulated function float GetDamageFor(Actor Victim)
{
    return ExplosionTemplate.Damage * DamageScale;
}

defaultproperties
{
    DamageScale=1.f
}