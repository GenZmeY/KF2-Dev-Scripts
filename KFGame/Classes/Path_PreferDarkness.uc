//=============================================================================
// Path_PreferDarkness.uc
//=============================================================================
// Path constraint for NPCs who prefer navigation points in darker areas
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//=============================================================================
class Path_PreferDarkness extends PathConstraint
	native(Waypoint);

cpptext
{
	virtual UBOOL EvaluatePath( UReachSpec* Spec, APawn* Pawn, INT& out_PathCost, INT& out_HeuristicCost );
}

/** Maximum luminance (per navigation point) before adding extra costs */
var() float	MaxLuminance;

static function bool DontGoIntoTheLight( Pawn P, float InMaxLuminance )
{
	local Path_PreferDarkness Con;

	if( P != None && InMaxLuminance > 0.f )
	{
		Con = Path_PreferDarkness(P.CreatePathConstraint(default.class));
		if( Con != None )
		{
			Con.MaxLuminance = InMaxLuminance;			
			P.AddPathConstraint( Con );
			return true;
		}
	}

	return false;
}

function Recycle()
{
	Super.Recycle();
	MaxLuminance=default.MaxLuminance;
}

defaultproperties
{
	CacheIdx=12
	MaxLuminance=0.5f
}
