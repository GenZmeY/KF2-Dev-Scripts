//=============================================================================
// KFProj_RicochetStickBullet
//=============================================================================
// Class for projectiles that can stick to walls and be picked up.
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
// Brooks Butler
//=============================================================================

class KFProj_RicochetStickBullet extends KFProj_RicochetBullet
	hidedropdown;

/************************************************************************************
 * @name Pickup Values
 ***********************************************************************************/

// Toned down ImpactInfo type to reduce net traffic.
struct StickInfo
{
	var vector HitLocation;
	var vector HitNormal;
	var vector RayDir;
	var PrimitiveComponent HitComponent;
};

/** Information on where this projectile has stuck */
var repnotify StickInfo RepStickInfo;
/** Information on where this projectile has stuck, cached for later use */
var StickInfo DelayedStickInfo;

/** The radius size of the pickup collision when the projectile stops moving */
var() float PickupRadius;
/** The height of the pickup collision when the projectile stops moving  */
var() float PickupHeight;

/** Class name of the weapon that shot this projectile (Network: Client) */
var const name WeaponClassName;
/** Class of weapon fired from for pickup logic (Network: Server only) */
var class<Weapon> WeaponClass;

/** Sound to play when picking up ammo */
var() AkEvent AmmoPickupSound;

/** Position this projectile was in last frame. Used to position the projectile on destructibles correctly */
var vector LastLocation;

/** This projectile is currently stuck to a wall */
var bool bStuck;

/** This is the effect that is played while in flight */
var(Projectile) ParticleSystem ProjPickupTemplate;

/** This is what LifeSpan is set to after Stick() is called.
	Allows us to set a much shorter LifeSpan to prevent fly-away projectiles living a long time. */
var float LifeSpanAfterStick;

replication
{
	if ( bNetDirty )
		RepStickInfo;
}

/* epic ===============================================
* ::ReplicatedEvent
*
* Called when a variable with the property flag "RepNotify" is replicated
*
* =====================================================
*/
simulated event ReplicatedEvent(name VarName)
{
	if (VarName == nameof(RepStickInfo))
	{
		Stick(RepStickInfo, true);
	}
	else
	{
		Super.ReplicatedEvent(VarName);
	}
}

