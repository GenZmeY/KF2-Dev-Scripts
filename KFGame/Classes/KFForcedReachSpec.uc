//=============================================================================
// KFForcedReachSpec
//=============================================================================
// Base KF ForcedReachSpec
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//=============================================================================
class KFForcedReachSpec extends KFReachSpec
	native(Waypoint);

struct native ForcedSpecInfo
{
	var()	vector2D	SpecSize; 
	var() bool			bSupports;
};

var() Vector2D ForcedSpec;

var() array<ForcedSpecInfo>	ForcedSpecInfoList;

var() bool	bSupportsHumanSize;
var() bool	bSupportsCommonSize;
var() bool	bSupportsMaxSize;

cpptext
{
	virtual FPlane PathColor()
	{
		// yellow for forced paths
		return FPlane(1.f, 1.f, 0.f, 0.f);
	}
	virtual FVector GetForcedPathSize( class ANavigationPoint* Start, class ANavigationPoint* End, class AScout* Scout );
	virtual UBOOL IsForced() { return TRUE; }
	virtual UBOOL PrepareForMove( AController * C );
	virtual INT CostFor(APawn* P);
	virtual UBOOL CanBeSkipped( APawn* P ) { return FALSE; }
}

defaultproperties
{
	bSupportsHumanSize=true
	bSupportsCommonSize=true
	bSupportsMaxSize=true
}

