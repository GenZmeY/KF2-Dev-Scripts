//=============================================================================
// KFProj_Grenade_CranialPopper
//=============================================================================
// Killing Floor 2
// Copyright (C) 2020 Tripwire Interactive LLC
//=============================================================================

class KFProj_Grenade_HRG_CranialPopper extends KFProj_BallisticExplosive
	hidedropdown;

/* Ensure it detonates */
var float WaveDuration;
var float WaveRadius;
var float WaveRadiusMax;
var float WaveTime;
var protected transient bool bWaveActive;
var array<Actor> VictimsList;
var vector WaveImpactMomentum;

var GameExplosion VFXExplosionTemplate;

state WaveState
{
	simulated event BeginState(Name PrevStateName)
	{
		super.BeginState(PrevStateName);
		
		bWaveActive = true;

		if (Role == ROLE_Authority)
		{
			SetTimer(WaveDuration, false, 'Timer_EndWave');
		}
	}

	simulated event Tick(float DeltaTime)
	{
		local KFPawn_Monster Victim;
		local TraceHitInfo   HitInfo;
		local float Radius;
		local float DamageHead;

		if(bWaveActive)
		{
			WaveTime += DeltaTime;
			Radius = Lerp(WaveRadius, WaveRadiusMax, WaveTime / WaveDuration);
			// DrawDebugSphere(Location, Radius, 100, 255, 255, 0, false);
			foreach CollidingActors(class'KFPawn_Monster', Victim, Radius, Location, true,, HitInfo)
			{
				if (Victim != none && Victim.CollisionComponent != none && VictimsList.Find(Victim) == INDEX_NONE)
				{
					VictimsList[VictimsList.Length] = Victim;
					DamageHead = Victim.AfflictionHandler.GetBigHeadAfflictionDamageModifier();
					if(DamageHead > 0)
					{
						//`Log("Take: "$Victim);
						//HitInfo.BoneName = 'head';
						Victim.TakeDamage(DamageHead * UpgradeDamageMod, InstigatorController, Victim.Location, Normal(Victim.Location - Instigator.Location), MyDamageType, HitInfo, (Owner != None) ? Owner : self);
						//Monster.PlayDismemberment(0, MyDamageType, WaveImpactMomentum);

						if (Victim.Health <= 0)
						{
							MakeHeadExplode(Victim);
						}
					}
				}
			}
		}
	}
}

/**
 * Set the initial velocity and cook time
 */
function Init(vector Direction)
{
	Super.Init(Direction);

	if ( Instigator.Role < ROLE_Authority )
	{
		return;
	}

	GotoState('WaveState');
	TriggerVFXExplosion();
}

simulated function TriggerVFXExplosion()
{
	local KFExplosionActorReplicated ExploActor;
	local float ModifiedDamage, OriginalDamage, OriginalDamageRadius;

	if (VFXExplosionTemplate != none)
	{
		// explode using the given template
		ExploActor = Spawn(class'KFExplosionActorReplicated', self,, Location, Rotation,, true);
		if (ExploActor != None)
		{
			ExploActor.InstigatorController = Instigator.Controller;
			ExploActor.Instigator = Instigator;

			// enable muzzle location sync
			ExploActor.bReplicateInstigator = true;
			ExploActor.bSyncParticlesToMuzzle = true;

			ModifiedDamage = 0;

			OriginalDamage = VFXExplosionTemplate.Damage;
			OriginalDamageRadius = VFXExplosionTemplate.DamageRadius;

			VFXExplosionTemplate.Damage *= ModifiedDamage;
			VFXExplosionTemplate.DamageRadius *= ModifiedDamage;

			ExploActor.Explode(VFXExplosionTemplate);

			VFXExplosionTemplate.Damage = OriginalDamage;
			VFXExplosionTemplate.DamageRadius = OriginalDamageRadius;
		}
	}
}

simulated function Explode(vector HitLocation, vector HitNormal)
{
}

simulated function Timer_EndWave()
{
	bWaveActive = false;
	DeferredDestroy(0.15);
}

simulated function MakeHeadExplode(KFPawn_Monster Victim)
{
	local KFPlayerController KFPC;

	if (Victim == none) return;

	// Notify all Clients to explode the monster head.
	foreach WorldInfo.AllControllers( class'KFPlayerController', KFPC )
	{
		if (KFPC != none)
		{
			KFPC.ForceMonsterHeadExplode(Victim);
		}
	}
}

defaultproperties
{
	TouchTimeThreshhold = 60.0f
	Physics=PHYS_Falling
	Speed=0
	MaxSpeed=0
	TerminalVelocity=0
	GravityScale=0.0
    LifeSpan=0.f
	bWarnAIWhenFired=true

	ProjFlightTemplate=none
	ProjFlightTemplateZedTime=none
    ProjDisintegrateTemplate=none

	bIsTimedExplosive=false;

	WaveImpactMomentum=(X=0,Y=0,Z=0)
	
	WaveTime=0.0f
	WaveDuration=2.0f
	WaveRadius=10
	WaveRadiusMax=15000 // 750
	bWaveActive=false

	// Grenade explosion light
	Begin Object Class=PointLightComponent Name=ExplosionPointLight
	    LightColor=(R=252,G=218,B=171,A=255)
		Brightness=0.5f
		Radius=400.f
		FalloffExponent=10.f
		CastShadows=False
		CastStaticShadows=FALSE
		CastDynamicShadows=False
		bCastPerObjectShadows=false
		bEnabled=FALSE
		LightingChannels=(Indoor=TRUE,Outdoor=TRUE,bInitialized=TRUE)
	End Object

	// explosion
	Begin Object Class=KFGameExplosion Name=ExploTemplate0
		Damage=0
		DamageRadius=2.0f
		DamageFalloffExponent=1.f
		DamageDelay=0.f
		MomentumTransferScale=0

		// Damage Effects
		MyDamageType=Class'KFDT_Blast_HRG_CranialPopper'
		KnockDownStrength=0
		FractureMeshRadius=0.0
		FracturePartVel=0.0
		
		ExplosionSound=AkEvent'WW_WEP_HRG_CranialPopper.Play_WEP_HRG_CranialPopper_AltFire_3P'
		//ExplosionEffects=KFImpactEffectInfo'WEP_HRG_Boomy_ARCH.WEB_HRG_Boomy_Impacts'
		ParticleEmitterTemplate=ParticleSystem'WEP_HRG_CranialPopper_EMIT.PS_Expansion_Wave'

        // Dynamic Light
        ExploLight=ExplosionPointLight
        ExploLightStartFadeOutTime=0.0
        ExploLightFadeOutTime=0.3

		bIgnoreInstigator=true

		// Camera Shake
		CamShake=CameraShake'FX_CameraShake_Arch.Misc_Explosions.Light_Explosion_Rumble'
		CamShakeInnerRadius=0
		CamShakeOuterRadius=300
		CamShakeFalloff=1.5f
		bOrientCameraShakeTowardsEpicenter=true
	End Object

	VFXExplosionTemplate=ExploTemplate0
}
