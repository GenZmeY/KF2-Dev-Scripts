//=============================================================================
// KFProj_ShrinkRay
//=============================================================================
// Projectile class for ground fire from Shrink ray, etc
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
// - John "Ramm-Jaeger" Gibson
//=============================================================================

class KFProj_ShrinkRay extends KFProj_GroundFire;

defaultproperties
{
	bWarnAIWhenFired=true

	// pointlight at far end of spray
	Begin Object Name=FlamePointLight
	    LightColor=(R=13,G=193,B=42,A=255)
		Brightness=0.25f
		Radius=500.f
		FalloffExponent=10.f
		CastShadows=False
		CastStaticShadows=FALSE
		CastDynamicShadows=TRUE
		bCastPerObjectShadows=false
		bEnabled=FALSE
		LightingChannels=(Indoor=TRUE,Outdoor=TRUE,bInitialized=TRUE)
	End Object

	// explosion
	Begin Object Class=KFGameExplosion Name=ExploTemplate0
		Damage=0
		DamageRadius=0.0
		DamageFalloffExponent=1.f
		DamageDelay=0.f
		MyDamageType=none
		// Don't burn the guy with the flamethrower
        bIgnoreInstigator=true	

        // Dynamic Light
        ExploLight=FlamePointLight
        ExploLightStartFadeOutTime=0.3
        ExploLightFadeOutTime=0.1
        ExploLightFlickerIntensity=1.f
        ExploLightFlickerInterpSpeed=50.f

		// Damage Effects
		KnockDownStrength=0
		KnockDownRadius=0
		FractureMeshRadius=0
		FracturePartVel=0
	    ExplosionEffects=KFImpactEffectInfo'WEP_ShrinkRay_Gun_ARCH.Beam_Impacts'
		ExplosionSound=none
		MomentumTransferScale=1
		bAllowPerMaterialFX=false

		// Camera Shake
		CamShake=none
	End Object
	ExplosionTemplate=ExploTemplate0
}
