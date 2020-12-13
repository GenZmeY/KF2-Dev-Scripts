/**
 * Copyright 1998-2012 Epic Games, Inc. All Rights Reserved.
 */

class OnlineSubsystemDingo extends OnlineSubsystemCommonImpl
	native
	implements(OnlinePlayerInterface, OnlinePlayerInterfaceEx, OnlineVoiceInterface,OnlineSystemInterface)
	config(Engine)
	inherits(FCallbackEventDevice);

/** The object that handles the game DVR interface implementation */
var OnlineGameDVRInterfaceDingo GameDVRInterfaceImpl;

/** The object that handles the stats interface implementation */
var OnlineStatsInterfaceDingo StatsInterfaceImpl;

/** The object that handles the title-file interface implementation */
var OnlineTitleFileInterfaceDingo TitleFileInterfaceImpl;

/** The object that handles the community content interface implementation */
var OnlineCommunityContentInterfaceDingo CommunityContentInterfaceImpl;

/** The object that handles the marketplace interface implementation */
var OnlineMarketplaceInterfaceDingo MarketplaceInterfaceImpl;

/** The object that handles the content interface implementation */
var OnlineContentInterfaceDingo ContentInterfaceImpl;

//@HSL_BEGIN - urias.rooney@hardsuitlabs.com – 12/08/16 - Dingo Party Interface
/** The object that handles the lobby interface implementation */
var KFOnlineLobbyDingo LobbyInterface;
//@HSL_END

/** These variables are used for limiting connection status flapping */
var EOnlineServerConnectionStatus CurrentConnectionStatus;
var EOnlineServerConnectionStatus DesiredConnectionStatus;
var float ConnectionTimeUpdateDelta;

/**
 * This is the array of queued async tasks that will be held until
 * the game is activated and will then be transferred to the standard async
 * task array.
 */
var native const array<pointer> QueuedActivationAsyncTasks{FQueuedOnlineAsyncTaskDingo};

/**
 * This is the array of pending async tasks. Each tick these tasks are checked
 * for completion. If complete, the delegate associated with them is called
 */
var native const array<pointer> AsyncTasks{FOnlineAsyncTaskDingo};

/** The directory profile data should be stored in */
var config string ProfileDataDirectory;

/** The file extension to use when saving profile data */
var config string ProfileDataExtension;

/** The array of delegates that notify the completion of OnlineProfile reads */
var array<delegate<OnReadOnlineProfilesComplete> > ReadOnlineProfileDelegates;

/** The cached profile for the player */
var OnlineProfileSettings CachedProfile;

/** The list of delegates to notify when the keyboard input is complete */
var array<delegate<OnKeyboardInputComplete> > KeyboardInputDelegates;

/** Was the keyboard input canceled? */
var byte KeyboardInputWasCanceled;

/** Holds the last keyboard input results */
var string KeyboardInputResults;

/** List of callbacks to notify when speech recognition is complete */
var array<delegate<OnRecognitionComplete> > SpeechRecognitionCompleteDelegates;

/** The array of delegates that notify read completion of the friends list data */
var array<delegate<OnReadFriendsComplete> > ReadFriendsDelegates;

/** The array of delegates that notify that the friends list has changed */
var array<delegate<OnFriendsChange> > FriendsChangeDelegates;

/** The array of delegates that notify that the mute list has changed */
var array<delegate<OnMutingChange> > MutingChangeDelegates;

/** The array of delegates that notify that help has been shown */
var array<delegate<OnShowHelpComplete> > ShowHelpDelegates;

/** The array of delegates that notify the token and signature have been retrieved */
var array<delegate<OnTokenAndSignatureRetrieved> > TokenAndSignatureDelegates;

/** The array of delegates that notify that help has been shown */
var array<delegate<OnShowGamerCardComplete> > ShowGamerCardCompleteDelegates;

/** Holds the list of delegates to fire when any login changes */
var array<delegate<OnLoginChange> > LoginChangeDelegates;

/** This is the list of requested delegates to fire when a login is cancelled */
var array<delegate<OnLoginCancelled> > LoginCancelledDelegates;

/** This is the list of delegates to fire when the current user changes */
var array<delegate<OnCurrentUserChanged> > CurrentUserChangedDelegates;

/** This is the list of requested delegates to fire when a login fails to process */
var array<delegate<OnLoginFailed> > LoginFailedDelegates;

/** This is the list of requested delegates to fire when a login finishes*/
var array<delegate<OnLoginComplete> > OnLoginCompleteDelegates;

/** This is the list of delegates to fire when a controller is connected/disconnected */
var array<delegate<OnControllerChange> > ControllerChangeDelegates;

/** This is the list of delegates to fire when a system user controller pairing event occurs */
var array<delegate<OnSystemUserControllerPairingChanged> > UserControllerPairingChangeDelegates;

/** This is the list of delegates to fire when a connection status change occurs */
var array<delegate<OnConnectionStatusChange> > ConnectionStatusChangeDelegates;

/** This is the list of delegates to fire when the game gains or loses focus */
var array<delegate<OnFocusChange> > FocusChangeDelegates;

/** The array of delegates to notify that a privilege check has completed */
var array<delegate<OnPrivilegeLevelChecked> > PrivilegeCheckedDelegates;

/** The array of delegates to notify that permissions have been checked on a per-user basis */
var array<delegate<OnPrivilegeCheckedForUsers> > PrivilegeCheckedForUsersDelegates;

/** The array of delegates to notify when a local talker registration completes */
var array<delegate<OnRegisterLocalTalkerComplete> > RegisterLocalTalkerCompleteDelegates;

/** The array of delegates to notify when a local talker unregistration completes */
var array<delegate<OnUnregisterLocalTalkerComplete> > UnregisterLocalTalkerCompleteDelegates;

/** The array of delegates to notify when a remote talker unregistration completes */
var array<delegate<OnUnregisterRemoteTalkerComplete> > UnregisterRemoteTalkerCompleteDelegates;

/** The array of delegates to notify when the user account info has been retrieved */
var array<delegate<OnUserAccountInfoRetrieved> > UserAccountInfoRetrievedDelegates;

/** The array of delegates to notify when a remote talker is talking or not */
var array<delegate<OnRemoteTalkerStatusChange> > RemoteTalkerStatusChangeDelegates;

/** Keep track of what user/contexts have connected to RTA services */
var native Map{FString, UBOOL} UsersConnectedToRTA;

/** The array of delegates to notify when a people picker operation is complete */
var array<delegate<OnPeoplePickerComplete> > PeoplePickerCompleteDelegates;
var array<delegate<OnAccountPickerComplete> > AccountPickerCompleteDelegates;

/** The array of delegates for when trial mode status has been updated */
var array<delegate<OnTrialModeUpdate> > TrialModeUpdateDelegates;

/** Holds the login state, xuids for a player */
struct native CachedLoginState
{
	/** The type of login for this player previously */
	var const ELoginStatus LoginStatus;
	/** The xuid for the signed in player */
	var const UniqueNetId PlayerXuid;
};

/** The cached state of each player's login status */
var native const CachedLoginState LastLoginState[`MAX_NUM_PLAYERS];

/** Holds the avatar, xuids for player */
struct native CachedAvatarData
{
	var const UniqueNetId PlayerXuid;
	var init array<byte> AvatarBytes;
	var float AvatarCreationTime;
};
var native array<CachedAvatarData> CachedAvatars;

/** Queued controller pairing changes to pass to the game for handling */
var native array<hatpointer> QueuedControllerPairingChangeEvents {Windows::Xbox::Input::ControllerPairingChangedEventArgs};

/** Should we allowed user status processing to occur? When the app is suspended, we disable this processing until
    the app is activated again */
var native const bool bAllowUserStateProcessing;

/** Keeps track if the app/game is focused or not */
var native const bool bIsAppInFocus;

/** Keeps track if the app/game is in constrained mode */
var native const bool bIsAppConstrained;

/** Keeps track if the app/game is suspended or not */
var native const bool bIsAppSuspended;

/** Have we received a login state change message? */
var native const bool bLoginStatusUpdated;

/** TRUE if the login status updated while suspended */
var const bool bLoginStatusUpdatedWhileSuspended;

/** TRUE if people picker is active */
var const bool bPeoplePickerActive;

/** Have we received a current user changed message? */
var native const bool bCurrentUserChanged;

/** Have we received a connection status change message? */
var native const bool bConnectionStatusUpdated;

/** Do we need to refresh Marketplace Inventory */
var native const bool bRefreshMarketplaceInventory;

//@TW_BEGIN | Adam Massingale | KFII-37834 Added this bool to force inventory checks to playfab when store page is closed since
//Microsoft's productpurchsed event unreliable
/** Did we just see the marketplace ui? is only set briefly */
var native const bool bMarketplaceUIWasSeen;
//@TW_END

/** Are we connected to the LIVE network? */
var native const bool bConnectedToLIVENetwork;

/** Have we received a user controller pairing change message? */
var native const bool bControllerPairingChanged;

/** Have we received info about license updated */
var native const bool bLisenceInfoUpdated;

/** Have we received a product purchased event? */
var const bool bProductPurchased;

/** Were we activated on the previous frame? */
var native const bool bWasActivated;

var const bool bAudioDeviceAdded;

/** TRUE if the local user is currently being registered for voice */
var const bool bLocalUserRegisteringForVoice;

/** TRUE if everybody should be muted */
var const bool PlayerMuteSetting;

/** TRUE if we have already checked the cmdline for a cross game invite */
var const bool bProcessedLaunchGameInvite;

/** The pending game invite command that comes in from the system. Used to store so we can process on the main thread */
var const string PendingGameInviteCmd;

/**
 * Information about a remote talker's priority
 *
 * Zero means highest priority, < zero means muted
 */
struct native TalkerPriority
{
	/** Holds the current priority for this talker */
	var int CurrentPriority;
	/** Holds the last priority for this talker */
	var int LastPriority;
};

/** Information about a remote talker */
struct native DingoRemoteTalker extends RemoteTalker
{
	/** Holds the priorities for each of the local players */
	var TalkerPriority LocalPriorities[`MAX_NUM_PLAYERS];

    var byte bReceivedAddMessage;

    /** TRUE if this talker is muted */
    var bool bMuted;

	structcpptext
	{
		/** @return TRUE if any of the local players have this player muted, otherwise FALSE */
		inline UBOOL IsLocallyMuted(void)
		{
			//for (INT Index = 0; Index < ARRAY_COUNT(LocalPriorities); Index++)
			//{
			//	if (LocalPriorities[Index].CurrentPriority == XHV_PLAYBACK_PRIORITY_NEVER)
			//	{
			//		return TRUE;
			//	}
			//}
			return FALSE;
		}
	}
};

/** Holds information about each of the local talkers */
var LocalTalker LocalTalkers[`MAX_NUM_PLAYERS];

/** Array of registered remote talkers */
var array<DingoRemoteTalker> RemoteTalkers;

/** Array or Remote Talkers waiting for a local talker to be registered */
var native array<UniqueNetId> PendingRemoteTalkerRegisters;

/** The list of voice IDs that have been registered. MUST be thread safe */
var array<UniqueNetId> VoiceRegisteredIds;

/** Holds the list of delegates that are interested in receiving talking notifications */
var array<delegate<OnPlayerTalkingStateChange> > TalkingDelegates;

/** Since the static array of dynamic array syntax appears to be broken */
struct native PerUserDelegateLists
{
	/** This is the list of requested delegates to fire */
	var array<delegate<OnLoginStatusChange> > LoginStatusChangeDelegates;
	/** The array of delegates for notifying when speech recognition has completed for a player */
	var array<delegate<OnRecognitionComplete> > SpeechRecognitionDelegates;
	/** The array of delegates for notifying when an achievement write has completed */
	var array<delegate<OnUnlockAchievementComplete> > AchievementDelegates;
	/** The array of delegates for notifying when an achievements list read has completed */
	var array<delegate<OnReadAchievementsComplete> > AchievementReadDelegates;
	/** The array of delegates for reading profile settings */
	var array<delegate<OnReadProfileSettingsComplete> > ReadProfileSettingsDelegates;
	/** The array of delegates that notify write completion of profile data */
	var array<delegate<OnWriteProfileSettingsComplete> > WriteProfileSettingsDelegates;
};

/** Per user array of array of delegates */
var PerUserDelegateLists PerUserDelegates[`MAX_NUM_PLAYERS];

/** The amount of time between voice notifications */
var config float VoiceNotificationDelta;

/** Holds the cached state of the friends list for a single player */
struct native FriendsListCache
{
	/** The list of returned friends */
	var init array<OnlineFriend> Friends;
	/** Indicates the state of the async read */
	var EOnlineEnumerationReadState ReadState;
	/** The array of delegates that notify read completion of the friends list data */
	var init array<delegate<OnReadFriendsComplete> > ReadFriendsDelegates;
	/** The array of delegates that notify that the friends list has changed */
	var init array<delegate<OnFriendsChange> > FriendsChangeDelegates;
};

/** Cache of friends data per player */
var native map{QWORD,FFriendsListCache} FriendsCache;

/** Cache of current presence data */
var native map{INT,FString} PresenceCache;

/** Holds the cached achievements for a single player */
struct native CachedAchievements
{
	/** The player these are for */
	var native QWORD PlayerXUID;
	/** The title id that these are for */
	var int TitleId;
	/** The list of achievements for this player and title */
	var init array<AchievementDetails> Achievements;
	/** Indicates the state of the async read */
	var EOnlineEnumerationReadState ReadState;

	structcpptext
	{
		FCachedAchievements () : ReadState(OERS_NotStarted) {}
	}
};

/** Holds the list of achievements that have been read for players */
var array<CachedAchievements> AchievementsCache;

var config string ProductID;
var const string ServiceConfigId;
var config string DefaultSessionKeyword;
var config string DefaultHopperName;

struct native CountryRegionMapping
{
	/** The country code*/
	var const int CountryCode;
	/** The matching region */
	var const int MatchingRegion;
};

/** The mappings from country to matchmaking region */
var const config array<CountryRegionMapping> CountryMatchmakingRegionMappings;


var native hatpointer ShowContentAsyncAction{Windows::Foundation::IAsyncAction};

/** The active license info for the app */
var native hatpointer ActiveLicenseInfo{Windows::ApplicationModel::Store::LicenseInformation};

/**
 * Called from engine start up code to allow the subsystem to initialize
 *
 * @return TRUE if the initialization was successful, FALSE otherwise
 */
native event bool Init();

/**
 * Called from the engine shutdown code to allow the subsystem to release any
 * resources that may have been allocated
 */
native event Exit();

/**
 * Delegate used in login notifications
 *
 * @param LocalUserNum the player that had the login change
 */
delegate OnLoginChange(byte LocalUserNum);

/**
 * Delegate used to notify when a login request was cancelled by the user
 */
delegate OnLoginCancelled();

/**
 * Delegate called when the current user changes
 *
 * @param LocalUserNum - The index of the player who is now the current user
 * @param CurrentUser  - The current user's Gamertag
 * @param LoggedInUser - The logged in user's Gamertag
 */
delegate OnCurrentUserChanged(byte LocalUserNum, string CurrentUser, string LoggedInUser);

/**
 * Delegate used in mute list change notifications
 */
