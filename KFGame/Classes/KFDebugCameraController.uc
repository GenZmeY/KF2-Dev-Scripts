//=============================================================================
// KFDebugCameraController
//=============================================================================
// Controller used when using the ToggleDebugCamera console command
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//=============================================================================

class KFDebugCameraController extends DebugCameraController
	config(Input)
	native(Controller);

/** Debug scene related properties */
var bool					bDebugSceneEnabled;
var KFSceneCaptureDebugCam	DebugSceneCamera;
var bool					bViewFromFocus;
var KFPawn_Monster			SelectedKFPawn;
var bool					bForceSprinting;
var float					SelectedNPCMoveOffset;
var bool					bMoveToActorOnly;
var AIDebugGoal				DebugGoal;
var KFPawn_Monster			DebugTarget;

native function PrimarySelect( vector HitLoc, vector HitNormal, TraceHitInfo HitInfo );

/**
 * Called when an actor has been selected with the secondary key (e.g. right mouse button).
 *
 * @param HitLoc	World-space position of the selection point.
 * @param HitNormal	World-space normal of the selection point.
 * @param HitInfo	Info struct for the selection point.
 */
native function SecondarySelect( vector HitLoc, vector HitNormal, TraceHitInfo HitInfo );

/**
 * Called when the user pressed the unselect key, just before the selected actor is cleared.
 */
native function Unselect();

simulated event PostBeginPlay()
{
	local HUD NewHUD;

	NewHUD = Spawn( HUDClass, self);

	if( OriginalControllerRef != none && OriginalControllerRef.myHUD.PostRenderedActors.Length > 0 )
	{
		NewHUD.PostRenderedActors = OriginalControllerRef.myHUD.PostRenderedActors;
		NewHUD.bShowOverlays = true;
	}

	if( myHUD != none && myHUD.PostRenderedActors.Length > 0 )
	{
		NewHUD.PostRenderedActors = myHUD.PostRenderedActors;
		NewHUD.bShowOverlays = true;
	}

	super(GamePlayerController).PostBeginPlay();

	// if hud is existing, delete it and create new hud for debug camera
	if ( NewHUD != None )
	{
		if( myHUD != none )
		{
			myHUD.Destroy();
		}
		myHUD = NewHuD;
	}
}

/**
 *  Function called on deactivation debug camera controller
 */
function OnDeactivate( PlayerController PC )
{
	if( DrawFrustum != none )
	{
		DrawFrustum.SetHidden( true );
		PC.PlayerCamera.DetachComponent( DrawFrustum );
	}
	PC.SetHidden( true );
	PC.PlayerCamera.SetHidden( true );
}

function DisableDebugCamera()
{
	if( OriginalControllerRef != none )
	{
		if( myHUD.PostRenderedActors.Length > 0 )
		{
			OriginalControllerRef.myHUD.PostRenderedActors = myHUD.PostRenderedActors;
		}

		Super.DisableDebugCamera();
	}
}

/*
 *  Function called on activation debug camera controller
 */
function OnActivate( PlayerController PC )
{
	//super.OnActivate( PC ); //?
	bCollideWorld = false;

	if ( KFDebugCameraHUD(myHUD) != None )
	{
		KFDebugCameraHUD(myHUD).bDrawDebugText = bDrawDebugText;
		if( OriginalControllerRef.myHUD.PostRenderedActors.Length > 0 )
		{
			KFDebugCameraHUD(myHUD).PostRenderedactors = OriginalControllerRef.myHUD.PostRenderedActors;
			KFDebugCameraHUD(myHUD).bShowOverlays = true;
		}
	}

	PC.SetHidden(false);
	PC.PlayerCamera.SetHidden(false);
}

function AddCheats(optional bool bForce)
{
	// Assuming that this never gets called for NM_Client without bForce=true
	if ( (CheatManager == None) && (WorldInfo.Game != None) && WorldInfo.Game.AllowCheats(self) || bForce)
	{
		CheatManager = new(Self) CheatClass;
		CheatManager.InitCheatManager();
		KFCheatManager(CheatManager).bDebugSceneEnabled = bDebugSceneEnabled;
		KFCheatManager(CheatManager).DebugSceneCamera = DebugSceneCamera;
		KFCheatManager(CheatManager).DebugTarget = DebugTarget;
	}
}

function AICommand_Debug GetDebugCommand( KFPawn DebugPawn )
{
	local AICommand_Debug DebugCommand;
	local KFAIController KFAIC;

	if( DebugPawn == none || DebugPawn.Controller == none|| DebugPawn.IsAliveAndWell() )
	{
		return none;
	}
	KFAIC = KFAIController( DebugPawn.Controller );
	if( KFAIC != none && KFAIC.bHasDebugCommand )
	{
		DebugCommand = KFAIC.FindCommandOfClass( class'AICommand_Debug' );
		if( DebugCommand != none )
		{
			return DebugCommand;
		}
	}

	return none;
}

/**
 * Attempts to match the name passed in to a SeqEvent_Console
 * object and then activate it.
 * Overridden to pass in the PlayerController's disembodied pawn while in debug mode
 * since the DebugCameraController has no pawn to send to CheckActivate().
 *
 * @param		eventName - name of the event to cause
 */
