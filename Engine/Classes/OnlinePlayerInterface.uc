/**
 * Copyright 1998-2013 Epic Games, Inc. All Rights Reserved.
 */

/**
 * This interface provides accessors to the platform specific player methods.
 * NOTE: All players are referenced by their controller number, which is
 * zero on the PC.
 */
interface OnlinePlayerInterface	dependson(OnlineSubsystem);

/**
 * Delegate called when a player logs in/out
 *
 * @param LocalUserNum the player that logged in/out
 */
delegate OnLoginChange(byte LocalUserNum);

/**
 * Delegate used to notify when a login request was cancelled by the user
 */
delegate OnLoginCancelled();

//@HSL_BEGIN_XBOX
/**
 * Delegate called when the current user changes
 *
 * @param LocalUserNum - The index of the player who is now the current user
 * @param CurrentUser  - The current user's Gamertag
 * @param LoggedInUser - The logged in user's Gamertag
 */
delegate OnCurrentUserChanged(byte CurrentUserLocalNum, string CurrentUser, string LoggedInUser);

/** 
 * Delegate called when OSS-side tokens are acquired 
 */
delegate OnTokenAndSignatureRetrieved(byte LocalUserNum, string URL, string Token, string Signature);

function GetTokenAndSignatureForURL(byte LocalUserNum, string URL);

function AddURLTokenRetrievedDelegate(byte LocalUserNum,delegate<OnTokenAndSignatureRetrieved> tsrDelegate);

function ClearURLTokenRetrievedDelegate(byte LocalUserNum, delegate<OnTokenAndSignatureRetrieved> tsrDelegate);
//@HSL_END_XBOX

/**
 * Delegate used in mute list change notifications
 */
delegate OnMutingChange();

/**
 * Delegate used in friends list change notifications
 */
delegate OnFriendsChange();

/**
 * Displays the UI that prompts the user for their login credentials. Each
 * platform handles the authentication of the user's data.
 *
 * @param bShowOnlineOnly whether to only display online enabled profiles or not
 *
 * @return TRUE if it was able to show the UI, FALSE if it failed
 */
//@HSL_BEGIN_XBOX
function bool ShowLoginUI(byte LocalUserNum, optional bool bShowOnlineOnly = false);
//@HSL_END_XBOX

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
function bool Login(byte LocalUserNum,string LoginName,string Password,optional bool bWantsLocalOnly);
//@HSL_BEGIN - BWJ - 6-21-16 - login callback support
delegate OnLoginComplete( byte LocalUserNum, bool bWasSuccessful, EOnlineServerConnectionStatus ErrorCode );
function AddLoginCompleteDelegate(byte LocalUserNum, delegate<OnLoginComplete> InDelegate);
function ClearLoginCompleteDelegate(byte LocalUserNum, delegate<OnLoginComplete> InDelegate);
//@HSL_END


/**
 * Logs the player into the online service using parameters passed on the
 * command line. Expects -Login=<UserName> -Password=<password>. If either
 * are missing, the function returns false and doesn't start the login
 * process
 *
 * @return true if the async call started ok, false otherwise
 */
function bool AutoLogin();

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
 * @param LoginDelegate the delegate to use for notifications
 */
function AddLoginFailedDelegate(byte LocalUserNum,delegate<OnLoginFailed> LoginDelegate);

/**
 * Removes the specified delegate from the notification list
 *
 * @param LocalUserNum the controller number of the associated user
 * @param LoginDelegate the delegate to use for notifications
 */
function ClearLoginFailedDelegate(byte LocalUserNum,delegate<OnLoginFailed> LoginDelegate);

/**
 * Signs the player out of the online service
 *
 * @param LocalUserNum the controller number of the associated user
 *
 * @return TRUE if the call succeeded, FALSE otherwise
 */
function bool Logout(byte LocalUserNum);

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

//@HSL_BEGIN_XBOX
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
function AddSystemUserContrllerPairingChangedDelegate(delegate<OnSystemUserControllerPairingChanged> PairingChangeDelegate);

/**
 * Removes the specified delegate from the notification list 
 *
 * @param PairingChangeDelegate the delegate to remove from notification
 */