delegate OnMutingChange();

/**
 * Called when a player is talking either locally or remote. This will be called
 * once for each active talker each frame.
 *
 * @param Player the player that is talking
 * @param bIsTalking if true, the player is now talking, if false they are no longer talking
 */
delegate OnPlayerTalkingStateChange(UniqueNetId Player,bool bIsTalking);

/**
 * Adds a talker delegate to the list of notifications
 *
 * @param TalkerDelegate the delegate to call when a player is talking
 */
function AddPlayerTalkingDelegate(delegate<OnPlayerTalkingStateChange> TalkerDelegate)
{
    `AddUniqueItemToArray(RemoteTalkerStatusChangeDelegates, TalkerDelegate);
}

/**
 * Removes a talker delegate to the list of notifications
 *
 * @param TalkerDelegate the delegate to remove from the notification list
 */
function ClearPlayerTalkingDelegate(delegate<OnPlayerTalkingStateChange> TalkerDelegate)
{
    RemoteTalkerStatusChangeDelegates.RemoveItem(TalkerDelegate);
}

/**
 * Delegate used in friends list change notifications
 */
delegate OnFriendsChange();

/**
 * Determine if the player is registered in the specified session
 *
 * @param PlayerId the player to check if in session or not
 * @return TRUE if the player is a registrant in the session
 */
native function bool IsPlayerInSession(name SessionName,UniqueNetId PlayerId);

/**
 * Get a list of the net ids for the players currently registered on the session
 *
 * @param SessionName name of the session to find
 * @param OutRegisteredPlayers [out] list of player net ids in the session (empty if not found)
 */
function GetRegisteredPlayers(name SessionName,out array<UniqueNetId> OutRegisteredPlayers)
{
	local int Idx,PlayerIdx;

	OutRegisteredPlayers.Length = 0;
	for (Idx=0; Idx < Sessions.Length; Idx++)
	{
		// find session by name
		if (Sessions[Idx].SessionName == SessionName)
		{
			// return list of player ids currently registered on the session
			OutRegisteredPlayers.Length = Sessions[Idx].Registrants.Length;
			for (PlayerIdx=0; PlayerIdx < Sessions[Idx].Registrants.Length; PlayerIdx++)
			{
				OutRegisteredPlayers[PlayerIdx] = Sessions[Idx].Registrants[PlayerIdx].PlayerNetId;
			}
			break;
		}
	}
}

/**
 * Displays the UI that prompts the user for their login credentials. Each
 * platform handles the authentication of the user's data.
 *
 * @param bShowOnlineOnly whether to only display online enabled profiles or not
 *
 * @return TRUE if it was able to show the UI, FALSE if it failed
 */
native function bool ShowLoginUI(byte LocalUserNum, optional bool bShowOnlineOnly = false);

delegate OnAccountPickerComplete( bool bForceLogin );

function AddAccountPickerCompleteDelegate(delegate<OnAccountPickerComplete> InDelegate)
{
    `AddUniqueItemToArray(AccountPickerCompleteDelegates, InDelegate);
}

function RemoveAccountPickerCompleteDelegate(delegate<OnAccountPickerComplete> InDelegate)
{
    AccountPickerCompleteDelegates.RemoveItem(InDelegate);
}

/**
 * Logs the player into the online service. If this fails, it generates a
 * OnLoginFailed notification
 *
 * @param LocalUserNum the controller number of the associated user
 * @param LoginName the unique identifier for the player
 * @param Password the password for this account
 * @param bWantsLocalOnly whether the player wants to sign in locally only or not
 *
 * @return true if the async call started ok, false otherwise
 */
native function bool Login(byte LocalUserNum,optional string LoginName="",optional string Password="",optional bool bWantsLocalOnly);

delegate OnLoginComplete( byte LocalUserNum, bool bWasSuccessful, EOnlineServerConnectionStatus ErrorCode );
function AddLoginCompleteDelegate(byte LocalUserNum, delegate<OnLoginComplete> InDelegate)
{
	`AddUniqueItemToArray(OnLoginCompleteDelegates, InDelegate);
}
function ClearLoginCompleteDelegate(byte LocalUserNum, delegate<OnLoginComplete> InDelegate)
{
	OnLoginCompleteDelegates.RemoveItem(InDelegate);
}

/**
 * Logs the player into the online service using parameters passed on the
 * command line. Expects -Login=<UserName> -Password=<password>. If either
 * are missing, the function returns false and doesn't start the login
 * process
 *
 * @return true if the async call started ok, false otherwise
 */
function bool AutoLogin()
{
	return false;
}

/**
 * Delegate used in notifying the UI/game that the manual login failed
 *
 * @param LocalUserNum the controller number of the associated user
 * @param ErrorCode the async error code that occurred
 */
delegate OnLoginFailed(byte LocalUserNum,EOnlineServerConnectionStatus ErrorCode);

/**
 * Sets the delegate used to notify the gameplay code that a login failed
 *
 * @param LocalUserNum the controller number of the associated user
 * @param FailedDelegate the delegate to use for notifications
 */
function AddLoginFailedDelegate(byte LocalUserNum,delegate<OnLoginFailed> FailedDelegate)
{
	`AddUniqueItemToArray(LoginFailedDelegates, FailedDelegate);
}

/**
 * Removes the specified delegate from the notification list
 *
 * @param LocalUserNum the controller number of the associated user
 * @param FailedDelegate the delegate to use for notifications
 */
function ClearLoginFailedDelegate(byte LocalUserNum,delegate<OnLoginFailed> FailedDelegate)
{
	LoginFailedDelegates.RemoveItem(FailedDelegate);
}

/**
 * Signs the player out of the online service
 *
 * @param LocalUserNum the controller number of the associated user
 *
 * @return TRUE if the call succeeded, FALSE otherwise
 */
native function bool Logout(byte LocalUserNum);

/**
 * Delegate used in notifying the UI/game that the manual logout completed
 *
 * @param bWasSuccessful whether the async call completed properly or not
 */
delegate OnLogoutCompleted(bool bWasSuccessful);

/**
 * Sets the delegate used to notify the gameplay code that a logout completed
 *
 * @param LocalUserNum the controller number of the associated user
 * @param LogoutDelegate the delegate to use for notifications
 */
function AddLogoutCompletedDelegate(byte LocalUserNum,delegate<OnLogoutCompleted> LogoutDelegate);

/**
 * Removes the specified delegate from the notification list
 *
 * @param LocalUserNum the controller number of the associated user
 * @param LogoutDelegate the delegate to use for notifications
 */
function ClearLogoutCompletedDelegate(byte LocalUserNum,delegate<OnLogoutCompleted> LogoutDelegate);

/**
 * Delegate used to notify the game that the system has detected a user controller pairing change
 * NOTE: This will not change the engine's user controller pairing. To do that, the game must call PairUserAndControllerAtIndex(...)
 *       in response to this delegate.
 *
 * @param NewLocalUserNum the index of the user now associated with the controller, INDEX_NONE if the controller no longer has a paired user
 * @param PreviousLocalUserNum the index of the user previously associated with the controller, INDEX_NONE if the controller was not previously paired
 */
delegate OnSystemUserControllerPairingChanged(INT NewLocalUserNum, INT PreviousLocalUserNum);

/**
 * Sets the delegate used to notify the game that a system user controller pairing change has occurred
 *
 * @param PairingChangeDelegate the delegate to use for notification
 */
function AddSystemUserContrllerPairingChangedDelegate(delegate<OnSystemUserControllerPairingChanged> PairingChangeDelegate)
{
	`AddUniqueItemToArray(UserControllerPairingChangeDelegates, PairingChangeDelegate);
}

/**
 * Removes the specified delegate from the notification list
 *
 * @param PairingChangeDelegate the delegate to remove from notification
 */
function ClearSystemUserContrllerPairingChangedDelegate(delegate<OnSystemUserControllerPairingChanged> PairingChangeDelegate)
{
	UserControllerPairingChangeDelegates.RemoveItem(PairingChangeDelegate);
}

/**
 * Gets added into UserControllerPairingChangeDelegates
 * @param NewLocalUserNum the index of the user now associated with the controller, INDEX_NONE if the controller no longer has a paired user
 * @param PreviousLocalUserNum the index of the user previously associated with the controller, INDEX_NONE if the controller was not previously paired
 */
native function OnUserControllerPairingChanged(INT NewLocalUserNum, INT PreviousLocalUserNum);

/**
 * Adds OnUserControllerPairingChanged to UserControllerPairingChangeDelegates
 */
event AddOnSystemUserControllerPairingChangedDelegate()
{
	AddSystemUserContrllerPairingChangedDelegate(OnUserControllerPairingChanged);
}

/**
 * Clears OnUserControllerPairingChanged from UserControllerPairingChangeDelegates
 */
event ClearOnSystemUserControllerPairingChangedDelegate()
{
	ClearSystemUserContrllerPairingChangedDelegate(OnUserControllerPairingChanged);
}

//@HSL_BEGIN - urias.rooney@hardsuitlabs.com – 12/08/16 - Dingo Party Interface
/**
 * Called from native code to assign the lobby interface
 *
 * @param NewInterface	The object to assign as providing the lobby interface
 * @return		Returns True if the interface is valid, False otherwise
 */
event bool SetLobbyInterface( object NewInterface )
{
	LobbyInterface = KFOnlineLobbyDingo( NewInterface );
	// Will return false if the interface isn't supported
    return LobbyInterface != none && LobbyInterface.Initialize();
}

function TWOnlineLobby GetLobbyInterface()
{
	return LobbyInterface;
}
//@HSL_END

/**
 * Pairs a player and controller at a given index
 *
 * @param PlayerIndex the index of the desired player to pair
 * @param ControllerIndex the index of the desired controller to pair
 * @param PairIndex the index to pair at
 *
 * @return true if successfull, false otherwise
 */
native function bool PairUserAndControllerAtIndex(byte PlayerIndex, byte ControllerIndex, INT PairIndex);

/**
 * Fetches the login status for a given player
 *
 * @param LocalUserNum the controller number of the associated user
 *
 * @return the enum value e e of their status
 */
native function ELoginStatus GetLoginStatus(byte LocalUserNum);

/**
 * Gets the platform specific unique id for the specified player
 *
 * @param LocalUserNum the controller number of the associated user
 * @param PlayerId the byte array that will receive the id
 *
 * @return TRUE if the call succeeded, FALSE otherwise
 */
native function bool GetUniquePlayerId(byte LocalUserNum,out UniqueNetId PlayerId);

/**
 * Gets the ControllerId for the platform specific unique Id
 *
 * @param PlayerId the platform specific unique Id
 * @param ControllerId the byte that will receive the controllerId
 *
 * @return TRUE if the call succeeded, FALSE otherwise
 */
native function bool GetControllerIdFromNetId(UniqueNetId PlayerId, out byte ControllerId);

native function ManuallyActivateUser( const UniqueNetId ForUniqueId );

native function ActivateGamepad( const int GamepadIndex );

/**
 * Reads the player's nick name from the online service
 *
 * @param LocalUserNum the controller number of the associated user
 *
 * @return a string containing the players nick name
 */
native function string GetPlayerNickname(byte LocalUserNum);

native function bool GetUserAccountInfo( byte LocalUserNum );

delegate OnUserAccountInfoRetrieved( bool bSuccessful, UserAccountInfo AccountInfo );

function AddGetUserAccountInfoDelegate( delegate<OnUserAccountInfoRetrieved> InDelegate )
{
    `AddUniqueItemToArray(UserAccountInfoRetrievedDelegates, InDelegate);
}

function ClearGetUserAccountInfoDelegate( delegate<OnUserAccountInfoRetrieved> InDelegate )
{
    UserAccountInfoRetrievedDelegates.RemoveItem(InDelegate);
}

/**
 * Delegate called when a user's privilege level has been checked
 *
 * @param LocalUserNum -  the player that checked a privilege level
 * @param Privilege - the privilege that was checked
 * @param PrivilegeLevel - the privilege level for the given user for the requested Privilege
 * @param bDiffersFromHint - does the returned privilege level differ from the hint that was given earlier?
 */
delegate OnPrivilegeLevelChecked(byte LocalUserNum, EFeaturePrivilege Privilege, EFeaturePrivilegeLevel PrivilegeLevel, bool bDiffersFromHint);

/**
 * Sets the delegate used to notify the gameplay code that a privilege check was completed
 *
 * @param PrivilegeDelegate the delegate to use for notifications
 */
function AddPrivilegeLevelCheckedDelegate(delegate<OnPrivilegeLevelChecked> PrivilegeDelegate)
{
	`AddUniqueItemToArray(PrivilegeCheckedDelegates, PrivilegeDelegate);
}

/**
 * If player does not have a systems premium online services then use this to upsell them
 */
function UpsellPremiumOnlineService();

/**
 * Removes the specified delegate from the notification list
 *
 * @param PrivilegeDelegate the delegate to use for notifications
 */
function ClearPrivilegeLevelCheckedDelegate(delegate<OnPrivilegeLevelChecked> PrivilegeDelegate)
{
	PrivilegeCheckedDelegates.RemoveItem(PrivilegeDelegate);
}

delegate OnPrivilegeCheckedForUsers(byte LocalUserNum, EFeaturePrivilege Privilege, array<PermissionsResult> Results);

function AddPrivilegeCheckedForUsersDelegate(delegate<OnPrivilegeCheckedForUsers> PrivilegeDelegate)
{
    `AddUniqueItemToArray(PrivilegeCheckedForUsersDelegates, PrivilegeDelegate);
}

function ClearPrivilegeCheckedForUsersDelegate(delegate<OnPrivilegeCheckedForUsers> PrivilegeDelegate)
{
    PrivilegeCheckedForUsersDelegates.RemoveItem(PrivilegeDelegate);
}

/**
 * Determines whether the player is allowed to play online
 *
 * @param LocalUserNum the controller number of the associated user
 * @param PrivilegeLevelHint upon completion, this parameter holds a hint about the expected value being retrieved asynchronously
 * @param bAttemptToResolve if the user does not have the proper privilege, should the system attempt to resolve the issue (eg via upsell)
 * @param Reason friendly display string explaining privilege failure
 *
 * @return true if the call succeeds, false otherwise
 */
native function bool CanPlayOnline(byte LocalUserNum, out EFeaturePrivilegeLevel PrivilegeLevelHint, optional bool bAttemptToResolve = false, optional string Reason = "");

/**
 * Determines whether the player is allowed to use text chat online
 *
 * @param LocalUserNum the controller number of the associated user
 * @param PrivilegeLevelHint upon completion, this parameter holds a hint about the expected value being retrieved asynchronously
 * @param bAttemptToResolve if the user does not have the proper privilege, should the system attempt to resolve the issue (eg via upsell)
 * @param Reason friendly display string explaining privilege failure
 *
 * @return true if the call succeeds, false otherwise
 */
native function bool CanCommunicateText(byte LocalUserNum, out EFeaturePrivilegeLevel PrivilegeLevelHint, optional bool bAttemptToResolve = false, optional string Reason = "");

