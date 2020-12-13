//=============================================================================
// KFDebugCameraHUD
//=============================================================================
// HUD used with the ToggleDebugCamera console command
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//=============================================================================
class KFDebugCameraHUD extends KFHUDBase 
	config(Game)
	native(UI);

var bool	bDrawDebugText;
var bool	bDrawAimBasedText;
var bool	bFocusOnSelectedActor;
var KFPawn	SelectedKFPawn;
var	Camera	PlayerCamera;	
var bool	bDisplayHelp;
var float	DebugTextMaxLen;

native function DrawDebugHUDText( String Text, optional color TextColor );

function ToggleHelpDisplay()
{
	bDisplayHelp = !bDisplayHelp;
}

function DisplayHelp()
{
	local Color Greenish;

	Greenish = MakeColor(0,255,50);

	Canvas.Font = class'Engine'.Static.GetSmallFont();
	Canvas.SetPos( (Canvas.ClipX * 0.5f) - 80, Canvas.SizeY * 0.3f );
	Canvas.bCenter = true;
	DrawDebugHUDText( "COMMANDS [work in progress]", Greenish );
	DrawDebugHUDText( "[LEFT CLICK] While aiming at NPC to enable issuing commands to selected NPC:" );
	DrawDebugHUDText( "[RIGHT CLICK] Move or pathfind to click location, if possible" );
	DrawDebugHUDText( "[ESC] Turn off NPC Lock" );
	DrawDebugHUDText( "[END] Toggle PlayersOnly" );
	DrawDebugHUDText( "[DEL] ToggleDebugCamera (exits this mode)" );
	DrawDebugHUDText( "[N] Order selected NPC to attempt to pathfind and move to your pawn location" );
	DrawDebugHUDText( "[Z] Teleport your own pawn to debug camera location" );
	DrawDebugHUDText( "[P] Toggle Sprinting" );
	DrawDebugHUDText( "[R] Rotate toward crosshair dot" );
	DrawDebugHUDText( "[K] Force a combat action" );
	DrawDebugHUDText( "[L] Toggle camera mode, current view or auto-viewing selected NPC" );
	DrawDebugHUDText( "[M] Move NPC forward regardless of obstructions" );
	DrawDebugHUDText( "[H] Toggle displaying this help menu" );
	DrawDebugHUDText( "[O] Toggle displaying debug text" );
}

event PostRender()
{
	local KFDebugCameraController DCC;
	local float				xl,yl,X,Y;
	local String			MyText;
	local TraceHitInfo		HitInfo;
	local byte i;
	local vector			CamLoc, HitLoc, HitNormal, ZeroVec;
	local rotator			CamRot;
	local Actor				HitActor;
	local KFPawn_Monster	HitPawn;

	Super(HUD).PostRender();

	DCC = KFDebugCameraController( PlayerOwner );
	if( DCC != none )
	{
		Canvas.SetDrawColor(0, 0, 255, 255);
		MyText = "KFDebugCameraHUD";
		Canvas.Font = class'Engine'.Static.GetSmallFont();
		
		Canvas.StrLen(MyText, XL, YL);
		X = Canvas.SizeX * 0.05f;
		Y = YL;//*1.67;
		YL += 2*Y;
		Canvas.SetPos( X, YL);
		Canvas.DrawText(MyText, true);

		Canvas.SetDrawColor(128, 128, 128, 255);

		YL += Y;
		if( bDisplayHelp )
		{
			DisplayHelp();
		}
		if( bDrawAimBasedText )
		{
			CamLoc = DCC.PlayerCamera.CameraCache.POV.Location;
			CamRot = DCC.PlayerCamera.CameraCache.POV.Rotation;
			HitActor = Trace(HitLoc, HitNormal, vector(CamRot) * 5000 * 20 + CamLoc, CamLoc, true, ZeroVec, HitInfo);
			DrawDebugLine( HitLoc, HitLoc+HitNormal*30, 255,255,1255 );
			HitPawn = KFPawn_Monster(HitActor);
			if( HitPawn != none )
			{
				DCC.SelectedActor = HitPawn;
				DCC.SelectedKFPawn = HitPawn;
				DCC.bShowSelectedInfo = true;
			}
			else
			{
				DCC.SelectedKFPawn = none;
				DCC.SelectedActor = none;
				DCC.bShowSelectedInfo = false;
			}
		}

		if ( DCC.bShowSelectedInfo == true && DCC.SelectedActor != None )
		{
			YL += Y;
			Canvas.SetPos( X, YL );
			Canvas.DrawText( "--------------------------------------" );
			YL += Y;
			Canvas.SetPos( X, YL );
			Canvas.DrawText( "Selected: '" $ DCC.SelectedActor.Name $ "'" );
			SelectedKFPawn = DCC.SelectedKFPawn;
			if( SelectedKFPawn != none )
			{
				if( SelectedKFPawn.MyKFAIC != none )
				{
					SelectedKFPawn.MyKFAIC.bPostRenderIfNotVisible = true;
					i = PostRenderedActors.Find(SelectedKFPawn.MyKFAIC);
					if( i == INDEX_NONE )
					{
						PostRenderedActors.AddItem(SelectedKFPawn.MyKFAIC);
					}
					bShowOverlays = true;
					//SelectedKFPawn.MyKFAIC.KFDrawDebug( self, 'All' );
				}
			}			
		}
	}
}

function DrawCrosshair()
{
	local byte CrossHairAlpha;

    CrossHairAlpha=255;

    Canvas.SetDrawColor(255, 255, 255, CrossHairAlpha);
    Canvas.SetPos(CenterX, CenterY);
    Canvas.DrawRect(4, 4);

}

DefaultProperties
{
	bHidden=false
	bDrawDebugText=true
	bShowOverlays=true
	bDrawAimBasedText=false
	bDrawCrosshair=true
}