unreliable server function ServerCauseEvent(Name EventName)
{
	local array<SequenceObject> AllConsoleEvents;
	local SeqEvent_Console ConsoleEvt;
	local Sequence GameSeq;
	local int Idx;
	local bool bFoundEvt;
	local PlayerController PC;
	local DebugCameraController DCC;

	// Get the gameplay sequence.
	GameSeq = WorldInfo.GetGameSequence();
	if ( (GameSeq != None) && (EventName != '') )
	{
		// Find all SeqEvent_Console objects anywhere.
		GameSeq.FindSeqObjectsByClass(class'SeqEvent_Console', TRUE, AllConsoleEvents);

		// Iterate over them, seeing if the name is the one we typed in.
		for( Idx=0; Idx < AllConsoleEvents.Length; Idx++ )
		{
			ConsoleEvt = SeqEvent_Console(AllConsoleEvents[Idx]);
			if (ConsoleEvt != None &&
				EventName == ConsoleEvt.ConsoleEventName)
			{
				bFoundEvt = TRUE;
				foreach WorldInfo.AllControllers(class'PlayerController', PC)
				{
					if ( PC.bIsPlayer && PC.IsLocalPlayerController() )
					{
						DCC = DebugCameraController(PC);
						if( DCC != none && DCC.OriginalControllerRef != none )
						{
							// activate the event
							ConsoleEvt.CheckActivate( self, DCC.OriginalControllerRef.Pawn );
						}
					}
				}
			}
		}
	}
	if (!bFoundEvt)
	{
		ListConsoleEvents();
	}
}

exec function AIMoveForward()
{
	local AICommand_Debug DebugCommand;

	if( SelectedKFPawn != none )
	{
		DebugCommand = GetDebugCommand( SelectedKFPawn );
		if( DebugCommand != none )
		{
			DebugCommand.Debug_MoveForward();
		}
	}
	else
	{
		KFCheatManager( CheatManager ).AIMoveForward();
	}
}

exec function AIShowSelectedInfo()
{
	bShowSelectedInfo = !bShowSelectedInfo;
}

exec function ToggleDebugViewFocus()
{
	KFDebugCameraHUD(myHUD).bFocusOnSelectedActor = !KFDebugCameraHUD(myHUD).bFocusOnSelectedActor;
	KFDebugCameraHUD(myHUD).PlayerCamera = PlayerCamera;
}

exec function SetMoveOffset( optional float NewOffset=64.f )
{		
	ClientMessage( "MoveOffset of "$NewOffset$" units will be used for selected NPC" );
	SelectedNPCMoveOffset = NewOffset;
}

exec function ToggleSelectedActorView()
{
	bViewFromFocus = !bViewFromFocus;
}

/**
 * public function GetDebugSceneViewPoint() 
 * Used to get the orbit locations for the debug scene camera
 * @param	out_Location    Location of current orbiting view point
 * @param	out_Rotation    Rotation of current orbiting view point
 */
function GetDebugSceneViewPoint( out vector out_Location, out Rotator out_Rotation )
{
	if( SelectedKFPawn != none )
	{
		out_Rotation = SelectedKFPawn.Rotation;
		out_Rotation.Pitch -= 3000;
		out_Rotation.Yaw = ( WorldInfo.TimeSeconds * 65536 ) / 10;
		out_Location = ( SelectedKFPawn.Location + vect(0,0,72) ) - 220 * vector( out_Rotation );
		return;
	}
}

/** If PlayerCamera.bUseClientSideCameraUpdates is set, client will replicate camera positions to the server. */
// @TODO - combine pitch/yaw into one int, maybe also send location compressed
unreliable server function ServerUpdateCamera(vector CamLoc, int CamPitchAndYaw)
{
	local TPOV		NewPOV;

	if( bViewFromFocus && SelectedActor != none )
	{
		GetDebugSceneViewPoint( NewPOV.Location, NewPOV.Rotation );
		PlayerCamera.FillCameraCache(NewPOV);
	}
	else
	{
		super.ServerUpdateCamera( CamLoc, CamPitchAndYaw );
	}
//	NewPOV.Location = CamLoc;

//	NewPOV.Rotation.Yaw = (CamPitchAndYaw >> 16) & 65535;
//	NewPOV.Rotation.Pitch = CamPitchAndYaw & 65535;
}

