//=============================================================================
// KFKActorSpawnable_Door
//=============================================================================
// A custom KActor that will hide if it lands in an akward position
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//  - Author 4/15/2014
//=============================================================================

class KFKActorSpawnable_Door extends KFKActorSpawnable;

event OnSleepRBPhysics()
{
	HideNonFlatMesh();
}

/** If a door lands at an awkward angle, hide it as soon as we can no longer see it */
simulated function HideNonFlatMesh()
{
	if ( !CheckOnFlatGround() )
	{
		StaticMeshComponent.SetActorCollision(false, false);

		if ( `TimeSince( LastRenderTime ) > 1.0 )
		{
			StaticMeshComponent.SetHidden(TRUE);
		}
		else
		{
			SetTimer(1.0f, false, nameof(HideNonFlatMesh), self);
		}
	}
}

/** Check if the door is laying flat on the ground after being destroyed */
function bool CheckOnFlatGround()
{
	local vector DoorX, DoorY, DoorZ;

    GetAxes(Rotation, DoorX, DoorY, DoorZ);
	return ( DoorX.Z < 0.95f ) ? false : true; 
}

defaultproperties
{
	bCallRigidBodyWakeEvents=true
	RemoteRole=ROLE_None
	LifeSpan=0.f
}
