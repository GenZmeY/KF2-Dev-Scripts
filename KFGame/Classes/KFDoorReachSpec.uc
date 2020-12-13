//=============================================================================
// KFDoorReachSpec
//=============================================================================
// ReachSpec used for paths going through KFDoorActors (used by KFDoorMarkers)
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//=============================================================================
class KFDoorReachSpec extends KFReachSpec
	native(Waypoint);

cpptext
{
	virtual INT		CostFor( APawn* P );
	virtual UBOOL	CanBeSkipped( APawn* P );
}

DefaultProperties
{
}
