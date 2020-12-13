//=============================================================================
// KFGFxOptionsMenu_Graphics
//=============================================================================
// This menu will be used to update and display the graphics options for the game
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//  Zane Gholson -  9/29/2014
//=============================================================================

class KFGFxOptionsMenu_Graphics extends KFGFxObject_Menu
	native(UI);

//@HSL_MOD_BEGIN - amiller 5/25/2016 - Adding support to save extra data into profile settings
`include(KFProfileSettings.uci);
//@HSL_MOD_END
`define MIN 0
`define MAX 1

enum PerfWarning
{
	// Little to no performance implications
	PerfWarning_None,
	// May cause performance degradation
	PerfWarning_Normal,
	// May cause severe performance degradation
	PerfWarning_Severe,
};

var bool bIsRevertCoundownActive;
var byte TimeCount;
var const byte ExpireTime;

var localized string FlexPopUpString;

var localized string KeepSettingsPromptString;
var localized string WarningPromptString;
var localized string WillExpireString;
var localized string PerformanceDescString[2];
var localized string RestartDescString;
var localized string SingleWarningString;
var localized string DoubleWarningString;
var localized string UnsavedChangesString;
var localized string ContinueString;
var localized string SaveChangesString;

var localized string AdjustGammaDescription;
var localized string ResetGammaString;
var localized string SetGammaString;

var localized string GraphicsString;
var localized string BasicString;
var localized string AdvancedString;
var localized string EffectsString;

var localized string AspectRatioString;
var localized string ResolutionString;
var localized string GraphicsQualityString;
var localized string VSyncString;
var localized string FullscreenString;
var localized string VariableFrameRateString;
var localized string AdjustGammaString;
var localized string FilmGrainString;

var localized string EnvironmentDetailsString;
var localized string CharacterDetailString;
var localized string FXString;
var localized string TextureResolutionString;
var localized string TextureFilteringString;
var localized string ShadowsString;
var localized string RealtimeReflectionsString;
var localized string AntiAliasingString;
var localized string BloomString;
var localized string MotionBlurString;
var localized string AmbientOcclusionString;
var localized string DepthOfFieldString;

var localized string VolumetricLightingString;
var localized string lensFlaresString;
var localized string LightShaftsString;
var localized string CustomString;
var localized string IniOverrideString;

var localized string OKString;
var localized string ApplyString;
var localized string CancelString;
var localized string DefaultString;

var localized string PhysicsLevelString;
var localized array<string> PhysicsLevelOptionStrings;
var localized array<string> PhysicsLevelSuggestionStrings;

var localized string AspectRatioString_All;
var localized string StandardAspectRatioString_4_3;
var localized string StandardAspectRatioString_5_4;
var localized string StandardAspectRatioString_3_2;
var localized string WideAspectRatioString_16_9;
var localized string WideAspectRatioString_16_10;
var localized string ExtraWideAspectRatioString_2_1;
var localized string ExtraWideAspectRatioString_21_9;
var localized string MultiMonitorAspectRatioString;
var localized array<string> FullScreenStringOptions;
var localized array<string> GraphicsQualityStringOptions;
var localized array<string> VSyncStringOptions;

var localized array<string> EnvironmentDetailsStringOptions;
var localized array<string> CharacterDetailStringOptions;
var localized array<string> FXStringOptions;
var localized array<string> TextureResolutionStringOptions;
var localized array<string> TextureFilteringStringOptions;
var localized array<string> ShadowsStringOptions;

var localized array<string> RealtimeReflectionsStringOptions;
var localized array<string> AntiAliasingStringOptions;
var localized array<string> BloomStringOptions;
var localized array<string> MotionBlurStringOptions;
var localized array<string> AmbientOcclusionStringOptions;
var localized array<string> DepthOfFieldStringOptions;

var localized array<string>OffOnStringOptions;

var transient array<string> SupportedResolutionList;

var transient string RevertPopupDescriptionString;

/** List of supported aspect ratios. All of them might not be available for user. */
enum SupportedAspectRatio
{
	KFASPECTRATIO_All,
	KFASPECTRATIO_Standard_4_3,
	KFASPECTRATIO_Standard_5_4,
	KFASPECTRATIO_Standard_3_2,
	KFASPECTRATIO_Wide_16_9,
	KFASPECTRATIO_Wide_16_10,
	KFASPECTRATIO_ExtraWide_2_1,
	KFASPECTRATIO_ExtraWide_21_9,
	KFASPECTRATIO_MultiMonitor,
	KFASPECTRATIO_MAX
};

/** Array containing the list of aspect ratios supported by the user's machine.
	Use the index retured by the UI to access this list to get the actual aspect ratio
 */
var transient array<SupportedAspectRatio> AvailableAspectRatioList;

//======================================================================================
// Meta Settings. Abstracted quality setting which contains one or more system settings.
//======================================================================================

// -------------------------------------------------------------------------------------
// Resolution Setting
// -------------------------------------------------------------------------------------
struct native ResolutionSetting
{
	var int ResX;
	var int ResY;

	structcpptext
	{
		void CopyToNativeSettings(FSystemSettings& OutSettings, UEngine* OutEngine)
		{
			OutSettings.ResX = ResX;
			OutSettings.ResY = ResY;
		}

		void CopyFromNativeSettings(FSystemSettings& InSettings, UEngine* InEngine)
		{
			ResX = InSettings.ResX;
			ResY = InSettings.ResY;
		}
	}
};

// -------------------------------------------------------------------------------------
// Graphics Quality (Basic Setting)
// -------------------------------------------------------------------------------------
struct native GraphicsQualitySetting
{
	var int EnvironmentDetailIndex;
	var int CharacterDetailIndex;
	var int FXQualityIndex;
	var int TextureResolutionIndex;
	var int TextureFilteringIndex;
	var int ShadowQualityIndex;
	var int RealtimeReflectionsIndex;
	var bool LightShafts;
	var bool VolumetricLighting;
	var bool LensFlares;
	var int AntiAliasingIndex;
	var int BloomIndex;
	var int MotionBlurIndex;
	var int AmbientOcclusionIndex;
	var int DOFIndex;
	var int FlexIndex;

	structcpptext
	{
#if __TW_WITH_GSA_	
		// This should match the number of options in the struct
		#define MAX_OPTIONS 16	

		static int GetGSAOptions(NvGsaNamedOption** OutOptions)
		{
			NvGsaNamedOption *GSAOptions = new NvGsaNamedOption[MAX_OPTIONS];

			// Environment Detail
			GSAOptions[0].name = TEXT("EnvironmentDetail");
			GSAOptions[0].value.type = NV_GSA_TYPE_INT;
			GSAOptions[0].value.asInt = 2;
			GSAOptions[0].numRange.maxValue.asInt = 3;
			GSAOptions[0].numRange.minValue.asInt = 0;
			GSAOptions[0].numRange.numSteps = 3;

			// Character Detail
			GSAOptions[1].name = TEXT("CharacterDetail");
			GSAOptions[1].value.type = NV_GSA_TYPE_INT;
			GSAOptions[1].value.asInt = 1;
			GSAOptions[1].numRange.maxValue.asInt = 2;
			GSAOptions[1].numRange.minValue.asInt = 0;
			GSAOptions[1].numRange.numSteps = 2;

			// FX Quality
			GSAOptions[2].name = TEXT("FX");
			GSAOptions[2].value.type = NV_GSA_TYPE_INT;
			GSAOptions[2].value.asInt = 2;
			GSAOptions[2].numRange.maxValue.asInt = 3;
			GSAOptions[2].numRange.minValue.asInt = 0;
			GSAOptions[2].numRange.numSteps = 3;

			// Texture Resolution
			GSAOptions[3].name = TEXT("TextureResolution");
			GSAOptions[3].value.type = NV_GSA_TYPE_INT;
			GSAOptions[3].value.asInt = 2;
			GSAOptions[3].numRange.maxValue.asInt = 3;
			GSAOptions[3].numRange.minValue.asInt = 0;
			GSAOptions[3].numRange.numSteps = 3;

			// Texture Filtering
			GSAOptions[4].name = TEXT("TextureFiltering");
			GSAOptions[4].value.type = NV_GSA_TYPE_INT;
			GSAOptions[4].value.asInt = 2;
			GSAOptions[4].numRange.maxValue.asInt = 3;
			GSAOptions[4].numRange.minValue.asInt = 0;
			GSAOptions[4].numRange.numSteps = 3;

			// Shadows
			GSAOptions[5].name = TEXT("Shadows");
			GSAOptions[5].value.type = NV_GSA_TYPE_INT;
			GSAOptions[5].value.asInt = 2;
			GSAOptions[5].numRange.maxValue.asInt = 3;
			GSAOptions[5].numRange.minValue.asInt = 0;
			GSAOptions[5].numRange.numSteps = 3;

			// Realtime Reflections
			GSAOptions[6].name = TEXT("RealtimeReflections");
			GSAOptions[6].value.type = NV_GSA_TYPE_INT;
			GSAOptions[6].value.asInt = 0;
			GSAOptions[6].numRange.maxValue.asInt = 1;
			GSAOptions[6].numRange.minValue.asInt = 0;
			GSAOptions[6].numRange.numSteps = 1;

			// Light Shafts
			GSAOptions[7].name = TEXT("LightShafts");
			GSAOptions[7].value.type = NV_GSA_TYPE_INT;
			GSAOptions[7].value.asInt = 1;
			GSAOptions[7].numRange.maxValue.asInt = 1;
			GSAOptions[7].numRange.minValue.asInt = 0;
			GSAOptions[7].numRange.numSteps = 1;

			// Volumetric Lighting
			GSAOptions[8].name = TEXT("VolumetricLighting");
			GSAOptions[8].value.type = NV_GSA_TYPE_INT;
			GSAOptions[8].value.asInt = 1;
			GSAOptions[8].numRange.maxValue.asInt = 1;
			GSAOptions[8].numRange.minValue.asInt = 0;
			GSAOptions[8].numRange.numSteps = 1;

			// Lens Flares
			GSAOptions[9].name = TEXT("LensFlares");
			GSAOptions[9].value.type = NV_GSA_TYPE_INT;
			GSAOptions[9].value.asInt = 1;
			GSAOptions[9].numRange.maxValue.asInt = 1;
			GSAOptions[9].numRange.minValue.asInt = 0;
			GSAOptions[9].numRange.numSteps = 1;

			// AntiAliasing
			GSAOptions[10].name = TEXT("AntiAliasing");
			GSAOptions[10].value.type = NV_GSA_TYPE_INT;
			GSAOptions[10].value.asInt = 1;
			GSAOptions[10].numRange.maxValue.asInt = 1;
			GSAOptions[10].numRange.minValue.asInt = 0;
			GSAOptions[10].numRange.numSteps = 1;

			// Bloom
			GSAOptions[11].name = TEXT("Bloom");
			GSAOptions[11].value.type = NV_GSA_TYPE_INT;
			GSAOptions[11].value.asInt = 2;
			GSAOptions[11].numRange.maxValue.asInt = 2;
			GSAOptions[11].numRange.minValue.asInt = 0;
			GSAOptions[11].numRange.numSteps = 2;

			// Motion Blur
			GSAOptions[12].name = TEXT("MotionBlur");
			GSAOptions[12].value.type = NV_GSA_TYPE_INT;
			GSAOptions[12].value.asInt = 0;
			GSAOptions[12].numRange.maxValue.asInt = 1;
			GSAOptions[12].numRange.minValue.asInt = 0;
			GSAOptions[12].numRange.numSteps = 1;

			// AO
			GSAOptions[13].name = TEXT("AmbientOcclusion");
			GSAOptions[13].value.type = NV_GSA_TYPE_INT;
			GSAOptions[13].value.asInt = 1;
			GSAOptions[13].numRange.maxValue.asInt = 2;
			GSAOptions[13].numRange.minValue.asInt = 0;
			GSAOptions[13].numRange.numSteps = 2;

			// DOF
			GSAOptions[14].name = TEXT("DepthOfField");
			GSAOptions[14].value.type = NV_GSA_TYPE_INT;
			GSAOptions[14].value.asInt = 1;
			GSAOptions[14].numRange.maxValue.asInt = 1;
			GSAOptions[14].numRange.minValue.asInt = 0;
			GSAOptions[14].numRange.numSteps = 1;

			// Flex
			GSAOptions[15].name = TEXT("Flex");
			GSAOptions[15].value.type = NV_GSA_TYPE_INT;
			GSAOptions[15].value.asInt = 0;
			GSAOptions[15].numRange.maxValue.asInt = 2;
			GSAOptions[15].numRange.minValue.asInt = 0;
			GSAOptions[15].numRange.numSteps = 2;

			// ----------------------------------------------------------- 
			// Add new settings here. Remember to increment MAX_OPTIONS
			// -----------------------------------------------------------

			*OutOptions = GSAOptions;

			return MAX_OPTIONS;
		}

		static FGraphicsQualitySetting GetGraphicsQualityFromGSA()
		{
			FGraphicsQualitySetting Out;
			NvGsaVariant Value;
			NvGsaStatus Status;

			// Environment Detail
			Status = GFSDK_GSA_GetOptionValue(&Value, TEXT("EnvironmentDetail"));
			checkSlow( Status == NV_GSA_STATUS_OK); 			
			Out.EnvironmentDetailIndex = Value.asInt;
			GFSDK_GSA_ReleaseVariant(&Value);

			// Character Detail
			Status = GFSDK_GSA_GetOptionValue(&Value, TEXT("CharacterDetail"));
			checkSlow( Status == NV_GSA_STATUS_OK); 			
			Out.CharacterDetailIndex = Value.asInt;
			GFSDK_GSA_ReleaseVariant(&Value);

			// FX Quality
			Status = GFSDK_GSA_GetOptionValue(&Value, TEXT("FX"));
			checkSlow( Status == NV_GSA_STATUS_OK); 			
			Out.FXQualityIndex = Value.asInt;
			GFSDK_GSA_ReleaseVariant(&Value);

			// Texture Resolution
			Status = GFSDK_GSA_GetOptionValue(&Value, TEXT("TextureResolution"));
			checkSlow( Status == NV_GSA_STATUS_OK); 			
			Out.TextureResolutionIndex = Value.asInt;
			GFSDK_GSA_ReleaseVariant(&Value);

			// Texture Filtering
			Status = GFSDK_GSA_GetOptionValue(&Value, TEXT("TextureFiltering"));
			checkSlow( Status == NV_GSA_STATUS_OK); 			
			Out.TextureFilteringIndex = Value.asInt;
			GFSDK_GSA_ReleaseVariant(&Value);

			// Shadows
			Status = GFSDK_GSA_GetOptionValue(&Value, TEXT("Shadows"));
			checkSlow( Status == NV_GSA_STATUS_OK); 			
			Out.ShadowQualityIndex = Value.asInt;
			GFSDK_GSA_ReleaseVariant(&Value);

			// Realtime Reflections
			Status = GFSDK_GSA_GetOptionValue(&Value, TEXT("RealtimeReflections"));
			checkSlow( Status == NV_GSA_STATUS_OK); 			
			Out.RealtimeReflectionsIndex = Value.asInt;
			GFSDK_GSA_ReleaseVariant(&Value);

			// Light Shafts
			Status = GFSDK_GSA_GetOptionValue(&Value, TEXT("LightShafts"));
			checkSlow( Status == NV_GSA_STATUS_OK); 			
			Out.LightShafts = Value.asInt > 0;
			GFSDK_GSA_ReleaseVariant(&Value);

			// Volumetric Lighting
			Status = GFSDK_GSA_GetOptionValue(&Value, TEXT("VolumetricLighting"));
			checkSlow( Status == NV_GSA_STATUS_OK); 			
			Out.VolumetricLighting = Value.asInt > 0;
			GFSDK_GSA_ReleaseVariant(&Value);

			// Lens Flares
			Status = GFSDK_GSA_GetOptionValue(&Value, TEXT("LensFlares"));
			checkSlow( Status == NV_GSA_STATUS_OK); 			
			Out.LensFlares = Value.asInt > 0;
			GFSDK_GSA_ReleaseVariant(&Value);

			// AntiAliasing
			Status = GFSDK_GSA_GetOptionValue(&Value, TEXT("AntiAliasing"));
			checkSlow( Status == NV_GSA_STATUS_OK); 			
			Out.AntiAliasingIndex = Value.asInt;
			GFSDK_GSA_ReleaseVariant(&Value);

			// Bloom
			Status = GFSDK_GSA_GetOptionValue(&Value, TEXT("Bloom"));
			checkSlow( Status == NV_GSA_STATUS_OK); 			
			Out.BloomIndex = Value.asInt;
			GFSDK_GSA_ReleaseVariant(&Value);

			// Motion Blur
			Status = GFSDK_GSA_GetOptionValue(&Value, TEXT("MotionBlur"));
			checkSlow( Status == NV_GSA_STATUS_OK); 			
			Out.MotionBlurIndex = Value.asInt;
			GFSDK_GSA_ReleaseVariant(&Value);

			// AO
			Status = GFSDK_GSA_GetOptionValue(&Value, TEXT("AmbientOcclusion"));
			checkSlow( Status == NV_GSA_STATUS_OK); 			
			Out.AmbientOcclusionIndex = Value.asInt;
			GFSDK_GSA_ReleaseVariant(&Value);

			// DOF
			Status = GFSDK_GSA_GetOptionValue(&Value, TEXT("DepthOfField"));
			checkSlow( Status == NV_GSA_STATUS_OK); 			
			Out.DOFIndex = Value.asInt;
			GFSDK_GSA_ReleaseVariant(&Value);

			// Flex
			Status = GFSDK_GSA_GetOptionValue(&Value, TEXT("Flex"));
			checkSlow( Status == NV_GSA_STATUS_OK); 			
			Out.FlexIndex = Value.asInt;
			GFSDK_GSA_ReleaseVariant(&Value);

			return Out;
		}
#endif	//__TW_WITH_GSA_	
	}
};

// -------------------------------------------------------------------------------------
// Display Setting
// -------------------------------------------------------------------------------------
struct native DisplaySetting
{
	var bool Fullscreen;
	var bool BorderlessWindow;

	structcpptext
	{
		void CopyToNativeSettings(FSystemSettings& OutSettings, UEngine* OutEngine)
		{
			OutSettings.bFullscreen = Fullscreen;
		#if __TW_BORDERLESS_WINDOW_SUPPORT_
			OutSettings.bBorderless = BorderlessWindow;
		#endif
		}

		void CopyFromNativeSettings(FSystemSettings& InSettings, UEngine* InEngine)
		{
			Fullscreen = InSettings.bFullscreen;
		#if __TW_BORDERLESS_WINDOW_SUPPORT_
			BorderlessWindow = InSettings.bBorderless;
		#endif
		}
	}
};

// -------------------------------------------------------------------------------------
// VSync Setting
// -------------------------------------------------------------------------------------
struct native VSyncSetting
{
	var bool VSync;

	structcpptext
	{
		void CopyToNativeSettings(FSystemSettings& OutSettings, UEngine* OutEngine)
		{
			OutSettings.bUseVSync = VSync;
		}

		void CopyFromNativeSettings(FSystemSettings& InSettings, UEngine* InEngine)
		{
			VSync = InSettings.bUseVSync;
		}
	}
};

// -------------------------------------------------------------------------------------
// Variable Framerate Setting
// -------------------------------------------------------------------------------------
struct native VariableFramerateSetting
{
	var bool VariableFrameRate;

	structcpptext
	{
		void CopyToNativeSettings(FSystemSettings& OutSettings, UEngine* OutEngine)
		{
			OutEngine->bSmoothFrameRate = !VariableFrameRate;
		}

		void CopyFromNativeSettings(FSystemSettings& InSettings, UEngine* InEngine)
		{
			VariableFrameRate = !InEngine->bSmoothFrameRate;
		}
	}
};

// -------------------------------------------------------------------------------------
// Film Grain Setting
// -------------------------------------------------------------------------------------
struct native FilmGrainSetting
{
	var float FilmGrainScale;

	structcpptext
	{
		void CopyToNativeSettings(FSystemSettings& OutSettings, UEngine* OutEngine)
		{
			OutSettings.ImageGrainScaler = FilmGrainScale;
		}

		void CopyFromNativeSettings(FSystemSettings& InSettings, UEngine* InEngine)
		{
			FilmGrainScale = InSettings.ImageGrainScaler;
		}
	}
};

// -------------------------------------------------------------------------------------
// Flex Setting
// -------------------------------------------------------------------------------------
struct native FlexSetting
{
	var int FlexLevel;

	structcpptext
	{
		void CopyToNativeSettings(FSystemSettings& OutSettings, UEngine* OutEngine)
		{
			OutEngine->PhysXLevel = FlexLevel;
		}

		void CopyFromNativeSettings(FSystemSettings& InSettings, UEngine* InEngine)
		{
			FlexLevel = InEngine->PhysXLevel;
		}
	}
};

// -------------------------------------------------------------------------------------
// Environment Setting
// -------------------------------------------------------------------------------------
struct native EnvironmentDetailSetting
{
	// Native setting(s)
	var int DetailMode;
	var bool AllowLightFunctions;
	var bool bDisableCanBecomeDynamicWakeup;
	var float MakeDynamicCollisionThreshold;

	// Script setting(s)
	var float DestructionLifetimeScale;

	structcpptext
	{
		void CopyToNativeSettings(FSystemSettings& OutSettings, UEngine* OutEngine)
		{
			OutSettings.DetailMode = DetailMode;
			OutSettings.bAllowLightFunctions = AllowLightFunctions;
			OutSettings.bDisableCanBecomeDynamicWakeup = bDisableCanBecomeDynamicWakeup;
			OutSettings.MakeDynamicCollisionThreshold = MakeDynamicCollisionThreshold;
		}

		void CopyFromNativeSettings(FSystemSettings& InSettings, UEngine* InEngine)
		{
			DetailMode = InSettings.DetailMode;
			AllowLightFunctions = InSettings.bAllowLightFunctions;
			bDisableCanBecomeDynamicWakeup = InSettings.bDisableCanBecomeDynamicWakeup;
			MakeDynamicCollisionThreshold = InSettings.MakeDynamicCollisionThreshold;
		}
	}
};

// -------------------------------------------------------------------------------------
// Shadow Setting
// -------------------------------------------------------------------------------------
struct native ShadowQualitySetting
{
	var bool bAllowWholeSceneDominantShadows;
	var bool bOverrideMapWholeSceneDominantShadowSetting;
	var bool bAllowDynamicShadows;
	var bool bAllowPerObjectShadows;
	var int MaxWholeSceneDominantShadowResolution;
	var int MaxShadowResolution;
	var int ShadowFadeResolution;
	var int MinShadowResolution;
	var float ShadowTexelsPerPixel;
	var float GlobalShadowDistanceScale;
	var bool AllowForegroundPreshadows;

	structcpptext
	{
		void CopyToNativeSettings(FSystemSettings& OutSettings, UEngine* OutEngine)
		{
			OutSettings.bAllowWholeSceneDominantShadows = bAllowWholeSceneDominantShadows;
			OutSettings.bOverrideMapWholeSceneDominantShadowSetting = bOverrideMapWholeSceneDominantShadowSetting;
			OutSettings.bAllowDynamicShadows = bAllowDynamicShadows;
			OutSettings.bAllowPerObjectShadows = bAllowPerObjectShadows;
			OutSettings.MaxWholeSceneDominantShadowResolution = MaxWholeSceneDominantShadowResolution;
			OutSettings.MaxShadowResolution = MaxShadowResolution;
			OutSettings.ShadowFadeResolution = ShadowFadeResolution;
			OutSettings.MinShadowResolution = MinShadowResolution;
			OutSettings.ShadowTexelsPerPixel = ShadowTexelsPerPixel;
			OutSettings.GlobalShadowDistanceScale = GlobalShadowDistanceScale;
			OutSettings.bAllowForegroundPreshadows = AllowForegroundPreshadows;
		}

		void CopyFromNativeSettings(FSystemSettings& InSettings, UEngine* InEngine)
		{
			bAllowWholeSceneDominantShadows = InSettings.bAllowWholeSceneDominantShadows;
			bOverrideMapWholeSceneDominantShadowSetting = InSettings.bOverrideMapWholeSceneDominantShadowSetting;
			bAllowDynamicShadows = InSettings.bAllowDynamicShadows;
			bAllowPerObjectShadows = InSettings.bAllowPerObjectShadows;
			MaxWholeSceneDominantShadowResolution = InSettings.MaxWholeSceneDominantShadowResolution;
			MaxShadowResolution = InSettings.MaxShadowResolution;
			ShadowFadeResolution = InSettings.ShadowFadeResolution;
			MinShadowResolution = InSettings.MinShadowResolution;
			ShadowTexelsPerPixel = InSettings.ShadowTexelsPerPixel;
			GlobalShadowDistanceScale = InSettings.GlobalShadowDistanceScale;
			AllowForegroundPreshadows = InSettings.bAllowForegroundPreshadows;
		}
	}
};

// -------------------------------------------------------------------------------------
// FX Setting
// -------------------------------------------------------------------------------------
struct native FXQualitySetting
{
	// Native settings
	var int ParticleLODBias;
	var int DistanceFogQuality;
	var bool Distortion;
	var bool FilteredDistortion;
	var bool DropParticleDistortion;
	var bool AllowSecondaryBloodEffects;

	// Script settings
	var float EmitterPoolScale;
	var float ShellEjectLifetime;
	var bool AllowExplosionLights;
	var bool AllowSprayActorLights;
	var bool AllowFootstepSounds;
	var bool AllowBloodSplatterDecals;
	var bool AllowRagdollAndGoreOnDeadBodies;
	var bool AllowPilotLights;
	var int MaxImpactEffectDecals;
	var int MaxExplosionDecals;
	var float GoreFXLifetimeMultiplier;
	var int MaxBloodEffects;
	var int MaxGoreEffects;
	var int MaxPersistentSplatsPerFrame;

	structcpptext
	{
		void CopyToNativeSettings(FSystemSettings& OutSettings, UEngine* OutEngine)
		{
			OutSettings.ParticleLODBias = ParticleLODBias;
			OutSettings.DistanceFogQuality = DistanceFogQuality;
			OutSettings.bAllowDistortion = Distortion;
			OutSettings.bAllowFilteredDistortion = FilteredDistortion;
			OutSettings.bAllowParticleDistortionDropping = DropParticleDistortion;
			OutSettings.bAllowSecondaryBloodEffects = AllowSecondaryBloodEffects;
		}

		void CopyFromNativeSettings(FSystemSettings& InSettings, UEngine* InEngine)
		{
			ParticleLODBias = InSettings.ParticleLODBias;
			DistanceFogQuality = InSettings.DistanceFogQuality;
			Distortion = InSettings.bAllowDistortion;
			FilteredDistortion = InSettings.bAllowFilteredDistortion;
			DropParticleDistortion = InSettings.bAllowParticleDistortionDropping;
			AllowSecondaryBloodEffects = InSettings.bAllowSecondaryBloodEffects;
		}
	}
};

// -------------------------------------------------------------------------------------
// Realtime Reflection Setting
// -------------------------------------------------------------------------------------
struct native RealtimeReflectionsSetting
{
	var bool bAllowScreenSpaceReflections;

	structcpptext
	{
		void CopyToNativeSettings(FSystemSettings& OutSettings, UEngine* OutEngine)
		{
			OutSettings.bAllowScreenSpaceReflections = bAllowScreenSpaceReflections;
		}

		void CopyFromNativeSettings(FSystemSettings& InSettings, UEngine* InEngine)
		{
			bAllowScreenSpaceReflections = InSettings.bAllowScreenSpaceReflections;
		}
	}
};

// -------------------------------------------------------------------------------------
// Character Detail Setting
// -------------------------------------------------------------------------------------
 struct native CharacterDetailSetting
{
	// System settings
	var int SkeletalMeshLODBias;
	var bool AllowSubsurfaceScattering;
	var float KinematicUpdateDistFactorScale;
	var bool ShouldCorpseCollideWithDead;
	var bool ShouldCorpseCollideWithLiving;
	var bool ShouldCorpseCollideWithDeadAfterSleep;

	// Script settings
	var int MaxBodyWoundDecals;
	var int MaxDeadBodies;
	var bool bAllowPhysics;

	structcpptext
	{
		void CopyToNativeSettings(FSystemSettings& OutSettings, UEngine* OutEngine)
		{
			OutSettings.SkeletalMeshLODBias = SkeletalMeshLODBias;
			OutSettings.bAllowSubsurfaceScattering = AllowSubsurfaceScattering;
			OutSettings.KinematicUpdateDistFactorScale = KinematicUpdateDistFactorScale;
			OutSettings.bShouldCorpseCollideWithDead = ShouldCorpseCollideWithDead;
			OutSettings.bShouldCorpseCollideWithLiving = ShouldCorpseCollideWithLiving;
			OutSettings.bShouldCorpseCollideWithDeadAfterSleep = ShouldCorpseCollideWithDeadAfterSleep;
		}

		void CopyFromNativeSettings(FSystemSettings& InSettings, UEngine* InEngine)
		{
			SkeletalMeshLODBias = InSettings.SkeletalMeshLODBias;
			AllowSubsurfaceScattering = InSettings.bAllowSubsurfaceScattering;
			KinematicUpdateDistFactorScale = InSettings.KinematicUpdateDistFactorScale;
			ShouldCorpseCollideWithDead = InSettings.bShouldCorpseCollideWithDead;
			ShouldCorpseCollideWithLiving = InSettings.bShouldCorpseCollideWithLiving;
			ShouldCorpseCollideWithDeadAfterSleep = InSettings.bShouldCorpseCollideWithDeadAfterSleep;
		}
	}
};

// -------------------------------------------------------------------------------------
// Light Shafts Setting
// -------------------------------------------------------------------------------------
struct native LightShaftsSetting
{
	var bool bAllowLightShafts;

	structcpptext
	{
		void CopyToNativeSettings(FSystemSettings& OutSettings, UEngine* OutEngine)
		{
			OutSettings.bAllowLightShafts = bAllowLightShafts;
		}

		void CopyFromNativeSettings(FSystemSettings& InSettings, UEngine* InEngine)
		{
			bAllowLightShafts = InSettings.bAllowLightShafts;
		}
	}
};

// -------------------------------------------------------------------------------------
// Volumetric Lighting Setting
// -------------------------------------------------------------------------------------
struct native VolumetricLightingSetting
{
	var bool bAllowLightCones;

	structcpptext
	{
		void CopyToNativeSettings(FSystemSettings& OutSettings, UEngine* OutEngine)
		{
			OutSettings.bAllowLightCones = bAllowLightCones;
		}

		void CopyFromNativeSettings(FSystemSettings& InSettings, UEngine* InEngine)
		{
			bAllowLightCones = InSettings.bAllowLightCones;
		}
	}
};

// -------------------------------------------------------------------------------------
// Lens Flare Setting
// -------------------------------------------------------------------------------------
struct native LensFlareSetting
{
	var bool bAllowLensFlares;

	structcpptext
	{
		void CopyToNativeSettings(FSystemSettings& OutSettings, UEngine* OutEngine)
		{
			OutSettings.bAllowLensFlares = bAllowLensFlares;
		}

		void CopyFromNativeSettings(FSystemSettings& InSettings, UEngine* InEngine)
		{
			bAllowLensFlares = InSettings.bAllowLensFlares;
		}
	}
};

// -------------------------------------------------------------------------------------
// Texture resolution
// -------------------------------------------------------------------------------------
struct native TextureResolutionSetting
{
	var int UIBias;
	var int ShadowmapBias;
	var int CharacterBias;
	var int Weapon1stBias;
	var int Weapon3rdBias;
	var int EnvironmentBias;
	var int FXBias;

	structcpptext
	{
		void CopyToNativeSettings(FSystemSettings& OutSettings, UEngine* OutEngine)
		{
			OutSettings.TextureLODSettings.GetTextureLODGroup(TEXTUREGROUP_UI).LODBias = UIBias;
			OutSettings.TextureLODSettings.GetTextureLODGroup(TEXTUREGROUP_UIWithMips).LODBias = UIBias;
			OutSettings.TextureLODSettings.GetTextureLODGroup(TEXTUREGROUP_UIStreamable).LODBias = UIBias; //@ TWI - bedwards: UI texture streaming support
			OutSettings.TextureLODSettings.GetTextureLODGroup(TEXTUREGROUP_Shadowmap).LODBias = ShadowmapBias;
			OutSettings.TextureLODSettings.GetTextureLODGroup(TEXTUREGROUP_Character).LODBias = CharacterBias;
			OutSettings.TextureLODSettings.GetTextureLODGroup(TEXTUREGROUP_CharacterNormalMap).LODBias = CharacterBias;
			OutSettings.TextureLODSettings.GetTextureLODGroup(TEXTUREGROUP_CharacterSpecular).LODBias = CharacterBias;
			OutSettings.TextureLODSettings.GetTextureLODGroup(TEXTUREGROUP_Creature).LODBias = CharacterBias;
			OutSettings.TextureLODSettings.GetTextureLODGroup(TEXTUREGROUP_CreatureNormalMap).LODBias = CharacterBias;
			OutSettings.TextureLODSettings.GetTextureLODGroup(TEXTUREGROUP_CreatureSpecular).LODBias = CharacterBias;
			OutSettings.TextureLODSettings.GetTextureLODGroup(TEXTUREGROUP_Cosmetic).LODBias = CharacterBias;
			OutSettings.TextureLODSettings.GetTextureLODGroup(TEXTUREGROUP_CosmeticNormalMap).LODBias = CharacterBias;
			OutSettings.TextureLODSettings.GetTextureLODGroup(TEXTUREGROUP_CosmeticSpecular).LODBias = CharacterBias;
			OutSettings.TextureLODSettings.GetTextureLODGroup(TEXTUREGROUP_Weapon).LODBias = Weapon1stBias;
			OutSettings.TextureLODSettings.GetTextureLODGroup(TEXTUREGROUP_WeaponNormalMap).LODBias = Weapon1stBias;
			OutSettings.TextureLODSettings.GetTextureLODGroup(TEXTUREGROUP_WeaponSpecular).LODBias = Weapon1stBias;
			OutSettings.TextureLODSettings.GetTextureLODGroup(TEXTUREGROUP_Weapon3rd).LODBias = Weapon3rdBias;
			OutSettings.TextureLODSettings.GetTextureLODGroup(TEXTUREGROUP_Weapon3rdNormalMap).LODBias = Weapon3rdBias;
			OutSettings.TextureLODSettings.GetTextureLODGroup(TEXTUREGROUP_Weapon3rdSpecular).LODBias = Weapon3rdBias;
			OutSettings.TextureLODSettings.GetTextureLODGroup(TEXTUREGROUP_World).LODBias = EnvironmentBias;
			OutSettings.TextureLODSettings.GetTextureLODGroup(TEXTUREGROUP_WorldNormalMap).LODBias = EnvironmentBias;
			OutSettings.TextureLODSettings.GetTextureLODGroup(TEXTUREGROUP_WorldSpecular).LODBias = EnvironmentBias;
			OutSettings.TextureLODSettings.GetTextureLODGroup(TEXTUREGROUP_Effects).LODBias = FXBias;
			OutSettings.TextureLODSettings.GetTextureLODGroup(TEXTUREGROUP_EffectsNotFiltered).LODBias = FXBias;
		}

		void CopyFromNativeSettings(FSystemSettings& InSettings, UEngine* InEngine)
		{
			// UI
			UIBias = InSettings.TextureLODSettings.GetTextureLODGroup(TEXTUREGROUP_UI).LODBias;

			// Shadowmap
			ShadowmapBias = InSettings.TextureLODSettings.GetTextureLODGroup(TEXTUREGROUP_Shadowmap).LODBias;

			CharacterBias = InSettings.TextureLODSettings.GetTextureLODGroup(TEXTUREGROUP_Character).LODBias;
			if( CharacterBias != InSettings.TextureLODSettings.GetTextureLODGroup(TEXTUREGROUP_CharacterNormalMap).LODBias ||
				CharacterBias != InSettings.TextureLODSettings.GetTextureLODGroup(TEXTUREGROUP_CharacterSpecular).LODBias ||
				CharacterBias != InSettings.TextureLODSettings.GetTextureLODGroup(TEXTUREGROUP_Creature).LODBias ||
				CharacterBias != InSettings.TextureLODSettings.GetTextureLODGroup(TEXTUREGROUP_CreatureNormalMap).LODBias ||
				CharacterBias != InSettings.TextureLODSettings.GetTextureLODGroup(TEXTUREGROUP_CreatureSpecular).LODBias || 
				CharacterBias != InSettings.TextureLODSettings.GetTextureLODGroup(TEXTUREGROUP_Cosmetic).LODBias ||
				CharacterBias != InSettings.TextureLODSettings.GetTextureLODGroup(TEXTUREGROUP_CosmeticNormalMap).LODBias ||
				CharacterBias != InSettings.TextureLODSettings.GetTextureLODGroup(TEXTUREGROUP_CosmeticSpecular).LODBias)
			{
				warnf(TEXT("Settings mismatch for Character Texture Resolution"));
				CharacterBias = -1;
			}

			// First person weapons
			Weapon1stBias = InSettings.TextureLODSettings.GetTextureLODGroup(TEXTUREGROUP_Weapon).LODBias;
			if( Weapon1stBias != InSettings.TextureLODSettings.GetTextureLODGroup(TEXTUREGROUP_WeaponNormalMap).LODBias ||
				Weapon1stBias != InSettings.TextureLODSettings.GetTextureLODGroup(TEXTUREGROUP_WeaponSpecular).LODBias )
			{
				warnf(TEXT("Settings mismatch for 1st Person Weapon Texture Resolution"));
				Weapon1stBias = -1;
			}

			// Third person weapons
			Weapon3rdBias = InSettings.TextureLODSettings.GetTextureLODGroup(TEXTUREGROUP_Weapon3rd).LODBias;
			if( Weapon3rdBias != InSettings.TextureLODSettings.GetTextureLODGroup(TEXTUREGROUP_Weapon3rdNormalMap).LODBias ||
				Weapon3rdBias != InSettings.TextureLODSettings.GetTextureLODGroup(TEXTUREGROUP_Weapon3rdSpecular).LODBias )
			{
				warnf(TEXT("Settings mismatch for 3rd Person Weapon Texture Resolution"));
				Weapon3rdBias = -1;
			}

			// Environment
			EnvironmentBias = InSettings.TextureLODSettings.GetTextureLODGroup(TEXTUREGROUP_World).LODBias;
			if( EnvironmentBias != InSettings.TextureLODSettings.GetTextureLODGroup(TEXTUREGROUP_WorldNormalMap).LODBias ||
				EnvironmentBias != InSettings.TextureLODSettings.GetTextureLODGroup(TEXTUREGROUP_WorldSpecular).LODBias )
			{
				warnf(TEXT("Settings mismatch for Environment Texture Resolution"));
				EnvironmentBias = -1;
			}

			// FX
			FXBias = InSettings.TextureLODSettings.GetTextureLODGroup(TEXTUREGROUP_Effects).LODBias;
			if( FXBias != InSettings.TextureLODSettings.GetTextureLODGroup(TEXTUREGROUP_EffectsNotFiltered).LODBias )
			{
				warnf(TEXT("Settings mismatch for FX Texture Resolution"));
				FXBias = -1;
			}
		}
	}
};

// -------------------------------------------------------------------------------------
// Texture Filtering
// -------------------------------------------------------------------------------------
struct native TextureFilterSetting
{
	var name MinMagFilter;
	var name MipFilter;
	var int MaxAnisotropy;

	structcpptext
	{
		void CopyToNativeSettings(FSystemSettings& OutSettings, UEngine* OutEngine)
		{
			// Anisotropy setting
			OutSettings.MaxAnisotropy = MaxAnisotropy;

			// Filter mode
			ESamplerFilter Filter = SF_Trilinear, NoMipFilter = SF_Bilinear;
			if( MinMagFilter == NAME_Linear && MipFilter == NAME_Point )
			{
				Filter = SF_Bilinear;
				NoMipFilter = SF_Bilinear;
			}
			else if( MinMagFilter == NAME_Linear && MipFilter == NAME_Linear )
			{
				Filter = SF_Trilinear;
				NoMipFilter = SF_Bilinear;
			}
			else if( MinMagFilter == NAME_Aniso && MipFilter == NAME_Linear )
			{
				Filter = SF_AnisotropicLinear;
				NoMipFilter = SF_AnisotropicPoint;
			}

			// Assign to texture groups
			OutSettings.TextureLODSettings.GetTextureLODGroup(TEXTUREGROUP_Shadowmap).Filter = Filter;
			OutSettings.TextureLODSettings.GetTextureLODGroup(TEXTUREGROUP_Character).Filter = Filter;
			OutSettings.TextureLODSettings.GetTextureLODGroup(TEXTUREGROUP_CharacterNormalMap).Filter = Filter;
			OutSettings.TextureLODSettings.GetTextureLODGroup(TEXTUREGROUP_CharacterSpecular).Filter = Filter;
			OutSettings.TextureLODSettings.GetTextureLODGroup(TEXTUREGROUP_Creature).Filter = Filter;
			OutSettings.TextureLODSettings.GetTextureLODGroup(TEXTUREGROUP_CreatureNormalMap).Filter = Filter;
			OutSettings.TextureLODSettings.GetTextureLODGroup(TEXTUREGROUP_CreatureSpecular).Filter = Filter;
			OutSettings.TextureLODSettings.GetTextureLODGroup(TEXTUREGROUP_Cosmetic).Filter = Filter;
			OutSettings.TextureLODSettings.GetTextureLODGroup(TEXTUREGROUP_CosmeticNormalMap).Filter = Filter;
			OutSettings.TextureLODSettings.GetTextureLODGroup(TEXTUREGROUP_CosmeticSpecular).Filter = Filter;
			OutSettings.TextureLODSettings.GetTextureLODGroup(TEXTUREGROUP_Weapon).Filter = Filter;
			OutSettings.TextureLODSettings.GetTextureLODGroup(TEXTUREGROUP_WeaponNormalMap).Filter = Filter;
			OutSettings.TextureLODSettings.GetTextureLODGroup(TEXTUREGROUP_WeaponSpecular).Filter = Filter;
			OutSettings.TextureLODSettings.GetTextureLODGroup(TEXTUREGROUP_Weapon3rd).Filter = Filter;
			OutSettings.TextureLODSettings.GetTextureLODGroup(TEXTUREGROUP_Weapon3rdNormalMap).Filter = Filter;
			OutSettings.TextureLODSettings.GetTextureLODGroup(TEXTUREGROUP_Weapon3rdSpecular).Filter = Filter;
			OutSettings.TextureLODSettings.GetTextureLODGroup(TEXTUREGROUP_World).Filter = Filter;
			OutSettings.TextureLODSettings.GetTextureLODGroup(TEXTUREGROUP_WorldNormalMap).Filter = Filter;
			OutSettings.TextureLODSettings.GetTextureLODGroup(TEXTUREGROUP_WorldSpecular).Filter = Filter;
			OutSettings.TextureLODSettings.GetTextureLODGroup(TEXTUREGROUP_Effects).Filter = Filter;
			OutSettings.TextureLODSettings.GetTextureLODGroup(TEXTUREGROUP_UIWithMips).Filter = Filter;

			// Special texture groups /wo mip filtering
			OutSettings.TextureLODSettings.GetTextureLODGroup(TEXTUREGROUP_UIStreamable).Filter = NoMipFilter;
			OutSettings.TextureLODSettings.GetTextureLODGroup(TEXTUREGROUP_UI).Filter = NoMipFilter;
			OutSettings.TextureLODSettings.GetTextureLODGroup(TEXTUREGROUP_EffectsNotFiltered).Filter = NoMipFilter;
		}

		void CopyFromNativeSettings(FSystemSettings& InSettings, UEngine* InEngine)
		{
			// Anisotropy setting
			MaxAnisotropy = InSettings.MaxAnisotropy;

			ESamplerFilter Filter;
			Filter = InSettings.TextureLODSettings.GetTextureLODGroup(TEXTUREGROUP_World).Filter;
			if( Filter != InSettings.TextureLODSettings.GetTextureLODGroup(TEXTUREGROUP_Shadowmap).Filter ||
				Filter != InSettings.TextureLODSettings.GetTextureLODGroup(TEXTUREGROUP_Character).Filter ||
				Filter != InSettings.TextureLODSettings.GetTextureLODGroup(TEXTUREGROUP_CharacterNormalMap).Filter ||
				Filter != InSettings.TextureLODSettings.GetTextureLODGroup(TEXTUREGROUP_CharacterSpecular).Filter ||
				Filter != InSettings.TextureLODSettings.GetTextureLODGroup(TEXTUREGROUP_Creature).Filter ||
				Filter != InSettings.TextureLODSettings.GetTextureLODGroup(TEXTUREGROUP_CreatureNormalMap).Filter ||
				Filter != InSettings.TextureLODSettings.GetTextureLODGroup(TEXTUREGROUP_CreatureSpecular).Filter ||
				Filter != InSettings.TextureLODSettings.GetTextureLODGroup(TEXTUREGROUP_Cosmetic).Filter ||
				Filter != InSettings.TextureLODSettings.GetTextureLODGroup(TEXTUREGROUP_CosmeticNormalMap).Filter ||
				Filter != InSettings.TextureLODSettings.GetTextureLODGroup(TEXTUREGROUP_CosmeticSpecular).Filter ||
				Filter != InSettings.TextureLODSettings.GetTextureLODGroup(TEXTUREGROUP_Weapon).Filter ||
				Filter != InSettings.TextureLODSettings.GetTextureLODGroup(TEXTUREGROUP_WeaponNormalMap).Filter ||
				Filter != InSettings.TextureLODSettings.GetTextureLODGroup(TEXTUREGROUP_WeaponSpecular).Filter ||
				Filter != InSettings.TextureLODSettings.GetTextureLODGroup(TEXTUREGROUP_Weapon3rd).Filter ||
				Filter != InSettings.TextureLODSettings.GetTextureLODGroup(TEXTUREGROUP_Weapon3rdNormalMap).Filter ||
				Filter != InSettings.TextureLODSettings.GetTextureLODGroup(TEXTUREGROUP_Weapon3rdSpecular).Filter ||
				Filter != InSettings.TextureLODSettings.GetTextureLODGroup(TEXTUREGROUP_WorldNormalMap).Filter ||
				Filter != InSettings.TextureLODSettings.GetTextureLODGroup(TEXTUREGROUP_WorldSpecular).Filter ||
				Filter != InSettings.TextureLODSettings.GetTextureLODGroup(TEXTUREGROUP_Effects).Filter ||
				Filter != InSettings.TextureLODSettings.GetTextureLODGroup(TEXTUREGROUP_UIWithMips).Filter )
			{
				warnf(TEXT("Settings mismatch for Texture Filter"));
			}

			ESamplerFilter NoMipFilter;
			NoMipFilter = InSettings.TextureLODSettings.GetTextureLODGroup(TEXTUREGROUP_UI).Filter;
			if( NoMipFilter != InSettings.TextureLODSettings.GetTextureLODGroup(TEXTUREGROUP_EffectsNotFiltered).Filter ||
				NoMipFilter != InSettings.TextureLODSettings.GetTextureLODGroup(TEXTUREGROUP_UIStreamable).Filter ) //@ TWI - bedwards: UI texture streaming support
			{
				warnf(TEXT("Settings mismatch for Texture Filter (No Mips)"));
			}

			if( Filter == SF_Bilinear && NoMipFilter == SF_Bilinear )
			{
				MinMagFilter = NAME_Linear;
				MipFilter = NAME_Point;
			}
			else if( Filter == SF_Trilinear && NoMipFilter == SF_Bilinear )
			{
				MinMagFilter = NAME_Linear;
				MipFilter = NAME_Linear;
			}
			else if( Filter == SF_AnisotropicLinear && NoMipFilter == SF_AnisotropicPoint )
			{
				MinMagFilter = NAME_Aniso;
				MipFilter = NAME_Linear;
			}
		}
	}
};

// -------------------------------------------------------------------------------------
// Bloom
// -------------------------------------------------------------------------------------
struct native BloomSetting
{
	var bool Bloom;
	var int BloomQuality;

	structcpptext
	{
		void CopyToNativeSettings(FSystemSettings& OutSettings, UEngine* OutEngine)
		{
			OutSettings.bAllowBloom = Bloom;
			OutSettings.BloomQuality = BloomQuality;
		}

		void CopyFromNativeSettings(FSystemSettings& InSettings, UEngine* InEngine)
		{
			Bloom = InSettings.bAllowBloom;
			BloomQuality = InSettings.BloomQuality;
		}
	}
};

// -------------------------------------------------------------------------------------
// Motion Blur
// -------------------------------------------------------------------------------------
struct native MotionBlurSetting
{
	var bool MotionBlur;
	var int MotionBlurQuality;

	structcpptext
	{
		void CopyToNativeSettings(FSystemSettings& OutSettings, UEngine* OutEngine)
		{
			OutSettings.bAllowMotionBlur = MotionBlur;
			OutSettings.MotionBlurQuality = MotionBlurQuality;
		}

		void CopyFromNativeSettings(FSystemSettings& InSettings, UEngine* InEngine)
		{
			MotionBlur = InSettings.bAllowMotionBlur;
			MotionBlurQuality = InSettings.MotionBlurQuality;
		}
	}
};

// -------------------------------------------------------------------------------------
// Anti Aliasing
// -------------------------------------------------------------------------------------
struct native AntiAliasingSetting
{
	var bool PostProcessAA;

	structcpptext
	{
		void CopyToNativeSettings(FSystemSettings& OutSettings, UEngine* OutEngine)
		{
			OutSettings.bAllowPostProcessAA = PostProcessAA;
		}

		void CopyFromNativeSettings(FSystemSettings& InSettings, UEngine* InEngine)
		{
			PostProcessAA = InSettings.bAllowPostProcessAA;
		}
	}
};

// -------------------------------------------------------------------------------------
// Ambient Occlusion
// -------------------------------------------------------------------------------------
struct native AmbientOcclusionSetting
{
	var bool AmbientOcclusion;
	var bool HBAO;

	structcpptext
	{
		void CopyToNativeSettings(FSystemSettings& OutSettings, UEngine* OutEngine)
		{
			OutSettings.bAllowAmbientOcclusion = AmbientOcclusion;
		#if __TW_GAMEWORKS_HBAO_
			OutSettings.bAllowHBAO = HBAO;
		#endif // __TW_GAMEWORKS_HBAO_
		}

		void CopyFromNativeSettings(FSystemSettings& InSettings, UEngine* InEngine)
		{
			AmbientOcclusion = InSettings.bAllowAmbientOcclusion;
		#if __TW_GAMEWORKS_HBAO_
			HBAO = InSettings.bAllowHBAO;
		#endif // __TW_GAMEWORKS_HBAO_
		}
	}
};


// -------------------------------------------------------------------------------------
// Depth Of Field
// -------------------------------------------------------------------------------------
struct native DOFSetting
{
	var bool DepthOfField;
	var int DepthOfFieldQuality;

	structcpptext
	{
		void CopyToNativeSettings(FSystemSettings& OutSettings, UEngine* OutEngine)
		{
			OutSettings.bAllowDepthOfField = DepthOfField;
			OutSettings.DepthOfFieldQuality = DepthOfFieldQuality;
		}

		void CopyFromNativeSettings(FSystemSettings& InSettings, UEngine* InEngine)
		{
			DepthOfField = InSettings.bAllowDepthOfField;
			DepthOfFieldQuality = InSettings.DepthOfFieldQuality;
		}
	}
};

//======================================================================================
// Setting Presets. Contains the values that make up the quality preset.
//======================================================================================
var array<GraphicsQualitySetting> GraphicsQualityPresets;
var array<DisplaySetting> DisplayPresets;
var array<VSyncSetting> VSyncPresets;
var array<VariableFramerateSetting> VariableFrameratePresets;
var array<FilmGrainSetting> FilmGrainMinMaxPreset;
var array<FlexSetting> FlexPresets;
var array<EnvironmentDetailSetting> EnvironmentDetailPresets;
var array<ShadowQualitySetting> ShadowQualityPresets;
var array<FXQualitySetting> FXQualityPresets;
var array<RealtimeReflectionsSetting> RealtimeReflectionsPresets;
var array<CharacterDetailSetting> CharacterDetailPresets;
var array<LightShaftsSetting> LightShaftsPresets;
var array<VolumetricLightingSetting> VolumetricLightingPresets;
var array<LensFlareSetting> LensFlarePresets;
var array<TextureResolutionSetting> TextureResolutionPresets;
var array<TextureFilterSetting> TextureFilterPresets;
var array<BloomSetting> BloomPresets;
var array<MotionBlurSetting> MotionBlurPresets;
var array<AntiAliasingSetting> AntiAliasingPresets;
var array<AmbientOcclusionSetting> AmbientOcclusionPresets;
var array<DOFSetting> DOFPresets;
//======================================================================================

enum GraphicsLevelPreset
{
	GRAPHICS_LOW,
	GRAPHICS_MEDIUM,
	GRAPHICS_HIGH,
	GRAPHICS_ULTRA,
	GRAPHICS_CUSTOM,
	GRAPHICS_MAX
};

struct native GFXSettings
{
	//basic
	var ResolutionSetting Resolution;
	var VSyncSetting VSync;
	var	DisplaySetting Display;
	var	VariableFramerateSetting VariableFPS;
	var FilmGrainSetting FilmGrain;
	var FlexSetting Flex;

	//advanced
	var EnvironmentDetailSetting EnvironmentDetail;
	var CharacterDetailSetting CharacterDetail;
	var FXQualitySetting FX;
	var TextureResolutionSetting TextureResolution;
	var TextureFilterSetting TextureFiltering;
	var ShadowQualitySetting Shadows;
	var RealtimeReflectionsSetting RealtimeReflections;
	var AntiAliasingSetting AntiAliasing;
	var BloomSetting Bloom;
	var MotionBlurSetting MotionBlur;
	var AmbientOcclusionSetting	AmbientOcclusion;
	var DOFSetting DepthOfField;
	var	VolumetricLightingSetting VolumetricLighting;
	var	LensFlareSetting LensFlares;
	var	LightShaftsSetting LightShafts;
};

// The current setting that the user has. Needs to be serialized.
var	transient GFXSettings CurrentGFXSettings;
//On revert, then these settings will be applied
var transient GFXSettings RevertedGFXSettings;
// Changes that the user made but did not apply
var transient GFXSettings UnsavedGFXSettings;
// Whether there is a pending restart due to unsaved changes
var transient bool UnsavedPendingRestart;

cpptext
{
#if __TW_WITH_GSA_	
	// NVIDIA GSA hooks
	static UBOOL InitGSASettings();
	static UBOOL ApplyGSASettings();
#endif	
}

// Update settings for GSA
// Note: This function definition is not compiled out for platforms 
// that don't support GSA so as to not cause a script native dependency when
// building for another platform. Instead, it turns into a empty function if
// not supported.
native static function UpdateGSASetting(string SettingName, int Index);

native static function UpdateGSAResolution(int Width, int Height);

// Update the config file
native static function FlushGSA();

/** Get/Set functions for native SystemSettings */
native static function GetCurrentNativeSettings(out GFXSettings CurrentSettings);
native static function SetNativeSettings(out GFXSettings NewSettings);

/** Returns the compat score assigned by the AppCompat system*/
native function int GetCompatLevel();

/** Queries engine to check whether the aspect ratio is available */
native function bool IsAspectRatioAvailable(SupportedAspectRatio InAspectRatio);

/** Update the resolution options based on given aspect ratio and the
	list of resolutions that are supported by the adapter
 */
native function RefreshSupportedResolutions(SupportedAspectRatio InAspectRatio);

native function string GetMonitorResolution();

/** Returns whether Nvidia FleX is supported or not */
native function bool IsFleXSupported();

/** Keeps the GSA system in sync whenever we change GFXSettings */
static function UpdateGSA(GFXSettings InSettings)
{
	// Register settings updates
	UpdateGSASetting("EnvironmentDetail", FindEnvironmentDetailIndex(InSettings.EnvironmentDetail, default.EnvironmentDetailPresets));
	UpdateGSASetting("CharacterDetail", FindCharacterDetailIndex(InSettings.CharacterDetail, default.CharacterDetailPresets));
	UpdateGSASetting("FX", FindFXQualityIndex(InSettings.FX, default.FXQualityPresets));
	UpdateGSASetting("TextureResolution", FindTextureResolutionSettingIndex(InSettings.TextureResolution, default.TextureResolutionPresets));
	UpdateGSASetting("TextureFiltering", FindTextureFilterSettingIndex(InSettings.TextureFiltering, default.TextureFilterPresets));
	UpdateGSASetting("Shadows", FindShadowQualityIndex(InSettings.Shadows, default.ShadowQualityPresets));
	UpdateGSASetting("RealtimeReflections", FindReflectionsSettingIndex(InSettings.RealtimeReflections, default.RealtimeReflectionsPresets));
	UpdateGSASetting("AntiAliasing", FindAntiAliasingSettingIndex(InSettings.AntiAliasing, default.AntiAliasingPresets));
	UpdateGSASetting("Bloom", FindBloomSettingIndex(InSettings.Bloom, default.BloomPresets));
	UpdateGSASetting("MotionBlur", FindMotionBlurSettingIndex(InSettings.MotionBlur, default.MotionBlurPresets));
	UpdateGSASetting("AmbientOcclusion", FindAmbientOcclusionSettingIndex(InSettings.AmbientOcclusion, default.AmbientOcclusionPresets));
	UpdateGSASetting("DepthOfField", FindDOFSettingIndex(InSettings.DepthOfField, default.DOFPresets));
	UpdateGSASetting("VolumetricLighting", FindVolumetricLightingSettingIndex(InSettings.VolumetricLighting, default.VolumetricLightingPresets));
	UpdateGSASetting("LensFlares", FindLensFlareSettingIndex(InSettings.LensFlares, default.LensFlarePresets));
	UpdateGSASetting("LightShafts", FindLightShaftsSettingIndex(InSettings.LightShafts, default.LightShaftsPresets));
	UpdateGSASetting("Flex", FindFlexSettingIndex(InSettings.Flex, default.FlexPresets));

	// Register resolution updates
	UpdateGSAResolution(InSettings.Resolution.ResX, InSettings.Resolution.ResY);

	// Save to config file
	FlushGSA();
}

/** Returns the aspect ratio for the given resolution */
event SupportedAspectRatio GetAspectRatio(int ResX, int ResY)
{
	local float ComputedAspectRatio;

	if( IsAspectRatioAvailable(KFASPECTRATIO_MultiMonitor) )
	{
		return KFASPECTRATIO_MultiMonitor;
	}
	else
	{
		// Compute the aspect ratio from current resolution
		ComputedAspectRatio = float(ResX)/float(ResY);

		// Match computed aspect ratio against supported aspect ratios
		if( ComputedAspectRatio ~= 4.f/3.f )
		{
			return KFASPECTRATIO_Standard_4_3;
		}
		else if( ComputedAspectRatio ~= 5.f/4.f )
		{
			return KFASPECTRATIO_Standard_5_4;
		}
		else if( ComputedAspectRatio ~= 3.f/2.f )
		{
			return KFASPECTRATIO_Standard_3_2;
		}
		else if( ComputedAspectRatio ~= 16.f/9.f)
		{
			return KFASPECTRATIO_Wide_16_9;
		}
		else if( ComputedAspectRatio ~= 16.f/10.f )
		{
			return KFASPECTRATIO_Wide_16_10;
		}
		else if( ComputedAspectRatio ~= 2.f/1.f )
		{
			return KFASPECTRATIO_ExtraWide_2_1;
		}
		else if( ComputedAspectRatio ~= 21.f/9.f )
		{
			return KFASPECTRATIO_ExtraWide_21_9;
		}
	}

	// Default: unsupress all resolutions
	return KFASPECTRATIO_All;
}

/** Function to get current script settings. Should not be called directly.
	Use GetCurrentGFXSettings() instead
 */
static function GetCurrentScriptSettings(out GFXSettings CurrentSettings)
{
	GetScriptDisplaySettings(CurrentSettings.Display);
	GetScriptVSyncSettings(CurrentSettings.VSync);
	GetScriptVariableFramerateSettings(CurrentSettings.VariableFPS);
	GetScriptFilmGrainSettings(CurrentSettings.FilmGrain);
	GetScriptFlexSettings(CurrentSettings.Flex);
	GetScriptEnvironmentDetailSettings(CurrentSettings.EnvironmentDetail);
	GetScriptShadowQualitySettings(CurrentSettings.Shadows);
	GetScriptFXQualitySettings(CurrentSettings.FX);
	GetScriptReflectionSettings(CurrentSettings.RealtimeReflections);
	GetScriptCharacterDetailSettings(CurrentSettings.CharacterDetail);
	GetScriptLightShaftsSettings(CurrentSettings.LightShafts);
	GetScriptVolumetricLightingSettings(CurrentSettings.VolumetricLighting);
	GetScriptLensFlareSettings(CurrentSettings.LensFlares);
	GetScriptTextureResolutionSettings(CurrentSettings.TextureResolution);
	GetScriptTextureFilterSettings(CurrentSettings.TextureFiltering);
	GetScriptBloomSettings(CurrentSettings.Bloom);
	GetScriptMotionBlurSettings(CurrentSettings.MotionBlur);
	GetScriptAntiAliasingSettings(CurrentSettings.AntiAliasing);
	GetScriptAmbientOcclusionSettings(CurrentSettings.AmbientOcclusion);
	GetScriptDOFSettings(CurrentSettings.DepthOfField);
}

/** Function to set script settings. Should not be called directly.
	Use SetGFXSettings() instead
 */
static function SetScriptSettings(out GFXSettings NewSettings)
{
	SetScriptDisplaySettings(NewSettings.Display);
	SetScriptVSyncSettings(NewSettings.VSync);
	SetScriptVariableFramerateSettings(NewSettings.VariableFPS);
	SetScriptFilmGrainSettings(NewSettings.FilmGrain);
	SetScriptFlexSettings(NewSettings.Flex);
	SetScriptEnvironmentDetailSettings(NewSettings.EnvironmentDetail);
	SetScriptShadowQualitySettings(NewSettings.Shadows);
	SetScriptFXQualitySettings(NewSettings.FX);
	SetScriptReflectionSettings(NewSettings.RealtimeReflections);
	SetScriptCharacterDetailSettings(NewSettings.CharacterDetail);
	SetScriptLightShaftsSettings(NewSettings.LightShafts);
	SetScriptVolumetricLightingSettings(NewSettings.VolumetricLighting);
	SetScriptLensFlareSettings(NewSettings.LensFlares);
	SetScriptTextureResolutionSettings(NewSettings.TextureResolution);
	SetScriptTextureFilterSettings(NewSettings.TextureFiltering);
	SetScriptBloomSettings(NewSettings.Bloom);
	SetScriptMotionBlurSettings(NewSettings.MotionBlur);
	SetScriptAntiAliasingSettings(NewSettings.AntiAliasing);
	SetScriptAmbientOcclusionSettings(NewSettings.AmbientOcclusion);
	SetScriptDOFSettings(NewSettings.DepthOfField);
}

//=======================================================================
// Helper functions for meta settings
//=======================================================================

//
//	Graphics Quality
//
function int FindGraphicsQualitySettingIndex(out GFXSettings Ref, out array<GraphicsQualitySetting> SettingsList)
{
	local int i;
	local GraphicsQualitySetting GraphicsQuality;

	// Retrieve graphics quality from the advanced settings
	GraphicsQuality.EnvironmentDetailIndex 	= FindEnvironmentDetailIndex(Ref.EnvironmentDetail, EnvironmentDetailPresets);
	GraphicsQuality.CharacterDetailIndex 	= FindCharacterDetailIndex(Ref.CharacterDetail, CharacterDetailPresets);
	GraphicsQuality.FXQualityIndex 			= FindFXQualityIndex(Ref.FX, FXQualityPresets);
	GraphicsQuality.TextureResolutionIndex	= FindTextureResolutionSettingIndex(Ref.TextureResolution, TextureResolutionPresets);
	GraphicsQuality.TextureFilteringIndex 	= FindTextureFilterSettingIndex(Ref.TextureFiltering, TextureFilterPresets);
	GraphicsQuality.ShadowQualityIndex 		= FindShadowQualityIndex(Ref.Shadows, ShadowQualityPresets);
	GraphicsQuality.RealtimeReflectionsIndex = FindReflectionsSettingIndex(Ref.RealtimeReflections, RealtimeReflectionsPresets);
	GraphicsQuality.LightShafts 			= FindLightShaftsSettingIndex(Ref.LightShafts, LightShaftsPresets) > 0;
	GraphicsQuality.VolumetricLighting 		= FindVolumetricLightingSettingIndex(Ref.VolumetricLighting, VolumetricLightingPresets) > 0;
	GraphicsQuality.LensFlares 				= FindLensFlareSettingIndex(Ref.LensFlares, LensFlarePresets) > 0;
	GraphicsQuality.AntiAliasingIndex 		= FindAntiAliasingSettingIndex(Ref.AntiAliasing, AntiAliasingPresets);
	GraphicsQuality.BloomIndex 				= FindBloomSettingIndex(Ref.Bloom, BloomPresets);
	GraphicsQuality.MotionBlurIndex 		= FindMotionBlurSettingIndex(Ref.MotionBlur, MotionBlurPresets);
	GraphicsQuality.AmbientOcclusionIndex 	= FindAmbientOcclusionSettingIndex(Ref.AmbientOcclusion, AmbientOcclusionPresets);
	GraphicsQuality.DOFIndex 				= FindDOFSettingIndex(Ref.DepthOfField, DOFPresets);
	GraphicsQuality.FlexIndex 				= FindFlexSettingIndex(Ref.Flex, FlexPresets);

	// Look for a match in the graphics quality presets
	for( i=0; i<SettingsList.length; i++ )
	{
		if( GraphicsQuality == SettingsList[i] )
		{
			return i;
		}
	}

	return INDEX_NONE;
}

//
// Display
//
function int FindDisplaySettingIndex(out DisplaySetting Ref, out array<DisplaySetting> SettingsList)
{
	local int i;
	for( i=0; i<SettingsList.length; i++ )
	{
		if( Ref == SettingsList[i] )
		{
			return i;
		}
	}

	return INDEX_NONE;
}

static function GetScriptDisplaySettings(out DisplaySetting Setting){}
static function SetScriptDisplaySettings(out DisplaySetting Setting){}

//
// VSync
//
function int FindVSyncSettingIndex(out VSyncSetting Ref, out array<VSyncSetting> SettingsList)
{
	local int i;
	for( i=0; i<SettingsList.length; i++ )
	{
		if( Ref == SettingsList[i] )
		{
			return i;
		}
	}

	return INDEX_NONE;
}

static function GetScriptVSyncSettings(out VSyncSetting Setting){}
static function SetScriptVSyncSettings(out VSyncSetting Setting){}

//
// Variable Framerate
//
function int FindVariableFPSSettingIndex(out VariableFramerateSetting Ref, out array<VariableFramerateSetting> SettingsList)
{
	local int i;
	for( i=0; i<SettingsList.length; i++ )
	{
		if( Ref == SettingsList[i] )
		{
			return i;
		}
	}

	return INDEX_NONE;
}

static function GetScriptVariableFramerateSettings(out VariableFramerateSetting Setting){}
static function SetScriptVariableFramerateSettings(out VariableFramerateSetting Setting){}

//
// Film Grain
//
function float GetFilmGrainSliderValue(out FilmGrainSetting Ref, out array<FilmGrainSetting> SettingsList)
{
	// Return normalized [0.0, 1.0] value for the slider
	local float SliderValue;
	SliderValue = (Ref.FilmGrainScale - SettingsList[`MIN].FilmGrainScale) / (SettingsList[`MAX].FilmGrainScale - SettingsList[`MIN].FilmGrainScale);
	return FClamp(SliderValue, 0.0, 1.0);
}

