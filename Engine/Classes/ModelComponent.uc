/**
 * Copyright 1998-2013 Epic Games, Inc. All Rights Reserved.
 */
class ModelComponent extends PrimitiveComponent
	native
	noexport;


/** These mirror the C++ side properties. I'm making a class here so
    ModelComponent will get the defaultprops from the PrimitiveComponent base class */
var transient native const noexport object Model;
var transient native const noexport int ZoneIndex;
var transient native const noexport int ComponentIndex; // (note that this is a WORD in C++, but alignment will make everything line up okay)
var transient native const noexport array<pointer> Nodes;
var transient native const noexport array<pointer> Elements;

defaultproperties
{
`if(`__TW_LIGHTING_MODIFICATIONS_)  // Custom lighting channel implementation
	LightingChannels=(Indoor=TRUE,bInitialized=TRUE)
`else
	LightingChannels=(BSP=TRUE,bInitialized=TRUE)
`endif
	CastShadow=TRUE
	bAcceptsLights=TRUE
	bAcceptsStaticDecals=TRUE
	bAcceptsDecals=TRUE
	bUsePrecomputedShadows=TRUE
	bUseAsOccluder=TRUE
}
