//=============================================================================
// KFProj_HRG_BallisticBouncer
//=============================================================================
// Projectile class for HRG Ballistic Bouncer
//=============================================================================
// Killing Floor 2
// Copyright (C) 2022 Tripwire Interactive LLC
//=============================================================================
class KFProj_HRG_BallisticBouncer extends KFProjectile;

/** Dampen amount for every bounce */
var float DampenFactor;

/** Dampen amount for parallel angle to velocity */
var float DampenFactorParallel;

/** Sound mine makes when it hits something and bounces off */
var AkEvent BounceAkEvent;

/** Sound mine makes when it hits something and comes to rest */
var AkEvent ImpactAkEvent;

/** Sound mine makes when it hits something and bounces off */
var AkEvent BounceAkEventHeavy;

/** Sound mine makes when it hits something and comes to rest */
var AkEvent ImpactAkEventHeavy;

/** Particle System spawned when it hits something */
var ParticleSystem HitFXTemplate;
var transient ParticleSystemComponent HitPSC;

/** Particle System for the fade out burst **/
var ParticleSystem BurstFXTemplate;
var transient ParticleSystemComponent BurstPSC;

/** Sound for the fade out burst **/
var AkEvent BurstAkEvent;

/** Decal settings */
var MaterialInterface ImpactDecalMaterial;
var float ImpactDecalWidth;
var float ImpactDecalHeight;
var float ImpactDecalThickness;

var int MaxBounces;
var int NumBounces;

var float MaxInitialSpeedByCharge;
var float MinInitialSpeedByCharge;

var float MaxCollisionRadius;
var float MinCollisionRadius;
var float MaxCollisionHeight;
var float MinCollisionHeight;

var float MaxScalePerPercentage;
var float MinScalePerPercentage;

var int MaxBouncesPerPercentage;
var int MinBouncesPerPercentage;

var float MaxLifeSpanPerPercentage;
var float MinLifeSpanPerPercentage;

var float InheritedScale;

var repnotify float fChargePercentage;

var float fCachedCylinderWidth, fCachedCylinderHeight;

var float ArmDistSquared;

var bool bFadingOut;
var float FadeOutTime;

var transient byte RequiredImpactsForSeasonal;
var transient array<Pawn> ImpactVictims;

replication
{
	if( bNetDirty )
		InheritedScale, fChargePercentage, MaxBounces;
}

simulated event ReplicatedEvent( name VarName )
{
	if( VarName == nameOf(fChargePercentage))
	{
		fCachedCylinderWidth = Lerp(MinCollisionRadius, MaxCollisionRadius, fChargePercentage);
		fCachedCylinderHeight = Lerp(MinCollisionHeight, MaxCollisionHeight, fChargePercentage);
		// CylinderComponent(CollisionComponent).SetCylinderSize(fCachedCylinderWidth, fCachedCylinderHeight);
        SetCollisionSize(fCachedCylinderWidth, fCachedCylinderHeight);
		ApplyVFXParams(fChargePercentage);
	}
	else
	{
		super.ReplicatedEvent( VarName );
	}
}

simulated event PostBeginPlay()
{
	Super.PostBeginPlay();
	RequiredImpactsForSeasonal = class'KFSeasonalEventStats_Xmas2022'.static.GetMaxBallisticBouncerImpacts();
}

simulated function SetInheritedScale(float Scale, float ChargePercentage)
{
	local float NewSpeed;

	InheritedScale = Scale;

	fChargePercentage = ChargePercentage;
	fChargePercentage = FMax(0.1, fChargePercentage);

	if (WorldInfo.NetMode == NM_DedicatedServer)
	{
		SetCollisionSize(Lerp(MinCollisionRadius, MaxCollisionRadius, fChargePercentage), Lerp(MinCollisionHeight, MaxCollisionHeight, ChargePercentage));
	}	
   
    NewSpeed = Lerp(MinInitialSpeedByCharge, MaxInitialSpeedByCharge, fChargePercentage);
	Velocity = Normal(Velocity) * NewSpeed;
	Speed = NewSpeed;

	MaxBounces = Lerp(MinBouncesPerPercentage, MaxBouncesPerPercentage, fChargePercentage);

	LifeSpan = Lerp(MinLifeSpanPerPercentage, MaxLifeSpanPerPercentage, fChargePercentage);

	if (ProjEffects != none)
	{
		ProjEffects.SetScale(Lerp(MinScalePerPercentage, MaxScalePerPercentage, fChargePercentage));
	}

	if (WorldInfo.NetMode != NM_DedicatedServer)
	{
		ApplyVFXParams(fChargePercentage);
	}

	bNetDirty=true;
}

