//=============================================================================
// KFProj_Bolt_HRG_Crossboom
//=============================================================================
// Bullet class for the HRG Crossboom
//=============================================================================
// Killing Floor 2
// Copyright (C) 2022 Tripwire Interactive LLC
//=============================================================================

class KFProj_Bolt_HRG_CrossboomAlt extends KFProjectile;

var() float SecondsBeforeDetonation;
var() bool bIsProjActive;
/**
 * Set the initial velocity and cook time
 */
simulated event PostBeginPlay()
{
	Super.PostBeginPlay();

	AdjustCanDisintigrate();
}

/**
 * Explode after a certain amount of time
 */
function Timer_Detonate()
{
	Detonate();
}

/** Called when the owning instigator controller has left a game */
simulated function OnInstigatorControllerLeft()
{
	if( WorldInfo.NetMode != NM_Client )
	{
		SetTimer( 1.f + Rand(5) + fRand(), false, nameOf(Destroy) );
	}
}

/**
 * Trace down and get the location to spawn the explosion effects and decal
 */
simulated function GetExplodeEffectLocation(out vector HitLocation, out vector HitRotation, out Actor HitActor)
{
    local vector EffectStartTrace, EffectEndTrace;
	local TraceHitInfo HitInfo;

	EffectStartTrace = Location + vect(0,0,1) * 4.f;
	EffectEndTrace = EffectStartTrace - vect(0,0,1) * 32.f;

    // Find where to put the decal
	HitActor = Trace(HitLocation, HitRotation, EffectEndTrace, EffectStartTrace, false,, HitInfo, TRACEFLAG_Bullet);

	// If the locations are zero (probably because this exploded in the air) set defaults
    if (IsZero(HitLocation))
    {
        HitLocation = Location;
    }

	if (IsZero(HitRotation))
    {
        HitRotation = vect(0,0,1);
    }
}

/** Used to check current status of StuckTo actor (to figure out if we should fall) */
simulated event Tick(float DeltaTime)
{
	super.Tick(DeltaTime);

    if (bIsProjActive)
    {
	    StickHelper.Tick(DeltaTime);
    }

	if (!IsZero(Velocity))
	{
		SetRelativeRotation(rotator(Velocity));
	}
}

/** Causes charge to explode */
function Detonate()
{
	local vector ExplosionNormal;

	ExplosionNormal = vect(0,0,1) >> Rotation;
	Explode(Location, ExplosionNormal);
}

simulated function Explode(vector HitLocation, vector HitNormal)
{   
    if (bIsProjActive)
    {
	    StickHelper.UnPin();
	    super.Explode(HitLocation, HitNormal);
    }
}

// for nukes && concussive force
simulated protected function PrepareExplosionTemplate()
{
	class'KFPerk_Demolitionist'.static.PrepareExplosive(Instigator, self);

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

simulated function SyncOriginalLocation()
{
	local Actor HitActor;
	local vector HitLocation, HitNormal;
	local TraceHitInfo HitInfo;

	if (Role < ROLE_Authority && Instigator != none && Instigator.IsLocallyControlled())
	{
		HitActor = Trace(HitLocation, HitNormal, OriginalLocation, Location,,, HitInfo, TRACEFLAG_Bullet);
		if (HitActor != none)
		{
			StickHelper.TryStick(HitNormal, HitLocation, HitActor);
		}
	}
}

simulated function NotifyStick()
{
    SetTimer(SecondsBeforeDetonation, false, nameof(Timer_Detonate));
}

simulated function NotifyBounce()
{
    ClearTimer(nameof(Timer_Detonate), self);
    ClearTimer(nameOf(Destroy));
    bIsProjActive=false;
}

unreliable server function OnCollectibleHit(Actor Collectible)
{
	Collectible.TakeDamage(Damage, InstigatorController, Location, MomentumTransfer * Normal(Velocity), MyDamageType,, Owner);
}

defaultproperties
{
	bWarnAIWhenFired=true

	MaxSpeed=15000.0
	Speed=15000.0

	DamageRadius=0

	ProjFlightTemplate=ParticleSystem'WEP_HRG_Crossboom_EMIT.FX_ALTFIRE_Crossboom_Projectile'
	ProjDisintegrateTemplate=ParticleSystem'ZED_Siren_EMIT.FX_Siren_grenade_disable_01'

    LifeSpan=20

    bBlockedByInstigator=false
    bCollideActors=true
    bCollideComplex=true
    bNoEncroachCheck=true
	bNoReplicationToInstigator=false
	bUseClientSideHitDetection=true
	bUpdateSimulatedPosition=false
	bRotationFollowsVelocity=false
	bNetTemporary=false
    bSyncToOriginalLocation=true

	ImpactEffects=KFImpactEffectInfo'FX_Impacts_ARCH.Crossbow_impact'

    AmbientSoundPlayEvent=AkEvent'WW_WEP_HRG_Crossboom.Play_WEP_HRG_Crossboom_Bolt_Fly_By'
    AmbientSoundStopEvent=AkEvent'WW_WEP_HRG_Crossboom.Stop_WEP_HRG_Crossboom_Bolt_Fly_By'

	// explosion light
	Begin Object Class=PointLightComponent Name=ExplosionPointLight
	    LightColor=(R=252,G=218,B=171,A=255)
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

	// explosion
	Begin Object Class=KFGameExplosion Name=ExploTemplate0
		Damage=100
	    DamageRadius=800
		DamageFalloffExponent=0.5f
		DamageDelay=0.f

		// Damage Effects
		MyDamageType=class'KFDT_Explosive_HRG_CrossboomAlt'
		KnockDownStrength=0
		FractureMeshRadius=200.0
		FracturePartVel=500.0
		ExplosionEffects=KFImpactEffectInfo'WEP_HRG_Crossboom_ARCH.Wep_ALTFIRE_HRG_Crossboom_Explosion'
		ExplosionSound=AkEvent'WW_WEP_HRG_Crossboom.Play_WEP_HRG_Crossboom_Impact_Explosion_Alt_Fire'

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
	ExplosionTemplate=ExploTemplate0

	ExplosionActorClass=class'KFExplosionActor'

	//PinBoneIdx=INDEX_None
    bCanStick=true
	bCanPin=false
	Begin Object Class=KFProjectileStickHelper_HRG_Crossboom Name=StickHelper0
		bAltFire=true
	End Object
	StickHelper=StickHelper0

    SecondsBeforeDetonation=0.5f
    bIsProjActive=true
	bCanDisintegrate=true
	bAlwaysReplicateExplosion=true
}