function float GetFilmGrainSettingValue(float SliderValue, out array<FilmGrainSetting> SettingsList)
{
	// Convert [0.0, 1.0] slider value to actual setting value in the range [MinFilmGrainScale, MaxFilmGrainScale]
	local float FilmGrainScale;
	FilmGrainScale = SliderValue * (SettingsList[`MAX].FilmGrainScale - SettingsList[`MIN].FilmGrainScale) + SettingsList[`MIN].FilmGrainScale;
	return FClamp(FilmGrainScale, SettingsList[`MIN].FilmGrainScale, SettingsList[`MAX].FilmGrainScale);
}

static function GetScriptFilmGrainSettings(out FilmGrainSetting Setting){}
static function SetScriptFilmGrainSettings(out FilmGrainSetting Setting){}

// Overridden comparison operators for float comparisons
static final operator(24) bool == (FilmGrainSetting A, FilmGrainSetting B)
{
	return 	A.FilmGrainScale ~= B.FilmGrainScale;
}

static final operator(26) bool != (FilmGrainSetting A, FilmGrainSetting B)
{
	return 	!(A==B);
}

//
// Environment Detail
//
static function int FindEnvironmentDetailIndex(out EnvironmentDetailSetting Ref, array<EnvironmentDetailSetting> SettingsList)
{
	local int i;
	for( i=0; i<SettingsList.length; i++ )
	{
		if( Ref == SettingsList[i] )
		{
			return i;
		}
	}

	return INDEX_NONE;
}

static function GetScriptEnvironmentDetailSettings(out EnvironmentDetailSetting Setting)
{
	Setting.DestructionLifetimeScale = class'WorldInfo'.default.DestructionLifetimeScale;
}

static function SetScriptEnvironmentDetailSettings(out EnvironmentDetailSetting Setting)
{
	class'WorldInfo'.default.DestructionLifetimeScale = Setting.DestructionLifetimeScale;
	class'WorldInfo'.static.StaticSaveConfig();
}

//
// Shadow Quality
//
static function int FindShadowQualityIndex(out ShadowQualitySetting Ref, array<ShadowQualitySetting> SettingsList)
{
	local int i;
	for( i=0; i<SettingsList.length; i++ )
	{
		if( Ref == SettingsList[i] )
		{
			return i;
		}
	}

	return INDEX_NONE;
}

static function GetScriptShadowQualitySettings(out ShadowQualitySetting Setting){}
static function SetScriptShadowQualitySettings(out ShadowQualitySetting Setting){}

//
// FX Quality
//
static function int FindFXQualityIndex(out FXQualitySetting Ref, array<FXQualitySetting> SettingsList)
{
	local int i;
	for( i=0; i<SettingsList.length; i++ )
	{
		if( Ref == SettingsList[i] )
		{
			return i;
		}
	}

	return INDEX_NONE;
}

static function GetScriptFXQualitySettings(out FXQualitySetting Setting)
{
	Setting.EmitterPoolScale = class'WorldInfo'.default.EmitterPoolScale;
	Setting.ShellEjectLifetime = class'KFMuzzleFlash'.default.ShellEjectLifetime;
	Setting.AllowExplosionLights = class'WorldInfo'.default.bAllowExplosionLights;
	Setting.AllowSprayActorLights = class'KFSprayActor'.default.bAllowSprayLights;
	Setting.AllowFootstepSounds = class'KFPawn'.default.bAllowFootstepSounds;
	Setting.AllowBloodSplatterDecals = class'KFGoreManager'.default.bAllowBloodSplatterDecals;
	Setting.AllowRagdollAndGoreOnDeadBodies = class'KFPawn'.default.bAllowRagdollAndGoreOnDeadBodies;
	Setting.AllowPilotLights = class'KFWeap_FlameBase'.default.bArePilotLightsAllowed;
	Setting.MaxImpactEffectDecals = class'KFImpactEffectManager'.default.MaxImpactEffectDecals;
	Setting.MaxExplosionDecals = class'WorldInfo'.default.MaxExplosionDecals;
	Setting.GoreFXLifetimeMultiplier = class'KFGoreManager'.default.GoreFXLifetimeMultiplier;
	Setting.MaxBloodEffects = class'KFGoreManager'.default.MaxBloodEffects;
	Setting.MaxGoreEffects = class'KFGoreManager'.default.MaxGoreEffects;
	Setting.MaxPersistentSplatsPerFrame = Class'KFGoreManager'.default.MaxPersistentSplatsPerFrame;
}

static function SetScriptFXQualitySettings(out FXQualitySetting Setting)
{
	class'WorldInfo'.default.EmitterPoolScale = Setting.EmitterPoolScale;
	class'KFMuzzleFlash'.default.ShellEjectLifetime = Setting.ShellEjectLifetime;
	class'WorldInfo'.default.bAllowExplosionLights = Setting.AllowExplosionLights;
	class'KFSprayActor'.default.bAllowSprayLights = Setting.AllowSprayActorLights;
	class'KFPawn'.default.bAllowFootstepSounds = Setting.AllowFootstepSounds;
	class'KFGoreManager'.default.bAllowBloodSplatterDecals = Setting.AllowBloodSplatterDecals;
	class'KFPawn'.default.bAllowRagdollAndGoreOnDeadBodies = Setting.AllowRagdollAndGoreOnDeadBodies;
	class'KFWeap_FlameBase'.default.bArePilotLightsAllowed = Setting.AllowPilotLights;
	class'KFImpactEffectManager'.default.MaxImpactEffectDecals = Setting.MaxImpactEffectDecals;
	class'WorldInfo'.default.MaxExplosionDecals = Setting.MaxExplosionDecals;
	class'KFGoreManager'.default.GoreFXLifetimeMultiplier =	Setting.GoreFXLifetimeMultiplier;
	class'KFGoreManager'.default.MaxBloodEffects = Setting.MaxBloodEffects;
	class'KFGoreManager'.default.MaxGoreEffects = Setting.MaxGoreEffects;
	class'KFGoreManager'.default.MaxPersistentSplatsPerFrame = Setting.MaxPersistentSplatsPerFrame;

	class'WorldInfo'.static.StaticSaveConfig();
	class'KFMuzzleFlash'.static.StaticSaveConfig();
	class'KFImpactEffectManager'.static.StaticSaveConfig();
	class'KFGoreManager'.static.StaticSaveConfig();
	class'KFSprayActor'.static.StaticSaveConfig();
	class'KFPawn'.static.StaticSaveConfig();
	class'KFWeap_FlameBase'.static.StaticSaveConfig();
}

//
// Realtime Reflections
//
static function int FindReflectionsSettingIndex(out RealtimeReflectionsSetting Ref, array<RealtimeReflectionsSetting> SettingsList)
{
	local int i;
	for( i=0; i<SettingsList.length; i++ )
	{
		if( Ref == SettingsList[i] )
		{
			return i;
		}
	}

	return INDEX_NONE;
}

static function GetScriptReflectionSettings(out RealtimeReflectionsSetting Setting) {}
static function SetScriptReflectionSettings(out RealtimeReflectionsSetting Setting) {}

//
// Character detail
//
static function int FindCharacterDetailIndex(out CharacterDetailSetting Ref, array<CharacterDetailSetting> SettingsList)
{
	local int i;
	for( i=0; i<SettingsList.length; i++ )
	{
		if( Ref == SettingsList[i] )
		{
			return i;
		}
	}

	return INDEX_NONE;
}

static function GetScriptCharacterDetailSettings(out CharacterDetailSetting Setting)
{
	Setting.MaxBodyWoundDecals = class'KFGoreManager'.default.MaxBodyWoundDecals;
	Setting.MaxDeadBodies = class'KFGoreManager'.default.MaxDeadBodies;
	Setting.bAllowPhysics = class'KFPawn'.default.bAllowAlwaysOnPhysics;
}

static function SetScriptCharacterDetailSettings(out CharacterDetailSetting Setting)
{
	class'KFGoreManager'.default.MaxBodyWoundDecals = Setting.MaxBodyWoundDecals;
	class'KFGoreManager'.default.MaxDeadBodies = Setting.MaxDeadBodies;
	class'KFPawn'.default.bAllowAlwaysOnPhysics = Setting.bAllowPhysics;

	class'KFGoreManager'.static.StaticSaveConfig();
	class'KFPawn'.static.StaticSaveConfig();
}

//
// Light Shafts
//
static function int FindLightShaftsSettingIndex(out LightShaftsSetting Ref, array<LightShaftsSetting> SettingsList)
{
	local int i;
	for( i=0; i<SettingsList.length; i++ )
	{
		if( Ref == SettingsList[i] )
		{
			return i;
		}
	}

	return INDEX_NONE;
}

static function GetScriptLightShaftsSettings(out LightShaftsSetting Setting) {}
static function SetScriptLightShaftsSettings(out LightShaftsSetting Setting) {}

//
// Volumetric Lighting
//
static function int FindVolumetricLightingSettingIndex(out VolumetricLightingSetting Ref, array<VolumetricLightingSetting> SettingsList)
{
	local int i;
	for( i=0; i<SettingsList.length; i++ )
	{
		if( Ref == SettingsList[i] )
		{
			return i;
		}
	}

	return INDEX_NONE;
}

static function GetScriptVolumetricLightingSettings(out VolumetricLightingSetting Setting) {}
static function SetScriptVolumetricLightingSettings(out VolumetricLightingSetting Setting) {}

//
// Lens Flare
//
static function int FindLensFlareSettingIndex(out LensFlareSetting Ref, array<LensFlareSetting> SettingsList)
{
	local int i;
	for( i=0; i<SettingsList.length; i++ )
	{
		if( Ref == SettingsList[i] )
		{
			return i;
		}
	}

	return INDEX_NONE;
}

static function GetScriptLensFlareSettings(out LensFlareSetting Setting) {}
static function SetScriptLensFlareSettings(out LensFlareSetting Setting) {}

//
// Texture Resolution
//
static function int FindTextureResolutionSettingIndex(out TextureResolutionSetting Ref, array<TextureResolutionSetting> SettingsList)
{
	local int i;
	for( i=0; i<SettingsList.length; i++ )
	{
		if( Ref == SettingsList[i] )
		{
			return i;
		}
	}

	return INDEX_NONE;
}

static function GetScriptTextureResolutionSettings(out TextureResolutionSetting Setting) {}
static function SetScriptTextureResolutionSettings(out TextureResolutionSetting Setting) {}

//
// Texture Filtering
//
static function int FindTextureFilterSettingIndex(out TextureFilterSetting Ref, array<TextureFilterSetting> SettingsList)
{
	local int i;
	for( i=0; i<SettingsList.length; i++ )
	{
		if( Ref == SettingsList[i] )
		{
			return i;
		}
	}

	return INDEX_NONE;
}

static function GetScriptTextureFilterSettings(out TextureFilterSetting Setting) {}
static function SetScriptTextureFilterSettings(out TextureFilterSetting Setting) {}

//
// Bloom
//
static function int FindBloomSettingIndex(out BloomSetting Ref, array<BloomSetting> SettingsList)
{
	local int i;
	for( i=0; i<SettingsList.length; i++ )
	{
		if( Ref == SettingsList[i] )
		{
			return i;
		}
	}

	return INDEX_NONE;
}

static function GetScriptBloomSettings(out BloomSetting Setting) {}
static function SetScriptBloomSettings(out BloomSetting Setting) {}

//
// Motion Blur
//
static function int FindMotionBlurSettingIndex(out MotionBlurSetting Ref, array<MotionBlurSetting> SettingsList)
{
	local int i;
	for( i=0; i<SettingsList.length; i++ )
	{
		if( Ref == SettingsList[i] )
		{
			return i;
		}
	}

	return INDEX_NONE;
}

static function GetScriptMotionBlurSettings(out MotionBlurSetting Setting) {}
static function SetScriptMotionBlurSettings(out MotionBlurSetting Setting) {}

//
// Anti Aliasing
//
static function int FindAntiAliasingSettingIndex(out AntiAliasingSetting Ref, array<AntiAliasingSetting> SettingsList)
{
	local int i;
	for( i=0; i<SettingsList.length; i++ )
	{
		if( Ref == SettingsList[i] )
		{
			return i;
		}
	}

	return INDEX_NONE;
}

static function GetScriptAntiAliasingSettings(out AntiAliasingSetting Setting) {}
static function SetScriptAntiAliasingSettings(out AntiAliasingSetting Setting) {}


//
// Ambient Occlusion
//
static function int FindAmbientOcclusionSettingIndex(out AmbientOcclusionSetting Ref, array<AmbientOcclusionSetting> SettingsList)
{
	local int i;
	for( i=0; i<SettingsList.length; i++ )
	{
		if( Ref == SettingsList[i] )
		{
			return i;
		}
	}

	return INDEX_NONE;
}

static function GetScriptAmbientOcclusionSettings(out AmbientOcclusionSetting Setting) {}
static function SetScriptAmbientOcclusionSettings(out AmbientOcclusionSetting Setting) {}


//
// Depth Of Field
//
static function int FindDOFSettingIndex(out DOFSetting Ref, array<DOFSetting> SettingsList)
{
	local int i;
	for( i=0; i<SettingsList.length; i++ )
	{
		if( Ref == SettingsList[i] )
		{
			return i;
		}
	}

	return INDEX_NONE;
}

static function GetScriptDOFSettings(out DOFSetting Setting) {}
static function SetScriptDOFSettings(out DOFSetting Setting) {}

//
// Flex
//
static function int FindFlexSettingIndex(out FlexSetting Ref, array<FlexSetting> SettingsList)
{
	local int i;
	for( i=0; i<SettingsList.length; i++ )
	{
		if( Ref == SettingsList[i] )
		{
			return i;
		}
	}

	return INDEX_NONE;
}

static function GetScriptFlexSettings(out FlexSetting Setting) {}
static function SetScriptFlexSettings(out FlexSetting Setting) {}


/** Init function */
function InitializeMenu( KFGFxMoviePlayer_Manager InManager )
{
	super.InitializeMenu(InManager);
	GetCurrentGFXSettings(CurrentGFXSettings);
  	LocalizeText();
  	InitializeResolution();
  	InitValues();
	SetFleXOptionEnabled(IsFleXSupported());
}

function SetFleXOptionEnabled(bool bEnable)
{
	local GFxObject FlexDropDown;
	FlexDropDown = GetObject("physicsLevelDropDown");

	FlexDropDown.SetBool("enabled", bEnable);
}

/**
	Functions used to populate the options for each setting.
	Can be overridden in subclass
 */

function SetAspectRatioOptions(out GFxObject LocalizedObject)
{
	local int i;
	local array<string> SupportedAspectRatioOptions;

	// Start clean
	i = 0;
	AvailableAspectRatioList.Remove(0, AvailableAspectRatioList.length);

	// All.
	// No filter option. Unsupress all resolutions.
	SupportedAspectRatioOptions[i++] = AspectRatioString_All;
	AvailableAspectRatioList.AddItem(KFASPECTRATIO_All);

	// 4:3
	if( IsAspectRatioAvailable(KFASPECTRATIO_Standard_4_3) )
	{
		SupportedAspectRatioOptions[i++] = StandardAspectRatioString_4_3;
		AvailableAspectRatioList.AddItem(KFASPECTRATIO_Standard_4_3);
	}

	// 5:4
	if( IsAspectRatioAvailable(KFASPECTRATIO_Standard_5_4) )
	{
		SupportedAspectRatioOptions[i++] = StandardAspectRatioString_5_4;
		AvailableAspectRatioList.AddItem(KFASPECTRATIO_Standard_5_4);
	}

	// 3:2
	if( IsAspectRatioAvailable(KFASPECTRATIO_Standard_3_2) )
	{
		SupportedAspectRatioOptions[i++] = StandardAspectRatioString_3_2;
		AvailableAspectRatioList.AddItem(KFASPECTRATIO_Standard_3_2);
	}

	// 16:9
	if( IsAspectRatioAvailable(KFASPECTRATIO_Wide_16_9) )
	{
		SupportedAspectRatioOptions[i++] = WideAspectRatioString_16_9;
		AvailableAspectRatioList.AddItem(KFASPECTRATIO_Wide_16_9);
	}

	// 16:10
	if( IsAspectRatioAvailable(KFASPECTRATIO_Wide_16_10) )
	{
		SupportedAspectRatioOptions[i++] = WideAspectRatioString_16_10;
		AvailableAspectRatioList.AddItem(KFASPECTRATIO_Wide_16_10);
	}

	// 2:1
	if( IsAspectRatioAvailable(KFASPECTRATIO_ExtraWide_2_1) )
	{
		SupportedAspectRatioOptions[i++] = ExtraWideAspectRatioString_2_1;
		AvailableAspectRatioList.AddItem(KFASPECTRATIO_ExtraWide_2_1);
	}

	// 21:9
	if( IsAspectRatioAvailable(KFASPECTRATIO_ExtraWide_21_9) )
	{
		SupportedAspectRatioOptions[i++] = ExtraWideAspectRatioString_21_9;
		AvailableAspectRatioList.AddItem(KFASPECTRATIO_ExtraWide_21_9);
	}

	// Multi-monitor
	if( IsAspectRatioAvailable(KFASPECTRATIO_MultiMonitor) )
	{
		SupportedAspectRatioOptions[i++] = MultiMonitorAspectRatioString;
		AvailableAspectRatioList.AddItem(KFASPECTRATIO_MultiMonitor);
	}

	LocalizedObject.SetObject("aspectRatioOptions",	MakeDataProvider(SupportedAspectRatioOptions));
}

function SetFullScreenOptions(out GFxObject LocalizedObject)
{
	LocalizedObject.SetObject("fullscreenOptions", MakeDataProvider(FullScreenStringOptions));
}
function SetGraphicsQualityOptions(out GFxObject LocalizedObject)
{
	LocalizedObject.SetObject("graphicsOptions", MakeDataProvider(GraphicsQualityStringOptions));
}

function SetVSyncOptions(out GFxObject LocalizedObject)
{
	LocalizedObject.SetObject("vSyncOptions", MakeDataProvider(VSyncStringOptions));
}

function SetEnvironmentDetailOptions(out GFxObject LocalizedObject)
{
	LocalizedObject.SetObject("environmentDetailOptions", MakeDataProvider(EnvironmentDetailsStringOptions));
}

function SetCharacterDetailOptions(out GFxObject LocalizedObject)
{
	LocalizedObject.SetObject("characterDetailOptions", MakeDataProvider(CharacterDetailStringOptions));
}

function SetFXOptions(out GFxObject LocalizedObject)
{
	LocalizedObject.SetObject("fxOptions", MakeDataProvider(FXStringOptions));
}

function SetTextureResolutionOptions(out GFxObject LocalizedObject)
{
	LocalizedObject.SetObject("textureResolutionOptions", MakeDataProvider(TextureResolutionStringOptions));
}

function SetTextureFilteringOptions(out GFxObject LocalizedObject)
{
	LocalizedObject.SetObject("textureFilteringOptions", MakeDataProvider(TextureFilteringStringOptions));
}

function SetShadowOptions(out GFxObject LocalizedObject)
{
	LocalizedObject.SetObject("shadowsOptions", MakeDataProvider(ShadowsStringOptions));
}

function SetRealtimeReflectionsOptions(out GFxObject LocalizedObject)
{
	LocalizedObject.SetObject("realtimeReflectionsOptions", MakeDataProvider(RealtimeReflectionsStringOptions));
}

function SetAntiAliasingOptions(out GFxObject LocalizedObject)
{
	LocalizedObject.SetObject("antiAliasingOptions", MakeDataProvider(AntiAliasingStringOptions));
}

function SetBloomOptions(out GFxObject LocalizedObject)
{
	LocalizedObject.SetObject("bloomOptions", MakeDataProvider(BloomStringOptions));
}

function SetMotionBlurOptions(out GFxObject LocalizedObject)
{
	LocalizedObject.SetObject("motionBlurOptions", MakeDataProvider(MotionBlurStringOptions));
}

function SetAmbientOcclusionOptions(out GFxObject LocalizedObject)
{
	LocalizedObject.SetObject("ambientOcclusionOptions", MakeDataProvider(AmbientOcclusionStringOptions));
}

function SetDepthOfFieldOptions(out GFxObject LocalizedObject)
{
	LocalizedObject.SetObject("depthOfFieldOptions", MakeDataProvider(DepthOfFieldStringOptions));
}

function SetVolumetricLightingOptions(out GFxObject LocalizedObject)
{
	LocalizedObject.SetObject("volumetricLightingOptions", MakeDataProvider(OffOnStringOptions));
}

function SetLensFlareOptions(out GFxObject LocalizedObject)
{
	LocalizedObject.SetObject("lensFlaresOptions", MakeDataProvider(OffOnStringOptions));
}

function SetLightShaftOptions(out GFxObject LocalizedObject)
{
	LocalizedObject.SetObject("lightShaftsOptions", MakeDataProvider(OffOnStringOptions));
}

function SetPhysicsLevelOptions(out GFxObject LocalizedObject)
{
	LocalizedObject.SetObject("physicsLevelOptions", MakeDataProvider(PhysicsLevelOptionStrings));
}

// *****************************************************************************************

function LocalizeText()
{
    local GFxObject LocalizedObject;

    LocalizedObject = CreateObject( "Object" );

	LocalizedObject.SetString("graphics", Caps(class'KFGFxOptionsMenu_Selection'.default.OptionStrings[OM_Video]));
	LocalizedObject.SetString("basic", Caps(BasicString));
	LocalizedObject.SetString("advanced", Caps(AdvancedString));
	LocalizedObject.SetString("effects", EffectsString);

	LocalizedObject.SetString("physicsLevel", PhysicsLevelString);

	LocalizedObject.SetString("aspectRatio", AspectRatioString);
	LocalizedObject.SetString("resolution", ResolutionString);
	LocalizedObject.SetString("graphicsQuality", GraphicsQualityString);
	LocalizedObject.SetString("vSync", VSyncString);
	LocalizedObject.SetString("fullscreen", FullscreenString);
	LocalizedObject.SetString("variableFrameRate", VariableFrameRateString);
	LocalizedObject.SetString("adjustGamma", AdjustGammaString);
	LocalizedObject.SetString("filmGrain", FilmGrainString);

	LocalizedObject.SetString("environmentDetails", EnvironmentDetailsString);
	LocalizedObject.SetString("characterDetail", CharacterDetailString);
	LocalizedObject.SetString("fx", FXString);
	LocalizedObject.SetString("textureResolution", TextureResolutionString);
	LocalizedObject.SetString("textureFiltering", TextureFilteringString);
	LocalizedObject.SetString("shadows", ShadowsString);
	LocalizedObject.SetString("realtimeReflections", RealtimeReflectionsString);
	LocalizedObject.SetString("antiAliasing", AntiAliasingString);
	LocalizedObject.SetString("bloom", BloomString);
	LocalizedObject.SetString("motionBlur", MotionBlurString);
	LocalizedObject.SetString("ambientOcclusion", AmbientOcclusionString);
	LocalizedObject.SetString("depthOfField", DepthOfFieldString);
	LocalizedObject.SetString("volumetricLighting", VolumetricLightingString);
	LocalizedObject.SetString("lensFlares", LensFlaresString);
	LocalizedObject.SetString("lightShafts", LightShaftsString);

	LocalizedObject.SetString("customString", CustomString);
	LocalizedObject.SetString("iniOverrideString", IniOverrideString);


	LocalizedObject.SetString("apply", ApplyString);
	LocalizedObject.SetString("close", Class'KFCommon_LocalizedStrings'.default.BackString);
	LocalizedObject.SetString("default", DefaultString);
	LocalizedObject.SetObject("physicsSuggestionsArray", MakeDataProvider(PhysicsLevelSuggestionStrings) );

	// Populate the options.
    SetAspectRatioOptions(LocalizedObject);
    SetFullScreenOptions(LocalizedObject);
	SetGraphicsQualityOptions(LocalizedObject);
	SetVSyncOptions(LocalizedObject);
	SetEnvironmentDetailOptions(LocalizedObject);
	SetCharacterDetailOptions(LocalizedObject);
	SetFXOptions(LocalizedObject);
	SetTextureResolutionOptions(LocalizedObject);
	SetTextureFilteringOptions(LocalizedObject);
	SetShadowOptions(LocalizedObject);
	SetRealTimeReflectionsOptions(LocalizedObject);
	SetAntiAliasingOptions(LocalizedObject);
	SetBloomOptions(LocalizedObject);
	SetMotionBlurOptions(LocalizedObject);
	SetAmbientOcclusionOptions(LocalizedObject);
	SetDepthOfFieldOptions(LocalizedObject);
	SetVolumetricLightingOptions(LocalizedObject);
	SetLensFlareOptions(LocalizedObject);
	SetLightShaftOptions(LocalizedObject);
	SetPhysicsLevelOptions(LocalizedObject);


    SetObject("localizedText", LocalizedObject);

}

//Returns an array for a dataProvider to be read in via GFX
function GFxObject MakeDataProvider(const out array<string> SourceText)
{
	local GFxObject DataProvider;
	local byte i;

	DataProvider = CreateArray();

	for (i = 0; i < SourceText.Length; i++)
	{
		DataProvider.SetElementString(i, SourceText[i]);
	}

	return DataProvider;
}

// Maps from compat level to graphics quality setting
static function int GetGraphicsQualityFromCompat(int CompatLevel)
{
	switch( CompatLevel)
	{
		case 0:
			// Unsupported.
			// Setting to low settings for now. We may want to catch that earlier
			// and let the user know that he won't be able to run the game
			return 0;
		case 1:
			// Low
			return 0;
		case 2:
			// Medium
			return 1;
		case 3:
		case 4:
		case 5:
			// 3,4,5 all map to high. Ultra is never assigned by default
			return 2;
		case 6:
			// Ultra setting (forced only)
			return 3;
		case 7: 
			// High + Low Flex (forced only)
			return 4;
		case 8:
			// High + High Flex (forced only)
			return 5;
		case 9:
			// Ultra + High Flex (forced only)
			return 6;
		default:
			`log("[AppCompat]" @ CompatLevel @ " is not a valid compat level. Defaulting to medium settings" );
			return 1;
	}
}

