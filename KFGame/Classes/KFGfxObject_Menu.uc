//=============================================================================
// KFGFxObject_Menu
//=============================================================================
// Class Description
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//  - Author 4/23/2014
//=============================================================================

class KFGFxObject_Menu extends GFxObject
	native(UI);

var KFGFxMoviePlayer_Manager Manager;
var TWOnlineLobby OnlineLobby;

var localized string LeavePartyTitleString;
var localized string LeavePartyDescriptionString;
var localized string LeaveString;

// This is only called once when a menu is created
function InitializeMenu( KFGFxMoviePlayer_Manager InManager )
{
	Manager = InManager;
	InitOnlineLobby();
  	GetPC().PlayerInput.ResetInput();
}

// This is called whenever we open the menu
function OnOpen();

function InitOnlineLobby()
{
	if(GetPC().OnlineSub != none)
	{
	OnlineLobby = GetPC().OnlineSub.GetLobbyInterface();
	}
}
function OnR3Pressed()
{
	local KFPlayerController KFPC;
	local KFPlayerReplicationInfo KFPRI;
	local KFGameReplicationInfo KFGRI;

	KFPC = KFPlayerController(GetPC());
	if(KFPC != none)
	{
		KFPRI = KFPlayerReplicationInfo( GetPC().PlayerReplicationInfo );
		if (KFPRI != none)
		{
			KFGRI = KFGameReplicationInfo(KFPRI.WorldInfo.GRI);
			if(KFGRI != none || KFGRI.bEndlessMode)
			{
				KFPC.RequestPauseGame();
				return;
			}
		}

		KFPC.RequestSwitchTeam();
	}
}

function OnInputTypeChanged(bool bGamePad);

function OneSecondLoop();

event bool OnAxisModified( int ControllerId, name Key, float Delta, float DeltaTime, bool bGamepad){};

event OnTraderTimeStart();

function OnRoundOver();

event OnClose();

function OnLobbyStatusChanged(bool bIsInParty){}

function ShowLeavePartyPopUp()
{
	if(Manager != none)
	{
		Manager.DelayedOpenPopup(EConfirmation,EDPPID_Misc, LeavePartyTitleString, LeavePartyDescriptionString, LeaveString, class'KFCommon_LocalizedStrings'.Default.CancelString, ConfirmLeaveParty, CancelLeaveParty);
	}
}

function ConfirmLeaveParty()
{
	local KFPlayerController KFPC;

    KFPC = KFPlayerController(GetPC());

	if(OnlineLobby != none)
	{
		OnlineLobby.QuitLobby();

        if ( KFPC != none && KFPC.MyGFxManager != none )
        {
        	if(KFPC.MyGFxManager.MenuBarWidget != none)
        	{
        		KFPC.MyGFxManager.MenuBarWidget.UpdateMenu(KFPC.MyGFxManager.CurrentMenuIndex);
        	}
        	if(KFPC.MyGFxManager.StartMenu != none && !OnlineLobby.IsLobbyOwner() )
        	{
				KFPC.MyGFxManager.StartMenu.OnPartyLeave();
        	}
        }
	}

	if (!class'WorldInfo'.static.IsMenuLevel())
	{
		ConsoleCommand("Disconnect");
	}
	//@SABER_EGS_BEGIN EOS
	if (class'WorldInfo'.static.isEOSBuild() && Manager != none) 
	{
		Manager.OnLobbyStatusChanged(false);
	}
	//@SABER_EGS_END
}

function CancelLeaveParty()
{
	//Do nothing
}


function string ConsoleLocalize( string Key, optional string SectionName )
{
	return Localize( SectionName != "" ? SectionName : string(self.Class.Name), Key, "KFGameConsole" );
}


//==============================================================
// ActionScript Callbacks
//==============================================================

