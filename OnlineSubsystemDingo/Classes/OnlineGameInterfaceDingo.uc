/**
 * Copyright 1998-2012 Epic Games, Inc. All Rights Reserved.
 */

/**
 * Class that implements a Dingo version of the game interface
 */
class OnlineGameInterfaceDingo extends OnlineGameInterfaceImpl
	native
	config(Engine);

enum EMatchmakingStatus
{
	MMS_Canceled,
	MMS_Expired,
	MMS_Found,
	MMS_None,
	MMS_Searching
};


var array<delegate<OnQueryMatchmakingForSessionComplete> > QueryMatchmakingForSessionCompleteDelegates;

var array<delegate<OnDeleteMatchTicketComplete> > DeleteMatchTicketCompleteDelegates;

var array<delegate<OnUpdateSessionPropertiesComplete> > UpdateSessionPropertiesCompleteDelegates;

var array<delegate<OnGamePlayersChanged> > GamePlayersChangedDelegates;

var array<delegate<OnMatchStatusChanged> > MatchStatusChangedDelegates;

var array<delegate<OnQuerySessionsForUserComplete> > QuerySessionsForUserCompleteDelegates;

var array<delegate<OnRegisterPlayerComplete> > RegisterPlayerCompleteDelegates;

var array<delegate<OnUnregisterPlayerComplete> > UnregisterPlayerCompleteDelegates;

/** The array of delegates to notify when a remote talker is talking or not */
var array<delegate<OnMultiplayerSessionChange> > MultiplayerSessionChangeDelegates;

var array<delegate<OnGameInviteAccepted> > GameInviteAcceptedDelegates;

var config bool XboxServicesDebugLogging;

/** The list of session names that are pending leave so we don't attempt to leave the same one more than once */
var array<name> PendingSessionLeaveNames;

/** The amount of time a member is reserved in a session. NOTE: This must match the template in xdp */
var const config float SessionMemberReserveTimeout;

struct native SessionReserveInfo
{
    /** The local user num */
    var const byte LocalUserNum;
    /** The pending member */
    var const UniqueNetId PendingMember;
    /** The reserve time remaining for this member */
    var const float ReserveTimeRemaining;
    /** The name of the session */
    var const name SessionName;
    /** The total reserved time elapsed used to abort polling once it hits 5 minutes */
    var const float ReserveTimeElapsed;
};

/** The list of reserved session members */
var array<SessionReserveInfo> ReservedSessionMembers;

/** Keep track of session event info so we can always properly MultiplayerSessionEnd every MultiplayerSessionStart */
var string SessionEventUniqueId;
var Guid SessionEventGuid;
var string SessionEventMultiplayerCorrelationId;
var float SessionEventStartTime;

/** TRUE if multiplayer subscription has been lost */
var bool bMultiplayerSubscriptionLost;


/**
 * Delegate fired when the search for an online game has completed
 *
 * @param bWasSuccessful true if the async action completed without error, false if there was an error
 */
delegate OnFindOnlineGamesComplete(bool bWasSuccessful);

/**
 * Returns the game settings object for the session with a matching name
 *
 * @param SessionName the name of the session to return
 *
 * @return the game settings for this session name
 */
function OnlineGameSettings GetGameSettings(name SessionName)
{
	local int SessionIndex;

	SessionIndex = Sessions.Find('SessionName',SessionName);
	if (SessionIndex != INDEX_NONE)
	{
		return Sessions[SessionIndex].GameSettings;
	}
	return None;
}

/** Returns the currently set game search object */
function OnlineGameSearch GetGameSearch()
{
	return GameSearch;
}

/**
 * Creates an online game based upon the settings object specified.
 * NOTE: online game registration is an async process and does not complete
 * until the OnCreateOnlineGameComplete delegate is called.
 *
 * @param HostingPlayerNum the index of the player hosting the match
 * @param SessionName the name to use for this session so that multiple sessions can exist at the same time
 * @param NewGameSettings the settings to use for the new game session
 *
 * @return true if successful creating the session, false otherwise
 */
native function bool CreateOnlineGame(byte HostingPlayerNum,name SessionName,OnlineGameSettings NewGameSettings);

/**
 * Delegate fired when a create request has completed
 *
 * @param SessionName the name of the session this callback is for
 * @param bWasSuccessful true if the async action completed without error, false if there was an error
 */
delegate OnCreateOnlineGameComplete(name SessionName,bool bWasSuccessful);

/**
 * Sets the delegate used to notify the gameplay code that the online game they
 * created has completed the creation process
 *
 * @param CreateOnlineGameCompleteDelegate the delegate to use for notifications
 */
function AddCreateOnlineGameCompleteDelegate(delegate<OnCreateOnlineGameComplete> CreateOnlineGameCompleteDelegate)
{
	if (CreateOnlineGameCompleteDelegates.Find(CreateOnlineGameCompleteDelegate) == INDEX_NONE)
	{
		CreateOnlineGameCompleteDelegates[CreateOnlineGameCompleteDelegates.Length] = CreateOnlineGameCompleteDelegate;
	}
}

/**
 * Sets the delegate used to notify the gameplay code that the online game they
 * created has completed the creation process
 *
 * @param CreateOnlineGameCompleteDelegate the delegate to use for notifications
 */
function ClearCreateOnlineGameCompleteDelegate(delegate<OnCreateOnlineGameComplete> CreateOnlineGameCompleteDelegate)
{
	local int RemoveIndex;

	RemoveIndex = CreateOnlineGameCompleteDelegates.Find(CreateOnlineGameCompleteDelegate);
	if (RemoveIndex != INDEX_NONE)
	{
		CreateOnlineGameCompleteDelegates.Remove(RemoveIndex,1);
	}
}

/**
 * Updates the localized settings/properties for the game in question. Updates
 * the QoS packet if needed (starting & restarting QoS).
 *
 * @param SessionName the name of the session to update
 * @param UpdatedGameSettings the object to update the game settings with
 * @param bShouldRefreshOnlineData whether to submit the data to the backend or not
 *
 * @return true if successful creating the session, false otherwsie
 */
native function bool UpdateOnlineGame(name SessionName,OnlineGameSettings UpdatedGameSettings,optional bool bShouldRefreshOnlineData = false);

/**
 * Delegate fired when a update request has completed
 *
 * @param SessionName the name of the session this callback is for
 * @param bWasSuccessful true if the async action completed without error, false if there was an error
 */