// Called during engine initialization to set graphics options
static event SetCompatibilityLevel(int CompatLevel)
{
	local GraphicsQualitySetting GraphicsQuality;
	local int GraphicsQualityIndex;

	GraphicsQualityIndex = GetGraphicsQualityFromCompat(CompatLevel);

	if( GraphicsQualityIndex >= 0  && GraphicsQualityIndex < default.GraphicsQualityPresets.length )
	{
		// Get base graphics quality
		GraphicsQuality = default.GraphicsQualityPresets[GraphicsQualityIndex];

		// Apply settings
		SetGraphicsQuality(GraphicsQuality, false);
	}
}

// Apply settings for the passed in graphics quality
static event SetGraphicsQuality(GraphicsQualitySetting GraphicsQuality, bool bPreserveUserOverrides)
{
	local GFXSettings NewGFXSettings;

	//
	// Initialize with current settings (for resolution, etc.)
	//
	GetCurrentGFXSettings(NewGFXSettings);

	//
	// Populate the advanced settings
	// NOTE: If bPreserveUserOverrides is specified, check whether current setting belongs to a preset or not before assigning one of the presets.
	// This done to preserve settings that a user has tweaked manually in the INI. The check will fail in 
	// that case, and GSA (or AppCompat) will leave that setting alone (preserging the user override)
	//
	if( !bPreserveUserOverrides || FindEnvironmentDetailIndex(NewGFXSettings.EnvironmentDetail, default.EnvironmentDetailPresets) != INDEX_NONE )
	{
		NewGFXSettings.EnvironmentDetail = default.EnvironmentDetailPresets[GraphicsQuality.EnvironmentDetailIndex];
	}

	if( !bPreserveUserOverrides || FindCharacterDetailIndex(NewGFXSettings.CharacterDetail, default.CharacterDetailPresets) != INDEX_NONE )
	{
		NewGFXSettings.CharacterDetail = default.CharacterDetailPresets[GraphicsQuality.CharacterDetailIndex];
	}

	if( !bPreserveUserOverrides || FindFXQualityIndex(NewGFXSettings.FX, default.FXQualityPresets) != INDEX_NONE )
	{
		NewGFXSettings.FX = default.FXQualityPresets[GraphicsQuality.FXQualityIndex];
	}

	if( !bPreserveUserOverrides || FindTextureResolutionSettingIndex(NewGFXSettings.TextureResolution, default.TextureResolutionPresets) != INDEX_NONE )
	{
		NewGFXSettings.TextureResolution = default.TextureResolutionPresets[GraphicsQuality.TextureResolutionIndex];
	}

	if( !bPreserveUserOverrides || FindTextureFilterSettingIndex(NewGFXSettings.TextureFiltering,  default.TextureFilterPresets) != INDEX_NONE )
	{
		NewGFXSettings.TextureFiltering = default.TextureFilterPresets[GraphicsQuality.TextureFilteringIndex];
	}

	if( !bPreserveUserOverrides || FindShadowQualityIndex(NewGFXSettings.Shadows, default.ShadowQualityPresets) != INDEX_NONE )
	{
		NewGFXSettings.Shadows = default.ShadowQualityPresets[GraphicsQuality.ShadowQualityIndex];
	}

	if( !bPreserveUserOverrides || FindReflectionsSettingIndex(NewGFXSettings.RealtimeReflections,  default.RealtimeReflectionsPresets) != INDEX_NONE )
	{
		NewGFXSettings.RealtimeReflections = default.RealtimeReflectionsPresets[GraphicsQuality.RealtimeReflectionsIndex];
	}

	if( !bPreserveUserOverrides || FindLightShaftsSettingIndex(NewGFXSettings.LightShafts, default.LightShaftsPresets) != INDEX_NONE )
	{
		NewGFXSettings.LightShafts = default.LightShaftsPresets[GraphicsQuality.LightShafts ? 1 : 0];
	}

	if( !bPreserveUserOverrides || FindVolumetricLightingSettingIndex(NewGFXSettings.VolumetricLighting,  default.VolumetricLightingPresets) != INDEX_NONE )
	{
		NewGFXSettings.VolumetricLighting = default.VolumetricLightingPresets[GraphicsQuality.VolumetricLighting ? 1 : 0];
	}

	if( !bPreserveUserOverrides || FindLensFlareSettingIndex(NewGFXSettings.LensFlares,  default.LensFlarePresets) != INDEX_NONE )
	{
		NewGFXSettings.LensFlares = default.LensFlarePresets[GraphicsQuality.LensFlares ? 1 : 0];
	}

	if( !bPreserveUserOverrides || FindAntiAliasingSettingIndex(NewGFXSettings.AntiAliasing,  default.AntiAliasingPresets) != INDEX_NONE )
	{
		NewGFXSettings.AntiAliasing = default.AntiAliasingPresets[GraphicsQuality.AntiAliasingIndex];
	}

	if( !bPreserveUserOverrides || FindBloomSettingIndex(NewGFXSettings.Bloom,  default.BloomPresets) != INDEX_NONE )
	{
		NewGFXSettings.Bloom = default.BloomPresets[GraphicsQuality.BloomIndex];
	}

	if( !bPreserveUserOverrides || FindMotionBlurSettingIndex(NewGFXSettings.MotionBlur,  default.MotionBlurPresets) != INDEX_NONE )
	{
		NewGFXSettings.MotionBlur = default.MotionBlurPresets[GraphicsQuality.MotionBlurIndex];
	}

	if( !bPreserveUserOverrides || FindAmbientOcclusionSettingIndex(NewGFXSettings.AmbientOcclusion,  default.AmbientOcclusionPresets) != INDEX_NONE )
	{
		NewGFXSettings.AmbientOcclusion = default.AmbientOcclusionPresets[GraphicsQuality.AmbientOcclusionIndex];
	}

	if( !bPreserveUserOverrides || FindDOFSettingIndex(NewGFXSettings.DepthOfField,  default.DOFPresets) != INDEX_NONE )
	{
		NewGFXSettings.DepthOfField = default.DOFPresets[GraphicsQuality.DOFIndex];
	}

	if( !bPreserveUserOverrides || FindFlexSettingIndex(NewGFXSettings.Flex,  default.FlexPresets) != INDEX_NONE )
	{
		NewGFXSettings.Flex = default.FlexPresets[GraphicsQuality.FlexIndex];
	}

	// Apply the new settings
	// Ideally, we should be calling SetGFXSettings() instead of the following
	// but SetGFXSettings() is not a static function. So we have to do this work around.
	SetNativeSettings(NewGFXSettings);
	SetScriptSettings(NewGFXSettings);

	// Keep GSA in sync
	UpdateGSA(NewGFXSettings);
}

