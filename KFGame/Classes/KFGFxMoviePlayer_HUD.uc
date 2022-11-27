//=============================================================================
// KFGFxMoviePlayer_HUD
//=============================================================================
// This is the managing class for all scaleform HUD items.
// It will tick and update its components to keep them all up to date
// as well as hide and pause items when they are not used
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//  - Greg Felber 5/12/2014
//=============================================================================

class KFGFxMoviePlayer_HUD extends GFxMoviePlayer
    config(UI);

var KFGFxMoviePlayer_ScoreBoard GfxScoreBoardPlayer;
var class<KFGFxMoviePlayer_ScoreBoard> ScoreBoardClass;

var EGameMessageType LastMessageType;
var bool bObjectiveQueued;

var array<string> SpecialWaveIconPath;
var array<string> SpecialWaveLocKey;

var KFGFxHUD_SpectatorInfo SpectatorInfoWidget;
// Container for Health & Armor widgets
var KFGFxHUD_PlayerStatus PlayerStatusContainer;
// Container for Weapon & ammo widgets
var KFGFxHUD_PlayerBackpack PlayerBackpackContainer;
// Container for Priority local message broadcasts.
var GfxObject PriorityMessageContainer;
// Container for boss name and message.
var GfxObject BossNameplateContainer;
// Container for interaction local message broadcasts.
var GfxObject InteractionMessageContainer;
// Widget for selecting your current weapon
var KFGFxHUD_WeaponSelectWidget KeyboardWeaponSelectWidget;
// Widget for selecting your current weapon
var KFGFxHUD_WeaponSelectWidget ControllerWeaponSelectWidget;
// This is the holder so that we keep track of one weaponselect container depending on user input type
var KFGFxHUD_WeaponSelectWidget WeaponSelectWidget;
// Widget for showing you were the trader is
var KFGFxHUD_TraderCompass TraderCompassWidget;
// Widget for showing how many enemies are left in the wave and which wave you are on.
var KFGFxHUD_WaveInfo WaveInfoWidget;

// Voip Notification Widget
var KFGFxWidget_VOIPNotification VOIPWidget;
// Widget for in game chat messages
var KFGFxHUD_ChatBoxWidget HudChatBox;
//Widget for displaying a level up.
var KFGFxWidget_LevelUpNotification LevelUpNotificationWidget;
//Widget for voice actions
var KFGFxWidget_VoiceComms VoiceCommsWidget;
//Widget for displaying song info
var KFGFxWidget_MusicNotification MusicNotification;
// widget for displaying a current kick vote and trader vote
var KFGFxWidget_KickVote KickVoteWidget;
// Widget that shows unimportant messages such as receiving ammo
var KFGFxWidget_NonCriticalGameMessage NonCriticalGameMessageWidget;
// Widget that shows invite message
var KFGFxWidget_NonCriticalGameMessage InviteGameMessageWidget;
// Widget that shows headshots for gunslinger
var KFGFxWidget_RhythmCounter RhythmCounterWidget;
// Widget that shows goompa jumps.
var KFGFxWidget_GoompaCounter GoompaCounterWidget;
// Widget that displays health bar
var KFGFxWidget_BossHealthBar bossHealthBar;
// Widget that displays map texts
var KFGFxWidget_MapText MapTextWidget;
// Widget that displays map texts
var KFGFxWidget_MapCounterText MapCounterTextWidget;
// Widget that displays gun mode texts
var KFGFxWidget_GunGame GunGameWidget;
// Widget that displays vip mode texts
var KFGFxWidget_VIP VIPWidget;

var KFPlayerController KFPC;

var config float HUDScale;

var GFxObject KFGXHUDManager;

var bool bIsSkipTraderVoteActive;
var bool bIsKickVoteActive;
var bool bUserAlreadyStartASkipTraderVote;
var bool bIsPauseGameVoteActive;

var bool bIsSpectating;
var bool bIsVisible;
var bool bUsingGamepad;

var int CurrentInteractionIndex;

var const string ControllerStringPrefix;
var const string HoldCommandDelimiter;

var const string ZEDTeamTextColor;
var const string HumanTeamTextColor;

// Interval between updates.  Higher values mean less frequent updates.
var const float UpdateInterval;
// Last time we performed an update.
var Protected float LastUpdateTime;

// The name of the player currently being voted on to kick
var string PendingKickPlayerName;

// Gun game variables
var transient bool                  bLastGunGameVisibility;

// VIP variables
var transient bool                  bLastVIPVisibility;

/** On creation of the HUD */
function Init(optional LocalPlayer LocPlay)
{
    KFPC=KFPlayerController( GetPC() );
    KFPC.SetGFxHUD( self );
    super.Init( LocPlay );
    KFGXHUDManager=GetVariableObject("root");
    UpdateRatio();
    UpdateScale();
    // Let the HUD Manager know if we are in a console build of the game.
    KFGXHUDManager.SetBool("bConsoleBuild",class'WorldInfo'.static.IsConsoleBuild());
}

function CreateScoreboard()
{
    if(GfxScoreBoardPlayer == none)
    {
        GfxScoreBoardPlayer=new ScoreBoardClass;
        GfxScoreBoardPlayer.SetTimingMode(TM_Real);
        GfxScoreBoardPlayer.Init(class'Engine'.static.GetEngine().GamePlayers[GfxScoreBoardPlayer.LocalPlayerOwnerIndex]);
    }
}

function ClearScoreboard()
{
    if( GfxScoreBoardPlayer != none )
    {
        GfxScoreBoardPlayer.Close(true);
        GfxScoreBoardPlayer=None;
    }
}

function UpdateRatio(optional float fScale=1.f)
{
    local GfxObject GFxStage;
    local float ScaleStage;

    if ( class'WorldInfo'.static.IsConsoleBuild() )
    {
        ScaleStage=class'Engine'.static.GetEngine().GetTitleSafeArea();
    }
    else
    {
        ScaleStage=fScale;
    }

    GFxStage=KFGXHUDManager != none ? KFGXHUDManager.GetObject("stage") : none;
	if( GFxStage != none )
	{
		GFxStage.SetFloat("x", (GFxStage.GetFloat("width") * (1.0f - ScaleStage)) / 2);
		GFxStage.SetFloat("y", (GFxStage.GetFloat("height") * (1.0f - ScaleStage)) / 2);
		GFxStage.SetFloat("scaleX", ScaleStage);
		GFxStage.SetFloat("scaleY", ScaleStage);
	}
}