function RestoreCylinder()
{
	CylinderComponent(CollisionComponent).SetCylinderSize(fCachedCylinderWidth, fCachedCylinderHeight);
}

simulated function BounceNoCheckRepeatingTouch(vector HitNormal, Actor BouncedOff)
{
	local vector VNorm;

    // Reflect off BouncedOff w/damping
    VNorm = (Velocity dot HitNormal) * HitNormal;
	
	if (NumBounces < MaxBounces)
	{
		Velocity = -VNorm + (Velocity - VNorm);
	}
	else
	{
		Velocity = -VNorm * DampenFactor + (Velocity - VNorm) * DampenFactorParallel;
	}

    Speed = VSize(Velocity);

	// Play a sound
	PlayImpactSound();

	// Spawn impact particle system, server needs to send the message (it's the only one storing MaxBounces)
	if (WorldInfo.NetMode != NM_DedicatedServer)
	{
		if (NumBounces < MaxBounces)
		{
			PlayImpactVFX(HitNormal);
		}

		`ImpactEffectManager.PlayImpactEffects(Location, Instigator, VNorm, ImpactEffects);
	}

	++NumBounces;
}

/** Adjusts movement/physics of projectile.
  * Returns true if projectile actually bounced / was allowed to bounce */
simulated function bool Bounce( vector HitNormal, Actor BouncedOff )
{
	// Avoid crazy bouncing
	if (CheckRepeatingTouch(BouncedOff))
	{
		CylinderComponent(CollisionComponent).SetCylinderSize(1,1);
		SetTimer(0.06f, false, nameof(RestoreCylinder));
		return false;
	}

	BounceNoCheckRepeatingTouch(HitNormal, BouncedOff);

	return true;
}

/** Plays a sound on impact */
simulated function PlayImpactSound( optional bool bIsAtRest )
{
	if( WorldInfo.NetMode != NM_DedicatedServer )
	{
		if( bIsAtRest )
		{
			if(fChargePercentage < 0.75f)
				PostAkEvent( ImpactAkEvent, true, true, false );
			else
				PostAkEvent( ImpactAkEventHeavy, true, true, false );
		}
		else
		{
			if(fChargePercentage < 0.75f)
				PostAkEvent( BounceAkEvent, true, true, false );
			else
				PostAkEvent( BounceAkEventHeavy, true, true, false );
		}
	}
}

simulated function PlayImpactVFX(vector HitNormal)
{
	HitPSC = WorldInfo.MyEmitterPool.SpawnEmitter(HitFXTemplate, ProjEffects.GetPosition(), rotator(HitNormal));
	HitPSC.SetFloatParameter(name("Charge"), fChargePercentage);
}

simulated function ProcessTouch(Actor Other, Vector HitLocation, Vector HitNormal)
{
	local float TraveledDistance;
	
	TraveledDistance = (`TimeSince(CreationTime) * Speed);
	TraveledDistance *= TraveledDistance;
	
	// If we collided with a Siren shield, let the shield code handle touches
    if( Other.IsA('KFTrigger_SirenProjectileShield') )
    {
        return;
    }

	if (Other != Instigator && Other.GetTeamNum() != GetTeamNum())
	{
		// check/ignore repeat touch events
		if (!CheckRepeatingTouch(Other))
		{
			ProcessBulletTouch(Other, HitLocation, HitNormal);
		}
	}
}
	
