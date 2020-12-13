//=============================================================================
// Copyright 1998-2012 Epic Games, Inc. All Rights Reserved.
//=============================================================================
class FlexActor extends InterpActor
	native
	placeable;

defaultproperties
{
	Begin Object Class=FlexComponent Name=FlexComponent0
	    BlockRigidBody=false
		LightEnvironment=MyLightEnvironment
		bUsePrecomputedShadows=FALSE
	End Object
	StaticMeshComponent=FlexComponent0
	Components.Remove(StaticMeshComponent0)
	Components.Add(FlexComponent0)
}
