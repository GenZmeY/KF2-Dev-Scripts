//=============================================================================
// KFAiBaseRangedBehavior.uc
//=============================================================================
// 
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//=============================================================================
class KFAiBaseRangedBehavior extends Object within KFAiController
	native(AI);

/**
 * RangedLocValidationData
 */
struct native RangedLocValidationData
{
    var bool                          bCalulatedThisEngagement;
    var bool                          bLastLosArcCheckValid;
    var float                         RadiusOfFireCheckPath;
    var vector                        FireLastPointToStrikeFrom;
    var vector                        FireLastLocOfEndOfArc;
    var vector                        FireLastLocOfBlockage;

    var array<vector>                 LogAlgosSegmentEnds;
    var array<bool>                   LogAlgosSegmentValiditys;
};


var KFAIController MyAiCtrl;

//
// Ranged attack info
//
var transient array<RangedLocValidationData>     StrikeLocValidationInfoList;
var protected transient int                      StrikeZoneForCurrentAttack;

var transient array<vector>                      ProjMeshLocations;
var transient vector                             ProjImpactLocation;
var transient vector                             ProjExplosionLocation;
var transient int                                StrikeLastCalcArcSuccessId;

var transient array<vector>                      LogAlgosSegmentEnds;
var transient array<bool>                        LogAlgosSegmentValiditys;
var transient vector                             FireLastLocOfBlockage;
var transient vector                             FireLastLocOfTarget;
var transient vector                             ProjStartLocation;

var int                                          TotalNumberOfPossibileFireLocationsPerFormationSlot;

var protected bool                               bIntentionalMiss;

/**
 * RangedStrikeData
 */
struct native RangedStrikeData
{
	/** */
	var() float HeightAboveTargetForRangedStrikeInUU;
	/** */
	var() float XY_DistanceFromTargetForRangedStrikeInUU;

	/** */
	var float XY_DistanceSqFromTargetForRangedStrikeInUU;

	/** */
	var() float RangedFireIdealSpeed;
	/** */
	var() float RangedFireMaxSpeed;
	/** */
	var() float RangedFireMinSpeed;

	/**  is the requested pct of the arc in the z direction (0=arc horizontally, 0.5 = arc at 45 degrees).  This is the starting point for finding a arc.  (Defaults to 0.05).	the purpose of this is to bias the test in cases where there is more than one solution*/
	var() float DesiredZPercentOfArc;

	/** IntentionalMissRangedFireIdealSpeed */
	var() float IntentionalMissRangedFireIdealSpeed;
	/** IntentionalMissRangedFireMaxSpeed */
	var() float IntentionalMissRangedFireMaxSpeed;
	/** IntentionalMissRangedFireMinSpeed */
	var() float IntentionalMissRangedFireMinSpeed;

	/**  is the requested pct of the arc in the z direction (0=arc horizontally, 0.5 = arc at 45 degrees).  This is the starting point for finding a arc.  (Defaults to 0.05).	the purpose of this is to bias the test in cases where there is more than one solution*/
	var() float IntentionalMissDesiredZPercentOf;

	/** IntentionalMissFrontOffsetDistance */
	var() float IntentionalMissFrontOffsetDistance;

	/** IntentionalMissSideOffsetDistance */
	var() float IntentionalMissSideOffsetDistance;

	/** IntentionalMissHeightOffsetDistance */
	var() float IntentionalMissHeightOffsetDistance;

	/** */
	var() vector ShapeOfProjectileForCalc;

	/** */
	var() float PercentOfArcToCheckForCalc;

	/** Alternate percentage of arcs to check after the defult beam the pill in value in order of Preferred arc*/
	var() array<float> AltDesiredZPercentOfList;

	structdefaultproperties
	{
		HeightAboveTargetForRangedStrikeInUU=100;
		XY_DistanceFromTargetForRangedStrikeInUU=1100;
		RangedFireIdealSpeed=1200.0;
		RangedFireMaxSpeed=2500;
		RangedFireMinSpeed=100;
		DesiredZPercentOfArc=0.1;
		IntentionalMissRangedFireIdealSpeed=1200.0;
		IntentionalMissRangedFireMaxSpeed=2500;
		IntentionalMissRangedFireMinSpeed=100;
		IntentionalMissDesiredZPercentOf=0.2;
		IntentionalMissFrontOffsetDistance=100;
		IntentionalMissSideOffsetDistance=0;
		IntentionalMissHeightOffsetDistance=0;
		ShapeOfProjectileForCalc=(x=1.0f,y=1.0f,z=1.0f);
		PercentOfArcToCheckForCalc=1.0f
	}
};