function InitValues()
{
	local GFxObject ValuesObject;

	local int GraphicsQualityIndex;
	local int DisplayIndex;
	local int VSyncSettingIndex;
	local int VariableFramerateSettingIndex;
	local int EnvironmentDetailIndex;
	local int ShadowQualityIndex;
	local int FXQualityIndex;
	local int ReflectionsSettingIndex;
	local int CharacterDetailIndex;
	local int LightShaftsSettingIndex;
	local int VolumetricLightingSettingIndex;
	local int LensFlareSettingIndex;
	local int TextureResolutionSettingIndex;
	local int TextureFilterSettingIndex;
	local int BloomSettingIndex;
	local int MotionBlurSettingIndex;
	local int AntiAliasingSettingIndex;
	local int AmbientOcclusionSettingIndex;
	local int DOFSettingIndex;
	local float FilmGrainSliderValue;
	local int FlexSettingIndex;

	ValuesObject = GetObject("options");

	// TODO:SAVE - need to find PC Values to be included here

	//
	// Basic Graphics Quality Setting
	// Passing -1 defaults to "Custom"
	//
	GraphicsQualityIndex = FindGraphicsQualitySettingIndex(CurrentGFXSettings, GraphicsQualityPresets);
	ValuesObject.SetInt("graphics", GraphicsQualityIndex);

	//
	// Vsync
	//
	VSyncSettingIndex = FindVSyncSettingIndex(CurrentGFXSettings.VSync, VSyncPresets);
	if(VSyncSettingIndex >= 0 && VSyncSettingIndex < VSyncPresets.length)
	{
		ValuesObject.SetInt("vSync", VSyncSettingIndex);
	}

	//
	// Display
	//
	DisplayIndex = FindDisplaySettingIndex(CurrentGFXSettings.Display, DisplayPresets);
	if(DisplayIndex >= 0 && DisplayIndex < DisplayPresets.length)
	{
		ValuesObject.SetInt("fullScreen", DisplayIndex);
	}

	//
	// Variable frame rate
	//
	VariableFramerateSettingIndex = FindVariableFPSSettingIndex(CurrentGFXSettings.VariableFPS, VariableFrameratePresets);
	if(VariableFramerateSettingIndex >= 0 && VariableFramerateSettingIndex < VariableFrameratePresets.length)
	{
		ValuesObject.SetBool("variableFrameRate", VariableFramerateSettingIndex > 0);
	}

	//
	// Film grain
	//
	FilmGrainSliderValue = GetFilmGrainSliderValue(CurrentGFXSettings.FilmGrain, FilmGrainMinMaxPreset);
	ValuesObject.SetFloat("filmGrain", FilmGrainSliderValue);

	//
	// Advanced Settings
	// Passing -1 defaults to "Custom"
	//
	EnvironmentDetailIndex = FindEnvironmentDetailIndex(CurrentGFXSettings.EnvironmentDetail, EnvironmentDetailPresets);
	ValuesObject.SetInt("environmentDetail", EnvironmentDetailIndex);

	CharacterDetailIndex = FindCharacterDetailIndex(CurrentGFXSettings.CharacterDetail, CharacterDetailPresets);
	ValuesObject.SetInt("characterDetail", CharacterDetailIndex);

	FXQualityIndex = FindFXQualityIndex(CurrentGFXSettings.FX, FXQualityPresets);
	ValuesObject.SetInt("fx", FXQualityIndex);

	TextureResolutionSettingIndex = FindTextureResolutionSettingIndex(CurrentGFXSettings.TextureResolution, TextureResolutionPresets);
	ValuesObject.SetInt("textureResolution", TextureResolutionSettingIndex);

	TextureFilterSettingIndex = FindTextureFilterSettingIndex(CurrentGFXSettings.TextureFiltering, TextureFilterPresets);
	ValuesObject.SetInt("textureFiltering", TextureFilterSettingIndex);

	ShadowQualityIndex = FindShadowQualityIndex(CurrentGFXSettings.Shadows, ShadowQualityPresets);
	ValuesObject.SetInt("shadows", ShadowQualityIndex);

	ReflectionsSettingIndex = FindReflectionsSettingIndex(CurrentGFXSettings.RealtimeReflections, RealtimeReflectionsPresets);
	ValuesObject.SetInt("realtimeReflections", ReflectionsSettingIndex);

	AntiAliasingSettingIndex = FindAntiAliasingSettingIndex(CurrentGFXSettings.AntiAliasing, AntiAliasingPresets);
	ValuesObject.SetInt("antiAliasing", AntiAliasingSettingIndex);

	BloomSettingIndex = FindBloomSettingIndex(CurrentGFXSettings.Bloom, BloomPresets);
	ValuesObject.SetInt("bloom", BloomSettingIndex);

	MotionBlurSettingIndex = FindMotionBlurSettingIndex(CurrentGFXSettings.MotionBlur, MotionBlurPresets);
	ValuesObject.SetInt("motionBlur", MotionBlurSettingIndex);

	AmbientOcclusionSettingIndex = FindAmbientOcclusionSettingIndex(CurrentGFXSettings.AmbientOcclusion, AmbientOcclusionPresets);
	ValuesObject.SetInt("ambientOcclusion", AmbientOcclusionSettingIndex);

	DOFSettingIndex = FindDOFSettingIndex(CurrentGFXSettings.DepthOfField, DOFPresets);
	ValuesObject.SetInt("depthOfField", DOFSettingIndex);

	LightShaftsSettingIndex = FindLightShaftsSettingIndex(CurrentGFXSettings.LightShafts, LightShaftsPresets);
	ValuesObject.SetInt("lightShafts", LightShaftsSettingIndex);

	VolumetricLightingSettingIndex = FindVolumetricLightingSettingIndex(CurrentGFXSettings.VolumetricLighting, VolumetricLightingPresets);
	ValuesObject.SetInt("volumetricLighting", VolumetricLightingSettingIndex);

	LensFlareSettingIndex = FindLensFlareSettingIndex(CurrentGFXSettings.LensFlares, LensFlarePresets);
	ValuesObject.SetInt("lensFlares", LensFlareSettingIndex);

	FlexSettingIndex = FindFlexSettingIndex(CurrentGFXSettings.Flex, FlexPresets);
	ValuesObject.SetInt("physicsLevel", FlexSettingIndex);	

	//
	// Update the UI
	//
 	SetObject("options", ValuesObject);
}

