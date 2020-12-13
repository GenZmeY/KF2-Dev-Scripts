//=============================================================================
// KFGFXHudWrapper_Versus
//=============================================================================
// HUD class for Versus mode
//=============================================================================
// Killing Floor 2
// Copyright (C) 2016 Tripwire Interactive LLC
//=============================================================================
class KFGFXHudWrapper_Versus extends KFGFXHudWrapper;

/** Cached GRI reference */
var KFGameReplicationInfoVersus MyKFGRIV;

var Class<KFGFxMoviePlayer_HUD> HumanHUDClass;
var Class<KFGFxMoviePlayer_HUD> ZedHUDClass;
var() float ZedPlayerHudLocX, ZedPlayerHudLocY;

var int HumanStatusBarLengthMax;
const FriendlyZedInfoShowDistanceSQ = 562000;

/** Boss icon texture/values */
var const Texture2D BossIconTexture;
var const color BossIconColor;

/** String displayed to player zeds waiting for the next spawn cycle */
var localized string WaitingToSpawnString;

/** String displayed to player zeds when the takeover timer is active */
var localized string ZedTakeOverActiveString;

/** String displayed to human players when the round is over */
var localized string PerkSwitchAllowedString;

var int LastTeamIndex;

simulated function PostBeginPlay()
{
    local KFPawn_Monster KFP;

    super.PostBeginPlay();
 
    // If we have a new HUD, try to cache a reference to boss pawn
    foreach WorldInfo.AllPawns( class'KFPawn_Monster', KFP )
    {
        if (KFP.static.IsABoss())
        {
            BossRef = KFInterface_MonsterBoss(KFP);
            break;
        }
    }
}

function CreateHUDMovie(optional bool bForce)
{
    if (!class'WorldInfo'.static.IsMenuLevel())
    {       
        if(KFPlayerOwner != none && KFPlayerOwner.PlayerReplicationInfo.GetTeamNum() != LastTeamIndex || bForce)
        {
            LastTeamIndex = KFPlayerOwner.GetTeamNum();
            if(HudMovie != none)
            {
                RemoveMovies();
            }
            HudMovie = new GetHUDClass();
            HudMovie.SetTimingMode(TM_Real);
            HudMovie.Init(class'Engine'.static.GetEngine().GamePlayers[HudMovie.LocalPlayerOwnerIndex]);
        }
    }
}

function class<KFGFxMoviePlayer_HUD> GetHUDClass()
{
    if( KFPlayerOwner != none && KFPlayerOwner.GetTeamNum() == 255 && KFPlayerOwner.PlayerReplicationInfo != none && !KFPlayerOwner.PlayerReplicationInfo.bOnlySpectator )
    {
        return ZedHUDClass;
    }

    return HumanHUDClass;
}

/**
 * @brief Main canvas draw function
 */
