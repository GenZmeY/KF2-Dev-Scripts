class KFPlayerCamera_Versus extends KFPlayerCamera;

/** Implements zed waiting camera */
var(Camera) editinline transient KFPlayerZedWaitingCamera			PlayerZedWaitingCam;
/** Class to use for zed waiting camera. */
var(Camera) protected const  class<KFPlayerZedWaitingCamera>      	PlayerZedWaitingCameraClass;

/** Implements zed suicide camera */
var(Camera) editinline transient KFPlayerZedSuicideCamera					PlayerZedSuicideCam;
/** Class to use for zed suicide camera. */
var(Camera) protected const  class<KFPlayerZedSuicideCamera>      		PlayerZedSuicideCameraClass;

function PostBeginPlay()
{
	super.PostBeginPlay();

	// Setup camera modes
	if ( (PlayerZedWaitingCam == None) && (PlayerZedWaitingCameraClass != None) )
	{
		PlayerZedWaitingCam = KFPlayerZedWaitingCamera( CreateCamera(PlayerZedWaitingCameraClass) );
	}
}

/*
 * Switches immediately to zed suicide cam so we can perform our init immediately
 * Pawn will be none on first frame after death
 */
function SwapToZedSuicideCam( vector SuicideLocation )
{
	local GameCameraBase NewCamera;

	// Setup camera modes
	if ( (PlayerZedSuicideCam == None) && (PlayerZedSuicideCameraClass != None) )
	{
		PlayerZedSuicideCam = KFPlayerZedSuicideCamera( CreateCamera(PlayerZedSuicideCameraClass) );
	}

	// decide which camera to use
	NewCamera = PlayerZedSuicideCam;

	// handle a switch if necessary
	if (CurrentCamera != NewCamera)
	{
		if (CurrentCamera != None)
		{
			CurrentCamera.OnBecomeInActive( NewCamera );
		}

		if (NewCamera != None)
		{
			NewCamera.OnBecomeActive( CurrentCamera );
		}

		CurrentCamera = NewCamera;
	}

	// Init our suicide cam
	PlayerZedSuicideCam.InitSuicideCam( SuicideLocation );
}

/**
 * Polls game state to determine best camera to use.
 */
protected function GameCameraBase FindBestCameraType( Actor CameraTarget )
{
	if( CameraStyle == 'PlayerZedWaiting' )
	{
		return PlayerZedWaitingCam;
	}	
	else if (CameraStyle == 'ZedSuicide')
	{
		return PlayerZedSuicideCam;
	}

	return super.FindBestCameraType( CameraTarget );
}

DefaultProperties
{
	ThirdPersonCameraClass=class'KFThirdPersonCamera_Versus'
	PlayerZedWaitingCameraClass=class'KFPlayerZedWaitingCamera'
	PlayerZedSuicideCameraClass=class'KFPlayerZedSuicideCamera'
}
