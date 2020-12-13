//=============================================================================
// Goal_WallToEnemy
//=============================================================================
// Returns (as goal) the KFWallPathNode that's closest to enemy, as long as
// enemy will be visible from that potential goal. Used to find ambush spots
// on walls for Crawlers.
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//=============================================================================
// Based on GOW Goal_FarthestNavInRange
// Copyright 1998-2011 Epic Games, Inc. All Rights Reserved.
//=============================================================================
class Goal_WallToEnemy extends PathGoalEvaluator
	native(Waypoint);

cpptext
{
	virtual UBOOL EvaluateGoal(ANavigationPoint*& PossibleGoal, APawn* Pawn);
	virtual UBOOL DetermineFinalGoal(ANavigationPoint*& out_GoalNav);
}

var NavigationPoint BestNode;
var int				OptimalMaxDist;
var float			BestNavDist;

/** current best result */
//var NavigationPoint CurrentBest;

static function bool WallToEnemy(Pawn P, optional int InOptimalMaxDist=3000)
{
	local Goal_WallToEnemy Eval;

	Eval = Goal_WallToEnemy(P.CreatePathGoalEvaluator(default.class));

	Eval.OptimalMaxDist = InOptimalMaxDist;
	P.AddGoalEvaluator(Eval);
	return true;
}

function Recycle()
{
	OptimalMaxDist = default.OptimalMaxDist;
	BestNode = none;
	Super.Recycle();
}

defaultproperties
{
	CacheIdx=18
	MaxPathVisits=10000 // don't want it to fail for this reason, reduce OptimalMaxDist to improve performance instead
}