simulated event GetPlayerViewPoint( out vector out_Location, out Rotator out_Rotation )
{
	local Actor TheViewTarget;

	// sometimes the PlayerCamera can be none and we probably do not want this
	// so we will check to see if we have a CameraClass.  Having a CameraClass is
	// saying:  we want a camera so make certain one exists by spawning one
	if( PlayerCamera == None )
	{
		if( CameraClass != None )
		{
			// Associate Camera with PlayerController
			PlayerCamera = Spawn(CameraClass, Self);
			if( PlayerCamera != None )
			{
				PlayerCamera.InitializeFor( Self );
			}
			else
			{
				`log("Couldn't Spawn Camera Actor for Player!!");
			}
		}
	}
	if( bViewFromFocus && SelectedActor != none )
	{
		GetDebugSceneViewPoint( out_Location, out_Rotation );
//		PlayerCamera.FillCameraCache(NewPOV);
	}
	else
	if( PlayerCamera != None )
	{
		PlayerCamera.GetCameraViewPoint(out_Location, out_Rotation);
	}
	else
	{
		TheViewTarget = GetViewTarget();

		if( TheViewTarget != None )
		{
			out_Location = TheViewTarget.Location;
			out_Rotation = TheViewTarget.Rotation;
		}
		else
		{
			super.GetPlayerViewPoint(out_Location, out_Rotation);
		}
	}
}

function bool NativeInputKey( int ControllerId, name Key, EInputEvent Event, float AmountDepressed = 1.f, bool bGamepad = FALSE )
{
	local vector		CamLoc, ZeroVec;
	local rotator		CamRot;
	local TraceHitInfo	HitInfo;
	local Actor			HitActor;
	local vector		HitLoc, HitNormal;
	local bool			bIsSprinting;

	CamLoc = PlayerCamera.CameraCache.POV.Location;
	CamRot = PlayerCamera.CameraCache.POV.Rotation;

	if ( Key == PrimaryKey )
	{
		HitActor = Trace(HitLoc, HitNormal, vector(camRot) * 5000 * 20 + CamLoc, CamLoc, true, ZeroVec, HitInfo);
		if( HitActor != None && KFPawn_Monster(HitActor) != none )
		{
// 			if( SelectedKFPawn != none )
// 			{
// 				myHuD.PostRenderedActors.RemoveItem(SelectedKFPawn.MyKFAIC);
// 			}
			SelectedActor = HitActor;
			SelectedKFPawn = KFPawn_Monster(HitActor);
			PrimarySelect( HitLoc, HitNormal, HitInfo );
		}
		return true;
	}
	else if( Key == 'P' && Event == IE_Pressed && SelectedActor != none )
	{
		SelectedKFPawn.bIsSprinting = !SelectedKFPawn.bIsSprinting;
		bIsSprinting = SelectedKFPawn.bIsSprinting;
		if( bIsSprinting )
		{
			ClientMessage( SelectedKFPawn$": Sprinting turned on" );
		}
		else
		{
			ClientMessage( SelectedKFPawn$" : Sprinting turned off" );
		}
		return true;
	}
	if( Key == 'L' && Event == IE_Pressed && SelectedActor != none )
	{
		ToggleSelectedActorView();
		return true;
	}
	if( Key == 'T' && Event == IE_Pressed && SelectedActor != none )
	{
		SelectedKFPawn.LookAtPawn(GetALocalPlayerController().Pawn);
		return true;
	}
	if( Key == 'Z' && Event == IE_Pressed )
	{
		KFCheatManager(CheatManager).TeleportPawnToCamera();
		return true;
	}
	if( Key == 'H' && Event == IE_Pressed )
	{
		KFDebugCameraHUD( myHUD ).ToggleHelpDisplay();
		return true;
	}
	if( Key == 'R' && Event == IE_Pressed && SelectedActor != none )
	{
		HitActor = Trace(HitLoc, HitNormal, vector(camRot) * 5000 * 20 + CamLoc, CamLoc, true, ZeroVec, HitInfo);
		SelectedKFPawn.MyKFAIC.Focus = none;		
		SelectedKFPawn.MyKFAIC.SetFocalPoint( HitLoc + HitNormal * 4.f );
		return true;
	}
	if ( Key == SecondaryKey && Event == IE_Pressed && SelectedActor != none )
	{
		HitActor = Trace(HitLoc, HitNormal, vector(camRot) * 5000 * 20 + CamLoc, CamLoc, false, ZeroVec, HitInfo);
		if( HitActor == none || HitActor.bWorldGeometry )
		{
			HitLoc += HitNormal * 4.0;
			SelectedKFPawn.MyKFAIC.StopAllLatentMovement();
			SelectedKFPawn.ZeroMovementVariables();
			if( bMoveToActorOnly )
			{	
				ClientMessage( "Attempting move to goal "$DebugGoal$". You can set bMoveToActorOnly to use move to location method instead." );

				if( DebugGoal == none )
				{
					DebugGoal = Spawn(class'AIDebugGoal', self,, HitLoc );
				}
				else
				{
					DebugGoal.SetLocation( HitLoc );
				}
//				SelectedKFPawn.MyKFAIC.SetMoveGoal( DebugGoal,, false, SelectedNPCMoveOffset, false, true, true );
			}
			else
			{
				ClientMessage( "Attempting move to location "$HitLoc$". You can set bMoveToActorOnly to true to use move to goal actor method instead." );
				//SelectedKFPawn.MyKFAIC.SetMovePoint( HitLoc,, false, SelectedNPCMoveOffset, false, false, true );
			}
		}
		return true;
	}

	return false;

}

DefaultProperties
{
	HUDClass=class'KFDebugCameraHUD'
	CheatClass=class'KFGame.KFCheatManager'
	InputClass=class'KFGame.KFDebugCameraInput'
	bMoveToActorOnly=true
}
