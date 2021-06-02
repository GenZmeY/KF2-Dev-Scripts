//=============================================================================
// KFProj_Rocket_ThermiteBore
//=============================================================================
// Thermite Bore Rifle rocket launcher harpoon
//=============================================================================
// Killing Floor 2
// Copyright (C) 2012 Tripwire Interactive LLC
//=============================================================================
class KFProj_Rocket_ThermiteBore extends KFProjectile;

var float FuseTime;

/** This is the effect indicator that is played for the current user **/
var(Projectile) ParticleSystem ProjIndicatorTemplate;
var ParticleSystemComponent	ProjIndicatorEffects;

var bool IndicatorActive;

/**
    Fire effects
 */

var class<KFProjectile> ResidualFlameProjClass;

var int NumResidualFlames;

/** Cone Angle to determine residual flame directions */
var float ResidualFlameHalfConeAngle;
/** Impulse modiffier apply to residual forces*/
var float ResidualFlameForceMultiplier;

simulated function TryActivateIndicator()
{
	if(!IndicatorActive && Instigator != None)
	{
		IndicatorActive = true;

		if(WorldInfo.NetMode == NM_Standalone || Instigator.Role == Role_AutonomousProxy ||
		 (Instigator.Role == ROLE_Authority && WorldInfo.NetMode == NM_ListenServer && Instigator.IsLocallyControlled() ))
		{
			if( ProjIndicatorTemplate != None )
			{
			    ProjIndicatorEffects = WorldInfo.MyEmitterPool.SpawnEmitterCustomLifetime(ProjIndicatorTemplate);
			}

			if(ProjIndicatorEffects != None)
			{
				ProjIndicatorEffects.SetAbsolute(false, false, false);
				ProjIndicatorEffects.SetLODLevel(WorldInfo.bDropDetail ? 1 : 0);
				ProjIndicatorEffects.bUpdateComponentInTick = true;
				AttachComponent(ProjIndicatorEffects);
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

	if (Role == ROLE_Authority)
	{
	   SetTimer(FuseTime, false, 'Timer_Detonate');
	}

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
		SetTimer( 1.f + Rand(5) + fRand(), false, nameOf(Timer_Detonate) );
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

	StickHelper.Tick(DeltaTime);

	if (!IsZero(Velocity))
	{
		SetRelativeRotation(rotator(Velocity));
	}

	TryActivateIndicator();
}

/** Causes charge to explode */
function Detonate()
{
	local KFWeap_RocketLauncher_ThermiteBore WeaponOwner;
	local vector ExplosionNormal;

	if (Role == ROLE_Authority)
    {
    	WeaponOwner = KFWeap_RocketLauncher_ThermiteBore(Owner);
    	if (WeaponOwner != none)
    	{
    		WeaponOwner.RemoveDeployedHarpoon(, self);
    	}
    }

	ExplosionNormal = vect(0,0,1) >> Rotation;
	Explode(Location, ExplosionNormal);
}

simulated function Explode(vector HitLocation, vector HitNormal)
{
    local vector HitVelocity;
    
    HitVelocity = Velocity;

	StickHelper.UnPin();
	super.Explode(HitLocation, HitNormal);

    // Spawn fire projectiles
    if(Role < Role_Authority)
    {
        return;
    }

    SpawnResidualFlames(HitLocation, HitNormal, HitVelocity);
    SpawnResidualFlame(ResidualFlameProjClass, Location, HitVelocity);
}

simulated function Disintegrate( rotator InDisintegrateEffectRotation )
{
	local KFWeap_RocketLauncher_ThermiteBore WeaponOwner;

	if (Role == ROLE_Authority)
    {
    	WeaponOwner = KFWeap_RocketLauncher_ThermiteBore(Owner);
    	if (WeaponOwner != none)
    	{
    		WeaponOwner.RemoveDeployedHarpoon(, self);
    	}
    }

    super.Disintegrate(InDisintegrateEffectRotation);
}

// for nukes && concussive force
simulated protected function PrepareExplosionTemplate()
{
	class'KFPerk_Demolitionist'.static.PrepareExplosive(Instigator, self);

	super.PrepareExplosionTemplate();
}

simulated function SyncOriginalLocation()
{
	// IMPORTANT NOTE: We aren't actually syncing to the original location (or calling the super).
	// We just want to receive the original location so we can do a trace between that location and
	// our current location to determine if we hit any zeds between those two locations.
	// KFII-45464

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

simulated protected function StopSimulating()
{
	super.StopSimulating();

	if (ProjIndicatorEffects!=None)
	{
        ProjIndicatorEffects.DeactivateSystem();
	}
}

/** Spawn several projectiles that explode and linger on impact */
function SpawnResidualFlames( vector HitLocation, vector HitNormal, vector HitVelocity )
{
	local int i;
	local vector HitVelDir;
	local float HitVelMag;
	local vector SpawnLoc, SpawnVel;

	HitVelMag = VSize( HitVelocity );
	HitVelDir = Normal( HitVelocity );

	SpawnLoc = HitLocation + (HitNormal * 10.f);

	// spawn random lingering fires (rather, projectiles that cause little fires)
	for( i = 0; i < NumResidualFlames; ++i )
	{
		
		SpawnVel = CalculateResidualFlameVelocity( HitNormal, HitVelDir, HitVelMag );
		SpawnResidualFlame( ResidualFlameProjClass, SpawnLoc, SpawnVel );
	}
}

function vector CalculateResidualFlameVelocity( vector HitNormal, vector HitVelDir, float HitVelMag )
{
    local vector SpawnDir;

    // apply some spread
    SpawnDir = VRandCone( HitNormal, ResidualFlameHalfConeAngle * DegToRad );
/*
    // make HitVelDir parallel to contact surface by subtracting component parallel to HitNormal
    SpawnDir = SpawnDir + (-(SpawnDir dot HitNormal) * HitNormal);

    // apply some more spread to get some of the flames to stick to the wall and others the ground beneath the wall
    // (makes it looks kind of smeared down the wall, like a real molotov)
    SpawnDir = VRandCone( SpawnDir, PI/4 );
*/
    return SpawnDir * ResidualFlameForceMultiplier;
} 

defaultproperties
{
	ProjFlightTemplate=ParticleSystem'WEP_Thermite_EMIT.FX_Harpoon_Projectile'
	ProjIndicatorTemplate=ParticleSystem'WEP_Thermite_EMIT.FX_Harpoon_Projectile_Indicator'

	bWarnAIWhenFired=true

	MaxSpeed=5000.0 //4000.0
	Speed=5000.0 //4000.0
	TerminalVelocity=5000 //4000

	Physics=PHYS_Falling

	TossZ=0 //150
    GravityScale=0.36 //0.5//0.7

	GlassShatterType=FMGS_ShatterAll

	bCollideComplex=true

	bIgnoreFoliageTouch=true

	bBlockedByInstigator=false
	bAlwaysReplicateExplosion=true

	FuseTime=4.0

	bNetTemporary=false
	NetPriority=5
	NetUpdateFrequency=200

	bNoReplicationToInstigator=false
	bUseClientSideHitDetection=true
	bUpdateSimulatedPosition=true
	bSyncToOriginalLocation=true
	bSyncToThirdPersonMuzzleLocation=true

	PinBoneIdx=INDEX_None

	bCanBeDamaged=true
	bCanDisintegrate=true
	Begin Object Name=CollisionCylinder
		BlockNonZeroExtent=false
		// for siren scream
		CollideActors=true
	End Object

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
	Begin Object Class=KFGameExplosion Name=ExploTemplate0 // @todo: change me
		Damage=150 //250
	    DamageRadius=500 //600
		DamageFalloffExponent=1.f
		DamageDelay=0.f

		// Damage Effects
		MyDamageType=class'KFDT_Explosive_Thermite'
		KnockDownStrength=0
		FractureMeshRadius=200.0
		FracturePartVel=500.0
		ExplosionEffects=KFImpactEffectInfo'WEP_Thermite_ARCH.ThermiteHarpoon_Explosion'
		ExplosionSound=AkEvent'WW_WEP_SealSqueal.Play_WEP_SealSqueal_Shoot_Explode'

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

	bCanStick=true
	bCanPin=true
	Begin Object Class=KFProjectileStickHelper Name=StickHelper0
	End Object
	StickHelper=StickHelper0

	ProjDisintegrateTemplate=ParticleSystem'ZED_Siren_EMIT.FX_Siren_grenade_disable_01'

    ResidualFlameProjClass=class'KFProj_ThermiteSplash'
	NumResidualFlames=4 //it always spawn 1 more than this parameter, so 5

	ResidualFlameHalfConeAngle=72
	ResidualFlameForceMultiplier=700f; //1000f; 

}