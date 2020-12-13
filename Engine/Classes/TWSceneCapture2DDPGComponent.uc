//=============================================================================
// TWSceneCapture2DDPGComponent
//=============================================================================
// A SceneCapture2DComponent that can additionally specify which DPGs to render
//=============================================================================
// Killing Floor 2
// Copyright (C) 2016 Tripwire Interactive LLC
//  - Sakib Saikia 1/12/2016
//=============================================================================
class TWSceneCapture2DDPGComponent extends SceneCapture2DComponent
    native(TW);

/** Turn on the scene capture for specific DPGs */
var(Capture) bool bRenderForegroundDPG;
var(Capture) bool bRenderWorldDPG;

cpptext
{

public:

	/**
	* Create a new probe with info needed to render the scene
	*/
	virtual class FSceneCaptureProbe* CreateSceneCaptureProbe();
}

defaultproperties
{
   bRenderForegroundDPG=true
   bRenderWorldDPG=true
   bSkipRenderingDepthPrepass=true
}