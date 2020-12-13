//=============================================================================
// KFReachSpec
//=============================================================================
// Default ReachSpec used by KFScout
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//=============================================================================
class KFReachSpec extends ReachSpec
	native(Waypoint);

/** If true, this ReachSpec will be blocked if the pathfinding NPC is using super speed */
var bool	bBlockedForSuperSpeed;

cpptext
{
	virtual UBOOL PrepareForMove( AController * C );
	virtual INT CostFor( APawn* P );
	virtual UBOOL CanBeSkipped( APawn* P );
	virtual FPlane PathColor();
}

native function bool HasJumpFlag();
native function bool HasJumpAndWalkFlag();
native function bool IsForcedSpec();
native function bool IsWallToCeiling();
native function bool IsPathBlockedByPawn( Pawn CheckPawn, optional out Pawn BlockingPawn );

defaultproperties
{
}