/**
 * Determines whether the player is allowed to use video chat online
 *
 * @param LocalUserNum the controller number of the associated user
 * @param PrivilegeLevelHint upon completion, this parameter holds a hint about the expected value being retrieved asynchronously
 * @param bAttemptToResolve if the user does not have the proper privilege, should the system attempt to resolve the issue (eg via upsell)
 * @param Reason friendly display string explaining privilege failure
 *
 * @return true if the call succeeds, false otherwise
 */
native function bool CanCommunicateVideo(byte LocalUserNum, out EFeaturePrivilegeLevel PrivilegeLevelHint, optional bool bAttemptToResolve = false, optional string Reason = "");

/**
 * Determines whether the player is allowed to use voice chat online
 *
 * @param LocalUserNum the controller number of the associated user
 * @param PrivilegeLevelHint upon completion, this parameter holds a hint about the expected value being retrieved asynchronously
 * @param bAttemptToResolve if the user does not have the proper privilege, should the system attempt to resolve the issue (eg via upsell)
 * @param Reason friendly display string explaining privilege failure
 *
 * @return true if the call succeeds, false otherwise
 */
native function bool CanCommunicateVoice(byte LocalUserNum, out EFeaturePrivilegeLevel PrivilegeLevelHint, optional bool bAttemptToResolve = false, optional string Reason = "");

/**
 * Determines whether the player is allowed to use voice chat online with specific users
 *
 * @param LocalUserNum the controller number of the associated user
 * @param Users the list of users to check against
 *
 * @return true if the call succeeds, false otherwise
 */
native function bool CanCommunicateVoiceWithUsers(byte LocalUserNum, array<SessionMemberInfo> Users);

/**
 * Determines whether the player is allowed to share (upload/download) user created content
 *
 * @param LocalUserNum the controller number of the associated user
 * @param PrivilegeLevelHint upon completion, this parameter holds a hint about the expected value being retrieved asynchronously
 * @param bAttemptToResolve if the user does not have the proper privilege, should the system attempt to resolve the issue (eg via upsell)
 * @param Reason friendly display string explaining privilege failure
 *
 * @return true if the call succeeds, false otherwise
 */
native function bool CanShareUserCreatedContent(byte LocalUserNum, out EFeaturePrivilegeLevel PrivilegeLevelHint, optional bool bAttemptToResolve = false, optional string Reason = "");

/**
 * Determines whether the player is allowed to buy content online
 *
 * @param LocalUserNum the controller number of the associated user
 * @param PrivilegeLevelHint upon completion, this parameter holds a hint about the expected value being retrieved asynchronously
 * @param bAttemptToResolve if the user does not have the proper privilege, should the system attempt to resolve the issue (eg via upsell)
 * @param Reason friendly display string explaining privilege failure
 *
 * @return true if the call succeeds, false otherwise
 */
native function bool CanPurchaseContent(byte LocalUserNum, out EFeaturePrivilegeLevel PrivilegeLevelHint, optional bool bAttemptToResolve = false, optional string Reason = "");

/**
 * Determines whether the player is allowed to view other people's player profile
 *
 * @param LocalUserNum the controller number of the associated user
 * @param PrivilegeLevelHint upon completion, this parameter holds a hint about the expected value being retrieved asynchronously
 * @param bAttemptToResolve if the user does not have the proper privilege, should the system attempt to resolve the issue (eg via upsell)
 * @param Reason friendly display string explaining privilege failure
 *
 * @return true if the call succeeds, false otherwise
 */
native function bool CanViewPlayerProfiles(byte LocalUserNum, out EFeaturePrivilegeLevel PrivilegeLevelHint, optional bool bAttemptToResolve = false, optional string Reason = "");

/**
 * Determines whether the player is allowed to have their online presence
 * information shown to remote clients
 *
 * @param LocalUserNum the controller number of the associated user
 * @param PrivilegeLevelHint upon completion, this parameter holds a hint about the expected value being retrieved asynchronously
 * @param bAttemptToResolve if the user does not have the proper privilege, should the system attempt to resolve the issue (eg via upsell)
 * @param Reason friendly display string explaining privilege failure
 *
 *@return true if the call succeeds, false otherwise
 */
native function bool CanShowPresenceInformation(byte LocalUserNum, out EFeaturePrivilegeLevel PrivilegeLevelHint, optional bool bAttemptToResolve = false, optional string Reason = "");

/**
 * Determines whether the player is allowed to record DVR clips
 *
 * @param LocalUserNum the controller number of the associated user
 * @param PrivilegeLevelHint upon completion, this parameter holds a hint about the expected value being retrieved asynchronously
 * @param bAttemptToResolve if the user does not have the proper privilege, should the system attempt to resolve the issue (eg via upsell)
 * @param Reason friendly display string explaining privilege failure
 *
 *@return true if the call succeeds, false otherwise
 */
native function bool CanRecordDVRClips(byte LocalUserNum, out EFeaturePrivilegeLevel PrivilegeLevelHint, optional bool bAttemptToResolve = false, optional string Reason = "");

/**
 * Determines whether the player is allowed to use Cloud storage
 *
 * @param LocalUserNum the controller number of the associated user
 * @param PrivilegeLevelHint upon completion, this parameter holds a hint about the expected value being retrieved asynchronously
 * @param bAttemptToResolve if the user does not have the proper privilege, should the system attempt to resolve the issue (eg via upsell)
 * @param Reason friendly display string explaining privilege failure
 *
 *@return true if the call succeeds, false otherwise
 */
native function bool CanUseCloudStorage(byte LocalUserNum, out EFeaturePrivilegeLevel PrivilegeLevelHint, optional bool bAttemptToResolve = false, optional string Reason = "");

/**
 * Determines whether the player is allowed to access premium content
 *
 * @param LocalUserNum the controller number of the associated user
 * @param PrivilegeLevelHint upon completion, this parameter holds a hint about the expected value being retrieved asynchronously
 * @param bAttemptToResolve if the user does not have the proper privilege, should the system attempt to resolve the issue (eg via upsell)
 * @param Reason friendly display string explaining privilege failure
 *
 *@return true if the call succeeds, false otherwise
 */
native function bool CanAccessPremiumContent(byte LocalUserNum, out EFeaturePrivilegeLevel PrivilegeLevelHint, optional bool bAttemptToResolve = false, optional string Reason = "");

/**
 * Determines whether the player is allowed to access premium video content
 *
 * @param LocalUserNum the controller number of the associated user
 * @param PrivilegeLevelHint upon completion, this parameter holds a hint about the expected value being retrieved asynchronously
 * @param bAttemptToResolve if the user does not have the proper privilege, should the system attempt to resolve the issue (eg via upsell)
 * @param Reason friendly display string explaining privilege failure
 *
 *@return true if the call succeeds, false otherwise
 */
native function bool CanAccessPremiumVideoContent(byte LocalUserNum, out EFeaturePrivilegeLevel PrivilegeLevelHint, optional bool bAttemptToResolve = false, optional string Reason = "");

/**
 * Determines whether the player is allowed to browse the internet
 *
 * @param LocalUserNum the controller number of the associated user
 * @param PrivilegeLevelHint upon completion, this parameter holds a hint about the expected value being retrieved asynchronously
 * @param bAttemptToResolve if the user does not have the proper privilege, should the system attempt to resolve the issue (eg via upsell)
 * @param Reason friendly display string explaining privilege failure
 *
 *@return true if the call succeeds, false otherwise
 */
native function bool CanBrowseInternet(byte LocalUserNum, out EFeaturePrivilegeLevel PrivilegeLevelHint, optional bool bAttemptToResolve = false, optional string Reason = "");

/**
 * Determines whether the player is allowed to share content with a social network
 *
 * @param LocalUserNum the controller number of the associated user
 * @param PrivilegeLevelHint upon completion, this parameter holds a hint about the expected value being retrieved asynchronously
 * @param bAttemptToResolve if the user does not have the proper privilege, should the system attempt to resolve the issue (eg via upsell)
 * @param Reason friendly display string explaining privilege failure
 *
 *@return true if the call succeeds, false otherwise
 */
native function bool CanShareWithSocialNetwork(byte LocalUserNum, out EFeaturePrivilegeLevel PrivilegeLevelHint, optional bool bAttemptToResolve = false, optional string Reason = "");

/**
 * Determines whether the player is allowed to share kinect generated/recorded content with other users
 *
 * @param LocalUserNum the controller number of the associated user
 * @param PrivilegeLevelHint upon completion, this parameter holds a hint about the expected value being retrieved asynchronously
 * @param bAttemptToResolve if the user does not have the proper privilege, should the system attempt to resolve the issue (eg via upsell)
 * @param Reason friendly display string explaining privilege failure
 *
 *@return true if the call succeeds, false otherwise
 */
native function bool CanShareKinectContent(byte LocalUserNum, out EFeaturePrivilegeLevel PrivilegeLevelHint, optional bool bAttemptToResolve = false, optional string Reason = "");

/**
 * Determines whether the player is allowed to upload fitness data (eg height, weight, age, gender)
 *
 * @param LocalUserNum the controller number of the associated user
 * @param PrivilegeLevelHint upon completion, this parameter holds a hint about the expected value being retrieved asynchronously
 * @param bAttemptToResolve if the user does not have the proper privilege, should the system attempt to resolve the issue (eg via upsell)
 * @param Reason friendly display string explaining privilege failure
 *
 *@return true if the call succeeds, false otherwise
 */
native function bool CanUploadFitnessData(byte LocalUserNum, out EFeaturePrivilegeLevel PrivilegeLevelHint, optional bool bAttemptToResolve = false, optional string Reason = "");

/**
 * Checks that a unique player id is part of the specified user's friends list
 *
 * @param LocalUserNum the controller number of the associated user
 * @param PlayerId the id of the player being checked
 *
 * @return TRUE if a member of their friends list, FALSE otherwise
 */
native function bool IsFriend(byte LocalUserNum,UniqueNetId PlayerId);

/**
 * Checks that whether a group of player ids are among the specified player's
 * friends
 *
 * @param LocalUserNum the controller number of the associated user
 * @param Query an array of players to check for being included on the friends list
 *
 * @return TRUE if the call succeeded, FALSE otherwise
 */
native function bool AreAnyFriends(byte LocalUserNum,out array<FriendsQuery> Query);

/**
 * Checks that a unique player id is on the specified user's mute list
 *
 * @param LocalUserNum the controller number of the associated user
 * @param PlayerId the id of the player being checked
 *
 * @return TRUE if the player should be muted, FALSE otherwise
 */
native function bool IsMuted(byte LocalUserNum,UniqueNetId PlayerId);

/**
 * Displays the UI that shows a user's list of friends
 *
 * @param LocalUserNum the controller number of the associated user
 *
 * @return TRUE if it was able to show the UI, FALSE if it failed
 */
native function bool ShowFriendsUI(byte LocalUserNum);

/**
 * Sets the delegate used to notify the gameplay code that a login changed
 *
 * @param LoginDelegate the delegate to use for notifications
 * @param LocalUserNum whether to watch for changes on a specific slot or all slots
 */
function AddLoginChangeDelegate(delegate<OnLoginChange> LoginDelegate)
{
	`AddUniqueItemToArray(LoginChangeDelegates, LoginDelegate);
}

/**
 * Removes the specified delegate from the notification list
 *
 * @param LoginDelegate the delegate to use for notifications
 * @param LocalUserNum whether to watch for changes on a specific slot or all slots
 */
function ClearLoginChangeDelegate(delegate<OnLoginChange> LoginDelegate)
{
	LoginChangeDelegates.RemoveItem(LoginDelegate);
}

/**
 * Adds a delegate to the list of delegates that are fired when a login is cancelled
 *
 * @param CancelledDelegate the delegate to add to the list
 */
function AddLoginCancelledDelegate(delegate<OnLoginCancelled> CancelledDelegate)
{
	`AddUniqueItemToArray(LoginCancelledDelegates, CancelledDelegate);
}

/**
 * Removes the specified delegate from the notification list
 *
 * @param CancelledDelegate the delegate to remove fromt he list
 */
function ClearLoginCancelledDelegate(delegate<OnLoginCancelled> CancelledDelegate)
{
	LoginCancelledDelegates.RemoveItem(CancelledDelegate);
}

/**
 * Adds a delegate to the list of delegates that are fired when the current user changes
 *
 * @param CurrentUserDelegate the delegate to add to the list
 */
function AddCurrentUserChangedDelegate(delegate<OnCurrentUserChanged> CurrentUserDelegate)
{
	`AddUniqueItemToArray(CurrentUserChangedDelegates, CurrentUserDelegate);
}

/**
 * Removes the specified delegate from the notification list
 *
 * @param CurrentUserDelegate the delegate to remove from the list
 */
function ClearCurrentUserChangedDelegate(delegate<OnCurrentUserChanged> CurrentUserDelegate)
{
	CurrentUserChangedDelegates.RemoveItem(CurrentUserDelegate);
}

/**
 * Determines whether the specified user is a local (non-online) login or not
 *
 * @param LocalUserNum the controller number of the associated user
 *
 * @return true if a local profile, false otherwise
 */
native function bool IsLocalLogin(byte LocalUserNum);

/**
 * Determines whether the specified user is a guest login or not
 *
 * @param LocalUserNum the controller number of the associated user
 *
 * @return true if a guest, false otherwise
 */
native function bool IsGuestLogin(byte LocalUserNum);

/**
 * Sets the delegate used to notify the gameplay code that a muting list changed
 *
 * @param MutingDelegate the delegate to use for notifications
 */
function AddMutingChangeDelegate(delegate<OnMutingChange> MutingDelegate)
{
	// Add this delegate to the array if not already present
	if (MutingChangeDelegates.Find(MutingDelegate) == INDEX_NONE)
	{
		MutingChangeDelegates[MutingChangeDelegates.Length] = MutingDelegate;
	}
}

/**
 * Searches the existing set of delegates for the one specified and removes it
 * from the list
 *
 * @param FriendsDelegate the delegate to use for notifications
 */
function ClearMutingChangeDelegate(delegate<OnFriendsChange> MutingDelegate)
{
	local int RemoveIndex;

	RemoveIndex = MutingChangeDelegates.Find(MutingDelegate);
	// Remove this delegate from the array if found
	if (RemoveIndex != INDEX_NONE)
	{
		MutingChangeDelegates.Remove(RemoveIndex,1);
	}
}

/**
 * Sets the delegate used to notify the gameplay code that a friends list changed
 *
 * @param LocalUserNum the user to read the friends list of
 * @param FriendsDelegate the delegate to use for notifications
 */
function AddFriendsChangeDelegate(byte LocalUserNum,delegate<OnFriendsChange> FriendsDelegate)
{
	if (LocalUserNum == 0)
	{
		// Add this delegate to the array if not already present
		if (FriendsChangeDelegates.Find(FriendsDelegate) == INDEX_NONE)
		{
			FriendsChangeDelegates[FriendsChangeDelegates.Length] = FriendsDelegate;
		}
	}
	else
	{
		`Warn("Invalid user index ("$LocalUserNum$") specified for ClearFriendsChangeDelegate()");
	}
}

/**
 * Searches the existing set of delegates for the one specified and removes it
 * from the list
 *
 * @param LocalUserNum the user to read the friends list of
 * @param FriendsDelegate the delegate to use for notifications
 */
