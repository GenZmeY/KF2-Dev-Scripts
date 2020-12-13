//=============================================================================
// Path_ToTrader
//=============================================================================
// Avoids any pathnodes flagged as bIgnoredByTraderTrail
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//=============================================================================
class Path_ToTrader extends PathConstraint
	native(Waypoint);

cpptext
{
	// Interface
	virtual UBOOL EvaluatePath( UReachSpec* Spec, APawn* Pawn, INT& out_PathCost, INT& out_HeuristicCost );
}

static function bool ToTrader( Pawn P )
{
	local Path_ToTrader PTT;

	if( P != None )
	{
		PTT = Path_ToTrader( P.CreatePathConstraint(default.class) );
		if( PTT != None )
		{
			P.AddPathConstraint( PTT );
			return true;
		}
	}

	return false;
}

defaultproperties
{
	CacheIdx=19
}