/** Ties the GFxClikWidget variables to the .swf components and handles events */
event bool WidgetInitialized(name WidgetName, name WidgetPath, GFxObject Widget)
{
    switch(WidgetName)
    {
    case 'ObjectiveContainer':
        if(WaveInfoWidget != none && WaveInfoWidget.ObjectiveContainer == none)
        {
			WaveInfoWidget.ObjectiveContainer=KFGFxHUD_ObjectiveConatiner(Widget);
			WaveInfoWidget.ObjectiveContainer.InitializeHUD();
			UpdateObjectiveActive();
        }
        break;
    case 'bossHealthBar':
        if( BossHealthBar == none )
        {
            BossHealthBar=KFGFxWidget_BossHealthBar(Widget);
            SetWidgetPathBinding( Widget, WidgetPath );
            BossHealthBar.InitializeHUD();
        }
        break;
    case 'mapTextWidget':
        if( MapTextWidget == none )
        {
            MapTextWidget=KFGFxWidget_MapText(Widget);
            SetWidgetPathBinding( Widget, WidgetPath );
            MapTextWidget.InitializeHUD();
        }
        break;
    case 'counterMapTextWidget':
        if( MapCounterTextWidget == none )
        {
            MapCounterTextWidget=KFGFxWidget_MapCounterText(Widget);
            SetWidgetPathBinding( Widget, WidgetPath );
            MapCounterTextWidget.InitializeHUD();
        }
        break;
    case 'KickVoteWidget':
        if( KickVoteWidget == none )
        {
            KickVoteWidget=KFGFxWidget_KickVote(Widget);
            SetWidgetPathBinding( Widget, WidgetPath );
            KickVoteWidget.InitializeHUD();
        }
        break;
    case 'SpectatorInfoWidget':
        if( SpectatorInfoWidget == none )
        {
            SpectatorInfoWidget=KFGFxHUD_SpectatorInfo(Widget);
            SetWidgetPathBinding( Widget, WidgetPath );
            SpectatorInfoWidget.InitializeHUD();
        }
        break;
    case 'PlayerStatWidgetMC':
        if ( PlayerStatusContainer == none )
        {
            PlayerStatusContainer=KFGFxHUD_PlayerStatus(Widget);
            SetWidgetPathBinding( Widget, WidgetPath );
            PlayerStatusContainer.InitializeHUD();
        }
        break;
    case 'PlayerBackpackWidget':
        if ( PlayerBackpackContainer == none )
        {
            PlayerBackpackContainer=KFGFxHUD_PlayerBackpack(Widget);
            SetWidgetPathBinding( Widget, WidgetPath );
            PlayerBackpackContainer.InitializeHUD();
        }
        break;
    case 'PriorityMsgWidget':
        if( PriorityMessageContainer == none)
        {
            PriorityMessageContainer=Widget;
            SetWidgetPathBinding( Widget, WidgetPath );
        }
        break;
    case 'BossNamePlate':
        if( BossNameplateContainer == none)
        {
            BossNameplateContainer=Widget;
            SetWidgetPathBinding( Widget, WidgetPath );
        }
        break;
    case 'interactionMsgWidget':
        if( InteractionMessageContainer == none)
        {
            InteractionMessageContainer=Widget;
            SetWidgetPathBinding( Widget, WidgetPath );
        }
        break;
    case 'WeaponSelectContainer':
        if ( KeyboardWeaponSelectWidget == none )
        {
            KeyboardWeaponSelectWidget=KFGFxHUD_WeaponSelectWidget(Widget);
            KeyboardWeaponSelectWidget.RefreshWeaponSelect();
            KeyboardWeaponSelectWidget.InitializeObject();
            if(!bUsingGamepad)
            {
                WeaponSelectWidget=KeyboardWeaponSelectWidget;
            }
        }
        break;
    case 'ControllerWeaponSelectContainer':
        if ( ControllerWeaponSelectWidget == none )
        {
            ControllerWeaponSelectWidget=KFGFxHUD_WeaponSelectWidget(Widget);
            ControllerWeaponSelectWidget.RefreshWeaponSelect();
            ControllerWeaponSelectWidget.InitializeObject();
            if(bUsingGamepad)
            {
                WeaponSelectWidget=ControllerWeaponSelectWidget;
            }
        }
        break;
    case 'CompassContainer':
        if ( TraderCompassWidget == none )
        {
            TraderCompassWidget=KFGFxHUD_TraderCompass(Widget);
            TraderCompassWidget.InitializeHUD();
            SetWidgetPathBinding( Widget, WidgetPath );
        }
        break;
    case 'WaveInfoContainer':
        if ( WaveInfoWidget == none )
        {
            WaveInfoWidget=KFGFxHUD_WaveInfo(Widget);
            WaveInfoWidget.InitializeHUD();
            SetWidgetPathBinding( Widget, WidgetPath );
        }
        break;
    case 'ChatBoxWidget':
        if(!(class'WorldInfo'.static.IsPlayInEditor()))
        {
            if(HudChatBox == none)
            {
                HudChatBox=KFGFxHUD_ChatBoxWidget(Widget);
            }
        }
        break;
    case 'voipWidget':
        if(VOIPWidget == none)
        {
            VOIPWidget=KFGFxWidget_VOIPNotification(Widget);
        }
        break;
    case 'LevelUpNotificationWidget':
        if(LevelUpNotificationWidget == none)
        {
            LevelUpNotificationWidget=KFGFxWidget_LevelUpNotification(Widget);
            LevelUpNotificationWidget.InitializeHUD();
        }
        break;
    case 'VoiceCommsWidget':
        if(VoiceCommsWidget == none)
        {
            VoiceCommsWidget=KFGFxWidget_VoiceComms(Widget);
            VoiceCommsWidget.InitializeHUD();
        }
        break;
    case 'MusicNotification':
        if(MusicNotification == none)
        {
            MusicNotification=KFGFxWidget_MusicNotification(Widget);
            MusicNotification.InitializeHUD();
        }
        break;
    case 'NonCriticalMessageWidget':
        if(NonCriticalGameMessageWidget == none)
        {
            NonCriticalGameMessageWidget=KFGFxWidget_NonCriticalGameMessage(Widget);
        }
        break;
    case 'InviteMessageWidget':
        if(InviteGameMessageWidget == none)
        {
            InviteGameMessageWidget=KFGFxWidget_NonCriticalGameMessage(Widget);
        }
        break;
    case 'RhythmCounter':
        if(RhythmCounterWidget == none)
        {
            RhythmCounterWidget=KFGFxWidget_RhythmCounter(Widget);
        }
        break;
    case 'GoompaCounter':
        if (GoompaCounterWidget == none)
        {
            GoompaCounterWidget=KFGFxWidget_GoompaCounter(Widget);
        }
        break;
    case 'GunGameContainer':
        if (GunGameWidget == none)
        {
            GunGameWidget=KFGFxWidget_GunGame(Widget);
            SetWidgetPathBinding( Widget, WidgetPath );
        }
        break;
    case 'VIPContainer':
        if (VIPWidget == none)
        {
            VIPWidget=KFGFxWidget_VIP(Widget);
            SetWidgetPathBinding( Widget, WidgetPath );
        }
        break;
    }
   
    return true;
}