simulated function ProcessBulletTouch(Actor Other, Vector HitLocation, Vector HitNormal)
{
	local Pawn Victim;
	local array<ImpactInfo> HitZoneImpactList;
	//local ImpactInfo ImpactInfoFallBack;
	local vector StartTrace, EndTrace, Direction; //, DirectionFallBack;
	local TraceHitInfo HitInfo;
    local KFWeapon KFW;

    Victim = Pawn( Other );
	if ( Victim == none )
	{
		if ( bDamageDestructiblesOnTouch && Other.bCanBeDamaged )
		{
			HitInfo.HitComponent = LastTouchComponent;
			HitInfo.Item = INDEX_None;	// force TraceComponent on fractured meshes
			Other.TakeDamage(Damage, InstigatorController, Location, MomentumTransfer * Normal(Velocity), MyDamageType, HitInfo, self);
		}

		// Reduce the penetration power to zero if we hit something other than a pawn or foliage actor
		if( InteractiveFoliageActor(Other) == None )
		{
			PenetrationPower = 0;

			BounceNoCheckRepeatingTouch(HitNormal, Other);

    		return;
		}
	}
    else
    {
		if (bSpawnShrapnel)
		{
			//spawn straight forward through the zed
			SpawnShrapnel(Other, HitLocation, HitNormal, rotator(Velocity), ShrapnelSpreadWidthZed, ShrapnelSpreadHeightZed);
		}

		StartTrace = HitLocation;
		Direction = Normal(Velocity);
		EndTrace = StartTrace + Direction * (Victim.CylinderComponent.CollisionRadius * 6.0);

		TraceProjHitZones(Victim, EndTrace, StartTrace, HitZoneImpactList);

		//`Log("HitZoneImpactList: " $HitZoneImpactList.Length);

		if ( HitZoneImpactList.length > 0 )
		{
            HitZoneImpactList[0].RayDir	= Direction;

			if( Owner != none )
			{
                KFW = KFWeapon( Owner );
                if( KFW != none )
                {
                    KFW.HandleProjectileImpact(WeaponFireMode, HitZoneImpactList[0], PenetrationPower);
                }
			}

			IncrementNumImpacts(Victim);

			BounceNoCheckRepeatingTouch(HitNormal, Other);
		}
	}
}

simulated function IncrementNumImpacts(Pawn Victim)
{
	local int i;
	local KFPlayerController KFPC;

	if (WorldInfo.NetMode == NM_Client)
	{
		return;
	}

	KFPC = KFPlayerController(InstigatorController);

	if (KFPC == none)
	{
		return;
	}

	for (i = 0; i < ImpactVictims.Length; ++i)
	{
		if (Victim == ImpactVictims[i])
		{
			return;
		}
	}

	ImpactVictims.AddItem(Victim);

	UpdateImpactsSeasonalObjective(KFPC);
}

function UpdateImpactsSeasonalObjective(KFPlayerController KFPC)
{
	local byte ObjectiveIndex;

	ObjectiveIndex = 3;

	if (ImpactVictims.Length >= RequiredImpactsForSeasonal)
	{
		// Check parent controller.
		KFPC.ClientOnTryCompleteObjective(ObjectiveIndex, SEI_Winter);
	}
}

simulated event HitWall( vector HitNormal, Actor Wall, PrimitiveComponent WallComp )
{
	// Don't collide with other projectiles
	if( Wall.class == class )
	{
		return;
	}

	Bounce( HitNormal, Wall );
}

simulated function SpawnBurstFX()
{
	local vector vec;

	if( WorldInfo.NetMode == NM_DedicatedServer || WorldInfo.MyEmitterPool == none || ProjEffects == none )
	{
		return;
	}

	BurstPSC = WorldInfo.MyEmitterPool.SpawnEmitter(BurstFXTemplate, ProjEffects.GetPosition(), rotator(vect(0,0,1)), self, , ,true);

	vec.X = fChargePercentage;
	vec.Y = fChargePercentage;
	vec.Z = fChargePercentage;

	BurstPSC.SetVectorParameter(name("BlobCharge"), vec);
	BurstPSC.SetFloatParameter(name("MineFxControlParam"), fChargePercentage);
	
	PostAkEvent(BurstAkEvent, true, true, false);
}

simulated function Tick(float Delta)
{
	if (NumBounces < MaxBounces || bFadingOut)
		return;

	if (Speed < 20.0f)
	{
		bFadingOut = true;
		StopSimulating();

		SpawnBurstFX();

		// Tell clients to tear off and fade out on their own
		if( WorldInfo.NetMode != NM_Client )
		{
			ClearTimer(nameof(Timer_Destroy));

			SetTimer( 1.0f, false, nameOf(Timer_Destroy) );
		}
	}
}

simulated function Timer_Destroy()
{
	if (BurstPSC != none)
	{
		BurstPSC.DeactivateSystem();
	}

	Destroy();
}

simulated function ApplyVFXParams(float ChargePercent)
{
	if (ProjEffects != none)
	{
		ProjEffects.SetFloatParameter(name("InflateBlob"), ChargePercent);
	}
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
			ProcessBulletTouch(HitActor, HitLocation, HitNormal);
		}
	}

    Super.SyncOriginalLocation();
}


