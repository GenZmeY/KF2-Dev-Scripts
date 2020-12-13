//=============================================================================
// KFProj_DragonsBreathSplash
//=============================================================================
// Projectile class for trench gun splash.  Handles a few overrides.
//=============================================================================
// Killing Floor 2
// Copyright (C) 2018 Tripwire Interactive LLC
//=============================================================================

class KFProj_DragonsBreathSplash extends KFProj_FlareGunSplash;

defaultproperties
{
	PostExplosionLifetime=2.5
	ExplosionActorClass=class'KFExplosion_GroundFire'

    Begin Object Name=ExploTemplate0
    	Damage=8
		DamageRadius=150.0
        MyDamageType=class'KFDT_Fire_Ground_DragonsBreath'
        ExplosionEffects=KFImpactEffectInfo'WEP_Flamethrower_ARCH.GroundFire_Impacts'
    End Object

    AssociatedPerkClass=none
}