/** Function to get current GFX settings. This will grab both native
	and script settings, and is the recommended funtion to use to query
	the current settings.
 */
static function GetCurrentGFXSettings(out GFXSettings CurrentSettings)
{
	GetCurrentNativeSettings(CurrentSettings);
	GetCurrentScriptSettings(CurrentSettings);
}


/** Wrapper function that updates the native side system settings,
	the script side settings, and also updates the book keeping variables
 */
function SetGFXSettings(GFXSettings NewSettings)
{
	// Store a copy of the current settings to support reverts
	RevertedGFXSettings = CurrentGFXSettings;

	// Actual update
	SetNativeSettings(NewSettings);
	SetScriptSettings(NewSettings);

	// Update the current settings
	CurrentGFXSettings = NewSettings;

	// Keep GSA in sync
	UpdateGSA(NewSettings);
}

function GetModifiedGFXSettings(out GFXSettings NewSettings)
{
	local array<string> ResolutionStringArr;
	local GFxObject OptionsObj;
	local int ResolutionIndex;
	local int DisplayIndex;
	local int VSyncSettingIndex;
	local int VariableFramerateSettingIndex;
	local int EnvironmentDetailIndex;
	local int ShadowQualityIndex;
	local int FXQualityIndex;
	local int ReflectionsSettingIndex;
	local int CharacterDetailIndex;
	local int LightShaftsSettingIndex;
	local int VolumetricLightingSettingIndex;
	local int LensFlareSettingIndex;
	local int TextureResolutionSettingIndex;
	local int TextureFilterSettingIndex;
	local int BloomSettingIndex;
	local int MotionBlurSettingIndex;
	local int AntiAliasingSettingIndex;
	local int AmbientOcclusionSettingIndex;
	local int DOFSettingIndex;
	local int FlexSettingIndex;
	local float FilmGrainSliderValue;

	OptionsObj = GetObject("options");

	ResolutionIndex = OptionsObj.GetInt("resolution");
    ResolutionStringArr = SplitString( SupportedResolutionList[ResolutionIndex], "x", true );
	NewSettings.Resolution.ResX  = int(ResolutionStringArr[0]);
	NewSettings.Resolution.ResY = int(ResolutionStringArr[1]);

	VSyncSettingIndex = OptionsObj.GetInt("vSync");
	if( VSyncSettingIndex >= 0  && VSyncSettingIndex < VSyncPresets.length )
	{
		NewSettings.VSync = VSyncPresets[VSyncSettingIndex];
	}

	DisplayIndex = OptionsObj.GetInt("fullScreen");
	if( DisplayIndex >= 0  && DisplayIndex < DisplayPresets.length )
	{
		NewSettings.Display = DisplayPresets[DisplayIndex];
	}

	VariableFramerateSettingIndex = OptionsObj.GetBool("variableFrameRate") ? 1 : 0;
	if( VariableFramerateSettingIndex >= 0  && VariableFramerateSettingIndex < VariableFrameratePresets.length )
	{
		NewSettings.VariableFPS = VariableFrameratePresets[VariableFramerateSettingIndex];
	}

	FilmGrainSliderValue = OptionsObj.GetFloat("filmGrain");
	NewSettings.FilmGrain.FilmGrainScale = GetFilmGrainSettingValue(FilmGrainSliderValue, FilmGrainMinMaxPreset);

	FlexSettingIndex = OptionsObj.GetInt("physicsLevel");
	if( FlexSettingIndex >= 0  && FlexSettingIndex < FlexPresets.length )
	{
		NewSettings.Flex = FlexPresets[FlexSettingIndex];
	}

	EnvironmentDetailIndex = OptionsObj.GetInt("environmentDetail");
	if( EnvironmentDetailIndex >= 0  && EnvironmentDetailIndex < EnvironmentDetailPresets.length )
	{
		NewSettings.EnvironmentDetail = EnvironmentDetailPresets[EnvironmentDetailIndex];
	}

	CharacterDetailIndex = OptionsObj.GetInt("characterDetail");
	if( CharacterDetailIndex >= 0  && CharacterDetailIndex < CharacterDetailPresets.length )
	{
		NewSettings.CharacterDetail = CharacterDetailPresets[CharacterDetailIndex];
	}

	FXQualityIndex = OptionsObj.GetInt("fx");
	if( FXQualityIndex >= 0  && FXQualityIndex < FXQualityPresets.length )
	{
		NewSettings.FX = FXQualityPresets[FXQualityIndex];
	}

	TextureResolutionSettingIndex = OptionsObj.GetInt("textureResolution");
	if( TextureResolutionSettingIndex >= 0  && TextureResolutionSettingIndex < TextureResolutionPresets.length )
	{
		NewSettings.TextureResolution = TextureResolutionPresets[TextureResolutionSettingIndex];
	}

	TextureFilterSettingIndex = OptionsObj.GetInt("textureFiltering");
	if( TextureFilterSettingIndex >= 0  && TextureFilterSettingIndex < TextureFilterPresets.length )
	{
		NewSettings.TextureFiltering = TextureFilterPresets[TextureFilterSettingIndex];
	}

	ShadowQualityIndex = OptionsObj.GetInt("shadows");
	if( ShadowQualityIndex >= 0  && ShadowQualityIndex < ShadowQualityPresets.length )
	{
		NewSettings.Shadows	= ShadowQualityPresets[ShadowQualityIndex];
	}

	ReflectionsSettingIndex = OptionsObj.GetInt("realtimeReflections");
	if( ReflectionsSettingIndex >= 0  && ReflectionsSettingIndex < RealtimeReflectionsPresets.length )
	{
		NewSettings.RealtimeReflections = RealtimeReflectionsPresets[ReflectionsSettingIndex];
	}

	AntiAliasingSettingIndex = OptionsObj.GetInt("antiAliasing");
	if( AntiAliasingSettingIndex >= 0  && AntiAliasingSettingIndex < AntiAliasingPresets.length )
	{
		NewSettings.AntiAliasing = AntiAliasingPresets[AntiAliasingSettingIndex];
	}

	BloomSettingIndex = OptionsObj.GetInt("bloom");
	if( BloomSettingIndex >= 0  && BloomSettingIndex < BloomPresets.length )
	{
		NewSettings.Bloom = BloomPresets[BloomSettingIndex];
	}

	MotionBlurSettingIndex = OptionsObj.GetInt("motionBlur");
	if( MotionBlurSettingIndex >= 0  && MotionBlurSettingIndex < MotionBlurPresets.length )
	{
		NewSettings.MotionBlur = MotionBlurPresets[MotionBlurSettingIndex];
	}

	AmbientOcclusionSettingIndex = OptionsObj.GetInt("ambientOcclusion");
	if( AmbientOcclusionSettingIndex >= 0  && AmbientOcclusionSettingIndex < AmbientOcclusionPresets.length )
	{
		NewSettings.AmbientOcclusion = AmbientOcclusionPresets[AmbientOcclusionSettingIndex];
	}

	DOFSettingIndex = OptionsObj.GetInt("depthOfField");
	if( DOFSettingIndex >= 0  && DOFSettingIndex < DOFPresets.length )
	{
		NewSettings.DepthOfField = DOFPresets[DOFSettingIndex];
	}

	LightShaftsSettingIndex = OptionsObj.GetInt("lightShafts");
	if( LightShaftsSettingIndex >= 0  && LightShaftsSettingIndex < LightShaftsPresets.length )
	{
		NewSettings.LightShafts = LightShaftsPresets[LightShaftsSettingIndex];
	}

	VolumetricLightingSettingIndex = OptionsObj.GetInt("volumetricLighting");
	if( VolumetricLightingSettingIndex >= 0  && VolumetricLightingSettingIndex < VolumetricLightingPresets.length )
	{
		NewSettings.VolumetricLighting = VolumetricLightingPresets[VolumetricLightingSettingIndex];
	}

	LensFlareSettingIndex = OptionsObj.GetInt("lensFlares");
	if( LensFlareSettingIndex >= 0  && LensFlareSettingIndex < LensFlarePresets.length )
	{
		NewSettings.LensFlares = LensFlarePresets[LensFlareSettingIndex];
	}

	AdjustModifiedGFXSettings(NewSettings);
}

