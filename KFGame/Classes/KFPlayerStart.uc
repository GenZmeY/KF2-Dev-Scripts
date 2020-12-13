//=============================================================================
// KFPlayerStart
//=============================================================================
// Class Description
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//  - Author 2/10/2014
//=============================================================================

class KFPlayerStart extends PlayerStart;

/** Saves enabled state at map start for restore on reset */
var transient bool bDefaultEnabled;

function PreBeginPlay()
{
	super.PreBeginPlay();

	bDefaultEnabled = bEnabled;
}

function Reset()
{
	super.Reset();
	
	bEnabled = bDefaultEnabled;
}

defaultproperties
{
	Begin Object NAME=CollisionCylinder
		CollisionRadius=+0036.000000
		CollisionHeight=+00086.000000
	End Object
}
