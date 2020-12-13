//=============================================================================
// KFHUDBase
//=============================================================================
// The Killing Floor 2 base HUD class
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
// Based on UDKHUD/UTBASEHUD Copyright 1998-2012 Epic Games, Inc.
//  - Christian "schneidzekk" Schneider 8/22/2012
//=============================================================================

class KFHUDBase extends HUD
	native(UI)
	dependson(KFWeapon)
	config(Game);

`include(KFProfileSettings.uci)

/** Cached a typed Player controller.  Unlike PawnOwner we only set this once in PostBeginPlay */
var KFPlayerController KFPlayerOwner;

/** Cached reference to the GRI */
var KFGameReplicationInfo KFGRI;

var const Texture2D IconHudTexture;
var const Texture2D IconHighLightTexture;

/** Various colors */
var const color BlackColor, GoldColor;
var const color LightGoldColor;

var const color LightGreenColor, YellowColor, OrangeColor, RedHealthColor;

var const color ArmorColor, HealthColor, ClassicArmorColor, ClassicHealthColor, NonPlayerHealth, HealthBeingRegeneratedColor;
var const color PlayerBarBGColor, PlayerBarTextColor, PlayerBarIconColor, PlayerBarShadowColor;
var const color SupplierActiveColor, SupplierUsableColor, SupplierHalfUsableColor;

var const color ZedIconColor;

/** Holds the scaling factor given the current resolution.  This is calculated in PostRender() */
var float ResolutionScale, ResolutionScaleX;

var float VoiceCommsIconHighlightScale;
var int CurrentVoiceCommsHighlightAlpha;
var int CurrentAlphaDelta;

var float MinScreenClampPos;
var float MaxScreenClampPos;

var float MaxDrawDistanceObjective;

var float PrestigeIconScale;

/*********************************************************************************************
 Friendly HUD
********************************************************************************************* */

var config float FriendlyHudScale;

/*********************************************************************************************
 DrawGlowText()
********************************************************************************************* */

var font			GlowFonts[2];	// 0 = the Glow, 1 = Text
var FontRenderInfo	TextRenderInfo;

/** How long should the pulse take total */
var float PulseDuration;
/** When should the pulse switch from Out to in */
var float PulseSplit;
/** How much should the text pulse - NOTE this will be added to 1.0 (so PulseMultipler 0.5 = 1.5) */
var float PulseMultiplier;

/*********************************************************************************************
 Debugging Related (showdebug)
********************************************************************************************* */

var bool	bCachedShowOverlays;
var const	FontRenderInfo Text_NoClipShadowed;

/*********************************************************************************************
 Crosshair - Added by Ramm
********************************************************************************************* */

/** Whether the crosshair should be drawn at this moment */
var	bool	bDrawCrosshair;
/** Whether or not we should force draw the crosshair for debugging (Toggled from exec ToggleCrosshair in KFCheatManager) */
var bool    bForceDrawCrosshair;

/** The target crosshair spread we are blending to */
var float TargetCrossHairMod;
/** The current crosshair spread value */
var float CurrentCrossHairMod;
/** Base size of the weapon crosshair */
var(Crosshair) float BaseCrosshairSize;
/** Used to scale the spread of the crosshair based on the Spread of the weapon */
var(Crosshair)	InterpCurveFloat	CrosshairAccuracyScale;

/** If true, we will alter the crosshair when it's over a friendly */
var bool bCrosshairOnFriendly;

/** Make the crosshair green (found valid friendly) */
var bool bGreenCrosshair;

//-----------------------------------------------------------------------------------------

var 	Texture2d					PlayerStatusBarBGTexture;
var 	const float 				PlayerStatusBarLengthMax;
var 	const float					PlayerStatusIconSize;

/** Classic Health Bar Colors */
var		config bool					ClassicPlayerInfo;

// Players that are not visible
struct sHiddenHumanPawnInfo
{
    var Pawn HumanPawn;
    var PlayerReplicationInfo HumanPRI;
};

var float HumanPlayerIconInterpMult;

/** Texture used for the generic human icon */
var const Texture2D GenericHumanIconTexture;

/** Texture used for the generic zed icon */
var const Texture2D GenericZedIconTexture;

/**
 * Draw a glowing string
 */
native function DrawGlowText(string Text, float X, float Y, optional float MaxHeightInPixels=0.0, optional float PulseTime=-100.0, optional bool bRightJustified);


simulated function PostBeginPlay()
{
	local KFProfileSettings Profile;

	super.PostBeginPlay();

	bDrawCrosshair = class'KFGameEngine'.static.IsCrosshairEnabled();
	bCachedShowOverlays = bShowOverlays;

	KFPlayerOwner = KFPlayerController(PlayerOwner);
	if( KFPlayerOwner != none && KFPlayerOwner.OnlineSub != none )
	{
		Profile = KFProfileSettings(KFPlayerOwner.OnlineSub.PlayerInterface.GetProfileSettings( LocalPlayer(PlayerOwner.Player).ControllerId ));
		if( Profile != none )
		{
			FriendlyHudScale = Profile.GetProfileFloat( KFID_FriendlyHudScale );
			//Clamping the value here in case we receive some crazy number
			FClamp( FriendlyHudScale, 0.25, 1.f);
		}
	}
}

/**
 * Pre-Calculate most common values, to avoid doing 1200 times the same operations
 */
function PreCalcValues()
{
	super.PreCalcValues();

	// Let the PC know that the resolution has changed
	if ( KFPlayerOwner != None )
	{
	   KFPlayerOwner.NotifyResolutionChanged(SizeX, SizeY);
	}
}

/**
  * Reset movies since resolution changed
  */
function ResolutionChanged()
{
}

/**
  * Currently used to let some actors render HUD debug text
  */
function SetShowOverlays( bool bShow )
{
	bShowOverlays = bShow;
}

/**
 * Draw the crosshair
 */
function DrawCrosshair()
{
	local float CrosshairSize;
	local float CrossHairSpread;
	local KFPawn KFP;
	local KFWeapon KFWP;
	local bool bMonsterPawn, bDrawCrosshairNoWeapon;
	local byte CrossHairAlpha;
	local float WeaponAccuracyAdjust;
	local float WeaponRecoilAdjust;
	local float WeaponRecoilMod;
	local KFPerk MyKFPerk;

	CrosshairSize = 6;

	// Only draw the crosshair if we're not in a vehicle and we have a living pawn
    if ( PlayerOwner.Pawn != none && PlayerOwner.Pawn.Health > 0  )
	{
		if (PlayerOwner.ViewTarget != PlayerOwner.Pawn)
		{
			return;
		}

		KFWP = KFWeapon(PlayerOwner.Pawn.Weapon);
		MyKFPerk = KFPlayerController(PlayerOwner).GetPerk();

		bMonsterPawn = PlayerOwner.GetTeamNum() == 255;

		// If our pawn class uses a crosshair regardless of weapon, draw it
		KFP = KFPawn( PlayerOwner.Pawn );
		bDrawCrosshairNoWeapon = KFP.bNeedsCrosshair;

        // Don't draw the crosshair if we're not a monster with a weapon class, or we're not forcing the crosshair for the zed without a weapon
        if( bMonsterPawn )
        {
            if( !bDrawCrosshairNoWeapon )
            {
                return;
            }
        }

		// Don't draw the crosshair if we don't have a weapon, or are using ironsights
		if( !bDrawCrosshairNoWeapon )
		{
	        if( (!bMonsterPawn && MyKFPerk == none) || KFWP == none || !bForceDrawCrosshair && (KFWP.bUsingSights /*|| KFWP.bResting*/) )
			{
	            return;
			}

			// Skip if weapon is missing spread settings
			if ( KFWP.Spread.Length == 0 && !bForceDrawCrosshair )
			{
				return;
			}
		}

		// Don't draw the crosshair if our special move won't allow it
		if( KFP.IsDoingSpecialMove() && !KFP.SpecialMoves[KFP.SpecialMove].CanDrawCrosshair() )
		{
			return;
		}

		if (KFWP != none)
		{
			TargetCrossHairMod = (1.f + KFWP.GetUpgradedSpread()) ** 2;
		}
		else
		{
			TargetCrossHairMod = 1.0;
		}

        // Have the crosshair really small if we are forcing it for debugging
        if( bForceDrawCrosshair )
        {
            TargetCrossHairMod = 0.0000001;
        }
        else if( bDrawCrosshairNoWeapon )
        {
            // Just picked a number for zeds
            TargetCrossHairMod = 0.4;
        }

        // Scale up the crosshair if the player is focusing - TODO: make this more precise based on FOV
        /*if( KFPlayerController(PlayerOwner) != none && KFPlayerController(PlayerOwner).bIsFocusing )
        {
            TargetCrossHairMod *= 2.15;
        }*/

        if( KFWP != none )
        {
	        if( !bForceDrawCrosshair )
	        {
	            WeaponAccuracyAdjust = EvalInterpCurveFloat(CrosshairAccuracyScale, KFWP.GetUpgradedSpread());
	            // Scale spread based on weapon accuracy
	            TargetCrossHairMod *= WeaponAccuracyAdjust;
	        }

	        WeaponRecoilMod = KFWP.RecoilPitchPercentage > KFWP.RecoilYawPercentage ? KFWP.RecoilPitchPercentage : KFWP.RecoilYawPercentage;

	        // Scale up the recoil spread based on how far away the weapon has rotated from center due to recoil
	        WeaponRecoilAdjust = Lerp(1.0,2.5,WeaponRecoilMod);

	        // Scale spread based on weapon recoil
	        TargetCrossHairMod *= WeaponRecoilAdjust;
	    }

        // Figure out the crosshair spread based on the pawn and weapon's state
        if ( MyKFPerk == none || !MyKFPerk.IsShootAndMoveActive() )
        {
	        if( PlayerOwner.Pawn.Physics == PHYS_Falling )
	        {
	        	if( KFWP == none )
	        	{
		            TargetCrossHairMod *= class'KFWeapon'.default.FallingRecoilModifier;
	        	}
	        	else
	        	{
		            TargetCrossHairMod *= KFWP.FallingRecoilModifier;
	        	}
	        }
	        else if( KFP != none && KFP.bIsSprinting )
	        {
	            TargetCrossHairMod *= 3.0;
	        }
	        else
	        {
	            if( PlayerOwner.Pawn.bIsCrouched )
	            {
    	            if( KFWP == none )
    	            {
                        TargetCrossHairMod *= class'KFWeapon'.default.CrouchSpreadMod;
                    }
                    else
                    {
                        TargetCrossHairMod *= KFWP.CrouchSpreadMod;
                    }
	            }

	            if( VSizeSq(PlayerOwner.Pawn.Velocity) > 50 && (KFWP == none || !KFWP.bZoomingOut) )
	            {
    	            if( KFWP == none )
    	            {
                        TargetCrossHairMod *= class'KFWeapon'.default.JoggingRecoilModifier;
                    }
                    else if( !KFWP.bZoomingOut )
                    {
                        TargetCrossHairMod *= KFWP.JoggingRecoilModifier;
                    }
	            }

				if( MyKFPerk != none )
	            {
		            MyKFPerk.ModifySpread(TargetCrossHairMod);
		        }
	        }
	    }

        // Blend the crosshair spread in
        if( CurrentCrossHairMod > TargetCrossHairMod )
        {
            CurrentCrossHairMod -= RenderDelta * 6.0;
            if( CurrentCrossHairMod < TargetCrossHairMod )
            {
                CurrentCrossHairMod = TargetCrossHairMod;
            }
        }
        else if( CurrentCrossHairMod < TargetCrossHairMod )
        {
            CurrentCrossHairMod += RenderDelta * 6.0;
            if( CurrentCrossHairMod > TargetCrossHairMod )
            {
                CurrentCrossHairMod = TargetCrossHairMod;
            }
        }

        // Set the stock crosshair spread and scale it based on screen resolution
        CrosshairSize *= RatioY;
        CrossHairSpread = BaseCrosshairSize * RatioY * CurrentCrossHairMod;

        // Set the crosshair alpha = TODO: Move this to a config?
        CrossHairAlpha=210;

        // If we're doing crosshair debugging then turn on the center dot
        if( bForceDrawCrosshair )
        {
            // Center
            Canvas.SetDrawColor(255, 255, 255, CrossHairAlpha);
    		Canvas.SetPos(CenterX, CenterY);
    		Canvas.DrawRect(1, 1);
		}

        // Left side
		// Drop shadow
        Canvas.SetDrawColor(0, 0, 0, CrossHairAlpha);
		Canvas.SetPos(CenterX - (CrosshairSize + CrossHairSpread) - 1, CenterY - 1);
		Canvas.DrawRect(CrosshairSize + 1, 3);
        // Crosshair
        Canvas.SetDrawColor(255, 255, 255, CrossHairAlpha);
		Canvas.SetPos(CenterX - (CrosshairSize + CrossHairSpread), CenterY);
		Canvas.DrawRect(CrosshairSize, 1);

		// Right side
		// Drop shadow
        Canvas.SetDrawColor(0, 0, 0, CrossHairAlpha);
		Canvas.SetPos(CenterX + CrossHairSpread + 1, CenterY - 1);
		Canvas.DrawRect(CrosshairSize + 1, 3);
        // Crosshair
        Canvas.SetDrawColor(255, 255, 255, CrossHairAlpha);
		Canvas.SetPos(CenterX + CrossHairSpread + 1, CenterY);
		Canvas.DrawRect(CrosshairSize, 1);

        // Top
		// Drop shadow
        Canvas.SetDrawColor(0, 0, 0, CrossHairAlpha);
		Canvas.SetPos(CenterX - 1, CenterY - (CrosshairSize + CrossHairSpread) - 1);
		Canvas.DrawRect(3, CrosshairSize + 1);
        // Crosshair
        Canvas.SetDrawColor(255, 255, 255, CrossHairAlpha);
		Canvas.SetPos(CenterX, CenterY - (CrosshairSize + CrossHairSpread));
		Canvas.DrawRect(1, CrosshairSize);

		// Bottom
		// Drop shadow
        Canvas.SetDrawColor(0, 0, 0, CrossHairAlpha);
		Canvas.SetPos(CenterX - 1, CenterY + CrossHairSpread + 1);
		Canvas.DrawRect(3, CrosshairSize + 1);
        // Crosshair
		Canvas.SetDrawColor(255, 255, 255, CrossHairAlpha);
		Canvas.SetPos(CenterX, CenterY + CrossHairSpread + 1);
		Canvas.DrawRect(1, CrosshairSize);
	}
}

/*
 * Complete close of Scoreboard.  Fired from Flash
 * when the "close" animation is finished.
 */
function OnCloseAnimComplete()
{
}

/*
 * Complete open of Scoreboard.  Fired from Flash
 * when the "open" animation is finished.
 */
function OnOpenAnimComplete()
{
}

/**
  * Destroy existing Movies
  */
function RemoveMovies()
{
}

/**
 *  Toggles visibility of normal in-game HUD
 */
function SetVisible(bool bNewVisible)
{
	bShowHUD = bNewVisible;
}

/**
  * Called when pause menu is opened
  */
function CloseOtherMenus();

/*
 * Toggle the Pause Menu on or off.
 *
 */
function TogglePauseMenu()
{
}

/*
 * Complete necessary actions for OnPauseMenuClose.
 * Fired from Flash.
 */
function CompletePauseMenuClose()
{
}

/* toggles displaying scoreboard (used by console controller)
*/
exec function ReleaseShowScores()
{
}

/**
  * Returns the index of the local player that owns this HUD
  */
function int GetLocalPlayerOwnerIndex()
{
	return class'Engine'.static.GetEngine().GamePlayers.Find(LocalPlayer(PlayerOwner.Player));
}

/*
 * SetShowScores() override to display GFx Scoreboard.
 * If the scoreboard has been loaded, this will play the appropriate
 * Flash animation.
 */
exec function SetShowScores(bool bEnableShowScores)
{
}

/**
 * Toggles display of the leaderboard
 */
exec function ToggleLeaderboard()
{
}

/**
 * Displays/closes the leaderboard
 */
exec function SetShowLeaderboard(bool bEnableLeaderboard)
{
}

//Given a input command of the form GBA_ and its mapping store that in a lookup for future use
function DrawToolTip(Canvas Cvs, PlayerController PC, string Command, float X, float Y, float U, float V, float UL, float VL, float ResScale, optional Texture2D IconTexture = default.IconHudTexture, optional float Alpha=1.0)
{
}

function bool CheckCrosshairOnFriendly()
{
	return true;
}

simulated function DrawShadowedTile(texture2D Tex, float X, float Y, float XL, float YL, float U, float V, float UL, float VL, Color TileColor, Optional bool bScaleToRes)
{
	local Color B;

	B = BlackColor;
	B.A = TileColor.A;

	XL *= (bScaleToRes) ? ResolutionScale : 1.0;
	YL *= (bScaleToRes) ? ResolutionScale : 1.0;

	Canvas.SetPos(X+1,Y+1);
	Canvas.DrawColor = B;
	Canvas.DrawTile(Tex,XL,YL,U,V,UL,VL);
	Canvas.SetPos(X,Y);
	Canvas.DrawColor = TileColor;
	Canvas.DrawTile(Tex,XL,YL,U,V,UL,VL);
}

simulated function DrawShadowedStretchedTile(texture2D Tex, float X, float Y, float XL, float YL, float U, float V, float UL, float VL, Color TileColor, Optional bool bScaleToRes)
{
	local LinearColor C,B;

	C = ColorToLinearColor(TileColor);
	B = ColorToLinearColor(BlackColor);
	B.A = C.A;

	XL *= (bScaleToRes) ? ResolutionScale : 1.0;
	YL *= (bScaleToRes) ? ResolutionScale : 1.0;

	Canvas.SetPos(X+1,Y+1);
	Canvas.DrawTileStretched(Tex,XL,YL,U,V,UL,VL,B);
	Canvas.SetPos(X,Y);
	Canvas.DrawColor = TileColor;
	Canvas.DrawTileStretched(Tex,XL,YL,U,V,UL,VL,C);
}

simulated function DrawShadowedRotatedTile(texture2D Tex, Rotator Rot, float X, float Y, float XL, float YL, float U, float V, float UL, float VL, Color TileColor, Optional bool bScaleToRes)
{
	local Color B;

	B = BlackColor;
	B.A = TileColor.A;

	XL *= (bScaleToRes) ? ResolutionScale : 1.0;
	YL *= (bScaleToRes) ? ResolutionScale : 1.0;

	Canvas.SetPos(X+1,Y+1);
	Canvas.DrawColor = B;
	Canvas.DrawRotatedTile(Tex,Rot,XL,YL,U,V,UL,VL);
	Canvas.SetPos(X,Y);
	Canvas.DrawColor = TileColor;
	Canvas.DrawRotatedTile(Tex,Rot,XL,YL,U,V,UL,VL);
}

/**
 * @brief Main canvas draw function
 */
function DrawHUD()
{
	local KFPawn_Human KFPH;
	local KFPawn_Scripted KFPS;
	local vector ViewLocation, ViewVector, PlayerPartyInfoLocation;
	local rotator ViewRotation;
    local array<PlayerReplicationInfo> VisibleHumanPlayers;
    local array<sHiddenHumanPawnInfo> HiddenHumanPlayers;
	local float ThisDot;
	local vector TargetLocation;
	local Actor LocActor;

    // Draw weapon HUD underneath everything else
    if( KFPlayerOwner != none && KFPlayerOwner.Pawn != none && KFPlayerOwner.Pawn.Weapon != none )
    {
    	KFPlayerOwner.Pawn.Weapon.DrawHUD( self, Canvas );
    }

	super.DrawHUD();

    // Cache GRI
    if( KFGRI == none )
    {
        KFGRI = KFGameReplicationInfo( WorldInfo.GRI );
    }

    // Don't draw canvas HUD in cinematic mode
	if( KFPlayerOwner != none && KFPlayerOwner.bCinematicMode )
	{
		return;
	}
	LocActor = KFPlayerOwner.ViewTarget != none ? KFPlayerOwner.ViewTarget : KFPlayerOwner;

	// Draw the crosshair for casual mode
	if( KFPlayerOwner != none && (bDrawCrosshair || bForceDrawCrosshair || KFPlayerOwner.GetTeamNum() == 255) )
	{
        DrawCrosshair();
    }

    // Friendly player status
    if( PlayerOwner.GetTeamNum() == 0 )
    {
		if( KFPlayerOwner != none )
		{
		    KFPlayerOwner.GetPlayerViewPoint( ViewLocation, ViewRotation );
		}
		ViewVector = vector(ViewRotation);

	    Canvas.EnableStencilTest(true);
		foreach WorldInfo.AllPawns( class'KFPawn_Human', KFPH )
		{
			if( KFPH.IsAliveAndWell() && KFPH != KFPlayerOwner.Pawn && KFPH.Mesh.SkeletalMesh != none && KFPH.Mesh.bAnimTreeInitialised )
			{
				PlayerPartyInfoLocation = KFPH.Mesh.GetPosition() + ( KFPH.CylinderComponent.CollisionHeight * vect(0,0,1) );
				if(`TimeSince(KFPH.Mesh.LastRenderTime) < 0.2f && Normal(PlayerPartyInfoLocation - ViewLocation) dot ViewVector > 0.f )
				{
					if( DrawFriendlyHumanPlayerInfo(KFPH) )
					{
						VisibleHumanPlayers.AddItem( KFPH.PlayerReplicationInfo );
					}
					else
					{
						HiddenHumanPlayers.Insert( 0, 1 );
                    	HiddenHumanPlayers[0].HumanPawn = KFPH;
                    	HiddenHumanPlayers[0].HumanPRI = KFPH.PlayerReplicationInfo;
					}
				}
				else
                {
                    HiddenHumanPlayers.Insert( 0, 1 );
                    HiddenHumanPlayers[0].HumanPawn = KFPH;
                    HiddenHumanPlayers[0].HumanPRI = KFPH.PlayerReplicationInfo;
                }
			}
		}

		foreach WorldInfo.AllPawns(class'KFPawn_Scripted', KFPS)
		{
			if (KFPS.ShouldShowOnHUD())
			{
				PlayerPartyInfoLocation = KFPS.Mesh.GetPosition() + (KFPS.CylinderComponent.CollisionHeight * vect(0,0,1));
				DrawScriptedPawnInfo(KFPS, Normal(PlayerPartyInfoLocation - ViewLocation) dot ViewVector, `TimeSince(KFPS.Mesh.LastRenderTime) < 0.2f);
			}
		}

		if( !KFGRI.bHidePawnIcons )
		{
			// Draw hidden players
			CheckAndDrawHiddenPlayerIcons( VisibleHumanPlayers, HiddenHumanPlayers );

			// Draw last remaining zeds
			CheckAndDrawRemainingZedIcons();

			//Draw our current objective location
			if(KFGRI.CurrentObjective != none && KFGRI.ObjectiveInterface != none)
			{
				KFGRI.ObjectiveInterface.DrawHUD(self, Canvas);

				TargetLocation = KFGRI.ObjectiveInterface.GetIconLocation();
				ThisDot = Normal((TargetLocation + (class'KFPawn_Human'.default.CylinderComponent.CollisionHeight * vect(0, 0, 1))) - ViewLocation) dot ViewVector;

				if (ThisDot > 0 &&
					KFGRI.ObjectiveInterface.ShouldShowObjectiveHUD() &&
					(!KFGRI.ObjectiveInterFace.HasObjectiveDrawDistance() || VSizeSq(TargetLocation - LocActor.Location) < MaxDrawDistanceObjective))
				{
					DrawObjectiveHUD();
				}
			}
		}

		Canvas.EnableStencilTest(false);
	}
}

simulated function DrawPerkIcons(KFPawn_Human KFPH, float PerkIconSize, float PerkIconPosX, float PerkIconPosY, float SupplyIconPosX, float SupplyIconPosY, bool bDropShadow)
{
	local byte PrestigeLevel;
	local KFPlayerReplicationInfo KFPRI;
	local color TempColor;
	local float ResModifier;

	KFPRI = KFPlayerReplicationInfo(KFPH.PlayerReplicationInfo);

	if (KFPRI == none)
	{
		return;
	}

	PrestigeLevel = KFPRI.GetActivePerkPrestigeLevel();
	ResModifier = WorldInfo.static.GetResolutionBasedHUDScale() * FriendlyHudScale;

	if (KFPRI.CurrentVoiceCommsRequest == VCT_NONE && KFPRI.CurrentPerkClass != none && PrestigeLevel > 0)
	{
		Canvas.SetPos(PerkIconPosX, PerkIconPosY);
		Canvas.DrawTile(KFPRI.CurrentPerkClass.default.PrestigeIcons[PrestigeLevel - 1], PerkIconSize, PerkIconSize, 0, 0, 256, 256);
	}

	if (PrestigeLevel > 0)
	{																//icon slot in image is not centered
		Canvas.SetPos(PerkIconPosX + (PerkIconSize * (1 - PrestigeIconScale)) / 2, PerkIconPosY + PerkIconSize * 0.05f);
		Canvas.DrawTile(KFPRI.GetCurrentIconToDisplay(), PerkIconSize * PrestigeIconScale, PerkIconSize * PrestigeIconScale, 0, 0, 256, 256);
	}
	else
	{
		Canvas.SetPos(PerkIconPosX, PerkIconPosY);
		Canvas.DrawTile(KFPRI.GetCurrentIconToDisplay(), PerkIconSize, PerkIconSize, 0, 0, 256, 256);
	}

	if (KFPRI.PerkSupplyLevel > 0 && KFPRI.CurrentPerkClass.static.GetInteractIcon() != none)
	{
		if (!bDropShadow)
		{
			if (KFPRI.PerkSupplyLevel == 2)
			{
				if (KFPRI.bPerkPrimarySupplyUsed && KFPRI.bPerkSecondarySupplyUsed)
				{
					TempColor = SupplierActiveColor;
				}
				else if (KFPRI.bPerkPrimarySupplyUsed || KFPRI.bPerkSecondarySupplyUsed)
				{
					TempColor = SupplierHalfUsableColor;
				}
				else
				{
					TempColor = SupplierUsableColor;
				}
			}
			else if (KFPRI.PerkSupplyLevel == 1)
			{
				TempColor = KFPRI.bPerkPrimarySupplyUsed ? SupplierActiveColor : SupplierUsableColor;
			}

			Canvas.SetDrawColorStruct(TempColor);
		}

		Canvas.SetPos(SupplyIconPosX, SupplyIconPosY); //offset so that supplier icon shows up on the correct side of the player's health bar
		Canvas.DrawTile(KFPRI.CurrentPerkClass.static.GetInteractIcon(), (PlayerStatusIconSize * 0.75) * ResModifier, (PlayerStatusIconSize * 0.75) * ResModifier, 0, 0, 256, 256);
	}
}

/**
 * @brief Draws name, perk etc over a human player's head
 *
 * @param KFPH Human player's pawn
 * @return true if draw was successful
 */
simulated function bool DrawFriendlyHumanPlayerInfo( KFPawn_Human KFPH )
{
	local float Percentage, PercentageHealth, PercentageHealthMissing, PercentageHealthToRegen;
	local float BarHeight, BarLength;
	local vector ScreenPos, TargetLocation;
	local KFPlayerReplicationInfo KFPRI;
	local FontRenderInfo MyFontRenderInfo;
	local float FontScale;
	local float ResModifier;
	local float PerkIconPosX, PerkIconPosY, SupplyIconPosX, SupplyIconPosY, PerkIconSize;
	local color CurrentArmorColor, CurrentHealthColor;


	ResModifier = WorldInfo.static.GetResolutionBasedHUDScale() * FriendlyHudScale;

	KFPRI = KFPlayerReplicationInfo(KFPH.PlayerReplicationInfo);

	if( KFPRI == none )
	{
		return false;
	}

	MyFontRenderInfo = Canvas.CreateFontRenderInfo( true );
	BarLength = FMin(PlayerStatusBarLengthMax * (Canvas.ClipX / 1024.f), PlayerStatusBarLengthMax) * ResModifier;
	BarHeight = FMin(8.f * (Canvas.ClipX / 1024.f), 8.f) * ResModifier;

	TargetLocation = KFPH.Mesh.GetPosition() + ( KFPH.CylinderComponent.CollisionHeight * vect(0,0,2.5f) );
	ScreenPos = Canvas.Project( TargetLocation );
	if( ScreenPos.X < 0 || ScreenPos.X > Canvas.ClipX || ScreenPos.Y < 0 || ScreenPos.Y > Canvas.ClipY )
	{
		return false;
	}

	//Draw player name (Top)
	FontScale = class'KFGameEngine'.Static.GetKFFontScale() * FriendlyHudScale;
	Canvas.Font = class'KFGameEngine'.Static.GetKFCanvasFont();

	// drop shadow for player name text
	Canvas.SetDrawColorStruct(PlayerBarShadowColor);
	Canvas.SetPos(ScreenPos.X - (BarLength * 0.5f) + 1, ScreenPos.Y + 8);
	Canvas.DrawText(KFPRI.PlayerName, , FontScale, FontScale, MyFontRenderInfo);

	Canvas.SetDrawColorStruct(PlayerBarTextColor);
	Canvas.SetPos(ScreenPos.X - (BarLength * 0.5f), ScreenPos.Y + 7);
	Canvas.DrawText(KFPRI.PlayerName, , FontScale, FontScale, MyFontRenderInfo);

	//Draw armor bar
	Percentage = FMin(float(KFPH.Armor) / float(KFPH.MaxArmor), 100);
	CurrentArmorColor = ClassicPlayerInfo ? ClassicArmorColor : ArmorColor;
	DrawKFBar(Percentage, BarLength, BarHeight, ScreenPos.X - (BarLength * 0.5f), ScreenPos.Y + BarHeight + (36 * FontScale * ResModifier), CurrentArmorColor);



	//Draw health bar
	PercentageHealth = FMin(float(KFPH.Health) / float(KFPH.HealthMax), 100);
	CurrentHealthColor = ClassicPlayerInfo ? ClassicHealthColor : HealthColor;
	DrawKFBar(PercentageHealth, BarLength, BarHeight, ScreenPos.X - (BarLength * 0.5f), ScreenPos.Y + BarHeight * 2 + (36 * FontScale * ResModifier), CurrentHealthColor);


	//Draw health being regenerated bar
	PercentageHealthToRegen = FMin(float(KFPH.HealthToRegen) / float(KFPH.HealthMax), 100);
	PercentageHealthMissing = FMin((float(KFPH.HealthMax) - float(KFPH.Health)) / float(KFPH.HealthMax), 100);
	PercentageHealthToRegen = FMin(PercentageHealthToRegen, PercentageHealthMissing);
	CurrentHealthColor = HealthBeingRegeneratedColor;
	DrawKFBar(1, PercentageHealthToRegen * BarLength, BarHeight, ScreenPos.X + BarLength * (PercentageHealth - 0.5f), ScreenPos.Y + BarHeight * 2 + (36 * FontScale * ResModifier), HealthBeingRegeneratedColor);

	if( KFPRI.CurrentPerkClass == none )
	{
		return false;
	}

	// drop shadow for perk name text
	Canvas.SetDrawColorStruct(PlayerBarShadowColor);
	Canvas.SetPos(ScreenPos.X - (BarLength * 0.5f) + 1, ScreenPos.Y + BarHeight * 3 + (36 * FontScale * ResModifier) + 1);
	Canvas.DrawText(KFPRI.GetActivePerkLevel() @KFPRI.CurrentPerkClass.default.PerkName, , FontScale, FontScale, MyFontRenderInfo);

	//Draw perk level and name text
	Canvas.SetDrawColorStruct(PlayerBarTextColor);
	Canvas.SetPos(ScreenPos.X - (BarLength * 0.5f), ScreenPos.Y + BarHeight * 3 + (36 * FontScale * ResModifier));
	Canvas.DrawText(KFPRI.GetActivePerkLevel() @KFPRI.CurrentPerkClass.default.PerkName, , FontScale, FontScale, MyFontRenderInfo);

	// drop shadow for perk icon
	Canvas.SetDrawColorStruct(PlayerBarShadowColor);
	PerkIconSize = PlayerStatusIconSize * ResModifier;
	PerkIconPosX = ScreenPos.X - (BarLength * 0.5f) - PerkIconSize + 1;
	PerkIconPosY = ScreenPos.Y + (36 * FontScale * ResModifier) + 1;
	SupplyIconPosX = ScreenPos.X + (BarLength * 0.5f) + 1;
	SupplyIconPosY = PerkIconPosY + 4 * ResModifier;
	DrawPerkIcons(KFPH, PerkIconSize, PerkIconPosX, PerkIconPosY, SupplyIconPosX, SupplyIconPosY, true);

	//draw perk icon
	Canvas.SetDrawColorStruct(PlayerBarIconColor);
	PerkIconPosX = ScreenPos.X - (BarLength * 0.5f) - PerkIconSize;
	PerkIconPosY = ScreenPos.Y + (36 * FontScale * ResModifier);
	SupplyIconPosX = ScreenPos.X + (BarLength * 0.5f);
	SupplyIconPosY = PerkIconPosY + 4 * ResModifier;
	DrawPerkIcons(KFPH, PerkIconSize, PerkIconPosX, PerkIconPosY, SupplyIconPosX, SupplyIconPosY, false);

	return true;
}

simulated function bool DrawScriptedPawnInfo(KFPawn_Scripted KFPS, float NormalizedAngle, bool bRendered)
{
	local float Percentage;
	local float BarHeight, BarLength;
	local vector ScreenPos, TargetLocation;
	local float FontScale;
	local float ResModifier;

	if (KFPS.bHidden)
	{
		//do not draw a hidden actor
		return false;
	}

	ResModifier = WorldInfo.static.GetResolutionBasedHUDScale() * FriendlyHudScale;

	BarLength = FMin(PlayerStatusBarLengthMax * (Canvas.ClipX / 1024.f), PlayerStatusBarLengthMax) * ResModifier;
	BarHeight = FMin(8.f * (Canvas.ClipX / 1024.f), 8.f) * ResModifier;

	TargetLocation = KFPS.Mesh.GetPosition() + (KFPS.CylinderComponent.CollisionHeight * vect(0,0,2.5f));
	ScreenPos = Canvas.Project(TargetLocation);

	if (NormalizedAngle > 0)
	{
		if (ScreenPos.X < 0 || ScreenPos.X > Canvas.ClipX || ScreenPos.Y < 0 || ScreenPos.Y > Canvas.ClipY)
		{
			ScreenPos.x = Canvas.ClipX - ScreenPos.x;
			ScreenPos = GetClampedScreenPosition(ScreenPos);
			//return false;
		}
		else
		{
			ScreenPos.x = FClamp(ScreenPos.x, PlayerStatusIconSize, Canvas.ClipX - PlayerStatusIconSize);
		}
	}
	else
	{
		ScreenPos = GetClampedScreenPosition(ScreenPos);
	}

	//Draw health bar
	FontScale = class'KFGameEngine'.Static.GetKFFontScale() * FriendlyHudScale;
	Percentage = FMin(float(KFPS.Health) / float(KFPS.HealthMax), 1);

	// Make sure that the entire health bar is on screen
	ScreenPos.X = FClamp(ScreenPos.X, BarLength * 0.5f, Canvas.ClipX - BarLength * 0.5f);

	DrawKFBar(Percentage, BarLength, BarHeight, ScreenPos.X - (BarLength * 0.5f), ScreenPos.Y + BarHeight * 2 + (36 * FontScale * ResModifier), GetHealthStateColor(KFPS));

	if (KFGRI != none && KFGRI.ObjectiveInterface != none)
	{
		Canvas.SetDrawColorStruct(PlayerBarShadowColor);
	}
	Canvas.SetPos(ScreenPos.X - PlayerStatusIconSize * ResModifier * 0.5f + 1, ScreenPos.Y - (PlayerStatusIconSize * ResModifier) + 1);
	Canvas.DrawTile(KFPS.GetStateIconTexture(), PlayerStatusIconSize * ResModifier, PlayerStatusIconSize * ResModifier, 0, 0, 256, 256);

	if (KFGRI != none && KFGRI.ObjectiveInterface != none)
	{
		Canvas.SetDrawColorStruct(KFGRI.ObjectiveInterface.GetIconColor());
	}
	Canvas.SetPos(ScreenPos.X - PlayerStatusIconSize * ResModifier * 0.5f, ScreenPos.Y - (PlayerStatusIconSize * ResModifier));
	Canvas.DrawTile(KFPS.GetStateIconTexture(), PlayerStatusIconSize * ResModifier, PlayerStatusIconSize * ResModifier, 0, 0, 256, 256);
	return true;
}

simulated function color GetHealthStateColor(const out KFPawn_Scripted KFPS)
{
	if (KFPS != none)
	{
		return KFPS.ScriptedCharArch.States[KFPS.CurrentState].PawnHealthBarColor;
	}
}

simulated function bool DrawObjectiveHUD()
{
	local float Percentage;
	local float BarHeight, BarLength, IconCenteringLength;
	local vector ScreenPos, TargetLocation;
	local float ResModifier;

	ResModifier = WorldInfo.static.GetResolutionBasedHUDScale() * FriendlyHudScale;

	//Get actor from GRI
	if(KFGRI.ObjectiveInterface == none)
	{
		return false;
	}

	if (!KFGRI.ObjectiveInterface.ShouldDrawIcon())
	{
		return false;
	}

	TargetLocation = KFGRI.ObjectiveInterface.GetIconLocation();
	ScreenPos = Canvas.Project( TargetLocation );
	if( ScreenPos.X < 0 || ScreenPos.X > Canvas.ClipX || ScreenPos.Y < 0 || ScreenPos.Y > Canvas.ClipY )
	{
		//if it is off screen, do not render
		return false;
	}

	//Draw progress bar
	if (KFGRI.ObjectiveInterface.UsesProgress())
	{
		BarLength = FMin(PlayerStatusBarLengthMax * (Canvas.ClipX / 1024.f), PlayerStatusBarLengthMax) * ResModifier;
		BarHeight = FMin(8.f * (Canvas.ClipX / 1024.f), 8.f) * ResModifier;
		Percentage = FMin(KFGRI.ObjectiveInterface.GetProgress(), 1);
		DrawKFBar(Percentage, BarLength, BarHeight, ScreenPos.X - (BarLength * 0.5f), ScreenPos.Y, NonPlayerHealth);
	}
	else
	{
		// if not using the progress bar, center the remaining icon
		IconCenteringLength = PlayerStatusIconSize * ResModifier * 0.5;
	}

	//draw objective icon
	if (KFGRI.ObjectiveInterface.GetIcon() != none)
	{
		Canvas.SetDrawColorStruct(PlayerBarShadowColor);
		Canvas.SetPos((ScreenPos.X - (BarLength * 0.75) - IconCenteringLength) + 1, (ScreenPos.Y - BarHeight * 2.0) + 1);
		Canvas.DrawTile(KFGRI.ObjectiveInterface.GetIcon(), PlayerStatusIconSize * ResModifier, PlayerStatusIconSize * ResModifier, 0, 0, 256, 256);

		Canvas.SetDrawColorStruct(KFGRI.ObjectiveInterface.GetIconColor());
		Canvas.SetPos(ScreenPos.X - (BarLength * 0.75) - IconCenteringLength, ScreenPos.Y - BarHeight * 2.0);
		Canvas.DrawTile(KFGRI.ObjectiveInterface.GetIcon(), PlayerStatusIconSize * ResModifier, PlayerStatusIconSize * ResModifier, 0, 0, 256, 256);
	}
	return true;
}

/**
 * @brief Generic function to draw health and armor bars
 *
 * @param BarPercentage Fill percentage
 * @param BarLength total length
 * @param BarHeight total height
 * @param XPos Horizontal screen position
 * @param YPos Vertical screen position
 * @param BarColor The bar's foreground color
 */
simulated function DrawKFBar( float BarPercentage, float BarLength, float BarHeight, float XPos, float YPos, Color BarColor )
{
	//background for status bar
	Canvas.SetDrawColorStruct(PlayerBarBGColor);
	Canvas.SetPos(XPos, YPos);
	Canvas.DrawTile(PlayerStatusBarBGTexture, BarLength, BarHeight, 0, 0, 32, 32);

	//Forground for status bar.
	Canvas.SetDrawColorStruct(BarColor);
	Canvas.SetPos(XPos, YPos + 1);  // Adjust pos for border
	Canvas.DrawTile(PlayerStatusBarBGTexture, (BarLength - 2.0) * BarPercentage, BarHeight - 2.0, 0, 0, 32, 32);
}

/**
 * @brief Checks if hidden player's icon should be drawn
 *
 * @param VisibleHumanPlayers A list of visible players
 * @param HiddenHumanPlayers A list of hidden players
 */
simulated function CheckAndDrawHiddenPlayerIcons( array<PlayerReplicationInfo> VisibleHumanPlayers, array<sHiddenHumanPawnInfo> HiddenHumanPlayers )
{
 	local int i, HiddenHumanIndex;
 	local PlayerReplicationInfo PRI;
    local vector ViewLocation, ViewVector, PawnLocation;
    local rotator ViewRotation;
 	local KFPlayerReplicationInfo KFPRI;

 	// GRI hasn't replicated yet
 	if( WorldInfo.GRI == none )
 	{
 		return;
 	}

 	if( KFPlayerOwner.PlayerCamera != none )
    {
        KFPlayerOwner.PlayerCamera.GetCameraViewPoint( ViewLocation, ViewRotation );
    }

    ViewVector = vector(ViewRotation);

    for( i = 0; i < WorldInfo.GRI.PRIArray.Length; i++ )
    {
        PawnLocation = vect(0,0,0);

        // Avoid casting until we've got some simple checks out of the way
        PRI = WorldInfo.GRI.PRIArray[i];

       if( VisibleHumanPlayers.Find( PRI ) != INDEX_NONE ||
        	KFPlayerOwner.PlayerReplicationInfo == PRI ||
        	PRI.GetTeamNum() == 255 )
        {
            continue;
        }

        // Use the real pawn location if the pawn is still relevant
        HiddenHumanIndex = HiddenHumanPlayers.Find( 'HumanPRI', PRI );
        if( HiddenHumanIndex != INDEX_NONE
        	&& HiddenHumanPlayers[HiddenHumanIndex].HumanPawn != none
        	&& HiddenHumanPlayers[HiddenHumanIndex].HumanPawn.Mesh.SkeletalMesh != none
        	&& HiddenHumanPlayers[HiddenHumanIndex].HumanPawn.Mesh.bAnimTreeInitialised )
        {
            PawnLocation = HiddenHumanPlayers[HiddenHumanIndex].HumanPawn.Mesh.GetPosition();
            KFPRI = KFPlayerReplicationInfo( PRI );
            if( KFPRI != none )
            {
            	KFPRI.SetSmoothedPawnIconLocation( PawnLocation );
            }
        }

        // Otherwise we'll use our replicated location
        if( IsZero(PawnLocation) )
        {
            KFPRI = KFPlayerReplicationInfo( PRI );
            if( KFPRI != none )
            {
	            PawnLocation = KFPRI.GetSmoothedPawnIconLocation( HumanPlayerIconInterpMult );
	            if( IsZero(PawnLocation) || KFPRI.PlayerHealth <= 0 )
	            {
	                continue;
	            }
	        }
	        else
	        {
	        	continue;
	        }
        }

        DrawHiddenHumanPlayerIcon( PRI, PawnLocation, Normal((PawnLocation + (class'KFPawn_Human'.default.CylinderComponent.CollisionHeight * vect(0, 0, 2))) - ViewLocation) dot ViewVector);
    }
}

/**
 * @brief Draws an icon when human players are hidden but in the field of view
 *
 * @param PRI Player's PlayerReplicationInfo
 * @param IconWorldLocation The "player's" location in the world
 * @Note:This is the one we want to clamp
 */
function DrawHiddenHumanPlayerIcon( PlayerReplicationInfo PRI, vector IconWorldLocation, float NormalizedAngle)
{
    local vector ScreenPos;
    local float IconSizeMult;
    local KFPlayerReplicationInfo KFPRI;
    local Texture2D PlayerIcon;
	local float ResModifier;

	ResModifier = WorldInfo.static.GetResolutionBasedHUDScale() * FriendlyHudScale;

    KFPRI = KFPlayerReplicationInfo(PRI);
    if( KFPRI == none )
    {
    	return;
    }

	ScreenPos = Canvas.Project(IconWorldLocation + class'KFPawn_Human'.default.CylinderComponent.CollisionHeight * vect(0, 0, 2));
	// Fudge by icon size
	IconSizeMult = (PlayerStatusIconSize * 0.8) * ResModifier;
	ScreenPos.X -= IconSizeMult;
	ScreenPos.Y -= IconSizeMult;

	if (NormalizedAngle > 0)
	{
		if (ScreenPos.X < 0 || ScreenPos.X > Canvas.ClipX || ScreenPos.Y < 0 || ScreenPos.Y > Canvas.ClipY )
		{
			if (KFPRI.CurrentVoiceCommsRequest != VCT_NONE)
			{
				if (CurrentVoiceCommsHighlightAlpha >= 255)
				{
					CurrentAlphaDelta = -5;
				}
				else if (CurrentVoiceCommsHighlightAlpha <= 0)
				{
					CurrentAlphaDelta = 5;
				}
				ScreenPos.X = Canvas.ClipX - ScreenPos.x;
				ScreenPos = GetClampedScreenPosition(ScreenPos);
				CurrentVoiceCommsHighlightAlpha += CurrentAlphaDelta;
				clamp(CurrentVoiceCommsHighlightAlpha, 0, 255);
				Canvas.SetDrawColor(255, 255, 255, CurrentVoiceCommsHighlightAlpha);
				Canvas.SetPos(ScreenPos.X - (IconSizeMult * VoiceCommsIconHighlightScale / 2), ScreenPos.Y - (IconSizeMult * VoiceCommsIconHighlightScale / 2));
				Canvas.DrawTile(IconHighLightTexture, IconSizeMult + (IconSizeMult * VoiceCommsIconHighlightScale), IconSizeMult + (IconSizeMult * VoiceCommsIconHighlightScale), 0, 0, 128, 128);

			}
			else
			{
				return;
			}
		}

	}
	else if (KFPRI.CurrentVoiceCommsRequest != VCT_NONE)
	{
		if (CurrentVoiceCommsHighlightAlpha >= 255)
		{
			CurrentAlphaDelta = -5;
		}
		else if (CurrentVoiceCommsHighlightAlpha <= 0)
		{
			CurrentAlphaDelta = 5;
		}
		CurrentVoiceCommsHighlightAlpha += CurrentAlphaDelta;
		clamp(CurrentVoiceCommsHighlightAlpha, 0, 255);
		ScreenPos = GetClampedScreenPosition(ScreenPos);
		Canvas.SetDrawColor(255, 255, 255, CurrentVoiceCommsHighlightAlpha);
		Canvas.SetPos(ScreenPos.X - (IconSizeMult * VoiceCommsIconHighlightScale / 2), ScreenPos.Y - (IconSizeMult * VoiceCommsIconHighlightScale / 2));
		Canvas.DrawTile(IconHighLightTexture, IconSizeMult + (IconSizeMult * VoiceCommsIconHighlightScale), IconSizeMult + (IconSizeMult * VoiceCommsIconHighlightScale), 0, 0, 128, 128);
	}
	else
	{
		return;
	}

    PlayerIcon = PlayerOwner.GetTeamNum() == 0 ? KFPRI.GetCurrentIconToDisplay() : GenericHumanIconTexture;

    // Draw human icon
	Canvas.SetDrawColor(0, 0, 0, 255);
	Canvas.SetPos(ScreenPos.X + 1, ScreenPos.Y + 1);
	Canvas.DrawTile(PlayerIcon, IconSizeMult, IconSizeMult, 0, 0, 256, 256);

	Canvas.SetDrawColor(255, 255, 255, 192);
    Canvas.SetPos( ScreenPos.X, ScreenPos.Y );
    Canvas.DrawTile( PlayerIcon, IconSizeMult, IconSizeMult, 0, 0, 256, 256 );
}

//These will be clamped
/** Draws icons for the last few remaining zeds */
function CheckAndDrawRemainingZedIcons()
{
	local Pawn P;
	local vector ViewLocation, ViewDir, PawnLocation;
	local rotator ViewRotation;

	if( KFGRI == none
		|| KFPlayerOwner == none
		|| KFPlayerOwner.PlayerCamera == none
		|| KFGRI.IsBossWave()
		|| KFGRI.IsEndlessWave()
		|| KFGRI.AIRemaining > class'KFGameInfo'.static.GetNumAlwaysRelevantZeds())
	{
		return;
	}

    KFPlayerOwner.PlayerCamera.GetCameraViewPoint( ViewLocation, ViewRotation );
    ViewDir = vector( ViewRotation );

	foreach WorldInfo.AllPawns( class'Pawn', P )
	{
		// Only draw hidden pawns
		if( P.Mesh.SkeletalMesh == none
			|| !P.Mesh.bAnimTreeInitialised
			|| P.GetTeamNum() == PlayerOwner.GetTeamNum()
			|| !P.IsAliveAndWell())
			//|| `TimeSince(P.Mesh.LastRenderTime) < 0.2f )
		{
			continue;
		}

		PawnLocation = P.Mesh.GetPosition();

		DrawZedIcon( P, PawnLocation, Normal((PawnLocation + (P.CylinderComponent.CollisionHeight * vect(0, 0, 1))) - ViewLocation) dot ViewDir);
	}
}

