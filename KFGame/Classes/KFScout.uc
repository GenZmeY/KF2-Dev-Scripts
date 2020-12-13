//=============================================================================
// KFScout
//=============================================================================
// KF2 scout class used when generating AI paths
//=============================================================================
// Killing Floor 2
// Copyright (C) 2012-2013 Tripwire Interactive LLC
//=============================================================================
class KFScout extends Scout
	native(AI);

var config bool						bReplacePathNodesWithKFPathNodes;
var config bool						bDebugReplacePathNodes;
var array< class<KFPawn> >			PrototypePawnClasses;
var int								PrototypeIndex;
var transient array<KFDoorMarker>	KFDoorMarkerList;
var float							TestSprintSpeed;
var float							TestHiddenGroundSpeed;
var float							DefaultMaxFallSpeed;
var float							DefaultJumpZ;

cpptext
{
	virtual void SetBase(AActor *NewBase, FVector NewFloor = FVector(0,0,1), INT bNotifyActor=1, USkeletalMeshComponent* SkelComp=NULL, FName BoneName=NAME_None );
	virtual void SetPrototype();
	virtual void InitForPathing( ANavigationPoint* Start, ANavigationPoint* End );
	virtual UClass* GetDefaultReachSpecClass();
	// To be overridden
	virtual FVector GetDefaultForcedPathSize(UReachSpec* Spec)
	{
		return Super::GetDefaultForcedPathSize(Spec);
	}
	virtual void SetPathColor(UReachSpec* ReachSpec);

#if WITH_EDITOR
	/** Long range reachspecs are evil and pointless, so we won't use them */
	virtual void AddLongReachSpecs( INT NumPaths );
	/** Good riddance to you, horribly annoying godawful senseless long-range-reachspecs! */
	virtual void Exec( const TCHAR* Str );

	UBOOL CreateLeapPath( ANavigationPoint* Nav, ANavigationPoint* DestNav, FCheckResult Hit, UBOOL bOnlyChanged );
	void AddSpecialPaths( INT NumPaths, UBOOL bOnlyChanged );
	virtual void UndefinePaths();
	virtual void DefinePaths( UBOOL bReviewPaths, UBOOL bShowMapCheck, UBOOL bUndefinePaths );
#endif
}

DefaultProperties
{
	PathSizes.Empty
	NavMeshGen_MaxPolyHeight=200.0
	//NavMeshGen_MaxPolyHeight=90.0

	PrototypePawnClasses(0)=class'KFGame.KFPawn_Monster'
	// Note: Human size is also clot size. "Human" is hardcoded all over the engine, so we'll stick with that name
	PathSizes(0)=(Desc=ClotsAllSirenStalker,Radius=36,Height=90)
	PathSizes(1)=(Desc=Human,Radius=40,Height=90)
	PathSizes(2)=(Desc=Crawler,Radius=48,Height=48)
	PathSizes(3)=(Desc=GoreFastHusk,Radius=48,Height=90)
	PathSizes(4)=(Desc=BloatScrakeFleshPoundHans,Radius=55,Height=90)
	PathSizes(5)=(Desc=Max,Radius=120,Height=120)

	EdgePathColors(0)=(R=0,G=0,B=255,A=255) // ClotsAllSirenStalkerBlue, blue
	EdgePathColors(1)=(R=173,G=255,B=47,A=255) // Human, green yellow (173,255,47)
	EdgePathColors(2)=(R=0,G=128,B=0,A=255) // Crawler green (0,255,0)
	EdgePathColors(3)=(R=0,G=255,B=0,A=255) // GoreFastHusk lime (0,128,0)
	EdgePathColors(4)=(R=255,G=255,B=255) // BloatScrakeFleshPoundHans White (255,255,255)
	EdgePathColors(5)=(R=255,G=105,B=180,A=255) // Max (255,105,180); // hot pink


	bHightlightOneWayReachSpecs=true // Epic's spelling error!
	//TestFallSpeed=600
	TestMaxFallSpeed=500
	TestGroundSpeed=500.000
	TestJumpZ=650.f
// __TW_AIJUMPDEBUG_
	MaxStepHeight=70.0
	MaxJumpHeight=128.0
	//TestFallSpeed=1200
	bCanJumpOverWalls=true
	DefaultMaxFallSpeed=500.f
	DefaultJumpZ=650.f
	DefaultReachSpecClass=class'KFGame.KFReachSpec'

	NavMeshGen_StepSize=30.0
	NavMeshGen_MaxGroundCheckSize=30.0f
	NavMeshGen_EntityHalfHeight=72.0
	//NavMeshGen_EntityHalfHeight=24.0
	NavMeshGen_StartingHeightOffset=65.0
	NavMeshGen_MaxDropHeight=250.0
	NavMeshGen_MaxStepHeight=40.0
	NavMeshGen_VertZDeltaSnapThresh=20.0
	NavMeshGen_MinPolyArea=25
	NavMeshGen_BorderBackfill_CheckDist=70.0
	NavMeshGen_MinMergeDotAreaThreshold=2.0
	NavMeshGen_MinMergeDotSmallArea=0.0
	NavMeshGen_MinMergeDotLargeArea=0.95
	//NavMeshGen_MaxPolyHeight=160.0
	NavMeshGen_HeightMergeThreshold=10
	NavMeshGen_EdgeMaxDelta=2.0
	NavMeshGen_MinEdgeLength=7.0
	NavMeshGen_ExpansionDoObstacleMeshSimplification=TRUE

}
