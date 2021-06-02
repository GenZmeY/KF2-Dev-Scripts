//=============================================================================
// KFProj_Grenade_GravityImploder
//=============================================================================
// Killing Floor 2
// Copyright (C) 2020 Tripwire Interactive LLC
//=============================================================================

class KFProj_Grenade_GravityImploder extends KFProj_BallisticExplosive
	hidedropdown;

/* Ensure it detonates */
var float DetonationTime;
var float VortexDuration;
var float VortexRadius;
var float VortexImpulseStrength;
var protected transient bool bVortexActive;

simulated state GrenadeState
{
	simulated event BeginState(Name PrevStateName)
	{
		super.BeginState(PrevStateName);

		if (Role == ROLE_Authority)
		{
			SetTimer(DetonationTime, false, nameOf(Timer_Detonate));
		}
	}
}

simulated state VortexState
{
	simulated event BeginState(Name PrevStateName)
	{
		super.BeginState(PrevStateName);
		
		ClearTimer(nameof(Timer_Detonate));
		
		bVortexActive = true;

		if (Role == ROLE_Authority)
		{
			SetTimer(VortexDuration, false, 'Timer_EndVortex');
		}
	}

	simulated event Tick(float DeltaTime)
	{
		local Actor          Victim;
		local TraceHitInfo   HitInfo;
		local FracturedStaticMeshActor FracActor;

		if(bVortexActive && (WorldInfo.NetMode == NM_Client || WorldInfo.NetMode == NM_Standalone))
		{
			foreach CollidingActors(class'Actor', Victim, VortexRadius, Location, true,, HitInfo)
			{
				if (KFPawn_Human(Victim) == none && Victim.CollisionComponent != none && !Victim.bWorldGeometry)
				{
					Victim.CollisionComponent.AddRadialImpulse(Location, VortexRadius, VortexImpulseStrength, RIF_Constant, true);
				}
				
				FracActor = FracturedStaticMeshActor(Victim);
				if (FracActor != none)
				{
					FracActor.BreakOffPartsInRadius(Location, VortexRadius, VortexImpulseStrength, true);
				}
			}
		}
	}
}

/**
 * Set the initial velocity and cook time
 */
simulated event PostBeginPlay()
{
	Super.PostBeginPlay();

	AdjustCanDisintigrate();
	GotoState('GrenadeState');
}

simulated function Timer_Detonate()
{
	Detonate();
}

simulated function Detonate()
{
	Explode(Location, vect(0,0,1) >> Rotation);
}

simulated function Explode(vector HitLocation, vector HitNormal)
{
	super.Explode(HitLocation, HitNormal);
	GotoState('VortexState');
}

simulated function Timer_EndVortex()
{
	bVortexActive = false;
	DeferredDestroy(0.15);
}


/** Called when the owning instigator controller has left a game */
simulated function OnInstigatorControllerLeft()
{
	if( WorldInfo.NetMode != NM_Client )
	{
		SetTimer( 1.f + Rand(5) + fRand(), false, nameOf(Timer_Detonate) );
	}
}


defaultproperties
{
	TouchTimeThreshhold = 60.0f
	Physics=PHYS_Falling
	Speed=3200
	MaxSpeed=3200
	TerminalVelocity=3200
	GravityScale=1.0
    LifeSpan=0.f
	bWarnAIWhenFired=true

	ProjFlightTemplate=ParticleSystem'WEP_Gravity_Imploder_EMIT.FX_Yellow_Projectile'
	ProjFlightTemplateZedTime=ParticleSystem'WEP_Gravity_Imploder_EMIT.FX_Yellow_Projectile_ZEDTIME'

	//GrenadeBounceEffectInfo=KFImpactEffectInfo'FX_Impacts_ARCH.DefaultGrenadeImpacts'
    ProjDisintegrateTemplate=ParticleSystem'ZED_Siren_EMIT.FX_Siren_grenade_disable_01'
	//AltExploEffects=KFImpactEffectInfo'WEP_Gravity_Imploder_ARCH.Yellow_Explosion_Concussive_Force'

	// Grenade explosion light
	Begin Object Class=PointLightComponent Name=ExplosionPointLight
	    LightColor=(R=0,G=25,B=250,A=255)
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

	// Explosion
	Begin Object Class=KFGameExplosion Name=ImploTemplate0
		Damage=320 //150
		DamageRadius=280 //375
		DamageFalloffExponent=0.2 //0.25
		DamageDelay=0.f
		MomentumTransferScale=-10000

		// Damage Effects
		MyDamageType=class'KFDT_Explosive_GravityImploder'
		KnockDownStrength=0
		FractureMeshRadius=200.0
		FracturePartVel=500.0

		ExplosionEffects=KFImpactEffectInfo'WEP_Gravity_Imploder_ARCH.Yellow_Explosion'
		ExplosionSound=AkEvent'WW_WEP_Gravity_Imploder.Play_WEP_Gravity_Imploder_Grenade_Yellow_Implosion'

        // Dynamic Light
        ExploLight=ExplosionPointLight
        ExploLightStartFadeOutTime=0.0
        ExploLightFadeOutTime=0.2

		// Camera Shake
		CamShake=CameraShake'FX_CameraShake_Arch.Misc_Explosions.Light_Explosion_Rumble'
		CamShakeInnerRadius=200
		CamShakeOuterRadius=900
		CamShakeFalloff=1.5f
		bOrientCameraShakeTowardsEpicenter=true
	End Object
	ExplosionTemplate=ImploTemplate0

	bIsTimedExplosive=false;
	DetonationTime=5.0

	VortexRadius=450
	VortexImpulseStrength=-100
	VortexDuration=0.5f
	bVortexActive=false
}
