//=============================================================================
// KFEmit_Path
//=============================================================================
// Path emitter
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
// - Christian "schneidzekk" Schneider
//============================================================================
class KFEmit_Path extends Emitter
	config(Game)
	abstract;

const MAX_WAYPOINTS = 24;

/** custom height offset for waypoints */
var const int WAYPOINT_HEIGHT;

/** custom height offset for waypoints on nav mesh */
var const int WAYPOINT_HEIGHT_NAV_MESH;

var const float MinDistanceBetweenWayPointsOnNavMesh;

/** The Template to use for this emitter */
var ParticleSystem EmitterTemplate;

/** path points to travel to */
var array<vector> WayPoints;
/** total number of valid points in WayPoints list */
var int NumPoints;
/** current position in WayPoints list */
var int Position;

/*********************************************************************************************
* Acceleration physics (KF1 style trails)
 ********************************************************************************************* */

/** Increases velocity correction to tigthen curve */
var const float CURVE_TURNRATE;
/** Acceleration magnitude */
var const float ACCEL_RATE;

/** If set, use KF1 style acceleration movement physics */
var bool bUseAccelerationPhysics;
/** heading direction used for accel based movement */
var	bool bHeadedRight;

var const bool bShowEmitPathDebugArtifacts;

simulated function PostBeginPlay()
{
	local int i, Start;
	local KFPlayerController P;
	local Actor HitActor;
	local Vector HitLocation,HitNormal;

	Super.PostBeginPlay();

	P = KFPlayerController(Owner);
	if ( P == None || P.Pawn == None )
	{
		Destroy();
	}
	else
	{
		SetTemplate(EmitterTemplate,true);
		SetLocation(P.Pawn.Location);

		WayPoints[0] = Location + (WAYPOINT_HEIGHT * vect(0,0,1)) + (200.0 * vector(P.Rotation));
		HitActor = Trace(HitLocation, HitNormal, WayPoints[0], Location, false);
		if ( HitActor != None )
		{
			WayPoints[0] = HitLocation;
		}
		NumPoints++;

		if( class'KFAIController'.default.bUseNavMesh )
		{
			//BuildWaypointsFromNavMeshPathCache();

			//if( class'KFAIController'.default.bShowDoorNavigationDebugArtifacts )
			//{
			//	class'KFAIController'.static.ShowAdvancedRouteEdgeDebugInfo( P.MyKFNavigationHandle, true );
			//}
		}
		else
		{
			if ( P.RouteCache[0] != None && P.RouteCache.length > 1 && P.ActorReachable(P.RouteCache[1]) )
			{
				Start = 1;
			}

			for (i = Start; NumPoints < MAX_WAYPOINTS && i < P.RouteCache.length && P.RouteCache[i] != None; i++)
			{
				WayPoints[NumPoints++] = P.RouteCache[i].Location + (WAYPOINT_HEIGHT * vect(0,0,1));
			}
		}
		StartNextPath();
	}
}

/** Override the final waypoint (optional) */
simulated function SetDestination(vector Destination)
{
	if ( NumPoints > 1 )
	{
		WayPoints[NumPoints-1] = Destination;
	}
}

simulated event SetInitialState()
{
	bScriptInitialized = true;

	if ( PlayerController(Owner).IsLocalPlayerController() )
	{
		StartNextPath();
	}
	else
	{
		//@warning: can't set bHidden because that would get replicated
		ParticleSystemComponent.DeactivateSystem();
		SetPhysics(PHYS_None);
	}
}

simulated event SetTemplate(ParticleSystem NewTemplate, optional bool bDestroyOnFinish)
{
	Super(Emitter).SetTemplate(NewTemplate, bDestroyOnFinish);
}