/** Draws a zed icon */
function DrawZedIcon( Pawn ZedPawn, vector PawnLocation, float NormalizedAngle )
{
    local vector ScreenPos, TargetLocation;
    local float IconSizeMult;
	local float ResModifier;

	ResModifier = WorldInfo.static.GetResolutionBasedHUDScale() * FriendlyHudScale;

    TargetLocation = PawnLocation + ( vect(0,0,2.5f) * ZedPawn.CylinderComponent.CollisionHeight );
    ScreenPos = Canvas.Project( TargetLocation );
    IconSizeMult = PlayerStatusIconSize * ResModifier * 0.5f;
    ScreenPos.X -= IconSizeMult;
    ScreenPos.Y -= IconSizeMult;



	if (NormalizedAngle > 0)
	{
		if (ScreenPos.X < 0 || ScreenPos.X > Canvas.ClipX || ScreenPos.Y < 0 || ScreenPos.Y > Canvas.ClipY)
		{
			ScreenPos.x = Canvas.ClipX - ScreenPos.x;
			ScreenPos = GetClampedScreenPosition(ScreenPos);
		}
		else
		{
			ScreenPos.x = FClamp(ScreenPos.x, PlayerStatusIconSize, Canvas.ClipX - (PlayerStatusIconSize));
		}
	}
	else
	{
		ScreenPos = GetClampedScreenPosition(ScreenPos);
	}


     // Draw boss icon
    Canvas.SetDrawColorStruct( ZedIconColor );
    Canvas.SetPos( ScreenPos.X, ScreenPos.Y );
    Canvas.DrawTile( GenericZedIconTexture, IconSizeMult, IconSizeMult, 0, 0, 128, 128 );
}

