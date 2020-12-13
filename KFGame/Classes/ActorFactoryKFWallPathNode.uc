//=============================================================================
// ActorFactoryKFWallPathNode
//=============================================================================
// This provides an option to place a KFWallPathnode when a level designer 
// right-clicks a location in a level in the editor
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//=============================================================================
class ActorFactoryKFWallPathNode extends ActorFactory
	config(Editor)
	collapsecategories
	hidecategories(Object)
	native(Waypoint);

defaultproperties
{
	MenuName="Add KFWallPathNode"
	NewActorClass=class'KFGame.KFWallPathNode'
	bShowInEditorQuickMenu=true
}
