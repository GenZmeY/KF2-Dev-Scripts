//=============================================================================
// Goal_AwayFromPosition
//=============================================================================
// Rates goals based on how far away they are from target
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//=============================================================================
// Based on GOW Goal_AwayFromPosition
// Copyright 1998-2011 Epic Games, Inc. All Rights Reserved.
//=============================================================================
class Goal_AwayFromPosition extends PathGoalEvaluator
	native(Waypoint);

cpptext
{
	virtual UBOOL EvaluateGoal(ANavigationPoint*& PossibleGoal, APawn* Pawn);
	virtual UBOOL DetermineFinalGoal( ANavigationPoint*& out_GoalNav );
}

/** Location to flee from */
var vector AvoidPos;

/** Cached direction from AvoidPos to Pawn.Location */
var vector AvoidDir;

/** Exit with the best result so far if the travel distance to the nodes being evaluated exceeds this */
var int MaxDist;

/** Best node away from AvoidDir we've found so far */
var NavigationPoint BestNode;
var int BestRating;

static function bool FleeFrom(Pawn P, vector InAvoidPos, int InMaxDist)
{
	local Goal_AwayFromPosition Eval;

	Eval = Goal_AwayFromPosition(P.CreatePathGoalEvaluator(default.class));
	Eval.AvoidPos = InAvoidPos;
	Eval.AvoidDir = Normal2D(InAvoidPos - P.Location);
	Eval.MaxDist = InMaxDist;
	P.AddGoalEvaluator(Eval);
	return true;
}

event Recycle()
{
	Super.Recycle();
	BestNode = None;
	BestRating = 0;
}

defaultproperties
{
	CacheIdx=7
}