defaultproperties
{
    TerminalVelocity=5000
    TossZ=150
    GravityScale=0.5
    MomentumTransfer=50000.0

	LifeSpan=300
	PostExplosionLifetime=1
	Physics=PHYS_Falling
	bBounce=true

	ProjFlightTemplate= ParticleSystem'WEP_HRG_BallisticBouncer_EMIT.FX_HRG_BallisticBouncer_Ball_Projectile'
	BurstFXTemplate= ParticleSystem'WEP_HRG_BallisticBouncer_EMIT.FX_HRG_BallisticBouncer_Ball_Explode'
	HitFXTemplate= ParticleSystem'WEP_HRG_BallisticBouncer_EMIT.FX_HRG_BallisticBouncer_Ball_Hit'

	bSuppressSounds=false
	bAmbientSoundZedTimeOnly=false
    bAutoStartAmbientSound=false
	bStopAmbientSoundOnExplode=true

	ImpactAkEvent=AkEvent'WW_WEP_HRG_BallisticBouncer.Play_WEP_HRG_BallisticBouncer_Ball_Impact'
    BounceAkEvent=AkEvent'WW_WEP_HRG_BallisticBouncer.Play_WEP_HRG_BallisticBouncer_Ball_Impact'
	ImpactAkEventHeavy=AkEvent'WW_WEP_HRG_BallisticBouncer.Play_WEP_HRG_BallisticBouncer_Ball_Impact_Heavy'
    BounceAkEventHeavy=AkEvent'WW_WEP_HRG_BallisticBouncer.Play_WEP_HRG_BallisticBouncer_Ball_Impact_Heavy'

	BurstAkEvent=AkEvent'WW_WEP_HRG_BallisticBouncer.Play_WEP_HRG_BallisticBouncer_Ball_Explosion'
	
    Begin Object Class=AkComponent name=AmbientAkSoundComponent
    	bStopWhenOwnerDestroyed=true
    	bForceOcclusionUpdateInterval=true
        OcclusionUpdateInterval=0.25f
    End Object
    AmbientComponent=AmbientAkSoundComponent
    Components.Add(AmbientAkSoundComponent)

    //ImpactDecalMaterial=DecalMaterial'FX_Mat_Lib.FX_Puke_Mine_Splatter_DM'
    ImpactDecalWidth=178.f
    ImpactDecalHeight=178.f
    ImpactDecalThickness=28.f

	Begin Object Name=CollisionCylinder
		CollisionRadius=0.f
		CollisionHeight=0.f
		CollideActors=true
		BlockNonZeroExtent=false
		PhysMaterialOverride=PhysicalMaterial'WEP_HRG_BallisticBouncer_EMIT.BloatPukeMine_PM'
	End Object

	bCollideComplex=TRUE	// Ignore simple collision on StaticMeshes, and collide per poly
	bUseClientSideHitDetection=true
	bNoReplicationToInstigator=false
	bUpdateSimulatedPosition=true

	bProjTarget=true
	bCanBeDamaged=false
	bNoEncroachCheck=true
    bPushedByEncroachers=false
    DampenFactor=0.175f
    DampenFactorParallel=0.175f

	ExtraLineCollisionOffsets.Add((Y=-20))
	ExtraLineCollisionOffsets.Add((Y=20))
	ExtraLineCollisionOffsets.Add((Z=-20))
	ExtraLineCollisionOffsets.Add((Z=20))
	// Since we're still using an extent cylinder, we need a line at 0
	ExtraLineCollisionOffsets.Add(())
	GlassShatterType=FMGS_ShatterAll
	InheritedScale=1

	MaxInitialSpeedByCharge=5000
	MinInitialSpeedByCharge=1500

	MaxCollisionRadius=20
	MinCollisionRadius=10
	MaxCollisionHeight=20
	MinCollisionHeight=10
	
	MaxScalePerPercentage=1.5f
	MinScalePerPercentage=0.5f

	MaxBouncesPerPercentage=5
	MinBouncesPerPercentage=1

	MaxLifespanPerPercentage=500
	MinLifeSpanPerPercentage=300

	bBlockedByInstigator=true
	bNetTemporary=false

	bSyncToOriginalLocation=true
	bSyncToThirdPersonMuzzleLocation=true

	bReplicateLocationOnExplosion=true

	TouchTimeThreshhold=0.05

	MaxBounces=0
	NumBounces=0

	ArmDistSquared=0

	// Fade out properties
	FadeOutTime=5.0f

	// ImpactEffects= KFImpactEffectInfo'WEP_DragonsBreath_ARCH.DragonsBreath_bullet_impact'
}