function UpdateWeaponSelect()
{
    if(bUsingGamepad)
    {
        WeaponSelectWidget=ControllerWeaponSelectWidget;
        if(KeyboardWeaponSelectWidget != none)
        {
            KeyboardWeaponSelectWidget.Hide();
        }
    }
    else
    {
        WeaponSelectWidget=KeyboardWeaponSelectWidget;
        if(ControllerWeaponSelectWidget != none)
        {
            ControllerWeaponSelectWidget.Hide();
        }
    }
}

/** Update all the unique HUD pieces */
function TickHud(float DeltaTime)
{
    local bool bGunGameVisibility, bVIPModeVisibility;

    if(KFPC == none || KFPC.WorldInfo.TimeSeconds - LastUpdateTime < UpdateInterval )
    {
        return;
    }
	
	if (WaveInfoWidget != none)
	{
		WaveInfoWidget.TickHUD(DeltaTime);
	}

    if(!KFPC.MyHUD.bShowHUD)
    {
        return;
    }

    LastUpdateTime=KFPC.WorldInfo.TimeSeconds;   // throttle the updates so we're not spamming Actionscript with data.

    // Update current input
    if(bUsingGamepad != KFPC.PlayerInput.bUsingGamepad)
    {
        bUsingGamepad=KFPC.PlayerInput.bUsingGamepad;
        UpdateUsingGamepad();
        UpdateWeaponSelect();
    }

    if(BossHealthBar != none)
    {
        BossHealthBar.TickHud( DeltaTime );
    }

    if(MapTextWidget != none)
    {
        MapTextWidget.TickHud( UpdateInterval );
    }

    if(MapCounterTextWidget != none)
    {
        MapCounterTextWidget.TickHud( UpdateInterval );
    }

    if( SpectatorInfoWidget != none )
    {
        SpectatorInfoWidget.TickHud( DeltaTime );
    }

    if( !bIsSpectating )
    {
        // Update Health / Armor
        if ( PlayerStatusContainer != none )
        {
            PlayerStatusContainer.TickHud( DeltaTime );
        }

        // Update Ammo
        if ( PlayerBackpackContainer != none )
        {
            PlayerBackpackContainer.TickHud( DeltaTime );
        }
    }

    if( TraderCompassWidget != none)
    {
        TraderCompassWidget.TickHUD( DeltaTime);
    }

    if(GfxScoreBoardPlayer != none)
    {
        GfxScoreBoardPlayer.TickHud(DeltaTime);
    }

    if (GunGameWidget != none)
    {
        bGunGameVisibility = KFPC.CanUseGunGame();

        if (bGunGameVisibility)
        {
             bGunGameVisibility = KFPC.Pawn.Health > 0;
        }
    
        if (bGunGameVisibility != bLastGunGameVisibility)
        {
            GunGameWidget.UpdateGunGameVisibility(bGunGameVisibility);
            bLastGunGameVisibility = bGunGameVisibility;
        }
    }

    if (VIPWidget != none)
    {
        bVIPModeVisibility = KFPC.CanUseVIP();

        if (bVIPModeVisibility != bLastVIPVisibility)
        {
            VIPWidget.UpdateVIPVisibility(bVIPModeVisibility);
            bLastVIPVisibility = bVIPModeVisibility;
        }
    }
}

function UpdateObjectiveActive()
{
	local KFGameReplicationInfo KFGRI;
	local KFInterface_MapObjective ObjectiveInterface;

	KFPC=KFPlayerController(GetPC());

	if (KFPC == none)
	{
		return;
	}
	KFGRI=KFGameReplicationInfo(KFPC.WorldInfo.GRI);
	if (WaveInfoWidget != none && WaveInfoWidget.ObjectiveContainer != none)
	{
		if (KFGRI.CurrentObjective == none)
		{
			WaveInfoWidget.ObjectiveContainer.SetActive(false);
		}
		else
		{
			ObjectiveInterface=KFInterface_MapObjective(KFGRI.CurrentObjective);
			WaveInfoWidget.ObjectiveContainer.SetActive(ObjectiveInterface.IsActive());
		}

	}
}

function UpdateWaveCount()
{
    if(GfxScoreBoardPlayer != none)
    {
        GfxScoreBoardPlayer.UpdateWaveCount();
    }

    if(WaveInfoWidget != none)
    {
        WaveInfoWidget.UpdateWaveCount();
    }
}

//==============================================================
// @name States
//==============================================================

/** Show or hide the HUD */
function NotifyVisibilityChange(bool bValue)
{
    if( bIsVisible != bValue )
    {
        bIsVisible=bValue;
        if(KFPC != none)
        {
            //Clear focus on next frame
            KFPC.SetTimer(0.01, false, nameOf(UpdateVisibilityState), self);
        }
    }
}

/** Make sure the chat box is closed if we've just opened a menu */
function UpdateVisibilityState()
{
    if(bIsVisible)
    {
        if( HudChatBox != none )
        {
            HudChatBox.ClearAndCloseChat();
        }
    }
    else
    {
        Callback_ChatBoxClosed();
    }
}

/** Hide the HUD elements and only display the spectating part of the HUD */
function SetHUDSpectating( bool bSpectate )
{
    bIsSpectating=bSpectate;

    KFGXHUDManager.SetBool("bSpectating", bIsSpectating);
}

/** Display the scoreboard on screen */
function ShowScoreboard(bool newShowScoreboard)
{
    if(GfxScoreBoardPlayer == none)
    {
        CreateScoreboard();
    }

    if(GfxScoreBoardPlayer  != none)
    {
        GfxScoreBoardPlayer.ShowScoreboard(newShowScoreboard);
    }
}

/** Display the voicecoms on screen */
function ShowVoiceComms(bool bShowComms)
{
    if(VoiceCommsWidget != none && !bIsSpectating)
    {
        if(bShowComms)
        {
            VoiceCommsWidget.EnableComm();
            ShowScoreboard(false);
            if(WeaponSelectWidget != none)
            {
                WeaponSelectWidget.Hide();
            }
        }
        else
        {
            VoiceCommsWidget.DisableComm();
        }
        SetMovieCanReceiveFocus(bShowComms);
        SetMovieCanReceiveInput(bShowComms);
    }
}

//==============================================================
// @name Died / Clean up
//==============================================================

function PlayerOwnerDied()
{
    if(VoiceCommsWidget != none)
    {
        VoiceCommsWidget.DisableComm();
    }
    if(WeaponSelectWidget != none)
    {
        WeaponSelectWidget.Hide();
    }
}

function CleanUp()
{
    //remove score board movie player
    ClearScoreboard();
    //Remove the delegate off of the VoiceComms so the game doesn't crash.  Crashes are bad.  They make me sad.
    if(GetGameViewportClient() != none)
    {
        GetGameViewportClient().HandleInputAxis=none;
    }
}

