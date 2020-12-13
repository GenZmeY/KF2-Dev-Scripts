/**
 * Copyright 1998-2013 Epic Games, Inc. All Rights Reserved.
 */
class LightComponent extends ActorComponent
	native(Light)
	noexport
	abstract;


//@warning: this structure is manually mirrored in UnActorComponent.h
struct LightingChannelContainer
{
	/** Whether the lighting channel has been initialized. Used to determine whether UPrimitveComponent::Attach should set defaults. */
	var		bool	bInitialized;

`if(`__TW_LIGHTING_MODIFICATIONS_)  // Custom lighting channel implementation
	// User settable channels that are auto set and true for lights
	var		bool	BSP;
	var		bool	Static;
	var		bool	Dynamic;
	// User set channels.
	var		bool	CompositeDynamic;
	var		bool	Skybox;
	var		bool	Unnamed_1;
	var		bool	Unnamed_2;
	var		bool	Unnamed_3;
	var		bool	Unnamed_4;
	var		bool	Unnamed_5;
	var		bool	Unnamed_6;
	var		bool	Cinematic_1;
	var		bool	Cinematic_2;
	var		bool	Cinematic_3;
	var		bool	Cinematic_4;
	var		bool	Cinematic_5;
	var		bool	Cinematic_6;
	var		bool	Cinematic_7;
	var		bool	Cinematic_8;
	var		bool	Cinematic_9;
	var		bool	Cinematic_10;
	var		bool	Gameplay_1;
	var		bool	Gameplay_2;
	var		bool	Gameplay_3;
	var		bool	Gameplay_4;
	var		bool	Crowd;
	var() 	bool 	Indoor;
	var() 	bool	Outdoor;
`else
		// User settable channels that are auto set and true for lights
	var()	bool	BSP;
	var()	bool	Static;
	var()	bool	Dynamic;
	// User set channels.
	var()	bool	CompositeDynamic;
	var()	bool	Skybox;
	var()	bool	Unnamed_1;
	var()	bool	Unnamed_2;
	var()	bool	Unnamed_3;
	var()	bool	Unnamed_4;
	var()	bool	Unnamed_5;
	var()	bool	Unnamed_6;
	var()	bool	Cinematic_1;
	var()	bool	Cinematic_2;
	var()	bool	Cinematic_3;
	var()	bool	Cinematic_4;
	var()	bool	Cinematic_5;
	var()	bool	Cinematic_6;
	var()	bool	Cinematic_7;
	var()	bool	Cinematic_8;
	var()	bool	Cinematic_9;
	var()	bool	Cinematic_10;
	var()	bool	Gameplay_1;
	var()	bool	Gameplay_2;
	var()	bool	Gameplay_3;
	var()	bool	Gameplay_4;
	var()	bool	Crowd;
`endif
};

var native private	transient noimport const pointer	SceneInfo;

var native const	transient matrix			WorldToLight;
var native const	transient matrix			LightToWorld;

/**
 * GUID used to associate a light component with precomputed shadowing information across levels.
 * The GUID changes whenever the light position changes.
 */
var	const duplicatetransient guid	LightGuid;
/**
 * GUID used to associate a light component with precomputed shadowing information across levels.
 * The GUID changes whenever any of the lighting relevant properties changes.
 */
var const duplicatetransient guid	LightmapGuid;

var() const interp float Brightness <UIMin=0.0 | UIMax=20.0>;
var() const interp color LightColor;