simulated function vector GetClampedScreenPosition(vector OldScreenPosition)
{
	local vector ScreenPos;
	local float ResModifier;
	local float YRange;

	YRange = MaxScreenClampPos * Canvas.ClipY - MinScreenClampPos * Canvas.ClipY;

	ResModifier = WorldInfo.static.GetResolutionBasedHUDScale() * FriendlyHudScale;

	ScreenPos.x = OldScreenPosition.x < (Canvas.ClipX / 2) ? Canvas.ClipX - (PlayerStatusIconSize * ResModifier) : PlayerStatusIconSize * ResModifier; //flipped do to being behind you
	OldScreenPosition.y = fclamp(OldScreenPosition.y, 0, Canvas.ClipY);

	ScreenPos.y = (OldScreenPosition.y / Canvas.ClipY) * YRange + (Canvas.ClipY - YRange) / 2;

	return ScreenPos;
}

/*********************************************************************************************
`* Pausing
********************************************************************************************* */

/**
 *	Pauses or unpauses the game due to main window's focus being lost.
 *	@param Enable tells whether to enable or disable the pause state
 */
event OnLostFocusPause(bool bEnable)
{
	// don't pause or unpause after toggling external UI if we have menus up (menu toggling handles pausing on standalone)
	// (see KFPlayerController::OnExternalUIChanged)
	if( WorldInfo.NetMode == NM_Standalone && KFPlayerOwner.MyGFxManager.bMenusOpen )
	{
		return;
	}

	super.OnLostFocusPause( bEnable );
}

