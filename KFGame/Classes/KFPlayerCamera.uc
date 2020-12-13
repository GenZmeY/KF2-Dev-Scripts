//=============================================================================
// KFPlayerCamera
//=============================================================================
// Camera class for KF players
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
// John "Ramm-Jaeger" Gibson
//=============================================================================

class KFPlayerCamera extends GamePlayerCamera
	config(Camera);

`include(KFProfileSettings.uci);

/** Implements typical third person camera. */
var(Camera) editinline transient KFCustomizationCamera			CustomizationCam;
/** Class to use for third person camera. */
var(Camera) protected const  class<KFCustomizationCamera>      	CustomizationCameraClass;


/** Implements the boss camera. */
var(Camera) editinline transient KFBossCamera					BossCam;
/** Class to use for viewing the boss camera. */
var(Camera) protected const  class<KFBossCamera>      			BossCameraClass;

/** Implements typical first person camera. */
var(Camera) editinline transient KFFirstPersonCamera			FirstPersonCam;
/** Class to use for first person camera. */
var(Camera) protected const  class<GameCameraBase>      		FirstPersonCameraClass;

/** Implements the Emote camera. */
var(Camera) editinline transient KFEmoteCamera					EmoteCam;
/** Class to use for viewing the Emote camera. */
var(Camera) protected const  class<KFEmoteCamera>      			EmoteCameraClass;

/*********************************************************************************************
 FOV Blending
********************************************************************************************* */

/** The FOV that the Camera is trying to acheive */
var()	float		TargetFOV;
/** The FOV that was being used at the start of the FOV Transition */
var		float		TransitionStartFOV;
/** How long (in seconds) the camera has been transitioning to TargetFOV */
var		float		TransitionTimeElapsed;
/** How long it should take to transition to the target FOV */
var		float		TransitionTimeTotal;

function PostBeginPlay()
{
	super.PostBeginPlay();

	// Setup camera modes
	if ( (CustomizationCam == None) && (CustomizationCameraClass != None) )
	{
		CustomizationCam = KFCustomizationCamera( CreateCamera(CustomizationCameraClass) );
	}

	// Setup camera modes
	if ( (BossCam == None) && (BossCameraClass != None) )
	{
		BossCam = KFBossCamera( CreateCamera(BossCameraClass) );
	}

	// Setup camera modes
	if ( (FirstPersonCam == None) && (FirstPersonCameraClass != None) )
	{
		FirstPersonCam = KFFirstPersonCamera( CreateCamera(FirstPersonCameraClass) );
	}

	if ( EmoteCam == None && EmoteCameraClass != None )
	{
		EmoteCam = KFEmoteCamera( CreateCamera(EmoteCameraClass) );
	}
}

/** Performs camera update. */
simulated function DoUpdateCamera(float DeltaTime)
{
	// __TW_ZEDTIME_ : Adjust by Pawn's TimeDilation (partial zed time) for camera anims
	Super.DoUpdateCamera(DeltaTime * ViewTarget.Target.CustomTimeDilation);
}

/**
 * UpdateViewTarget
 * Overridden to support FOV Blending
 */
simulated function UpdateViewTarget(out TViewTarget OutVT, float DeltaSeconds)
{
	local float CurrentFOVAngle;
	local float TransitionDelta;

	super.UpdateViewTarget(OutVT,DeltaSeconds);

	if ( CameraActor(OutVT.Target) != None )
	{
		SetFOV(0);	// Give CameraActor control over FOV
	}
	else
	{
		CurrentFOVAngle = GetFOVAngle();
		// Updating the FOV
		if( TransitionTimeTotal > 0.0f && CurrentFOVAngle != TargetFOV )
		{
			TransitionTimeElapsed += DeltaSeconds;
			if( TransitionTimeElapsed > TransitionTimeTotal )
			{
				TransitionTimeElapsed = TransitionTimeTotal;
				TransitionDelta = 1.0;
			}
			else
			{
                TransitionDelta = TransitionTimeElapsed/TransitionTimeTotal;
			}

            //`log("CurrentFOVAngle = "$CurrentFOVAngle$" TransitionDelta = "$TransitionDelta$" TransitionTimeTotal = "$TransitionTimeTotal$" TransitionTimeElapsed = "$TransitionTimeElapsed);

			CurrentFOVAngle = Lerp( TransitionStartFOV, TargetFOV, TransitionDelta );
			super.SetFOV(CurrentFOVAngle);
		}
	}

	// Call this after the FOV has been adjusted
	if( CameraLensEffects.Length > 0 )
	{
		UpdateCameraLensEffects( OutVT );
	}
}

