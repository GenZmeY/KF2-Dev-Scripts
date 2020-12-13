/**
 *
 * Copyright 1998-2013 Epic Games, Inc. All Rights Reserved.
 */


class FloorToCeilingReachSpec extends ForcedReachSpec
	native;

cpptext
{
	virtual INT CostFor(APawn* P);
	virtual INT AdjustedCostFor( APawn* P, const FVector& StartToGoalDir, ANavigationPoint* Goal, INT Cost );
#if __TW_PATHFINDING_
	virtual FPlane PathColor()
	{
		return FPlane(0.83f,0.58f,0.27f,0.f); // Crawler
	}
#endif
}

defaultproperties
{
	bSkipPrune=TRUE
}
