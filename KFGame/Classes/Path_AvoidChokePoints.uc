//=============================================================================
// Path_AvoidChokePoints.uc
//=============================================================================
// Path constraint for NPCs who prefer navigation points in darker areas
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//=============================================================================
class Path_AvoidChokePoints extends PathConstraint
	native(Waypoint);

cpptext
{
	virtual UBOOL EvaluatePath( UReachSpec* Spec, APawn* Pawn, INT& out_PathCost, INT& out_HeuristicCost );
}

/** Maximum luminance (per navigation point) before adding extra costs */
//var() float	MaxLuminance;

static function bool AvoidChokePoints( Pawn P )
{
	local Path_AvoidChokePoints Con;

	if( P != None )
	{
		Con = Path_AvoidChokePoints(P.CreatePathConstraint(default.class));
		if( Con != None )
		{
			//Con.MaxLuminance = InMaxLuminance;			
			P.AddPathConstraint( Con );
			return true;
		}
	}

	return false;
}

function Recycle()
{
	Super.Recycle();
	//MaxLuminance=default.MaxLuminance;
}

defaultproperties
{
	CacheIdx=13
	//MaxLuminance=0.5f
}