function ClearFriendsChangeDelegate(byte LocalUserNum,delegate<OnFriendsChange> FriendsDelegate)
{
	local int RemoveIndex;

	// @igs(jtl) TODO, support > 1 user
	if (LocalUserNum == 0)
	{
		RemoveIndex = FriendsChangeDelegates.Find(FriendsDelegate);
		// Remove this delegate from the array if found
		if (RemoveIndex != INDEX_NONE)
		{
			FriendsChangeDelegates.Remove(RemoveIndex,1);
		}
	}
	else
	{
		`Warn("Invalid user index ("$LocalUserNum$") specified for ClearFriendsChangeDelegate()");
	}
}

/**
 * Reads the online profile settings for a given user
 *
 * @param LocalUserNum the user that we are reading the data for
 * @param ProfileSettings the object to copy the results to and contains the list of items to read
 *
 * @return true if the call succeeds, false otherwise
 */
native function bool ReadProfileSettings(byte LocalUserNum,OnlineProfileSettings ProfileSettings);

/**
 * Delegate used when the last read profile settings request has completed
 *
 * @param LocalUserNum the controller index of the player who's read just completed
 * @param bWasSuccessful true if the async action completed without error, false if there was an error
 */
delegate OnReadProfileSettingsComplete(byte LocalUserNum,bool bWasSuccessful);

/**
 * Sets the delegate used to notify the gameplay code that the last read request has completed
 *
 * @param LocalUserNum which user to watch for read complete notifications
 * @param ReadProfileSettingsCompleteDelegate the delegate to use for notifications
 */
function AddReadProfileSettingsCompleteDelegate(byte LocalUserNum,delegate<OnReadProfileSettingsComplete> ReadProfileSettingsCompleteDelegate)
{
	if (LocalUserNum >= 0 && LocalUserNum < ArrayCount(PerUserDelegates))
	{
		`AddUniqueItemToArray(PerUserDelegates[LocalUserNum].ReadProfileSettingsDelegates, ReadProfileSettingsCompleteDelegate);
	}
	else
	{
		`Warn("Invalid user index ("$LocalUserNum$") specified for AddReadProfileSettingsCompleteDelegate()");
	}
}

/**
 * Searches the existing set of delegates for the one specified and removes it
 * from the list
 *
 * @param LocalUserNum which user to watch for read complete notifications
 * @param ReadProfileSettingsCompleteDelegate the delegate to find and clear
 */
function ClearReadProfileSettingsCompleteDelegate(byte LocalUserNum,delegate<OnReadProfileSettingsComplete> ReadProfileSettingsCompleteDelegate)
{
	if (LocalUserNum >= 0 && LocalUserNum < ArrayCount(PerUserDelegates))
	{
		PerUserDelegates[LocalUserNum].ReadProfileSettingsDelegates.RemoveItem(ReadProfileSettingsCompleteDelegate);
	}
	else
	{
		`Warn("Invalid user index ("$LocalUserNum$") specified for ClearReadProfileSettingsCompleteDelegate()");
	}
}


//@HSL_BEGIN - BWJ - 1-11-17 - Support for setting a cached profile
function SetCachedProfile(OnlineProfileSettings InSettings)
{
	CachedProfile = InSettings;
}
//@HSL_END


/**
 * Returns the online profile settings for a given user
 *
 * @param LocalUserNum the user that we are reading the data for
 *
 * @return the profile settings object
 */
function OnlineProfileSettings GetProfileSettings(byte LocalUserNum)
{
	return CachedProfile;
}

/**
 * Writes the online profile settings for a given user to the online data store
 *
 * @param LocalUserNum the user that we are writing the data for
 * @param ProfileSettings the list of settings to write out
 *
 * @return true if the call succeeds, false otherwise
 */
native function bool WriteProfileSettings(byte LocalUserNum,OnlineProfileSettings ProfileSettings);

/**
 * Delegate used when the last write profile settings request has completed
 *
 * @param LocalUserNum the controller index of the player who's write just completed
 * @param bWasSuccessful true if the async action completed without error, false if there was an error
 */
delegate OnWriteProfileSettingsComplete(byte LocalUserNum,bool bWasSuccessful);

/**
 * Sets the delegate used to notify the gameplay code that the last read request has completed
 *
 * @param LocalUserNum which user to watch for read complete notifications
 * @param ReadProfileSettingsCompleteDelegate the delegate to use for notifications
 */
function AddWriteProfileSettingsCompleteDelegate(byte LocalUserNum,delegate<OnWriteProfileSettingsComplete> WriteProfileSettingsCompleteDelegate)
{
	if (LocalUserNum >= 0 && LocalUserNum < ArrayCount(PerUserDelegates))
	{
		`AddUniqueItemToArray(PerUserDelegates[LocalUserNum].WriteProfileSettingsDelegates, WriteProfileSettingsCompleteDelegate);
	}
	else
	{
		`Warn("Invalid user index ("$LocalUserNum$") specified for AddWriteProfileSettingsCompleteDelegate()");
	}
}

/**
 * Searches the existing set of delegates for the one specified and removes it
 * from the list
 *
 * @param LocalUserNum which user to watch for read complete notifications
 * @param ReadProfileSettingsCompleteDelegate the delegate to find and clear
 */
function ClearWriteProfileSettingsCompleteDelegate(byte LocalUserNum,delegate<OnWriteProfileSettingsComplete> WriteProfileSettingsCompleteDelegate)
{
	if (LocalUserNum >= 0 && LocalUserNum < ArrayCount(PerUserDelegates))
	{
		PerUserDelegates[LocalUserNum].WriteProfileSettingsDelegates.RemoveItem(WriteProfileSettingsCompleteDelegate);
	}
	else
	{
		`Warn("Invalid user index ("$LocalUserNum$") specified for ClearWriteProfileSettingsCompleteDelegate()");
	}
}

/**
 * Delegate called when a player's status changes but doesn't change profiles
 *
 * @param NewStatus the new login status for the user
 * @param NewId the new id to associate with the user
 */
delegate OnLoginStatusChange(ELoginStatus NewStatus,UniqueNetId NewId);

/**
 * Sets the delegate used to notify the gameplay code that a login status has changed
 *
 * @param LoginDelegate the delegate to use for notifications
 * @param LocalUserNum the player to watch login status changes for
 */
function AddLoginStatusChangeDelegate(delegate<OnLoginStatusChange> LoginStatusDelegate,byte LocalUserNum)
{
	// Make sure the user is valid
	if (LocalUserNum >= 0 && LocalUserNum < ArrayCount(PerUserDelegates))
	{
		`AddUniqueItemToArray(PerUserDelegates[LocalUserNum].LoginStatusChangeDelegates, LoginStatusDelegate);
	}
	else
	{
		`warn("Invalid index ("$LocalUserNum$") passed to AddLoginStatusChangeDelegate()");
	}
}

/**
 * Removes the specified delegate from the notification list
 *
 * @param LoginDelegate the delegate to use for notifications
 * @param LocalUserNum the player to watch login status changes for
 */
function ClearLoginStatusChangeDelegate(delegate<OnLoginStatusChange> LoginStatusDelegate,byte LocalUserNum)
{
	// Make sure the user is valid
	if (LocalUserNum >= 0 && LocalUserNum < ArrayCount(PerUserDelegates))
	{
		PerUserDelegates[LocalUserNum].LoginStatusChangeDelegates.RemoveItem(LoginStatusDelegate);
	}
	else
	{
		`warn("Invalid index ("$LocalUserNum$") passed to ClearLoginStatusChangeDelegate()");
	}
}

/**
 * Delegate used when the friends read request has completed
 *
 * @param bWasSuccessful true if the async action completed without error, false if there was an error
 */
delegate OnReadFriendsComplete(bool bWasSuccessful);

/**
 * Starts an async task that retrieves the list of friends for the player from the
 * online service. The list can be retrieved in whole or in part.
 *
 * @param LocalUserNum the user to read the friends list of
 * @param Count the number of friends to read or zero for all
 * @param StartingAt the index of the friends list to start at (for pulling partial lists)
 *
 * @return true if the read request was issued successfully, false otherwise
 */
native function bool ReadFriendsList(byte LocalUserNum,optional int Count,optional int StartingAt);

/**
 * Sets the delegate used to notify the gameplay code that the friends read request has completed
 *
 * @param LocalUserNum the user to read the friends list of
 * @param ReadFriendsCompleteDelegate the delegate to use for notifications
 */
native function AddReadFriendsCompleteDelegate(byte LocalUserNum,delegate<OnReadFriendsComplete> ReadFriendsCompleteDelegate);

/**
 * Searches the existing set of delegates for the one specified and removes it
 * from the list
 *
 * @param LocalUserNum which user to watch for read complete notifications
 * @param ReadFriendsCompleteDelegate the delegate to find and clear
 */
native function ClearReadFriendsCompleteDelegate(byte LocalUserNum,delegate<OnReadFriendsComplete> ReadFriendsCompleteDelegate);

/**
 * Copies the list of friends for the player previously retrieved from the online
 * service. The list can be retrieved in whole or in part.
 *
 * @param LocalUserNum the user to read the friends list of
 * @param Friends the out array that receives the copied data
 * @param Count the number of friends to read or zero for all
 * @param StartingAt the index of the friends list to start at (for pulling partial lists)
 *
 * @return OERS_Done if the read has completed, otherwise one of the other states
 */
native function EOnlineEnumerationReadState GetFriendsList(byte LocalUserNum,out array<OnlineFriend> Friends,optional int Count,optional int StartingAt);

/**
 * Registers the user as a talker
 *
 * @param LocalUserNum the local player index that is a talker
 *
 * @return TRUE if the call succeeded, FALSE otherwise
 */
native function bool RegisterLocalTalker(byte LocalUserNum, optional byte ChannelIndex);

/**
 * Unregisters the user as a talker
 *
 * @param LocalUserNum the local player index to be removed
 *
 * @return TRUE if the call succeeded, FALSE otherwise
 */
native function bool UnregisterLocalTalker(byte LocalUserNum, optional byte ChannelIndex);

/**
 * Determines whether a local talker is currently registered or not
 *
 * @return TRUE if the user is talking, FALSE otherwise
 */
native function bool IsLocalTalkerRegistered(byte LocalUserNum);

/**
 * Determines if there are any local talkers that are currently registered
 */
native function bool AreAnyLocalTalkersRegistered();

/**
 * Recieves a reliable voice packet from server
 *
 * @param MessageType the type of message sent
 * @param Sender the Unique Net Id for the sender who sent the packet
 * @param InData the reliable voice data
 *
 */
native function ReceiveReliableVoicePacket( byte MessageType, UniqueNetId Sender, int Length, byte InData[60]);

/**
 * Registers a remote player as a talker
 *
 * @param PlayerId the unique id of the remote player that is a talker
 *
 * @return TRUE if the call succeeded, FALSE otherwise
 */
native function bool RegisterRemoteTalker(UniqueNetId PlayerId);

/**
 * Unregisters a remote player as a talker
 *
 * @param PlayerId the unique id of the remote player to be removed
 *
 * @return TRUE if the call succeeded, FALSE otherwise
 */
native function bool UnregisterRemoteTalker(UniqueNetId PlayerId);

/**
 * Unregisters all remote players
 *
 * @return TRUE if the call succeeded, FALSE otherwise
 */
native function bool UnregisterAllRemoteTalkers();

/**
 * Determines if the specified player is actively talking into the mic
 *
 * @param LocalUserNum the local player index being queried
 *
 * @return TRUE if the player is talking, FALSE otherwise
 */
native function bool IsLocalPlayerTalking(byte LocalUserNum);

/**
 * Determines if the specified remote player is actively talking into the mic
 * NOTE: Network latencies will make this not 100% accurate
 *
 * @param PlayerId the unique id of the remote player being queried
 *
 * @return TRUE if the player is talking, FALSE otherwise
 */
native function bool IsRemotePlayerTalking(UniqueNetId PlayerId);

/**
 * Determines if the specified player has a headset connected
 *
 * @param LocalUserNum the local player index being queried
 *
 * @return TRUE if the player has a headset plugged in, FALSE otherwise
 */
native function bool IsHeadsetPresent(byte LocalUserNum);

/**
 * Sets the relative priority for a remote talker. 0 is highest
 *
 * @param LocalUserNum the user that controls the relative priority
 * @param PlayerId the remote talker that is having their priority changed for
 * @param Priority the relative priority to use (0 highest, < 0 is muted)
 *
 * @return TRUE if the function succeeds, FALSE otherwise
 */
native function bool SetRemoteTalkerPriority(byte LocalUserNum,UniqueNetId PlayerId,int Priority);

/**
 * Mutes all the players (including self)
 *
 * @param PlayerMuteSetting whether to mute all, mute bad rep, or mute nobody by default
 *
 * @return TRUE if the function succeeds, FALSE otherwise
 */
native function bool UpdatePlayerMuteSetting(bool NewPlayerMuteSetting);

/**
 * Mutes a remote talker for the specified local player. NOTE: This only mutes them in the
 * game unless the bIsSystemWide flag is true, which attempts to mute them globally
 *
 * @param LocalUserNum the user that is muting the remote talker
 * @param PlayerId the remote talker that is being muted
 * @param bIsSystemWide whether to try to mute them globally or not
 *
 * @return TRUE if the function succeeds, FALSE otherwise
 */
native function bool MuteRemoteTalker(byte LocalUserNum,UniqueNetId PlayerId,optional bool bIsSystemWide);

/**
 * Allows a remote talker to talk to the specified local player. NOTE: This only unmutes them in the
 * game unless the bIsSystemWide flag is true, which attempts to unmute them globally
 *
 * @param LocalUserNum the user that is allowing the remote talker to talk
 * @param PlayerId the remote talker that is being restored to talking
 * @param bIsSystemWide whether to try to unmute them globally or not
 *
 * @return TRUE if the function succeeds, FALSE otherwise
 */
native function bool UnmuteRemoteTalker(byte LocalUserNum,UniqueNetId PlayerId,optional bool bIsSystemWide);

/**
 * Checks if a user is muted or not
 *
 * @param ConsoleId the remote talker that is being restored to talking
 *
 * @return TRUE if the player is muted, FALSE otherwise
 */
native function bool IsTalkerMuted(UniqueNetId ConsoleId);

/**
 * Tells the voice layer that networked processing of the voice data is allowed
 * for the specified player. This allows for push-to-talk style voice communication
 *
 * @param LocalUserNum the local user to allow network transimission for
 */
native function StartNetworkedVoice(byte LocalUserNum);

/**
 * Tells the voice layer to stop processing networked voice support for the
 * specified player. This allows for push-to-talk style voice communication
 *
 * @param LocalUserNum the local user to disallow network transimission for
 */
native function StopNetworkedVoice(byte LocalUserNum);

/**
 * Tells the voice system to start tracking voice data for speech recognition
 *
 * @param LocalUserNum the local user to recognize voice data for
 *
 * @return true upon success, false otherwise
 */
function bool StartSpeechRecognition(byte LocalUserNum);

/**
 * Tells the voice system to stop tracking voice data for speech recognition
 *
 * @param LocalUserNum the local user to recognize voice data for
 *
 * @return true upon success, false otherwise
 */
function bool StopSpeechRecognition(byte LocalUserNum);

