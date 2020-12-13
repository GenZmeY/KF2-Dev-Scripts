//=============================================================================
// KFProj_EvilDAR_Rocket
//=============================================================================
//
//=============================================================================
// Killing Floor 2
// Copyright (C) 2018 Tripwire Interactive LLC
//=============================================================================
class KFProj_EvilDAR_Rocket extends KFProjectile;

defaultproperties
{
	Physics=PHYS_Projectile
	Speed=1800 //6000
	MaxSpeed=3200 //6000
	ProjFlightTemplate=ParticleSystem'ZED_EvilDAR_EMIT.FX_EvilDar_RPG7_Projectile'
	ExplosionActorClass=class'KFExplosionActor'

    bCollideComplex=true	// Ignore simple collision on StaticMeshes, and collide per poly
	bBlockedByInstigator=false

	Begin Object Class=PointLightComponent Name=ExplosionPointLight
	    LightColor=(R=245,G=190,B=140,A=255)
		Brightness=4.f
		Radius=2000.f
		FalloffExponent=10.f
		CastShadows=False
		CastStaticShadows=FALSE
		CastDynamicShadows=False
		bCastPerObjectShadows=false
		bEnabled=FALSE
		LightingChannels=(Indoor=TRUE,Outdoor=TRUE,bInitialized=TRUE)
	End Object

	Begin Object Class=KFGameExplosion Name=ExploTemplate0
		Damage=10
		DamageRadius=300
		DamageFalloffExponent=1.f
		DamageDelay=0.f

		// Damage Effects
		MyDamageType=class'KFDT_EvilDAR_Rocket'
		MomentumTransferScale=30000.f //60000
		KnockDownStrength=100
		FractureMeshRadius=200.0
		FracturePartVel=500.0
		ExplosionEffects=KFImpactEffectInfo'FX_Impacts_ARCH.Explosions.HuskProjectile_Explosion'
		ExplosionSound=AkEvent'WW_ZED_Evil_DAR.Play_ZED_EvilDAR_SFX_Missle_Impact'

        // Dynamic Light
        ExploLight=ExplosionPointLight
        ExploLightStartFadeOutTime=0.0
        ExploLightFadeOutTime=0.5

		// Camera Shake
		CamShake=CameraShake'FX_CameraShake_Arch.Misc_Explosions.HuskFireball'
		CamShakeInnerRadius=150
		CamShakeOuterRadius=325
		CamShakeFalloff=1.f
		bOrientCameraShakeTowardsEpicenter=true
	End Object
	ExplosionTemplate=ExploTemplate0

	Begin Object Class=AkComponent name=AmbientAkSoundComponent
		bStopWhenOwnerDestroyed=true
        bForceOcclusionUpdateInterval=true
        OcclusionUpdateInterval=0.1f
    End Object
    AmbientComponent=AmbientAkSoundComponent
    Components.Add(AmbientAkSoundComponent)

	AmbientSoundPlayEvent=AkEvent'WW_ZED_Evil_DAR.Play_ZED_EvilDAR_SFX_Missle_Passby'
	bAutoStartAmbientSound=true
	bStopAmbientSoundOnExplode=true
}