/** Function that allows us to control the FOV value. Needed for half-res checkerboard rendering */
function float GetActualFOV()
{
	local LocalPlayer LP;
	local vector2D ViewportSize;
	local float ActualFOV;

	// Scale FOV by aspect ratio
	if( WorldInfo.IsNeoCheckerboardRendering() )
	{
		LP = LocalPlayer( PCOwner.Player );
		if( LP != none && LP.ViewportClient != none )
		{
			// Grab our viewport size, not our canvas size
			LP.ViewportClient.GetViewportSize( ViewportSize );
			class'KFPlayerController'.static.CalcFOVForAspectRatio( GetFOVAngle(), ViewportSize.X, ViewportSize.Y, ActualFOV );

			return ActualFOV;
		}
	}

	return super.GetActualFOV();
}

/** Update any attached camera lens effects (e.g. blood) **/
simulated function UpdateCameraLensEffects( const out TViewTarget OutVT )
{
	local EmitterCameraLensEffectBase CameraEffect;
	local float ActualFOV;

	ActualFOV = GetActualFOV();
	foreach CameraLensEffects( CameraEffect )
	{
		if( CameraEffect != none )
		{
			if( class'WorldInfo'.static.IsNeoCheckerboardRendering() )
            {
                CameraEffect.UpdateLocation( OutVT.POV.Location, OutVT.POV.Rotation, UnModifiedFOV );
            }
            else
            {
                CameraEffect.UpdateLocation( OutVT.POV.Location, OutVT.POV.Rotation, ActualFOV );
            }
		}
	}
}

/**
 * Handle smoothly transitioning between FOVs
 * @param NewFOV specifies the new TargetFOV
 * @param TransitionTime specifies how long in seconds the transition should take
 */
function TransitionFOV(float NewFOV, float TransitionTime)
{
	NewFOV *= GetOptionsFOVScale();

	if( TransitionTime > 0.0f )
	{
		TargetFOV = NewFOV;
		TransitionTimeTotal = TransitionTime;
		TransitionStartFOV = GetFOVAngle();
		TransitionTimeElapsed = 0.0f;
	}
	else
	{
		SetFOV(NewFOV);
		TransitionTimeTotal = 0.0f; // The system won't attempt an FOV transition if TimeTotal is 0.
	}
}

function  float GetOptionsFOVScale()
{
	local float FOVScale;
	local KFProfileSettings Settings;

	FOVScale = 1.0f;

	if(class'WorldInfo'.static.IsConsoleBuild())
	{
		Settings = KFProfileSettings(class'GameEngine'.static.GetOnlineSubsystem().PlayerInterface.GetProfileSettings(LocalPlayer(PCOwner.Player).ControllerId));
		if(Settings != None)
		{
			FOVScale = Settings.GetProfileFloat(KFID_FOVOptionsPercentageValue);
		}
	}
	else // PC
	{
		FOVScale = class'KFGameEngine'.default.FOVOptionsPercentageValue;
	}
	return FClamp(FOVScale, 0.75f, 1.25f);
}

/**
 * Directly set the FOV with no transition
 */
function SetFOV(float NewFOV)
{
    TransitionTimeTotal = 0.0f;
	TargetFOV = NewFOV;
	super.SetFOV(NewFOV);
}

/** Overriden to use CameraCache.Pov.Location */
static function float CalcRadialShakeScale(Camera Cam, vector Epicenter, float InnerRadius, float OuterRadius, float Falloff)
{
	local Vector			POVLoc;
	local float				DistPct;

	// using camera location so stuff like spectator cameras get shakes applied sensibly as well
	// need to ensure server has reasonably accurate camera position
	POVLoc = Cam.CameraCache.POV.Location;

	if (InnerRadius < OuterRadius)
	{
		DistPct = (VSize(Epicenter - POVLoc) - InnerRadius) / (OuterRadius - InnerRadius);
		DistPct = 1.f - FClamp(DistPct, 0.f, 1.f);
		return DistPct ** Falloff;
	}
	else
	{
		// ignore OuterRadius and do a cliff falloff at InnerRadius
		return (VSize(Epicenter - POVLoc) < InnerRadius) ? 1.f : 0.f;
	}
}

/**
 * Polls game state to determine best camera to use.
 */
protected function GameCameraBase FindBestCameraType(Actor CameraTarget)
{
	if (CameraStyle == 'ThirdPerson')
	{
		return ThirdPersonCam;
	}
	else if (CameraStyle == 'Boss')
	{
		return BossCam;
	}
	else if (CameraStyle == 'Customization')
	{
		return CustomizationCam;
	}
	else if( CameraStyle == 'FirstPerson' )
	{
		return FirstPersonCam;
	}
	else if( CameraStyle == 'Emote' )
	{
		return EmoteCam;
	}

	return Super.FindBestCameraType(CameraTarget);
}

simulated function Reset();

defaultproperties
{
	// Our default FOV is in 16:9, and then scaled based on the aspect ratio
    DefaultFOV=90.0.f
	FreeCamOffset=(X=0,Y=0,Z=68)
	ThirdPersonCameraClass=class'KFThirdPersonCamera'
	CustomizationCameraClass=class'KFCustomizationCamera'
	BossCameraClass=class'KFBossCamera'
	FirstPersonCameraClass=class'KFFirstPersonCamera'
	EmoteCameraClass=class'KFEmoteCamera'
}