/**
 * Gets the results of the voice recognition
 *
 * @param LocalUserNum the local user to read the results of
 * @param Words the set of words that were recognized by the voice analyzer
 *
 * @return true upon success, false otherwise
 */
function bool GetRecognitionResults(byte LocalUserNum,out array<SpeechRecognizedWord> Words);

/**
 * Called when speech recognition for a given player has completed. The
 * consumer of the notification can call GetRecognitionResults() to get the
 * words that were recognized
 */
delegate OnRecognitionComplete();

/**
 * Sets the speech recognition notification callback to use for the specified user
 *
 * @param LocalUserNum the local user to receive notifications for
 * @param RecognitionDelegate the delegate to call when recognition is complete
 */
function AddRecognitionCompleteDelegate(byte LocalUserNum,delegate<OnRecognitionComplete> RecognitionDelegate)
{
	if (SpeechRecognitionCompleteDelegates.Find(RecognitionDelegate) == INDEX_NONE)
	{
		SpeechRecognitionCompleteDelegates[SpeechRecognitionCompleteDelegates.Length] = RecognitionDelegate;
	}
}

/**
 * Clears the speech recognition notification callback to use for the specified user
 *
 * @param LocalUserNum the local user to receive notifications for
 * @param RecognitionDelegate the delegate to call when recognition is complete
 */
function ClearRecognitionCompleteDelegate(byte LocalUserNum,delegate<OnRecognitionComplete> RecognitionDelegate)
{
	local int RemoveIndex;

	RemoveIndex = SpeechRecognitionCompleteDelegates.Find(RecognitionDelegate);
	if (RemoveIndex != INDEX_NONE)
	{
		SpeechRecognitionCompleteDelegates.Remove(RemoveIndex,1);
	}
}

/**
 * Changes the vocabulary id that is currently being used
 *
 * @param LocalUserNum the local user that is making the change
 * @param VocabularyId the new id to use
 *
 * @return true if successful, false otherwise
 */
function bool SelectVocabulary(byte LocalUserNum,int VocabularyId);

/**
 * Changes the object that is in use to the one specified
 *
 * @param LocalUserNum the local user that is making the change
 * @param SpeechRecogObj the new object use
 *
 * @param true if successful, false otherwise
 */
function bool SetSpeechRecognitionObject(byte LocalUserNum,SpeechRecognition SpeechRecogObj);

/**
 * Returns the name of the player for the specified index
 *
 * @param UserIndex the user to return the name of
 *
 * @return the name of the player at the specified index
 */
native function string GetPlayerNicknameFromIndex(int UserIndex);

/**
 * Determines if the ethernet link is connected or not
 */
function bool HasLinkConnection()
{
	return true;
}

/**
 * Delegate fired when the network link status changes
 *
 * @param bIsConnected whether the link is currently connected or not
 */
delegate OnLinkStatusChange(bool bIsConnected);

/**
 * Adds the delegate used to notify the gameplay code that link status changed
 *
 * @param LinkStatusDelegate the delegate to use for notifications
 */
function AddLinkStatusChangeDelegate(delegate<OnLinkStatusChange> LinkStatusDelegate);

/**
 * Removes the delegate from the notify list
 *
 * @param LinkStatusDelegate the delegate to remove
 */
function ClearLinkStatusChangeDelegate(delegate<OnLinkStatusChange> LinkStatusDelegate);

/**
 * Delegate fired when an external UI display state changes (opening/closing)
 *
 * @param bIsOpening whether the external UI is opening or closing
 */
delegate OnExternalUIChange(bool bIsOpening);

/**
 * Sets the delegate used to notify the gameplay code that external UI state
 * changed (opened/closed)
 *
 * @param ExternalUIDelegate the delegate to use for notifications
 */
function AddExternalUIChangeDelegate(delegate<OnExternalUIChange> ExternalUIDelegate);

/**
 * Removes the delegate from the notification list
 *
 * @param ExternalUIDelegate the delegate to remove
 */
function ClearExternalUIChangeDelegate(delegate<OnExternalUIChange> ExternalUIDelegate);

/**
 * Determines the current notification position setting
 */
function ENetworkNotificationPosition GetNetworkNotificationPosition();

/**
 * Sets a new position for the network notification icons/images
 *
 * @param NewPos the new location to use
 */
function SetNetworkNotificationPosition(ENetworkNotificationPosition NewPos);

/**
 * Delegate fired when the controller becomes dis/connected
 *
 * @param ControllerId the id of the controller that changed connection state
 * @param bIsConnected whether the controller connected (true) or disconnected (false)
 * @param bPauseGame wheater the game should pause or not
 */
delegate OnControllerChange(int ControllerId,bool bIsConnected,bool bPauseGame);

/**
 * Sets the delegate used to notify the gameplay code that the controller state changed
 *
 * @param ControllerChangeDelegate the delegate to use for notifications
 */
function AddControllerChangeDelegate(delegate<OnControllerChange> ControllerChangeDelegate)
{
	`AddUniqueItemToArray(ControllerChangeDelegates, ControllerChangeDelegate);
}

/**
 * Removes the delegate used to notify the gameplay code that the controller state changed
 *
 * @param ControllerChangeDelegate the delegate to remove
 */
function ClearControllerChangeDelegate(delegate<OnControllerChange> ControllerChangeDelegate)
{
	ControllerChangeDelegates.RemoveItem(ControllerChangeDelegate);
}

/**
 * Determines if the specified controller is connected or not
 *
 * @param ControllerId the controller to query
 *
 * @return true if connected, false otherwise
 */
native function bool IsControllerConnected(int ControllerId);

/**
 * Retrieves the current connection status
 *
 * @return the current connection status
 */
native function EOnlineServerConnectionStatus GetCurrentConnectionStatus();

/**
 * Delegate fire when the online server connection state changes
 *
 * @param ConnectionStatus the new connection status
 */
delegate OnConnectionStatusChange(EOnlineServerConnectionStatus ConnectionStatus);

/**
 * Adds the delegate to the list to be notified when the connection status changes
 *
 * @param ConnectionStatusDelegate the delegate to add
 */
function AddConnectionStatusChangeDelegate(delegate<OnConnectionStatusChange> ConnectionStatusDelegate)
{
	`AddUniqueItemToArray(ConnectionStatusChangeDelegates, ConnectionStatusDelegate);
}

/**
 * Removes the delegate from the notify list
 *
 * @param ConnectionStatusDelegate the delegate to remove
 */
function ClearConnectionStatusChangeDelegate(delegate<OnConnectionStatusChange> ConnectionStatusDelegate)
{
	ConnectionStatusChangeDelegates.RemoveItem(ConnectionStatusDelegate);
}

/**
 * Determines the NAT type the player is using
 */
function ENATType GetNATType()
{
	return NAT_Open;
}

/**
 * Determine the locale (country code) for the player
 */
function int GetLocale()
{
	return 0;
}

/**
 * Delegate fired when a storage device change is detected
 */
delegate OnStorageDeviceChange();

/**
 * Adds the delegate to the list to be notified when a storage device changes
 *
 * @param StorageDeviceChangeDelegate the delegate to add
 */
function AddStorageDeviceChangeDelegate(delegate<OnStorageDeviceChange> StorageDeviceChangeDelegate);

/**
 * Removes the delegate from the notify list
 *
 * @param ConnectionStatusDelegate the delegate to remove
 */
function ClearStorageDeviceChangeDelegate(delegate<OnStorageDeviceChange> StorageDeviceChangeDelegate);

/**
 * Delegate fired when the application's focus changes
 */
delegate OnFocusChange(bool bHasFocus);

/**
 * Adds the delegate to the list to be notified when the application's focus changes
 *
 * @param FocusChangeDelegate the delegate to add
 */
