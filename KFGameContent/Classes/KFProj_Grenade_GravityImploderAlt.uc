//=============================================================================
// KFProj_Grenade_GravityImploderAlt
//=============================================================================
// Killing Floor 2
// Copyright (C) 2020 Tripwire Interactive LLC
//=============================================================================

class KFProj_Grenade_GravityImploderAlt extends KFProj_BallisticExplosive
	hidedropdown;

/** Factor added to the rolling speed of the ball when bouncing **/
var(Projectile) float RollingFactor;

/** Indicates that the ball hit the wall and is doing rolling animations **/
var transient bool bIsRolling;

/** Amount of roll stored for this cannonball **/
var transient float CurrentRoll;

var bool bHasAlreadyBounced;

/** Collider **/
var Object Collider;
/** Time before starting the implosion effect **/
var float PreparationTime;

/** Vortex params. */
var float VortexDuration;
var float VortexTime;
var float VortexRadius;
var float VortexAbsorptionStrength;
var float VortexElevationStrength;
var bool  bVortexReduceImpulseOnDist;

var protected transient bool bFirstAbsorption;
var protected transient vector VortexLocation;

var protected vector				VortexNormal;
var protected KFImpactEffectInfo	VortexImpactEffects;

simulated state PreparingState
{
	simulated function BeginState(Name PrevStateName)
	{
		super.BeginState(PrevStateName);
		SetTimer( PreparationTime, false, nameOf(Timer_Ready) );
	}

	simulated event Tick(float DeltaTime)
	{
		local vector RollDelta;
		local rotator NewRotation;

		// Let's roll (only in the client)
		if ( bIsRolling && WorldInfo.NetMode != NM_DedicatedServer && Physics != PHYS_None && (Velocity.X != 0 || Velocity.Y != 0) )
		{
			CurrentRoll -= (Abs(Velocity.X) + Abs(Velocity.Y)) * DeltaTime * RollingFactor; 
			RollDelta = ((vect(1, 0 , 0) * (Velocity.X)) + (vect(0, 1, 0) * (Velocity.Y) ));
			NewRotation = Rotator(RollDelta);
			NewRotation.pitch += CurrentRoll;
			SetRotation(NewRotation);
		}

		Super.Tick(DeltaTime);
	}

	simulated event HitWall(vector HitNormal, actor Wall, PrimitiveComponent WallComp)
	{
		VortexNormal = HitNormal;

		ProcessRebound(HitNormal, Wall, WallComp);

		if( !bDud && !bIsTimedExplosive )
		{
			Super.HitWall(HitNormal, Wall, WallComp);
		}
	}

	simulated function ProcessTouch(Actor Other, Vector HitLocation, Vector HitNormal)
	{
		local bool bWantsClientSideDudHit;
		local float TraveledDistance;
		local Vector VNorm;
		//local int Index;

		// If we collided with a Siren shield, let the shield code handle touches
		if( Other.IsA('KFTrigger_SirenProjectileShield') )
		{
			return;
		}

		if ( !bCollideWithTeammates && Pawn(Other) != None )
		{
			// Don't hit teammates
			if( Other.GetTeamNum() == GetTeamNum() )
			{
				return;
			}
		}

		// Need to do client side dud hits if this is a client
		if( Instigator != none && Instigator.Role < ROLE_Authority )
		{
			bWantsClientSideDudHit = true;
		}

		TraveledDistance = (`TimeSince(CreationTime) * Speed);
		TraveledDistance *= TraveledDistance;

		if( (!bDud || ( bWantsClientSideDudHit && !bClientDudHit)) && ((TraveledDistance < ArmDistSquared) || bIsTimedExplosive || (OriginalLocation == vect(0,0,0) && ArmDistSquared > 0)))
		{
			// Don't touch the same actor multiple time's immediately after just
			// touching it if the TouchTimeThreshhold is set to greater than 0.
			// This was causing projectiles just to "stop" sometimes when hitting
			// dead/ragdolled pawns because it was counting as multiple penetrations
			if( LastTouched.Actor == Other && TouchTimeThreshhold > 0
				&& `TimeSince(LastTouched.Time) <= TouchTimeThreshhold )
			{
				return;
			}

			//TODO: Add an impact sound here
			SetIsDud(bWantsClientSideDudHit, HitNormal);

			if (Other != Instigator && !Other.bStatic && Other.GetTeamNum() != GetTeamNum() && !CheckRepeatingTouch(Other))
			{
				ProcessBulletTouch(Other, HitLocation, HitNormal);
			}
			// Reflect off Wall w/damping but allow penetration if the pawn is dead
			//if(KFPawn_Monster(Other) == None || KFPawn_Monster(Other).Health > 0)
			//{
				VNorm = (Velocity dot HitNormal) * HitNormal;
				Velocity = -VNorm * DampenFactor + (Velocity - VNorm) * DampenFactorParallel;
				Speed = VSize(Velocity);
			//}
		}
		else if (!bDud && !bIsTimedExplosive)
		{
			// Process impact hits
			if (Other != Instigator && !Other.bStatic)
			{
				// check/ignore repeat touch events
				if( !CheckRepeatingTouch(Other) && Other.GetTeamNum() != GetTeamNum())
				{
					ProcessBulletTouch(Other, HitLocation, HitNormal);
				}
			}

			if( WorldInfo.NetMode == NM_Standalone ||
				(WorldInfo.NetMode == NM_ListenServer && Instigator != none && Instigator.IsLocallyControlled()) )
			{
				Super.ProcessTouch( Other, HitLocation, HitNormal );
				return;
			}

			if( Owner != none && KFWeapon( Owner ) != none && Instigator != none )
			{
				if( Instigator.Role < ROLE_Authority && Instigator.IsLocallyControlled() )
				{
					KFWeapon(Owner).HandleClientProjectileExplosion(HitLocation, self);
					Super.ProcessTouch( Other, HitLocation, HitNormal );
					return;
				}
			}
		}
	}
} 

