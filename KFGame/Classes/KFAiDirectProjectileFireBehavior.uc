//=============================================================================
// KFAiDirectProjectileFireBehavior
//=============================================================================
// 
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//=============================================================================
class KFAiDirectProjectileFireBehavior extends KFAiBaseRangedBehavior
	native(AI);


native static function bool LosTestForAttackLane(   Vector From,
													Vector To,
													float Radius,
													optional float Height,
													optional out Vector HitLoc,
													optional const out array<Actor> IgnoreActors,
													optional const out array< class<Actor> > IgnoreActorsClasses,
													optional out ImpactInfo outImpactInfo);


/**
 * IsThereClearDirectFireAttackLaneFromGivenLoc
 *  
 */
function bool IsThereClearDirectFireAttackLaneFromGivenLoc( vector PointToStrikeFrom, Actor TheTarget )
{
	local vector targetsOffsetForCals;
	local vector displacementToTarget;
	local vector pointToCalcLaunchFrom;
	local vector locationOfBlockage;
	local Quat qRot;

	local array< actor > losIgnoreActors;
	local array< class<Actor> > losIgnoreActorsClasses;

	local bool bfoundLane;
	local RangedLocValidationData newData;
	
	targetsOffsetForCals = TheTarget.Location;
	targetsOffsetForCals.Z += 10.0f;

	displacementToTarget = targetsOffsetForCals - PointToStrikeFrom;

	QRot = QuatFromRotator( Rotator(displacementToTarget) );
	pointToCalcLaunchFrom = QuatRotateVector( QRot, OffsetForCalcOfForStrike );

	pointToCalcLaunchFrom = pointToCalcLaunchFrom + PointToStrikeFrom;
	
	if( TotalNumOfAttemptsToFindFireStrikeLaneThisEngagement > 0 )
	{
		if( StrikeLocValidationInfoList.Length <= TotalNumOfAttemptsToFindFireStrikeLaneThisEngagement )
		{
			StrikeLocValidationInfoList.AddItem(newData);
			//StrikeLocValidationInfoList[TotalNumOfAttemptsToFindFireStrikeLaneThisEngagement].bCalulatedThisEngagement = true;
			SetAllPastStrikeLocValidationInfoToExpired();
		}

		StrikeLocValidationInfoList[TotalNumOfAttemptsToFindFireStrikeLaneThisEngagement].bCalulatedThisEngagement = true;

		StrikeLocValidationInfoList[TotalNumOfAttemptsToFindFireStrikeLaneThisEngagement].LogAlgosSegmentValiditys.Length = 0;
		StrikeLocValidationInfoList[TotalNumOfAttemptsToFindFireStrikeLaneThisEngagement].LogAlgosSegmentEnds.Length = 0;

		StrikeLocValidationInfoList[TotalNumOfAttemptsToFindFireStrikeLaneThisEngagement].FireLastPointToStrikeFrom = pointToCalcLaunchFrom;
	}

	losIgnoreActors.AddItem( MyKfPawn) ;
	losIgnoreActors.AddItem( TheTarget );
	losIgnoreActorsClasses.AddItem( class'KFPawn_Monster' );


	bfoundLane = LosTestForAttackLane( pointToCalcLaunchFrom, // Vector From,
										targetsOffsetForCals, // Vector To,
										Outer.BaseShapeOfProjectileForCalc.X, // StrikeInfoByZone[CurrentZone].ShapeOfProjectileForFireCalc.X, // float Radius,
										Outer.BaseShapeOfProjectileForCalc.Z, // StrikeInfoByZone[CurrentZone].ShapeOfProjectileForFireCalc.Z, // optional float Height,
										locationOfBlockage, // optional out Vector HitLoc,
										losIgnoreActors, // optional const out array<Actor> IgnoreActors,
										losIgnoreActorsClasses, // optional const out array< class<Actor> > IgnoreActorsClasses,
										StrikeLaneBlockageImpactInfo ); // optional out ImpactInfo outImpactInfo);

	if( TotalNumOfAttemptsToFindFireStrikeLaneThisEngagement > 0 )
	{
		StrikeLocValidationInfoList[TotalNumOfAttemptsToFindFireStrikeLaneThisEngagement].LogAlgosSegmentEnds.AddItem(targetsOffsetForCals);

		StrikeLocValidationInfoList[TotalNumOfAttemptsToFindFireStrikeLaneThisEngagement].FireLastLocOfBlockage = locationOfBlockage;

		if ( bfoundLane )
		{
			StrikeLocValidationInfoList[TotalNumOfAttemptsToFindFireStrikeLaneThisEngagement].LogAlgosSegmentValiditys.AddItem(TRUE);
			return true;
		}
		else
		{
			StrikeLocValidationInfoList[TotalNumOfAttemptsToFindFireStrikeLaneThisEngagement].LogAlgosSegmentValiditys.AddItem(false);
			`AiLog("IsThereClearDirectFireAttackLaneFromGivenLoc - Not a clear Fire lane- Direct Fire point to target loc: " $ VSize(pointToCalcLaunchFrom - targetsOffsetForCals) );
			return false;
		}
	}

	return bfoundLane;
}


DefaultProperties
{
}