function Callback_ControllerCloseMenu()
{
	local KFPlayerReplicationInfo KFPRI;
	KFPRI = KFPlayerReplicationInfo( GetPC().PlayerReplicationInfo );

	`log(`location@`showvar(KFPRI)@`showvar(Manager));
	if( Manager != none && KFPRI != none )
	{
		if( !class'WorldInfo'.static.IsMenuLevel() && Manager.bUsingGamepad )
		{
			if(KFPRI.bReadyToPlay || KFPRI.bOnlySpectator)
			{
				if ( KFPRI.WorldInfo.GRI.bMatchHasBegun )
				{
					Manager.CloseMenus();
				}
				else if ( Manager.bAfterLobby && ( Manager.CurrentMenu != None && Manager.PostGameMenu != None && Manager.CurrentMenu != Manager.PostGameMenu) )
				{
					// Allow for backing out of the pause screen into the AAR.
					Manager.ToggleMenus();
				}
			}
		}
	}
}

// Opens the "Are you sure you want to quit" Confirmation
function Callback_Quit()
{
    if(Manager != none)
    {
		if (class'WorldInfo'.static.IsConsoleBuild(CONSOLE_Durango))
		{
			Manager.MenuBarWidget.OpenLogoutPopup();
		}
		else
		{
			Manager.MenuBarWidget.OpenQuitPopUp();
		}
    }
}

