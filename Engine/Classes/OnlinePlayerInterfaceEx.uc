/**
 * Copyright 1998-2013 Epic Games, Inc. All Rights Reserved.
 */

/**
 * This interface provides extended player functionality not supported by
 * all platforms. The OnlineSubsystem will return NULL when requesting this
 * interface on a platform where it is not supporeted.
 */
interface OnlinePlayerInterfaceEx dependson(OnlineSubsystem);

/**
 * Displays the UI that allows a player to give feedback on another player
 *
 * @param LocalUserNum the controller number of the associated user
 * @param PlayerId the id of the player having feedback given for
 *
 * @return TRUE if it was able to show the UI, FALSE if it failed
 */
function bool ShowFeedbackUI(byte LocalUserNum,UniqueNetId PlayerId);

//@HSL_BEGIN_XBOX
/**
 * Displays the UI with Help documentation
 *
 * @param LocalUserNum the controller number of the associated user
 *
 * @return TRUE if the async show command is processing, FALSE if it failed to initialize
 */
function bool ShowHelpUI(byte LocalUserNum);

/**
 * Displays the UI with Help documentation for a given error the application has encountered
 *
 * @param ContextId application specific context within which the error occurred
 * @param ErrorString a string representation of the error
 *
 * @return TRUE if the async show command is processing, FALSE if it failed to initialize
 */
function bool ShowHelpForErrorUI(string ContextId, string ErrorString);

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
function AddShowHelpCompleteDelegate(delegate<OnShowHelpComplete> HelpDelegate);

/**
 * Removes the specified delegate from the list of callbacks
 *
 * @param ShowHelpDelegate the delegate to use for notifications
 */
function ClearShowHelpCompleteDelegate(delegate<OnShowHelpComplete> HelpDelegate);

/**
 * Displays the UI with Help documentation
 *
 * @param URL link to show
 *
 * @return TRUE if the show command succeded, FALSE otherwise
 */
function bool ShowVideo(string URL);

/**
 * Delegate used when a show gamer card request has completed
 */
delegate OnShowGamerCardComplete(bool bWasSuccessful);

/**
 * Adds the delegate used to notify the gameplay code that a show gamer card request has finished
 *
 * @param OnShowGamerCardComplete the delegate to use for notifications
 */
function AddShowGamerCardCompleteDelegate(delegate<OnShowGamerCardComplete> GamerCardDelegate);

/**
 * Removes the specified delegate from the list of callbacks
 *
 * @param OnShowGamerCardComplete the delegate to use for notifications
 */
function ClearShowGamerCardCompleteDelegate(delegate<OnShowGamerCardComplete> GamerCardDelegate);
//@HSL_END_XBOX

/**
 * Displays the gamer card UI for the specified player
 *
 * @param LocalUserNum the controller number of the associated user
 * @param PlayerId the id of the player to show the gamer card of
 *
 * @return TRUE if it was able to show the UI, FALSE if it failed
 */
function bool ShowGamerCardUI(byte LocalUserNum,UniqueNetId PlayerId);
// @zombie_ps4_begin - ccooper 10/3/2013 - Adding a username version which works for PSN
function bool ShowGamerCardUIByUsername(byte LocalUserNum, string UserName);
// @zombie_ps4_end

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
function bool ShowInviteUI(byte LocalUserNum,optional string InviteText);

//@HSL_BEGIN_XBOX
/**
 * Displays the people picker ui
 *
 * @param LocalUserNum the local user sending the invite
 * @param People the people to fill out the people picker list with
 * @param Text the text to show in the people picker
 */
function bool ShowPeoplePickerUI(byte LocalUserNum, array<OnlineFriend> People, int MaxSelectable, optional string Text);

/**
 * Delegate used when the device selection request has completed
 *
 * @param bWasSuccessful true if the async action completed without error, false if there was an error
 */
delegate OnPeoplePickerComplete(bool bWasSuccessful, array<OnlineFriend> PeoplePicked);

