/**
 * Copyright 1998-2013 Epic Games, Inc. All Rights Reserved.
 */
 
class SplineLoftActorMovable extends SplineLoftActor
	placeable
	native(Spline);



defaultproperties
{
	Begin Object Class=DynamicLightEnvironmentComponent Name=MyMeshLightEnvironment
	`if(`__TW_LIGHTING_MODIFICATIONS_)
		bEnabled=False
	`else
		bEnabled=True
	`endif
	End Object
	MeshLightEnvironment=MyMeshLightEnvironment
	Components.Add(MyMeshLightEnvironment)

	Physics=PHYS_Interpolating

	bNoDelete=true
	bStatic=false
	bMovable=true
}