function ClearSystemUserContrllerPairingChangedDelegate(delegate<OnSystemUserControllerPairingChanged> PairingChangeDelegate);

/**
 * Pairs a player and controller at a given index
 *
 * @param PlayerIndex the index of the desired player to pair
 * @param ControllerIndex the index of the desired controller to pair
 * @param PairIndex the index to pair at
 *
 * @return true if successfull, false otherwise
 */
function bool PairUserAndControllerAtIndex(byte PlayerIndex, byte ControllerIndex, INT PairIndex);
//@HSL_END_XBOX

/**
 * Fetches the login status for a given player
 *
 * @param LocalUserNum the controller number of the associated user
 *
 * @return the enum value of their status
 */
function ELoginStatus GetLoginStatus(byte LocalUserNum);

/**
 * Gets the platform specific unique id for the specified player
 *
 * @param LocalUserNum the controller number of the associated user
 * @param PlayerId the byte array that will receive the id
 *
 * @return TRUE if the call succeeded, FALSE otherwise
 */
function bool GetUniquePlayerId(byte LocalUserNum,out UniqueNetId PlayerId);

//@HSL_BEGIN_XBOX
/**
 * Gets the ControllerId for the platform specific unique Id 
 *
 * @param PlayerId the platform specific unique Id
 * @param ControllerId the byte that will receive the controllerId
 *
 * @return TRUE if the call succeeded, FALSE otherwise
 */
function bool GetControllerIdFromNetId(UniqueNetId PlayerId, out byte ControllerId);
//@HSL_END_XBOX 

/**
 * Reads the player's nick name from the online service
 *
 * @param LocalUserNum the controller number of the associated user
 *
 * @return a string containing the players nick name
 */
function string GetPlayerNickname(byte LocalUserNum);

/**
 * Determines whether the specified user is a guest login or not
 *
 * @param LocalUserNum the controller number of the associated user
 *
 * @return true if a guest, false otherwise
 */
function bool IsGuestLogin(byte LocalUserNum);

/**
 * Determines whether the specified user is a local (non-online) login or not
 *
 * @param LocalUserNum the controller number of the associated user
 *
 * @return true if a local profile, false otherwise
 */
function bool IsLocalLogin(byte LocalUserNum);

//@HSL_BEGIN - JRO - 3/21/2016 PS4 Sessions - Make sure they have the privileges needed to play online
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
function AddPrivilegeLevelCheckedDelegate(delegate<OnPrivilegeLevelChecked> PrivilegeDelegate);

/**
 * Removes the specified delegate from the notification list
 *
 * @param PrivilegeDelegate the delegate to use for notifications
 */