/**
 * Adds the delegate used to notify the gameplay code that the user has completed
 * their device selection
 *
 * @param DeviceDelegate the delegate to use for notifications
 */
function AddPeoplePickerCompleteDelegate(byte LocalUserNum,delegate<OnPeoplePickerComplete> InDelegate);

/**
 * Removes the specified delegate from the list of callbacks
 *
 * @param DeviceDelegate the delegate to use for notifications
 */
function ClearPeoplePickerCompleteDelegate(byte LocalUserNum,delegate<OnPeoplePickerComplete> InDelegate);

// Displays UI for sending data to other users using system-supplied UI
function bool ShowDataSendingUI(byte LocalUserNum, string Message, string DataName, string DataDescription, array<byte> Data, int MaxSelectableUsers);
delegate OnAcceptReceivedData(string Data);
function AddAcceptReceivedDataDelegate(byte LocalUserNum, delegate<OnAcceptReceivedData> InDelegate);
function ClearAcceptReceivedDataDelegate(byte LocalUserNum, delegate<OnAcceptReceivedData> InDelegate);

/**
 * Displays the UI for a products details 
 *
 * @param LocalUserNum the local user viewing available content
 * @param ParentProductId the product ID of the parent product for which to show child content
 */
function bool ShowProductDetailsUI(byte LocalUserNum, optional string ParentProductId);
//@HSL_END_XBOX

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
 function bool ShowContentMarketplaceUI(byte LocalUserNum, int ParentProductType, int RequestedProductTypes, optional string ParentProductId);

/**
 * Displays the purchase UI for an offer
 *
 * @param LocalUserNum the local user viewing available content
 * @param Offer the offer that you want the purchase screen shown for
 */
function bool ShowContentPurchaseUI(byte LocalUserNum, string Offer);

/**
 * Displays the redeem code UI for content
 *
 * @param LocalUserNum the local user viewing available content
 * @param Offer the offer that you want the redeem code screen shown for
 */
function bool ShowContentRedeemCodeUI(byte LocalUserNum, string Offer);

/**
 * Close the current content UI
 *
 */
function CloseCurrentContentUI();
//@HSL_END_XBOX

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
function bool ShowFriendsInviteUI(byte LocalUserNum,UniqueNetId PlayerId);

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

//@zombie_ps4_begin
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
function bool RecordPlayersRecentlyMet( byte LocalUserNum, out array<PlayerNameIdPair> Players, string GameDescription ); //@HSL_BEGIN - JRO - 4/28/2016 - PS4 needs player names

/**
 * Adds an In Game Post to the Activity Feed
 *
 * @param InNameID the string associated with the post
 *
 * @return TRUE if it was able to show the UI, FALSE if it failed
 */
function bool AddInGamePost( int InPostID, optional string InPostParam );
//@zombie_ps4_end
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

//@HSL_BEGIN - JRO - 5/17/2016 - PS4 Activity Feeds
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

//@HSL_BEGIN - JRO - 6/1/2016 - Upsell
function UpsellPremiumOnlineService();
//@HSL_END


/**
 * Shows a system dialog with the given error code and context
 *
 * @param ErrorCode the error code to display
 * @param ErrorContext the error context to display
 *
 * @return true of successful, false otherwise
 */
function bool ShowSystemErrorUI(int ErrorCode, string ErrorContext);

//@HSL_BEGIN - BWJ - 6-21-16 - Error dialog support
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
function bool ShowCustomErrorUI(int ErrorCode, optional string ErrorContext, optional string DialogTitle, optional string DialogContent);
//@HSL_END


/**
 * Look up a player's nickname from their net ID
 *
 * @param InPlayerId the player ID for which to retrieve the nickname
 * @param OutPlayerNickname the nickname for the player with the given ID
 *
 * @return true if successful, false otherwise
 */
function bool GetPlayerNicknameForPlayerId(UniqueNetId InPlayerId, out string OutPlayerNickname);