function NotifyHUDofPRIDestroyed(KFPlayerReplicationInfo KFPRI)
{
    if(VOIPWidget != none)
    {
        VOIPWidget.VOIPEventTriggered(KFPRI, false);
    }
}

//==============================================================
// Localized Message rendering
//==============================================================
function ShowKillMessage(PlayerReplicationInfo PRI1, PlayerReplicationInfo PRI2, optional bool bDeathMessage=false, optional Object OptionalObject)
{
    local GFxObject DataObject;
    local bool bHumanDeath;
    local string KilledName, KillerName, KilledIconpath, KillerIconPath;
    local string KillerTextColor, KilledTextColor;
    local class<KFPawn_Monster> KFPM;

    if(KFPC == none)
    {
        return;
    }

    KFPM=class<KFPawn_Monster>(OptionalObject);

    if( KFGXHUDManager != none )
    {
        if(bDeathMessage)
        {
            if(KFPM != none)
            {
                KillerName=KFPM.static.GetLocalizedName();
                KillerTextColor=ZEDTeamTextColor;
                KillerIconpath="img://"$class'KFPerk_Monster'.static.GetPerkIconPath();
            }
        }
        else
        {
            if(KFPM != none)
            {
                KilledName=KFPM.static.GetLocalizedName();
                bHumanDeath=false;
            }
            else if(PRI1 != none)
            {
                if(PRI1.GetTeamNum() == 255)
                {
                    KillerTextColor=ZEDTeamTextColor;
                    KillerIconpath="img://"$class'KFPerk_Monster'.static.GetPerkIconPath();
                }
                else
                {
                    KillerTextColor=HumanTeamTextColor;
                    KillerIconpath="img://"$KFPlayerReplicationInfo(PRI1).CurrentPerkClass.static.GetPerkIconPath();
                }
                KillerName=PRI1.PlayerName;
            }
        }

        if(PRI2 != none)
        {
            if(PRI2.GetTeamNum() == class'KFTeamInfo_Human'.default.TeamIndex)
            {
                bHumanDeath=true;
                KilledTextColor=HumanTeamTextColor;
            }
            else
            {
                KilledTextColor=ZEDTeamTextColor;
                bHumanDeath=false;
            }
            KilledName=PRI2.PlayerName;
            KilledIconpath="img://"$KFPlayerReplicationInfo(PRI2).CurrentPerkClass.static.GetPerkIconPath();
        }

        DataObject=CreateObject("Object");

        DataObject.SetBool("humanDeath", bHumanDeath);

        DataObject.SetString("killedName", KilledName);
        DataObject.SetString("killedTextColor", KilledTextColor);
        DataObject.SetString("killedIcon", KilledIconpath);

        DataObject.SetString("killerName", KillerName);
        DataObject.SetString("killerTextColor", KillerTextColor);
        DataObject.SetString("killerIcon", KillerIconpath);

        //temp remove when rest of design catches up
        DataObject.SetString("text", KillerName@KilledName);

        KFGXHUDManager.SetObject("newBark", DataObject);
    }
}

function ShowBossNameplate(string BossName, string InSecondaryMessageString)
{
    local GFxObject TempObject;

    ShowVoiceComms(false);

    if(BossNameplateContainer != none && BossName != "")
    {
        TempObject=CreateObject("Object");
        TempObject.SetString("bossName", BossName);
        TempObject.SetString("subString", InSecondaryMessageString);
        KFGXHUDManager.SetObject("bossData", TempObject);
    }
}

function HideBossNamePlate()
{
    if(BossNameplateContainer != none)
    {
        KFGXHUDManager.ActionScriptVoid("hideBossNamePlate");
    }
    if(BossHealthBar != none)
    {
        BossHealthBar.OnNamePlateHidden();
    }
}

function DisplayMapText(string MessageText, float DisplayTime, bool bWaitForTheNextMessageToFinish)
{
    if(MapTextWidget != none)
    {
        MapTextWidget.DisplayMapText(MessageText, DisplayTime, bWaitForTheNextMessageToFinish);
    }
}

function DisplayMapCounterText(string MessageText, float DisplayTime)
{
    if(MapCounterTextWidget != none)
    {
        MapCounterTextWidget.DisplayMapText(MessageText, DisplayTime);
    }
}

function DisplayPriorityMessage(string InPrimaryMessageString, string InSecondaryMessageString, int LifeTime, optional EGameMessageType MessageType, optional string SpecialIconPath)
{
	local GFxObject PriorityMessageObject;

	if (PriorityMessageContainer != none && InPrimaryMessageString != "")
	{
		LastMessageType=MessageType;
		PriorityMessageObject=CreateObject("Object");

		PriorityMessageObject.SetString("priorityTextPrimaryString", InPrimaryMessageString);
		PriorityMessageObject.SetString("priorityTextSecondaryString", InSecondaryMessageString);
		PriorityMessageObject.SetInt("priorityTextDisplayTime", LifeTime);

        if (SpecialIconPath != "")
        {
            PriorityMessageObject.SetString("specialIconPath", "img://"$SpecialIconPath);
        }

		PriorityMessageContainer.SetObject("priorityMessage", PriorityMessageObject);
	}
}

function DisplayExpandedWaveInfo()
{
	local KFGameReplicationInfo KFGRI;
	local KFWeeklyOutbreakInformation WeeklyInfo;
	local GFxObject PriorityMessageObject;
	local int ModifierIndex;

	switch (LastMessageType)
	{
		case GMT_WaveStart:
		case GMT_WaveStartWeekly:
		case GMT_WaveStartSpecial:
		case GMT_WaveSBoss:

			break;
		default:
			return;
	}

	PriorityMessageObject=CreateObject("Object");

	KFGRI=KFGameReplicationInfo(KFPC.WorldInfo.GRI);
	if (PriorityMessageContainer != none)
	{
		PriorityMessageObject=CreateObject("Object");
		if (KFGRI.default.bEndlessMode)
		{
			PriorityMessageObject.SetString("waveNum", String(KFGRI.WaveNum));
		}
		else
		{
            if (KFGRI.bIsWeeklyMode && KFGRI.CurrentWeeklyIndex == 16)
            {
				if (KFGRI.bWaveGunGameIsFinal)
				{
					PriorityMessageObject.SetString("waveNum", class'KFGFxHUD_WaveInfo'.default.FinalWaveString);
				}
				else
				{
	                PriorityMessageObject.SetString("waveNum", KFGRI.GunGameWavesCurrent $"/?");
				}
            }
            else if (KFGRI.IsBossWave())
			{
				PriorityMessageObject.SetString("waveNum", class'KFGFxHUD_WaveInfo'.default.BossWaveString);
			}
			else
			{
				if (KFGRI.IsFinalWave())
				{
					PriorityMessageObject.SetString("waveNum", class'KFGFxHUD_WaveInfo'.default.FinalWaveString);
				}
				else
				{
					PriorityMessageObject.SetString("waveNum", KFGRI.WaveNum $"/"@KFGRI.GetFinalWaveNum());
				}
			}
		}

		PriorityMessageObject.SetString("waveString", class'KFGFxHUD_WaveInfo'.default.WaveString);

		PriorityMessageObject.SetInt("waveTier", GetWaveTier());
		if (KFGRI.IsWeeklyWave(ModifierIndex))
		{
			WeeklyInfo=class'KFMission_LocalizedStrings'.static.GetWeeklyOutbreakInfoByIndex(ModifierIndex);
			PriorityMessageObject.SetString("waveType", WeeklyInfo.FriendlyName);
			PriorityMessageObject.SetString("waveImage", "img://"$WeeklyInfo.IconPath);
		}
		else if (KFGRI.IsSpecialWave(ModifierIndex))
		{
			//Something for zed waves
			PriorityMessageObject.SetString("waveType", Localize("Zeds", SpecialWaveLocKey[ModifierIndex], "KFGame"));
			PriorityMessageObject.SetString("waveImage", "img://"$SpecialWaveIconPath[ModifierIndex]);
		}
		else
		{
			//PriorityMessageObject.SetString("waveType", "Survival");
		}

		PriorityMessageContainer.SetObject("waveNumberMessage", PriorityMessageObject);
	}
}