function AdjustModifiedGFXSettings(out GFXSettings NewSettings)
{
	local string MonitorResolution;
	local array<string> ResolutionStringArr;
	local array<string> MonitorResolutionStringArr;
	local GFxObject OptionsObj;
	local int ResolutionIndex;
	local int i;
	local bool NewSettingIsBorderless;
	local bool OldSettingIsNotBorderless;

	NewSettingIsBorderless = NewSettings.Display.BorderlessWindow && !NewSettings.Display.Fullscreen;
	OldSettingIsNotBorderless = !(CurrentGFXSettings.Display.BorderlessWindow && !CurrentGFXSettings.Display.Fullscreen);
	
	// Adjust resolution in case we are in changing to borderless mode
	if(NewSettingIsBorderless && OldSettingIsNotBorderless)
	{
		// Get current monitor resolution
		MonitorResolution = GetMonitorResolution();
		if(MonitorResolution != "")
		{
			// Put the biggest resolution just in case
			ResolutionIndex = SupportedResolutionList.length - 1;

			// Search for the correct resolution among all the possible that the game support
			for( i=0 ; i<SupportedResolutionList.length ; i++ )
			{
				ResolutionStringArr = SplitString( SupportedResolutionList[i], "x", true );
				MonitorResolutionStringArr = SplitString( MonitorResolution, "x", true );
				if(ResolutionStringArr[0] == MonitorResolutionStringArr[0] && ResolutionStringArr[1] == MonitorResolutionStringArr[1])
				{
					ResolutionIndex = i;
				}
			}
			
			// Set the new resolution
			ResolutionStringArr = SplitString( SupportedResolutionList[ResolutionIndex], "x", true );
			NewSettings.Resolution.ResX  = int(ResolutionStringArr[0]);
			NewSettings.Resolution.ResY = int(ResolutionStringArr[1]);

			// Update selected resolution display
			OptionsObj = GetObject("options");
			OptionsObj.SetInt("resolution", ResolutionIndex);
			SetObject("options", OptionsObj);
		}
	}
}

function InitializeResolution()
{
	local SupportedAspectRatio AspectRatio;
	local GFxObject OptionsObj;
	local int CurrentAspectRatioIndex;

	// Get current aspect ratio
	AspectRatio = GetAspectRatio(CurrentGFXSettings.Resolution.ResX, CurrentGFXSettings.Resolution.ResY);

	// Update the resolution list for the current aspect ratio
	UpdateResolutionList(AspectRatio);

	// Update selected aspect ratio display
	CurrentAspectRatioIndex = AvailableAspectRatioList.Find(AspectRatio);
	OptionsObj = GetObject("options");
	OptionsObj.SetInt("aspectRatio", CurrentAspectRatioIndex != INDEX_NONE ? CurrentAspectRatioIndex : 0);
	SetObject("options", OptionsObj);
}

/** Check to see if any settings were modified. Calls callback on modification.
	Set bUpdateSystemSettings to TRUE if SystemSettings need to be updated.
	Set bRestartRequired to TRUE if the change requires you to restart the game
 */
function CheckForChangedSettings(out GFXSettings NewSettings, out byte bUpdateSystemSettings, out byte bRequiresRestart, out byte PerformanceWarningLevel, out byte NeedsRevertCountdown)
{

	if( NewSettings.Resolution != CurrentGFXSettings.Resolution )
		OnResolutionSettingChanged(CurrentGFXSettings.Resolution, NewSettings.Resolution, bUpdateSystemSettings, bRequiresRestart, PerformanceWarningLevel, NeedsRevertCountdown);

	if( NewSettings.VSync != CurrentGFXSettings.VSync )
		OnVsyncSettingChanged(CurrentGFXSettings.Vsync, NewSettings.VSync, bUpdateSystemSettings, bRequiresRestart, PerformanceWarningLevel, NeedsRevertCountdown);

	if( NewSettings.Display != CurrentGFXSettings.Display )
		OnDisplaySettingChanged(CurrentGFXSettings.Display, NewSettings.Display, bUpdateSystemSettings, bRequiresRestart, PerformanceWarningLevel, NeedsRevertCountdown);

	if( NewSettings.VariableFPS != CurrentGFXSettings.VariableFPS )
		OnVariableFramerateSettingChanged(CurrentGFXSettings.VariableFPS, NewSettings.VariableFPS, bUpdateSystemSettings, bRequiresRestart, PerformanceWarningLevel, NeedsRevertCountdown);

	if( NewSettings.FilmGrain != CurrentGFXSettings.FilmGrain )
		OnFilmGrainSettingChanged(CurrentGFXSettings.FilmGrain, NewSettings.FilmGrain, bUpdateSystemSettings, bRequiresRestart, PerformanceWarningLevel, NeedsRevertCountdown);

	if( NewSettings.Flex != CurrentGFXSettings.Flex )
		OnFlexSettingChanged(CurrentGFXSettings.Flex, NewSettings.Flex, bUpdateSystemSettings, bRequiresRestart, PerformanceWarningLevel, NeedsRevertCountdown);		

	if( NewSettings.EnvironmentDetail != CurrentGFXSettings.EnvironmentDetail )
		OnEnvironmentDetailSettingChanged(CurrentGFXSettings.EnvironmentDetail, NewSettings.EnvironmentDetail, bUpdateSystemSettings, bRequiresRestart, PerformanceWarningLevel, NeedsRevertCountdown);

	if( NewSettings.CharacterDetail != CurrentGFXSettings.CharacterDetail )
		OnCharacterDetailSettingChanged(CurrentGFXSettings.CharacterDetail, NewSettings.CharacterDetail, bUpdateSystemSettings, bRequiresRestart, NeedsRevertCountdown);

	if( NewSettings.FX != CurrentGFXSettings.FX )
		OnFXQualitySettingChanged(CurrentGFXSettings.FX, NewSettings.FX, bUpdateSystemSettings, bRequiresRestart, PerformanceWarningLevel, NeedsRevertCountdown);

	if( NewSettings.TextureResolution != CurrentGFXSettings.TextureResolution )
		OnTextureResolutionSettingChanged(CurrentGFXSettings.TextureResolution, NewSettings.TextureResolution, bUpdateSystemSettings, bRequiresRestart, PerformanceWarningLevel, NeedsRevertCountdown);

	if( NewSettings.TextureFiltering != CurrentGFXSettings.TextureFiltering )
		OnTextureFilteringSettingChanged(CurrentGFXSettings.TextureFiltering, NewSettings.TextureFiltering, bUpdateSystemSettings, bRequiresRestart, PerformanceWarningLevel, NeedsRevertCountdown);

	if( NewSettings.Shadows != CurrentGFXSettings.Shadows )
		OnShadowQualitySettingChanged(CurrentGFXSettings.Shadows, NewSettings.Shadows, bUpdateSystemSettings, bRequiresRestart, PerformanceWarningLevel, NeedsRevertCountdown);

	if( NewSettings.RealtimeReflections != CurrentGFXSettings.RealtimeReflections )
		OnReflectionSettingChanged(CurrentGFXSettings.RealtimeReflections, NewSettings.RealtimeReflections, bUpdateSystemSettings, bRequiresRestart, PerformanceWarningLevel, NeedsRevertCountdown);

	if( NewSettings.AntiAliasing != CurrentGFXSettings.AntiAliasing )
		OnAntiAliasingSettingChanged(CurrentGFXSettings.AntiAliasing, NewSettings.AntiAliasing, bUpdateSystemSettings, bRequiresRestart, PerformanceWarningLevel, NeedsRevertCountdown);

	if( NewSettings.Bloom  != CurrentGFXSettings.Bloom )
		OnBloomSettingChanged(CurrentGFXSettings.Bloom, NewSettings.Bloom, bUpdateSystemSettings, bRequiresRestart, PerformanceWarningLevel, NeedsRevertCountdown);

	if( NewSettings.MotionBlur != CurrentGFXSettings.MotionBlur )
		OnMotionBlurSettingChanged(CurrentGFXSettings.MotionBlur, NewSettings.MotionBlur, bUpdateSystemSettings, bRequiresRestart, PerformanceWarningLevel, NeedsRevertCountdown);

	if( NewSettings.AmbientOcclusion != CurrentGFXSettings.AmbientOcclusion )
		OnAmbientOcclusionSettingChanged(CurrentGFXSettings.AmbientOcclusion, NewSettings.AmbientOcclusion, bUpdateSystemSettings, bRequiresRestart, PerformanceWarningLevel, NeedsRevertCountdown);

	if( NewSettings.DepthOfField != CurrentGFXSettings.DepthOfField )
		OnDOFSettingChanged(CurrentGFXSettings.DepthOfField, NewSettings.DepthOfField, bUpdateSystemSettings, bRequiresRestart, PerformanceWarningLevel, NeedsRevertCountdown);

	if( NewSettings.VolumetricLighting != CurrentGFXSettings.VolumetricLighting )
		OnVolumetricLightingSettingChanged(CurrentGFXSettings.VolumetricLighting, NewSettings.VolumetricLighting, bUpdateSystemSettings, bRequiresRestart, PerformanceWarningLevel, NeedsRevertCountdown);

	if( NewSettings.LensFlares != CurrentGFXSettings.LensFlares )
		OnLensFlareSettingChanged(CurrentGFXSettings.LensFlares, NewSettings.LensFlares, bUpdateSystemSettings, bRequiresRestart, PerformanceWarningLevel, NeedsRevertCountdown);

	if( NewSettings.LightShafts != CurrentGFXSettings.LightShafts )
		OnLightShaftsSettingChanged(CurrentGFXSettings.LightShafts, NewSettings.LightShafts, bUpdateSystemSettings, bRequiresRestart, PerformanceWarningLevel, NeedsRevertCountdown);
}

