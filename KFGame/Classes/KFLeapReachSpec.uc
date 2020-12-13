//=============================================================================
// KFLeapReachSpec
//=============================================================================
// Special reachspec for wall/ceiling related navigation (Based on GOW2-3)
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//=============================================================================
class KFLeapReachSpec extends AdvancedReachSpec
	native(Waypoint);

cpptext
{
	virtual INT CostFor(APawn* P);
	virtual UBOOL CanBeSkipped(APawn* P)
	{
		return FALSE;
	}
}

var() editconst Vector	CachedVelocity;
var() editconst float	RequiredJumpZ;

defaultproperties
{
	bSkipPrune=TRUE
}