function int GetWaveTier()
{
	local KFGameReplicationInfo KFGRI;
	KFGRI=KFGameReplicationInfo(KFPC.WorldInfo.GRI);

	if (KFGRI.default.bEndlessMode)
	{
		//calculate it
		if (KFGRI.WaveNum > 20 )
		{
			return 5;
		}
		else if (KFGRI.WaveNum > 15 )
		{
			return 4;
		}
		if (KFGRI.WaveNum > 10 )
		{
			return 3;
		}
		if (KFGRI.WaveNum > 5)
		{
			return 2;
		}
	}
	else
	{
        if (KFGRI.IsRandomPerkMode())
        {
            return 5;
        }
		else if (KFGRI.IsFinalWave())
		{
			return 3;
		}
		else if (KFGRI.IsBossWave())
		{
			return 5;
		}
	}

	return 1;
}


function bool ShouldCheckForObjective(EGameMessageType MessageType)
{
	local KFGameReplicationInfo KFGRI;

	KFGRI=KFGameReplicationInfo(KFPC.WorldInfo.GRI);

	if (KFGRI.GetNumPlayersAlive() <= 0)
	{
		return false;
	}

	switch (MessageType)
	{
		case GMT_WaveStart:
		case GMT_WaveStartWeekly:
		case GMT_WaveStartSpecial:
		case GMT_WaveSBoss:
		case GMT_WaveEnd:
			return true;
	}
	return false;
}

simulated function PlayObjectiveAudio()
{
	local KFGameReplicationInfo KFGRI;

	KFGRI=KFGameReplicationInfo(KFPC.WorldInfo.GRI);

	if (KFGRI.PreviousObjectiveResult > 0)
	{
		class'KFMusicStingerHelper'.static.PlayObjectiveWonStinger(GetPC());
	}
	else
	{
		class'KFMusicStingerHelper'.static.PlayNewObjectiveStinger(GetPC());
	}
}

simulated function DisplayObjectiveResults()
{
	local KFGameReplicationInfo KFGRI;
	local GFxObject ObjectiveObject;
	local KFInterface_MapObjective ObjectiveInterface;

	KFGRI=KFGameReplicationInfo(KFPC.WorldInfo.GRI);
	ObjectiveInterface=KFInterface_MapObjective(KFGRI.PreviousObjective);
	if (KFGRI.PreviousObjectiveResult > 0)
	{
		ObjectiveObject=CreateObject("Object");
		//do not show lost because this is optional
		ObjectiveObject.SetString("titleString", class'KFLocalMessage_Priority'.default.ObjectiveWonMessage);
		ObjectiveObject.SetString("nameString", class'KFCommon_LocalizedStrings'.default.BonusDoshString);
		ObjectiveObject.SetString("descString", " ");
		ObjectiveObject.SetString("requireString", " ");
		ObjectiveObject.SetString("rewardNum", string(KFGRI.PreviousObjectiveResult));

		ObjectiveObject.SetString("xpBonus", string(KFGRI.PreviousObjectiveXPResult));
		ObjectiveObject.SetString("voshBonus", string(KFGRI.PreviousObjectiveVoshResult));

		ObjectiveObject.SetString("iconPath", "img://"$PathName(ObjectiveInterface.GetIcon()));
		ObjectiveObject.SetBool("isBonus", true);
		PriorityMessageContainer.SetObject("objectiveMessage", ObjectiveObject);
		LastMessageType=GMT_Null;
	}
}

simulated function DisplayNewObjective()
{
	local KFGameReplicationInfo KFGRI;
	local GFxObject ObjectiveObject;
	local KFInterface_MapObjective ObjectiveInterface;

	KFGRI=KFGameReplicationInfo(KFPC.WorldInfo.GRI);

	ObjectiveInterface=KFGRI.ObjectiveInterface;

	if (ObjectiveInterface != none)
	{
		ObjectiveObject=CreateObject("Object");

		ObjectiveObject.SetString("titleString", class'KFLocalMessage_Priority'.default.ObjectiveStartMessage);
		ObjectiveObject.SetString("nameString", ObjectiveInterface.GetLocalizedName());
		ObjectiveObject.SetString("descString", ObjectiveInterface.GetLocalizedDescription());
		ObjectiveObject.SetString("requireString", ObjectiveInterface.GetLocalizedRequirements());
		ObjectiveObject.SetString("rewardNum", string(ObjectiveInterface.GetMaxDoshReward()));
		ObjectiveObject.SetString("xpBonus", string(ObjectiveInterface.GetMaxXPReward()));
		ObjectiveObject.SetString("voshBonus", string(ObjectiveInterface.GetMaxVoshReward()));
		ObjectiveObject.SetString("iconPath", "img://"$PathName(ObjectiveInterface.GetIcon()));
		ObjectiveObject.SetBool("isBonus", false);

		KFGRI.PreviousObjectiveResult=INDEX_NONE;
		PriorityMessageContainer.SetObject("objectiveMessage", ObjectiveObject);
		LastMessageType=GMT_Null;
	}
}

