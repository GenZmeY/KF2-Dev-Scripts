//=============================================================================
// FloorToWallReachSpec
//=============================================================================
// 
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//=============================================================================

class FloorToWallReachSpec extends KFForcedReachSpec
	native(Waypoint);

cpptext
{ 
	virtual INT CostFor(APawn* P);
	virtual INT AdjustedCostFor( APawn* P, const FVector& StartToGoalDir, ANavigationPoint* Goal, INT Cost );
	virtual void AddToDebugRenderProxy(class FDebugRenderSceneProxy* DRSP);
	virtual FVector GetForcedPathSize( class ANavigationPoint* Start, class ANavigationPoint* End, class AScout* Scout );
	virtual FPlane PathColor()
	{
		return FPlane(0.f,1.f,1.f,0.f);
	}
	virtual UBOOL CanBeSkipped(APawn* P)
	{
		return FALSE;
	}
	virtual FVector GetInitialVelocity();
}


DefaultProperties
{
	bSkipPrune=true
	bCanCutCorners=false
	//bCheckForObstructions=false
}