simulated function StartNextPath()
{
	local Pawn OwnerPawn;
	local KFPlayerController KFPC;

   	KFPC = KFPlayerController(Owner);

	if ( ShouldStopPathing() )
	{
		Destroy();
		return;
	}

	++Position;
	if ( Position >= NumPoints || Position >= WayPoints.Length )
	{
		LifeSpan = 5.0;
		Velocity = vect(0,0,0);
		ParticleSystemComponent.DeactivateSystem();
		SetPhysics(PHYS_None);
		GotoState('');
	}
	else if ( bUseAccelerationPhysics )
	{
		OwnerPawn = (KFPC != None) ? KFPC.Pawn : None;
		if ( Position == 0 && OwnerPawn != None )
		{
			SetLocation(OwnerPawn.Location + (WAYPOINT_HEIGHT * vect(0,0,1)));
			// initial forward velocity to make the path loop around
			Velocity = 4000 * CURVE_TURNRATE * Normal(WayPoints[0] - Location) + OwnerPawn.Velocity;
		}

		bHeadedRight = false;
		Acceleration = ACCEL_RATE * Normal(WayPoints[Position] - Location);
		Velocity *= 0.5;
		Velocity.Z = 0.5 * (Velocity.Z + Acceleration.Z);

		SetRotation(rotator(WayPoints[Position] - Location));
		GotoState('Pathing');
	}
	else
	{
		OwnerPawn = (KFPC != None) ? KFPC.Pawn : None;
		if ( Position == 0 && OwnerPawn != None )
		{
			SetLocation(OwnerPawn.Location + (WAYPOINT_HEIGHT * vect(0,0,1)) + vector(OwnerPawn.Rotation) * 100.0);
		}

		SetRotation(rotator(WayPoints[Position] - Location));
		GotoState('Pathing');
	}
}

simulated function bool ShouldStopPathing()
{
	local KFPlayerController KFPC;

   	KFPC = KFPlayerController(Owner);
	if( KFPC != none && KFPC.Pawn != none )
	{
		return KFPC.Pawn.IsA('KFPawn_Customization');
	}
	
	return false;
}

state Pathing
{
	simulated function Tick(float DeltaTime)
	{
		local KFPlayerController KFPC;

	   	KFPC = KFPlayerController(Owner);

		if ( ShouldStopPathing() )
		{
			Destroy();
			return;
		}

		//DrawDebugSphere(Location, 12, 12, 255, 0, 0, false);

		if ( !bUseAccelerationPhysics )
		{
			TickUDK(DeltaTime, KFPC.Pawn);
		}
		else
		{
			TickClassic(DeltaTime);
		}
	}

	/** Velocity based movement based on UDK */
	simulated function TickUDK(float DeltaTime, Pawn OwnerPawn)
	{
		local float MaxSpeed;

		SetRotation (rotator(WayPoints[Position] - Location));

		if ( OwnerPawn != None )
		{
			if ( VSize(Location - OwnerPawn.Location) < OwnerPawn.GroundSpeed && vector(Rotation) dot vector(OwnerPawn.Rotation) > 0.0 )
			{
				// go faster when near owner to get some separation
				MaxSpeed = OwnerPawn.GroundSpeed + 400.0;
			}
			else
			{
				MaxSpeed = VSize(OwnerPawn.Velocity) + 200.0;
				RotationRate = default.RotationRate;
			}
		}
		else
		{
			MaxSpeed = 200.0;
		}

		Velocity = vector(Rotation) * MaxSpeed;
		if (VSize(WayPoints[Position] - Location) < FMax(80.0, VSize(Velocity) * DeltaTime * 3.0))
		{
			StartNextPath();
		}
	}

	/** Acceleration based movement from KF1 */
	simulated function TickClassic(float DeltaTime)
	{
		Acceleration = ACCEL_RATE * Normal(WayPoints[Position] - Location);
		Velocity = Velocity + CURVE_TURNRATE * DeltaTime * Acceleration; // force double acceleration

		// use heading change to detect if we curved around WayPoint.
		if ( !bHeadedRight )
			bHeadedRight = ( (Velocity Dot Acceleration) > 0 );
		else if ( Velocity Dot Acceleration < 0 )
			StartNextPath();

		if ( WayPoints.Length > Position  && VSize(WayPoints[Position] - Location) < 80 )
			StartNextPath();
	}

	simulated function BeginState(name PreviousStateName)
	{
		SetPhysics(PHYS_Projectile);
	}
}

defaultproperties
{
	WAYPOINT_HEIGHT_NAV_MESH=25
	
	MinDistanceBetweenWayPointsOnNavMesh=250
}