function Callback_MenusFinishedClosing()
{
	`log(`location@`showvar(Manager.bMenusOpen));
	if( Manager != none && Manager.bMenusOpen)
	{
		Manager.MenusFinishedClosing();
	}
}

function Callback_MenuBarTabChanged( int NewMenuIndex )
{
	if ( Manager != none )
	{
		Manager.OpenMenu( NewMenuIndex );
	}
}

function Callback_RequestTeamSwitch()
{
	local KFPlayerController KFPC;

    KFPC = KFPlayerController(GetPC());
	if ( KFPC != none )
	{
		KFPC.RequestSwitchTeam();
	}
}

function Callback_RequestEndlessPause()
{
	local KFPlayerController KFPC;
	local KFPlayerReplicationInfo KFPRI;
	
	KFPC = KFPlayerController(GetPC());
	KFPRI = KFPlayerReplicationInfo( KFPC.PlayerReplicationInfo );

	if (KFPC != none && KFPRI != none)
	{
		KFPRI.RequestPauseGame(KFPRI);
		KFPC.MyGFxManager.CloseMenus();
	}
}

function Callback_ReadyClicked( bool bReady )
{
	local KFPlayerReplicationInfo KFPRI;
	local KFGameReplicationInfo KFGRI;
	local KFPlayerController KFPC;

	KFPC = KFPlayerController(GetPC());
	KFPRI = KFPlayerReplicationInfo( KFPC.PlayerReplicationInfo );
	KFGRI = KFGameReplicationInfo(KFPRI.WorldInfo.GRI);

	if (KFPRI != none)
	{
	    // For game in progress, close menus on ready
	    if (KFGRI.bMatchHasBegun)
	    {
			//player has spawned, skip trader time
			if (KFGRI.bTraderIsOpen && KFPRI.bHasSpawnedIn)
			{
				if (KFPC.MyGFxManager.bMenusOpen && KFPC.MyGFxManager.CurrentMenu != KFPC.MyGFxManager.TraderMenu)
				{
					//skip trader request
					KFPRI.RequestSkiptTrader(KFPRI);
					KFPC.MyGFxManager.CloseMenus();
					//Setready button visibility to false here
					if (Manager != none && Manager.PartyWidget != none)
					{
						Manager.PartyWidget.SetReadyButtonVisibility(false);
					}
				}
			}
			else //spawn them
			{
				KFPRI.SetPlayerReady(bReady);
				KFPlayerController(GetPC()).MyGFxManager.CloseMenus();
				GetPC().ServerRestartPlayer();
			}
	    }
	    else if (Manager != none )
	    {
			KFPRI.SetPlayerReady(bReady);
	    	if(Manager.PartyWidget !=none)
	    	{
				Manager.PartyWidget.RefreshParty();
			}
			if(Manager.StartMenu != none && bReady)
			{
				Manager.StartMenu.OnPlayerReadiedUp();
			}
			if(Manager.PerksMenu != none)
			{
				Manager.PerksMenu.SelectionContainer.SetPerkListEnabled(!bReady);
			}
		}
	}
}

function Callback_PlayerClicked( int SlotIndex )
{
/*
	local array<KFPlayerReplicationInfo> KFPRIArray;
	local KFPawn_Customization KFP;

	GetKFPRIArray( KFPRIArray );
	if ( SlotIndex >= KFPRIArray.length )
	{
    	return;
	}

	foreach GetPC().WorldInfo.AllPawns(class'KFPawn_Customization', KFP)
	{
		// find the selected pawn and view it
		if ( KFP.PlayerReplicationInfo == KFPRIArray[SlotIndex] )
		{
			GetPC().SetViewTarget( KFP );
			if ( KFPlayerCamera( GetPC().PlayerCamera ) != none )
				KFPlayerCamera( GetPC().PlayerCamera ).CustomizationCam.SetBodyView( 0, true );
			break;
		}
	}
	*/
}

function ConfirmCreateParty()
{
	local OnlineSubsystem OnlineSub;

	OnlineSub = class'GameEngine'.static.GetOnlineSubsystem();

	if (OnlineLobby != none)
	{
		if (OnlineSub != none && !OnlineSub.IsGameOwned() && class'WorldInfo'.static.IsConsoleBuild(CONSOLE_Orbis))
		{
			if (OnlineSub.CanCheckFreeTrialState() && !OnlineSub.IsFreeTrialPeriodActive())
			{
				Manager.HandleFreeTrialError(FTN_BuyGame);
				return;
			}

			if (!OnlineSub.CanCheckFreeTrialState())
			{
				Manager.HandleFreeTrialError(FTN_NetworkCheckFailed);
				return;
			}
		}

		//@SABER_EGS_BEGIN Friends list
		if (Class'WorldInfo'.Static.IsConsoleBuild())
		{
			OnlineLobby.MakeLobby(`KF_MAX_PLAYERS, LV_Private);	// returns false if we're already in a lobby
			OnlineLobby.ShowLobbyInviteInterface(Localize("Notifications", "InviteMessage", "KFGameConsole"));
		}
		else
		{
			OnlineLobby.MakeLobby(`KF_MAX_PLAYERS, LV_Friends);	// returns false if we're already in a lobby
			showFriendsListPopup();
		}
		//@SABER_EGS_END
	}
}

function showFriendsListPopup()
{
	Manager.DelayedOpenPopup(EFriendsList, EDPPID_ExitToMainMenu, 
	Class'KFCommon_LocalizedStrings'.default.FriendsListPopupTitleString, 
	"", 
	Class'KFCommon_LocalizedStrings'.default.ReturnString);
}

//==============================================================
// Party Widget Callbacks
//==============================================================
function Callback_PerkChanged(int PerkIndex)
{
	local KFPlayerController KFPC;

    KFPC = KFPlayerController(GetPC());
	if ( KFPC != none )
	{
		KFPC.RequestPerkChange( PerkIndex );

		if( KFPC.CanUpdatePerkInfo() )
		{
			KFPC.SetHaveUpdatePerk( true );
		}

		if( KFPC.MyGFxManager != none )
		{
			if( KFPC.MyGFxManager.CurrentMenu == KFPC.MyGFxManager.PerksMenu )
			{
				KFPC.MyGFxManager.PerksMenu.UpdateLock();
			}
		}
	}
}

function Callback_ProfileOption(string OptionKey, int SlotIndex)
{
	if( Manager != none && Manager.PartyWidget != none)
	{
		`log("OptionKey- " @OptionKey,,'DevGFxUI');
		Manager.PartyWidget.ProfileOptionClicked(OptionKey, SlotIndex);
	}
}

