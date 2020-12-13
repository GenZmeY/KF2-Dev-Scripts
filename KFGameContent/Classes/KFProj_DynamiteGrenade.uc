//=============================================================================
// KFProj_DynamiteGrenade
//=============================================================================
// Dynamite projectile class
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
// - John "Ramm-Jaeger" Gibson and Jeff Robinson
//=============================================================================

class KFProj_DynamiteGrenade extends KFProj_Grenade
	hidedropdown;

/** On Contact demo skill can turn our grenade into an insta boom device */
var bool bExplodeOnContact;

/** Ambient sound to play */
var AkEvent FuseEvent;

/** Dynamic light */
var PointLightComponent FuseLight;

/**
 * Set the initial velocity and cook time
 */
simulated function PostBeginPlay()
{
	PlaySoundBase( FuseEvent, true,, true );

	Super.PostBeginPlay();
}

/** Overridden to turn off dynamic light */
simulated function TriggerExplosion(Vector HitLocation, Vector HitNormal, Actor HitActor)
{
	super.TriggerExplosion( HitLocation, HitNormal, HitActor );

	FuseLight.SetEnabled( false );
}

//==============
// Touching
simulated function ProcessTouch(Actor Other, Vector HitLocation, Vector HitNormal)
{
	local Pawn ActorPawn;

	if( Other != Instigator && !Other.bWorldGeometry )
	{
		ActorPawn = Pawn(other);
		if ( ActorPawn != None )
		{
            // For opposing team, make the grenade explode instantly
			if( ActorPawn.GetTeamNum() != GetTeamNum() )
			{
				if (!bHasExploded && !bHasDisintegrated)
				{
					GetExplodeEffectLocation( HitLocation, HitNormal, Other );
        			TriggerExplosion( HitLocation, HitNormal, Other );
        		}
			}
		}
	}

	super.ProcessTouch( Other, HitLocation, HitNormal );
}

// for nukes && concussive force
simulated protected function PrepareExplosionTemplate()
{
	class'KFPerk_Demolitionist'.static.PrepareExplosive( Instigator, self );

    super.PrepareExplosionTemplate();
}

simulated protected function SetExplosionActorClass()
{
   local KFPlayerReplicationInfo InstigatorPRI;

    if( WorldInfo.TimeDilation < 1.f && Instigator != none )
    {
       InstigatorPRI = KFPlayerReplicationInfo(Instigator.PlayerReplicationInfo);
        if( InstigatorPRI != none )
        {
            if( InstigatorPRI.bNukeActive && class'KFPerk_Demolitionist'.static.ProjectileShouldNuke( self ) )
            {
                ExplosionActorClass = class'KFPerk_Demolitionist'.static.GetNukeExplosionActorClass();
            }
        }
    }

    super.SetExplosionActorClass();
}

defaultproperties
{
	bWarnAIWhenFired=true

	Speed=1500
	TossZ=400

	LandedTranslationOffset=(X=-8)

	FuseTime=3.0

	DampenFactor=0.200000
    DampenFactorParallel=0.300000

	ProjFlightTemplate=ParticleSystem'WEP_Dynamite_EMIT.FX_Dynamite_Grenade_Mesh'
	ExplosionActorClass=class'KFExplosionActor'
	WeaponSelectTexture=Texture2D'wep_ui_dynamite_tex.UI_WeaponSelect_Dynamite'

	AltExploEffects=KFImpactEffectInfo'WEP_Dynamite_ARCH.Dynamite_Explosion_Concussive_Force'

	// fuse light
	Begin Object Class=PointLightComponent Name=FusePointLight
	    LightColor=(R=255,G=200,B=63,A=255)
		Brightness=1.f
		Radius=300.f
		FalloffExponent=10.f
		CastShadows=False
		CastStaticShadows=FALSE
		CastDynamicShadows=False
		bCastPerObjectShadows=false
		bEnabled=TRUE
		LightingChannels=(Indoor=TRUE,Outdoor=TRUE,bInitialized=TRUE)
		Translation=(Z=6)

		// light anim
        AnimationType=1 // LightAnim_Flicker
        AnimationFrequency=2.f
        MinBrightness=0.5f
        MaxBrightness=1.5f
	End Object
	FuseLight=FusePointLight
	Components.Add(FusePointLight);

	// explosion
	Begin Object Class=KFGameExplosion Name=ExploTemplate0
		Damage=300  //400
		DamageRadius=400  //900
		DamageFalloffExponent=2  //3
		DamageDelay=0.f

		// Damage Effects
		MyDamageType=class'KFDT_Explosive_DynamiteGrenade'
		KnockDownStrength=0
		FractureMeshRadius=200.0
		FracturePartVel=500.0
		ExplosionEffects=KFImpactEffectInfo'WEP_Dynamite_ARCH.Dynamite_Explosion'
		ExplosionSound=AkEvent'WW_WEP_EXP_Dynamite.Play_WEP_EXP_Dynamite_Explosion'

        // Dynamic Light
        ExploLight=ExplosionPointLight
        ExploLightStartFadeOutTime=0.0
        ExploLightFadeOutTime=0.2

		// Camera Shake
		CamShake=CameraShake'FX_CameraShake_Arch.Grenades.Default_Grenade'
		CamShakeInnerRadius=200
		CamShakeOuterRadius=900
		CamShakeFalloff=1.5f
		bOrientCameraShakeTowardsEpicenter=true
	End Object
	ExplosionTemplate=ExploTemplate0

	// Temporary effect (5.14.14)
	ProjDisintegrateTemplate=ParticleSystem'ZED_Siren_EMIT.FX_Siren_grenade_disable_01'

	GlassShatterType=FMGS_ShatterNone

	FuseEvent=AkEvent'WW_WEP_EXP_Dynamite.Play_WEP_EXP_Dynamite_Fuse_LP'

	AssociatedPerkClass=class'KFPerk_Demolitionist'
}


