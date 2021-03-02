//=============================================================================
// KFProj_SonicBlastFullyCharged_HRG_SonicGun
//=============================================================================
// HRG Sonic Gun sonic projectile for default fire
//=============================================================================
// Killing Floor 2
// Copyright (C) 2020 Tripwire Interactive LLC
//=============================================================================
class KFProj_SonicBlastFullyCharged_HRG_SonicGun extends KFProj_Bullet;

/**
 * Initialize the Projectile
 */
function Init(vector Direction)
{
    super(KFProjectile).Init( Direction );
}

simulated function SpawnFlightEffects()
{
	super.SpawnFlightEffects();
	//TODO: Remove. Temporal to see change in FX
	ProjEffects.SetScale( 1.0 );
}

simulated function ProcessTouch(Actor Other, Vector HitLocation, Vector HitNormal)
{
	super.ProcessTouch(Other, HitLocation, HitNormal);
	if (PenetrationPower <= 0)
	{
		Shutdown();
	}
}

defaultproperties
{
	ProjFlightTemplate = ParticleSystem'WEP_HRG_SonicGun_EMIT.FX_Projectile_AltFire'
	ProjFlightTemplateZedTime = ParticleSystem'WEP_HRG_SonicGun_EMIT.FX_Projectile_AltFire'

	ImpactEffects = KFImpactEffectInfo'WEP_HRG_SonicGun_ARCH.HRG_SonicGun_Projectile_AltFire_Impacts'

	bWarnAIWhenFired=true

    Lifespan=10.0

	MaxSpeed=10000.0 //7200.0
	Speed=10000.0 //7200.0
	TerminalVelocity=7200

    GravityScale=0.0//0.7

	ProjDisintegrateTemplate=ParticleSystem'ZED_Siren_EMIT.FX_Siren_grenade_disable_01'

	AssociatedPerkClass=class'KFPerk_Sharpshooter'
}