function Callback_CreateParty()
{
	local KFPlayerController KFPC;

	KFPC = KFPlayerController(GetPC());
	if (class'WorldInfo'.static.IsConsoleBuild())
	{
		KFPC.StartLogin(ConfirmCreateParty, true);
	}
	else
	{
		//@SABER_EGS_BEGIN EOS
		if (class'WorldInfo'.static.IsEOSBuild() && Manager != none) 
		{
			Manager.OnLobbyStatusChanged(true);	
		}		
		//@SABER_EGS_END
		ConfirmCreateParty();
	}
	
}

function Callback_LeaveParty()
{
	ShowLeavePartyPopUp();
}

function Callback_OpenPlayerList(int SlotIndex)
{
	if (Manager != none )
    {
    	if(Manager.PartyWidget !=none)
    	{
			Manager.PartyWidget.OpenPlayerList(SlotIndex);
		}
	}
}

function Callback_InviteFriend()
{
	local OnlineSubsystem OnlineSub;

	OnlineSub = class'GameEngine'.static.GetOnlineSubsystem();

	if ( Class'WorldInfo'.Static.IsConsoleBuild() )
	{

		if (OnlineSub != none && !OnlineSub.IsGameOwned() && !OnlineSub.IsFreeTrialPeriodActive() && class'WorldInfo'.static.IsConsoleBuild(CONSOLE_Orbis))
		{
			class'KFGFxMoviePlayer_Manager'.static.DisplayFreeTrialOverPopUp();
			return;
		}
		// We have main menu parties and in game sessions, be sure to show the right interface when we want to invite someone
		if(class'WorldInfo'.static.IsMenuLevel())
		{
			OnlineLobby.ShowLobbyInviteInterface(Localize("Notifications", "InviteMessage", "KFGameConsole"));
		}
		else
		{

			OnlineSub.PlayerInterfaceEx.ShowInviteUI(Manager.GetLP().ControllerId, "");
		}
	}
	else if ( OnlineLobby != none )
	{
		OnlineLobby.MakeLobby(`KF_MAX_PLAYERS, LV_Friends);	// returns false if we're already in a lobby
		showFriendsListPopup();
	}
}

/** Plays the view's open animation. */
function PlayOpenAnimation();

/** Plays the view's close animation. */
function PlayCloseAnimation(float AnimationRate )
{
	ActionScriptVoid("closeMenu");
}


//only called from the party widget chat
function Callback_BroadcastChatMessage(string Message)
{
	local PlayerReplicationInfo PRI;
	local string ChatMessage;

	PRI = GetPC().PlayerReplicationInfo;

    if(Message != "")
    {
    	if(class'WorldInfo'.static.IsMenuLevel())
    	{
    		ChatMessage = PRI.PlayerName$": " $Message;
			if ( OnlineLobby != none )
			{
				OnlineLobby.LobbyMessage(ChatMessage);
			}
		}
    	else
    	{
    		//game has started
    		if(Manager.bAfterLobby)
    		{
    			GetPC().TeamSay(Message);
    		}
	    	else
	    	{
	    		GetPC().Say(Message);
	    	}
    	}
    }
}

//From Party widget chat and aar chat
function Callback_ChatFocusIn()
{
	Manager.ClearFocusIgnoreKeys();
}

function Callback_ChatFocusOut()
{
	Manager.UpdateDynamicIgnoreKeys();
}

/** RETURN TO THESE FUNCTIONS */

/************************************************************************
* CONTROL FUNCTIONS
* give unreal functionality upon performing an event
* (ex. clicking apply options), if functionality is not listed here
* it is done in actionscript inside the .swf file
*************************************************************************/

/** Detects any input and passes it to the active view*/
event bool FilterButtonInput(int ControllerId, name ButtonName, EInputEvent InputEvent);

function SetControlScheme( bool bUseGamePad )
{
	ActionScriptVoid("setGamepadInput");
}

function Callback_MouseMoved()
{
 	SetControlScheme( false );
}

DefaultProperties
{
	//defaults
}