`if(`__TW_LIGHTING_MODIFICATIONS_)
/** Used to control the contribution of NdotL Lambertian lighting factor. Primary use case if for fill lights that have DisableSpecular=True */
var() float Hardness <UIMin=0.0 | UIMax=1.0 | ClampMin=0.0 | ClampMax=1.0>;
`endif

/**
 * The light function to be applied to this light.
 * Note that only non-lightmapped lights (UseDirectLightMap=False) can have a light function.
 */
var() const editinline export LightFunction Function;

/** Is this light enabled? */
var() const bool bEnabled;

/**
 * Whether the light should cast any shadows.
 **/
var() const bool CastShadows;

/**
 * Whether the light should cast shadows from static objects.  Also requires Cast Shadows to be set to True.
 */
var() const bool CastStaticShadows;

`if(`__TW_LIGHTING_MODIFICATIONS_)
/**
 * Whether the light should cast dynamic whole scene shadows from static objects.  Also requires Cast Shadows to be set to True.
 * This is usually used in combination with Cast Static Shadows set to True, and the primitives the light affects will either cast a
 * static shadow or a dynamic shadow based on the proximity of the camera to the light.
 **/
var() bool CastDynamicShadows<DisplayName=Cast Whole Scene Dynamic Shadows>;

/** 
 * Whether this light should force dynamic shadows even if the primitive is not set to cast dynamic shadows.
 * Not exposed to editor. Use for special cases light the flashlight to prevent light bleeding.
 */
var bool ForceCastDynamicShadows;
`else
/**
 * Whether the light should cast shadows from dynamic objects.  Also requires Cast Shadows to be set to True.
 **/
var() bool CastDynamicShadows;
`endif

/** Whether the light should cast shadows from objects with composite lighting (i.e. an enabled light environment). */
var() bool bCastCompositeShadow;

/** If bCastCompositeShadow=TRUE, whether the light should affect the composite shadow direction. */
var() bool bAffectCompositeShadowDirection;

/**
 * If enabled and the light casts modulated shadows, this will cause self-shadowing of shadows rendered from this light to use normal shadow blending.
 * This is useful to get better quality self shadowing while still having a shadow on the lightmapped environment.
 * When enabled it incurs most of the rendering overhead of both approaches combined.
 */
var() bool bNonModulatedSelfShadowing;

/** Whether the light should cast shadows only from a dynamic object onto itself. */
var() interp bool bSelfShadowOnly;

`if(`__TW_LIGHTING_MODIFICATIONS_)
// SRS - Exposed property to editor
/** Whether to allow preshadows (the static environment casting dynamic shadows on dynamic objects) from this light. */
var() bool bAllowPreShadow<DisplayName=Allow Per Object PreShadow>;
`else
/** Whether to allow preshadows (the static environment casting dynamic shadows on dynamic objects) from this light. */
var bool bAllowPreShadow;
`endif

/**
 * Whether the light should cast shadows as if it was movable, regardless of its class.
 * This is useful for gameplay lights dynamically spawned and attached to a static actor.
 */
var const bool bForceDynamicLight;

/** If set to false on a static light, forces it to use precomputed shadowing instead of precomputed lighting. */
var const bool UseDirectLightMap;

/** Whether light has ever been built into a lightmap */
var const bool bHasLightEverBeenBuiltIntoLightMap;

/** Whether the light can affect dynamic primitives even though the light is not affecting the dynamic channel. */
var const bool bCanAffectDynamicPrimitivesOutsideDynamicChannel;

/** Whether to render light shafts from this light.  Only non-static lights can render light shafts (toggleable, movable or dominant types). */
var(LightShafts) bool bRenderLightShafts;

/** Whether to replace this light's analytical specular with image based specular on materials that support it. */
var(ImageReflection) bool bUseImageReflectionSpecular <bShowOnlyWhenTrue=bShowD3D11Properties>;

/** The precomputed lighting for that light source is valid. It might become invalid if some properties change (e.g. position, brightness). */
var protected const bool bPrecomputedLightingIsValid;

/** Whether this light is being used as the OverrideLightComponent on a primitive and shouldn't affect any other primitives. */
var protected const bool bExplicitlyAssignedLight;

/** Whether this light can be combined into the DLE normally.  Overriden to false in the case of muzzle flashes to prevent SH artifacts */
var bool bAllowCompositingIntoDLE;

`if(`__TW_LIGHTING_MODIFICATIONS_) // BITFIELDS
/** Whether the light should cast dynamic per object shadows from dynamic objects that have Allow Per Object Shadows set to True.
 * This must be set to true if you want the light to cast character shadows (which are per object). Also requires Cast Shadow to be set to True.
 */
var() bool bCastPerObjectShadows<DisplayName=Cast Per Object Dynamic Shadows>;

/** If set, the auto light channel generation will not modify the light channel for this light */
var() const bool bOverrideAutoLightingChannels;

/**
 * Disable specular component of the light for diffuse only lighting.
 * This can be used to simulate fill lighting
 */
var() bool bDisableSpecular;

/** If set, owner is responsible for ticking the light animation */
var transient bool bOverrideLightAnimTick;

/** If set, when light is rendered also update owner's LastRenderTime.  Used to modify skip rate code in SkelComp::Tick */
var bool bUpdateOwnerRenderTime;
`endif

/**
 * The light environment which the light affects.
 * NULL represents an implicit default light environment including all primitives and lights with LightEnvironment=NULL.
 */
var const LightEnvironmentComponent LightEnvironment;

/** Lighting channels controlling light/ primitive interaction. Only allows interaction if at least one channel is shared */
var() const LightingChannelContainer LightingChannels;

//@warning: this structure is manually mirrored in UnActorComponent.h
enum ELightAffectsClassification
{
	LAC_USER_SELECTED,
	LAC_DYNAMIC_AFFECTING,
	LAC_STATIC_AFFECTING,
	LAC_DYNAMIC_AND_STATIC_AFFECTING
};

/**
 * This is the classification of this light.  This is used for placing a light for an explicit
 * purpose.  Basically you can now have "type" information with lights and understand the
 * intent of why a light was placed.  This is very useful for content people getting maps
 * from others and understanding why there is a dynamic affect light in the middle of the world
 * with a radius of 32k!  And also useful for being able to do searches such as the following:
 * show me all lights which effect dynamic objects.  Now show me the set of lights which are
 * not explicitly set as Dynamic Affecting lights.
 *
 **/
var() const editconst ELightAffectsClassification LightAffectsClassification;

enum ELightShadowMode
{
	/** Shadows rendered due to absence of light when doing dynamic lighting. High overhead per-light, especially on xbox 360. */
	LightShadow_Normal,
	/** Shadows rendered as a fullscreen pass by modulating entire scene by a shadow factor.  Least expensive, Default. */
	LightShadow_Modulate,
	/** Deprecated */
	LightShadow_ModulateBetter
};

/** The type of shadowing to apply for the light. */
var() ELightShadowMode LightShadowMode;

/** The color to modulate with pixels that receive a dynamic shadow from this light (if it casts modulated shadows). */
var() LinearColor ModShadowColor;

/** Time since the caster was last visible at which the mod shadow will fade out completely.  */
var float ModShadowFadeoutTime;

/** Exponent that controls mod shadow fadeout curve. */
var float ModShadowFadeoutExponent;

/**
 * The munged index of this light in the light list
 *
 * > 0 == static light list
 *   0 == not part of any light list
 * < 0 == dynamic light list
 */
var const native duplicatetransient int LightListIndex;

enum EShadowProjectionTechnique
{
	/** Shadow projection is rendered using either PCF/VSM based on global settings  */
	ShadowProjTech_Default,
	/** Shadow projection is rendered using the PCF (Percentage Closer Filtering) technique. May have heavy banding artifacts */
	ShadowProjTech_PCF,
	/** Shadow projection is rendered using the VSM (Variance Shadow Map) technique. May have shadow offset and light bleed artifacts */
	ShadowProjTech_VSM,
	/** Shadow projection is rendered using the Low quality Branching PCF technique. May have banding and penumbra detection artifacts */
	ShadowProjTech_BPCF_Low,
	/** Shadow projection is rendered using the Medium quality Branching PCF technique. May have banding and penumbra detection artifacts */
	ShadowProjTech_BPCF_Medium,
	/** Shadow projection is rendered using the High quality Branching PCF technique. May have banding and penumbra detection artifacts */
	ShadowProjTech_BPCF_High
};
/** Type of shadow projection to use for this light */
var EShadowProjectionTechnique ShadowProjectionTechnique;

enum EShadowFilterQuality
{
	SFQ_Low,
	SFQ_Medium,
	SFQ_High
};
/** The quality of filtering to use for dynamic shadows cast by the light. */
var() EShadowFilterQuality ShadowFilterQuality;

/**
 * Override for min dimensions (in texels) allowed for rendering shadow subject depths.
 * This also controls shadow fading, once the shadow resolution reaches MinShadowResolution it will be faded out completely.
 * A value of 0 defaults to MinShadowResolution in SystemSettings.
 */
var() int MinShadowResolution;

/**
 * Override for max square dimensions (in texels) allowed for rendering shadow subject depths.
 * A value of 0 defaults to MaxShadowResolution in SystemSettings.
 */
var() int MaxShadowResolution;

/**
 * Resolution in texels below which shadows begin to be faded out.
 * Once the shadow resolution reaches MinShadowResolution it will be faded out completely.
 * A value of 0 defaults to ShadowFadeResolution in SystemSettings.
 */
var() int ShadowFadeResolution;

/** Everything closer to the camera than this distance will occlude light shafts for directional lights. */
var(LightShafts) float OcclusionDepthRange;

/**
 * Scales additive color near the light source.  A value of 0 will result in no additive term.
 * If BloomScale is 0 and OcclusionMaskDarkness is 1, light shafts will effectively be disabled.
 */
var(LightShafts) interp float BloomScale;

/** Scene color luminance must be larger than this to create bloom in light shafts. */
var(LightShafts) float BloomThreshold;

/**
 * Scene color luminance must be less than this to receive bloom from light shafts.
 * This behaves like Photoshop's screen blend mode and prevents over-saturation from adding bloom to already bright areas.
 * The default value of 1 means that a pixel with a luminance of 1 won't receive any bloom, but a pixel with a luminance of .5 will receive half bloom.
 */
var(LightShafts) float BloomScreenBlendThreshold;

/** Multiplies against scene color to create the bloom color. */
var(LightShafts) interp color BloomTint;

/** 100 is maximum blur length, 0 is no blur. */
var(LightShafts) float RadialBlurPercent;

/**
 * Controls how dark the occlusion masking is, a value of .5 would mean that an occlusion of 0 only darkens underlying color by half.
 * A value of 1 results in no darkening term.  If BloomScale is 0 and OcclusionMaskDarkness is 1, light shafts will effectively be disabled.
 */
var(LightShafts) interp float OcclusionMaskDarkness;

/** Scales the contribution of the reflection specular highlight. */
var(ImageReflection) float ReflectionSpecularBrightness <bShowOnlyWhenTrue=bShowD3D11Properties>;

`if(`__TW_LIGHTING_MODIFICATIONS_)
/**
 * Max draw distance beyond which the light will be culled
 */
var() const float MaxDrawDistance;

/** The maximum brightness value for this light. Default is 1.0 */
var float MaxBrightness<UIMin=0.0|ClampMin=0.0>;
/** The minimum brightness override value for this light. If 0, it uses the
	global value for the light animation type specified in WorldInfo. */
var float MinBrightness<UIMin=0.0|ClampMin=0.0>;
/** Light animation type used by this light */
var byte AnimationType;
/** The rate at which the LightAnimation is played. Default is 1.0. Must be greater than 0 */
var float AnimationFrequency<UIMin=0.01|ClampMin=0.01|UIMax=20.0|ClampMax=20.0>;
/** Time offset into the LightAnimation. This is used to add variation so that
all the animations are not in perfect sync. default is 0.0.
Note: This value will not have any effect it is a multiple of the inverse of the AnimationFrequency.
Eg. If the AnimationFrequency is 0.5, AnimationTimeOffsets of 2, 4, 6 ... will have same effect at 0  */
var float AnimationTimeOffset;

/** How many times the light animation was ticked. */
var transient int LightAnimFrameCount;
/** The value of WorldInfo->TimeSeconds for the frame when this actor was last rendered. */
var transient float	LastRenderTime;
`endif

/**
 * Toggles the light on or off
 *
 * @param bSetEnabled TRUE to enable the light or FALSE to disable it
 */
native final function SetEnabled(bool bSetEnabled);

/** sets Brightness, LightColor, and/or LightFunction */
native final function SetLightProperties(optional float NewBrightness = Brightness, optional color NewLightColor = LightColor, optional LightFunction NewLightFunction = Function);

/** Script interface to retrieve light location. */
native final function vector GetOrigin();

/** Script interface to retrieve light direction. */
native final function vector GetDirection();

/** Script interface to update the color and brightness on the render thread. */
native final function UpdateColorAndBrightness();

/** Script interface to update light shaft parameters on the render thread. */
native final function UpdateLightShaftParameters();

/** Called from matinee code when BloomScale property changes. */
function OnUpdatePropertyBloomScale()
{
	UpdateLightShaftParameters();
}

/** Called from matinee code when BloomTint property changes. */
function OnUpdatePropertyBloomTint()
{
	UpdateLightShaftParameters();
}

/** Called from matinee code when OcclusionMaskDarkness property changes. */
function OnUpdatePropertyOcclusionMaskDarkness()
{
	UpdateLightShaftParameters();
}

/** Called from matinee code when Brightness property changes. */
function OnUpdatePropertyBrightness()
{
	UpdateColorAndBrightness();
}

/** Called from matinee code when LightColor property changes. */
function OnUpdatePropertyLightColor()
{
	UpdateColorAndBrightness();
}



defaultproperties
{
	LightAffectsClassification=LAC_USER_SELECTED

	Brightness=1.0
	LightColor=(R=255,G=255,B=255)
	bEnabled=TRUE

	// for now we are leaving this as people may be depending on it in script and we just
    // set the specific default settings in each light as they are all pretty different
	CastShadows=TRUE
	CastStaticShadows=TRUE
	CastDynamicShadows=TRUE
	bCastCompositeShadow=TRUE
	bAffectCompositeShadowDirection=TRUE
	bForceDynamicLight=FALSE
	UseDirectLightMap=FALSE
	bPrecomputedLightingIsValid=TRUE

	//All lights default to being able to be composited normally.
	bAllowCompositingIntoDLE=TRUE

`if(`__TW_LIGHTING_MODIFICATIONS_)  // Custom lighting channel implementation
	LightingChannels=(Indoor=TRUE,bInitialized=TRUE)
`else
	LightingChannels=(BSP=TRUE,Static=TRUE,Dynamic=TRUE,CompositeDynamic=TRUE,bInitialized=TRUE)
`endif

`if(`__TW_LIGHTING_MODIFICATIONS_)
	// Use fully dynamic shadowing
	LightShadowMode=LightShadow_Normal
`else
	// Use cheap modulated shadowing by default
	LightShadowMode=LightShadow_Modulate
`endif

`if(`__TW_LIGHTING_MODIFICATIONS_)
	Hardness=1.0
`endif 

	ModShadowFadeoutExponent=3.0
	// default to PCF shadow projection
	ShadowProjectionTechnique=ShadowProjTech_Default
	ShadowFilterQuality=SFQ_Low

	bRenderLightShafts=false
	OcclusionDepthRange=20000
	BloomScale=2
	BloomThreshold=0
	BloomScreenBlendThreshold=1
	BloomTint=(R=255,G=255,B=255)
	RadialBlurPercent=100
	OcclusionMaskDarkness=.3

	bUseImageReflectionSpecular=false
	ReflectionSpecularBrightness=.2
}


/*

 Notes on all of the various Affecting Classifications


USER SELECTED:
   settings that god knows what they do


DYNAMIC AFFECTING:  // pawns, characters, kactors
	CastShadows=TRUE
	CastStaticShadows=FALSE
	CastDynamicShadows=TRUE
	bForceDynamicLight=TRUE
	UseDirectLightMap=FALSE

    LightingChannels:  Dynamic


STATIC AFFECTING:
	CastShadows=TRUE
	CastStaticShadows=TRUE
	CastDynamicShadows=FALSE
	bForceDynamicLight=FALSE
	UseDirectLightMap=TRUE   // For Toggleables this is UseDirectLightMap=FALSE

    LightingChannels:  BSP, Static


DYNAMIC AND STATIC AFFECTING:
	CastShadows=TRUE
	CastStaticShadows=TRUE
	CastDynamicShadows=TRUE
	bForceDynamicLight=FALSE
	UseDirectLightMap=FALSE

    LightingChannels:  BSP, Dynamic, Static


how to light the skybox?

  -> make a user selected affecting light with the skybox channel checked.
     - if we need to have a special classification for this then we will make it at a later time

SKYLIGHT:
	CastShadows=FALSE
	CastStaticShadows=FALSE
	CastDynamicShadows=FALSE
	bForceDynamicLight=FALSE
	UseDirectLightMap=TRUE

    LightingChannels:  SkyLight


how to only light character then?

  -> Character Lighting Channel  not at this time as people will mis use it
  -> for cinematics (where character only lighting could be used) we just use the unamed_#
	    lighting channels!


*/