delegate OnUpdateOnlineGameComplete(name SessionName,bool bWasSuccessful);

/**
 * Adds a delegate to the list of objects that want to be notified
 *
 * @param UpdateOnlineGameCompleteDelegate the delegate to use for notifications
 */
function AddUpdateOnlineGameCompleteDelegate(delegate<OnUpdateOnlineGameComplete> UpdateOnlineGameCompleteDelegate)
{
	if (UpdateOnlineGameCompleteDelegates.Find(UpdateOnlineGameCompleteDelegate) == INDEX_NONE)
	{
		UpdateOnlineGameCompleteDelegates[UpdateOnlineGameCompleteDelegates.Length] = UpdateOnlineGameCompleteDelegate;
	}
}

/**
 * Removes a delegate from the list of objects that want to be notified
 *
 * @param UpdateOnlineGameCompleteDelegate the delegate to use for notifications
 */
function ClearUpdateOnlineGameCompleteDelegate(delegate<OnUpdateOnlineGameComplete> UpdateOnlineGameCompleteDelegate)
{
	local int RemoveIndex;

	RemoveIndex = UpdateOnlineGameCompleteDelegates.Find(UpdateOnlineGameCompleteDelegate);
	if (RemoveIndex != INDEX_NONE)
	{
		UpdateOnlineGameCompleteDelegates.Remove(RemoveIndex,1);
	}
}

/**
 * Destroys the current online game
 * NOTE: online game de-registration is an async process and does not complete
 * until the OnDestroyOnlineGameComplete delegate is called.
 *
 * @param SessionName the name of the session to delete
 *
 * @return true if successful destroying the session, false otherwsie
 */
native function bool DestroyOnlineGame(name SessionName);

/**
 * Delegate fired when a destroying an online game has completed
 *
 * @param SessionName the name of the session this callback is for
 * @param bWasSuccessful true if the async action completed without error, false if there was an error
 */
delegate OnDestroyOnlineGameComplete(name SessionName,bool bWasSuccessful);

/**
 * Sets the delegate used to notify the gameplay code that the online game they
 * destroyed has completed the destruction process
 *
 * @param DestroyOnlineGameCompleteDelegate the delegate to use for notifications
 */
function AddDestroyOnlineGameCompleteDelegate(delegate<OnDestroyOnlineGameComplete> DestroyOnlineGameCompleteDelegate)
{
	if (DestroyOnlineGameCompleteDelegates.Find(DestroyOnlineGameCompleteDelegate) == INDEX_NONE)
	{
		DestroyOnlineGameCompleteDelegates[DestroyOnlineGameCompleteDelegates.Length] = DestroyOnlineGameCompleteDelegate;
	}
}

/**
 * Removes the delegate from the notification list
 *
 * @param DestroyOnlineGameCompleteDelegate the delegate to use for notifications
 */
function ClearDestroyOnlineGameCompleteDelegate(delegate<OnDestroyOnlineGameComplete> DestroyOnlineGameCompleteDelegate)
{
	local int RemoveIndex;

	RemoveIndex = DestroyOnlineGameCompleteDelegates.Find(DestroyOnlineGameCompleteDelegate);
	if (RemoveIndex != INDEX_NONE)
	{
		DestroyOnlineGameCompleteDelegates.Remove(RemoveIndex,1);
	}
}

/**
 * Searches for games matching the settings specified
 *
 * @param SearchingPlayerNum the index of the player searching for a match
 * @param SearchSettings the desired settings that the returned sessions will have
 *
 * @return true if successful searching for sessions, false otherwise
 */
native function bool FindOnlineGames(byte SearchingPlayerNum,OnlineGameSearch SearchSettings);

/**
 * Adds the delegate used to notify the gameplay code that the search they
 * kicked off has completed
 *
 * @param FindOnlineGamesCompleteDelegate the delegate to use for notifications
 */
function AddFindOnlineGamesCompleteDelegate(delegate<OnFindOnlineGamesComplete> FindOnlineGamesCompleteDelegate)
{
	// Only add to the list once
	if (FindOnlineGamesCompleteDelegates.Find(FindOnlineGamesCompleteDelegate) == INDEX_NONE)
	{
		FindOnlineGamesCompleteDelegates[FindOnlineGamesCompleteDelegates.Length] = FindOnlineGamesCompleteDelegate;
	}
}

/**
 * Removes the delegate from the notify list
 *
 * @param FindOnlineGamesCompleteDelegate the delegate to use for notifications
 */
function ClearFindOnlineGamesCompleteDelegate(delegate<OnFindOnlineGamesComplete> FindOnlineGamesCompleteDelegate)
{
	local int RemoveIndex;
	// Find it in the list
	RemoveIndex = FindOnlineGamesCompleteDelegates.Find(FindOnlineGamesCompleteDelegate);
	// Only remove if found
	if (RemoveIndex != INDEX_NONE)
	{
		FindOnlineGamesCompleteDelegates.Remove(RemoveIndex,1);
	}
}

/**
 * Cancels the current search in progress if possible for that search type
 *
 * @return true if successful searching for sessions, false otherwise
 */
native function bool CancelFindOnlineGames();

/**
 * Delegate fired when the cancellation of a search for an online game has completed
 *
 * @param bWasSuccessful true if the async action completed without error, false if there was an error
 */
delegate OnCancelFindOnlineGamesComplete(bool bWasSuccessful);

/**
 * Adds the delegate to the list to notify with
 *
 * @param CancelFindOnlineGamesCompleteDelegate the delegate to use for notifications
 */
function AddCancelFindOnlineGamesCompleteDelegate(delegate<OnCancelFindOnlineGamesComplete> CancelFindOnlineGamesCompleteDelegate)
{
	// Only add to the list once
	if (CancelFindOnlineGamesCompleteDelegates.Find(CancelFindOnlineGamesCompleteDelegate) == INDEX_NONE)
	{
		CancelFindOnlineGamesCompleteDelegates[CancelFindOnlineGamesCompleteDelegates.Length] = CancelFindOnlineGamesCompleteDelegate;
	}
}

/**
 * Removes the delegate from the notify list
 *
 * @param CancelFindOnlineGamesCompleteDelegate the delegate to use for notifications
 */