/**
 * Look up a player's net ID from their nickname
 *
 * @param InPlayerNickname the nickname to look up a player ID for
 * @param OutPlayerId the player ID for the player with the given nickname
 *
 * @return true if successful, false otherwise
 */
function bool GetPlayerIDForPlayerNickname(string InPlayerNickname, out UniqueNetId OutPlayerId);

/**
 * Asynchronously retrieve a set of OnlineProfiles for a list of Player IDs
 *
 * @param PlayerIDs the list of Player IDs for which to retrieve OnlineProfiles
 *
 * @return true if the async action began successfully, false otherwise
 */
function bool ReadOnlineProfilesForPlayers(array<string> PlayerIDs);

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
function AddReadOnlineProfilesCompleteDelegate(delegate<OnReadOnlineProfilesComplete> ReadOnlineProfileDelegate);

/**
 * Removes the specified delegate from the list of callbacks
 *
 * @param ReadOnlineProfileDelegate the delegate to use for notifications
 */
function ClearReadOnlineProfilesCompleteDelegate(delegate<OnReadOnlineProfilesComplete> ReadOnlineProfileDelegate);


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
function AddRegisterLocalTalkerCompleteDelegate(delegate<OnRegisterLocalTalkerComplete> RegisterLocalTalkerCompleteDelegate);

/**
 * Searches the existing set of delegates for the one specified and removes it
 * from the list
 *
  * @param RegisterLocalTalkerCompleteDelegate the delegate to find and clear
 */
function ClearRegisterLocalTalkerCompleteDelegate(delegate<OnRegisterLocalTalkerComplete> RegisterLocalTalkerCompleteDelegate);


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
function AddUnregisterLocalTalkerCompleteDelegate(delegate<OnUnregisterLocalTalkerComplete> UnregisterLocalTalkerCompleteDelegate);

/**
 * Searches the existing set of delegates for the one specified and removes it
 * from the list
 *
  * @param UnregisterLocalTalkerCompleteDelegate the delegate to find and clear
 */
function ClearUnregisterLocalTalkerCompleteDelegate(delegate<OnUnregisterLocalTalkerComplete> UnregisterLocalTalkerCompleteDelegate);


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
 * @param UnregisterRmeoteTalkerCompleteDelegate the delegate to use for notifications
 */
function AddUnregisterRemoteTalkerCompleteDelegate(delegate<OnUnregisterRemoteTalkerComplete> UnregisterRemoteTalkerCompleteDelegate);

/**
 * Searches the existing set of delegates for the one specified and removes it
 * from the list
 *
  * @param UnregisterRmeoteTalkerCompleteDelegate the delegate to find and clear
 */
function ClearUnregisterRemoteTalkerCompleteDelegate(delegate<OnUnregisterRemoteTalkerComplete> UnregisterRemoteTalkerCompleteDelegate);

/**
 * Delegate used when unregistration of a remote talker completes
 *
 * @param netId ofthe player who is unregistered as a remote talker
 * @param bWasSuccessful true if the async action completed without error, false if there was an error
 */
delegate OnRemoteTalkerStatusChange(UniqueNetId RemoteNetId, bool bIsTalking);

/**
 * Sets the delegate used to notify the gameplay code that the remote talker unregistration has completed
 *
 * @param UnregisterRmeoteTalkerCompleteDelegate the delegate to use for notifications
 */
function AddPlayerTalkingDelegate(delegate<OnRemoteTalkerStatusChange> RemoteTalkerStatusChangeDelegate);

/**
 * Searches the existing set of delegates for the one specified and removes it
 * from the list
 *
  * @param UnregisterRmeoteTalkerCompleteDelegate the delegate to find and clear
 */
function ClearPlayerTalkingDelegate(delegate<OnRemoteTalkerStatusChange> RemoteTalkerStatusChangeDelegate);
//@HSL_END_XBOX