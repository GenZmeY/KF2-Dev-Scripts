/**
 * Copyright 2014 Tripwire Interactive.  All Rights Reserved.
 *
 * Tripwire's custom postprocess effect, which replaces the UberPostProcessEffect.
 */

class TWPostProcessEffect extends PostProcessEffect
	native
	dependson(PostProcessVolume);

/* ***********************************************************************
 * DEPTH OF FIELD
 * ***********************************************************************/

/** Distance to focal plane, computed in native code */
var const transient float DOF_FocalDistance;


/** New parameters */
var(DepthOfField) float DOF_SharpRadius;
var(DepthOfField) float DOF_FocalRadius;
var(DepthOfField) float DOF_MinBlurSize;
var(DepthOfField) float DOF_MaxNearBlurSize;
var(DepthOfField) float DOF_MaxFarBlurSize;
var(DepthOfField) float DOF_ExpFalloff;

var(DepthOfField) float DOF_FG_SharpRadius;
var(DepthOfField) float DOF_FG_FocalRadius;
var(DepthOfField) float DOF_FG_MinBlurSize;
var(DepthOfField) float DOF_FG_MaxNearBlurSize;
var(DepthOfField) float DOF_FG_ExpFalloff;


/* ***********************************************************************
 * MOTION BLUR
 * ***********************************************************************/

/** Flag to enable tile-max motion blur */
var const transient bool MB_TileMaxEnabled;


/* ***********************************************************************
 * BLOOM
 * ***********************************************************************/

/** Scales the final bloom color before applying to the scene */
var(Bloom) float Bloom_Intensity;

/** Width multiplier for the blur kernel.  Larger values equal width bloom. */
var(Bloom) float Bloom_Width;

/** During the bright-pass phase, the candidate color at each pixel is scaled by this
 *  value before applying the threshold. */
var(Bloom) float Bloom_Exposure;

/** Threshold value for determining which pixels contribute to bloom.  Pixel colors
 *  are scaled by Exposure before applying the threshold. */
var(Bloom) float Bloom_Threshold;

/** Multiplies against the bloom color. */
var(Bloom) color Bloom_Tint;

/** 
 * Scene color luminance must be less than this to receive bloom. 
 * This behaves like Photoshop's screen blend mode and prevents over-saturation from adding bloom to already bright areas.
 * The default value of 1 means that a pixel with a luminance of 1 won't receive any bloom, but a pixel with a luminance of .5 will receive half bloom.
 */
var(Bloom) float Bloom_ScreenBlendThreshold;


/* ***********************************************************************
 * COLOR GRADING
 * ***********************************************************************/

var(ColorGrading) vector SceneShadows<DisplayName=Shadows>;
/** */
var(ColorGrading) vector SceneHighLights<DisplayName=HighLights>;
/** */
var(ColorGrading) vector SceneMidTones<DisplayName=MidTones>;
/** */
var(ColorGrading) float  SceneDesaturation<DisplayName=Desaturation>;
/** */
var(ColorGrading) vector  SceneColorize<DisplayName=Colorize>;


/* ***********************************************************************
 * TONE MAPPING
 * ***********************************************************************/

/** Allows to specify the tone mapper function which maps HDR colors into the LDR color range. */
var(Tonemapper) ETonemapperType TonemapperType;

/**
 * This tonemapper property allows to specify the HDR brightness value that is mapping to the maximum LDR value. 
 * Brighter values will be mapped to white (good values are in the range 2 to 16). Only affects the "Customizable" 
 * tonemapper.
 */
var(Tonemapper) float TonemapperRange;

/**
 * This tonemapper property allows to adjust the mapping of the darker colors (tonemapper toe).
 * As the adjustment is independent per color channel it can introduce slight shifts color and saturation changes.
 * Only affects the "Customizable" tonemapper.
 * 0=linear .. 1=crushed darks (more filmic)
 */
var(Tonemapper) float TonemapperToeFactor<DisplayName=ToeFactor>;

/**
 * Scale the input for the tonemapper. Only used if a tonemapper is specified.
 * >=0, 0:black, 1(default), >1 brighter
 */
var(Tonemapper) float TonemapperScale;

/** Film-grain noise intensity */
var(Noise) float NoiseIntensity;


/* ***********************************************************************
 * ANTIALIASING
 * ***********************************************************************/

/** Only used if PostProcessAAType is MLAA */
var(AntiAliasing) float EdgeDetectionThreshold;
/** Allows to specify the postprocess antialiasing method (affects quality and performace). */
var(AntiAliasing) EPostProcessAAType PostProcessAAType;

/* ***********************************************************************
 * DISTANCE FOG
 * ***********************************************************************/