/** Display a message that corresponds to input */
function DisplayInteractionMessage( string MessageString, int MessageIndex, optional string ButtonName="", optional float Duration )
{
    if( InteractionMessageContainer != none )
    {
        if( MessageIndex == IMT_None || KFPC.IsBossCameraMode() )
        {
            HideInteractionMessage();
        }
        // allow messages of the same priority to replace each other (unless it's the same message)
        else if( MessageIndex != CurrentInteractionIndex && GetInteractionMessagePriority(MessageIndex) >= GetInteractionMessagePriority(CurrentInteractionIndex) )
        {
            MessageString=Caps(MessageString);
            if ( KFPC != None )
            {
                KFPC.ClearTimer(nameOf(HideInteractionMessage), self);
                if ( Duration > 0.f )
                {
                    KFPC.SetTimer(Duration, false, nameOf(HideInteractionMessage), self);
                }
            }

            //Check to see if removing the controller prefix will result in a single character.  If we send a single character
            // bad things will happen.
            if(class'Actor'.static.Len(ButtonName) - class'Actor'.static.Len(ControllerStringPrefix) > 1)
            {
                //Image Replacing a string in AS3 cannot take a substring larger than 15 characters.  We remove the prefix for controllers
                //because these are common accross all controller inputs.
                class'Actor'.static.ReplaceText(ButtonName, ControllerStringPrefix, "" );
            }
            // Put the command into the string so that it can be replaced  Scaleform will not try to image replace a keyboard command unless
            // we actually put an icon and object for it.
            //class'Actor'.static.ReplaceText(MessageString, "<%X%>", ButtonName );

            SendInteractionMessageToGFX(MessageString, ButtonName);
            CurrentInteractionIndex=MessageIndex;
        }
    }
}


/** Allows client to group message indices together in the same priority (e.g. all usable trigger messages get same priority even though enum id is different) */
function int GetInteractionMessagePriority( int MessageIndex )
{
    // for now, make all usable messages the same priority
    if( MessageIndex < IMT_GamepadWeaponSelectHint )
    {
        return IMT_GamepadWeaponSelectHint - 1;
    }

    return MessageIndex;
}

/** Display a message that corresponds to input */
function SendInteractionMessageToGFX(string MessageString, string ButtonName)
{
    local GFxObject TextObject;
    local array<String> StringArray;

    TextObject=CreateObject("Object");

    StringArray=SplitString(MessageString, HoldCommandDelimiter);

    if(StringArray.length > 1)
    {
        TextObject.SetString("holdMessage", StringArray[1]);
        TextObject.SetBool("bHoldCommand", true);
    }
    else
    {
        TextObject.SetBool("bHoldCommand", false);
    }

    TextObject.SetString("message", StringArray[0]);
    TextObject.SetString("buttonName", ButtonName);
    TextObject.SetString("holdString", class'KFGFxControlsContainer_ControllerPresets'.default.HoldString);
    TextObject.SetString("tapString", class'KFGFxControlsContainer_ControllerPresets'.default.TapString);

    InteractionMessageContainer.SetObject("interactionMessageData", TextObject);
}

/**
* Close the interaction message
*/
function HideInteractionMessage()
{
    CurrentInteractionIndex=IMT_None;
    InteractionMessageContainer.ActionScriptVoid("outInteractionMessage");
}

/** Show less important messages */
function ShowNonCriticalMessage(string LocalizedMessage)
{
    if(NonCriticalGameMessageWidget != none)
    {
        NonCriticalGameMessageWidget.ShowMessage(LocalizedMessage);
    }
}

/** Show invite text message */
function ShowInviteMessage(string FriendName)
{
    if (InviteGameMessageWidget != none)
    {
        if (FriendName == "")
        {
            InviteGameMessageWidget.ShowMessage(FriendName);
        }
        else
        {
            InviteGameMessageWidget.ShowMessage(FriendName$Class'KFCommon_LocalizedStrings'.default.InvitePopupTextString);
        }
    }
}

function UpdateRhythmCounterWidget(int value, int max)
{
    if(RhythmCounterWidget != none)
    {
        RhythmCounterWidget.SetCount(value, max);
    }
}

function UpdateGoompaCounterWidget(int value, int max)
{
    if(GoompaCounterWidget != none)
    {
        GoompaCounterWidget.SetCount(value, max);
    }
}

function UpdateGunGameWidget(int score, int max_score, int level, int max_level)
{
    if (GunGameWidget != none)
    {
        GunGameWidget.SetData(score, max_score, level, max_level);
    }
}

function UpdateVIP(ReplicatedVIPGameInfo VIPInfo, bool bIsVIP)
{
    local KFGameReplicationInfo KFGRI;
    KFGRI=KFGameReplicationInfo(KFPC.WorldInfo.GRI);

    if (VipWidget == none || KFGRI == none || !KFGRI.IsVIPMode())
    {
        return;
    }

    if (bIsVIP)
    {
        VIPWidget.SetVIP();
    }
    else if (VipInfo.VIPPlayer != none)
    {
        VIPWidget.SetNOVIP(VIPInfo.VIPPlayer.PlayerName, VIPInfo.CurrentHealth, VIPInfo.MaxHealth);
    }
}

//==============================================================
// Input
//==============================================================

/** Set whether the HUD should eat all button input */
function EatMyInput(bool bValue)
{
    local byte HUDPriority;

    if( bValue )
    {
        GetPC().PlayerInput.ResetInput();
    }

    // Set whether the HUD should eat the input
    SetMovieCanReceiveFocus(bValue);
    SetMovieCanReceiveInput(bValue);

    // Set the HUD as the movie player with the highest priority
    HUDPriority=( bValue ) ? 255 : 1;
    SetPriority(HUDPriority);
}

/** Update icons with either mouse / keyboard or gamepad */
function UpdateUsingGamepad()
{
    if(SpectatorInfoWidget != none)
    {
        SpectatorInfoWidget.UpdateUsingGamepad(bUsingGamepad);
    }
    if(KickVoteWidget != none)
    {
        KickVoteWidget.UpdateUsingGamepad(bUsingGamepad);
    }
}

//==============================================================
// In-Game Chat Box.
//==============================================================

// A player pressed the 'Talk' key. Open the Gfx chat box.
function OpenChatBox()
{
    if(HudChatBox != none)
    {
        HudChatBox.OpenInputField();

        // Give focus to the GfxMovie so player can type in the box.
        EatMyInput(true);
        bIgnoreMouseInput=false;
    }
}

//==============================================================
// Kick, Skip Trader and Pause Game Vote
//==============================================================

function ShowKickVote(PlayerReplicationInfo PRI, byte VoteDuration, bool bShowChoices)
{
    if(KickVoteWidget != none)
    {
		bIsSkipTraderVoteActive = false;
        bIsPauseGameVoteActive = false;
        bIsKickVoteActive = true;
        KickVoteWidget.ShowVote(PRI, VoteDuration, bShowChoices, VT_KICK);
    }
}

simulated function HideKickVote()
{
    if(KickVoteWidget != none)
    {
		bIsSkipTraderVoteActive = false;
		bIsKickVoteActive = false;
        bIsPauseGameVoteActive = false;
        KickVoteWidget.VoteClosed();
    }
}

