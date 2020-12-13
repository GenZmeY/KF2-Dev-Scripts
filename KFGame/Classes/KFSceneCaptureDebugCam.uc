//=============================================================================
// KFSceneCaptureDebugCam
//=============================================================================
// Renders a debug scene window focusing on the FocusActor's location.
// Activated through KFCheatManager - see "FocusOn" exec function.
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//=============================================================================
class KFSceneCaptureDebugCam extends SceneCapture2DActor
	native(Camera);

const MAXDEBUGWINDOWS = 1;

var Texture2D				BlackTexture;
/** Scene capture component that's attached when debug scene camera is active */
var SceneCapture2DComponent	CaptureComponent;
/** Actor that this camera is focused on */
var Actor					FocusActor;
/** Class of actor that this camera is focused on */
var class<Actor>			FocusClass;
/** This variable is used if the current focus actor is a Pawn */
var Pawn					FocusPawn;
/** Owning player controller for this debug scene camera */
var KFPlayerController		PCOwner;
/** Pop up a debug scene view focusing on NPC who most recently failed a move */
var bool					bWatchNPCPathFailures;
/** Pop up a debug scene view when an actor with a specific name is spawned */
var bool					bWatchActorSpawn;
/** Actor name to watch for spawn if bWatchActorSpawn is true */
var name					ActorNameToWatchOnSpawn;
/** Pop up a debug scene view when the camera receives a touch event */
var bool					bWatchTouch;
/** Debug scene view orbits around focus actor when true */
var bool					bOrbitFocus;
/** Set the camera's base to the focus actor */
var bool					bSetBaseToFocus;
/** Prevents the focus actor's skeletal mesh from pausing animations when not in view */
var bool					bNoAnimPause;
/** When true, camera location/orientation has been placed in a fixed position/rotation by player */
var bool					bOverrideFocus;
/** Number of currently active debug windows (WIP, currently 1 max) */
var int						ActiveDebugWindows;
var bool					bLockFocus;
/** If bNoAnimPause is true, some of the focus actor's skeletal mesh properties are stored here to be reset later */
var bool					bTickAnimNodesWhenNotRendered;
var bool					bUpdateSkelWhenNotRendered;
var bool					bIgnoreControllersWhenNotRendered;
var float					MinDistFactorForKinematicUpdate;
var bool					bPauseAnims;
var string					CurrentDebugSceneMessage;
var bool					bTextOnly;

/** Material for debug scene window */
var MaterialInterface			DebugViewMaterial;
var MaterialInstanceConstant	DebugViewMaterialInstance;

var KFAIController FocusController;
var KFPawn		   FocusKFPawn;
var vector		   LastLocation;

/*********************************************************************************************
 Native functions
 **********************************************************************************************/

/** Creates the TextureRenderTarget2D in which the debug scene is rendered */
native function TextureRenderTarget2D CreateDebugTexture();
/** Overridden to call the PostRender event if this camera is active and PC is the PCOwner */
simulated native function NativePostRenderFor(PlayerController PC, Canvas Canvas, vector CameraPosition, vector CameraDir);
simulated native function GetDebugSceneViewPoint( out vector out_Location, out Rotator out_Rotation );

/*********************************************************************************************
 Initialization / Destruction
 **********************************************************************************************/

/**
 * public function bool InitDebugScene() 
 * Called from KFPlayerController - initializes the debug scene to focus on ActorToWatch
 * @param	NewOwner        PlayerController who will own this debug cam
 * @param	ActorToWatch    Debug scene will be focused on this actor's location
 * @param	DebugMessage    Optional debug message which will be shown in debug text by PostRenderFor()
 */
function bool InitDebugScene( KFPlayerController NewOwner, actor ActorToWatch, optional string DebugMessage )
{
	local TextureRenderTarget2D TextureTarget;
	local vector SceneLocation;
	local rotator SceneRotation;

	PCOwner = NewOwner;
	CurrentDebugSceneMessage = DebugMessage;

	if( FocusActor == ActorToWatch )
	{
		return false;
	}
	FocusActor = ActorToWatch;
	FocusPawn = Pawn( FocusActor );
	FocusKFPawn = KFPawn( FocusActor );
	FocusController = KFAIController( FocusKFPawn.Controller );

	if( FocusPawn != none && !bTextOnly )
	{
		RestoreFocusPawnMeshProperties();
		FocusPawn = None;
	}

	TextureTarget = CreateDebugTexture();

	//SetLocation( ActorToWatch.Location );
	SetRotation( ActorToWatch.Rotation );

	if( bSetBaseToFocus )
	{
		//SetBase( ActorToWatch );
	}

	CaptureComponent.SetEnabled( true );
	CaptureComponent.SetCaptureParameters( TextureTarget );

	GetDebugSceneViewPoint( SceneLocation, SceneRotation );
	CaptureComponent.SetView( SceneLocation, SceneRotation );
	
	// Create the material instance for the debug scene view
	if( DebugViewMaterialInstance == none )
	{
		DebugViewMaterialInstance = new(self) class'MaterialInstanceConstant';
	}
	DebugViewMaterialInstance.SetParent( DebugViewMaterial ); 
	DebugViewMaterialInstance.SetTextureParameterValue( 'RenderToTextureMap', TextureTarget);

	AttachComponent( CaptureComponent );
	ActiveDebugWindows++;

	// Special handling if actor to watch is a pawn
	if( Pawn( ActorToWatch ) != none && !bTextOnly )
	{
		FocusPawn = Pawn( ActorToWatch );

		if( FocusPawn.Mesh != none )
		{
			// Make the pawn animate if not visible, if desired
			if( bNoAnimPause )
			{
				CacheAndUpdateFocusPawnMeshProperties();
			}
		}
	}
	
	return true;
}