function ClearCancelFindOnlineGamesCompleteDelegate(delegate<OnCancelFindOnlineGamesComplete> CancelFindOnlineGamesCompleteDelegate)
{
	local int RemoveIndex;
	// Find it in the list
	RemoveIndex = CancelFindOnlineGamesCompleteDelegates.Find(CancelFindOnlineGamesCompleteDelegate);
	// Only remove if found
	if (RemoveIndex != INDEX_NONE)
	{
		CancelFindOnlineGamesCompleteDelegates.Remove(RemoveIndex,1);
	}
}

/**
 * Cleans up any platform specific allocated data contained in the search results
 *
 * @param Search the object to free search results for
 *
 * @return true if successful, false otherwise
 */
native function bool FreeSearchResults(OnlineGameSearch Search);

/**
 * Joins the game specified
 *
 * @param PlayerNum the index of the player searching for a match
 * @param SessionName the name of the session to join
 * @param DesiredGame the desired game to join
 *
 * @return true if the call completed successfully, false otherwise
 */
native function bool JoinOnlineGame(byte PlayerNum,name SessionName,const out OnlineGameSearchResult DesiredGame);
native function bool JoinOnlineGameBySessionHandle( byte PlayerNum, name SessionName, const string InSessionGuid );

/**
 * Delegate fired when the joing process for an online game has completed
 *
 * @param SessionName the name of the session this callback is for
 * @param bWasSuccessful true if the async action completed without error, false if there was an error
 */
delegate OnJoinOnlineGameComplete(name SessionName,bool bWasSuccessful);

/**
 * Sets the delegate used to notify the gameplay code that the join request they
 * kicked off has completed
 *
 * @param JoinOnlineGameCompleteDelegate the delegate to use for notifications
 */
function AddJoinOnlineGameCompleteDelegate(delegate<OnJoinOnlineGameComplete> JoinOnlineGameCompleteDelegate)
{
	if (JoinOnlineGameCompleteDelegates.Find(JoinOnlineGameCompleteDelegate) == INDEX_NONE)
	{
		JoinOnlineGameCompleteDelegates[JoinOnlineGameCompleteDelegates.Length] = JoinOnlineGameCompleteDelegate;
	}
}

/**
 * Removes the delegate from the notify list
 *
 * @param JoinOnlineGameCompleteDelegate the delegate to use for notifications
 */
function ClearJoinOnlineGameCompleteDelegate(delegate<OnJoinOnlineGameComplete> JoinOnlineGameCompleteDelegate)
{
	local int RemoveIndex;
	// Find it in the list
	RemoveIndex = JoinOnlineGameCompleteDelegates.Find(JoinOnlineGameCompleteDelegate);
	// Only remove if found
	if (RemoveIndex != INDEX_NONE)
	{
		JoinOnlineGameCompleteDelegates.Remove(RemoveIndex,1);
	}
}


/**
 * Delegate used when multiplayer session changed
 *
 * @param SessionName Name of the session that changed
 * @param SessionChanges Information on what in the session changed
 */
delegate OnMultiplayerSessionChange(Name SessionName, SessionUpdateInfo SessionChanges);

/**
 * Sets the delegate used to notify the gameplay code that the multiplayer session changed
 *
 * @param MultiplayerSessionChange the delegate to use for notifications
 */
function AddMultiplayerSessionChangeDelegate(delegate<OnMultiplayerSessionChange> MultiplayerSessionChange)
{
	`AddUniqueItemToArray(MultiplayerSessionChangeDelegates, MultiplayerSessionChange);
}

/**
 * Searches the existing set of delegates for the one specified and removes it
 * from the list
 *
  * @param MultiplayerSessionChange the delegate to find and clear
 */
function ClearMultiplayerSessionChangeDelegate(delegate<OnMultiplayerSessionChange> MultiplayerSessionChange)
{
	MultiplayerSessionChangeDelegates.RemoveItem(MultiplayerSessionChange);
}

/**
 * Submit the game session for matchmaking
 *
 * @param ScoutingPlayerNum The scout player who is registering the session
 * @param SessionName The name of the session to register
 * @param MatchTimeout Matchmaking timeout in seconds
 */
native function bool QueryMatchmakingForSession(byte ScoutingPlayerNum, name SessionName, int MatchTimeout, optional EOnlineCreateGameSessionFlag CreateGameSessionType=OCGSF_New);

native function bool QueryMatchmakingForSessionWithHopper(byte ScoutingPlayerNum, name SessionName, int MatchTimeout, string HopperName, optional EOnlineCreateGameSessionFlag CreateGameSessionType=OCGSF_New);

/**
 * Delegate fired when a matchmaking query
 *
 * @param SessionName the name of the session this callback is for
 * @param bWasSuccessful true if the async action completed without error, false if there was an error
 */
delegate OnQueryMatchmakingForSessionComplete(name SessionName, bool bWasSuccessful);

/**
 * Sets the delegate used to notify the gameplay code that the matchmaking query 
 * has completed 
 *
 * @param QueryMatchmakingForSessionCompleteDelegate the delegate to use for notifications
 */
function AddQueryMatchmakingForSessionCompleteDelegate(delegate<OnQueryMatchmakingForSessionComplete> QueryMatchmakingForSessionCompleteDelegate)
{
	if (QueryMatchmakingForSessionCompleteDelegates.Find(QueryMatchmakingForSessionCompleteDelegate) == INDEX_NONE)
	{
		QueryMatchmakingForSessionCompleteDelegates[QueryMatchmakingForSessionCompleteDelegates.Length] = QueryMatchmakingForSessionCompleteDelegate;
	}
}

/**
 * Removes the delegate from the list of notifications
 *
 * @param QueryMatchmakingForSessionCompleteDelegate the delegate to use for notifications
 */
function ClearQueryMatchmakingForSessionCompleteDelegate(delegate<OnQueryMatchmakingForSessionComplete> QueryMatchmakingForSessionCompleteDelegate)
{
	local int RemoveIndex;
	// Find it in the list
	RemoveIndex = QueryMatchmakingForSessionCompleteDelegates.Find(QueryMatchmakingForSessionCompleteDelegate);
	// Only remove if found
	if (RemoveIndex != INDEX_NONE)
	{
		QueryMatchmakingForSessionCompleteDelegates.Remove(RemoveIndex,1);
	}
}

/**
 * Delete the match ticket associated with a session.  Call when cancelling matchmaking.
 * Assumes the default hopper.
 *
 * @param SessionName The name of the session to delete the ticket for
 */
native function bool DeleteMatchTicket(byte ScoutingPlayerNum, name SessionName);

/**
 * Delete the match ticket associated with a session.  Call when cancelling matchmaking.
 *
 * @param SessionName The name of the session to delete the ticket for
 * @param HopperName The name of the Hopper used to search matchmaking
 */
native function bool DeleteMatchTicketWithHopper(byte ScoutingPlayerNum, name SessionName, string HopperName);

/**
 * Delegate fired when deleting a match ticket completes
 *
 * @param SessionName the name of the session this callback is for
 * @param bWasSuccessful true if the async action completed without error, false if there was an error
 */
delegate OnDeleteMatchTicketComplete(name SessionName, bool bWasSuccessful);

/**
 * Sets the delegate used to notify the gameplay code that the matchmaking query 
 * has completed 
 *
 * @param DeleteMatchTicketCompleteDelegate the delegate to use for notifications
 */
function AddDeleteMatchTicketCompleteDelegate(delegate<OnDeleteMatchTicketComplete> DeleteMatchTicketCompleteDelegate)
{
	`AddUniqueItemToArray(DeleteMatchTicketCompleteDelegates, DeleteMatchTicketCompleteDelegate);
}

