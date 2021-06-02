//=============================================================================
// KFProj_ThermiteSplash
//=============================================================================
// Projectile class for the thermite rocket launchers
//=============================================================================
// Killing Floor 2
// Copyright (C) 2021 Tripwire Interactive LLC
//=============================================================================

class KFProj_ThermiteSplash extends KFProj_MolotovSplash;

/*
simulated function Tick(float Delta)
{
	super.Tick(Delta);

	if (WorldInfo.NetMode != NM_Client && WorldInfo.NetMode != NM_Standalone)
	{
		return;
	}

	// Rotate towards velocity:
	if (VSizeSq(Velocity) > 0)
	{
		SetRotation(rotator(Normal(Velocity)));
	}
}
*/
defaultproperties
{
	Physics=PHYS_Falling

	bCollideComplex=TRUE	// Ignore simple collision on StaticMeshes, and collide per poly

	// network
	bNetTemporary=False
	bAlwaysReplicateExplosion=true
	AlwaysRelevantDistanceSquared=6250000 // 25m

	// gameplay
	bBlockedByInstigator=false
	GlassShatterType=FMGS_ShatterNone

	// audio
	bStopAmbientSoundOnExplode=false
    bAutoStartAmbientSound=true
    bAmbientSoundZedTimeOnly=false

    AmbientSoundPlayEvent=AkEvent'WW_WEP_SA_Flamethrower.Play_WEP_SA_Flamethrower_Residual_Fire_Loop'
    AmbientSoundStopEvent=AkEvent'WW_WEP_SA_Flamethrower.Stop_WEP_SA_Flamethrower_Residual_Fire_Loop'

    Begin Object name=AmbientAkSoundComponent
    	bStopWhenOwnerDestroyed=true
    	bForceOcclusionUpdateInterval=true
        OcclusionUpdateInterval=0.25;
    End Object
    AmbientComponent=AmbientAkSoundComponent
    Components.Add(AmbientAkSoundComponent)

    // light
	Begin Object Name=FlamePointLight
	    LightColor=(R=245,G=190,B=140,A=255)
		Brightness=2.f
		Radius=300.f
		FalloffExponent=10.f
		CastShadows=False
		CastStaticShadows=FALSE
		CastDynamicShadows=FALSE
		bCastPerObjectShadows=false
		bEnabled=FALSE
		LightingChannels=(Indoor=TRUE,Outdoor=TRUE,bInitialized=TRUE)
	End Object

	// explosion
	Begin Object Name=ExploTemplate0
		Damage=10
		DamageRadius=150
		DamageFalloffExponent=1.f
		DamageDelay=0.f
		// Don't burn the guy that tossed it, it's just too much damage with multiple fires, its almost guaranteed to kill the guy that tossed it
        bIgnoreInstigator=true

		MomentumTransferScale=1

		// Damage Effects
		MyDamageType=class'KFDT_Fire_Ground_ThermiteBore'
		KnockDownStrength=0
		FractureMeshRadius=0
		ExplosionEffects=KFImpactEffectInfo'wep_thermite_arch.Thermite_GroundFire'

		bDirectionalExplosion=true

		// Camera Shake
		CamShake=none

		// Dynamic Light
        ExploLight=FlamePointLight
        ExploLightStartFadeOutTime=4.2
        ExploLightFadeOutTime=0.3
	End Object
	ExplosionTemplate=ExploTemplate0

	ProjFlightTemplate=ParticleSystem'WEP_Thermite_EMIT.FX_Thermite_Spread_01'
	ExplosionActorClass=class'KFExplosion_Thermite'

	AssociatedPerkClass=class'KFPerk_Firebug'

	// Ground Fire Perk Skill Alternative FX
    AltExploEffects=KFImpactEffectInfo'WEP_Thermite_ARCH.GroundFire_Splash_Impacts'
}