/**
 * public function DestroyDebugScene() 
 * Clean up the debug scene and capture component, and restore any properties changed on the focus actor's skeletal mesh
 */
event DestroyDebugScene()
{
	CurrentDebugSceneMessage = "";
	ActiveDebugWindows--;
	if( FocusPawn != none )
	{
		RestoreFocusPawnMeshProperties();
		FocusPawn = none;
	}
	FocusActor = none;
	DebugViewMaterialInstance.SetParent( none );
	DebugViewMaterialInstance = none;
	FocusClass = none;
	PCOwner = none;

	DetachComponent( CaptureComponent );
	CaptureComponent = none;
	Destroy();
}

/*********************************************************************************************
 Behavior changing functions accessed through cheat manager
 **********************************************************************************************/

/** Turn the orbiting camera movement on or off */
function ToggleDebugSceneOrbit()
{
	bOrbitFocus = !bOrbitFocus;
}

/** Called from cheat manager when player wants to set the debug view to a fixed position/rotation matching the pawn's current values */
function MoveToMyPawnLocation()
{
	local vector CameraLoc;
	local rotator CameraRot;

	bOverrideFocus = true;
	// Turn movement/orbiting off
	SetBase( None );
	bOrbitFocus = false;

	PCOwner.GetPlayerViewPoint( CameraLoc, CameraRot );
	SetLocation( CameraLoc );
	SetRotation( CameraRot );
	CaptureComponent.SetView( CameraLoc, CameraRot );
}

/**
 * public function ToggleLockFocus() 
 * Toggles whether debug scene focus is locked to its current view
 */
function ToggleLockFocus()
{
	bLockFocus = !bLockFocus;
}

/**
 * public function SetDebugSceneViewMode() 
 * Called from cheat manager - lets player change debug scene viewmode 
 * @param	NewViewMode     New scene capture view mode to use (SceneCapView_Lit,SceneCapView_Wire,etc.)
 */
function SetDebugSceneViewMode( ESceneCaptureViewMode NewViewMode )
{
	CaptureComponent.ViewMode = NewViewMode;
	DetachComponent( CaptureComponent );
	AttachComponent( CaptureComponent );
}

/**
 * public function PauseDebugSceneUpdate() 
 * Called from cheat manager, toggles pausing of debug scene window updates
 */
function PauseDebugSceneUpdate()
{
	CaptureComponent.bEnabled = !CaptureComponent.bEnabled;
}

/*********************************************************************************************
 FocusPawn handling - if FocusActor is a pawn
 **********************************************************************************************/

/**
 * public function CacheAndUpdateFocusPawnMeshProperties() 
 * Store some of the focus pawn's mesh property values and get the mesh to animate if it's not 
 * considered visible
 */
function CacheAndUpdateFocusPawnMeshProperties()
{
	// Store the mesh properties that will might be changing
	bTickAnimNodesWhenNotRendered = FocusPawn.Mesh.bTickAnimNodesWhenNotRendered;
	bUpdateSkelWhenNotRendered = FocusPawn.Mesh.bUpdateSkelWhenNotRendered;
	bIgnoreControllersWhenNotRendered = FocusPawn.Mesh.bIgnoreControllersWhenNotRendered;
	MinDistFactorForKinematicUpdate = FocusPawn.Mesh.MinDistFactorForKinematicUpdate;
	bPauseAnims = FocusPawn.Mesh.bPauseAnims;

	// Update the mesh properties to prevent the focus target mesh from pausing its animations
	FocusPawn.Mesh.bTickAnimNodesWhenNotRendered = true;
	FocusPawn.Mesh.bUpdateSkelWhenNotRendered = true;
	FocusPawn.Mesh.bIgnoreControllersWhenNotRendered = false;
	FocusPawn.Mesh.MinDistFactorForKinematicUpdate = 0;
	FocusPawn.Mesh.bPauseAnims = false;
}

/**
 * public function RestoreFocusPawnMeshProperties() 
 * Reset any properties changed for the focus actor's skeletal mesh
 */
function RestoreFocusPawnMeshProperties()
{
	FocusPawn.Mesh.bTickAnimNodesWhenNotRendered = bTickAnimNodesWhenNotRendered;
	FocusPawn.Mesh.bUpdateSkelWhenNotRendered = bUpdateSkelWhenNotRendered;
	FocusPawn.Mesh.bIgnoreControllersWhenNotRendered = bIgnoreControllersWhenNotRendered;
	FocusPawn.Mesh.MinDistFactorForKinematicUpdate = MinDistFactorForKinematicUpdate;
	FocusPawn.Mesh.bPauseAnims = bPauseAnims;
}