/**
 * Removes the delegate from the list of notifications
 *
 * @param DeleteMatchTicketCompleteDelegate the delegate to use for notifications
 */
function ClearDeleteMatchTicketCompleteDelegate(delegate<OnDeleteMatchTicketComplete> DeleteMatchTicketCompleteDelegate)
{
	DeleteMatchTicketCompleteDelegates.RemoveItem(DeleteMatchTicketCompleteDelegate);
}

/** 
 * Queue a custom session property for update
 * NOT updated until UpdateSessionProperties() is called
 *
 * @param SessionName name of the session to update
 * @param PropertyName property to update
 * @param PropertyValue new value of property
 */
native function bool SetCustomSessionProperty(name SessionName, string PropertyName, string PropertyValue);

/** 
 * Queue a custom session property for delete
 * NOT updated until UpdateSessionProperties() is called
 *
 * @param SessionName name of the session to update
 * @param PropertyName property to delete
 */
native function bool DeleteCustomSessionProperty(name SessionName, string PropertyName);

/** 
 * Queue a custom session member property for update
 * NOT updated until UpdateSessionProperties() is called
 *
 * @param SessionName name of the session to update
 * @param PropertyName property to update
 * @param PropertyValue new value of property
 */
native function bool SetCustomMemberProperty(name SessionName, string PropertyName, string PropertyValue);

/** 
 * Queue a custom session member property for delete
 * NOT updated until UpdateSessionProperties() is called
 *
 * @param SessionName name of the session to update
 * @param PropertyName property to delete
 */
native function bool DeleteCustomMemberProperty(name SessionName, string PropertyName);

/**
 * Update the queued properties for the session
 *
 * @param SessionName name of the session to update
 */
native function bool UpdateSessionProperties(byte ScoutingUserNum, name SessionName);

/**
 * Delegate fired when updating session properties is complete
 * 
 * @param SessionName the name of the session this callback is for
 * @param bWasSuccessful true if the async action completed without error, false if there was an error
 */
delegate OnUpdateSessionPropertiesComplete(name SessionName, bool bWasSuccessful);

/**
 * Sets the delegate used to notify the gameplay code that the session properties update
 * has completed 
 *
 * @param UpdateSessionPropertiesCompleteDelegate the delegate to use for notifications
 */
function AddUpdateSessionPropertiesCompleteDelegate(delegate<OnUpdateSessionPropertiesComplete> UpdateSessionPropertiesCompleteDelegate)
{
	if (UpdateSessionPropertiesCompleteDelegates.Find(UpdateSessionPropertiesCompleteDelegate) == INDEX_NONE)
	{
		UpdateSessionPropertiesCompleteDelegates[UpdateSessionPropertiesCompleteDelegates.Length] = UpdateSessionPropertiesCompleteDelegate;
	}
}

/**
 * Removes the delegate from the list of notifications
 *
 * @param UpdateSessionPropertiesCompleteDelegate the delegate to use for notifications
 */
function ClearUpdateSessionPropertiesCompleteDelegate(delegate<OnUpdateSessionPropertiesComplete> UpdateSessionPropertiesCompleteDelegate)
{
	local int RemoveIndex;
	// Find it in the list
	RemoveIndex = UpdateSessionPropertiesCompleteDelegates.Find(UpdateSessionPropertiesCompleteDelegate);
	// Only remove if found
	if (RemoveIndex != INDEX_NONE)
	{
		UpdateSessionPropertiesCompleteDelegates.Remove(RemoveIndex,1);
	}
}

/**
 * Delegate fired when the List of available Game Players has changed
 *
 * @param SessionName the name of the session this callback is for
 * @param Players the array of available Game Players for the session
 */
delegate OnGamePlayersChanged(name SessionName, array<UniqueNetId> Players);

/**
 * Sets the delegate used to notify the gameplay code that the list of 
 * available game players has changed
 *
 * @param GamePlayersChangedDelegate the delegate to use for notifications
 */
