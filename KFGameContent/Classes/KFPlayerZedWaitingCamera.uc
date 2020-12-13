//=============================================================================
// KFPlayerZedWaitingCamera
//=============================================================================
// Camera class for waiting zed players
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
// Matt "Squirrlz" Farber
//=============================================================================
class KFPlayerZedWaitingCamera extends GameFixedCamera;

/** Actor we're currently using as an anchor for our fixed camera */
var Actor FocalPoint;

/** Array of player starts, filled when the camera goes live */
var array<Actor> AvailableFocalPoints;

/** Location offset from focal point base */
var vector CameraOffset;

/** Angle to pitch the camera at */
var int CameraPitchAngle;

/** How long the camera should linger on a focal point */
var float CameraLingerDuration;

/** Last time we changed camera focal points */
var float LastCameraChangeTime;

/** FOV angle used for this camera mode */
var float CameraFOV;

/** Interpolated camera yaw value */
var float CameraYaw;

/** Multiplier used to control how fast the camera pans */
var float CameraPanSpeed;

/** Color to use when fading between camera points */
var color FadeColor;

/** Fade time */
var float FadeTime;

/** Whether we've played a camera fade out before swapping focal points or not */
var bool bPlayedCameraFade;

/** Color to fade out with when switching away from this camera mode */
var color ExitFadeColor;

/** Whether we've played our camera swap fade */
var bool bPlayedExitFade;

/** Light component for our focal point */
var	PointLightComponent CameraLightTemplate;
var transient PointLightComponent CameraLight;

/** Called when the camera becomes active */
function OnBecomeActive( GameCameraBase OldCamera )
{
	super.OnBecomeActive( OldCamera );

	// Fade in
	if( PlayerCamera != none && PlayerCamera.PCOwner != none )
	{
		PlayerCamera.PCOwner.ClientSetCameraFade( true, FadeColor, vect2d(1.f, 0.f), FadeTime, true );
	}

	CameraOffset = default.CameraOffset;
	bPlayedCameraFade = false;
	bPlayedExitFade = false;

	// Create our light
	if( CameraLight == none && CameraLightTemplate != none )
	{
		CameraLight = new(self) class'PointLightComponent'( CameraLightTemplate );
	}

	// Pick a focal point
	UpdateCameraFocalPoint();
}

/** Fills our array of focal points */
function PopulateFocalPoints()
{
	local KFPlayerStart KFPS;
	local KFTraderTrigger KFTT;
	local KFPathnode KFPN;
	local bool bHostileGroundsHackFix;

	// @TODO: HACK FIXME! REMOVE WHEN RENDERER CRASH HAS BEEN SOLVED
	bHostileGroundsHackFix = InStr( class'WorldInfo'.static.GetWorldInfo().GetMapName(), "hostilegrounds",, true ) != INDEX_NONE;
`if(`notdefined(ShippingPC) )
	if( `TimeSinceEx(PlayerCamera, PlayerCamera.CreationTime) < 5.f )
	{
		`log( "[DEBUGVERSUS] KF-HostileGrounds hack fix applied in KFPlayerZedWaitingCamera! FIXME!" );
	}
