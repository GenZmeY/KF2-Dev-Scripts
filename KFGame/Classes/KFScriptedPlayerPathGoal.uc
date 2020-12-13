//=============================================================================
// KFScriptedPlayerPathGoal
//=============================================================================
// Placed at the end of a scripted path for player-only pathing
//=============================================================================
// Killing Floor 2
// Copyright (C) 2017 Tripwire Interactive LLC
//=============================================================================
class KFScriptedPlayerPathGoal extends PathNode
	native(Waypoint)
	placeable;

/** Override to prevent AI from navigating to this node */
native function bool IsUsableAnchorFor( Pawn P );

defaultproperties
{
	Begin Object NAME=Sprite
		Sprite=Texture2D'EditorResources.S_NavP'
	End Object

	//bStatic=false
	//bMovable=true
	bNotBased=true
	bMustTouchToReach=false
	bCanWalkOnToReach=true
}