function ClearPrivilegeLevelCheckedDelegate(delegate<OnPrivilegeLevelChecked> PrivilegeDelegate);
//@HSL_END

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
function bool CanPlayOnline(byte LocalUserNum, out EFeaturePrivilegeLevel PrivilegeLevelHint, optional bool bAttemptToResolve = false, optional string Reason = "");

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
function bool CanCommunicateText(byte LocalUserNum, out EFeaturePrivilegeLevel PrivilegeLevelHint, optional bool bAttemptToResolve = false, optional string Reason = "");

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
function bool CanCommunicateVideo(byte LocalUserNum, out EFeaturePrivilegeLevel PrivilegeLevelHint, optional bool bAttemptToResolve = false, optional string Reason = "");

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
function bool CanCommunicateVoice(byte LocalUserNum, out EFeaturePrivilegeLevel PrivilegeLevelHint, optional bool bAttemptToResolve = false, optional string Reason = "");

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
function bool CanShareUserCreatedContent(byte LocalUserNum, out EFeaturePrivilegeLevel PrivilegeLevelHint, optional bool bAttemptToResolve = false, optional string Reason = "");

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
function bool CanPurchaseContent(byte LocalUserNum, out EFeaturePrivilegeLevel PrivilegeLevelHint, optional bool bAttemptToResolve = false, optional string Reason = "");

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
function bool CanViewPlayerProfiles(byte LocalUserNum, out EFeaturePrivilegeLevel PrivilegeLevelHint, optional bool bAttemptToResolve = false, optional string Reason = "");

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
function bool CanShowPresenceInformation(byte LocalUserNum, out EFeaturePrivilegeLevel PrivilegeLevelHint, optional bool bAttemptToResolve = false, optional string Reason = "");

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
function bool CanRecordDVRClips(byte LocalUserNum, out EFeaturePrivilegeLevel PrivilegeLevelHint, optional bool bAttemptToResolve = false, optional string Reason = "");

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
function bool CanUseCloudStorage(byte LocalUserNum, out EFeaturePrivilegeLevel PrivilegeLevelHint, optional bool bAttemptToResolve = false, optional string Reason = "");

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
function bool CanAccessPremiumContent(byte LocalUserNum, out EFeaturePrivilegeLevel PrivilegeLevelHint, optional bool bAttemptToResolve = false, optional string Reason = "");

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
function bool CanAccessPremiumVideoContent(byte LocalUserNum, out EFeaturePrivilegeLevel PrivilegeLevelHint, optional bool bAttemptToResolve = false, optional string Reason = "");

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
function bool CanBrowseInternet(byte LocalUserNum, out EFeaturePrivilegeLevel PrivilegeLevelHint, optional bool bAttemptToResolve = false, optional string Reason = "");

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
function bool CanShareWithSocialNetwork(byte LocalUserNum, out EFeaturePrivilegeLevel PrivilegeLevelHint, optional bool bAttemptToResolve = false, optional string Reason = "");

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
function bool CanShareKinectContent(byte LocalUserNum, out EFeaturePrivilegeLevel PrivilegeLevelHint, optional bool bAttemptToResolve = false, optional string Reason = "");

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
function bool CanUploadFitnessData(byte LocalUserNum, out EFeaturePrivilegeLevel PrivilegeLevelHint, optional bool bAttemptToResolve = false, optional string Reason = "");
//@HSL_END_XBOX

/**
 * Checks that a unique player id is part of the specified user's friends list
 *
 * @param LocalUserNum the controller number of the associated user
 * @param PlayerId the id of the player being checked
 *
 * @return TRUE if a member of their friends list, FALSE otherwise
 */
function bool IsFriend(byte LocalUserNum,UniqueNetId PlayerId);

/**
 * Checks that whether a group of player ids are among the specified player's
 * friends
 *
 * @param LocalUserNum the controller number of the associated user
 * @param Query an array of players to check for being included on the friends list
 *
 * @return TRUE if the call succeeded, FALSE otherwise
 */
function bool AreAnyFriends(byte LocalUserNum,out array<FriendsQuery> Query);

/**
 * Checks that a unique player id is on the specified user's mute list
 *
 * @param LocalUserNum the controller number of the associated user
 * @param PlayerId the id of the player being checked
 *
 * @return TRUE if the player should be muted, FALSE otherwise
 */
function bool IsMuted(byte LocalUserNum,UniqueNetId PlayerId);

/**
 * Displays the UI that shows a user's list of friends
 *
 * @param LocalUserNum the controller number of the associated user
 *
 * @return TRUE if it was able to show the UI, FALSE if it failed
 */
function bool ShowFriendsUI(byte LocalUserNum);

/**
 * Sets the delegate used to notify the gameplay code that a login changed
 *
 * @param LoginDelegate the delegate to use for notifications
 */
function AddLoginChangeDelegate(delegate<OnLoginChange> LoginDelegate);

/**
 * Removes the specified delegate from the notification list
 *
 * @param LoginDelegate the delegate to use for notifications
 */
function ClearLoginChangeDelegate(delegate<OnLoginChange> LoginDelegate);

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
function AddLoginStatusChangeDelegate(delegate<OnLoginStatusChange> LoginStatusDelegate,byte LocalUserNum);

/**
 * Removes the specified delegate from the notification list
 *
 * @param LoginDelegate the delegate to use for notifications
 * @param LocalUserNum the player to watch login status changes for
 */
function ClearLoginStatusChangeDelegate(delegate<OnLoginStatusChange> LoginStatusDelegate,byte LocalUserNum);

