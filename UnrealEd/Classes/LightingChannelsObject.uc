/**
 * Copyright 1998-2013 Epic Games, Inc. All Rights Reserved.
 */
/** Container class for LightingChannelContainer, so they can be edited in an editor property window. */
class LightingChannelsObject extends Object
	native
	hidecategories(Object);

/** The edited lighting channels. */
var() const LightingChannelContainer LightingChannels;

defaultproperties
{
`if(`__TW_LIGHTING_MODIFICATIONS_)  // Custom lighting channel implementation
	LightingChannels=(bInitialized=TRUE,Indoor=TRUE,Outdoor=TRUE)
`else
	LightingChannels=(bInitialized=TRUE,BSP=TRUE)
`endif
}