// Update advanced settings UI if the user changed the basic graphics quality setting
function UpdateAdvancedSettingsUI(int GraphicsQualityIndex)
{
	local GraphicsQualitySetting GraphicsQuality;
	local GFxObject OptionsObj;

	OptionsObj = GetObject("options");

	if( GraphicsQualityIndex >= 0  && GraphicsQualityIndex < GraphicsQualityPresets.length )
	{
		GraphicsQuality = GraphicsQualityPresets[GraphicsQualityIndex];

		OptionsObj.SetInt("environmentDetail", GraphicsQuality.EnvironmentDetailIndex);
		OptionsObj.SetInt("characterDetail", GraphicsQuality.CharacterDetailIndex);
		OptionsObj.SetInt("fx", GraphicsQuality.FXQualityIndex);
		OptionsObj.SetInt("textureResolution", GraphicsQuality.TextureResolutionIndex);
		OptionsObj.SetInt("textureFiltering", GraphicsQuality.TextureFilteringIndex);
		OptionsObj.SetInt("shadows", GraphicsQuality.ShadowQualityIndex);
		OptionsObj.SetInt("realtimeReflections", GraphicsQuality.RealtimeReflectionsIndex);
		OptionsObj.SetBool("lightShafts", GraphicsQuality.LightShafts);
		OptionsObj.SetBool("volumetricLighting", GraphicsQuality.VolumetricLighting);
		OptionsObj.SetBool("lensFlares", GraphicsQuality.LensFlares);
		OptionsObj.SetInt("antiAliasing", GraphicsQuality.AntiAliasingIndex);
		OptionsObj.SetInt("bloom", GraphicsQuality.BloomIndex);
		OptionsObj.SetInt("motionBlur", GraphicsQuality.MotionBlurIndex);
		OptionsObj.SetInt("ambientOcclusion", GraphicsQuality.AmbientOcclusionIndex);
		OptionsObj.SetInt("depthOfField", GraphicsQuality.DOFIndex);
		OptionsObj.SetInt("physicsLevel", GraphicsQuality.FlexIndex);

		SetObject("options", OptionsObj);
	}
}

function OneSecondLoop()
{
	local byte TimeLeft;
	local string TempString;

	if(Manager != none && Manager.CurrentPopUp != none && bIsRevertCoundownActive && IsViewportInFocus())
	{
		if(TimeCount < ExpireTime)
		{
			TimeLeft = ExpireTime - TimeCount;
			TempString = Repl(RevertPopupDescriptionString, "%x%", TimeLeft, true);

			Manager.CurrentPopUp.UpdateDescritionText(TempString);
			TimeCount++;
		}
		else
		{
			RevertSettings();
			Manager.UnloadCurrentPopup();
		}
	}
}

/** Called when Apply is clicked in the menu */
function Apply()
{
	local GFXSettings NewGFXSettings;

	// These need to by bytes because UnrealScript doesn't support bools as out parameters
	local byte UpdateSystemSettings;
	local byte NeedsRestart;
	local byte PerformanceWarningLevel;
	local byte NeedsRevertCountdown;

	// Get the current settings
	GetCurrentGFXSettings(CurrentGFXSettings);

	// Get the modified settings (if any)
	// Initialize with current settings so that we don't have invalid values for INI Overrides
	NewGFXSettings = CurrentGFXSettings;
	GetModifiedGFXSettings(NewGFXSettings);

	// Check to see if there where any udpates
	UpdateSystemSettings = 0;
	NeedsRestart = 0;
	NeedsRevertCountdown = 0;
	PerformanceWarningLevel=PerfWarning_None;
	CheckForChangedSettings(NewGFXSettings, UpdateSystemSettings, NeedsRestart, PerformanceWarningLevel, NeedsRevertCountdown);

	//Apply changes and show popup if there where any udpates.
	if( UpdateSystemSettings != 0 )
	{
		// Apply changes
 		SetGFXSettings(NewGFXSettings);

 		// -----------------------------------------------------------------
 		// Popup to revert settings. Show popup only if you need to display 
 		// a) Performance warning, or
		// b) Restart warning, or
		// c) Revert countdown
		// -----------------------------------------------------------------
 		if( PerformanceWarningLevel > PerfWarning_None || NeedsRestart > 0 || NeedsRevertCountdown > 0 )
 		{
 			ShowRevertPopUp(PerformanceWarningLevel, NeedsRestart > 0, NeedsRevertCountdown > 0);
 		}
	}
}

function ResetValues()
{
	InitializeResolution();
	InitValues();
}

function RevertSettings()
{
	//REVERT
	SetGFXSettings(RevertedGFXSettings);
	ResetValues();
	bIsRevertCoundownActive = false;
}

function ShowRevertPopUp(byte PerfWarningLevel, bool bNeedsRestart, bool bNeedsRevertCountdown)
{
	local string TempString;
	local string PromptString;

	bIsRevertCoundownActive = bNeedsRevertCountdown;
	TimeCount = 0;

	if( PerfWarningLevel > PerfWarning_None && bNeedsRestart )
	{
		//Popup text
		PromptString = WarningPromptString;
		RevertPopupDescriptionString = Repl(Repl(DoubleWarningString, "%x%", PerformanceDescString[PerfWarningLevel-1], true), "%y%", RestartDescString, true);
		RevertPopupDescriptionString $= ". " $ ContinueString;

		if( bNeedsRevertCountdown )
		{
			RevertPopupDescriptionString $= "\n\n" $ WillExpireString;
			TempString = Repl(RevertPopupDescriptionString, "%x%", ExpireTime, true);
			Manager.DelayedOpenPopup( EConfirmation, EDPPID_Misc,PromptString, TempString, OKString, CancelString, OnRestartConfirm, OnSettingsRevert);
		}
		else
		{
			Manager.DelayedOpenPopup( EConfirmation,EDPPID_Misc, PromptString, RevertPopupDescriptionString, OKString, CancelString, OnRestartConfirm, OnSettingsRevert);
		}
	}
	else if( PerfWarningLevel > PerfWarning_None )
	{
		//Popup text
		PromptString = WarningPromptString;
		RevertPopupDescriptionString = Repl(SingleWarningString, "%x%", PerformanceDescString[PerfWarningLevel-1], true);
		RevertPopupDescriptionString $= ". " $ ContinueString;

		if( bNeedsRevertCountdown )
		{
			RevertPopupDescriptionString $= "\n\n" $ WillExpireString;
			TempString = Repl(RevertPopupDescriptionString, "%x%", ExpireTime, true);
			Manager.DelayedOpenPopup( EConfirmation, EDPPID_Misc, PromptString, TempString, OKString, CancelString, OnSettingsConfirm, OnSettingsRevert);
		}
		else
		{
			Manager.DelayedOpenPopup( EConfirmation, EDPPID_Misc, PromptString, RevertPopupDescriptionString, OKString, CancelString, OnSettingsConfirm, OnSettingsRevert);
		}
	}
	else if( bNeedsRestart )
	{
		//Popup text
		PromptString = WarningPromptString;
		RevertPopupDescriptionString = Repl(SingleWarningString, "%x%", RestartDescString, true);
		RevertPopupDescriptionString $= ". " $ ContinueString;

		if( bNeedsRevertCountdown )
		{
			RevertPopupDescriptionString $= "\n\n" $ WillExpireString;
			TempString = Repl(RevertPopupDescriptionString, "%x%", ExpireTime, true);
			Manager.DelayedOpenPopup( EConfirmation, EDPPID_Misc, PromptString, TempString, OKString, CancelString, OnRestartConfirm, OnSettingsRevert);
		}
		else
		{
			Manager.DelayedOpenPopup( EConfirmation, EDPPID_Misc, PromptString, RevertPopupDescriptionString, OKString, CancelString, OnRestartConfirm, OnSettingsRevert);	
		}
	}
	else
	{
		//Popup text
		RevertPopupDescriptionString = KeepSettingsPromptString;

		if( bNeedsRevertCountdown )
		{
			RevertPopupDescriptionString $= "\n\n" $ WillExpireString;
			TempString = Repl(RevertPopupDescriptionString, "%x%", ExpireTime, true);
			Manager.DelayedOpenPopup( EConfirmation, EDPPID_Misc, PromptString, TempString, OKString, CancelString, OnSettingsConfirm, OnSettingsRevert);
		}
		else
		{
			Manager.DelayedOpenPopup( EConfirmation, EDPPID_Misc, PromptString, RevertPopupDescriptionString, OKString, CancelString, OnSettingsConfirm, OnSettingsRevert);
		}
	}
}

function OnGraphicsQualitySet(int Index)
{
	// Update advanced settings UI
	UpdateAdvancedSettingsUI(Index);
}

/** Update the resolution list for the selected AspectRatio */
function UpdateResolutionList(SupportedAspectRatio InAspectRatio)
{
	local int i;
	local int CurrentResolutionIndex;
	local GFxObject ResolutionSlot, DataProvider;
	local GFxObject OptionsObj;
	local string CurrentRes;

	// Selected value to display in resolution list drop box.
	// Current resolution if in list, otherwise the first entry in the list
	CurrentResolutionIndex = 0;

	// Resolution string for current resolution
	CurrentRes = CurrentGFXSettings.Resolution.ResX $"x" $CurrentGFXSettings.Resolution.ResY;

	// Update the resolution options based on given aspect ratio and the
	// list of resolutions that are supported by the adapter
	RefreshSupportedResolutions(InAspectRatio);

	// Populate the data provider with above list
	DataProvider = CreateArray();
	for( i = 0; i < SupportedResolutionList.Length; i++ )
	{
		ResolutionSlot = CreateObject( "Object" );
		ResolutionSlot.SetString("label",  SupportedResolutionList[i]);

		if ( CurrentRes == SupportedResolutionList[i] )
		{
   			CurrentResolutionIndex = i;
		}
		DataProvider.SetElementObject(i, ResolutionSlot);
	}

	// Update UI
	SetObject("resolutionOptions", DataProvider);

	// Update selected resolution display
	OptionsObj = GetObject("options");
	OptionsObj.SetInt("resolution", CurrentResolutionIndex);
	SetObject("options", OptionsObj);
}

/** Callback when aspect ratio is changed. Populate the resolution list with
	supported resolutions for selected aspect ratio
 */
function OnAspectRatioSet(int Index)
{
	UpdateResolutionList(AvailableAspectRatioList[Index]);
}

function OnAdvancedOptionChanged()
{
	//`log("SET TO CUSTOM!");
}

//==============================================================
// Per setting callbacks
// NOTE: These can be used to specify settings update or application
// restart. Additionally you can also use logic here to warn about
// performance implications.
//==============================================================
function OnResolutionSettingChanged(ResolutionSetting OldSetting, ResolutionSetting NewSetting, out byte bUpdateSystemSettings, out byte bRequiresRestart, out byte PerformanceWarningLevel, out byte bNeedsRevertCountdown)
{
	bUpdateSystemSettings = bUpdateSystemSettings | 1;
	bNeedsRevertCountdown = bNeedsRevertCountdown | 1;
}

function OnVsyncSettingChanged(VSyncSetting OldSetting, VSyncSetting NewSetting, out byte bUpdateSystemSettings, out byte bRequiresRestart, out byte PerformanceWarningLevel, out byte bNeedsRevertCountdown)
{
	bUpdateSystemSettings = bUpdateSystemSettings | 1;
}

function OnDisplaySettingChanged(DisplaySetting OldSetting, DisplaySetting NewSetting, out byte bUpdateSystemSettings, out byte bRequiresRestart, out byte PerformanceWarningLevel, out byte bNeedsRevertCountdown)
{
	bUpdateSystemSettings = bUpdateSystemSettings | 1;
	bNeedsRevertCountdown = bNeedsRevertCountdown | 1;
}

function OnVariableFramerateSettingChanged(VariableFramerateSetting OldSetting, VariableFramerateSetting NewSetting, out byte bUpdateSystemSettings, out byte bRequiresRestart, out byte PerformanceWarningLevel, out byte bNeedsRevertCountdown)
{
	bUpdateSystemSettings = bUpdateSystemSettings | 1;
}

function OnFilmGrainSettingChanged(FilmGrainSetting OldSetting, FilmGrainSetting NewSetting, out byte bUpdateSystemSettings, out byte bRequiresRestart, out byte PerformanceWarningLevel, out byte bNeedsRevertCountdown)
{
	bUpdateSystemSettings = bUpdateSystemSettings | 1;
}

function OnEnvironmentDetailSettingChanged(EnvironmentDetailSetting OldSetting, EnvironmentDetailSetting NewSetting, out byte bUpdateSystemSettings, out byte bRequiresRestart, out byte PerformanceWarningLevel, out byte bNeedsRevertCountdown)
{
	bUpdateSystemSettings = bUpdateSystemSettings | 1;
	bRequiresRestart = bRequiresRestart | 1;
}

function OnCharacterDetailSettingChanged(CharacterDetailSetting OldSetting, CharacterDetailSetting NewSetting, out byte bUpdateSystemSettings, out byte bRequiresRestart, out byte bNeedsRevertCountdown)
{
	bUpdateSystemSettings = bUpdateSystemSettings | 1;
}

function OnFXQualitySettingChanged(FXQualitySetting OldSetting, FXQualitySetting NewSetting, out byte bUpdateSystemSettings, out byte bRequiresRestart, out byte PerformanceWarningLevel, out byte bNeedsRevertCountdown)
{
	bUpdateSystemSettings = bUpdateSystemSettings | 1;
	bRequiresRestart = bRequiresRestart | 1;
}

function OnTextureResolutionSettingChanged(TextureResolutionSetting OldSetting, TextureResolutionSetting NewSetting, out byte bUpdateSystemSettings, out byte bRequiresRestart, out byte PerformanceWarningLevel, out byte bNeedsRevertCountdown)
{
	bUpdateSystemSettings = bUpdateSystemSettings | 1;
}

function OnTextureFilteringSettingChanged(TextureFilterSetting OldSetting, TextureFilterSetting NewSetting, out byte bUpdateSystemSettings, out byte bRequiresRestart, out byte PerformanceWarningLevel, out byte bNeedsRevertCountdown)
{
	bUpdateSystemSettings = bUpdateSystemSettings | 1;
	bRequiresRestart = bRequiresRestart | 1;
}

function OnShadowQualitySettingChanged(ShadowQualitySetting OldSetting, ShadowQualitySetting NewSetting, out byte bUpdateSystemSettings, out byte bRequiresRestart, out byte PerformanceWarningLevel, out byte bNeedsRevertCountdown)
{
	bUpdateSystemSettings = bUpdateSystemSettings | 1;
	bRequiresRestart = bRequiresRestart | 1;
}

function OnReflectionSettingChanged(RealtimeReflectionsSetting OldSetting, RealtimeReflectionsSetting NewSetting, out byte bUpdateSystemSettings, out byte bRequiresRestart, out byte PerformanceWarningLevel, out byte bNeedsRevertCountdown)
{
	bUpdateSystemSettings = bUpdateSystemSettings | 1;

	// Caution about possible performance drop
	if( !OldSetting.bAllowScreenSpaceReflections &&
		NewSetting.bAllowScreenSpaceReflections )
	{
		PerformanceWarningLevel = Max(PerformanceWarningLevel, PerfWarning_Normal);
	}
}

function OnAntiAliasingSettingChanged(AntiAliasingSetting OldSetting, AntiAliasingSetting NewSetting, out byte bUpdateSystemSettings, out byte bRequiresRestart, out byte PerformanceWarningLevel, out byte bNeedsRevertCountdown)
{
	bUpdateSystemSettings = bUpdateSystemSettings | 1;
}

function OnBloomSettingChanged(BloomSetting OldSetting, BloomSetting NewSetting, out byte bUpdateSystemSettings, out byte bRequiresRestart, out byte PerformanceWarningLevel, out byte bNeedsRevertCountdown)
{
	bUpdateSystemSettings = bUpdateSystemSettings | 1;
}

function OnMotionBlurSettingChanged(MotionBlurSetting OldSetting, MotionBlurSetting NewSetting, out byte bUpdateSystemSettings, out byte bRequiresRestart, out byte PerformanceWarningLevel, out byte bNeedsRevertCountdown)
{
	bUpdateSystemSettings = bUpdateSystemSettings | 1;
}

function OnAmbientOcclusionSettingChanged(AmbientOcclusionSetting OldSetting, AmbientOcclusionSetting NewSetting, out byte bUpdateSystemSettings, out byte bRequiresRestart, out byte PerformanceWarningLevel, out byte bNeedsRevertCountdown)
{
	bUpdateSystemSettings = bUpdateSystemSettings | 1;

	// Caution about possible performance drop
	if( NewSetting.HBAO )
	{
		PerformanceWarningLevel = Max(PerformanceWarningLevel, PerfWarning_Normal);
	}
}

function OnDOFSettingChanged(DOFSetting OldSetting, DOFSetting NewSetting, out byte bUpdateSystemSettings, out byte bRequiresRestart, out byte PerformanceWarningLevel, out byte bNeedsRevertCountdown)
{
	bUpdateSystemSettings = bUpdateSystemSettings | 1;
}


function OnVolumetricLightingSettingChanged(VolumetricLightingSetting OldSetting, VolumetricLightingSetting NewSetting, out byte bUpdateSystemSettings, out byte bRequiresRestart, out byte PerformanceWarningLevel, out byte bNeedsRevertCountdown)
{
	bUpdateSystemSettings = bUpdateSystemSettings | 1;
	bRequiresRestart = bRequiresRestart | 1;
}

function OnLensFlareSettingChanged(LensFlareSetting OldSetting, LensFlareSetting NewSetting, out byte bUpdateSystemSettings, out byte bRequiresRestart, out byte PerformanceWarningLevel, out byte bNeedsRevertCountdown)
{
	bUpdateSystemSettings = bUpdateSystemSettings | 1;
	bRequiresRestart = bRequiresRestart | 1;
}

function OnLightShaftsSettingChanged(LightShaftsSetting OldSetting, LightShaftsSetting NewSetting, out byte bUpdateSystemSettings, out byte bRequiresRestart, out byte PerformanceWarningLevel, out byte bNeedsRevertCountdown)
{
	bUpdateSystemSettings = bUpdateSystemSettings | 1;
}

function OnFlexSettingChanged(FlexSetting OldSetting, FlexSetting NewSetting, out byte bUpdateSystemSettings, out byte bRequiresRestart, out byte PerformanceWarningLevel, out byte bNeedsRevertCountdown)
{
	bUpdateSystemSettings = bUpdateSystemSettings | 1;
	bRequiresRestart = bRequiresRestart | 1;

	// Caution about possible performance drop
	if( NewSetting.FlexLevel > OldSetting.FlexLevel &&
		NewSetting.FlexLevel == 1 )
	{
		PerformanceWarningLevel = Max(PerformanceWarningLevel, PerfWarning_Normal);
	}

	if( NewSetting.FlexLevel > OldSetting.FlexLevel &&
		NewSetting.FlexLevel == 2  )
	{
		PerformanceWarningLevel = Max(PerformanceWarningLevel, PerfWarning_Severe);
	}
}

//==============================================================
// @name Popup delegates
//==============================================================

function OnSettingsConfirm()
{
	bIsRevertCoundownActive = false;
}

function OnRestartConfirm()
{
	bIsRevertCoundownActive = false;
	ConsoleCommand("RESTART");
}

function OnSettingsRevert()
{
	RevertSettings();
}

