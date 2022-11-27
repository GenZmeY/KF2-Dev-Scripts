//=============================================================================
// KFProj_HRG_DragonBreath_Splash
//=============================================================================
// Projectile class for hrg dragonbreath gun splash.  Handles a few overrides.
//=============================================================================
// Killing Floor 2
// Copyright (C) 2022 Tripwire Interactive LLC
//=============================================================================

class KFProj_HRG_DragonBreath_Splash extends KFProj_FlareGunSplash;

defaultproperties
{
	PostExplosionLifetime=2.5
	ExplosionActorClass=class'KFExplosion_HRG_Dragonbreath_GroundFire'

    Begin Object Name=ExploTemplate0
    	Damage=8
		DamageRadius=150.0
        MyDamageType=class'KFDT_Fire_Ground_HRG_DragonBreath'
        ExplosionEffects=KFImpactEffectInfo'WEP_Flamethrower_ARCH.GroundFire_Impacts'
    End Object

    AssociatedPerkClass=none
}