//=============================================================================
// KFProj_Missile_Patriarch
//=============================================================================
// High explosive missile fired from Patriarch weapons platform.
// Based on flocking code from UT3
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//=============================================================================
class KFProj_Missile_Patriarch extends KFProjectile
	hidedropdown;

/** Used for the curling missile effect */
var KFProj_Missile_Patriarch Flock[2];

var float InitialSpeed;

var float FlockRadius;
var float FlockStiffness;
var float FlockMaxForce;
var float FlockCurlForce;

var repnotify byte bCurl;
var float VelocityScale;

var vector Dir;

/** Applies wobble to the missile, making it seem erratic. Simulates real liquid state thrusters */
var bool bWobble;
var float WobbleForce;

/** How long to wait after spawning before starting to seek */
var float SeekDelay;

/** How strong a force should be applied to the missile when seeking */
var float SeekForce;

/** Gravity application */
var float GravForce;
var float DistToApplyGravitySQ;

/** Target impact location for seeking */
var vector TargetImpactLoc;

/** Flight light */
var PointLightComponent FlightLight;

replication
{
	if ( bNetInitial && (Role == ROLE_Authority) )
		bCurl, FlockCurlForce, VelocityScale, TargetImpactLoc,
		SeekDelay, SeekForce, GravForce, DistToApplyGravitySQ, InitialSpeed;
}

simulated protected function PrepareExplosionTemplate()
{
	super.PrepareExplosionTemplate();
	
	/** Since bIgnoreInstigator is transient, its value must be defined here */
	ExplosionTemplate.bIgnoreInstigator = true;
}

function InitEx( vector AimDir, float CurlForceMultiplier, vector TargetLoc, float InitialMissileSpeed,
				float NewSeekDelay, float NewSeekForce, float NewGravForce, float NewDistToApplyGravitySQ )
{
	Init( AimDir );

	// Our base speed
	InitialSpeed = InitialMissileSpeed;
	Speed = InitialSpeed;

	// Do some randomization for an even cooler effect
	FlockCurlForce = (default.FlockCurlForce * (0.95f + (fRand()*0.1f))) * CurlForceMultiplier;
	VelocityScale = 0.95f + (fRand()*0.1f);

	// Our impact target location
	TargetImpactLoc = TargetLoc;

	// Set our seek delay
	SeekDelay = NewSeekDelay;

	// Set our seek force
	SeekForce = NewSeekForce;

	// Set our gravity force
	GravForce = NewGravForce;

	// Set our distance before we apply gravity
	DistToApplyGravitySQ = NewDistToApplyGravitySQ;
}

simulated function StartCurlTimer()
{
	SetTimer( 0.06f, true, nameOf(CurlTimer) );
}

simulated event ReplicatedEvent(name VarName)
{
	local KFProj_Missile_Patriarch R;
	local int i;

	if( VarName == 'bCurl' )
	{
		StartCurlTimer();

		// look for other missiles
		if( bCurl < 3 && Flock[1] == None )
		{
			foreach DynamicActors( class'KFProj_Missile_Patriarch', R )
			{
				if( R.Instigator == Instigator )
				{
					Flock[i] = R;
					if ( R.Flock[0] == None )
					{
						R.Flock[0] = self;
					}
					else if ( R.Flock[0] != self )
					{
						R.Flock[1] = self;
					}

					i++;
					if ( i == 2 )
					{
						break;
					}
				}
			}
		}
	}
	else
	{
		Super.ReplicatedEvent(VarName);
	}
}

simulated event Tick( float DeltaTime )
{
	super.Tick( DeltaTime );

	if( FlightLight != none && WorldInfo.NetMode != NM_DedicatedServer )
	{
		FlightLight.Radius = 120.f + FlightLight.default.Radius * Abs( Cos(WorldInfo.TimeSeconds * (DeltaTime * 800.f)) );
	}

	// Finalize rotation
	SetRotation( rotator(Velocity) );	
}