function AddFocusChangeDelegate(delegate<OnFocusChange> FocusChangeDelegate)
{
	`AddUniqueItemToArray(FocusChangeDelegates, FocusChangeDelegate);
}

/**
 * Removes the delegate from the notify list
 *
 * @param FocusChangeDelegate the delegate to remove
 */
function ClearFocusChangeDelegate(delegate<OnFocusChange> FocusChangeDelegate)
{
	FocusChangeDelegates.RemoveItem(FocusChangeDelegate);
}

/**
 * Sets the online status information to use for the specified player. Used to
 * tell other players what the player is doing (playing, menus, away, etc.)
 *
 * @param LocalUserNum the controller number of the associated user
 * @param StatusString the status string to use
 * @param PlayerActive indicates if the player is active
 */
native function SetOnlineStatus(byte LocalUserNum,string StatusString,optional bool PlayerActive=true);

/**
 * Called when keyboard input is completed. Sets the appropriate member variables and fires the OnKeyboardInputComplete delegates
 *
 * @param bWasCancelled - if the input was cancelled
 * @param InputResults - the results of the keyboard input
 */
native function KeyboardInputFinished(bool bWasCanceled, string InputResults);

/**
 * Displays the UI that shows the keyboard for inputing text
 *
 * @param LocalUserNum the controller number of the associated user
 * @param TitleText the title to display to the user
 * @param DescriptionText the text telling the user what to input
 * @param bIsPassword whether the item being entered is a password or not
 * @param bShouldValidate whether to apply the string validation API after input or not
 * @param DefaultText the default string to display
 * @param MaxResultLength the maximum length string expected to be filled in
 *
 * @return TRUE if it was able to show the UI, FALSE if it failed
 */
native function bool ShowKeyboardUI(byte LocalUserNum,string TitleText,string DescriptionText,
	optional bool bIsPassword = false,
	optional bool bShouldValidate = true,
	optional string DefaultText,
	optional int MaxResultLength = 256);

/**
 * Hides the UI that shows the keyboard for inputing text
 *
 * @param LocalUserNum the controller number of the associated user
 *
 * @return TRUE if it was able to hide the UI, FALSE if it failed
 */
native function bool HideKeyboardUI(byte LocalUserNum);

/**
 * Delegate used when the keyboard input request has completed
 *
 * @param bWasSuccessful true if the async action completed without error, false if there was an error
 */
delegate OnKeyboardInputComplete(bool bWasSuccessful);

/**
 * Adds the delegate used to notify the gameplay code that the user has completed
 * their keyboard input
 *
 * @param InputDelegate the delegate to use for notifications
 */
function AddKeyboardInputDoneDelegate(delegate<OnKeyboardInputComplete> InputDelegate)
{
	if (KeyboardInputDelegates.Find(InputDelegate) == INDEX_NONE)
	{
		KeyboardInputDelegates.AddItem(InputDelegate);
	}
}

/**
 * Clears the delegate used to notify the gameplay code that the user has completed
 * their keyboard input
 *
 * @param InputDelegate the delegate to use for notifications
 */
function ClearKeyboardInputDoneDelegate(delegate<OnKeyboardInputComplete> InputDelegate)
{
	local int RemoveIndex;
	RemoveIndex = KeyboardInputDelegates.Find(InputDelegate);
	if (RemoveIndex != INDEX_NONE)
	{
		KeyboardInputDelegates.Remove(RemoveIndex,1);
	}
}

/**
 * Fetches the results of the input
 *
 * @param bWasCancelled whether the user canceled the input or not
 *
 * @return the string entered by the user. Note the string will be empty if it
 * fails validation
 */
function string GetKeyboardInputResults(out byte bWasCanceled)
{
	bWasCanceled = KeyboardInputWasCanceled;
	return KeyboardInputResults;
}

/**
 * Delegate used when the last write online player storage request has completed
 *
 * @param LocalUserNum the controller index of the player who's write just completed
 * @param bWasSuccessful true if the async action completed without error, false if there was an error
 */
delegate OnWritePlayerStorageComplete(byte LocalUserNum,bool bWasSuccessful);

/**
 * Sets the delegate used to notify the gameplay code that the last write request has completed
 *
 * @param LocalUserNum which user to watch for write complete notifications
 * @param WritePlayerStorageCompleteDelegate the delegate to use for notifications
 */
function AddWritePlayerStorageCompleteDelegate(byte LocalUserNum,delegate<OnWritePlayerStorageComplete> WritePlayerStorageCompleteDelegate);

/**
 * Delegate used when the last read of online player storage data request has completed
 *
 * @param NetId the net id for the user who's read just completed
 * @param bWasSuccessful true if the async action completed without error, false if there was an error
 */
delegate OnReadPlayerStorageForNetIdComplete(UniqueNetId NetId,bool bWasSuccessful);

/**
 * Sets the delegate used to notify the gameplay code that the last read request has completed
 *
 * @param NetId the net id for the user to watch for read complete notifications
 * @param ReadPlayerStorageForNetIdCompleteDelegate the delegate to use for notifications
 */
function AddReadPlayerStorageForNetIdCompleteDelegate(UniqueNetId NetId,delegate<OnReadPlayerStorageForNetIdComplete> ReadPlayerStorageForNetIdCompleteDelegate);

/**
 * Reads the online player storage data for a given net user
 *
 * @param LocalUserNum the local user that is initiating the read
 * @param NetId the net user that we are reading the data for
 * @param PlayerStorage the object to copy the results to and contains the list of items to read
 *
 * @return true if the call succeeds, false otherwise
 */
function bool ReadPlayerStorageForNetId(byte LocalUserNum,UniqueNetId NetId,OnlinePlayerStorage PlayerStorage);

/**
 * Searches the existing set of delegates for the one specified and removes it
 * from the list
 *
 * @param NetId the net id for the user to watch for read complete notifications
 * @param ReadPlayerStorageForNetIdCompleteDelegate the delegate to find and clear
 */
function ClearReadPlayerStorageForNetIdCompleteDelegate(UniqueNetId NetId,delegate<OnReadPlayerStorageForNetIdComplete> ReadPlayerStorageForNetIdCompleteDelegate);

/**
 * Reads the online player storage data for a given local user
 * If a valid storage device ID is specified then data is also read from that device and the newer version is kept.
 *
 * @param LocalUserNum the user that we are reading the data for
 * @param PlayerStorage the object to copy the results to and contains the list of items to read
 * @param DeviceId optional ID for connected device to read from. -1 for no device
 *
 * @return true if the call succeeds, false otherwise
 */
function bool ReadPlayerStorage(byte LocalUserNum,OnlinePlayerStorage PlayerStorage,optional int DeviceId = -1);

/**
 * Delegate used when the last read of online player storage data request has completed
 *
 * @param LocalUserNum the controller index of the player who's read just completed
 * @param bWasSuccessful true if the async action completed without error, false if there was an error
 */
delegate OnReadPlayerStorageComplete(byte LocalUserNum,bool bWasSuccessful);

/**
 * Sets the delegate used to notify the gameplay code that the last read request has completed
 *
 * @param LocalUserNum which user to watch for read complete notifications
 * @param ReadPlayerStorageCompleteDelegate the delegate to use for notifications
 */
function AddReadPlayerStorageCompleteDelegate(byte LocalUserNum,delegate<OnReadPlayerStorageComplete> ReadPlayerStorageCompleteDelegate);

/**
 * Searches the existing set of delegates for the one specified and removes it
 * from the list
 *
 * @param LocalUserNum which user to watch for read complete notifications
 * @param ReadPlayerStorageCompleteDelegate the delegate to find and clear
 */
function ClearReadPlayerStorageCompleteDelegate(byte LocalUserNum,delegate<OnReadPlayerStorageComplete> ReadPlayerStorageCompleteDelegate);

/**
 * Returns the online player storage for a given local user
 *
 * @param LocalUserNum the user that we are reading the data for
 *
 * @return the player storage object
 */
function OnlinePlayerStorage GetPlayerStorage(byte LocalUserNum)
{
	return None;
}

/**
 * Writes the online player storage data for a given local user to the online data store
 * If a valid storage device ID is specified then data is also written to that device.
 *
 * @param LocalUserNum the user that we are writing the data for
 * @param PlayerStorage the object that contains the list of items to write
 * @param DeviceId optional ID for connected device to write to. -1 for no device
 *
 * @return true if the call succeeds, false otherwise
 */
function bool WritePlayerStorage(byte LocalUserNum,OnlinePlayerStorage PlayerStorage,optional int DeviceId = -1);

/**
 * Clears the delegate used to notify the gameplay code that the last write request has completed
 *
 * @param LocalUserNum which user to watch for write complete notifications
 * @param WritePlayerStorageCompleteDelegate the delegate to use for notifications
 */
function ClearWritePlayerStorageCompleteDelegate(byte LocalUserNum,delegate<OnWritePlayerStorageComplete> WritePlayerStorageCompleteDelegate);

/**
 * Sends a friend invite to the specified player
 *
 * @param LocalUserNum the user that is sending the invite
 * @param NewFriend the player to send the friend request to
 * @param Message the message to display to the recipient
 *
 * @return true if successful, false otherwise
 */
function bool AddFriend(byte LocalUserNum,UniqueNetId NewFriend,optional string Message);

/**
 * Sends a friend invite to the specified player nick
 *
 * @param LocalUserNum the user that is sending the invite
 * @param FriendName the name of the player to send the invite to
 * @param Message the message to display to the recipient
 *
 * @return true if successful, false otherwise
 */
function bool AddFriendByName(byte LocalUserNum,string FriendName,optional string Message);

/**
 * Called when a friend invite arrives for a local player
 *
 * @param bWasSuccessful true if successfully added, false if not found or failed
 */
delegate OnAddFriendByNameComplete(bool bWasSuccessful);

/**
 * Adds the delegate used to notify the gameplay code that the user has received a friend invite
 *
 * @param LocalUserNum the user associated with the notification
 * @param FriendDelegate the delegate to use for notifications
 */
function AddAddFriendByNameCompleteDelegate(byte LocalUserNum,delegate<OnAddFriendByNameComplete> FriendDelegate);

/**
 * Removes the delegate specified from the list
 *
 * @param LocalUserNum the user associated with the notification
 * @param FriendDelegate the delegate to use for notifications
 */
function ClearAddFriendByNameCompleteDelegate(byte LocalUserNum,delegate<OnAddFriendByNameComplete> FriendDelegate);

/**
 * Used to accept a friend invite sent to this player
 *
 * @param LocalUserNum the user the invite is for
 * @param RequestingPlayer the player the invite is from
 *
 * @param true if successful, false otherwise
 */
function bool AcceptFriendInvite(byte LocalUserNum,UniqueNetId RequestingPlayer);

/**
 * Used to deny a friend request sent to this player
 *
 * @param LocalUserNum the user the invite is for
 * @param RequestingPlayer the player the invite is from
 *
 * @param true if successful, false otherwise
 */
function bool DenyFriendInvite(byte LocalUserNum,UniqueNetId RequestingPlayer);

/**
 * Removes a friend from the player's friend list
 *
 * @param LocalUserNum the user that is removing the friend
 * @param FormerFriend the player to remove from the friend list
 *
 * @return true if successful, false otherwise
 */
function bool RemoveFriend(byte LocalUserNum,UniqueNetId FormerFriend);

/**
 * Called when a friend invite arrives for a local player
 *
 * @param LocalUserNum the user that is receiving the invite
 * @param RequestingPlayer the player sending the friend request
 * @param RequestingNick the nick of the player sending the friend request
 * @param Message the message to display to the recipient
 */
delegate OnFriendInviteReceived(byte LocalUserNum,UniqueNetId RequestingPlayer,string RequestingNick,string Message);

/**
 * Adds the delegate used to notify the gameplay code that the user has received a friend invite
 *
 * @param LocalUserNum the user associated with the notification
 * @param InviteDelegate the delegate to use for notifications
 */
function AddFriendInviteReceivedDelegate(byte LocalUserNum,delegate<OnFriendInviteReceived> InviteDelegate);

/**
 * Removes the delegate specified from the list
 *
 * @param LocalUserNum the user associated with the notification
 * @param InviteDelegate the delegate to use for notifications
 */
function ClearFriendInviteReceivedDelegate(byte LocalUserNum,delegate<OnFriendInviteReceived> InviteDelegate);

/**
 * Sends a message to a friend
 *
 * @param LocalUserNum the user that is sending the message
 * @param Friend the player to send the message to
 * @param Message the message to display to the recipient
 *
 * @return true if successful, false otherwise
 */
function bool SendMessageToFriend(byte LocalUserNum,UniqueNetId Friend,string Message);

/**
 * Sends an invitation to play in the player's current session
 *
 * @param LocalUserNum the user that is sending the invite
 * @param Friend the player to send the invite to
 * @param Text the text of the message for the invite
 *
 * @return true if successful, false otherwise
 */
native function bool SendGameInviteToFriend(byte LocalUserNum,name SessionName,UniqueNetId Friend,optional string Text);

/**
 * Sends invitations to play in the player's current session
 *
 * @param LocalUserNum the user that is sending the invite
 * @param Friends the player to send the invite to
 * @param Text the text of the message for the invite
 *
 * @return true if successful, false otherwise
 */
native function bool SendGameInviteToFriends(byte LocalUserNum,name SessionName,array<UniqueNetId> Friends,optional string Text);

//@HSL_BEGIN - JRO - 6/10/2016 - Is this needed for Dingo?
function bool SendGameInviteToUsers(string SessionId, name SessionName, array<string> MembersToInvite, optional string Text);
//@HSL_END

/**
 * Called when the online system receives a game invite that needs handling
 *
 * @param LocalUserNum the user that is receiving the invite
 * @param InviterName the nick name of the person sending the invite
 */
delegate OnReceivedGameInvite(byte LocalUserNum,string InviterName);

/**
 * Adds the delegate used to notify the gameplay code that the user has received a game invite
 *
 * @param LocalUserNum the user associated with the notification
 * @param ReceivedGameInviteDelegate the delegate to use for notifications
 */
function AddReceivedGameInviteDelegate(byte LocalUserNum,delegate<OnReceivedGameInvite> ReceivedGameInviteDelegate);

/**
 * Removes the delegate specified from the list
 *
 * @param LocalUserNum the user associated with the notification
 * @param ReceivedGameInviteDelegate the delegate to use for notifications
 */
function ClearReceivedGameInviteDelegate(byte LocalUserNum,delegate<OnReceivedGameInvite> ReceivedGameInviteDelegate);


delegate OnReceivedGameInviteById(byte LocalUserNum, UniqueNetId InviterId);
function AddReceivedGameInviteByIdDelegate(byte LocalUserNum,delegate<OnReceivedGameInviteById> ReceivedGameInviteDelegate);
function ClearReceivedGameInviteByIdDelegate(byte LocalUserNum,delegate<OnReceivedGameInviteById> ReceivedGameInviteDelegate);


/**
 * Checks if the game was booted due to a game invite
 */
native function CheckForGameInviteOnLaunch();

/**
 * Allows the local player to follow a friend into a game
 *
 * @param LocalUserNum the local player wanting to join
 * @param Friend the player that is being followed
 *
 * @return true if the async call worked, false otherwise
 */
function bool JoinFriendGame(byte LocalUserNum,UniqueNetId Friend);

/**
 * Called once the join task has completed
 *
 * @param bWasSuccessful the session was found and is joinable, false otherwise
 */
delegate OnJoinFriendGameComplete(bool bWasSuccessful);

/**
 * Sets the delegate used to notify when the join friend is complete
 *
 * @param JoinFriendGameCompleteDelegate the delegate to use for notifications
 */
function AddJoinFriendGameCompleteDelegate(delegate<OnJoinFriendGameComplete> JoinFriendGameCompleteDelegate);

/**
 * Removes the delegate from the list of notifications
 *
 * @param JoinFriendGameCompleteDelegate the delegate to use for notifications
 */
function ClearJoinFriendGameCompleteDelegate(delegate<OnJoinFriendGameComplete> JoinFriendGameCompleteDelegate);

/**
 * Returns the list of messages for the specified player
 *
 * @param LocalUserNum the local player wanting to join
 * @param FriendMessages the set of messages cached locally for the player
 */
function GetFriendMessages(byte LocalUserNum,out array<OnlineFriendMessage> FriendMessages);

/**
 * Called when a friend invite arrives for a local player
 *
 * @param LocalUserNum the user that is receiving the message
 * @param SendingPlayer the player sending the message
 * @param SendingNick the nick of the player sending the message
 * @param Message the message to display to the recipient
 */
delegate OnFriendMessageReceived(byte LocalUserNum,UniqueNetId SendingPlayer,string SendingNick,string Message);

/**
 * Adds the delegate used to notify the gameplay code that the user has received a friend invite
 *
 * @param LocalUserNum the user associated with the notification
 * @param MessageDelegate the delegate to use for notifications
 */
function AddFriendMessageReceivedDelegate(byte LocalUserNum,delegate<OnFriendMessageReceived> MessageDelegate);

/**
 * Removes the delegate specified from the list
 *
 * @param LocalUserNum the user associated with the notification
 * @param MessageDelegate the delegate to use for notifications
 */
function ClearFriendMessageReceivedDelegate(byte LocalUserNum,delegate<OnFriendMessageReceived> MessageDelegate);

/**
 * Mutes all voice or all but friends
 *
 * @param LocalUserNum the local user that is making the change
 * @param bAllowFriends whether to mute everyone or allow friends
 */
function bool MuteAll(byte LocalUserNum,bool bAllowFriends);

/**
 * Allows all speakers to send voice
 *
 * @param LocalUserNum the local user that is making the change
 */
function bool UnmuteAll(byte LocalUserNum);

/**
 * Deletes a message from the list of messages
 *
 * @param LocalUserNum the user that is deleting the message
 * @param MessageIndex the index of the message to delete
 *
 * @return true if the message was deleted, false otherwise
 */
function bool DeleteMessage(byte LocalUserNum,int MessageIndex);

/**
 * Unlocks the specified achievement for the specified user
 *
 * @param LocalUserNum the controller number of the associated user
 * @param AchievementId the id of the achievement to unlock
 *
 * @return TRUE if the call worked, FALSE otherwise
 */
function bool UnlockAchievement(byte LocalUserNum,int AchievementId,float PercentComplete=100.0);

/**
 * Delegate used when the achievement unlocking has completed
 *
 * @param bWasSuccessful true if the async action completed without error, false if there was an error
 */
delegate OnUnlockAchievementComplete(bool bWasSuccessful);

/**
 * Adds the delegate used to notify the gameplay code that the achievement unlocking has completed
 *
 * @param LocalUserNum which user to watch for read complete notifications
 * @param UnlockAchievementCompleteDelegate the delegate to use for notifications
 */
function AddUnlockAchievementCompleteDelegate(byte LocalUserNum,delegate<OnUnlockAchievementComplete> UnlockAchievementCompleteDelegate);

/**
 * Clears the delegate used to notify the gameplay code that the achievement unlocking has completed
 *
 * @param LocalUserNum which user to watch for read complete notifications
 * @param UnlockAchievementCompleteDelegate the delegate to use for notifications
 */
function ClearUnlockAchievementCompleteDelegate(byte LocalUserNum,delegate<OnUnlockAchievementComplete> UnlockAchievementCompleteDelegate);

/**
 * Starts an async read for the achievement list
 *
 * @param LocalUserNum the controller number of the associated user
 * @param TitleId the title id of the game the achievements are to be read for
 * @param bShouldReadText whether to fetch the text strings or not
 * @param bShouldReadImages whether to fetch the image data or not
 *
 * @return TRUE if the task starts, FALSE if it failed
 */
native function bool ReadAchievements(byte LocalUserNum,optional int TitleId = 0,optional bool bShouldReadText = true,optional bool bShouldReadImages = false);

/**
 * Called when the async achievements read has completed
 *
 * @param TitleId the title id that the read was for (0 means current title)
 */
delegate OnReadAchievementsComplete(int TitleId);

/**
 * Sets the delegate used to notify the gameplay code that the achievements read request has completed
 *
 * @param LocalUserNum the user to read the achievements list for
 * @param ReadAchievementsCompleteDelegate the delegate to use for notifications
 */
function AddReadAchievementsCompleteDelegate(byte LocalUserNum,delegate<OnReadAchievementsComplete> ReadAchievementsCompleteDelegate)
{
	// Make sure the user is valid
	if (LocalUserNum >= 0 && LocalUserNum < ArrayCount(PerUserDelegates))
	{
		if (PerUserDelegates[LocalUserNum].AchievementReadDelegates.Find(ReadAchievementsCompleteDelegate) == INDEX_NONE)
		{
			PerUserDelegates[LocalUserNum].AchievementReadDelegates.AddItem(ReadAchievementsCompleteDelegate);
		}
	}
	else
	{
		`warn("Invalid index ("$LocalUserNum$") passed to AddReadAchievementsComplete()");
	}
}

/**
 * Clears the delegate used to notify the gameplay code that the achievements read request has completed
 *
 * @param LocalUserNum the user to read the achievements list for
 * @param ReadAchievementsCompleteDelegate the delegate to use for notifications
 */
