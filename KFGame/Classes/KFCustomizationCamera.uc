//=============================================================================
// KFCustomizationCamera
//=============================================================================
// Class Description
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//  - Author 1/20/2014
//=============================================================================

class KFCustomizationCamera extends GameCameraBase;

var		bool 	bInitialize;
var 	byte	BodyViewIndex;
var 	byte 	CurrentViewIndex;

var()	Vector	CharacterOffset;
var()	Vector	HeadOffset;

var		float 	CharacterDistance;
var		float 	HeadDistance;

var     int 	RotationOffset;
var     int 	RotationRate;
var 	int 	MaxRotationRate;


var int 	LastRotation;
var float	FadeRotationStartTime;
var float	FadeRotationDuration;
var float	FadeRotationScaler;

/** Called when the camera becomes active */
function OnBecomeActive( GameCameraBase OldCamera )
{
	SetCustomizationView( PlayerCamera, PlayerCamera.ViewTarget, CharacterOffset, CharacterDistance );
}

function UpdateCamera(Pawn P, GamePlayerCamera CameraActor, float DeltaTime, out TViewTarget OutVT)
{
	// OnBecomeActive doesn't have the customization pawn at the start of the game
	if ( !bInitialize && P != none )
	{
		SetCustomizationView( CameraActor, OutVT, CharacterOffset, CharacterDistance );
		bInitialize = true;
	}

	if( PlayerCamera.PCOwner.Pawn != none )
	{
		PlayerCamera.PCOwner.SetViewTarget( PlayerCamera.PCOwner.Pawn );	
	}

	// cameraanims, fades, etc
	PlayerCamera.ApplyCameraModifiers( DeltaTime, OutVT.POV );
}

function SetBodyView( byte Index, optional bool bForceView = false )
{
	if ( BodyViewIndex != Index || bForceView )
	{
		BodyViewIndex = Index;
		BlendCustomizationPart( PlayerCamera, BodyViewIndex );
	}
}

function BlendCustomizationPart( GamePlayerCamera CameraActor, byte Index )
{
	CurrentViewIndex = Index;
	CameraActor.ViewTarget.POV = CameraActor.CameraCache.POV;
	CameraActor.PendingViewTarget.Target = CameraActor.ViewTarget.Target;
	
	switch ( Index )
	{
	 	case 0:
        	SetCustomizationView( CameraActor, CameraActor.PendingViewTarget, CharacterOffset, CharacterDistance );
	 	break;
	 	case 1:
        	SetCustomizationView( CameraActor, CameraActor.PendingViewTarget, HeadOffset, HeadDistance );
	 	break;
	}
}

function SetCustomizationView( GamePlayerCamera CameraActor, out TViewTarget OutVT, Vector Offset, float Distance )
{
	local vector		Loc, Pos, HitLocation, HitNormal;
	local rotator		Rot;
    local Actor			HitActor;

	Loc = OutVT.Target.Location;
	Rot = OutVT.Target.Rotation;
	Rot.Yaw += RotationOffset;

	CameraActor.BlendTimeToGo = 0.5f;	
	CameraActor.BlendParams.BlendTime = CameraActor.BlendTimeToGo;		

	Loc += Offset >> Rot;
	Pos = Loc - Vector(Rot) * Distance;

	HitActor = CameraActor.Trace(HitLocation, HitNormal, Pos, Loc, FALSE, vect(12,12,12));
	OutVT.POV.Location = (HitActor == None) ? Pos : HitLocation;
	OutVT.POV.Rotation = Rot;
}

/** This is used to remember the last known mouse input for fading out */
function RotatedCamera( int DirectionOffset )
{
	DirectionOffset = FClamp(DirectionOffset, -MaxRotationRate, MaxRotationRate);
	UpdateRotation( DirectionOffset );
	// LastRotation is used for when the mouse is released
	LastRotation = DirectionOffset / FadeRotationScaler;
}

function UpdateRotation( int DirectionOffset )
{
	if( PlayerCamera.PCOwner.IsTimerActive(nameof(FadeCameraRotation)) )
	{
		PlayerCamera.PCOwner.ClearTimer(nameof(FadeCameraRotation), self);
	}

	RotationOffset += DirectionOffset * RotationRate;
	//BlendCustomizationPart( PlayerCamera, CurrentViewIndex );
	if( CurrentViewIndex == 0 )
	{
		SetCustomizationView( PlayerCamera, PlayerCamera.ViewTarget, CharacterOffset, CharacterDistance );
	}
	else
	{
		SetCustomizationView( PlayerCamera, PlayerCamera.ViewTarget, HeadOffset, HeadDistance );
	}
}

/** Once we let go of the mouse, lerp the rotation to a halt */
function StartFadeRotation()
{
	if( LastRotation != 0 )
	{
		// Scale the duration of the fading rotation by how strong our mouse movement was
		FadeRotationDuration = Abs(LastRotation) * 0.01f;
		FadeRotationStartTime = PlayerCamera.PCOwner.WorldInfo.TimeSeconds;
		PlayerCamera.PCOwner.SetTimer( 0.01f, true, nameof(FadeCameraRotation), self );
	}
}

/** Handles lerping the camera rotation once we let go */
function FadeCameraRotation()
{
	local int NewRotation;
	local float	RotationAlpha;
	RotationAlpha = (PlayerCamera.PCOwner.WorldInfo.TimeSeconds - FadeRotationStartTime) / FadeRotationDuration;
	RotationAlpha = FClamp(RotationAlpha, 0, 1);
	NewRotation = Lerp(LastRotation, 0, RotationAlpha);

	if( RotationAlpha >= 1 )
	{
		PlayerCamera.PCOwner.ClearTimer(nameof(FadeCameraRotation), self);
		LastRotation = 0;
		NewRotation = 0;
	}
	
	UpdateRotation( NewRotation );
}


/** Called when the camera becomes inactive */
function OnBecomeInActive( GameCameraBase NewCamera )
{
	super.OnBecomeInActive( NewCamera );

	bInitialize = false;
	LastRotation = 0;
}

defaultproperties
{
	CharacterOffset=(X=0,Y=-15,Z=6)
	HeadOffset=(X=0,Y=-15,Z=68)

	CharacterDistance=200
	HeadDistance=70

	RotationOffset=38500
	RotationRate=50
	MaxRotationRate=100

	FadeRotationDuration=0.2f
	FadeRotationScaler=3.5f
}