function UpdateKickVoteCount(byte YesVotes, byte NoVotes)
{
    if(KickVoteWidget != none)
    {
        KickVoteWidget.UpdateVoteCount(YesVotes, NoVotes);
    }
}

function ShowSkipTraderVote(PlayerReplicationInfo PRI, byte VoteDuration, bool bShowChoices)
{
    if(KickVoteWidget != none)
    {
		bIsSkipTraderVoteActive = true;
		bIsKickVoteActive = false;
        bIsPauseGameVoteActive = false;
        KickVoteWidget.ShowVote(PRI, VoteDuration, bShowChoices, VT_SKIP_TRADER);
    }
}

function UpdateSkipTraderTime(byte VoteDuration)
{
    if(KickVoteWidget != none)
    {
        KickVoteWidget.UpdateVoteDuration(VoteDuration);
    }
}

simulated function HideSkipTraderVote()
{
    if(KickVoteWidget != none)
    {
		bIsSkipTraderVoteActive = false;
		bIsKickVoteActive = false;
        bIsPauseGameVoteActive = false;
        KickVoteWidget.VoteClosed();
    }
}

function UpdateSkipTraderVoteCount(byte YesVotes, byte NoVotes)
{
    if(KickVoteWidget != none)
    {
        KickVoteWidget.UpdateVoteCount(YesVotes, NoVotes);
    }
}

function ShowPauseGameVote(PlayerReplicationInfo PRI, byte VoteDuration, bool bShowChoices)
{
    local KFGameReplicationInfo KFGRI;
    KFGRI=KFGameReplicationInfo(KFPC.WorldInfo.GRI);

    if (KickVoteWidget != none)
    {
        bIsPauseGameVoteActive = true;
		bIsKickVoteActive = false;
        bIsSkipTraderVoteActive = false;
        KickVoteWidget.ShowVote(PRI, VoteDuration, bShowChoices, (KFGRI != none && KFGRI.bIsEndlessPaused) ? VT_RESUME_GAME : VT_PAUSE_GAME);
    }
} 

function UpdatePauseGameTime(byte VoteDuration)
{
    if(KickVoteWidget != none)
    {
        KickVoteWidget.UpdateVoteDuration(VoteDuration);
    }
}

simulated function HidePauseGameVote()
{
    if(KickVoteWidget != none)
    {
		bIsPauseGameVoteActive = false;
		bIsKickVoteActive = false;
        bIsSkipTraderVoteActive = false;
        KickVoteWidget.VoteClosed();
    }
}

function UpdatePauseGameVoteCount(byte YesVotes, byte NoVotes)
{
    if(KickVoteWidget != none)
    {
        KickVoteWidget.UpdateVoteCount(YesVotes, NoVotes);
    }
}

//==============================================================
// Updates
//==============================================================

/* currently only set in the INI file due to Relow issues with layouts. */
function UpdateScale()
{
    if(KFGXHUDManager != none)
    {
        KFGXHUDManager.SetFloat("HUDScale", HUDScale * class'WorldInfo'.static.GetResolutionBasedHUDScale());
    }
}

/** Refresh the weapon HUD upon obtaining a new one */
function NotifyHUDofWeapon()
{
    if(WeaponSelectWidget != none)
    {
        WeaponSelectWidget.RefreshWeaponSelect();
    }
}

function ClearBuffIcons()
{
    if(PlayerStatusContainer != none)
    {
        PlayerStatusContainer.ClearBuffIcons();
    }
}

function PawnDied()
{
    ClearBuffIcons();
}

function ReceivePawn(KFPawn NewPawn);

//==============================================================
// ActionScript Callbacks
//==============================================================

function Callback_ObjMessageFired()
{
	PlayObjectiveAudio();
}

