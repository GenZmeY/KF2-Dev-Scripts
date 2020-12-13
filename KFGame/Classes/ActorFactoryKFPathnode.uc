//=============================================================================
// ActorFactoryKFPathnode
//=============================================================================
// This provides an option to place a KFPathnode when a level designer 
// right-clicks a location in a level in the editor
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//=============================================================================
class ActorFactoryKFPathNode extends ActorFactory
	config(Editor)
	collapsecategories
	hidecategories(Object)
	native(Waypoint);

defaultproperties
{
	MenuName="Add KFPathNode"
	NewActorClass=class'KFGame.KFPathNode'
	bShowInEditorQuickMenu=true
}
