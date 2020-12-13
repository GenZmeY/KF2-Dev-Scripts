/**
 * Copyright 1998-2012 Epic Games, Inc. All Rights Reserved.
 */

/**
 * Class that implements a Dingo version of the game interface
 */
class OnlineStatsInterfaceDingo extends Object within OnlineSubsystemDingo
	native
	implements(OnlineStatsInterface)
	config(Engine);


`include(KFGame\KFOnlineStats.uci);


/** The owning subsystem that this object is providing an implementation for */
var OnlineSubsystemDingo OwningSubsystem;

/** The stats interface will cancel any profile read that takes longer than this timeout */
var config float ReadProfileAsyncTimeout;

/** Track the current stats read so we don't allow more than one in-flight at a time */
var init array<native pointer> CurrentStatsRead{class FDingoAsyncTaskReadOnlineStats};

/** This is the list of delegates requesting notification when a stats read finishes */
var array<delegate<OnReadOnlineStatsComplete> > ReadOnlineStatsCompleteDelegates;

/** Used to initialize ETW events for stats */
var bool  EventsRegistered;

enum RealTimeActivityConnectionStatus
{
	RTA_NotConnected,
	RTA_Connecting,
	RTA_Connected
};

struct native RealTimeActivitySubscriptionData
{
	var UniqueNetId PlayerNetId;
	var name StatName;
	var delegate<OnStatisticChanged> OnStatisticChanged;
	//var native hatpointer RTAStatisticChangeSubscription{Microsoft::Xbox::Services::RealTimeActivity::RealTimeActivityStatisticChangeSubscription};
};

struct native XboxLiveContextPlayerData
{
	var native hatpointer LiveContext{Microsoft::Xbox::Services::XboxLiveContext};
    var UniqueNetId PlayerNetId;
    var Guid PlayerSessionGuid;

	var RealTimeActivityConnectionStatus MultiplayerSubscriptionStatus;
	var RealTimeActivityConnectionStatus RTAConnectionStatus;
	var array<RealTimeActivitySubscriptionData> RTASubscriptions;
	//var native array<hatpointer> QueuedRTAChangeEvents {Microsoft::Xbox::Services::RealTimeActivity::RealTimeActivityStatisticChangeEventArgs};

	var qword StatisticChangedTokenKey;
	var qword WebSocketClosedTokenKey;

	structcpptext
	{
		FXboxLiveContextPlayerData()
		{
			appMemzero(this, sizeof(FXboxLiveContextPlayerData));
		}

		void SubscribeToStatisticEvent(FUniqueNetId PlayerNetId, FName StatName, FScriptDelegate EventDelegate);
		void UnsubscribeToStatisticEvent(FUniqueNetId PlayerNetId, FName StatName);
		void Update();

		private:
		void ConnectToRTAService();
		void OnRTAConnect();
		void OnRTADisconnect();
		//void OnRTAStatisticChanged(Microsoft::Xbox::Services::RealTimeActivity::RealTimeActivityStatisticChangeEventArgs^ args);
		void OnRTAWebSocketClosed(Windows::Networking::Sockets::WebSocketClosedEventArgs^ args);
		void SubscribeToRTA(FRealTimeActivitySubscriptionData& SubscriptionData);
		void UnsubscribeToRTA(FRealTimeActivitySubscriptionData& SubscriptionData);

		static FCriticalSection RTACriticalSection;

		public:
	}
};

var native map{QWORD, FXboxLiveContextPlayerData} PlayerXboxLiveContextMap;


/**
 * Notifies the interested party that the last stats read has completed
 *
 * @param bWasSuccessful true if the async action completed without error, false if there was an error
 */
delegate OnReadOnlineStatsComplete(bool bWasSuccessful);

/**
 * Reads a set of stats for a player
 *
 * @param LocalUserNum the local player having their stats queried
 * @param StatsRead holds the names of the stats to be queried and
 *		  results are copied into the specified object
 *
 * @return TRUE if the call is successful, FALSE otherwise
 */
native function bool ReadOnlineStatsForPlayer(byte LocalUserNum, OnlineStatsRead StatsRead);

/**
 * Reads a set of stats for the specified list of players
 *
 * @param Players the array of unique ids to read stats for
 * @param StatsRead holds the definitions of the tables to read the data from and
 *		  results are copied into the specified object
 *
 * @return TRUE if the call is successful, FALSE otherwise
 */
native function bool ReadOnlineStats(byte LocalUserNum, const out array<UniqueNetId> Players,OnlineStatsRead StatsRead);

/**
 * Reads a player's stats and all of that player's friends stats for the
 * specified set of stat views. This allows you to easily compare a player's
 * stats to their friends.
 *
 * @param LocalUserNum the local player having their stats and friend's stats read for
 * @param StatsRead holds the definitions of the tables to read the data from and
 *		  results are copied into the specified object
 *
 * @return TRUE if the call is successful, FALSE otherwise
 */
native function bool ReadOnlineStatsForFriends(byte LocalUserNum,OnlineStatsRead StatsRead, optional bool FavoriteFriendsOnly=false, optional int NumToRead = 100);

/**
 * Reads stats by ranking. This grabs the rows starting at StartIndex through
 * NumToRead and places them in the StatsRead object.
 *
 * @param StatsRead holds the definitions of the tables to read the data from and
 *		  results are copied into the specified object
 * @param StartIndex the starting rank to begin reads at (1 for top)
 * @param NumToRead the number of rows to read (clamped at 100 underneath)
 *
 * @return TRUE if the call is successful, FALSE otherwise
 */
native function bool ReadOnlineStatsByRank(byte LocalUserNum, OnlineStatsRead StatsRead,optional int StartIndex = 1,optional int NumToRead = 100);

/**
 * Reads stats by ranking centered around a player. This grabs a set of rows
 * above and below the player's current rank
 *
 * @param LocalUserNum the local player having their stats being centered upon
 * @param StatsRead holds the definitions of the tables to read the data from and
 *		  results are copied into the specified object
 * @param NumRows the number of rows to read above and below the player's rank
 *
 * @return TRUE if the call is successful, FALSE otherwise
 */
native function bool ReadOnlineStatsByRankAroundPlayer(byte LocalUserNum,OnlineStatsRead StatsRead,optional int NumRows = 10);

/**
 * Adds the delegate to a list used to notify the gameplay code that the stats read has completed
 *
 * @param ReadOnlineStatsCompleteDelegate the delegate to use for notifications
 */
function AddReadOnlineStatsCompleteDelegate(delegate<OnReadOnlineStatsComplete> ReadOnlineStatsCompleteDelegate)
{
	if (ReadOnlineStatsCompleteDelegates.Find(ReadOnlineStatsCompleteDelegate) == INDEX_NONE)
	{
		ReadOnlineStatsCompleteDelegates.AddItem(ReadOnlineStatsCompleteDelegate);
	}
}

/**
 * Removes the delegate from the notify list
 *
 * @param ReadOnlineStatsCompleteDelegate the delegate to use for notifications
 */
function ClearReadOnlineStatsCompleteDelegate(delegate<OnReadOnlineStatsComplete> ReadOnlineStatsCompleteDelegate)
{
	local int RemoveIndex;
	// Find it in the list
	RemoveIndex = ReadOnlineStatsCompleteDelegates.Find(ReadOnlineStatsCompleteDelegate);
	// Only remove if found
	if (RemoveIndex != INDEX_NONE)
	{
		ReadOnlineStatsCompleteDelegates.Remove(RemoveIndex,1);
	}
}

/**
 * Cleans up any platform specific allocated data contained in the stats data
 *
 * @param StatsRead the object to handle per platform clean up on
 */
native function FreeStats(OnlineStatsRead StatsRead);

/**
 * Writes out the stats contained within the stats write object to the online
 * subsystem's cache of stats data. Note the new data replaces the old. It does
 * not write the data to the permanent storage until a FlushOnlineStats() call
 * or a session ends. Stats cannot be written without a session or the write
 * request is ignored. No more than 5 stats views can be written to at a time
 * or the write request is ignored.
 *
 * @param SessionName the name of the session to write stats for
 * @param Player the player to write stats for
 * @param StatsWrite the object containing the information to write
 *
 * @return TRUE if the call is successful, FALSE otherwise
 */
native function bool WriteOnlineStats(name SessionName, UniqueNetId Player, OnlineStatsWrite StatsWrite);

/**
 * Commits any changes in the online stats cache to the permanent storage
 *
 * @param SessionName the name of the session having stats flushed
 *
 * @return TRUE if the call is successful, FALSE otherwise
 */
function bool FlushOnlineStats(name SessionName)
{
}

/**
 * Delegate called when the stats flush operation has completed
 *
 * @param SessionName the name of the session having stats flushed
 * @param bWasSuccessful true if the async action completed without error, false if there was an error
 */
delegate OnFlushOnlineStatsComplete(name SessionName,bool bWasSuccessful);

/**
 * Adds the delegate used to notify the gameplay code that the stats flush has completed
 *
 * @param FlushOnlineStatsCompleteDelegate the delegate to use for notifications
 */
function AddFlushOnlineStatsCompleteDelegate(delegate<OnFlushOnlineStatsComplete> FlushOnlineStatsCompleteDelegate)
{
}

/**
 * Clears the delegate used to notify the gameplay code that the stats flush has completed
 *
 * @param FlushOnlineStatsCompleteDelegate the delegate to use for notifications
 */
function ClearFlushOnlineStatsCompleteDelegate(delegate<OnFlushOnlineStatsComplete> FlushOnlineStatsCompleteDelegate)
{
}

/**
 * Writes the score data for the match
 *
 * @param SessionName the name of the session to write scores for
 * @param LeaderboardId the leaderboard to write the score information to
 * @param PlayerScores the list of players, teams, and scores they earned
 *
 * @return TRUE if the call is successful, FALSE otherwise
 */
function bool WriteOnlinePlayerScores(name SessionName,int LeaderboardId,const out array<OnlinePlayerScore> PlayerScores)
{
}

/**
 * Reads the host's stat guid for synching up stats. Only valid on the host.
 *
 * @return the host's stat guid
 */
function string GetHostStatGuid();

/**
 * Registers the host's stat guid with the client for verification they are part of
 * the stat. Note this is an async task for any backend communication that needs to
 * happen before the registration is deemed complete
 *
 * @param HostStatGuid the host's stat guid
 *
 * @return TRUE if the call is successful, FALSE otherwise
 */
function bool RegisterHostStatGuid(const out string HostStatGuid);

/**
 * Called when the host stat guid registration is complete
 *
 * @param bWasSuccessful whether the registration has completed or not
 */
delegate OnRegisterHostStatGuidComplete(bool bWasSuccessful);

/**
 * Adds the delegate for notifying when the host guid registration is done
 *
 * @param RegisterHostStatGuidCompleteDelegate the delegate to use for notifications
 */
function AddRegisterHostStatGuidCompleteDelegate(delegate<OnRegisterHostStatGuidComplete> RegisterHostStatGuidCompleteDelegate);

/**
 * Clears the delegate used to notify the gameplay code
 *
 * @param RegisterHostStatGuidCompleteDelegate the delegate to use for notifications
 */
function ClearRegisterHostStatGuidCompleteDelegateDelegate(delegate<OnRegisterHostStatGuidComplete> RegisterHostStatGuidCompleteDelegate);

/**
 * Reads the client's stat guid that was generated by registering the host's guid
 * Used for synching up stats. Only valid on the client. Only callable after the
 * host registration has completed
 *
 * @return the client's stat guid
 */
function string GetClientStatGuid();

/**
 * Registers the client's stat guid on the host to validate that the client was in the stat.
 * Used for synching up stats. Only valid on the host.
 *
 * @param PlayerId the client's unique net id
 * @param ClientStatGuid the client's stat guid
 *
 * @return TRUE if the call is successful, FALSE otherwise
 */
function bool RegisterStatGuid(UniqueNetId PlayerId,const out string ClientStatGuid);

/**
 * Calculates the aggregate skill from an array of skills.
 *
 * @param Mus - array that holds the mu values
 * @param Sigmas - array that holds the sigma values
 * @param OutAggregateMu - aggregate Mu
 * @param OutAggregateSigma - aggregate Sigma
 */
function CalcAggregateSkill(array<double> Mus, array<double> Sigmas, out double OutAggregateMu, out double OutAggregateSigma);

/**
 * Delegate used when an event subscription is notified
 *
 * @param PlayerNetId: the player whos stat change caused the event to occur
 * @param StatName: the name of the stat that changed
 * @param NewStatValue: the new value of that stat
 */
delegate OnStatisticChanged(UniqueNetId PlayerNetId, name StatName, string NewStatValue);

/**
 * Subscribe and unsubscribe from RTA events.
 * Unfortunately these need to be tied to a User on the recieving end too since that is how the API is defined.
 *
 * @param LocalUserNum: the user that will be subscribed to listen for stat-event changes
 * @param PlayerNetId: the (probably remote) player whos events we want to listen for
 * @param StatName: the name of the stat that we want to get events for
 * @param EventDelegate: the delegate that will be notified when a stat event occurs
 */
native function SubscribeToStatisticEvent(byte LocalUserNum, UniqueNetId PlayerNetId, name StatName, delegate<OnStatisticChanged> EventDelegate);
native function UnsubscribeToStatisticEvent(byte LocalUserNum, UniqueNetId PlayerNetId, name StatName);

//@HSL_BEGIN_XBOX - JRO - 1/23/2015 - Adding game events to update stats
function bool SendPlayerSessionStart(byte LocalUserNum, string MultiplayerCorrelationId, int GameplayModeId, int DifficultyLevelId);
function bool SendPlayerSessionEnd(byte LocalUserNum, string MultiplayerCorrelationId, int GameplayModeId, int DifficultyLevelId, int ExitStatusId);
function bool SendPlayerSessionPause(byte LocalUserNum, string MultiplayerCorrelationId);
function bool SendPlayerSessionResume(byte LocalUserNum, string MultiplayerCorrelationId, int GameplayModeId, int DifficultyLevelId);
function bool SendTestEvent(byte LocalUserNum, string TestStatInstancing, int TestStatParameter);
//@HSL_END_XBOX


cpptext
{
	/**
	 * Handles updating of any async tasks that need to be performed
	 *
	 * @param DeltaTime the amount of time that has passed since the last tick
	 */
	virtual void Tick(FLOAT DeltaTime);

	/**
	 * Retrieves or creates the LiveContextUserData for a particular player
	 */
	FXboxLiveContextPlayerData* GetLiveContextDataForLocalPlayer(BYTE LocalUserNum);


	void RemoveXboxLiveContextPlayerData(QWORD Xuid);


	/**
	 * Updates each XboxLiveContextPlayerData so that they can handle messages from callbacks received on other threads
	 */
	void TickXboxLiveContextDatas();
}