function AddGamePlayersChangedDelegate(delegate<OnGamePlayersChanged> GamePlayersChangedDelegate)
{
	`AddUniqueItemToArray(GamePlayersChangedDelegates, GamePlayersChangedDelegate);
}

/**
 * Removes the delegate from the list of notifications
 *
 * @param GamePlayersChangedDelegate the delegate to use for notifications
 */
function ClearGamePlayersChangedDelegate(delegate<OnGamePlayersChanged> GamePlayersChangedDelegate)
{
	GamePlayersChangedDelegates.RemoveItem(GamePlayersChangedDelegate);
}

/**
 * Delegate fired when the status of a match session has changed
 *
 * @param SessionName the name of the session this callback is for
 */
delegate OnMatchStatusChanged(name SessionName, byte Status);

/**
 * Sets the delegate used to notify the gameplay code that the match status
 * has changed
 *
 * @param MatchStatusChangedDelegate the delegate to use for notifications
 */
function AddMatchStatusChangedDelegate(delegate<OnMatchStatusChanged> MatchStatusChangedDelegate)
{
	if (MatchStatusChangedDelegates.Find(MatchStatusChangedDelegate) == INDEX_NONE)
	{
		MatchStatusChangedDelegates[MatchStatusChangedDelegates.Length] = MatchStatusChangedDelegate;
	}
}

/**
 * Removes the delegate from the list of notifications
 *
 * @param MatchStatusChangedDelegate the delegate to use for notifications
 */
function ClearMatchStatusChangedDelegate(delegate<OnMatchStatusChanged> MatchStatusChangedDelegate)
{
	local int RemoveIndex;
	// Find it in the list
	RemoveIndex = MatchStatusChangedDelegates.Find(MatchStatusChangedDelegate);
	// Only remove if found
	if (RemoveIndex != INDEX_NONE)
	{
		MatchStatusChangedDelegates.Remove(RemoveIndex,1);
	}
}

/**
 * Leave an online game session
 *
 * @param LocalPlayerNum the player to leave
 * @param SessionName the session to leave
 * @param bClearSessionIfHost completely clears the session immediately (ie synchronously) if we are the host
 */
native function bool LeaveOnlineSession(byte LocalPlayerNum, name SessionName, optional bool bClearSessionIfHost = false);


/**
 * Leaves all online game sessions
 *
 * @param bClearSessionIfHost completely clears the sessions immediately (ie synchrdonously) if we are the host
 */
native function LeaveAllOnlineSessions(optional bool bClearSessionIfHost = false);

/**
 * Get a list of sessions for a user
 *
 * @param LocalPlayerNum The player to query
 */
native function bool QuerySessionsForUser(byte LocalPlayerNum);


/**
 * Get a list of sessions with a keyword
 *
 * @param LocalPlayerNum The player who is requesting the sessions
 * @param Keyword The keyworkd to search session with
 * @param SearchSettings the desired search to bind the session to
 */
native function bool QuerySessionsByKeyword(byte LocalPlayerNum, string Keyword, OnlineGameSearch SearchSettings);


/**
 * Delegate fired when QuerySessionsForUser has completed
 *
 * @param LocalPlayerNum the player queried
 * @param bWasSuccessful true if the async action completed without error, false if there was an error
 */
delegate OnQuerySessionsForUserComplete(byte LocalPlayerNum, bool bWasSuccessful);

/**
 * Sets the delegate used to notify the gameplay code that the query request
 * has completed 
 *
 * @param QuerySessionsForUserCompleteDelegate the delegate to use for notifications
 */
function AddQuerySessionsForUserCompleteDelegate(delegate<OnQuerySessionsForUserComplete> QuerySessionsForUserCompleteDelegate)
{
	`AddUniqueItemToArray(QuerySessionsForUserCompleteDelegates, QuerySessionsForUserCompleteDelegate);
}

/**
 * Removes the delegate from the list of notifications
 *
 * @param QuerySessionsForUserCompleteDelegate the delegate to use for notifications
 */
function ClearQuerySessionsForUserCompleteDelegate(delegate<OnQuerySessionsForUserComplete> QuerySessionsForUserCompleteDelegate)
{
	QuerySessionsForUserCompleteDelegates.RemoveItem(QuerySessionsForUserCompleteDelegate);
}


/**
 * Returns the platform specific connection information for joining the match.
 * Call this function from the delegate of join completion
 *
 * @param SessionName the name of the session to fetch the connection information for
 * @param ConnectInfo the out var containing the platform specific connection information
 *
 * @return true if the call was successful, false otherwise
 */
native function bool GetResolvedConnectString(name SessionName,out string ConnectInfo);

/**
 * Registers a player with the online service as being part of the online game
 *
 * @param SessionName the name of the session the player is joining
 * @param UniquePlayerId the player to register with the online servicer
 * @param bWasInvited whether the player was invited to the game or searched for it
 *
 * @return true if the call succeeds, false otherwise
 */
native function bool RegisterPlayer(name SessionName,UniqueNetId PlayerId,bool bWasInvited);

/**
 * Registers a group of players with the online service as being part of the online game
 *
 * @param SessionName the name of the session the player is joining
 * @param Players the list of players to register with the online service
 *
 * @return true if the call succeeds, false otherwise
 */
function bool RegisterPlayers(name SessionName,const out array<UniqueNetId> Players);

/**
 * Delegate fired when the registration process has completed
 *
 * @param SessionName the name of the session the player joined or not
 * @param PlayerId the player that was unregistered from the online service
 * @param bWasSuccessful true if the async action completed without error, false if there was an error
 */
delegate OnRegisterPlayerComplete(name SessionName,UniqueNetId PlayerId,bool bWasSuccessful);

/**
 * Sets the delegate used to notify the gameplay code that the player
 * registration request they submitted has completed
 *
 * @param RegisterPlayerCompleteDelegate the delegate to use for notifications
 */
function AddRegisterPlayerCompleteDelegate(delegate<OnRegisterPlayerComplete> RegisterPlayerCompleteDelegate)
{
	`AddUniqueItemToArray(RegisterPlayerCompleteDelegates, RegisterPlayerCompleteDelegate);
}

/**
 * Removes the delegate from the notify list
 *
 * @param RegisterPlayerCompleteDelegate the delegate to use for notifications
 */
function ClearRegisterPlayerCompleteDelegate(delegate<OnRegisterPlayerComplete> RegisterPlayerCompleteDelegate)
{
	RegisterPlayerCompleteDelegates.RemoveItem(RegisterPlayerCompleteDelegate);
}

/**
 * Unregisters a player with the online service as being part of the online game
 *
 * @param SessionName the name of the session the player is leaving
 * @param PlayerId the player to unregister with the online service
 *
 * @return true if the call succeeds, false otherwise
 */
native function bool UnregisterPlayer(name SessionName,UniqueNetId PlayerId);

/**
 * Unregisters a group of players with the online service as being part of the online game
 *
 * @param SessionName the name of the session the player is joining
 * @param Players the list of players to unregister with the online service
 *
 * @return true if the call succeeds, false otherwise
 */
function bool UnregisterPlayers(name SessionName,const out array<UniqueNetId> Players);

/**
 * Delegate fired when the unregistration process has completed
 *
 * @param SessionName the name of the session the player left
 * @param PlayerId the player that was unregistered from the online service
 * @param bWasSuccessful true if the async action completed without error, false if there was an error
 */
delegate OnUnregisterPlayerComplete(name SessionName,UniqueNetId PlayerId,bool bWasSuccessful);

/**
 * Sets the delegate used to notify the gameplay code that the player
 * unregistration request they submitted has completed
 *
 * @param UnregisterPlayerCompleteDelegate the delegate to use for notifications
 */
function AddUnregisterPlayerCompleteDelegate(delegate<OnUnregisterPlayerComplete> UnregisterPlayerCompleteDelegate)
{
	`AddUniqueItemToArray(UnregisterPlayerCompleteDelegates, UnregisterPlayerCompleteDelegate);
}

