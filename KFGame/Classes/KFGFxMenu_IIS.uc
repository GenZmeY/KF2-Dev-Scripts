//=============================================================================
// KFGFxMenu_IIS
//=============================================================================
// The Initial Interaction Screen displayed on Console.
//=============================================================================
//	Killing Floor 2
//  Bryan Brooks -  04/15/2016
//=============================================================================

class KFGFxMenu_IIS extends KFGFxObject_Menu
	native(UI)
	config(UI);

var delegate<OnAutoLoginComplete> AutoLoginCompleteDelegate;

/** TRUE if we are actively logging in */
var bool bLoggingIn;

var OnlineSubsystem OnlineSub;
var PlayfabInterface PlayfabInter;

/** TRUE if we need to force having a connection at login */
var bool bForceConnectionAtLogin;

/** Set once after menu has been closed for the first time */
var bool bClosed;

delegate OnAutoLoginComplete();

event AttemptAutoLogin(delegate<OnAutoLoginComplete> del = none)
{
	AutoLoginCompleteDelegate = del;
	LoginToGame();
}


function OnOpen()
{
	local string LoginTextString;
	local GFxObject PressStartTxtField;
	local KFGameEngine KFEngine;

	OnlineSub = class'GameEngine'.static.GetOnlineSubsystem();
	PlayfabInter = class'GameEngine'.static.GetPlayfabInterface();

	LoginTextString = ConsoleLocalize( "PressButtonToStart" );

	// For XB1, append the option to switch profiles
	if( class'WorldInfo'.static.IsConsoleBuild( CONSOLE_Durango ) )
	{
		LoginTextString @= "<br>"$ConsoleLocalize( "SwitchProfile" );

		PressStartTxtField = GetObject("textField");
		PressStartTxtField.SetBool("multiline", true);
	}

	SetString("loginText", LoginTextString );
	SetBool("showLoading", false);

	// We can use any controller right now
	class'Engine'.static.GetEngine().GameViewport.bAllowInputFromMultipleControllers = true;

	KFEngine = KFGameEngine( class'Engine'.static.GetEngine() );
	if( class'WorldInfo'.static.IsConsoleBuild( CONSOLE_Durango ) )
	{
		// Flag us as not yet logged in
		KFEngine.LocalLoginStatus = LS_NotLoggedIn;
	}

	// If there was a pending invite, we need to process that now
	if( KFEngine.GameSettingsForPendingInvite != none )
	{
		// Set the cached game settings on the invite result
		GetPC().CachedInviteResult.GameSettings = KFEngine.GameSettingsForPendingInvite;
		// Now we manually activate the user
		OnlineSub.ManuallyActivateUser(KFEngine.GameSettingsForPendingInvite.OwningPlayerId);
		// Clear the pending game settings. We have no use for it anymore
		KFEngine.GameSettingsForPendingInvite = none;
		// Try and accept the game invite again using the cached result (only game settings are needed really)
		GetPC().OnGameInviteAccepted( GetPC().CachedInviteResult, OGIAR_Success );
	}
	// If there was an error before getting to this screen, we need to display it now (usually sign out)
	else if( KFEngine.ReturnToIISConnectionErrorMessage != "" )
	{
		Manager.DelayedOpenPopup(ENotification, EDPPID_Misc, KFEngine.ReturnToIISConnectionErrorTitle, KFEngine.ReturnToIISConnectionErrorMessage,
			class'KFCommon_LocalizedStrings'.default.OKString );

		// Clear the cached messages
		KFEngine.ReturnToIISConnectionErrorTitle = "";
		KFEngine.ReturnToIISConnectionErrorMessage = "";
	}
}

event OnClose()
{
	local KFGameViewportClient GVC;

	bClosed = true;

	// Closing this menu.  Let the Game Viewport know that we've been here since it is persistent.
	GVC = KFGameViewportClient(GetGameViewportClient());
	if ( GVC != None )
	{
		GVC.bSeenIIS = true;
		GVC.bAllowInputFromMultipleControllers = false;
	}

	UnRegisterDelegates();
}


