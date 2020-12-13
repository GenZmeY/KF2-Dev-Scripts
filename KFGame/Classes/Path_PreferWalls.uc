//=============================================================================
// Path_AvoidChokePoints.uc
//=============================================================================
// Path constraint for NPCs who prefer navigation points in darker areas
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//=============================================================================
class Path_PreferWalls extends PathConstraint
	native(Waypoint);

var bool 	bOnlyAcceptWallNodes;
var int 	FloorNodeCost;
var bool 	bAvoidEnemy;

cpptext
{
	virtual UBOOL EvaluatePath( UReachSpec* Spec, APawn* Pawn, INT& out_PathCost, INT& out_HeuristicCost );
}

static function bool PreferWalls( Pawn P, optional bool InOnlyAcceptWallNodes=false, optional int InFloorNodeCost=10000, optional bool InAvoidEnemy=false )
{
	local Path_PreferWalls Con;

	if( P != None )
	{
		Con = Path_PreferWalls( P.CreatePathConstraint(default.class) );
		if( Con != None )
		{
			Con.FloorNodeCost		 = InFloorNodeCost;
			Con.bOnlyAcceptWallNodes = InOnlyAcceptWallNodes;
			Con.bAvoidEnemy			 = InAvoidEnemy;
			P.AddPathConstraint( Con );
			return true;
		}
	}

	return false;
}

function Recycle()
{
	Super.Recycle();
}

defaultproperties
{
	CacheIdx=16
}
