//=============================================================================
// KFPawnBlockingVolume
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//=============================================================================

class KFPawnBlockingVolume extends BlockingVolume
	native(Pawn)
	placeable;

/** whether to block PCs */
var() bool bBlockPlayers<DisplayName=Block Human Players>;
/** whether to block PC controlled zeds (team == 255) */
var() bool bBlockZedPlayers;

/** whether to block NPCs */
var() bool bBlockMonsters<DisplayName=Block AI>;

cpptext
{
	// Since we use Actor::IsPlayerOwned, ShouldTrace will only work properly on
	// Role > ROLE_SimulatedProxy which is good enough for us.  To use IgnoreBlockingBy
	// we would need to set bWorldGeometry=FALSE and use a const_cast (see GoW).
	UBOOL ShouldTrace( UPrimitiveComponent* Primitive, AActor* SourceActor, DWORD TraceFlags );
}

defaultproperties
{
	bBlockPlayers=true
	bBlockMonsters=false

	BlockRigidBody=false
}