function UnRegisterDelegates()
{
	OnlineSub.PlayerInterface.ClearLoginCancelledDelegate(OnLoginCancelled);
	OnlineSub.PlayerInterface.ClearLoginStatusChangeDelegate(OnLoginStatusChanged, GetLP().ControllerId);
	OnlineSub.PlayerInterface.ClearReadProfileSettingsCompleteDelegate(GetLP().ControllerId, OnReadProfileSettingsComplete);
	OnlineSub.StatsInterface.ClearReadOnlineStatsCompleteDelegate(OnStatsRead);
}


event bool FilterButtonInput(int ControllerId, name ButtonName, EInputEvent InputEvent)
{
	if( bClosed )
	{
		// sanity check to prevent adding new delegates.  does not unclose -tripwire ZG
		`warn("FilterButtonInput called after IIS menu has been closed!");
		return false;
	}

	if( InputEvent == IE_Pressed && Manager != None && Manager.CurrentPopup == None )
	{
		if( ButtonName == 'XboxTypeS_A' )
		{
			// Activate this gamepad so we can pair whichever user is active to it
			OnlineSub.ActivateGamepad( ControllerId );

			// Controller ID may have changed
			if( ValidateActiveAccount( GetLP().ControllerId) )
			{
				// Uncomment to change visuals to the loading screen.
				LoginToGame();
			}

			return true;
		}
		// For xbox, we support changing profiles
		else if( class'WorldInfo'.static.IsConsoleBuild( CONSOLE_Durango ) && ButtonName == 'XboxTypeS_Y' )
		{
			if( !bLoggingIn && ValidateActiveAccount(ControllerId) )
			{
				OnlineSub.PlayerInterface.ShowLoginUI( ControllerId );
			}

			return true;
		}
	}

	return false;
}


function bool ValidateActiveAccount( byte ControllerId )
{
	local UniqueNetId NewUniqueId, ZeroId;

	if( class'WorldInfo'.static.IsConsoleBuild( CONSOLE_Durango ) )
	{
		// See if the controllerId is different
		if( ControllerId != GetLP().ControllerId )
		{
			// Assign new controller ID
			GetLP().ControllerId = ControllerId;
		}

		// If there is no user paired to the gamepad, show the login UI now
		OnlineSub.PlayerInterface.GetUniquePlayerId( ControllerId, NewUniqueId );
		if (NewUniqueId == ZeroId)
		{
			ShowLoginUI();
			return false;
		}
	}

	return true;
}


function ShowLoginUI()
{
	OnlineSub.PlayerInterface.AddLoginCancelledDelegate( OnLoginCancelled );
	OnlineSub.PlayerInterface.AddLoginStatusChangeDelegate( OnLoginStatusChanged, GetLP().ControllerId );
	OnlineSub.PlayerInterface.ShowLoginUI( GetLP().ControllerId );
}


// Called when user cancels people picker
function OnLoginCancelled()
{
	OnlineSub.PlayerInterface.ClearLoginCancelledDelegate( OnLoginCancelled );
	OnlineSub.PlayerInterface.ClearLoginStatusChangeDelegate( OnLoginStatusChanged, GetLP().ControllerId );

	// Show popup asking if player wants to play offline
	Manager.DelayedOpenPopup( EConfirmation, EDPPID_Misc, ConsoleLocalize( "NotSignedInTitle" ), ConsoleLocalize( "PlayOffline" ),
		class'KFCommon_LocalizedStrings'.default.OKString, class'KFCommon_LocalizedStrings'.Default.CancelString, OnConfirmPlayOffline, ShowLoginUI );
}


function OnConfirmPlayOffline()
{
	local UIDataStore_OnlinePlayerData PlayerDataDS;
	local OnlineProfileSettings ProfileSettings;

	PlayerDataDS = UIDataStore_OnlinePlayerData(class'UIInteraction'.static.GetDataStoreClient().FindDataStore('OnlinePlayerData', GetLP()));
	ProfileSettings = OnlineProfileSettings(PlayerDataDS.ProfileProvider.Profile);

	// Set the profile settings to default
	ProfileSettings.SetToDefaults();
	ProfileSettings.ExpandExtraFromProfileSettings();

	// Set the cached profile in the OSS so it can be referenced and saved to
	OnlineSub.SetCachedProfile( ProfileSettings );

	KFPlayerController(GetPC()).OnReadProfileSettingsComplete( GetLP().ControllerId, true );

	// Get the nickname of the local player
	GetPC().PlayerReplicationInfo.PlayerName = GetLP().GetNickname();
	GetPC().PlayerReplicationInfo.UniqueId = GetLP().GetUniqueNetId();

	// Flag us as using local profile
	KFGameEngine(class'Engine'.static.GetEngine()).LocalLoginStatus = LS_UsingLocalProfile;

	// Now we proceed to the main menu
	ProceedToMainMenu();
}


function OnLoginStatusChanged( ELoginStatus NewStatus, UniqueNetId NewId )
{
	OnlineSub.PlayerInterface.ClearLoginCancelledDelegate(OnLoginCancelled);
	OnlineSub.PlayerInterface.ClearLoginStatusChangeDelegate(OnLoginStatusChanged, GetLP().ControllerId);

	// Logged in, we can begin login process
	if( NewStatus == LS_LoggedIn )
	{
		LoginToGame();
	}
}


function LoginToGame()
{
	local UIDataStore_OnlinePlayerData PlayerDataDS;
	local string LoggingInText;
	local UniqueNetId ZeroId;

	if( bLoggingIn )
	{
		`warn("Ignoring login while one is already occurring");
		return;
	}
	bLoggingIn = true;

	LoggingInText = ConsoleLocalize( "LoggingIn");

	// Need to display the active user
	if( class'WorldInfo'.static.IsConsoleBuild(CONSOLE_Durango) && GetLP().GetUniqueNetId() != ZeroId )
	{
		LoggingInText = GetLP().GetNickname()$"<br>"$LoggingInText;
	}

	SetString("loginText", LoggingInText );
	SetBool("showLoading", true);

	// For XB1 we need to first read save data before attempting the "login"
	if( class'WorldInfo'.static.IsConsoleBuild( CONSOLE_Durango ) )
	{
		// Ensure we're completely erased attempting a login
		OnlineSub.PlayerInterface.Logout(GetLP().ControllerId);
		if( PlayfabInter != none )
		{
			PlayfabInter.Logout();
		}

		PlayerDataDS = UIDataStore_OnlinePlayerData(class'UIInteraction'.static.GetDataStoreClient().FindDataStore('OnlinePlayerData', GetLP()));
		OnlineSub.PlayerInterface.AddReadProfileSettingsCompleteDelegate(GetLP().ControllerId, OnReadProfileSettingsComplete);
		OnlineSub.PlayerInterface.ReadProfileSettings(GetLP().ControllerId, OnlineProfileSettings(PlayerDataDS.ProfileProvider.Profile));
	}
	else
	{
		KFPlayerController(GetPC()).StartLogin( OnLoginToGameComplete, AutoLoginCompleteDelegate != none );
	}
}