/**
 * Removes the delegate from the notify list
 *
 * @param UnregisterPlayerCompleteDelegate the delegate to use for notifications
 */
function ClearUnregisterPlayerCompleteDelegate(delegate<OnUnregisterPlayerComplete> UnregisterPlayerCompleteDelegate)
{
	UnregisterPlayerCompleteDelegates.RemoveItem(UnregisterPlayerCompleteDelegate);
}

/**
 * Marks an online game as in progress (as opposed to being in lobby or pending)
 *
 * @param SessionName the name of the session that is being started
 *
 * @return true if the call succeeds, false otherwise
 */
native function bool StartOnlineGame(name SessionName);

/**
 * Delegate fired when the online game has transitioned to the started state
 *
 * @param SessionName the name of the session the that has transitioned to started
 * @param bWasSuccessful true if the async action completed without error, false if there was an error
 */
delegate OnStartOnlineGameComplete(name SessionName,bool bWasSuccessful);

/**
 * Sets the delegate used to notify the gameplay code that the online game has
 * transitioned to the started state.
 *
 * @param StartOnlineGameCompleteDelegate the delegate to use for notifications
 */
function AddStartOnlineGameCompleteDelegate(delegate<OnStartOnlineGameComplete> StartOnlineGameCompleteDelegate)
{
	if (StartOnlineGameCompleteDelegates.Find(StartOnlineGameCompleteDelegate) == INDEX_NONE)
	{
		StartOnlineGameCompleteDelegates[StartOnlineGameCompleteDelegates.Length] = StartOnlineGameCompleteDelegate;
	}
}

/**
 * Removes the delegate from the notify list
 *
 * @param StartOnlineGameCompleteDelegate the delegate to use for notifications
 */
function ClearStartOnlineGameCompleteDelegate(delegate<OnStartOnlineGameComplete> StartOnlineGameCompleteDelegate)
{
	local int RemoveIndex;

	RemoveIndex = StartOnlineGameCompleteDelegates.Find(StartOnlineGameCompleteDelegate);
	if (RemoveIndex != INDEX_NONE)
	{
		StartOnlineGameCompleteDelegates.Remove(RemoveIndex,1);
	}
}

/**
 * Marks an online game as having been ended
 *
 * @param SessionName the name of the session the to end
 *
 * @return true if the call succeeds, false otherwise
 */
native function bool EndOnlineGame(name SessionName);

/**
 * Delegate fired when the online game has transitioned to the ending game state
 *
 * @param SessionName the name of the session the that was ended
 * @param bWasSuccessful true if the async action completed without error, false if there was an error
 */
delegate OnEndOnlineGameComplete(name SessionName,bool bWasSuccessful);

/**
 * Sets the delegate used to notify the gameplay code that the online game has
 * transitioned to the ending state.
 *
 * @param EndOnlineGameCompleteDelegate the delegate to use for notifications
 */
function AddEndOnlineGameCompleteDelegate(delegate<OnEndOnlineGameComplete> EndOnlineGameCompleteDelegate)
{
	if (EndOnlineGameCompleteDelegates.Find(EndOnlineGameCompleteDelegate) == INDEX_NONE)
	{
		EndOnlineGameCompleteDelegates[EndOnlineGameCompleteDelegates.Length] = EndOnlineGameCompleteDelegate;
	}
}

/**
 * Removes the delegate from the notify list
 *
 * @param EndOnlineGameCompleteDelegate the delegate to use for notifications
 */
function ClearEndOnlineGameCompleteDelegate(delegate<OnEndOnlineGameComplete> EndOnlineGameCompleteDelegate)
{
	local int RemoveIndex;

	RemoveIndex = EndOnlineGameCompleteDelegates.Find(EndOnlineGameCompleteDelegate);
	if (RemoveIndex != INDEX_NONE)
	{
		EndOnlineGameCompleteDelegates.Remove(RemoveIndex,1);
	}
}

/**
 * Tells the game to register with the underlying arbitration server if available
 *
 * @param SessionName the name of the session to register for arbitration with
 */
function bool RegisterForArbitration(name SessionName);

/**
 * Delegate fired when the online game has completed registration for arbitration
 *
 * @param SessionName the name of the session the that had arbitration pending
 * @param bWasSuccessful true if the async action completed without error, false if there was an error
 */
delegate OnArbitrationRegistrationComplete(name SessionName,bool bWasSuccessful);

/**
 * Sets the notification callback to use when arbitration registration has completed
 *
 * @param ArbitrationRegistrationCompleteDelegate the delegate to use for notifications
 */
function AddArbitrationRegistrationCompleteDelegate(delegate<OnArbitrationRegistrationComplete> ArbitrationRegistrationCompleteDelegate);

/**
 * Removes the specified delegate from the notification list
 *
 * @param ArbitrationRegistrationCompleteDelegate the delegate to use for notifications
 */
function ClearArbitrationRegistrationCompleteDelegate(delegate<OnArbitrationRegistrationComplete> ArbitrationRegistrationCompleteDelegate);

/**
 * Returns the list of arbitrated players for the arbitrated session
 *
 * @param SessionName the name of the session to get the arbitration results for
 *
 * @return the list of players that are registered for this session
 */
function array<OnlineArbitrationRegistrant> GetArbitratedPlayers(name SessionName);

/**
 * Called when a user accepts a game invitation. Allows the gameplay code a chance
 * to clean up any existing state before accepting the invite. The invite must be
 * accepted by calling AcceptGameInvite() on the OnlineGameInterface after clean up
 * has completed
 *
 * @param InviteResult the search/settings for the game we're joining via invite
 */
delegate OnGameInviteAccepted(const out OnlineGameSearchResult InviteResult, OnGameInviteAcceptedResult ResultReason);

/**
 * Sets the delegate used to notify the gameplay code when a game invite has been accepted
 *
 * @param LocalUserNum the user to request notification for
 * @param GameInviteAcceptedDelegate the delegate to use for notifications
 */