/** Distance from the camera at which the fog kicks in (World Space Units) */
var(DistanceFog) float Fog_Start_Distance<DisplayName=Start Distance | UIMin=0.0 | ClampMin=0.0>;

/** Distance from the camera at which max fog kicks in (World Space Units).
	This is the distance at which the interp ends - max fog will be in effect past this distance. 
	This should be greater than Fog Start Distance.
*/
var(DistanceFog) float Fog_MaxStrength_Distance<DisplayName=MaxStrength Distance | UIMin=0.0 | ClampMin=0.0>;

/** Distance at which the perlin noise based fog animation will give way to a solid fog color.
	This should be greater than Fog Start Distance. Clamp at 30000 uu as noise samples get bunched together 
	at a distance creating a salt and pepper  pattern since the sampling is not perspective correct
*/
var(DistanceFog) float Fog_AnimationCutoff_Distance<UIMin=0.0 | ClampMin=0.0 | ClampMax=30000.0>;

/** 0-1 value that controls how much fog to apply. 0 - No fog, 1 - Full fog */
var(DistanceFog) float Fog_Intensity<DisplayName=Intensity | UIMin=0.0 | UIMax=1.0>;

/** 0-1 value that specifies the lower bound on the amount of fog. This will be modulated by Fog_Intesity. */
var(DistanceFog) float Fog_MinAmount<DisplayName=Min Fog | UIMin=0.0 | UIMax=1.0>;

/** Fog Color */
var(DistanceFog) color Fog_Color<DisplayName=Color>;

cpptext
{
	// UPostProcessEffect interface

	/**
	 * Creates a proxy to represent the render info for a post process effect
	 * @param WorldSettings - The world's post process settings for the view.
	 * @return The proxy object.
	 */
	virtual class FPostProcessSceneProxy* CreateSceneProxy(const FPostProcessSettings* WorldSettings);

	// UObject interface

	/**
	* Called after this instance has been serialized.  TWPostProcessEffect should only
	* ever exists in the SDPG_PostProcess scene
	*/
	virtual void PostLoad();

	/**
	 * Called when properties change.  TWPostProcessEffect should only
	 * ever exists in the SDPG_PostProcess scene
	 */
	virtual void PostEditChangeProperty(FPropertyChangedEvent& PropertyChangedEvent);

	/**
	* Tells the SceneRenderer is this effect includes the uber post process.
	*/
	virtual UBOOL IncludesUberpostprocess() const
	{
		return TRUE;
	}

	/**
	* This allows to print a warning when the effect is used.
	*/
	virtual void OnPostProcessWarning(FString& OutWarning) const
	{
		// we don't want to output any warning but derive from a effect that might do that.
	}

     /**
	 * @param View - current view
	 * @return TRUE if the effect should be rendered
	 */
	virtual UBOOL IsShown(const FSceneView* View) const
	{
            // The TWPostProcessEffect needs to be rendered even if bloom and
            // depth of field are disabled since it also contains desaturation,
            // tone mapping, etc.
            return UPostProcessEffect::IsShown(View);
	}
}


defaultproperties
{
    DOF_FocalDistance=1000.0
	
	DOF_SharpRadius=500.0
	DOF_FocalRadius=1000.0
	DOF_MinBlurSize=1.25
	DOF_MaxNearBlurSize=4.0
	DOF_MaxFarBlurSize=8.0
	DOF_ExpFalloff=1.0
	
	DOF_FG_SharpRadius=10.0
	DOF_FG_FocalRadius=10.0
	DOF_FG_MinBlurSize=1.0
	DOF_FG_MaxNearBlurSize=2.0
	DOF_FG_ExpFalloff=1.0

	MB_TileMaxEnabled=true

	Bloom_Intensity=1.05
	Bloom_Width=4
	Bloom_Exposure=1.25
	Bloom_Threshold=0.6
	Bloom_Tint=(R=255,G=255,B=255)
	Bloom_ScreenBlendThreshold=10

	Fog_Start_Distance=0.0
	Fog_MaxStrength_Distance=10000.0
	Fog_AnimationCutoff_Distance=8000.0
	Fog_Intensity=0.3
	Fog_Color=(R=255, G=255, B=255)


	SceneShadows=(X=0.0,Y=0.0,Z=-0.003);
    SceneHighLights=(X=0.8,Y=0.8,Z=0.8);
    SceneMidTones=(X=1.3,Y=1.3,Z=1.3);
    SceneDesaturation=0.4;
    SceneColorize=(X=1,Y=1,Z=1);

	TonemapperScale=1.0;
	TonemapperRange=8;
	TonemapperToeFactor=1;

	EdgeDetectionThreshold=12.0
	PostProcessAAType=PostProcessAA_Off

	NoiseIntensity=1.0
}