event PreBeginPlay()
{
    super.PreBeginPlay();

	// store weapon class for later on the server
	if ( Role == ROLE_Authority && PickupRadius > 0 )
	{
		WeaponClass = Instigator.Weapon.Class;

		// These better be the same or someone messed up
		if ( WeaponClass.Name != WeaponClassName && 
			 (class<KFWeap_DualBase>(WeaponClass) == none || class<KFWeap_DualBase>(WeaponClass).default.SingleClass.Name != WeaponClassName))
		{
			`warn("Projectile pickup mismatch class:"$WeaponClass@"name:"$WeaponClassName);
		}
	}
}

simulated event HitWall(vector HitNormal, Actor Wall, PrimitiveComponent WallComp)
{
	local StickInfo MyStickInfo;
    local KActorFromStatic NewKActor;
	local KFDestructibleActor HitDestructible;
	local StaticMeshComponent HitComponent;
	local TraceHitInfo HitInfo;

	SetRotation(rotator(Normal(Velocity)));
	SetPhysics(PHYS_Falling);

	if( bBounce && !Wall.bStatic && Wall.bCanBeDamaged && Wall.bProjTarget )
	{
        HitInfo.HitComponent = WallComp;
        HitInfo.Item = INDEX_None;  // force TraceComponent on fractured meshes
        Wall.TakeDamage( Damage, InstigatorController, Location, MomentumTransfer * -HitNormal, MyDamageType, HitInfo, self );

        // If we destroyed the wall we just hit, pass through but stop bouncing
        if( !Wall.bBlockActors || (WallComp != none && !WallComp.BlockActors) )
        {
        	BouncesLeft = 0;
        	return;
        }
	}

	// check if we should do a bounce, otherwise stick
	if( !Bounce(HitNormal, Wall) )
	{
		// Turn off the corona when it stops
		if ( WorldInfo.NetMode != NM_DedicatedServer && ProjEffects!=None )
		{
			ProjEffects.DeactivateSystem();
			ProjEffects.SetVectorParameter('Rotation', vect(0,0,0));
		}

		// Check to see whether we should stick or not.
		if( !Wall.bStatic && Wall.bWorldGeometry && Wall.bCanBeDamaged && Wall.bProjTarget )
		{
			// If the object is client side, don't stick, because it's destruction won't be replicated
			HitDestructible = KFDestructibleActor(Wall);
			if(HitDestructible != none && HitDestructible.ReplicationMode >= RT_ClientSide) 
			{
				// Pass through with no collision.
				return;
			}
		}
		else
		{
			// If our hit object can become dynamic, don't stick.
			HitComponent = StaticMeshComponent( WallComp );
			if( HitComponent != none && HitComponent.CanBecomeDynamic() )
			{
		        NewKActor = class'KActorFromStatic'.static.MakeDynamic( HitComponent );
		        if( NewKActor != none )
		        {
		            NewKActor.TakeDamage( Damage, InstigatorController, Location, MomentumTransfer * -HitNormal, MyDamageType, HitInfo, self );
		        }
				return;
			}
		}

		MyStickInfo.HitLocation = Location;
		MyStickInfo.HitNormal = HitNormal;
		MyStickInfo.HitComponent = WallComp;

		MyStickInfo.RayDir = EncodeSmallVector(Normal(Velocity));
		Stick(MyStickInfo, false);

		bBounce = false;
	}
}

/**
 * Very small momentum values get truncated during replication. So, we need to scale the
 * momentum vector during replication.
 */
simulated function vector EncodeSmallVector(vector V)	{return V * 256.f;}
simulated function vector DecodeSmallVector(vector V)	{return V / 256.f;}

/**
 * Spawns any effects needed for the flight of this projectile
 */
simulated function SpawnFlightEffects()
{
	local KFWeapon W;
	local PlayerController PC;
	local bool bOwnsWeapon;

	super.SpawnFlightEffects();

	if (WorldInfo.NetMode != NM_DedicatedServer && ProjEffects!=None )
	{
		ProjEffects.SetVectorParameter('Rotation', vect(0,0,1));

		PC = GetALocalPlayerController();
		if ( PC.Pawn != None )
		{
			// If we own this weapon show the pickup icon
			foreach PC.Pawn.InvManager.InventoryActors( class'KFWeapon', W )
			{
				if( W.Class.Name == WeaponClassName )
				{
					bOwnsWeapon = true;
					break;
				}
			}
		}

		ProjEffects.SetFloatParameter('Icon', (bOwnsWeapon) ? 1.f : 0.f);
	}
}

/*********************************************************************************************
 * State Pickup
 * State for when the projectile needs to be picked up after it is fired.
 *********************************************************************************************/
/**
 * State where this projectile is waiting to be picked up
 */
state Pickup
{
	/** give pickup to player */
	function GiveTo( Pawn P )
	{
		local KFWeapon W;
		local class<KFWeapon> KFWeaponClass;
		local class<KFWeap_DualBase> DualWeaponClass;
		
		KFWeaponClass   = class<KFWeapon>(WeaponClass);
		DualWeaponClass = class<KFWeap_DualBase>(WeaponClass);

		foreach P.InvManager.InventoryActors( class'KFWeapon', W )
		{
			// Give the player 1 shot back
			if( W.Class == WeaponClass || (DualWeaponClass != none ? DualWeaponClass.default.SingleClass == W.Class 
									 							   : KFWeaponClass.default.DualClass == W.Class))
			{
				W.AddAmmo(1);

				PlayerController( P.Owner ).ReceiveLocalizedMessage( class'KFLocalMessage_Game', GMT_PickedupWeaponAmmo,,,WeaponClass);
				P.PlaySoundBase( AmmoPickupSound );

				ShutDown();
			}
		}
	}

	/**
	* Validate touch (if valid return true to let other pick me up and trigger event).
	* Overridden to remove call to WorldInfo.Game.PickupQuery(Other, InventoryType, self) since we need this to be client side
	*/
	function bool ValidTouch( Pawn Other )
	{
		local vector PickupLocation;

		// make sure its a live player
		if (Other == None || !Other.bCanPickupInventory || (Other.DrivenVehicle == None && Other.Controller == None))
		{
			return false;
		}

		// Set the pickup check location slightly away from the impact point, so it can't get caught in bad collision.
		PickupLocation = Location - vector(Rotation) * 15.f;

		// make sure not touching through wall
		if ( !FastTrace(Other.Location, PickupLocation) && !FastTrace(Other.Location, PickupLocation,,true) )
		{
			return false;
		}

		// make sure game will let player pick me up
		if (WorldInfo.Game.PickupQuery(Other, WeaponClass, self))
		{
			return true;
		}
		return false;
	}

	// When touched by an actor.
	simulated event Touch( Actor Other, PrimitiveComponent OtherComp, vector HitLocation, vector HitNormal )
	{
		local Pawn P;

		if( Role == ROLE_Authority )
		{
			// If touched by a player pawn, let him pick this up.
			P = Pawn(Other);
			if( P != None && ValidTouch(P) )
			{
				GiveTo(P);
			}
		}
	}

	// Make sure no pawn already touching .
	function CheckTouching()
	{
		local Pawn P;

		ForEach TouchingActors(class'Pawn', P)
		{
			Touch(P, None, Location, Normal(Location-P.Location) );
		}
	}

	/**
	* Overridden to prevent adding to navigation network.
	*/
	function BeginState(Name PreviousStateName)
	{
		// Modify the collision so it can be picked up by the player
		SetCollisionSize(PickupRadius,PickupHeight);
		CylinderComponent.SetTraceBlocking( true, true );
		CylinderComponent.SetActorCollision( true, false );
		bCollideComplex = false;
		SetOwner( None ); // If the owner is still the weapon (which is owned by the pawn that shot the projectile), then it will not collide at all with the pawn, so set its owner to none!
	}

	// Here we handle what happens if a stuck on a destructible, and that destructible is destroyed.
	simulated function Tick( float DeltaTime )
	{
		if(Role == ROLE_Authority && RepStickInfo.HitComponent != none && RepStickInfo.HitComponent.HiddenGame)
		{
			Explode(RepStickInfo.HitLocation, RepStickInfo.HitNormal);
			ImpactedActor = None;
		}
	}

Begin:
	CheckTouching();
}

/**
 * Stick on the wall
 */
simulated function Stick(StickInfo MyStickInfo, bool bReplicated )
{
	// Turn off the corona and rotation when it stops
	if ( WorldInfo.NetMode != NM_DedicatedServer && ProjEffects!=None )
	{
		// Turn off the old effects
		ProjEffects.DeactivateSystem();

		// Activate the pickup effects
		ProjEffects.SetTemplate(ProjPickupTemplate);
		ProjEffects.ActivateSystem();
		ProjEffects.SetVectorParameter('Rotation', vect(0,0,0));
	}

	// Play the bullet impact sound and effects
	if ( WorldInfo.NetMode != NM_DedicatedServer && !bStuck )
	{
		`ImpactEffectManager.PlayImpactEffects(Location, Instigator, MyStickInfo.HitNormal, ImpactEffects);
	}

	if( !IsZero(DecodeSmallVector(MyStickInfo.RayDir)) )
	{
		SetRotation(Rotator(DecodeSmallVector(MyStickInfo.RayDir)));
	}
	else
	{
		SetRotation(Rot(0,0,0));
	}

	SetPhysics(PHYS_None);

	if( bReplicated )
	{
		SetLocation(MyStickInfo.HitLocation);
		bStuck = true;
	}
	else if( Role == ROLE_Authority )
	{
		bStuck = true;
		//@see DelayedStick()
		//RepStickInfo = MyStickInfo;
		LifeSpan = LifeSpanAfterStick;
	}

	// Stop ambient sounds when this projectile ShutsDown
	if( bStopAmbientSoundOnExplode )
	{
		StopAmbientSound();
	}

	// Do stick next frame to give owning client time for CSHD
	if ( Role == ROLE_Authority && !Instigator.IsLocallyControlled() )
	{
		DelayedStickInfo = MyStickInfo;
		SetTimer(0.01, false, nameof(DelayedStick));
	}
	else
	{
		if( Role == ROLE_Authority )
		{
			RepStickInfo = MyStickInfo;
			bForceNetUpdate = TRUE;
			NetUpdateFrequency = 3;
		}

		GotoState('Pickup');
	}
}

/**
 * Delay the stick so that client side hit detection doesn't get messed up for close shots
 */
simulated function DelayedStick()
{
	RepStickInfo = DelayedStickInfo;

	bForceNetUpdate = TRUE;
	NetUpdateFrequency = 3;

	GotoState('Pickup');
}

simulated function Tick( float DeltaTime )
{
	super.Tick(DeltaTime);

	LastLocation = Location;

	// Make it start falling faster if it's moving really slow
	if( Physics == PHYS_Projectile && VSizeSq(Velocity) < (Square(Speed) * 0.1f) )
	{
		SetPhysics( PHYS_Falling );
		GravityScale = 1.0f;
	}

	if ( WorldInfo.NetMode != NM_DedicatedServer && Physics != PHYS_None )
	{
		SetRotation( rotator(Velocity) );
	}
}

//==============
// Touching
// Overridden to get bouncing off of destructible meshes
simulated function ProcessTouch(Actor Other, Vector HitLocation, Vector HitNormal)
{
	local KFPawn KFP;
	local bool bPassThrough;

	if ( Other != Instigator && Other.bCanBeDamaged && (!Other.bWorldGeometry || !Other.bStatic) )
	{
		if( ShouldProcessBulletTouch() )
		{
			KFP = KFPawn( Other );
			if ( KFP != None )
			{
				// check/ignore repeat touch events
				if( CheckRepeatingTouch(Other) )
				{
					return;
				}

				ProcessBulletTouch(Other, HitLocation, HitNormal);

				// Keep going if we need to keep penetrating
				if( PenetrationPower > 0 || PassThroughDamage(Other) )
				{
					// Reduce penetration power for every KFPawn penetrated
					PenetrationPower -= KFP.PenetrationResistance;
					bPassThrough = TRUE;
				}

				if ( !bPassThrough )
				{
					// Turn off the corona when it stops
					if ( WorldInfo.NetMode != NM_DedicatedServer && ProjEffects!=None )
					{
						ProjEffects.DeactivateSystem();
						ProjEffects.SetVectorParameter('Rotation', vect(0,0,0));
					}

					// Make the projectile fall to the ground if it his something it can't penetrate
					Velocity = vect(0,0,0);
					BouncesLeft=0;
					SetPhysics(PHYS_Falling);
				}
				return;
			}
			else
			{
				ProcessDestructibleTouchOnBounce( Other, HitLocation, HitNormal );
				return;
			}
		}
	}

	Super.ProcessTouch(Other, HitLocation, HitNormal);;
}

simulated function bool ShouldProcessBulletTouch()
{
	return Physics == PHYS_Projectile && BouncesLeft > 0;
}

defaultproperties
{
	PickupRadius=250
	PickupHeight=250
}