function AddGameInviteAcceptedDelegate(byte LocalUserNum,delegate<OnGameInviteAccepted> GameInviteAcceptedDelegate)
{
    `AddUniqueItemToArray(GameInviteAcceptedDelegates, GameInviteAcceptedDelegate);
}


/**
 * Removes the specified delegate from the notification list
 *
 * @param LocalUserNum the user to request notification for
 * @param GameInviteAcceptedDelegate the delegate to use for notifications
 */
function ClearGameInviteAcceptedDelegate(byte LocalUserNum,delegate<OnGameInviteAccepted> GameInviteAcceptedDelegate)
{
    GameInviteAcceptedDelegates.RemoveItem(GameInviteAcceptedDelegate);
}


/**
 * Tells the online subsystem to accept the game invite that is currently pending
 *
 * @param LocalUserNum the local user accepting the invite
 * @param SessionName the name of the session this invite is to be known as
 *
 * @return true if the game invite was able to be accepted, false otherwise
 */
function bool AcceptGameInvite(byte LocalUserNum,name SessionName,const out OnlineGameSearchResult DesiredGame);

/**
 * Updates the current session's skill rating using the list of players' skills
 *
 * @param SessionName the name of the session to update the skill rating for
 * @param Players the set of players to use in the skill calculation
 *
 * @return true if the update succeeded, false otherwise
 */
function bool RecalculateSkillRating(name SessionName,const out array<UniqueNetId> Players);

/**
 * Delegate fired when a skill rating request has completed
 *
 * @param SessionName the name of the session this callback is for
 * @param bWasSuccessful true if the async action completed without error, false if there was an error
 */
delegate OnRecalculateSkillRatingComplete(name SessionName,bool bWasSuccessful);

/**
 * Adds a delegate to the list of objects that want to be notified
 *
 * @param RecalculateSkillRatingCompleteDelegate the delegate to use for notifications
 */
function AddRecalculateSkillRatingCompleteDelegate(delegate<OnRecalculateSkillRatingComplete> RecalculateSkillRatingCompleteDelegate);

/**
 * Removes a delegate from the list of objects that want to be notified
 *
 * @param RecalculateSkillRatingCompleteDelegate the delegate to use for notifications
 */
function ClearRecalculateSkillRatingCompleteDelegate(delegate<OnRecalculateSkillRatingComplete> RecalculateSkillRatingGameCompleteDelegate);

/**
 * Migrates an existing online game on the host.
 * NOTE: online game migration is an async process and does not complete
 * until the OnMigrateOnlineGameComplete delegate is called.
 *
 * @param HostingPlayerNum the index of the player now hosting the match
 * @param SessionName the name of the existing session to migrate
 *
 * @return true if successful migrating the session, false otherwise
 */
function bool MigrateOnlineGame(byte HostingPlayerNum,name SessionName);

/**
 * Delegate fired when a create request has completed
 *
 * @param SessionName the name of the session this callback is for
 * @param bWasSuccessful true if the async action completed without error, false if there was an error
 */
delegate OnMigrateOnlineGameComplete(name SessionName,bool bWasSuccessful);

/**
 * Sets the delegate used to notify the gameplay code when the session migration completes
 *
 * @param MigrateOnlineGameCompleteDelegate the delegate to use for notifications
 */
function AddMigrateOnlineGameCompleteDelegate(delegate<OnMigrateOnlineGameComplete> MigrateOnlineGameCompleteDelegate);

/**
 * Removes the delegate from the list of notifications
 *
 * @param MigrateOnlineGameCompleteDelegate the delegate to use for notifications
 */
function ClearMigrateOnlineGameCompleteDelegate(delegate<OnMigrateOnlineGameComplete> MigrateOnlineGameCompleteDelegate);

/**
 * Joins the migrated game specified
 *
 * @param PlayerNum the index of the player about to join a match
 * @param SessionName the name of the migrated session to join
 * @param DesiredGame the desired migrated game to join
 *
 * @return true if the call completed successfully, false otherwise
 */
function bool JoinMigratedOnlineGame(byte PlayerNum,name SessionName,const out OnlineGameSearchResult DesiredGame);

/**
 * Delegate fired when the joing process for a migrated online game has completed
 *
 * @param SessionName the name of the session this callback is for
 * @param bWasSuccessful true if the async action completed without error, false if there was an error
 */
delegate OnJoinMigratedOnlineGameComplete(name SessionName,bool bWasSuccessful);

/**
 * Sets the delegate used to notify the gameplay code that the join request for a migrated session they
 * kicked off has completed
 *
 * @param JoinMigratedOnlineGameCompleteDelegate the delegate to use for notifications
 */
function AddJoinMigratedOnlineGameCompleteDelegate(delegate<OnJoinMigratedOnlineGameComplete> JoinMigratedOnlineGameCompleteDelegate)
{
	if (JoinMigratedOnlineGameCompleteDelegates.Find(JoinMigratedOnlineGameCompleteDelegate) == INDEX_NONE)
	{
		JoinMigratedOnlineGameCompleteDelegates.AddItem(JoinMigratedOnlineGameCompleteDelegate);
	}
}

/**
 * Removes the delegate from the list of notifications
 *
 * @param JoinMigratedOnlineGameCompleteDelegate the delegate to use for notifications
 */
function ClearJoinMigratedOnlineGameCompleteDelegate(delegate<OnJoinMigratedOnlineGameComplete> JoinMigratedOnlineGameCompleteDelegate)
{
	local int RemoveIndex;

	RemoveIndex = JoinMigratedOnlineGameCompleteDelegates.Find(JoinMigratedOnlineGameCompleteDelegate);
	if (RemoveIndex != INDEX_NONE)
	{
		JoinMigratedOnlineGameCompleteDelegates.Remove(RemoveIndex,1);
	}
}

/**
 * Fetches the additional data a session exposes outside of the online service.
 * NOTE: notifications will come from the OnFindOnlineGamesComplete delegate
 *
 * @param StartAt the search result index to start gathering the extra information for
 * @param NumberToQuery the number of additional search results to get the data for
 *
 * @return true if the query was started, false otherwise
 */
function bool QueryNonAdvertisedData(int StartAt,int NumberToQuery);

/**
 * Serializes the platform specific data into the provided buffer for the specified search result
 *
 * @param DesiredGame the game to copy the platform specific data for
 * @param PlatformSpecificInfo the buffer to fill with the platform specific information
 *
 * @return true if successful serializing the data, false otherwise
 */
native function bool ReadPlatformSpecificSessionInfo(const out OnlineGameSearchResult DesiredGame,out byte PlatformSpecificInfo[80]);

/**
 * Serializes the platform specific data into the provided buffer for the specified settings object.
 * NOTE: This can only be done for a session that is bound to the online system
 *
 * @param GameSettings the game to copy the platform specific data for
 * @param PlatformSpecificInfo the buffer to fill with the platform specific information
 *
 * @return true if successful reading the data for the session, false otherwise
 */
native function bool ReadPlatformSpecificSessionInfoBySessionName(name SessionName,out byte PlatformSpecificInfo[80]);


/**
 * Serializes the platform specific data into the provided buffer for the specified settings object.
 * NOTE: This can only be done for a session that is bound to the online system
 *
 * @param GameSettings the game to copy the platform specific data for
 * @param PlatformSpecificInfo the buffer to fill with the platform specific information
 *
 * @return true if successful reading the data for the session, false otherwise
 */
native function bool ReadSessionGuidBySessionName(name SessionName,out string SessionGuid);


/**
 * Creates a search result out of the platform specific data and adds that to the specified search object
 *
 * @param SearchingPlayerNum the index of the player searching for a match
 * @param SearchSettings the desired search to bind the session to
 * @param PlatformSpecificInfo the platform specific information to convert to a server object
 *
 * @return true if successful searching for sessions, false otherwise
 */
native function bool BindPlatformSpecificSessionToSearch(byte SearchingPlayerNum,OnlineGameSearch SearchSettings,byte PlatformSpecificInfo[80]);


/**
 * Creates a search result out of the session GUID and adds that to the specified search object
 *
 * @param SearchingPlayerNum the index of the player searching for a match
 * @param SearchSettings the desired search to bind the session to
 * @param SessionGuid the session GUID to convert to a server object
 *
 * @return true if successful serializing the data, false otherwise
 */
native function bool BindSessionGuidToSearch(byte SearchingPlayerNum,OnlineGameSearch SearchSettings,string SessionGuid);

/**
 * Delegate fired when QoS status has changed for a given search
 *
 * @param NumComplete the number completed thus far
 * @param NumTotal the number of QoS requests total
 */
delegate OnQosStatusChanged(int NumComplete,int NumTotal);

/**
 * Adds a delegate to the list of objects that want to be notified
 *
 * @param QosStatusChangedDelegate the delegate to use for notifications
 */
function AddQosStatusChangedDelegate(delegate<OnQosStatusChanged> QosStatusChangedDelegate);

/**
 * Removes the delegate from the list of notifications
 *
 * @param QosStatusChangedDelegate the delegate to use for notifications
 */
function ClearQosStatusChangedDelegate(delegate<OnQosStatusChanged> QosStatusChangedDelegate);


//@HSL_BEGIN_PS4 - BWJ - 11-17-10 - Adding this to all online sub systems
/**
 * Starts an async query for the total players. This is the amount of players the system thinks is playing right now, globally,
 *  not just on a specific server.
 *
 * @return TRUE if async call started, FALSE otherwise.
 */
function bool GetNumberOfCurrentPlayers();


delegate OnRetrievedGameSettingsForIP( bool bSuccessful, const out OnlineGameSearchResult ConnectResult );

//* ===================================================================================
//* @function	AddOnRetrieveGameSettingsForIPDelegate
//* @date	Mar 09, 2011 02:28PM
//* @author	Brandon Johnson
//* @brief	Adds a retrieve game settings for IP delegate
//* @param	NewRetrieveIPDelegate is the new delegate
//* ===================================================================================
function AddOnRetrieveGameSettingsForIPDelegate( delegate<OnRetrievedGameSettingsForIP> NewRetrieveIPDelegate );

//* ===================================================================================
//* @function	ClearOnRetrieveGameSettingsForIPDelegate
//* @date	Mar 09, 2011 02:29PM
//* @author	Brandon Johnson
//* @brief	Removes a retrieve game settings for IP delegate
//* @param	RetrieveIPDelegate is the delegate to remove
//* ===================================================================================
function ClearOnRetrieveGameSettingsForIPDelegate( delegate<OnRetrievedGameSettingsForIP> RetrieveIPDelegate );

//* ===================================================================================
//* @function	RetrieveGameSettingsForIP
//* @date	Mar 09, 2011 02:29PM
//* @author	Brandon Johnson
//* @brief	Retrieves the game settings for a particular IP address. Fires off a OnRetrievedGameSettingsForIP delegate when complete
//* @param	IPAddress is the string representation of the IP address in the form xxx.xxx.xxx.xxx:xxxx
//* ===================================================================================
function RetrieveGameSettingsForIP( string IPAddress );

function bool SendPlayerList( const array<PlayerReplicationInfo> Players );

function int GetNumberOfCurrentPlayersCached();

/**
 * Called when the async player count has completed
 *
 * @param TotalPlayers Count of players. -1 if unknown or error.
 */
delegate OnGetNumberOfCurrentPlayersComplete(int TotalPlayers);

/**
 * Sets the delegate used to notify the gameplay code that the player count request has completed
 *
 * @param GetNumberOfCurrentPlayersCompleteDelegate the delegate to use for notifications
 */
function AddGetNumberOfCurrentPlayersCompleteDelegate(delegate<OnGetNumberOfCurrentPlayersComplete> GetNumberOfCurrentPlayersCompleteDelegate);

/**
 * Clears the delegate used to notify the gameplay code that the player count read request has completed
 *
 * @param GetNumberOfCurrentPlayersCompleteDelegate the delegate to use for notifications
 */
function ClearGetNumberOfCurrentPlayersCompleteDelegate(delegate<OnGetNumberOfCurrentPlayersComplete> GetNumberOfCurrentPlayersCompleteDelegate);

function string GetRoomId();

delegate OnGetRoomIdFromTitleService(qword RoomId);
function GetRoomIdFromTitleService(qword DataId);
function GetRoomIdFromSessionId(string SessionId);
function AddGetRoomIdFromTitleServiceDelegate(delegate<OnGetRoomIdFromTitleService> InDelegate);
function ClearGetRoomIdFromTitleServiceDelegate(delegate<OnGetRoomIdFromTitleService> InDelegate);

function bool IsAllowedToNetworkHost();
function RunBandwidthTest();

function bool JoinOnlineGameByMatchingParams(QWORD RoomId, out OnlineGameSettings JoinedGameSettings);
function bool IsJoinOperationInProgress();
function bool SetRankedReadyStatus(bool bReady);
function bool IsCurrentRoomOwner();
//@HSL_END_PS4
