//=============================================================================
// ActorFactoryKFScriptedPlayerPathGoal
//=============================================================================
// This provides an option to place a KFScriptedPlayerPathGoal when a level designer 
// right-clicks a location in a level in the editor
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//=============================================================================
class ActorFactoryKFScriptedPlayerPathGoal extends ActorFactory
	config(Editor)
	collapsecategories
	hidecategories(Object)
	native(Waypoint);

defaultproperties
{
	MenuName="Add KFScriptedPlayerPathGoal"
	NewActorClass=class'KFGame.KFScriptedPlayerPathGoal'
	bShowInEditorQuickMenu=true
}