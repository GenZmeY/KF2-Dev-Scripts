/**
 * Dominant version of DirectionalLight that generates static shadow maps.
 * There can only be one!
 *
 * Copyright 1998-2013 Epic Games, Inc. All Rights Reserved.
 */
class DominantDirectionalLight extends DirectionalLight
	native(Light)
	ClassGroup(Lights,DirectionalLights)
	placeable;

cpptext
{
	// UObject interface
#if WITH_EDITOR
	virtual void CheckForErrors();
#endif

	/**
	 * Returns true if the light supports being toggled off and on on-the-fly
	 **/
	virtual UBOOL IsToggleable() const
	{
		return TRUE;
	}
}

defaultproperties
{
	// Light component.
	Begin Object Class=DominantDirectionalLightComponent Name=DominantDirectionalLightComponent0
	    LightAffectsClassification=LAC_DYNAMIC_AND_STATIC_AFFECTING

	    CastShadows=TRUE
	    CastStaticShadows=TRUE
	    CastDynamicShadows=TRUE
	    bForceDynamicLight=FALSE
	    UseDirectLightMap=FALSE
        bAllowPreShadow=TRUE
`if(`__TW_LIGHTING_MODIFICATIONS_)  // Custom lighting channel implementation
		LightingChannels=(Outdoor=TRUE,bInitialized=TRUE)
`else
	    LightingChannels=(BSP=TRUE,Static=TRUE,Dynamic=TRUE,bInitialized=TRUE)
`endif
        LightmassSettings=(LightSourceAngle=.2)
	End Object
	Components.Remove(DirectionalLightComponent0)
    LightComponent=DominantDirectionalLightComponent0
	Components.Add(DominantDirectionalLightComponent0)

	bMovable=FALSE
	bStatic=FALSE
	bHardAttach=TRUE
}
