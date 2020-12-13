/**
 *
 * Copyright 1998-2013 Epic Games, Inc. All Rights Reserved.
 */


class CeilingReachSpec extends ReachSpec
	native;

cpptext
{
	virtual INT CostFor( APawn* P );
	virtual INT AdjustedCostFor( APawn* P, const FVector& StartToGoalDir, ANavigationPoint* Goal, INT Cost );
#if __TW_PATHFINDING_
	virtual FPlane PathColor()
	{
		return FPlane( 0.89f, 0.565f, 0.294f, 1.f );
	}
#endif
}



defaultproperties
{
}