/**
 * Adds a delegate to the list of delegates that are fired when a login is cancelled
 *
 * @param CancelledDelegate the delegate to add to the list
 */
function AddLoginCancelledDelegate(delegate<OnLoginCancelled> CancelledDelegate);

/**
 * Removes the specified delegate from the notification list
 *
 * @param CancelledDelegate the delegate to remove fromt he list
 */
function ClearLoginCancelledDelegate(delegate<OnLoginCancelled> CancelledDelegate);

//@HSL_BEGIN_XBOX
/**
 * Adds a delegate to the list of delegates that are fired when the current user changes
 *
 * @param CurrentUserDelegate the delegate to add to the list
 */
function AddCurrentUserChangedDelegate(delegate<OnCurrentUserChanged> CurrentUserDelegate);

/**
 * Removes the specified delegate from the notification list
 *
 * @param CurrentUserDelegate the delegate to remove from the list
 */
function ClearCurrentUserChangedDelegate(delegate<OnCurrentUserChanged> CurrentUserDelegate);
//@HSL_END_XBOX

/**
 * Sets the delegate used to notify the gameplay code that a muting list changed
 *
 * @param MutingDelegate the delegate to use for notifications
 */
function AddMutingChangeDelegate(delegate<OnMutingChange> MutingDelegate);

/**
 * Clears the delegate used to notify the gameplay code that a muting list changed
 *
 * @param MutingDelegate the delegate to use for notifications
 */
function ClearMutingChangeDelegate(delegate<OnMutingChange> MutingDelegate);

/**
 * Sets the delegate used to notify the gameplay code that a friends list changed
 *
 * @param LocalUserNum the user to read the friends list of
 * @param FriendsDelegate the delegate to use for notifications
 */
function AddFriendsChangeDelegate(byte LocalUserNum,delegate<OnFriendsChange> FriendsDelegate);

/**
 * Sets the delegate used to notify the gameplay code that a friends list changed
 *
 * @param LocalUserNum the user to read the friends list of
 * @param FriendsDelegate the delegate to use for notifications
 */
function ClearFriendsChangeDelegate(byte LocalUserNum,delegate<OnFriendsChange> FriendsDelegate);

/**
 * Reads the online profile settings for a given user
 *
 * @param LocalUserNum the user that we are reading the data for
 * @param ProfileSettings the object to copy the results to and contains the list of items to read
 *
 * @return true if the call succeeds, false otherwise
 */
function bool ReadProfileSettings(byte LocalUserNum,OnlineProfileSettings ProfileSettings);

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
function AddReadProfileSettingsCompleteDelegate(byte LocalUserNum,delegate<OnReadProfileSettingsComplete> ReadProfileSettingsCompleteDelegate);

/**
 * Searches the existing set of delegates for the one specified and removes it
 * from the list
 *
 * @param LocalUserNum which user to watch for read complete notifications
 * @param ReadProfileSettingsCompleteDelegate the delegate to find and clear
 */
function ClearReadProfileSettingsCompleteDelegate(byte LocalUserNum,delegate<OnReadProfileSettingsComplete> ReadProfileSettingsCompleteDelegate);

/**
 * Returns the online profile settings for a given user
 *
 * @param LocalUserNum the user that we are reading the data for
 *
 * @return the profile settings object
 */
function OnlineProfileSettings GetProfileSettings(byte LocalUserNum);

/**
 * Writes the online profile settings for a given user to the online data store
 *
 * @param LocalUserNum the user that we are writing the data for
 * @param ProfileSettings the list of settings to write out
 *
 * @return true if the call succeeds, false otherwise
 */
function bool WriteProfileSettings(byte LocalUserNum,OnlineProfileSettings ProfileSettings);

/**
 * Delegate used when the last write profile settings request has completed
 *
 * @param LocalUserNum the controller index of the player who's write just completed
 * @param bWasSuccessful true if the async action completed without error, false if there was an error
 */
delegate OnWriteProfileSettingsComplete(byte LocalUserNum,bool bWasSuccessful);

/**
 * Sets the delegate used to notify the gameplay code that the last write request has completed
 *
 * @param LocalUserNum which user to watch for write complete notifications
 * @param WriteProfileSettingsCompleteDelegate the delegate to use for notifications
 */