function OnReadProfileSettingsComplete(byte LocalUserNum,bool bWasSuccessful)
{
	`log("Profile settings read for"@LocalUserNum@"with success"@bWasSuccessful);

	OnlineSub.PlayerInterface.ClearReadProfileSettingsCompleteDelegate( GetLP().ControllerId, OnReadProfileSettingsComplete);
	// Ensure player controller updates its cached settings
	KFPlayerController(GetPC()).OnReadProfileSettingsComplete( LocalUserNum, bWasSuccessful );

	// Set the ID of the owning player
	KFPlayerController(GetPC()).SetStatsReadOwningPlayerId( GetLP().GetUniqueNetId() );

	// Now proceed with login
	KFPlayerController(GetPC()).StartLogin(OnLoginToGameComplete, AutoLoginCompleteDelegate != none);
}


function OnLoginToGameComplete()
{
	// Detect logout during "login" process
	if (OnlineSub.PlayerInterface.GetLoginStatus(GetLP().ControllerId) != LS_LoggedIn && class'WorldInfo'.static.IsConsoleBuild(CONSOLE_Durango))
	{
		return;
	}

	// Flag us as logged in
	KFGameEngine(class'Engine'.static.GetEngine()).LocalLoginStatus = LS_LoggedIn;

	// Now we kick off stats read
	OnlineSub.StatsInterface.AddReadOnlineStatsCompleteDelegate(OnStatsRead);
	KFPlayerController(GetPC()).ReadStats();
}

//read stats after we login because the login process will read title data.
//title data will give us bunches of information like any seasonal events.
function OnStatsRead( bool bWasSuccessful )
{
	`log("stats read with success"@bWasSuccessful);

	OnlineSub.StatsInterface.ClearReadOnlineStatsCompleteDelegate( OnStatsRead );

	ProceedToMainMenu();

	if (AutoLoginCompleteDelegate != none)
	{
		AutoLoginCompleteDelegate();
		AutoLoginCompleteDelegate = none;
	}
}