//
// Ranged Strike
//
/** SleepTimeDuringRangeAttackDamageAssessment */
var (RangedStrike) float SleepTimeDuringRangeAttackDamageAssessment;

/** How far from the VS the flyer should be at when striking */
var (RangedStrike) bool bUseTargetsCurrentLocAtRelease;

/** How far from the VS the flyer should be at when striking */
var (RangedStrike) float NumOfStrikeLocationsToLookForAtEachRange;

/** How far from the VS the flyer should be at when striking */
var (RangedStrike) float HorizontalSeperationBetweenPointsForStrike;

/** How far from the location of the pawn to the location where the projectile will be spawned */
var (RangedStrike) vector OffsetForCalcOfForStrike;

/** MinRangeFromOrbitBeforeLookingForTierOffsetStrikeLocations */
var (RangedStrike) float MinRangeFromOrbitBeforeLookingForTierOffsetStrikeLocations;

/** How far from the VS the flyer should be at when striking */
var (RangedStrike) int ForceAllAttacksFromThisTier;

/** How far from the VS the flyer should be at when striking */
var (RangedStrike) int ForceAllAttacksFromThisZone;

/** This data is used for normal from any where position ing */
var (RangedStrike) array<RangedStrikeData> StrikeInfoByZone;

/** bCheckIfCanMoveToStrikeLocationBeforeTestingForLane */
var (RangedStrike) bool bCheckIfCanMoveToStrikeLocationBeforeTestingForLane;

/** How far from the VS the flyer should be at when striking */
var (RangedStrike) float HieghtOffTargetPointForEndOfFireArc;

/** bAbleToAdjustAimPositionForGameplay */
var (RangedStrike) bool bAbleToAdjustAimPositionForGameplay;

/** IntentionalMissChance */
var (RangedStrike) float IntentionalMissChance;


var transient int TotalNumOfAttemptsToFindFireStrikeLaneThisEngagement;

var transient ImpactInfo StrikeLaneBlockageImpactInfo;


function SetUp()
{
	local RangedLocValidationData newLocData;
	local int iter;

	TotalNumOfAttemptsToFindFireStrikeLaneThisEngagement = -1;

	TotalNumberOfPossibileFireLocationsPerFormationSlot = NumOfStrikeLocationsToLookForAtEachRange;

    for( iter = 0; iter < TotalNumberOfPossibileFireLocationsPerFormationSlot; ++iter)
    {
        StrikeLocValidationInfoList.AddItem(newLocData);
    }

	InitRangeFireData();

}

/**
 * InitRangeFireData
 *	
 */
simulated function InitRangeFireData()
{

	local int iter;

	StrikeLastCalcArcSuccessId = -1;


	for( iter = 0; iter < StrikeInfoByZone.Length; ++iter )
	{
		StrikeInfoByZone[iter].XY_DistanceSqFromTargetForRangedStrikeInUU = StrikeInfoByZone[iter].XY_DistanceFromTargetForRangedStrikeInUU * StrikeInfoByZone[iter].XY_DistanceFromTargetForRangedStrikeInUU;
	}

}


function float GetRangedFireMidZoneRangeForThisZone( int Zone )
{
	return 1000.0;
}

native final function int FindCurrentFireFromAnywhereZone( Actor TargetOfLob );

function vector GetBestCurrentVelocityForThisTarget( Actor TargetToCalcFor )
{
	if( TargetToCalcFor != none )
	{
		return TargetToCalcFor.Velocity;
	}

	return Vect(0.0,0.0,0.0);
}

/**
 * SetRangedLobStrikeZoneInfo
 * 
 */
function SetStrikeZoneInfo( int ZoneId )
{
	StrikeZoneForCurrentAttack = ZoneId;
}


