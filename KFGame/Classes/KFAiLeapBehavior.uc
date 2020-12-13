//=============================================================================
// KFAiBallisticProjectileFireBehavior
//=============================================================================
// 
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//=============================================================================
class KFAiLeapBehavior extends KFAiBaseRangedBehavior
	native(AI);

var transient array<Vector> CalculatedArc;
var transient array<Vector> ArcImpacts;

var (LeapCalc) color ValidArcColor;
var (LeapCalc) color InValidArcColor;


cpptext
{
	UBOOL SuggestLeapVelocity( FVector* outLeapVelocity,
							const FVector& Dest,
							const FVector& Start,
							FLOAT DesiredLeapSpeed,
							FLOAT MinSpeedAllowed,
							FLOAT MaxSpeedAllowed,
							FLOAT BaseLeapZ,
							FLOAT DesiredZPct,
							const FVector& CollisionSize,
							FLOAT TerminalVelocity,
							FLOAT OverrideGravityZ = 0.f,
							UBOOL bUseDeadReckoning = FALSE,
							const FVector& TargetVelocity = FVector(0,0,1),
							UBOOL bOnlyTraceUp = FALSE,
							UBOOL bShowDebugArtifacts = FALSE,
							UBOOL bPreLobCalc = FALSE,
							INT LobStrikeValidationIdx = -1 );

	static UBOOL staticSuggestLeapVelocity( UKFAiLeapBehavior* BehInstance,
											AActor* ActorFor,
											FVector* outLeapVelocity,
											TArray<FVector>& outArcVerts,
											TArray<FVector>& outImpactLoc,
											const FVector& Dest,
											const FVector& Start,
											FLOAT DesiredLeapSpeed,
											FLOAT MinSpeedAllowed,
											FLOAT MaxSpeedAllowed,
											FLOAT BaseLeapZ,
											FLOAT DesiredZPct,
											const FVector& CollisionSize,
											FLOAT TerminalVelocity,
											FLOAT OverrideGravityZ = 0.f,
											UBOOL bUseDeadReckoning = FALSE,
											const FVector& TargetVelocity = FVector(0,0,1),
											UBOOL bOnlyTraceUp = FALSE,
											UBOOL bShowDebugArtifacts = FALSE,
											UBOOL bPreLobCalc = FALSE,
											INT LobStrikeValidationIdx = -1 );




}


/* Chad's Version of an epic methods ===============================================
* ::SuggestLeapVelocity()
*
* returns a recommended leap velocity vector, given a destination and a leap speed magnitude
* @param outLeapVelocity - out param stuffed with the computed velocity to use
* @param End - desired end point of arc
* @param Start - desired start point of arc
* @param DesiredLeapSpeed - in the magnitude of the leap - assumed to only change due to gravity for the entire lifetime of the projectile
* @param BaseLeapZ - is an additional Z direction force added to the leap (which will not be included in the returned outLeapVelocity) - (defaults to 0)
* @param DesiredZPct (optional) - is the requested pct of the leap in the z direction (0=leap horizontally, 0.5 = leap at 45 degrees).  This is the starting point for finding a leap.  (Defaults to 0.05).
*		the purpose of this is to bias the test in cases where there is more than one solution
* @param CollisionSize (optional) - is the size of bunding box of the leaping actor (defaults to (0,0,0)
* @param TerminalVelocity (optional) - terminal velocity of the projectile
* @param OverrideGravityZ (optional) - gravity inflicted upon the projectile in the z direction
* @param bOnlyTraceUp  (optional) - when TRUE collision checks verifying the arc will only be done along the upward portion of the arc
* @return - TRUE/FALSE depending on whether a valid arc was computed
*/
native noexport final function bool SuggestLeapVelocity(out vector outLeapVelocity,
														vector Destination,
														vector Start,
														float DesiredLeapSpeed,
														optional float MinSpeedAllowed,
														optional float MaxSpeedAllowed,
														optional float BaseLeapZ,
														optional float DesiredZPct,
														optional vector CollisionSize,
														optional float TerminalVelocity,
														optional float OverrideGravityZ /* = GetGravityZ() */,
														optional bool bUseDeadReckoning,
														optional const vector TargetVelocity,
														optional bool bOnlyTraceUp,
														optional bool bShowDebugArtifacts,
														optional bool bPreLobCalc,
														optional int LobStrikeValidationIdx );


function DrawDebugLastValidLeapArcCalced( vector FromLoc )
{
	local int idx;
	local vector lastArcLoc;

	lastArcLoc = FromLoc;

	for( idx = 0; idx < CalculatedArc.Length; ++idx )
	{
		DrawDebugLine( lastArcLoc, CalculatedArc[idx], ValidArcColor.R, ValidArcColor.G, ValidArcColor.B, true );
		lastArcLoc = CalculatedArc[idx];
	}
} 

function DrawDebugLastLeapArcCalcedArcImpacts()
{
	local int idx;

	for( idx = 0; idx < ArcImpacts.Length; ++idx )
	{
		DrawDebugStar( ArcImpacts[idx], 25,  InValidArcColor.R, InValidArcColor.G, InValidArcColor.B, true );
	}
} 

DefaultProperties
{
	// darkorange 	#FF8C00 	255 	140 	0 	36095
	ValidArcColor=(R=255,G=140,B=0,A=255)
	// Whore of Babylon (252, 40, 71)
	InValidArcColor=(R=252,G=40,B=71,A=255)
}

