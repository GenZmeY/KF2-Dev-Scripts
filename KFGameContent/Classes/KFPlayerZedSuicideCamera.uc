//=============================================================================
// KFPlayerZedSuicideCamera
//=============================================================================
// Camera class for player zed suicide attacks (crawler, husk)
//=============================================================================
// Killing Floor 2
// Copyright (C) 2016 Tripwire Interactive LLC
// Matt "Squirrlz" Farber
//=============================================================================
class KFPlayerZedSuicideCamera extends GameFixedCamera;

/** Initial camera location for a smooth transition */
var vector InitialCameraLocation;

/** Location offset from focal point base */
var vector CameraOffset;

/** Speed to interpolate from the initial location to the desired location */
var float CameraInterpSpeed;

/** Our desired location */
var vector DesiredLocation;

/** Our desired rotation */
var rotator DesiredRotation;

/** Angle to pitch the camera at */
var int CameraPitchAngle;

/** Multiplier used to control how fast the camera pans */
var float CameraPanSpeed;

/** Interpolated camera yaw */
var int CameraPanYaw;

/** Desired FOV for the camera */
var float CameraFOV;

/** Speed to reach the desired FOV */
var float CameraFOVInterpSpeed;

/** Our interpolated FOV value */
var float InterpolatedFOV;

/** How much to offset the camera by if a trace hits the ceiling */
var float CameraCollisionZOffset;

/** Called when the camera becomes active */
function OnBecomeActive( GameCameraBase OldCamera )
{
	super.OnBecomeActive( OldCamera );
}

/** Sets our initial values. Needs to be done immediately upon switch, because UpdateCamera() is a frame behind */
function InitSuicideCam( vector PawnLocation )
{
	CameraOffset = default.CameraOffset;	
	InitialCameraLocation = PlayerCamera.CameraCache.POV.Location;
	DesiredRotation = rotator( InitialCameraLocation - PawnLocation );
	DesiredRotation.Pitch = CameraPitchAngle;
	CameraPanYaw = PlayerCamera.CameraCache.POV.Rotation.Yaw;

	// Set our initial camera targets
	PlayerCamera.PCOwner.SetLocation( InitialCameraLocation );
	PlayerCamera.PCOwner.SetViewTarget( PlayerCamera.PCOwner );
	InterpolatedFOV = PlayerCamera.CameraCache.POV.FOV;

	UpdateCameraFocalPoint();
}

/** Gets a new focal point for the camera */
function UpdateCameraFocalPoint()
{
	local Actor TraceActor;
	local vector HitLocation, HitNormal;

	// Make sure the camera is in a valid location
	TraceActor = PlayerCamera.PCOwner.Pawn != none ? PlayerCamera.PCOwner.Pawn : PlayerCamera.PCOwner;
	TraceActor.Trace( HitLocation, HitNormal, InitialCameraLocation + (vect(0,0,1) * (default.CameraOffset.Z + CameraCollisionZOffset)), InitialCameraLocation, false, vect(5,5,5),, TraceActor.TRACEFLAG_Bullet );
	
	// Offset it if we would have been inside geometry
	if( !IsZero(HitLocation) )
	{
		CameraOffset.Z = VSize( HitLocation - InitialCameraLocation ) - CameraCollisionZOffset;
	}
	else
	{
		CameraOffset = default.CameraOffset;
	}

	DesiredLocation = InitialCameraLocation + CameraOffset;
}

/** Expected to fill in OutVT with new camera pos/loc/fov. */
simulated function UpdateCamera( Pawn P, GamePlayerCamera CameraActor, float DeltaTime, out TViewTarget OutVT )
{
	super(GameCameraBase).UpdateCamera( P, CameraActor, DeltaTime, OutVT );

	if( DesiredLocation == vect(0,0,0) || InitialCameraLocation == vect(0,0,0) )
	{	
		return;
	}

	// Cameraanims, fades, etc
	PlayerCamera.ApplyCameraModifiers( DeltaTime, OutVT.POV );

	// Set view location and rotation
	OutVT.POV.Location = VInterpTo( OutVT.POV.Location, DesiredLocation, DeltaTime, CameraInterpSpeed );
	OutVT.POV.Rotation = RInterpTo( OutVT.POV.Rotation, DesiredRotation, DeltaTime, CameraInterpSpeed );
	CameraPanYaw = ( CameraPanYaw + (CameraPanSpeed * DeltaTime) ) & 65535;
	OutVT.POV.Rotation.Yaw = CameraPanYaw;
	OutVT.POV.Rotation.Roll = 0;

	// Set FOV
	InterpolatedFOV = FInterpTo( InterpolatedFOV, CameraFOV, DeltaTime, CameraFOVInterpSpeed );
	OutVT.POV.FOV = InterpolatedFOV;
}

/** Called when the camera becomes inactive */
function OnBecomeInActive( GameCameraBase NewCamera )
{
	super.OnBecomeInactive( NewCamera );

	InitialCameraLocation = vect(0,0,0);
	DesiredLocation = vect(0,0,0);
}

defaultproperties
{
	CameraOffset=(X=0,Y=0,Z=300.f)
	CameraInterpSpeed=2.f
	CameraPanSpeed=1024.f
	CameraPitchAngle=-12000
	CameraFOV=160.f
	CameraFOVInterpSpeed=1.f
	CameraCollisionZOffset=40.f
}