function DrawFireAttackDebug()
{
	local int iter;
	local int iterLobArc;
	local vector previousLobArcLoc;

	for( iter = 0; iter < StrikeLocValidationInfoList.Length; ++iter)
	{
		if( StrikeLocValidationInfoList[iter].bCalulatedThisEngagement )
		{
			previousLobArcLoc = StrikeLocValidationInfoList[iter].FireLastPointToStrikeFrom;

			for( iterLobArc = 0; iterLobArc < StrikeLocValidationInfoList[iter].LogAlgosSegmentEnds.Length; ++iterLobArc)
			{
				if( StrikeLocValidationInfoList[iter].LogAlgosSegmentValiditys[iterLobArc] )
				{
					DrawDebugLine( previousLobArcLoc, StrikeLocValidationInfoList[iter].LogAlgosSegmentEnds[iterLobArc], 127, 255, 212 );
				}
				else
				{
					if( StrikeLocValidationInfoList[iter].FireLastLocOfBlockage == Vect(0,0,0) )
					{
						// this arc failed because could not get it up enough 
						DrawDebugLine( previousLobArcLoc, StrikeLocValidationInfoList[iter].LogAlgosSegmentEnds[iterLobArc], 28, 255, 174 );

						DrawDebugStar( previousLobArcLoc, 75, 28, 255, 174);
					}
					else
					{
						DrawDebugLine( previousLobArcLoc, StrikeLocValidationInfoList[iter].LogAlgosSegmentEnds[iterLobArc], 255, 28, 174 );

						DrawDebugStar( StrikeLocValidationInfoList[iter].FireLastLocOfBlockage, 25, 255, 28, 174 );
					}
				}

				previousLobArcLoc = StrikeLocValidationInfoList[iter].LogAlgosSegmentEnds[iterLobArc];

			}
		}
		else
		{
			break;
		}

	} // end for( iter = 0; iter < StrikeLocValidationInfoList.Length; ++iter)


	if( FireLastLocOfBlockage != vect(0,0,0) )
	{
		DrawDebugStar( FireLastLocOfBlockage, 25, 255, 0, 255);
	}

	if( FireLastLocOfTarget != vect(0,0,0) )
	{
		DrawDebugStar( FireLastLocOfTarget, 25, 0, 255, 0);
	}

	previousLobArcLoc = MyKfPawn.Location;

    for( iter = 0; iter < LogAlgosSegmentEnds.Length; ++iter)
    {
        if( LogAlgosSegmentValiditys[iter] )
        {
            if( StrikeLastCalcArcSuccessId == 1 )
            {
                DrawDebugLine( previousLobArcLoc, LogAlgosSegmentEnds[iter], 0, 255, 0 );
                DrawDebugStar( LogAlgosSegmentEnds[iter], 5, 0, 255, 0);
            }
            else
            {
                DrawDebugLine( previousLobArcLoc, LogAlgosSegmentEnds[iter], 0, 0,255 );
                DrawDebugStar( LogAlgosSegmentEnds[iter], 5, 0, 0, 255);
            }
        }
        else
        {
            DrawDebugLine( previousLobArcLoc, LogAlgosSegmentEnds[iter], 255, 0, 0 );

            DrawDebugStar( FireLastLocOfBlockage, 25, 255, 0, 255);
        }

        previousLobArcLoc = LogAlgosSegmentEnds[iter];
    }

    DrawDebugStar( ProjStartLocation, 25, 255, 0, 0);


    for( iter = 0; iter < ProjMeshLocations.Length; ++iter)
    {
        DrawDebugStar( ProjMeshLocations[iter], 5, 0, 255, 255);
    }
   
	if( ProjExplosionLocation != vect(0,0,0) )
	{
		DrawDebugSphere( ProjExplosionLocation, 35, 8, 255,0,255);
	}

	if( ProjImpactLocation != vect(0,0,0) )
	{
		DrawDebugSphere( ProjImpactLocation, 25, 8, 0, 255, 255);
	}
}


function SetAllPastStrikeLocValidationInfoToExpired()
{
	local int iter;

	for( iter = 0; iter < StrikeLocValidationInfoList.Length -1; ++iter)
	{
		StrikeLocValidationInfoList[iter].bCalulatedThisEngagement = false;
	}
}

DefaultProperties
{
	OffsetForCalcOfForStrike=(x=0.0,y=0.0,z=0.0)
}