`endif

	// Fill out focal points array with player starts
	foreach PlayerCamera.WorldInfo.AllNavigationPoints( class'KFPlayerStart', KFPS )
	{
		if( bHostileGroundsHackFix && (KFPS.Name == 'KFPlayerStart_44' || KFPS.Name == 'KFPlayerStart_37') )
		{
			AvailableFocalPoints[AvailableFocalPoints.Length] = KFPS;
		}
	}

	if( bHostileGroundsHackFix )
	{
		return;
	}

	// Fill out focal points array with path nodes near trader triggers
	foreach PlayerCamera.WorldInfo.AllNavigationPoints( class'KFPathnode', KFPN )
	{
		foreach PlayerCamera.DynamicActors( class'KFTraderTrigger', KFTT )
		{
			if( VSizeSQ(KFTT.Location - KFPN.Location) <= 160000.f )
			{
				AvailableFocalPoints[AvailableFocalPoints.Length] = KFPN;
				break;
			}
		}
	}
}

/** Gets a new focal point for the camera */
function UpdateCameraFocalPoint()
{
	local int FocalPointNum;
	local vector HitLocation, HitNormal;
	local vector Projection;
	local KFTraderTrigger KFTT;

	if( PlayerCamera != none && PlayerCamera.PCOwner != none && PlayerCamera.WorldInfo.NetMode != NM_DedicatedServer )
	{
		if( AvailableFocalPoints.Length == 0 )
		{
			PopulateFocalPoints();
		}

		if( FocalPoint != none )
		{
			// Make sure our current focal point is not the next one chosen
			FocalPointNum = AvailableFocalPoints.Find( FocalPoint );
			if( FocalPointNum != INDEX_NONE )
			{
				AvailableFocalPoints.Remove( FocalPointNum, 1 );
			}

			// In case we just cleared focal points, repopulate the list
			if( AvailableFocalPoints.Length == 0 )
			{
				PopulateFocalPoints();
			}

			// Detach our ambient light
			FocalPoint.DetachComponent( CameraLight );
		}

		LastCameraChangeTime = PlayerCamera.WorldInfo.TimeSeconds;

		FocalPoint = AvailableFocalPoints[Rand(AvailableFocalPoints.Length)];

		// Set our initial rotation to face away from the trader (if we're a pathnode)
		foreach FocalPoint.AllActors( class'KFTraderTrigger', KFTT )
		{
			Projection = FocalPoint.Location - KFTT.Location;
			if( VSizeSQ(Projection) <= 160000.f )
			{
				CameraYaw = ( rotator(Projection).Yaw + (8192 - Rand(16384)) ) & 65535;
				break;
			}
		}

		PlayerCamera.PCOwner.SetViewTarget( FocalPoint );

		if( FocalPoint != none )
		{
			// Make sure the camera is in a valid location
			FocalPoint.Trace( HitLocation, HitNormal, FocalPoint.Location + (vect(0,0,1) * (default.CameraOffset.Z + 30.f)), FocalPoint.Location, false,,, FocalPoint.TRACEFLAG_Bullet );
			
			// Offset it if we would have been inside geometry
			if( !IsZero(HitLocation) )
			{
				CameraOffset.Z = VSize( HitLocation - FocalPoint.Location ) - 30.f;
			}
			else
			{
				CameraOffset = default.CameraOffset;
			}

			// Attach our ambient light
			FocalPoint.AttachComponent( CameraLight );
			CameraLight.SetEnabled( true );
		}

		// Play a camera fade
		PlayerCamera.PCOwner.ClientSetCameraFade( true, FadeColor, vect2d(1.f, 0.f), FadeTime, true );
		bPlayedCameraFade = false;		
	}
	else if( FocalPoint != none )
	{
		FocalPoint.DetachComponent( CameraLight );
		FocalPoint = none;
	}
}

/** Expected to fill in OutVT with new camera pos/loc/fov. */
simulated function UpdateCamera( Pawn P, GamePlayerCamera CameraActor, float DeltaTime, out TViewTarget OutVT )
{
	if( PlayerCamera != none
		&& (PlayerCamera.WorldInfo.TimeSeconds - LastCameraChangeTime) >= (CameraLingerDuration - FadeTime) )
	{
		if( !bPlayedCameraFade )
		{
			// Play a camera fade
			PlayerCamera.PCOwner.ClientSetCameraFade( true, FadeColor, vect2d(0.f, 1.f), FadeTime, true );
			bPlayedCameraFade = true;
		}

		if( PlayerCamera.WorldInfo.TimeSeconds - LastCameraChangeTime >= CameraLingerDuration )
		{
			UpdateCameraFocalPoint();
		}
	}

	if( FocalPoint != none )
	{
		// Set location and rotation
		OutVT.POV.Location = FocalPoint.Location + CameraOffset;
		OutVT.POV.Rotation.Pitch = CameraPitchAngle;
		CameraYaw = ( CameraYaw + (CameraPanSpeed * DeltaTime) ) & 65535;
		OutVT.POV.Rotation.Yaw = CameraYaw;

		// Set FOV
		OutVT.POV.FOV = CameraFOV;

		// cameraanims, fades, etc
		PlayerCamera.ApplyCameraModifiers( DeltaTime, OutVT.POV );
	}

	// if we had to reset camera interpolation, then turn off flag once it's been processed.
	bResetCameraInterpolation = false;

	super(GameCameraBase).UpdateCamera( P, CameraActor, DeltaTime, OutVT );
}

/** Fades out when leaving this camera mode */
function PlayExitFade()
{
	if( !bPlayedExitFade )
	{
		PlayerCamera.PCOwner.ClientSetCameraFade( true, ExitFadeColor, vect2d(1.f, 0.f), FadeTime, true );
		bPlayedExitFade = true;
	}
}

/** Called when the camera becomes inactive */
function OnBecomeInActive( GameCameraBase NewCamera )
{
	super.OnBecomeInActive( NewCamera );

	// Detach and de-reference our light
	if( CameraLight != none )
	{
		if( FocalPoint != none )
		{
			FocalPoint.DetachComponent( CameraLight );
		}
		CameraLight.SetEnabled( false );
		CameraLight = none;
	}

	// Fade out our camera transition
	PlayExitFade();

	// Restore defaults
	CameraOffset = default.CameraOffset;
	FocalPoint = none;
	bPlayedCameraFade = false;
}

DefaultProperties
{
	CameraOffset=(X=0,Y=0,Z=300.f)
	CameraPitchAngle=-3072
	CameraLingerDuration=12.f
	CameraFOV=160.f
	CameraPanSpeed=256.f
	FadeColor=(R=0,G=0,B=0)
	FadeTime=1.f
	ExitFadeColor=(R=255,G=255,B=255)

	Begin Object Class=PointLightComponent Name=PointLightTemplate_0
		LightColor=(R=230,G=255,B=235,A=255)
		Brightness=0.2f
		Radius=2000.f
		FalloffExponent=10.f
		CastShadows=false
		CastStaticShadows=false
		CastDynamicShadows=false
		bCastPerObjectShadows=false
		bEnabled=false
		LightingChannels=(Indoor=TRUE,Outdoor=TRUE,bInitialized=TRUE)
	End Object
	CameraLightTemplate=PointLightTemplate_0
}