function OnSaveConfirm()
{
	// Save unsaved changes
	SetGFXSettings(UnsavedGFXSettings);

	// Restart game if required
	if( UnsavedPendingRestart )
	{
		ConsoleCommand("RESTART");
	}

	Manager.OpenMenu( UI_OptionsSelection );
}

function OnSaveCancel()
{
	ResetValues();
	Manager.OpenMenu( UI_OptionsSelection );
}

/*********************************************************************************************
 * @name	ActionScript Callbacks
 ********************************************************************************************* */
function Callback_CloseMenu()
{
	local GFXSettings NewGFXSettings;
	local string PromptString;
	local string DescriptionString;

	// These need to by bytes because UnrealScript doesn't support bools as out parameters
	local byte UpdateSystemSettings;
	local byte NeedsRestart;
	local byte PerformanceWarningLevel;
	local byte NeedsRevertCountdown;

	// Get the current settings
	GetCurrentGFXSettings(CurrentGFXSettings);

	// Get the modified settings (if any)
	// Initialize with current settings so that we don't have invalid values for INI Overrides
	NewGFXSettings = CurrentGFXSettings;
	GetModifiedGFXSettings(NewGFXSettings);

	// Check to see if there where any udpates
	UpdateSystemSettings = 0;
	NeedsRestart = 0;
	NeedsRevertCountdown = 0;
	PerformanceWarningLevel=PerfWarning_None;
	CheckForChangedSettings(NewGFXSettings, UpdateSystemSettings, NeedsRestart, PerformanceWarningLevel, NeedsRevertCountdown);

	//Apply changes and show popup if there where any udpates.
	if( UpdateSystemSettings != 0 )
	{
		// Cache the new but unsaved settings
		UnsavedGFXSettings = NewGFXSettings;
		UnsavedPendingRestart = NeedsRestart > 0;


		if( PerformanceWarningLevel > PerfWarning_None && NeedsRestart > 0 )
		{
			//Popup text
			PromptString = WarningPromptString;
			DescriptionString = UnsavedChangesString $ ". ";
			DescriptionString $= Repl(Repl(DoubleWarningString, "%x%", PerformanceDescString[PerformanceWarningLevel-1], true), "%y%", RestartDescString, true) $ ". ";
			DescriptionString $= "\n\n" $ SaveChangesString;
		}
		else if( PerformanceWarningLevel > PerfWarning_None )
		{
			//Popup text
			PromptString = WarningPromptString;
			DescriptionString = UnsavedChangesString $ ". ";
			DescriptionString $= Repl(SingleWarningString, "%x%", PerformanceDescString[PerformanceWarningLevel-1], true) $ ". ";
			DescriptionString $= "\n\n" $ SaveChangesString;
		}
		else if( NeedsRestart > 0 )
		{
			//Popup text
			PromptString = WarningPromptString;
			DescriptionString = UnsavedChangesString $ ". ";
			DescriptionString $= Repl(SingleWarningString, "%x%", RestartDescString, true) $ ". ";
			DescriptionString $= "\n\n" $ SaveChangesString;
		}
		else
		{
			//Popup text
			PromptString = "";
			DescriptionString = UnsavedChangesString $ ". ";
			DescriptionString $= "\n\n" $ SaveChangesString;
		}

		Manager.DelayedOpenPopup( EConfirmation, EDPPID_Misc, PromptString, DescriptionString, Class'KFCommon_LocalizedStrings'.default.YesString, Class'KFCommon_LocalizedStrings'.default.NoString, OnSaveConfirm, OnSaveCancel);
	}
	else
	{
		ResetValues();
		Manager.OpenMenu( UI_OptionsSelection );
	}
}

function Callback_FleXOptionChange(bool bShowPopUp)
{
	if(bShowPopUp)
	{
		Manager.DelayedOpenPopup(ENotification, EDPPID_Misc, WarningPromptString, FlexPopUpString, class'KFCommon_LocalizedStrings'.default.OKString);
	}	
}

function Callback_ApplyVideo()
{
	Apply();
}

function Callback_CancelVideo()
{
	ResetValues();
	Manager.OpenMenu( UI_OptionsSelection );
}

function Callback_ResetDefaultVideo()
{
	local GFxObject OptionsObj;
	local int GraphicsQualityIndex;
	local float FilmGrainSliderValue;
	local FilmGrainSetting DefultImageGrain;

	// Retrieve the current options
	OptionsObj = GetObject("options");

	// Set graphics preset.
	// @TODO: Query from appcompat system. Defaulting to high for now.
	GraphicsQualityIndex = GetGraphicsQualityFromCompat(GetCompatLevel());
	OptionsObj.SetInt("graphics", GraphicsQualityIndex);

	// Film grain scale = 1.0
	DefultImageGrain.FilmGrainScale = 1.f;
	FilmGrainSliderValue = GetFilmGrainSliderValue(DefultImageGrain, FilmGrainMinMaxPreset);
	OptionsObj.SetFloat("filmGrain", FilmGrainSliderValue);

	// Vsync off
	OptionsObj.SetInt("vSync", 0);

	// Variable framerate off
	OptionsObj.SetBool("variableFrameRate", false);

	// Update options
	SetObject("options", OptionsObj);

	// Update the advanced settings options
    OnGraphicsQualitySet(GraphicsQualityIndex);
}

function Callback_OpenGamma()
{
	Manager.SetVariableBool("bStartUpGamma", false);  // Let the manager know if we are gamma for start up so we can block backing out of the popup - HSL
	Manager.DelayedOpenPopup(EGamma, EDPPID_Gamma, "", AdjustGammaDescription, ResetGammaString, SetGammaString);
}

defaultproperties
{
	ExpireTime=30

	//=================================================================================================
	// Preset values
	//=================================================================================================

	// Graphics Quality (Basic Setting)
	GraphicsQualityPresets(0)={(EnvironmentDetailIndex=0,CharacterDetailIndex=0,FXQualityIndex=0,TextureResolutionIndex=0,TextureFilteringIndex=0,ShadowQualityIndex=0,RealtimeReflectionsIndex=0,LightShafts=False,VolumetricLighting=False,LensFlares=False,AntiAliasingIndex=0,BloomIndex=0,MotionBlurIndex=0,AmbientOcclusionIndex=0,DOFIndex=0,FlexIndex=0)}
	GraphicsQualityPresets(1)={(EnvironmentDetailIndex=1,CharacterDetailIndex=0,FXQualityIndex=1,TextureResolutionIndex=1,TextureFilteringIndex=1,ShadowQualityIndex=1,RealtimeReflectionsIndex=0,LightShafts=False,VolumetricLighting=False,LensFlares=False,AntiAliasingIndex=1,BloomIndex=1,MotionBlurIndex=0,AmbientOcclusionIndex=0,DOFIndex=0,FlexIndex=0)}
	GraphicsQualityPresets(2)={(EnvironmentDetailIndex=2,CharacterDetailIndex=1,FXQualityIndex=2,TextureResolutionIndex=2,TextureFilteringIndex=2,ShadowQualityIndex=2,RealtimeReflectionsIndex=0,LightShafts=True,VolumetricLighting=True,LensFlares=True,AntiAliasingIndex=1,BloomIndex=2,MotionBlurIndex=0,AmbientOcclusionIndex=1,DOFIndex=1,FlexIndex=0)}
	GraphicsQualityPresets(3)={(EnvironmentDetailIndex=3,CharacterDetailIndex=2,FXQualityIndex=3,TextureResolutionIndex=3,TextureFilteringIndex=3,ShadowQualityIndex=3,RealtimeReflectionsIndex=1,LightShafts=True,VolumetricLighting=True,LensFlares=True,AntiAliasingIndex=1,BloomIndex=2,MotionBlurIndex=1,AmbientOcclusionIndex=2,DOFIndex=1,FlexIndex=0)}
	GraphicsQualityPresets(4)={(EnvironmentDetailIndex=2,CharacterDetailIndex=1,FXQualityIndex=2,TextureResolutionIndex=2,TextureFilteringIndex=2,ShadowQualityIndex=2,RealtimeReflectionsIndex=0,LightShafts=True,VolumetricLighting=True,LensFlares=True,AntiAliasingIndex=1,BloomIndex=2,MotionBlurIndex=0,AmbientOcclusionIndex=1,DOFIndex=1,FlexIndex=1)}
	GraphicsQualityPresets(5)={(EnvironmentDetailIndex=2,CharacterDetailIndex=1,FXQualityIndex=2,TextureResolutionIndex=2,TextureFilteringIndex=2,ShadowQualityIndex=2,RealtimeReflectionsIndex=0,LightShafts=True,VolumetricLighting=True,LensFlares=True,AntiAliasingIndex=1,BloomIndex=2,MotionBlurIndex=0,AmbientOcclusionIndex=1,DOFIndex=1,FlexIndex=2)}
	GraphicsQualityPresets(6)={(EnvironmentDetailIndex=3,CharacterDetailIndex=2,FXQualityIndex=3,TextureResolutionIndex=3,TextureFilteringIndex=3,ShadowQualityIndex=3,RealtimeReflectionsIndex=1,LightShafts=True,VolumetricLighting=True,LensFlares=True,AntiAliasingIndex=1,BloomIndex=2,MotionBlurIndex=1,AmbientOcclusionIndex=2,DOFIndex=1,FlexIndex=2)}

	// Display
	DisplayPresets(0)={(Fullscreen=False, BorderlessWindow=False)}
	DisplayPresets(1)={(Fullscreen=False, BorderlessWindow=True)}
	DisplayPresets(2)={(Fullscreen=True, BorderlessWindow=False)}

	//VSync
	VSyncPresets(0)={(VSync=False)}
	VSyncPresets(1)={(VSync=True)}
	//VSyncPresets(2)={(VSync=True)}

	// Variable Framerate
	VariableFrameratePresets(0)={(VariableFramerate=False)}
	VariableFrameratePresets(1)={(VariableFramerate=True)}

	// Film Grain
	FilmGrainMinMaxPreset(`MIN)={(FilmGrainScale=0.5)}
	FilmGrainMinMaxPreset(`MAX)={(FilmGrainScale=37.5)}

	// Environment Detail
	EnvironmentDetailPresets(0)={(DetailMode=0, DestructionLifetimeScale=0.25, bDisableCanBecomeDynamicWakeup=True, MakeDynamicCollisionThreshold=200, AllowLightFunctions=False)}
	EnvironmentDetailPresets(1)={(DetailMode=1, DestructionLifetimeScale=0.5, bDisableCanBecomeDynamicWakeup=False, MakeDynamicCollisionThreshold=200, AllowLightFunctions=False)}
	EnvironmentDetailPresets(2)={(DetailMode=2, DestructionLifetimeScale=1.0, bDisableCanBecomeDynamicWakeup=False, MakeDynamicCollisionThreshold=150, AllowLightFunctions=True)}
	EnvironmentDetailPresets(3)={(DetailMode=2, DestructionLifetimeScale=1.2, bDisableCanBecomeDynamicWakeup=False, MakeDynamicCollisionThreshold=150, AllowLightFunctions=True)}

	// Shadows
	ShadowQualityPresets(0)={(bAllowWholeSceneDominantShadows=FALSE, bOverrideMapWholeSceneDominantShadowSetting=FALSE, bAllowDynamicShadows=TRUE, bAllowPerObjectShadows=FALSE, MaxWholeSceneDominantShadowResolution=1204, MaxShadowResolution=1024, ShadowFadeResolution=256, MinShadowResolution=128, ShadowTexelsPerPixel=0.5, GlobalShadowDistanceScale=0.75, AllowForegroundPreshadows=False)}
	ShadowQualityPresets(1)={(bAllowWholeSceneDominantShadows=TRUE, bOverrideMapWholeSceneDominantShadowSetting=FALSE, bAllowDynamicShadows=TRUE, bAllowPerObjectShadows=TRUE, MaxWholeSceneDominantShadowResolution=1204, MaxShadowResolution=1024, ShadowFadeResolution=128, MinShadowResolution=64, ShadowTexelsPerPixel=1.0, GlobalShadowDistanceScale=0.75, AllowForegroundPreshadows=False)}
	ShadowQualityPresets(2)={(bAllowWholeSceneDominantShadows=TRUE, bOverrideMapWholeSceneDominantShadowSetting=FALSE, bAllowDynamicShadows=TRUE, bAllowPerObjectShadows=TRUE, MaxWholeSceneDominantShadowResolution=1280, MaxShadowResolution=1024, ShadowFadeResolution=128, MinShadowResolution=64, ShadowTexelsPerPixel=1.3, GlobalShadowDistanceScale=1.0, AllowForegroundPreshadows=True)}
	ShadowQualityPresets(3)={(bAllowWholeSceneDominantShadows=TRUE, bOverrideMapWholeSceneDominantShadowSetting=TRUE, bAllowDynamicShadows=TRUE, bAllowPerObjectShadows=TRUE, MaxWholeSceneDominantShadowResolution=2048, MaxShadowResolution=1536, ShadowFadeResolution=64, MinShadowResolution=32, ShadowTexelsPerPixel=2.0, GlobalShadowDistanceScale=1.5, AllowForegroundPreshadows=True)}

	// FX
	FXQualityPresets(0)={(ParticleLODBias=1, DistanceFogQuality=0, Distortion=False, FilteredDistortion=False, DropParticleDistortion=True, EmitterPoolScale=0.25, ShellEjectLifetime=2, AllowExplosionLights=False, AllowSprayActorLights=False, AllowPilotLights=False, AllowFootstepSounds=False, AllowRagdollAndGoreOnDeadBodies=False, MaxImpactEffectDecals=8, MaxExplosionDecals=8, GoreFXLifetimeMultiplier=0.5, MaxBloodEffects=12, MaxGoreEffects=8, AllowSecondaryBloodEffects=False, AllowBloodSplatterDecals=False,MaxPersistentSplatsPerFrame=25)}
	FXQualityPresets(1)={(ParticleLODBias=0, DistanceFogQuality=0, Distortion=False, FilteredDistortion=False, DropParticleDistortion=True, EmitterPoolScale=0.5, ShellEjectLifetime=5, AllowExplosionLights=True, AllowSprayActorLights=False, AllowPilotLights=True, AllowFootstepSounds=True, AllowRagdollAndGoreOnDeadBodies=True, MaxImpactEffectDecals=15, MaxExplosionDecals=12, GoreFXLifetimeMultiplier=0.75, MaxBloodEffects=15, MaxGoreEffects=8, AllowSecondaryBloodEffects=False, AllowBloodSplatterDecals=False, MaxPersistentSplatsPerFrame=50)}
	FXQualityPresets(2)={(ParticleLODBias=0, DistanceFogQuality=1, Distortion=True, FilteredDistortion=True, DropParticleDistortion=False, EmitterPoolScale=1.0,ShellEjectLifetime=10, AllowExplosionLights=True, AllowSprayActorLights=True, AllowPilotLights=True, AllowFootstepSounds=True, AllowRagdollAndGoreOnDeadBodies=True, MaxImpactEffectDecals=20, MaxExplosionDecals=15, GoreFXLifetimeMultiplier=1.0, MaxBloodEffects=25, MaxGoreEffects=10, AllowSecondaryBloodEffects=True, AllowBloodSplatterDecals=True, MaxPersistentSplatsPerFrame=75)}
	FXQualityPresets(3)={(ParticleLODBias=0, DistanceFogQuality=1, Distortion=True, FilteredDistortion=True, DropParticleDistortion=False, EmitterPoolScale=2.0,ShellEjectLifetime=20, AllowExplosionLights=True, AllowSprayActorLights=True, AllowPilotLights=True, AllowFootstepSounds=True, AllowRagdollAndGoreOnDeadBodies=True, MaxImpactEffectDecals=40, MaxExplosionDecals=20, GoreFXLifetimeMultiplier=1.2, MaxBloodEffects=40, MaxGoreEffects=15, AllowSecondaryBloodEffects=True, AllowBloodSplatterDecals=True, MaxPersistentSplatsPerFrame=100)}

	// Realtime Reflections
	RealtimeReflectionsPresets(0)={(bAllowScreenSpaceReflections=False)}
	RealtimeReflectionsPresets(1)={(bAllowScreenSpaceReflections=True)}

	// Character Detail
	CharacterDetailPresets(0)={(SkeletalMeshLODBias=1, AllowSubsurfaceScattering=False, MaxBodyWoundDecals=2, MaxDeadBodies=8, KinematicUpdateDistFactorScale=3.0, ShouldCorpseCollideWithDead=False, ShouldCorpseCollideWithLiving=False, ShouldCorpseCollideWithDeadAfterSleep=False, bAllowPhysics=false)}
	CharacterDetailPresets(1)={(SkeletalMeshLODBias=0, AllowSubsurfaceScattering=False, MaxBodyWoundDecals=5, MaxDeadBodies=12, KinematicUpdateDistFactorScale=1.3, ShouldCorpseCollideWithDead=True, ShouldCorpseCollideWithLiving=True, ShouldCorpseCollideWithDeadAfterSleep=False, bAllowPhysics=true)}
	CharacterDetailPresets(2)={(SkeletalMeshLODBias=0, AllowSubsurfaceScattering=True, MaxBodyWoundDecals=5, MaxDeadBodies=15, KinematicUpdateDistFactorScale=1.0, ShouldCorpseCollideWithDead=True, ShouldCorpseCollideWithLiving=True, ShouldCorpseCollideWithDeadAfterSleep=True, bAllowPhysics=true)}

	// Light Shafts
	LightShaftsPresets(0)={(bAllowLightShafts=False)}
	LightShaftsPresets(1)={(bAllowLightShafts=True)}

	// Volumetric Lighting
	VolumetricLightingPresets(0)={(bAllowLightCones=False)}
	VolumetricLightingPresets(1)={(bAllowLightCones=True)}

	// Lens Flare
	LensFlarePresets(0)={(bAllowLensFlares=False)}
	LensFlarePresets(1)={(bAllowLensFlares=True)}

	// Texture Resolution
	TextureResolutionPresets(0)={(UIBias=0, ShadowmapBias=1, CharacterBias=3, Weapon1stBias=1, Weapon3rdBias=1, EnvironmentBias=2, FXBias=1)}
	TextureResolutionPresets(1)={(UIBias=0, ShadowmapBias=0, CharacterBias=2, Weapon1stBias=1, Weapon3rdBias=1, EnvironmentBias=2, FXBias=1)}
	TextureResolutionPresets(2)={(UIBias=0, ShadowmapBias=0, CharacterBias=1, Weapon1stBias=0, Weapon3rdBias=0, EnvironmentBias=1, FXBias=0)}
	TextureResolutionPresets(3)={(UIBias=0, ShadowmapBias=0, CharacterBias=0, Weapon1stBias=0, Weapon3rdBias=0, EnvironmentBias=0, FXBias=0)}

	// Texture Filtering
	TextureFilterPresets(0)={(MinMagFilter=Linear, MipFilter=Point, MaxAnisotropy=1)}
	TextureFilterPresets(1)={(MinMagFilter=Linear, MipFilter=Linear, MaxAnisotropy=1)}
	TextureFilterPresets(2)={(MinMagFilter=Aniso, MipFilter=Linear, MaxAnisotropy=4)}
	TextureFilterPresets(3)={(MinMagFilter=Aniso, MipFilter=Linear, MaxAnisotropy=16)}

	// Bloom
	BloomPresets(0)={(Bloom=False, BloomQuality=0)}
	BloomPresets(1)={(Bloom=True, BloomQuality=1)}
	BloomPresets(2)={(Bloom=True, BloomQuality=2)}

	// Motion Blur
	MotionBlurPresets(0)={(MotionBlur=False, MotionBlurQuality=0)}
	MotionBlurPresets(1)={(MotionBlur=True, MotionBlurQuality=1)}

	// Anti Aliasing
	AntiAliasingPresets(0)={(PostProcessAA=False)}
	AntiAliasingPresets(1)={(PostProcessAA=True)}

	// Ambient Occlusion
	AmbientOcclusionPresets(0)={(AmbientOcclusion=False, HBAO=False)}
	AmbientOcclusionPresets(1)={(AmbientOcclusion=True, HBAO=False)}
	AmbientOcclusionPresets(2)={(AmbientOcclusion=True, HBAO=True)}

	// Depth Of Field
	DOFPresets(0)={(DepthOfField=False, DepthOfFieldQuality=0)}
	DOFPresets(1)={(DepthOfField=True, DepthOfFieldQuality=1)}
	DOFPresets(2)={(DepthOfField=True, DepthOfFieldQuality=2)}
	DOFPresets(3)={(DepthOfField=True, DepthOfFieldQuality=3)}

    // Flex 
	FlexPresets(0)={(FlexLevel=0)}
	FlexPresets(1)={(FlexLevel=1)}
	FlexPresets(2)={(FlexLevel=2)}
}