function DrawHUD()
{
    local float ThisDot;
    local vector ViewLocation, ViewVector, TestPawnLocation;
    local rotator ViewRotation;
    local Pawn TestPawn;
    local KFPawn_Human HumanPawn;
    local array<PlayerReplicationInfo> VisibleHumanPlayers;
    local array<sHiddenHumanPawnInfo> HiddenHumanPlayers;
    local byte MyTeamNum;

    super.DrawHUD();

    // Don't draw canvas HUD in cinematic mode
    if( WorldInfo.GRI == none || (KFPlayerOwner != none && KFPlayerOwner.bCinematicMode) )
    {
        return;
    }

    if( KFPlayerOwner.PlayerCamera != none )
    {
        KFPlayerOwner.PlayerCamera.GetCameraViewPoint( ViewLocation, ViewRotation );
    }

    // Enable stencil test
    Canvas.EnableStencilTest(true);

    // Cache off view rotation vector
    ViewVector = vector(ViewRotation);
    MyTeamNum = KFPlayerOwner.GetTeamNum();

    // Cache GRI
    if( MyKFGRIV == none )
    {
        MyKFGRIV = KFGameReplicationInfoVersus( WorldInfo.GRI );
    }

    if( MyKFGRIV == none )
    {
        return;
    }

    if( KFPlayerOwner != none && MyTeamNum == 255 )
    {
        foreach WorldInfo.AllPawns( class'Pawn', TestPawn )   
        {
            // Only player-controlled pawns
            if( TestPawn.PlayerReplicationInfo == none )
            {
                continue;
            }

            if( TestPawn.IsAliveAndWell()
                && TestPawn.Mesh.SkeletalMesh != none
                && TestPawn.Mesh.bAnimTreeInitialised
                && TestPawn != KFPlayerOwner.Pawn )
            {	
                if( TestPawn.Mesh != none && `TimeSince( TestPawn.Mesh.LastRenderTime ) < 0.2f )
                {
                    TestPawnLocation = TestPawn.Mesh.GetPosition() + ( TestPawn.CylinderComponent.CollisionHeight * vect(0,0,1) );
                    ThisDot = Normal(TestPawnLocation - ViewLocation) dot ViewVector;
                    if( ThisDot > 0.f )
                    {
                        HumanPawn = KFPawn_Human(TestPawn);
                        if( HumanPawn != none )
                        {
                            if( DrawPreciseHumanPlayerInfo( HumanPawn ) )
                            {
                                VisibleHumanPlayers.AddItem( HumanPawn.PlayerReplicationInfo );
                            }
                            else
                            {
                                HiddenHumanPlayers.Insert( 0, 1 );
                                HiddenHumanPlayers[0].HumanPawn = HumanPawn;
                                HiddenHumanPlayers[0].HumanPRI = HumanPawn.PlayerReplicationInfo;
                            }
                        }/* //Not supposed to be drawing a bar above zed characters
                        else if( MyTeamNum == 255 && TestPawn.GetTeamNum() == 255 )
                        {
                            if( VSizeSq( KFPlayerOwner.ViewTarget.Location - TestPawnLocation ) <= FriendlyZedInfoShowDistanceSQ )
                            {
                                DrawFriendlyZedPawnIcon( TestPawn );
                            }
                        }*/
                    }
                }
                else if( TestPawn.GetTeamNum() == 0 )
                {
                    HiddenHumanPlayers.Insert( 0, 1 );
                    HiddenHumanPlayers[0].HumanPawn = TestPawn;
                    HiddenHumanPlayers[0].HumanPRI = TestPawn.PlayerReplicationInfo;
                }
            }
        }

        if( !KFGRI.bHidePawnIcons )
        {
            CheckAndDrawHiddenPlayerIcons( VisibleHumanPlayers, HiddenHumanPlayers );
        }
    }
    
    
    // Draw boss pawn icon if needed
    CheckAndDrawBossPawnIcon( ViewLocation, ViewVector );
    
     // Disable stencil test
    Canvas.EnableStencilTest(false);

    // Draw spawn time remaining
    if( (MyTeamNum == 255 || MyKFGRIV.bRoundIsOver)
        && !MyKFGRIV.bMatchIsOver
        && (PlayerOwner.Pawn == none || PlayerOwner.Pawn.bPlayedDeath)
        && PlayerOwner.CanRestartPlayer() )
    {
        if( MyKFGRIV.TimeUntilNextSpawn != 255 || MyKFGRIV.PlayerZedSpawnWaitTimeData.bTakeOverActive )
        {
             DrawRemainingTimeUntilSpawn( MyKFGRIV.TimeUntilNextSpawn, MyKFGRIV.PlayerZedSpawnWaitTimeData.bTakeOverActive );
        }
    }    
}

/**
 * @brief Checks if a boss icon should be drawn
 * 
 * @param ViewLocation Thew local player's ViewLocation 
 * @param ViewVector Thew local player's ViewVector 
 * 
 */
simulated function CheckAndDrawBossPawnIcon( vector ViewLocation, vector ViewVector )
{
    local float ThisDot;
    local vector BossPawnLocation;
    local KFPawn_Monster BossPawn;

    if (BossRef == none)
    {
        return;
    }

    BossPawn = BossRef.GetMonsterPawn();

    if( BossPawn != none
        && BossPawn.Mesh.SkeletalMesh != none
        && BossPawn.Mesh.bAnimTreeInitialised
        && BossPawn != PlayerOwner.Pawn
        && BossPawn.IsAliveAndWell()
        && `TimeSince( BossPawn.Mesh.LastRenderTime ) > 0.2f
        && (PlayerOwner.GetTeamNum() == 255 || BossPawn.ShouldDrawBossIcon()) )
    {
        BossPawnLocation = BossPawn.Mesh.GetPosition();
        ThisDot = Normal( (BossPawnLocation + (BossPawn.CylinderComponent.CollisionHeight * vect(0,0,1))) - ViewLocation ) dot ViewVector;
        if( ThisDot > 0.f )
        {
            DrawBossPawnIcon( BossPawnLocation );
        }
    }
}

/**
 * @brief Draws a visible zed team mate's info
 * 
 * @param MonsterPawn The zed's pawn
 */
simulated function DrawFriendlyZedPawnIcon( Pawn MonsterPawn )
{
    local float Percentage;
    local float BarHeight, BarLength;
    local vector ScreenPos, TargetLocation;
    local FontRenderInfo MyFontRenderInfo;
    local float FontScale;
    //local color TempColor;

    MyFontRenderInfo = Canvas.CreateFontRenderInfo( true );
    BarLength = FMin(HumanStatusBarLengthMax * (float(Canvas.SizeX) / 1024.f), HumanStatusBarLengthMax) * FriendlyHudScale;
    BarHeight = FMin(8.f * (float(Canvas.SizeX) / 1024.f), 8.f) * FriendlyHudScale;

    TargetLocation = MonsterPawn.Mesh.GetPosition() + ( MonsterPawn.CylinderComponent.CollisionHeight * vect(0,0,2.2f) );

    ScreenPos = Canvas.Project(TargetLocation);
    if( ScreenPos.X < 0 || ScreenPos.X > Canvas.SizeX || ScreenPos.Y < 0 || ScreenPos.Y > Canvas.SizeY )
    {
        return;
    }

    //Draw health bar
    Percentage = FMin(float(MonsterPawn.Health) / float(MonsterPawn.HealthMax), 100);
    DrawKFBar(Percentage, BarLength, BarHeight, ScreenPos.X - (BarLength *0.5f), ScreenPos.Y, HealthColor);

    //Draw player name (Top)
    FontScale = class'KFGameEngine'.Static.GetKFFontScale();
    Canvas.Font = class'KFGameEngine'.Static.GetKFCanvasFont();
    Canvas.SetDrawColorStruct(PlayerBarTextColor);
    Canvas.SetPos(ScreenPos.X - (BarLength *0.5f), ScreenPos.Y - BarHeight * 3);
    Canvas.DrawText( MonsterPawn.PlayerReplicationInfo.PlayerName,,FontScale * FriendlyHudScale,FontScale * FriendlyHudScale, MyFontRenderInfo );
}

/**
 * @brief Draws a visible human player's info
 * 
 * @param KFPH The player's pawn
 * @return true if successfully drawn
 */
function bool DrawPreciseHumanPlayerInfo( KFPawn_Human KFPH )
{
    local float Percentage;
    local float BarHeight, BarLength;
    local vector ScreenPos, TargetLocation;
    local KFPlayerReplicationInfo KFPRI;
    local float IconSizeMult;

    KFPRI = KFPlayerReplicationInfo(KFPH.PlayerReplicationInfo);
    if( KFPRI == none )
    {        
        return false;
    }

    BarLength = FMin( HumanStatusBarLengthMax * (float(Canvas.SizeX) / 1024.f), HumanStatusBarLengthMax ) * FriendlyHudScale;
    BarHeight = FMin( 8.f * (float(Canvas.SizeX) / 1024.f), 8.f ) * FriendlyHudScale;

    TargetLocation = KFPH.Mesh.GetPosition() + ( KFPH.CylinderComponent.CollisionHeight * vect(0,0,2.2f) );

    ScreenPos = Canvas.Project(TargetLocation);
    if( ScreenPos.X < 0 || ScreenPos.X > Canvas.SizeX || ScreenPos.Y < 0 || ScreenPos.Y > Canvas.SizeY )
    {
        return true;
    }
    //Draw health bar
    Percentage = FMin( float(KFPH.Health) / float(KFPH.HealthMax), 100  );
    DrawKFBar( Percentage, BarLength, BarHeight, ScreenPos.X - BarLength * 0.5f, ScreenPos.Y, HealthColor );
    //Draw armor bar
    Percentage = FMin(float(KFPH.Armor) / float(KFPH.MaxArmor), 100);
    DrawKFBar(Percentage, BarLength, BarHeight, ScreenPos.X - (BarLength *0.5f), ScreenPos.Y - BarHeight, ArmorColor);

    IconSizeMult = PlayerStatusIconSize * FriendlyHudScale * 0.5f;
    ScreenPos.X -= IconSizeMult;
    ScreenPos.Y -= IconSizeMult * 2.5;

    Canvas.SetDrawColor(255,255,255,255);
    Canvas.SetPos( ScreenPos.X, ScreenPos.Y );
    Canvas.DrawTile( GenericHumanIconTexture, PlayerStatusIconSize * FriendlyHudScale, PlayerStatusIconSize * FriendlyHudScale, 0, 0, 256, 256 );
    return true;
}

/**
 * @brief Draws an icon projecting the boss' world position on the screen
 * 
 * @param BossPawn The boss' pawn
 */
function DrawBossPawnIcon( vector BossLocation )
{
    local vector ScreenPos, TargetLocation;
    local float IconSizeMult;

	if (BossRef == none)
	{
		return;
	}

    TargetLocation = BossLocation + ( BossRef.GetMonsterPawn().CylinderComponent.CollisionHeight * vect(0,0,2.2f) );
    ScreenPos = Canvas.Project( TargetLocation );
    IconSizeMult = PlayerStatusIconSize * FriendlyHudScale * 0.5f;
    ScreenPos.X -= IconSizeMult;
    ScreenPos.Y -= IconSizeMult;

    if( ScreenPos.X < 0 || ScreenPos.X > Canvas.SizeX || 
        ScreenPos.Y < 0 || ScreenPos.Y > Canvas.SizeY )
    {
        return;
    }   
  
     // Draw boss icon
    Canvas.SetDrawColorStruct( BossIconColor );
    Canvas.SetPos( ScreenPos.X, ScreenPos.Y );
    Canvas.DrawTile( BossIconTexture, PlayerStatusIconSize * FriendlyHudScale, PlayerStatusIconSize * FriendlyHudScale, 0, 0, 256, 256 );
}

function DrawRemainingTimeUntilSpawn( byte RemainingTime, bool bTakeOverIsActive )
{
    local vector2D ScreenPos;
    local int ShadowSize;
    local float TextScale, XL, YL;
    local string ActualString;
    local FontRenderInfo MyFontRenderInfo;

    MyFontRenderInfo = Canvas.CreateFontRenderInfo( true );

    if( bTakeOverIsActive && PlayerOwner.GetTeamNum() == 255 )
    {
        ActualString = ZedTakeOverActiveString;
    }
    else
    {
        if( PlayerOwner.GetTeamNum() == 0 && MyKFGRIV.bRoundIsOver )
        {
            ActualString = Repl( PerkSwitchAllowedString, "%x%", RemainingTime, true );
        }
        else
        {
            ActualString = Repl( WaitingToSpawnString, "%x%", RemainingTime, true );           
        }
    }

    TextScale = class'KFGameEngine'.Static.GetKFFontScale() * (Canvas.ClipY / 768.f);
    Canvas.Font = class'KFGameEngine'.Static.GetKFCanvasFont();
    Canvas.TextSize( Repl( WaitingToSpawnString, "%x%", "00", true ), XL, YL, TextScale, TextScale );
    ScreenPos.X = (Canvas.ClipX * 0.5f) - (XL * 0.5f);
    ScreenPos.Y = Canvas.ClipY * 0.25f;

    // Drop shadow
    ShadowSize = int( Canvas.ClipY / 360.f );
    Canvas.SetPos( ScreenPos.X + ShadowSize, ScreenPos.Y + ShadowSize );
    Canvas.SetDrawColor( 0, 0, 0, 160 );
    Canvas.DrawText( ActualString,, TextScale, TextScale, MyFontRenderInfo );

    // Text
    Canvas.SetPos( ScreenPos.X, ScreenPos.Y );
    Canvas.SetDrawColor( 255, 255, 255, 255 );
    Canvas.DrawText( ActualString,, TextScale, TextScale, MyFontRenderInfo );
}

DefaultProperties
{
    LastTeamIndex=-1
    HUDClass=class'KFGFxMoviePlayer_HUD'
    HumanHUDClass=class'KFGFxMoviePlayer_HUD'
    ZedHUDClass=class'KFGFxMoviePlayer_HUD_Versus'

    ZedPlayerHudLocX=0.25
    ZedPlayerHudLocY=0.85

    HumanStatusBarLengthMax = 80.0f;

    BossIconTexture=Texture2D'ZED_Patriarch_UI.ZED-VS_Icon_Boss'
    BossIconColor=(R=255, G=255, B=255, A=192)
}