simulated state WaitingToImplode
{
	simulated function BeginState(Name PrevStateName)
	{
		super.BeginState(PrevStateName);
	}

	simulated event HitWall(vector HitNormal, actor Wall, PrimitiveComponent WallComp)
	{
		if (HitNormal Dot vect(0,0,1) > 0.5f)
		{
			GotoState('ImplodingState');
			return;
		}
		
		ProcessRebound(HitNormal, Wall, WallComp);
		if(!bDud && !bIsTimedExplosive)
		{
			Super.HitWall(HitNormal, Wall, WallComp);
		}
	}

	simulated function Tick(float Delta)
	{
		if (vSize(Velocity) < 0.05f)
		{
			GotoState('ImplodingState');
			return;
		}

		super.Tick(Delta);
	}

	simulated function ProcessTouch(Actor Other, Vector HitLocation, Vector HitNormal)
	{
		// Prevent default funcionality;
		super.ProcessTouch(Other, HitLocation, HitNormal);
	}
}

simulated state ImplodingState
{
	simulated function BeginState(Name PrevStateName)
	{
		super.BeginState(PrevStateName);

		StopSimulating();

		AdjustVortexForPerk();
		if ( WorldInfo.NetMode != NM_Client )
		{
			Velocity=vect(0,0,0);
			Acceleration=vect(0,0,0);
			RotationRate=rot(0,0,0);
			GravityScale=0.0;
			
			bFirstAbsorption=true;
			VortexTime=0.0f;

			SetTimer(VortexDuration, false, nameOf(Detonation_Ready) );
		}

		VortexLocation = Location + vect(0,0,1) * 125;

		// Start VGC
		StartVortexVFX();
	}

	simulated function StartVortexVFX()
	{
		if(VortexImpactEffects != None)
		{
			if(VortexImpactEffects.DefaultImpactEffect.ParticleTemplate != None)
			{
				WorldInfo.MyEmitterPool.SpawnEmitter(VortexImpactEffects.DefaultImpactEffect.ParticleTemplate, VortexLocation, rotator(VortexNormal));
			}
			if(VortexImpactEffects.DefaultImpactEffect.Sound != None)
			{
				PlaySoundBase(VortexImpactEffects.DefaultImpactEffect.Sound, true,,, VortexLocation);
			}
		}
	}	

	simulated function EndState(Name NextStateName)
	{
		super.EndState(NextStateName);
	}

	simulated event Tick(float DeltaTime)
	{
		Super.Tick(DeltaTime);

		// Avoids to be moved in case there's any force applied.
		SetLocation(VortexLocation);

`if(`notdefined(ShippingPC))
			
		if( KFWeap_GravityImploder(Owner) != none && KFWeap_GravityImploder(Owner).bDebugDrawVortex)
		{
			DrawDebugSphere(Location, VortexRadius, 125, 0, 0, 255, false);
		}
`endif

		if (WorldInfo.NetMode < NM_Client)
		{
			VortexTime += DeltaTime;
			AbsorbEnemies();
			bFirstAbsorption=false;
		}
	}

	function AdjustVortexForPerk()
	{
		local KFPlayerController KFPC;
		local KFPerk Perk;

		KFPC = KFPlayerController(InstigatorController);
		if( KFPC != none )
		{
			Perk = KFPC.GetPerk();
			if(Perk != none)
			{
				VortexRadius = default.VortexRadius * Perk.GetAoERadiusModifier();
			}
		}
	}

	simulated function AbsorbEnemies()
	{
		local Actor          Victim;
		local TraceHitInfo   HitInfo;
		local KFPawn         KFP;
		local KFPawn_Monster KFPM;
		local float		     ColRadius, ColHeight;
		local float		     Dist;
		local vector	     Dir;
		local vector         Momentum;
		local float          MomentumModifier;

		foreach CollidingActors(class'Actor', Victim, VortexRadius, VortexLocation, true,, HitInfo)
		{
			KFP  = KFPawn(Victim);
			KFPM = KFPawn_Monster(Victim);

			if (Victim != Self
				&& (!Victim.bWorldGeometry || Victim.bCanBeDamaged)
				&& (NavigationPoint(Victim) == None)
				&& Victim != Instigator
				&& KFP != None 
				&& KFPawn_Human(Victim) == none // No player's character
				&& (KFPM == none || VortexTime < VortexDuration*KFPM.GetVortexAttractionModifier()) )
			{
				KFP.GetBoundingCylinder(ColRadius, ColHeight);

				if (bFirstAbsorption)
				{
					Dir      = vect(0,0,1);
					Momentum = Dir * VortexElevationStrength;
				}
				else
				{
					Dir              = Normal(VortexLocation - KFP.Location);
					Dist             = FMax(vSize(Dir) - ColRadius, 0.f);
					MomentumModifier = bVortexReduceImpulseOnDist ? (1.0f - Dist / VortexRadius) : 1.0f;
					Momentum         = Dir * VortexAbsorptionStrength * MomentumModifier + vect(0,0,1) * (Dist/VortexRadius) * VortexAbsorptionStrength;
				}

				if(KFPM != none)
				{
					Momentum *= KFPM.GetVortexAttractionModifier();
				}

				KFP.AddVelocity( Momentum, KFP.Location - 0.5 * (ColHeight + ColRadius) * Dir, class 'KFDT_Explosive_GravityImploder');
			}
		}
	}
}

simulated state DetonatingState
{
	simulated function BeginState(Name PrevStateName)
	{
		super.BeginState(PrevStateName);
		Detonate();
	}
}


simulated function PostBeginPlay()
{
	Super.PostBeginPlay();
	GotoState('PreparingState');
}

simulated function Timer_Ready()
{
	// GotoState('ImplodingState');
	GotoState('WaitingToImplode');
}

simulated function Detonation_Ready()
{
	GotoState('DetonatingState');
}

simulated function Detonate()
{
	local vector ExplosionNormal, vExplosionOffset;

	// Check if the bomb should explode right now
	if (!bHasExploded && !bHasDisintegrated)
	{
		ExplosionNormal =  vect(0,0,1) >> Rotation;
		vExplosionOffset.x = 0;
		vExplosionOffset.y = 0;
		vExplosionOffset.z = 10;
		SetLocation(VortexLocation + vExplosionOffset);
		CallExplode(VortexLocation, ExplosionNormal);
	}
	// If not, mark the bomb to explode as soon as it hits something
	else
	{
		bIsTimedExplosive = false;
		bNetDirty = true;
	}
}

simulated function SetIsDud(bool bWantsClientSideDudHit, vector HitNormal)
{
	// This projectile doesn't dud.
}

simulated protected function StopSimulating()
{
	Velocity = vect(0,0,0);
	Acceleration = vect(0,0,0);
	RotationRate = rot(0,0,0);
	SetCollision(FALSE, FALSE);

	StopFlightEffects();

	bRotationFollowsVelocity = FALSE;
}

simulated function ProcessRebound(vector HitNormal, actor Wall, PrimitiveComponent WallComp)
{
	local Vector VNorm;
	local rotator NewRotation;
	local Vector Offset;
	local bool bWantsClientSideDudHit;
	local TraceHitInfo HitInfo;
	local float TraveledDistance;

	bIsRolling = true;

	// Need to do client side dud hits if this is a client
	if( Instigator != none && Instigator.Role < ROLE_Authority )
	{
		bWantsClientSideDudHit = true;
	}

	TraveledDistance = (`TimeSince(CreationTime) * Speed);
	TraveledDistance *= TraveledDistance;

	// Bounce off the wall and cause the shell to dud if we hit too close
	if( bDud || ((TraveledDistance < ArmDistSquared) || bIsTimedExplosive || (OriginalLocation == vect(0,0,0) && ArmDistSquared > 0)))
	{
		// Reflect off Wall w/damping
		VNorm = (Velocity dot HitNormal) * HitNormal;
		Velocity = -VNorm * WallHitDampenFactor + (Velocity - VNorm) * WallHitDampenFactorParallel;
		Speed = VSize(Velocity);

		if( (!bDud || ( bWantsClientSideDudHit && !bClientDudHit)) )
		{
			SetIsDud(bWantsClientSideDudHit, HitNormal);
		}

		if ( WorldInfo.NetMode != NM_DedicatedServer && Pawn(Wall) == none && bHasAlreadyBounced == false )
		{
			// do the impact effects
			bHasAlreadyBounced = true;
			`ImpactEffectManager.PlayImpactEffects(Location, Instigator, HitNormal, GrenadeBounceEffectInfo, true );
		}

		// if we hit a pawn or we are moving too slowly stop moving and lay down flat
		if ( Speed < MinSpeedBeforeStop  )
		{
			ImpactedActor = Wall;
			SetPhysics(PHYS_None);
			if( ProjEffects != none )
			{
				ProjEffects.SetTranslation(LandedTranslationOffset);
			}

			// Position the shell on the ground
			RotationRate.Yaw = 0;
			RotationRate.Pitch = 0;
			RotationRate.Roll = 0;
			NewRotation = Rotation;
			NewRotation.Pitch = 0;
			if(ResetRotationOnStop)
			{
				SetRotation(NewRotation);
			}
			Offset.Z = LandedTranslationOffset.X;
			SetLocation(Location + Offset);
		}

		if( !Wall.bStatic && Wall.bCanBeDamaged && (DamageRadius == 0 || bDamageDestructiblesOnTouch) && !CheckRepeatingTouch(Wall) )
		{
			HitInfo.HitComponent = WallComp;
			HitInfo.Item = INDEX_None;
			Wall.TakeDamage( Damage, InstigatorController, Location, MomentumTransfer * Normal(Velocity), MyDamageType, HitInfo, self);
		}
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
    MomentumTransfer=100000
    LifeSpan=0.f
	bWarnAIWhenFired=true
	RollingFactor=1100
	MinSpeedBeforeStop=5
	ResetRotationOnStop=false

	// Rolling and dampen values
    DampenFactor=0.1
    DampenFactorParallel=0
	WallHitDampenFactor=0.4 //0.5
	WallHitDampenFactorParallel=0.4 //0.5

	bCollideComplex=TRUE	// Ignore simple collision on StaticMeshes, and collide per poly
	bUseClientSideHitDetection=true
	bNoReplicationToInstigator=false
	bAlwaysReplicateExplosion=true;
	bUpdateSimulatedPosition=true

	Begin Object Name=CollisionCylinder
		CollisionRadius=0.f
		CollisionHeight=0.f
		BlockNonZeroExtent=false
	End Object

	ExplosionActorClass=class'KFExplosionActor'

	ProjFlightTemplate=ParticleSystem'WEP_Gravity_Imploder_EMIT.FX_Blue_Projectile'
	ProjFlightTemplateZedTime=ParticleSystem'WEP_Gravity_Imploder_EMIT.FX_Blue_Projectile_ZEDTIME'
	
	GrenadeBounceEffectInfo=KFImpactEffectInfo'FX_Impacts_ARCH.DefaultGrenadeImpacts'
    ProjDisintegrateTemplate=ParticleSystem'ZED_Siren_EMIT.FX_Siren_grenade_disable_01'
	AltExploEffects=KFImpactEffectInfo'WEP_Gravity_Imploder_ARCH.Blue_Explosion_Concussive_Force'

	// Grenade explosion light
	Begin Object Class=PointLightComponent Name=ExplosionPointLight
	    LightColor=(R=0,G=50,B=171,A=255)
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
		Damage=1
		DamageRadius=450 //600
		DamageFalloffExponent=0.f //2
		DamageDelay=0.f
		MomentumTransferScale=10000

		// Damage Effects
		MyDamageType=class'KFDT_Explosive_GravityImploderWave'
		KnockDownStrength=150
		FractureMeshRadius=200.0
		FracturePartVel=500.0
		ExplosionEffects=KFImpactEffectInfo'WEP_Gravity_Imploder_ARCH.Blue_Explosion'
		ExplosionSound=AkEvent'WW_WEP_Gravity_Imploder.Play_WEP_Gravity_Imploder_Grenade_Blue_Explosion'

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
		bIgnoreInstigator=false
		
	End Object
	ExplosionTemplate=ExploTemplate0

	bIsTimedExplosive=true;
	PreparationTime=0.8 //1.0

	VortexDuration=0.5 //0.7
	VortexRadius=500 //650
	VortexAbsorptionStrength=120 //100
	VortexElevationStrength=700
	bVortexReduceImpulseOnDist=false
	bFirstAbsorption=true
	VortexImpactEffects=KFImpactEffectInfo'WEP_Gravity_Imploder_ARCH.Blue_Attract'
}