function AddWriteProfileSettingsCompleteDelegate(byte LocalUserNum,delegate<OnWriteProfileSettingsComplete> WriteProfileSettingsCompleteDelegate);

/**
 * Clears the delegate used to notify the gameplay code that the last write request has completed
 *
 * @param LocalUserNum which user to watch for write complete notifications
 * @param WriteProfileSettingsCompleteDelegate the delegate to use for notifications
 */
function ClearWriteProfileSettingsCompleteDelegate(byte LocalUserNum,delegate<OnWriteProfileSettingsComplete> WriteProfileSettingsCompleteDelegate);

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
 * Searches the existing set of delegates for the one specified and removes it
 * from the list
 *
 * @param NetId the net id for the user to watch for read complete notifications
 * @param ReadPlayerStorageForNetIdCompleteDelegate the delegate to find and clear
 */
function ClearReadPlayerStorageForNetIdCompleteDelegate(UniqueNetId NetId,delegate<OnReadPlayerStorageForNetIdComplete> ReadPlayerStorageForNetIdCompleteDelegate);

/**
 * Returns the online player storage for a given local user
 *
 * @param LocalUserNum the user that we are reading the data for
 *
 * @return the player storage object
 */
function OnlinePlayerStorage GetPlayerStorage(byte LocalUserNum);

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
 * Clears the delegate used to notify the gameplay code that the last write request has completed
 *
 * @param LocalUserNum which user to watch for write complete notifications
 * @param WritePlayerStorageCompleteDelegate the delegate to use for notifications
 */
function ClearWritePlayerStorageCompleteDelegate(byte LocalUserNum,delegate<OnWritePlayerStorageComplete> WritePlayerStorageCompleteDelegate);

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
function bool ReadFriendsList(byte LocalUserNum,optional int Count,optional int StartingAt);

/**
 * Delegate used when the friends read request has completed
 *
 * @param bWasSuccessful true if the async action completed without error, false if there was an error
 */
delegate OnReadFriendsComplete(bool bWasSuccessful);

/**
 * Sets the delegate used to notify the gameplay code that the friends read request has completed
 *
 * @param LocalUserNum the user to read the friends list of
 * @param ReadFriendsCompleteDelegate the delegate to use for notifications
 */
function AddReadFriendsCompleteDelegate(byte LocalUserNum,delegate<OnReadFriendsComplete> ReadFriendsCompleteDelegate);

/**
 * Clears the delegate used to notify the gameplay code that the friends read request has completed
 *
 * @param LocalUserNum the user to read the friends list of
 * @param ReadFriendsCompleteDelegate the delegate to use for notifications
 */
function ClearReadFriendsCompleteDelegate(byte LocalUserNum,delegate<OnReadFriendsComplete> ReadFriendsCompleteDelegate);

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
function EOnlineEnumerationReadState GetFriendsList(byte LocalUserNum,out array<OnlineFriend> Friends,optional int Count,optional int StartingAt);

/**
 * Sets the online status information to use for the specified player. Used to
 * tell other players what the player is doing (playing, menus, away, etc.)
 *
 * @param LocalUserNum the controller number of the associated user
 * @param StatusId the status id to use (maps to strings where possible)
 * @param LocalizedStringSettings the list of localized string settings to set
 * @param Properties the list of properties to set
 */
//@HSL_BEGIN - JRO - 3/14/2016 - Changing signature so we can easily pass the useful info
function SetOnlineStatus(byte LocalUserNum,string StatusString,optional bool PlayerActive=true);
//@HSL_END

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
function bool ShowKeyboardUI(byte LocalUserNum,string TitleText,string DescriptionText,
	optional bool bIsPassword = false,
	optional bool bShouldValidate = true,
	optional string DefaultText,
	optional int MaxResultLength = 256);

//@HSL_BEGIN_XBOX
/**
 * Hides the UI that shows the keyboard for inputing text
 *
 * @param LocalUserNum the controller number of the associated user
 *
 * @return TRUE if it was able to hide the UI, FALSE if it failed
 */
