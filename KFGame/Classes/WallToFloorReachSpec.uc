//=============================================================================
// WallToFloorReachSpec
//=============================================================================
// Path connection leading from a navigation point based on a wall/ceiling to
// a navigation point on the walkable floor.
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//=============================================================================

class WallToFloorReachSpec extends KFForcedReachSpec
	native(Waypoint);

var() bool bJumpDownTo;

cpptext
{
	virtual FVector GetForcedPathSize( class ANavigationPoint* Start, class ANavigationPoint* End, class AScout* Scout );
	virtual INT CostFor(APawn* P);
	virtual INT AdjustedCostFor( APawn* P, const FVector& StartToGoalDir, ANavigationPoint* Goal, INT Cost );
	virtual UBOOL CanBeSkipped(APawn* P)
	{
		return FALSE;
	}
	virtual FPlane PathColor()
	{
		return FPlane(0.5f,0.f,0.5f,0.f);
	}
}


DefaultProperties
{
	bJumpDownTo=true
	bSkipPrune=true
	bCanCutCorners=false
	bCheckForObstructions=false
}