function ProceedToMainMenu()
{
	local KFPlayerController PC;

	PC = KFPlayerController(GetPC());

	PC.ResetPerkStatsLoaded();
	PC.ClientInitializePerks();

	Manager.PartyWidget.RefreshParty();

	// For now just opening the start menu.
	Manager.OpenMenu( UI_Start );
	bLoggingIn = false;

	// Set up special event if there is one
	class'KFGameEngine'.static.InitEventContent();

	if(Manager != none)
	{
		Manager.UpdateBackgroundMovie();
		if(Manager.StartMenu.MissionObjectiveContainer != none)
		{
			Manager.StartMenu.MissionObjectiveContainer.UpdateMissionObjectiveState();
		}
        PC.UpdateSeasonalState();
	}

	// We no longer allow input from multiple controllers. Only the active one
	class'Engine'.static.GetEngine().GameViewport.bAllowInputFromMultipleControllers = false;

	// For XB1, we throw the gamma popup now
	if( class'WorldInfo'.static.IsConsoleBuild( CONSOLE_Durango ) )
	{
		// Check and see if we need to set safe frame first
		if( !Manager.CachedProfile.HasSafeFrameSet() )
		{
			Manager.OpenScreenSizeMovie();
		}
		// Check for brightness
		else if( !Manager.bSetGamma && !class'KFGameEngine'.static.CheckSkipGammaCheck() )
		{
			PC.SetTimer( 0.01, false, nameof(DelayedOpenGammaPopup), self );
		}
	}

	// If controller is not connected when proceeding to main menu. We need to show the controller disconnect dialog again
	if( class'WorldInfo'.static.IsConsoleBuild( CONSOLE_Durango ) &&
		!OnlineSub.SystemInterface.IsControllerConnected(GetLP().ControllerId) &&
		!class'Engine'.static.GetEngine().GameViewport.bNeedsNewGamepadPairingForNewProfile )
	{
		PC.SetTimer( 0.01, false, 'ShowControllerDisconnectedDialog' );
	}
	PC.CheckPrivilegesForMultiplayer();
}

function DelayedOpenGammaPopup()
{
	Manager.ManagerObject.SetBool("bStartUpGamma", true);   // Let the manager know if we are gamma for start up so we can block backing out of the popup - HSL
	Manager.DelayedOpenPopup(EGamma, EDPPID_Gamma, "", Class'KFGFxOptionsMenu_Graphics'.default.AdjustGammaDescription, Class'KFGFxOptionsMenu_Graphics'.default.ResetGammaString, Class'KFGFxOptionsMenu_Graphics'.default.SetGammaString);
}


function NotifyLoginFailed()
{
	// Detect logout during "login" process
	if (OnlineSub.PlayerInterface.GetLoginStatus(GetLP().ControllerId) != LS_LoggedIn && class'WorldInfo'.static.IsConsoleBuild(CONSOLE_Durango))
	{
		return;
	}

	// We still proceed to main menu
	ProceedToMainMenu();
}


defaultproperties
{
	bForceConnectionAtLogin=false
}