/*********************************************************************************************
`* Debugging
********************************************************************************************* */

/** Add an actor to the list so that it will recieve a PostRenderFor() */
function SetPostRenderingFor( bool bOn, Actor A )
{
	if( bOn )
	{
		A.bPostRenderIfNotVisible = true;
		if( !bShowOverlays )
		{
			SetShowOverlays( true );
		}
		AddPostRenderedActor(A);
	}
	else
	{
		bPostRenderIfNotVisible = default.bPostRenderIfNotVisible;
		SetShowOverlays( default.bShowOverlays );
		RemovePostRenderedActor(A);
	}
}

defaultproperties
{
	PrestigeIconScale=0.75f

	PulseDuration=0.33
	PulseSplit=0.25
	PulseMultiplier=0.5

	bDrawCrosshair=false
	CrosshairAccuracyScale=(Points=((InVal=0.0001,OutVal=0.4),(InVal=0.0095,OutVal=0.5),(InVal=0.015,OutVal=0.65)))
	BaseCrosshairSize=50

	Text_NoClipShadowed=(bClipText=false,bEnableShadow=true)

	ClassicArmorColor=(R=0, G=0, B=255, A=192)
	ClassicHealthColor=(R=95, G=210, B=255, A=192)
	ArmorColor=(R=0, G=100, B=210, A=192)		// slightly less saturated
	HealthColor=(R=0, G=192, B=0, A=192)		// changed to match 'LightGreenColor'
	HealthBeingRegeneratedColor=(R=211, G=211, B=211, A=192)
	NonPlayerHealth=(R=0, G=184, B=97, A=192)
	PlayerBarBGColor=(R=16, G=16, B=16, A=192) 	// changed to grey so that depleted health is more obvious. More transparent.
	PlayerBarTextColor=(R=255, G=255, B=255, A=192)
	PlayerBarIconColor=(R=255, G=255, B=255, A=192)
	PlayerBarShadowColor=(R=0, G=0, B=0, A=255)

	LightGreenColor=(R=0, G=192, B=0, A=192)
	YellowColor=(R=255, G=176, B=0, A=192)
	OrangeColor=(R=255, G=96, B=0, A=192)
	RedHealthColor=(R=173, G=22, B=17, A=192)

	// changes colors to what players generally expect from active/inactive colors
	SupplierActiveColor=(R=192, G=192, B=192, A=192) // this actually INACTIVE, not an active color
	SupplierUsableColor=(R=0, G=192, B=0, A=192)
	SupplierHalfUsableColor=(R=160, G=192, B=0, A=192) // lime green

    HumanPlayerIconInterpMult=0.007f
	PlayerStatusBarBGTexture=Texture2D'EngineResources.WhiteSquareTexture'
	PlayerStatusBarLengthMax = 150.0f;
	PlayerStatusIconSize = 32; 					// 48. slightly smaller to reduce screen clutter

	ZedIconColor = (R = 255, G = 255, B = 255, A = 192)

	GenericHumanIconTexture = Texture2D'UI_PerkIcons_TEX.UI_Horzine_H_Logo'
	GenericZedIconTexture = Texture2D'UI_PerkIcons_TEX.UI_PerkIcon_ZED'

	IconHighLightTexture = Texture2D'UI_World_TEX.VoicCommsCircleHighlight'
	VoiceCommsIconHighlightScale = 0.5f
	CurrentVoiceCommsHighlightAlpha=255

	MinScreenClampPos=0.1f
	MaxScreenClampPos=0.4f

	MaxDrawDistanceObjective=100000000.f 		//		100 meters | squared value  for performance reasons
}