/*********************************************************************************************
 Rendering
 **********************************************************************************************/

/**
 * public function GetDebugSceneViewPoint() 
 * Used to get the orbit locations for the debug scene camera
 * @param	out_Location    Location of current orbiting view point
 * @param	out_Rotation    Rotation of current orbiting view point
 */
// function GetDebugSceneViewPoint( out vector out_Location, out Rotator out_Rotation )
// {
// 	if( FocusActor != none )
// 	{
// 		if( bOrbitFocus )
// 		{
// 			out_Rotation = FocusActor.Rotation;
// 			out_Rotation.Pitch -= 3000;
// 			out_Rotation.Yaw = ( WorldInfo.TimeSeconds * 65536 ) / 10;
// 			out_Location = ( FocusActor.Location + vect(0,0,72) ) - 120 * vector( out_Rotation );
// 		}
// 		else
// 		{
// 			out_Rotation = FocusActor.Rotation;
// 			//out_Rotation.Pitch -= 3000;
// 		//	out_Rotation.Yaw = ( WorldInfo.TimeSeconds * 65536 ) / 10;
// 			out_Location = ( FocusActor.Location + vect(0,0,72) ) - 120 * vector( out_Rotation );
// 		}
// 		return;
// 	}
// }

/**
 * public simulated event PostRenderFor() 
 * Event called by NativePostRenderFor - Draws debug text related to current FocusActor
 * @param	PC                  PlayerController we're rendering for
 * @param	Canvas              HUD Canvas to use
 * @param	CameraPosition      
 * @param	CameraDir
 */
simulated event PostRenderFor( PlayerController PC, Canvas Canvas, vector CameraPosition, vector CameraDir )
{
	local float H, W; 
	local vector SceneLocation;
	local rotator SceneRotation;

	return;

	if( ( FocusActor == none && !bOverrideFocus ) )
	{
		if( PCOwner != none && PCOwner.CheatManager != none )
		{
			KFCheatManager( PCOwner.CheatManager ).DestroyDebugScene();
		}
		else
		{
			DestroyDebugScene();
		}

		return;
	}

	if( !bTextOnly && bOrbitFocus )
	{
		if( CaptureComponent.bEnabled )
		{
			// Don't think detach/attach is necessary here, will double check
			DetachComponent( CaptureComponent );
			GetDebugSceneViewPoint( SceneLocation, SceneRotation );
			CaptureComponent.SetView( SceneLocation, SceneRotation );
			AttachComponent( CaptureComponent );
		}
	}
	else if( !bOrbitFocus ) 
	{
		GetDebugSceneViewPoint( SceneLocation, SceneRotation );
		if( SceneLocation != LastLocation )
		{
		DetachComponent( CaptureComponent );
		//GetDebugSceneViewPoint( SceneLocation, SceneRotation );
		CaptureComponent.SetView( SceneLocation, SceneRotation );
		AttachComponent( CaptureComponent );
		LastLocation = SceneLocation;
		}
	}

// 	if( PC != none && PC.myHUD != none )
// 	{
// 		if( FocusKFPawn != none && FocusController != none )
// 		{
// 			FocusController.KFDrawDebug( KFHUDBase(PC.myHUD), 'Default' );
// 		}
// 	}

	if( !bTextOnly )
	{
		// Draw the debug scene material
		//Canvas.SetPos( 4, 200 );
		Canvas.SetPos( Canvas.ClipX * 0.65f, Canvas.ClipY * 0.075 );	
		H = 256 * ( Canvas.ClipY/768.0 );
		W = 256 * ( Canvas.ClipY/768.0 );
		Canvas.DrawTile( BlackTexture, H, W, 0, 0, 32, 32 );
		Canvas.DrawColor = MakeColor( 255, 255, 255, 255 );
		Canvas.SetPos( Canvas.ClipX * 0.65f, Canvas.ClipY * 0.075 );
		Canvas.DrawMaterialTile( DebugViewMaterialInstance, H, W, 0.0, 0.0, 1.0, 1.0 );
	}
}
DefaultProperties
{
	bAlwaysRelevant=true
	bOrbitFocus=true
	bNoAnimPause=true
	bSetBaseToFocus=true
	bNoDelete=false
	bPostRenderIfNotVisible=true
	bCollideActors=false
	bCollideWorld=false
	bBlockActors=false
	BlackTexture=Texture2D'EngineResources.Black'
	Begin Object Name=SceneCapture2DComponent0
		ClearColor=(R=0,G=0,B=0,A=255)
		Viewmode=SceneCapView_Unlit
		MaxUpdateDist=0.0
		//bSkipRenderingDepthPrepass=false
		bUpdateMatrices=false
		bEnableFog=false
		NearPlane=10
		FarPlane=-1  //1024
	End Object
	CaptureComponent=SceneCapture2DComponent0

	DebugViewMaterial=MaterialInterface'ENG_EngineResources_MAT.Debugging.DebugRenderTargetMaterial'
} 