function Callback_Log(string text)
{
    `Log("Received log from actionscript: " $text);
}

function Callback_PriorityMessageComplete()
{
	local KFInterface_MapObjective ObjectiveInterface;
	local KFGameReplicationInfo KFGRI;

	DisplayExpandedWaveInfo();

	if (ShouldCheckForObjective(LastMessageType))
	{
		KFGRI=KFGameReplicationInfo(KFPC.WorldInfo.GRI);

		ObjectiveInterface=KFGRI.ObjectiveInterface;
		if (ObjectiveInterface != none)
		{
			DisplayNewObjective();
		}
		else if (KFGRI.PreviousObjective != none)
		{
			DisplayObjectiveResults();
		}
		UpdateObjectiveActive();
		LastMessageType=GMT_Null;
	}
	else
	{
		bObjectiveQueued=true;
	}
}

function Callback_BroadcastChatMessage(string NewMessage)
{
    if(!IsPendingKill())
    {
        if(NewMessage != "")
        {
            if(KFPC.CurrentTextChatChannel == ETCC_TEAM)
            {
                GetPC().TeamSay(NewMessage);
            }
            else
            {
                GetPC().Say(NewMessage);
            }
        }
    }
}

function Callback_ChatBoxClosed()
{
    EatMyInput(false);
    bIgnoreMouseInput=true;
}

function Callback_SelectWeapon( int GroupIndex, int WeaponIndex )
{
    local KFInventoryManager KFIM;
    if(GetPC().Pawn != none )
    {
        KFIM=KFInventoryManager(GetPC().Pawn.InvManager);
        if ( KFIM != none )
        {
            KFIM.SelectCurrentWeapon( GroupIndex, WeaponIndex );
        }
    }
}

function Callback_WeaponSelectFadedOut()
{
    if ( WeaponSelectWidget != none)
    {
        WeaponSelectWidget.bChangingWeapons=false;
    }
}

function Callback_VoiceCommsSay(int CommsIndex)
{
    if(VoiceCommsWidget != none)
    {
        VoiceCommsWidget.SayVoiceCommms(CommsIndex);
    }
}

function Callback_VoiceCommsSelection( int CommsIndex )
{
    if( VoiceCommsWidget != none )
    {
        VoiceCommsWidget.SaveVoiceCommSelection( CommsIndex );
    }
}

function Callback_VoteKick(bool Vote)
{
    local KFPlayerReplicationInfo KFPRI;

    KFPRI=KFPlayerReplicationInfo(GetPC().PlayerReplicationInfo);

	if(bIsSkipTraderVoteActive)
	{
		KFPRI.CastSkipTraderVote(KFPRI, Vote);
	}
    else if(bIsPauseGameVoteActive)
    {
        KFPRI.CastPauseGameVote(KFPRI, Vote);
    }
	else
	{
		KFPRI.CastKickVote(KFPRI, Vote);
	}

	if(KickVoteWidget != none)
	{
		KickVoteWidget.ResetVote();
	}
}


DefaultProperties
{
	SoundThemes.Add((ThemeName = "UI",Theme = UISoundTheme'SoundsShared_UI.SoundTheme_UI'))

    ZEDTeamTextColor="0xBE0600"
    HumanTeamTextColor="0xBAFFFF"
    ScoreBoardClass=class'KFGFxMoviePlayer_ScoreBoard'
    MovieInfo=SwfMovie'UI_HUD.InGameHUD_SWF'
    ControllerStringPrefix="XboxTypeS_"
    HoldCommandDelimiter="<%HOLD%>"

    Priority=1
    UpdateInterval=.1f

    bAllowFocus=true
    bCaptureInput=true
    bAllowInput=true
    bDisplayWithHudOff=false
    bAutoPlay=true
    bIsSpectating=false

    bLastGunGameVisibility=true
    bLastVIPVisibility=true

    WidgetBindings.Add((WidgetName="ObjectiveContainer",WidgetClass=class'KFGFxHUD_ObjectiveConatiner'))
    WidgetBindings.Add((WidgetName="SpectatorInfoWidget",WidgetClass=class'KFGFxHUD_SpectatorInfo'))
    WidgetBindings.Add((WidgetName="PlayerStatWidgetMC",WidgetClass=class'KFGFxHUD_PlayerStatus'))
    WidgetBindings.Add((WidgetName="PlayerBackpackWidget",WidgetClass=class'KFGFxHUD_PlayerBackpack'))
    WidgetBindings.Add((WidgetName="PriorityMsgWidget",WidgetClass=class'GfxObject'))
    WidgetBindings.Add((WidgetName="BossNamePlate",WidgetClass=class'GfxObject'))
    WidgetBindings.Add((WidgetName="interactionMsgWidget",WidgetClass=class'GfxObject'))
    WidgetBindings.Add((WidgetName="ControllerWeaponSelectContainer",WidgetClass=class'KFGFxHUD_WeaponSelectWidget'))
    WidgetBindings.Add((WidgetName="WeaponSelectContainer",WidgetClass=class'KFGFxHUD_WeaponSelectWidget'))
    WidgetBindings.Add((WidgetName="CompassContainer",WidgetClass=class'KFGFxHUD_TraderCompass'))
    WidgetBindings.Add((WidgetName="WaveInfoContainer",WidgetClass=class'KFGFxHUD_WaveInfo'))
    WidgetBindings.Add((WidgetName="ChatBoxWidget", WidgetClass=class'KFGFxHUD_ChatBoxWidget'))
    WidgetBindings.Add((WidgetName="voipWidget", WidgetClass=class'KFGFxWidget_VOIPNotification'))
    WidgetBindings.Add((WidgetName="LevelUpNotificationWidget", WidgetClass=class'KFGFxWidget_LevelUpNotification'))
    WidgetBindings.Add((WidgetName="VoiceCommsWidget", WidgetClass=class'KFGFxWidget_VoiceComms'))
    WidgetBindings.Add((WidgetName="KickVoteWidget", WidgetClass=class'KFGFxWidget_KickVote'))
    WidgetBindings.Add((WidgetName="MusicNotification", WidgetClass=class'KFGFxWidget_MusicNotification'))
    WidgetBindings.Add((WidgetName="NonCriticalMessageWidget", WidgetClass=class'KFGFxWidget_NonCriticalGameMessage'))
    WidgetBindings.Add((WidgetName="InviteMessageWidget", WidgetClass=class'KFGFxWidget_NonCriticalGameMessage'))
    WidgetBindings.Add((WidgetName="RhythmCounter", WidgetClass=class'KFGFxWidget_RhythmCounter'))
    WidgetBindings.ADD((WidgetName="GoompaCounter", WidgetClass=class'KFGFxWidget_GoompaCounter'));
    WidgetBindings.Add((WidgetName="bossHealthBar", WidgetClass=class'KFGFxWidget_BossHealthBar'))
    WidgetBindings.Add((WidgetName="mapTextWidget", WidgetClass=class'KFGFxWidget_MapText'))
    WidgetBindings.Add((WidgetName="counterMapTextWidget", WidgetClass=class'KFGFxWidget_MapCounterText'))
    WidgetBindings.ADD((WidgetName="GunGameContainer", WidgetClass=class'KFGFxWidget_GunGame'));
    WidgetBindings.ADD((WidgetName="VIPContainer", WidgetClass=class'KFGFxWidget_VIP'));

	SpecialWaveIconPath(AT_Clot)="UI_Endless_TEX.ZEDs.UI_ZED_Endless_Cyst"
	SpecialWaveIconPath(AT_SlasherClot)="UI_Endless_TEX.ZEDs.UI_ZED_Endless_Slasher"
	SpecialWaveIconPath(AT_AlphaClot)="UI_Endless_TEX.ZEDs.UI_ZED_Endless_Clot"
	SpecialWaveIconPath(AT_Crawler)="UI_Endless_TEX.ZEDs.UI_ZED_Endless_Crawler"
	SpecialWaveIconPath(AT_GoreFast)="UI_Endless_TEX.ZEDs.UI_ZED_Endless_Gorefast"
	SpecialWaveIconPath(AT_Stalker)="UI_Endless_TEX.ZEDs.UI_ZED_Endless_Stalker"
	SpecialWaveIconPath(AT_Scrake)="UI_Endless_TEX.ZEDs.UI_ZED_Endless_Scrake"
	SpecialWaveIconPath(AT_FleshPound)="UI_Endless_TEX.ZEDs.UI_ZED_Endless_FP"
	SpecialWaveIconPath(AT_FleshpoundMini)="UI_Endless_TEX.ZEDs.UI_ZED_Endless_FP"
	SpecialWaveIconPath(AT_Bloat)="UI_Endless_TEX.ZEDs.UI_ZED_Endless_Bloat"
	SpecialWaveIconPath(AT_Siren)="UI_Endless_TEX.ZEDs.UI_ZED_Endless_Siren"
	SpecialWaveIconPath(AT_Husk)="UI_Endless_TEX.ZEDs.UI_ZED_Endless_Husk"

	SpecialWaveLocKey(AT_SlasherClot)="KFPawn_ZedClot_Slasher"
	SpecialWaveLocKey(AT_Clot)="KFPawn_ZedClot_Cyst"
	SpecialWaveLocKey(AT_Crawler)="KFPawn_ZedCrawler"
	SpecialWaveLocKey(AT_Stalker)="KFPawn_ZedStalker"
	SpecialWaveLocKey(AT_Siren)="KFPawn_ZedSiren"
	SpecialWaveLocKey(AT_Husk)="KFPawn_ZedHusk"
	SpecialWaveLocKey(AT_Scrake)="KFPawn_ZedScrake"
	SpecialWaveLocKey(AT_AlphaClot)="KFPawn_ZedClot_Alpha"
	SpecialWaveLocKey(AT_GoreFast)="KFPawn_ZedGorefast"
	SpecialWaveLocKey(AT_Bloat)="KFPawn_ZedBloat"
	SpecialWaveLocKey(AT_FleshPound)="KFPawn_ZedFleshpound"

}