simulated function CurlTimer()
{
	local vector TargetVec, SeekDir, X,Y,Z;

	// Initialize Dir, if necessary
	if( SeekForce > 0.f )
	{
		if( bCurl == 3 || IsZero(Dir) )
		{
			Dir = Normal(Velocity);
		}

		if( bCurl < 3 )
		{
			Velocity = (InitialSpeed * Normal(Dir * 0.5 * InitialSpeed + Velocity)) * VelocityScale;
		}

		TargetVec = TargetImpactLoc - Location;

		// Add seeking
		if( `TimeSince(CreationTime) >= SeekDelay )
		{
			SeekDir = Normal(TargetVec);
			if( GravForce > 0.f )
			{
				SeekDir.Z = 0.f;
			}

			Velocity += SeekDir * SeekForce;

			// Apply pseudo-gravity
			if( GravForce > 0.f && TargetVec.Z < Location.Z )
			{
				TargetVec.Z = 0.f;
				if( VSizeSQ(TargetVec) <= DistToApplyGravitySQ )
				{
					Velocity += vect(0,0,-1) * GravForce;
				}
				else
				{
					Velocity += vect(0,0,-1) * GravForce * 0.1f;
				}
			}
		}

		if( bCurl < 3 )
		{
			DoFlocking();
		}

		// Update our rotation before adding wobble
		SetRotation( rotator(Velocity) );
	}

	// Add some crazy wobble
	GetAxes( Rotation, X,Y,Z );
	Velocity += (bWobble ? Z * WobbleForce : -Z * WobbleForce)
				+ (bWobble ? Y * WobbleForce : -Y * WobbleForce);

	bWobble = !bWobble;
}

simulated function DoFlocking()
{
	local int i;
	local vector ForceDir, CurlDir;
	local float ForceMag;

	// Curl missiles around each other
	for( i = 0; i < 2; i++ )
	{
		if( Flock[i] == None )
			continue;

		// Attract if distance between missiles is over 2*FlockRadius, repulse if below.
		ForceDir = Flock[i].Location - Location;
		ForceMag = FlockStiffness * ( (2 * FlockRadius) - VSize(ForceDir) );
		Acceleration = Normal(ForceDir) * Min(ForceMag, FlockMaxForce*VelocityScale);

		// Vector 'curl'
		CurlDir = Flock[i].Velocity Cross ForceDir;
		if( bCurl == Flock[i].bCurl )
			Acceleration += Normal(CurlDir) * FlockCurlForce;
		else
			Acceleration -= Normal(CurlDir) * FlockCurlForce;
	}
}

/** Overloaded to apply direct damage on hit */
simulated function bool TraceProjHitZones(Pawn P, vector EndTrace, vector StartTrace, out array<ImpactInfo> out_Hits)
{
	if( P != none )
	{
		P.TakeDamage( Damage, InstigatorController, StartTrace, MomentumTransfer * Normal(Velocity), MyDamageType,, self );
		return true;
	}

	return false;
}

/** Stops projectile simulation without destroying it.  Projectile is resting, essentially. */
simulated protected function StopSimulating()
{
	super.StopSimulating();

	FlightLight.SetEnabled( false );
	DetachComponent( FlightLight );
	FlightLight = none;
}

simulated function Destroyed()
{
	ClearTimer( nameOf(CurlTimer) );

	super.Destroyed();
}

defaultproperties
{
	Physics=PHYS_Projectile
	// Speeds below are overridden by KFPawn_ZedHusk FireballSpeed property
	Speed=2000
	MaxSpeed=2000
	ProjFlightTemplate=ParticleSystem'ZED_Patriarch_EMIT.FX_Patriarch_Rocket_Projectile'
	ExplosionActorClass=class'KFExplosionActor'

	FlockRadius=10.f
	FlockStiffness=-20.f
	FlockMaxForce=700.f
	FlockCurlForce=3600.f
	WobbleForce=120.f
	SeekForce=10.f
	RotationRate=(Roll=50000)

	Damage=200
	MyDamageType=class'KFDT_Explosive_PatMissile'
	MomentumTransfer=1000.f

	// CollideActors=true allows detection via OverlappingActors or CollidingActors (for Siren scream)
	Begin Object Name=CollisionCylinder
		CollisionRadius=5.f
		CollisionHeight=5.f
		BlockNonZeroExtent=false
		CollideActors=true
	End Object

	// Flight light
	Begin Object Class=PointLightComponent Name=FlightPointLight
	    LightColor=(R=255,G=205,B=150,A=255)
		Brightness=1.5f
		Radius=120.f
		FalloffExponent=10.f
		CastShadows=false
		CastStaticShadows=false
		CastDynamicShadows=false
		bCastPerObjectShadows=false
		bEnabled=true
		LightingChannels=(Indoor=TRUE,Outdoor=TRUE,bInitialized=TRUE)
	End Object
	FlightLight=FlightPointLight
	Components.Add(FlightPointLight)

	// Grenade explosion light
	Begin Object Class=PointLightComponent Name=ExplosionPointLight
	    LightColor=(R=245,G=190,B=140,A=255)
		Brightness=4.f
		Radius=1400.f
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
		Damage=70
		DamageRadius=650
		DamageFalloffExponent=2.f
		DamageDelay=0.f

		// Damage Effects
		MyDamageType=class'KFDT_Explosive_PatMissile'
		KnockDownStrength=100
		FractureMeshRadius=200.0
		FracturePartVel=500.0
		ExplosionEffects=KFImpactEffectInfo'WEP_Patriarch_ARCH.Missile_Explosion'
		ExplosionSound=AkEvent'WW_WEP_SA_RPG7.Play_WEP_SA_RPG7_Explosion'

        // Dynamic Light
        ExploLight=ExplosionPointLight
        ExploLightStartFadeOutTime=0.0
        ExploLightFadeOutTime=0.5

		// Camera Shake
		CamShake=CameraShake'FX_CameraShake_Arch.Grenades.Default_Grenade'
		CamShakeInnerRadius=200
		CamShakeOuterRadius=700
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

	bAutoStartAmbientSound=true
	bStopAmbientSoundOnExplode=true
	AmbientSoundPlayEvent=AkEvent'WW_ZED_Patriarch.Play_Mini_Rocket_Trail_1'
    //AmbientSoundStopEvent=AkEvent'WW_ZED_Husk.ZED_Husk_SFX_Ranged_Shot_LP_Stop'
}