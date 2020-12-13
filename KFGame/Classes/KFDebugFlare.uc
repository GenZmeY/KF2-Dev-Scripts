//=============================================================================
// Debug_Flare
//=============================================================================
//
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//=============================================================================

class KFDebugFlare extends Actor;

var PointLightComponent FlareLight;

defaultproperties
{
    Physics = PHYS_Falling
	bCollideActors=true
	bCollideWorld=true

	Begin Object Class=PointLightComponent Name=FlareLightComponent
	    LightAffectsClassification=LAC_STATIC_AFFECTING
		CastShadows=TRUE
		CastDynamicShadows=TRUE
		Brightness=1
		LightColor=(R=255,G=255,B=255)
		Radius=1024
	End Object
	Components.Add(FlareLightComponent)
	FlareLight = FlareLightComponent

	Begin Object Class=StaticMeshComponent Name=FlareMesh
	   StaticMesh = StaticMesh'EditorMeshes.TexPropSphere'
	   Scale = 0.1
	   CastShadow = false
    End Object
	Components.Add(FlareMesh)

	Begin Object Class=CylinderComponent Name=Cylinder
		CollisionRadius=+10.000000
		CollisionHeight=+10.000000
		CollideActors=true
	End Object
	Components.Add(Cylinder)
	CollisionComponent=Cylinder
}