function bool HideKeyboardUI(byte LocalUserNum);
//@HSL_END_XBOX

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
function AddKeyboardInputDoneDelegate(delegate<OnKeyboardInputComplete> InputDelegate);

/**
 * Clears the delegate used to notify the gameplay code that the user has completed
 * their keyboard input
 *
 * @param InputDelegate the delegate to use for notifications
 */
function ClearKeyboardInputDoneDelegate(delegate<OnKeyboardInputComplete> InputDelegate);

/**
 * Fetches the results of the input
 *
 * @param bWasCanceled whether the user cancelled the input or not
 *
 * @return the string entered by the user. Note the string will be empty if it
 * fails validation
 */
function string GetKeyboardInputResults(out byte bWasCanceled);

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
//@HSL_BEGIN_XBOX
function bool SendGameInviteToFriend(byte LocalUserNum,name SessionName,UniqueNetId Friend,optional string Text);

/**
 * Sends invitations to play in the player's current session
 *
 * @param LocalUserNum the user that is sending the invite
 * @param Friends the player to send the invite to
 * @param Text the text of the message for the invite
 *
 * @return true if successful, false otherwise
 */
function bool SendGameInviteToFriends(byte LocalUserNum,name SessionName,array<UniqueNetId> Friends,optional string Text);

//@HSL_BEGIN - JRO - 6/10/2016 - Used for Play Together feature
function bool SendGameInviteToUsers(string SessionId, name SessionName, array<string> MembersToInvite, optional string Text);
//@HSL_END

/**
 * Called when the online system receives a game invite that needs handling
 *
 * @param LocalUserNum the user that is receiving the invite
 * @param InviterName the nick name of the person sending the invite
 */
delegate OnReceivedGameInvite(byte LocalUserNum,string InviterName);
delegate OnReceivedGameInviteById(byte LocalUserNum, UniqueNetId InviterId);

/**
 * Adds the delegate used to notify the gameplay code that the user has received a game invite
 *
 * @param LocalUserNum the user associated with the notification
 * @param ReceivedGameInviteDelegate the delegate to use for notifications
 */
function AddReceivedGameInviteDelegate(byte LocalUserNum,delegate<OnReceivedGameInvite> ReceivedGameInviteDelegate);
function AddReceivedGameInviteByIdDelegate(byte LocalUserNum,delegate<OnReceivedGameInviteById> ReceivedGameInviteDelegate);

/**
 * Removes the delegate specified from the list
 *
 * @param LocalUserNum the user associated with the notification
 * @param ReceivedGameInviteDelegate the delegate to use for notifications
 */
function ClearReceivedGameInviteDelegate(byte LocalUserNum,delegate<OnReceivedGameInvite> ReceivedGameInviteDelegate);
function ClearReceivedGameInviteByIdDelegate(byte LocalUserNum,delegate<OnReceivedGameInviteById> ReceivedGameInviteDelegate);

//@HSL_BEGIN_XBOX
function CheckForGameInviteOnLaunch();
//@HSL_END_XBOX

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
function bool ReadAchievements(byte LocalUserNum,optional int TitleId = 0,optional bool bShouldReadText = true,optional bool bShouldReadImages = false);

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
function AddReadAchievementsCompleteDelegate(byte LocalUserNum,delegate<OnReadAchievementsComplete> ReadAchievementsCompleteDelegate);

/**
 * Clears the delegate used to notify the gameplay code that the achievements read request has completed
 *
 * @param LocalUserNum the user to read the achievements list for
 * @param ReadAchievementsCompleteDelegate the delegate to use for notifications
 */
function ClearReadAchievementsCompleteDelegate(byte LocalUserNum,delegate<OnReadAchievementsComplete> ReadAchievementsCompleteDelegate);

/**
 * Copies the list of achievements for the specified player and title id
 *
 * @param LocalUserNum the user to read the friends list of
 * @param Achievements the out array that receives the copied data
 * @param TitleId the title id of the game that these were read for
 *
 * @return OERS_Done if the read has completed, otherwise one of the other states
 */
function EOnlineEnumerationReadState GetAchievements(byte LocalUserNum,out array<AchievementDetails> Achievements,optional int TitleId = 0);