function ClearReadAchievementsCompleteDelegate(byte LocalUserNum,delegate<OnReadAchievementsComplete> ReadAchievementsCompleteDelegate)
{
	local int RemoveIndex;

	// Make sure the user is valid
	if (LocalUserNum >= 0 && LocalUserNum < ArrayCount(PerUserDelegates))
	{
		RemoveIndex = PerUserDelegates[LocalUserNum].AchievementReadDelegates.Find(ReadAchievementsCompleteDelegate);
		if (RemoveIndex != INDEX_NONE)
		{
			PerUserDelegates[LocalUserNum].AchievementReadDelegates.Remove(RemoveIndex,1);
		}
	}
	else
	{
		`warn("Invalid index ("$LocalUserNum$") passed to ClearReadAchievementsCompleteDelegate()");
	}
}

/**
 * Copies the list of achievements for the specified player and title id
 *
 * @param LocalUserNum the user to read the friends list of
 * @param Achievements the out array that receives the copied data
 * @param TitleId the title id of the game that these were read for
 *
 * @return OERS_Done if the read has completed, otherwise one of the other states
 */
native function EOnlineEnumerationReadState GetAchievements(byte LocalUserNum,out array<AchievementDetails> Achievements,optional int TitleId = 0);

/**
 * Clears the list of achievements for the specified player and title id
 *
 * @param LocalUserNum the user to read the friends list of
 * @param TitleId the title id of the game that these were read for
 */
native function ClearAchievements(byte LocalUserNum, optional int TitleId = 0);

/**
 * Displays the UI for a products details
 *
 * @param LocalUserNum the local user viewing available content
 * @param ParentProductId the product ID of the parent product for which to show child content
 */
native function bool ShowProductDetailsUI(byte LocalUserNum, optional string ParentProductId = ProductId);

/**
 * Displays the marketplace UI for content
 *
 * @param LocalUserNum the local user viewing available content
 * @param ParentProductType the type of the parent product specified by ParentProductId
 *                          (use constants defined in OnlineSubsyste.uc, generally this should be PIT_Game)
 * @param RequestedProductTypes the types of child products to show in the marketplace UI
 *                          (use constants defined in OnlineSubsyste.uc, generally this should be PIT_Durable | PIT_Consumable)
 * @param ParentProductId the product ID of the parent product for which to show child content
 */
native function bool ShowContentMarketplaceUI(byte LocalUserNum, int ParentProductType, int RequestedProductTypes, optional string ParentProductId = ProductId);

/**
 * Displays the purchase UI for an offer
 *
 * @param LocalUserNum the local user viewing available content
 * @param Offer the offer that you want the purchase screen shown for
 */
native function bool ShowContentPurchaseUI(byte LocalUserNum, string Offer);

/**
 * Displays the redeem code UI for content
 *
 * @param LocalUserNum the local user viewing available content
 * @param Offer the offer that you want the redeem code screen shown for
 */
native function bool ShowContentRedeemCodeUI(byte LocalUserNum, string Offer);

/**
 * Close the current content UI
 *
 */
native function CloseCurrentContentUI();

/**
 * Displays the UI that allows a player to give feedback on another player
 *
 * @param LocalUserNum the controller number of the associated user
 * @param PlayerId the id of the player having feedback given for
 *
 * @return TRUE if it was able to show the UI, FALSE if it failed
 */
function bool ShowFeedbackUI(byte LocalUserNum,UniqueNetId PlayerId);

/**
 * Displays the UI with Help documentation
 *
 * @param LocalUserNum the controller number of the associated user
 *
 * @return TRUE if the async show command is processing, FALSE if it failed to initialize
 */
native function bool ShowHelpUI(byte LocalUserNum);

/**
 * Displays the UI with Help documentation for a given error the application has encountered
 *
 * @param ContextId application specific context within which the error occurred
 * @param ErrorString a string representation of the error
 *
 * @return TRUE if the async show command is processing, FALSE if it failed to initialize
 */
native function bool ShowHelpForErrorUI(string ContextId, string ErrorString);

/**
 * Delegate used when a show help request has completed
 *
 * @param bWasSuccessful true if the async action completed without error, false if there was an error
 */
delegate OnShowHelpComplete(bool bWasSuccessful);

/**
 * Adds the delegate used to notify the gameplay code that a show help request has finished
 *
 * @param ShowHelpDelegate the delegate to use for notifications
 */
function AddShowHelpCompleteDelegate(delegate<OnShowHelpComplete> HelpDelegate)
{
	`AddUniqueItemToArray(ShowHelpDelegates, HelpDelegate);
}

/**
 * Removes the specified delegate from the list of callbacks
 *
 * @param ShowHelpDelegate the delegate to use for notifications
 */
function ClearShowHelpCompleteDelegate(delegate<OnShowHelpComplete> HelpDelegate)
{
	ShowHelpDelegates.RemoveItem(HelpDelegate);
}

/**
 * Displays the UI with Help documentation
 *
 * @param URL link to show
 *
 * @return TRUE if the show command succeded, FALSE otherwise
 */
native function bool ShowVideo(string URL);

// Overriden from Onlinesubsystem.uc
native function OpenURL(string WebsiteLink);


//@HSL_BEGIN_XBOX
/**
 * Delegate called when OSS-side tokens are acquired
 */
delegate OnTokenAndSignatureRetrieved(byte LocalUserNum, string URL, string Token, string Signature);

native function GetTokenAndSignatureForURL(byte LocalUserNum, string URL);

function AddURLTokenRetrievedDelegate(byte LocalUserNum,delegate<OnTokenAndSignatureRetrieved> tsrDelegate)
{
	`AddUniqueItemToArray(TokenAndSignatureDelegates, tsrDelegate);
}

function ClearURLTokenRetrievedDelegate(byte LocalUserNum, delegate<OnTokenAndSignatureRetrieved> tsrDelegate)
{
	TokenAndSignatureDelegates.RemoveItem(tsrDelegate);
}
//@HSL_END_XBOX

/**
 * Delegate used when a show gamer card request has completed
 */
delegate OnShowGamerCardComplete(bool bWasSuccessful);

/**
 * Adds the delegate used to notify the gameplay code that a show gamer card request has finished
 *
 * @param ShowHelpDelegate the delegate to use for notifications
 */
function AddShowGamerCardCompleteDelegate(delegate<OnShowGamerCardComplete> GamerCardDelegate)
{
    `AddUniqueItemToArray(ShowGamerCardCompleteDelegates, GamerCardDelegate);
}

/**
 * Removes the specified delegate from the list of callbacks
 *
 * @param ShowHelpDelegate the delegate to use for notifications
 */
function ClearShowGamerCardCompleteDelegate(delegate<OnShowGamerCardComplete> GamerCardDelegate)
{
    ShowGamerCardCompleteDelegates.RemoveItem(GamerCardDelegate);
}

/**
 * Displays the gamer card UI for the specified player
 *
 * @param LocalUserNum the controller number of the associated user
 * @param PlayerId the id of the player to show the gamer card of
 *
 * @return TRUE if it was able to show the UI, FALSE if it failed
 */
native function bool ShowGamerCardUI(byte LocalUserNum,UniqueNetId PlayerId);

/**
 * Displays the messages UI for a player
 *
 * @param LocalUserNum the controller number of the associated user
 *
 * @return TRUE if it was able to show the UI, FALSE if it failed
 */
function bool ShowMessagesUI(byte LocalUserNum);

/**
 * Displays the achievements UI for a player
 *
 * @param LocalUserNum the controller number of the associated user
 *
 * @return TRUE if it was able to show the UI, FALSE if it failed
 */
function bool ShowAchievementsUI(byte LocalUserNum);

/**
 * Displays the invite ui
 *
 * @param LocalUserNum the local user sending the invite
 * @param InviteText the string to prefill the UI with
 */
native function bool ShowInviteUI(byte LocalUserNum,optional string InviteText);

/**
 * Displays the marketplace UI for memberships
 *
 * @param LocalUserNum the local user viewing available memberships
 */
function bool ShowMembershipMarketplaceUI(byte LocalUserNum);

/**
 * Displays the UI that allows the user to choose which device to save content to
 *
 * @param LocalUserNum the controller number of the associated user
 * @param SizeNeeded the size of the data to be saved in bytes
 * @param bManageStorage whether to allow the user to manage their storage or not
 *
 * @return TRUE if it was able to show the UI, FALSE if it failed
 */
function bool ShowDeviceSelectionUI(byte LocalUserNum,int SizeNeeded,optional bool bManageStorage);

/**
 * Delegate used when the device selection request has completed
 *
 * @param bWasSuccessful true if the async action completed without error, false if there was an error
 */
delegate OnDeviceSelectionComplete(bool bWasSuccessful);

/**
 * Adds the delegate used to notify the gameplay code that the user has completed
 * their device selection
 *
 * @param DeviceDelegate the delegate to use for notifications
 */
function AddDeviceSelectionDoneDelegate(byte LocalUserNum,delegate<OnDeviceSelectionComplete> DeviceDelegate);

/**
 * Removes the specified delegate from the list of callbacks
 *
 * @param DeviceDelegate the delegate to use for notifications
 */
function ClearDeviceSelectionDoneDelegate(byte LocalUserNum,delegate<OnDeviceSelectionComplete> DeviceDelegate);

/**
 * Fetches the results of the device selection
 *
 * @param LocalUserNum the player to check the results for
 * @param DeviceName out param that gets a copy of the string
 *
 * @return the ID of the device that was selected
 * NOTE: Zero means the user hasn't selected one
 */
function int GetDeviceSelectionResults(byte LocalUserNum,out string DeviceName);

/**
 * Checks the device id to determine if it is still valid (could be removed) and/or
 * if there is enough space on the specified device
 *
 * @param DeviceId the device to check
 * @param SizeNeeded the amount of space requested
 *
 * @return true if valid, false otherwise
 */
function bool IsDeviceValid(int DeviceId,optional int SizeNeeded);

/**
 * Unlocks a gamer picture for the local user
 *
 * @param LocalUserNum the user to unlock the picture for
 * @param PictureId the id of the picture to unlock
 */
function bool UnlockGamerPicture(byte LocalUserNum,int PictureId);

/**
 * Called when an external change to player profile data has occured
 */
delegate OnProfileDataChanged();

/**
 * Sets the delegate used to notify the gameplay code that someone has changed their profile data externally
 *
 * @param LocalUserNum the user the delegate is interested in
 * @param ProfileDataChangedDelegate the delegate to use for notifications
 */
function AddProfileDataChangedDelegate(byte LocalUserNum,delegate<OnProfileDataChanged> ProfileDataChangedDelegate);

/**
 * Clears the delegate used to notify the gameplay code that someone has changed their profile data externally
 *
 * @param LocalUserNum the user the delegate is interested in
 * @param ProfileDataChangedDelegate the delegate to use for notifications
 */
function ClearProfileDataChangedDelegate(byte LocalUserNum,delegate<OnProfileDataChanged> ProfileDataChangedDelegate);

/**
 * Displays the UI that shows a user's list of friends
 *
 * @param LocalUserNum the controller number of the associated user
 * @param PlayerId the id of the player being invited
 *
 * @return TRUE if it was able to show the UI, FALSE if it failed
 */
native function bool ShowFriendsInviteUI(byte LocalUserNum,UniqueNetId PlayerId);

native function bool ShowPeoplePickerUI(byte LocalUserNum, array<OnlineFriend> People, int MaxSelectable, optional string Text);
delegate OnPeoplePickerComplete(bool bWasSuccessful, array<OnlineFriend> PeoplePicked);
function AddPeoplePickerCompleteDelegate(byte LocalUserNum,delegate<OnPeoplePickerComplete> InDelegate)
{
    // Add this delegate to the array if not already present
    if (PeoplePickerCompleteDelegates.Find(InDelegate) == INDEX_NONE)
    {
        PeoplePickerCompleteDelegates[PeoplePickerCompleteDelegates.Length] = InDelegate;
    }
}
function ClearPeoplePickerCompleteDelegate(byte LocalUserNum,delegate<OnPeoplePickerComplete> InDelegate)
{
    local int RemoveIndex;

    RemoveIndex = PeoplePickerCompleteDelegates.Find(InDelegate);
    // Remove this delegate from the array if found
    if (RemoveIndex != INDEX_NONE)
    {
        PeoplePickerCompleteDelegates.Remove(RemoveIndex,1);
    }
}

// Displays UI for sending data to other users using system-supplied UI
function bool ShowDataSendingUI(byte LocalUserNum, string Message, string DataName, string DataDescription, array<byte> Data, int MaxSelectableUsers);
delegate OnAcceptReceivedData(string Data);
function AddAcceptReceivedDataDelegate(byte LocalUserNum, delegate<OnAcceptReceivedData> InDelegate);
function ClearAcceptReceivedDataDelegate(byte LocalUserNum, delegate<OnAcceptReceivedData> InDelegate);

/**
 * Displays the UI that shows the player list
 *
 * @param LocalUserNum the controller number of the associated user
 *
 * @return TRUE if it was able to show the UI, FALSE if it failed
 */
function bool ShowPlayersUI(byte LocalUserNum);

/**
 * Shows a custom players UI for the specified list of players
 *
 * @param LocalUserNum the controller number of the associated user
 * @param Players the list of players to show in the custom UI
 * @param Title the title to use for the UI
 * @param Description the text to show at the top of the UI
 *
 * @return TRUE if it was able to show the UI, FALSE if it failed
 */
function bool ShowCustomPlayersUI(byte LocalUserNum,const out array<UniqueNetId> Players,string Title,string Description);

//@HSL_BEGIN_XBOX
/**
 * Shows a custom players UI for the specified list of players
 *
 * @param LocalUserNum the controller number of the associated user
 * @param Players the list of players to show in the custom UI
 * @param Title the title to use for the UI
 * @param Description the text to show at the top of the UI
 *
 * @return TRUE if it was able to show the UI, FALSE if it failed
 */
function bool RecordPlayersRecentlyMet( byte LocalUserNum, out array<PlayerNameIdPair> Players, string GameDescription );
//@HSL_END_XBOX

/**
 * Unlocks an avatar award for the local user
 *
 * @param LocalUserNum the user to unlock the avatar item for
 * @param AvatarItemId the id of the avatar item to unlock
 */
function bool UnlockAvatarAward(byte LocalUserNum,int AvatarItemId);

/**
 * Reads the online profile settings for a given user and title id
 *
 * @param LocalUserNum the user that we are reading the data for
 * @param TitleId the title that the profile settings are being read for
 * @param ProfileSettings the object to copy the results to and contains the list of items to read
 *
 * @return true if the call succeeds, false otherwise
 */
function bool ReadCrossTitleProfileSettings(byte LocalUserNum,int TitleId,OnlineProfileSettings ProfileSettings);

/**
 * Delegate used when the last read profile settings request has completed
 *
 * @param LocalUserNum the controller index of the player who's read just completed
 * @param TitleId the title that the profile settings were read for
 * @param bWasSuccessful true if the async action completed without error, false if there was an error
 */
delegate OnReadCrossTitleProfileSettingsComplete(byte LocalUserNum,int TitleId,bool bWasSuccessful);

/**
 * Sets the delegate used to notify the gameplay code that the last read request has completed
 *
 * @param LocalUserNum which user to watch for read complete notifications
 * @param ReadProfileSettingsCompleteDelegate the delegate to use for notifications
 */
function AddReadCrossTitleProfileSettingsCompleteDelegate(byte LocalUserNum,delegate<OnReadCrossTitleProfileSettingsComplete> ReadProfileSettingsCompleteDelegate);

/**
 * Searches the existing set of delegates for the one specified and removes it
 * from the list
 *
 * @param LocalUserNum which user to watch for read complete notifications
 * @param ReadProfileSettingsCompleteDelegate the delegate to find and clear
 */
function ClearReadCrossTitleProfileSettingsCompleteDelegate(byte LocalUserNum,delegate<OnReadCrossTitleProfileSettingsComplete> ReadProfileSettingsCompleteDelegate);

/**
 * Returns the online profile settings for a given user and title id
 *
 * @param LocalUserNum the user that we are reading the data for
 * @param TitleId the title that the profile settings are being read for
 *
 * @return the profile settings object
 */
function OnlineProfileSettings GetCrossTitleProfileSettings(byte LocalUserNum,int TitleId);

/**
 * Removes a cached entry of a profile for the specified title id
 *
 * @param LocalUserNum the user that we are reading the data for
 * @param TitleId the title that the profile settings are being read for
 */
function ClearCrossTitleProfileSettings(byte LocalUserNum,int TitleId);

/**
 * Shows a dialog with the message pre-populated in it
 *
 * @param LocalUserNum the user sending the message
 * @param Recipients the list of people to send the message to
 * @param MessageTitle the title of the message being sent
 * @param NonEditableMessage the portion of the message that the user cannot edit
 * @param EditableMessage the portion of the message the user can edit
 *
 * @return true if successful, false otherwise
 */
function bool ShowCustomMessageUI(byte LocalUserNum,const out array<UniqueNetId> Recipients,string MessageTitle,string NonEditableMessage,optional string EditableMessage);

/**
 * Shows a system dialog with the given error code and context
 *
 * @param ErrorCode the error code to display
 * @param ErrorContext the error context to display
 *
 * @return true of successful, false otherwise
 */
native function bool ShowSystemErrorUI(int ErrorCode, string ErrorContext);

/**
 * Shows a customized system dialog with the given error code, context, title and content
 *
 * @param ErrorCode the error code to display
 * @param ErrorContext the error context to display
 * @param DialogTitle the title of the dialog
 * @param DialogContent the content of the dialog
 *
 * @return true of successful, false otherwise
 */
native function bool ShowCustomErrorUI(int ErrorCode, string ErrorContext, string DialogTitle, string DialogContent);

/**
 * Look up a player's nickname from their net ID
 *
 * @param InPlayerId the player ID for which to retrieve the nickname
 * @param OutPlayerNickname the nickname for the player with the given ID
 *
 * @return true if successful, false otherwise
 */
native function bool GetPlayerNicknameForPlayerId(UniqueNetId InPlayerId, out string OutPlayerNickname);

/**
 * Look up a player's net ID from their nickname
 *
 * @param InPlayerNickname the nickname to look up a player ID for
 * @param OutPlayerId the player ID for the player with the given nickname
 *
 * @return true if successful, false otherwise
 */
native function bool GetPlayerIDForPlayerNickname(string InPlayerNickname, out UniqueNetId OutPlayerId);

/**
 * Caches the controller that the player logged in with
*/
native function CacheLoggedInGamepad();

/**
 * Asynchronously retrieve a set of OnlineProfiles for a list of Player IDs
 *
 * @param PlayerIDs the list of Player IDs for which to retrieve OnlineProfiles
 *
 * @return true if the async action began successfully, false otherwise
 */
native function bool ReadOnlineProfilesForPlayers(array<string> PlayerIDs);

/**
 * Delegate fired when an OnlineProfile read completes
 *
 * @param bWasSuccessful true if the async action completed without error, false if there was an error
 * @param PlayerIDs the list of Player IDs that the request originated with
 * @param OnlineProfiles the list of OnlineProfiles for the requested Player IDs
 */
delegate OnReadOnlineProfilesComplete(bool bWasSuccessful, array<string> PlayerIDs, array<OnlineProfile> OnlineProfiles);

/**
 * Adds the delegate used to notify the gameplay code that an OnlineProfile read has completed
 *
 * @param ReadOnlineProfileDelegate the delegate to use for notifications
 */
function AddReadOnlineProfilesCompleteDelegate(delegate<OnReadOnlineProfilesComplete> ReadOnlineProfileDelegate)
{
	`AddUniqueItemToArray(ReadOnlineProfileDelegates, ReadOnlineProfileDelegate);
}

/**
 * Removes the specified delegate from the list of callbacks
 *
 * @param ReadOnlineProfileDelegate the delegate to use for notifications
 */
function ClearReadOnlineProfilesCompleteDelegate(delegate<OnReadOnlineProfilesComplete> ReadOnlineProfileDelegate)
{
	ReadOnlineProfileDelegates.RemoveItem(ReadOnlineProfileDelegate);
}

/**
 * Delegate used when registration of a local talker completes
 *
 * @param LocalUserNum the controller index of the player who is registered as a local talker
  * @param bWasSuccessful true if the async action completed without error, false if there was an error
 */
delegate OnRegisterLocalTalkerComplete(byte LocalUserNum,bool bWasSuccessful);

/**
 * Sets the delegate used to notify the gameplay code that the local talker registration has completed
 *
 * @param RegisterLocalTalkerCompleteDelegate the delegate to use for notifications
 */
function AddRegisterLocalTalkerCompleteDelegate(delegate<OnRegisterLocalTalkerComplete> RegisterLocalTalkerCompleteDelegate)
{
	`AddUniqueItemToArray(RegisterLocalTalkerCompleteDelegates, RegisterLocalTalkerCompleteDelegate);
}

/**
 * Searches the existing set of delegates for the one specified and removes it
 * from the list
 *
  * @param RegisterLocalTalkerCompleteDelegate the delegate to find and clear
 */
function ClearRegisterLocalTalkerCompleteDelegate(delegate<OnRegisterLocalTalkerComplete> RegisterLocalTalkerCompleteDelegate)
{
	RegisterLocalTalkerCompleteDelegates.RemoveItem(RegisterLocalTalkerCompleteDelegate);
}

/**
 * Delegate used when unregistration of a local talker completes
 *
 * @param LocalUserNum the controller index of the player who is unregistered as a local talker
  * @param bWasSuccessful true if the async action completed without error, false if there was an error
 */
delegate OnUnregisterLocalTalkerComplete(byte LocalUserNum,bool bWasSuccessful);

/**
 * Sets the delegate used to notify the gameplay code that the local talker unregistration has completed
 *
 * @param UnregisterLocalTalkerCompleteDelegate the delegate to use for notifications
 */
function AddUnregisterLocalTalkerCompleteDelegate(delegate<OnUnregisterLocalTalkerComplete> UnregisterLocalTalkerCompleteDelegate)
{
	`AddUniqueItemToArray(UnregisterLocalTalkerCompleteDelegates, UnregisterLocalTalkerCompleteDelegate);
}


/**
 * Searches the existing set of delegates for the one specified and removes it
 * from the list
 *
  * @param UnregisterLocalTalkerCompleteDelegate the delegate to find and clear
 */
function ClearUnregisterLocalTalkerCompleteDelegate(delegate<OnUnregisterLocalTalkerComplete> UnregisterLocalTalkerCompleteDelegate)
{
	UnregisterLocalTalkerCompleteDelegates.RemoveItem(UnregisterLocalTalkerCompleteDelegate);
}


/**
 * Delegate used when unregistration of a remote talker completes
 *
 * @param netId ofthe player who is unregistered as a remote talker
 * @param bWasSuccessful true if the async action completed without error, false if there was an error
 */
delegate OnUnregisterRemoteTalkerComplete(UniqueNetId RemoteNetId,bool bWasSuccessful);

/**
 * Sets the delegate used to notify the gameplay code that the remote talker unregistration has completed
 *
 * @param UnregisterRemoteTalkerCompleteDelegate the delegate to use for notifications
 */
function AddUnregisterRemoteTalkerCompleteDelegate(delegate<OnUnregisterRemoteTalkerComplete> UnregisterRemoteTalkerCompleteDelegate)
{
	`AddUniqueItemToArray(UnregisterRemoteTalkerCompleteDelegates, UnregisterRemoteTalkerCompleteDelegate);
}

/**
 * Searches the existing set of delegates for the one specified and removes it
 * from the list
 *
  * @param UnregisterRemoteTalkerCompleteDelegate the delegate to find and clear
 */
function ClearUnregisterRemoteTalkerCompleteDelegate(delegate<OnUnregisterRemoteTalkerComplete> UnregisterRemoteTalkerCompleteDelegate)
{
	UnregisterRemoteTalkerCompleteDelegates.RemoveItem(UnregisterRemoteTalkerCompleteDelegate);
}

/**
 * Delegate used when unregistration of a remote talker completes
 *
 * @param netId ofthe player who is currently talking
 * @param bWasSuccessful true if the async action completed without error, false if there was an error
 */
delegate OnRemoteTalkerStatusChange(UniqueNetId RemoteNetId, bool bIsTalking);

/**
 * Sets the delegate used to notify the gameplay code that the remote talker unregistration has completed
 *
 * @param RemoteTalkerStatusChange the delegate to use for notifications
 */
function AddRemoteTalkerStatusChangeDelegate(delegate<OnRemoteTalkerStatusChange> RemoteTalkerStatusChange)
{
	`AddUniqueItemToArray(RemoteTalkerStatusChangeDelegates, RemoteTalkerStatusChange);
}

/**
 * Searches the existing set of delegates for the one specified and removes it
 * from the list
 *
  * @param RemoteTalkerStatusChange the delegate to find and clear
 */
function ClearRemoteTalkerStatusChangeDelegate(delegate<OnRemoteTalkerStatusChange> RemoteTalkerStatusChange)
{
	RemoteTalkerStatusChangeDelegates.RemoveItem(RemoteTalkerStatusChange);
}

/**
 * Sends reputation feedback
 *
 * @param SenderLocalUserNum The user that's sending the reputation feedback
 * @param ReputeeNetId The console id of the player getting reported
 * @param FeedbackType What type of feedback to send
 * @param ReportText Report message associated with the report
 */
native function bool SendReputationFeedback(byte SenderLocalUserNum, UniqueNetId ReputeeNetId, EReputationFeedbackType FeedbackType, string ReportText);

delegate OnTrialModeUpdate( bool bTrialActive );
function AddOnTrialModeUpdateDelegate( delegate<OnTrialModeUpdate> InDelegate ) { `AddUniqueItemToArray(TrialModeUpdateDelegates, InDelegate); }
function ClearOnTrialModeUpdatedDelegate( delegate<OnTrialModeUpdate> InDelegate ) { TrialModeUpdateDelegates.RemoveItem(InDelegate); }

//@HSL_BEGIN_PS4
function PostActivityFeedSample(int Foo, string Bar);
function bool ShowGamerCardUIByUsername(byte LocalUserNum, string UserName);
//@HSL_END_PS4

//@HSL_BEGIN_PS4
function StartRealtimeMultiplay();
function StopRealtimeMultiplay();
//@HSL_END_PS4


/**
 * Notifies the interested party that the micro transaction purchase was completed(success or fail)
 *
 * @param bWasSuccessful true if the async action completed without error, false if there was an error
 */
delegate OnReadMicroTransactionStatusComplete(bool bAuthorized, int iAppId, QWORD qOrderId);

/**
 * Adds the delegate to a list used to notify the gameplay code that the stats read has completed
 *
 * @param OnReadMicroTransactionStatusComplete the delegate to use for notifications
 */
function AddReadMicroTransactionStatusCompleteDelegate(delegate<OnReadMicroTransactionStatusComplete> ReadMicroTransactionStatusCompleteDelegate);

/**
 * Removes the delegate from the notify list
 *
 * @param ReadMicroTransactionStatusCompleteDelegate the delegate to use for notifications
 */
function ClearReadMicroTransactionStatusCompleteDelegate(delegate<OnReadMicroTransactionStatusComplete> ReadMicroTransactionStatusCompleteDelegate);

delegate OnIsConnectedToOnlineServiceChecked(bool bIsConnected);
function AddIsConnectedToOnlineServiceCheckedDelegate(delegate<OnIsConnectedToOnlineServiceChecked> InDelegate);
function ClearIsConnectedToOnlineServiceCheckedDelegate(delegate<OnIsConnectedToOnlineServiceChecked> InDelegate);
function IsConnectedToOnlineService();

/**
 * Get safe frame settings
 *
 * @param fSafeFrame safe frame value
 */
function SetSystemSafeFrame( float fSafeFrame );
function float GetSystemSafeFrame( );

/**
* Starts an asynchronous request for a user's avatar.
*
* @param LocalUserNum The controller number of the associated user making the request.
* @param PlayerNetId The network id of the player who's avatar is requested.
* @param Size The desired resolution of the avatar (Size x Size). Final texture size may vary.
* @param Obsolete Obsolete
*/
native function ReadOnlineAvatar(const UniqueNetId PlayerNetId, int Size);
//@HSL_END


//@HSL_BEGIN - JRO - 5/17/2016 - PS4 Activity Feeds
function bool AddInGamePost( int InPostID, optional string InPostParam ); // Unused...
function PostActivityFeedBossKill(string BossName, string ClassName, string MapName);
function PostActivityFeedTeamAward(string AwardName);
function PostActivityFeedPerkLevelUp(string PerkClassName, int Level);
//@HSL_END


//@HSL_BEGIN - BWJ - 5-26-16 - Support for reading store data
function ReadStoreData();
delegate OnStoreDataRead( bool bSuccessful );
function AddStoreDataReadCompleteDelegate( delegate<OnStoreDataRead> InDelegate );
function ClearStoreDataReadCompleteDelegate( delegate<OnStoreDataRead> InDelegate );

function ReadEntitlements();
delegate OnEntitlementsRead( bool bSuccess );
function AddOnEntitlementsReadDelegate( delegate<OnEntitlementsRead> InDelegate );
function ClearOnEntitlementsReadDelegate( delegate<OnEntitlementsRead> InDelegate );
//@HSL_END

//@HSL_BEGIN - BWJ - 12-1-16 - Support for save data
private event StartSaveDataRead( byte LocalUserNum, string FileName )
{
	ContentInterfaceImpl.AddReadSaveGameDataComplete(LocalUserNum, OnReadProfileSaveData);
	ContentInterfaceImpl.ReadSaveGameData(LocalUserNum, 0, "", "", FileName);
}

private function OnReadProfileSaveData(bool bWasSuccessful,byte LocalUserNum,int DeviceId,string FriendlyName,string FileName,string SaveFileName)
{
	ContentInterfaceImpl.ClearReadSaveGameDataComplete( LocalUserNum, OnReadProfileSaveData );
	HandleReadProfileSaveDataComplete( bWasSuccessful, LocalUserNum, SaveFileName );
}


private native function HandleReadProfileSaveDataComplete( bool bWasSuccessful, byte LocalUserNum, string SaveFileName );


private event WriteProfileData(byte LocalUserNum, string FileName, const out array<byte> ProfileData)
{
	ContentInterfaceImpl.AddWriteSaveGameDataComplete(LocalUserNum, OnWriteProfileSaveData);
	ContentInterfaceImpl.WriteSaveGameData(LocalUserNum, 0, "", "", FileName, ProfileData);
}

// Callback for profile writing complete
private function OnWriteProfileSaveData(bool bWasSuccessful,byte LocalUserNum,int DeviceId,string FriendlyName,string FileName,string SaveFileName)
{
	ContentInterfaceImpl.ClearWriteSaveGameDataComplete(LocalUserNum, OnWriteProfileSaveData);
	HandleWriteProfileSaveDataComplete(bWasSuccessful, LocalUserNum, SaveFileName);
}

// Fire off write profile delegates in native
private native function HandleWriteProfileSaveDataComplete(bool bWasSuccessful, byte LocalUserNum, string SaveFileName);
//@HSL_END

//@HSL BEGIN - BWJ - 2-27-17 - Support for detecting default region
native function StartRegionPingAndSelectDefaultRegion(delegate<OnPingRegionsComplete> Callback);
//@HSL_END


defaultproperties
{
	bLoginStatusUpdated=FALSE
	bCurrentUserChanged=FALSE
	bConnectionStatusUpdated=FALSE
	bRefreshMarketplaceInventory=FALSE
	bConnectedToLIVENetwork=FALSE
	bControllerPairingChanged=FALSE
    bIsAppInFocus=TRUE
	bIsAppSuspended =FALSE
    bIsAppConstrained=FALSE
	ConnectionTimeUpdateDelta=1.0f
}
