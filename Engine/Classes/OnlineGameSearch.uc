/**
 * Copyright 1998-2013 Epic Games, Inc. All Rights Reserved.
 */

/**
 * Holds the base settings for an online game search
 */
class OnlineGameSearch extends Settings
	dependson(OnlineSubsystem)
	native;

/** Max number of queries returned by the matchmaking service */
var int MaxSearchResults;

/** The query to use for finding matching servers */
var LocalizedStringSetting Query;

/** Whether the query is intended for LAN matches or not */
var databinding bool bIsLanQuery;

/** Whether to use arbitration or not */
var databinding bool bUsesArbitration;

/** Whether the search object in question is in progress or not. This is the union of the other flags */
var const bool bIsSearchInProgress;

/** Struct used to return matching servers */
struct native OnlineGameSearchResult
{
	/** The settings used by this particular server */
//@HSL_BEGIN - BWJ - 12-12-16-  Need to be able to change this in script (script const is kinda stupid anyways. doesn't hold true in native)
	var /*const*/ OnlineGameSettings GameSettings;
//@HSL_END
	/**
	 * Platform/online provider specific data
	 * NOTE: It is imperative that the subsystem be called to clean this data
	 * up or the PlatformData will leak memory!
	 */
	var const native pointer PlatformData{void};

	structcpptext
	{
		/** Default constructor does nothing and is here for NoInit types */
		FOnlineGameSearchResult()
		{
		}

		/** Zeroing constructor */
		FOnlineGameSearchResult(EEventParm) :
			GameSettings(NULL),
			PlatformData(NULL)
		{
		}
	}
};

/** The class to create for each returned result from the search */
var class<OnlineGameSettings> GameSettingsClass;

/** The list of servers and their settings that match the search */
var const array<OnlineGameSearchResult> Results;

/** Used to manually specify the skill to use when matchmaking */
struct native OverrideSkill
{
	/** The skill leaderboard to read the player skill from */
	var int LeaderboardId;
	/** The set of players to read the skill for */
	var array<UniqueNetId> Players;
	/** The set of skill values to use */
	var array<double> Mus;
	var array<double> Sigmas;
};

/** Instance of the above to manually specify the players involved in the skill search */
var OverrideSkill ManualSkillOverride;

/**
 * Used to search for named properties on game setting objects
 */
struct native NamedObjectProperty
{
	/** The name of the property to search with */
	var name ObjectPropertyName;
	/** The string value to compare against */
	var string ObjectPropertyValue;
};

/** The list of named properties to search on */
var array<NamedObjectProperty> NamedProperties;

/** The type of data to use to fill out an online parameter */
enum EOnlineGameSearchEntryType
{
	/** A property is used to filter with */
	OGSET_Property,
	/** A localized setting is used to filter with */
	OGSET_LocalizedSetting,
	/** A property on the game settings object to filter with */
	OGSET_ObjectProperty
};

/** The type of comparison to perform on the search entry */
enum EOnlineGameSearchComparisonType
{
	OGSCT_Equals,
	OGSCT_NotEquals,
	OGSCT_GreaterThan,
	OGSCT_GreaterThanEquals,
	OGSCT_LessThan,
	OGSCT_LessThanEquals
};

/** Struct used to describe a search criteria */
struct native OnlineGameSearchParameter
{
	/** The Id of the property or localized string */
	var int EntryId;
	/** The name of the property to search with */
	var name ObjectPropertyName;
	/** Whether this parameter to compare against comes from a property or a localized setting */
	var EOnlineGameSearchEntryType EntryType;
	/** The type of comparison to perform */
	var EOnlineGameSearchComparisonType ComparisonType;
};

/** Used to indicate which way to sort a result set */
enum EOnlineGameSearchSortType
{
	OGSSO_Ascending,
	OGSSO_Descending
};

/** Struct used to describe the sorting of items */
struct native OnlineGameSearchSortClause
{
	/** The Id of the property or localized string */
	var int EntryId;
	/** The name of the property to search with */
	var name ObjectPropertyName;
	/** Whether this parameter to compare against comes from a property or a localized setting */
	var EOnlineGameSearchEntryType EntryType;
	/** The type of comparison to perform */
	var EOnlineGameSearchSortType SortType;
};

/** Matches parameters using a series of OR comparisons */
struct native OnlineGameSearchORClause
{
	/** The list of parameters to compare and use as an OR clause */
	var array<OnlineGameSearchParameter> OrParams;
};

/** Struct used to describe a query */
struct native OnlineGameSearchQuery
{
	/** A set of OR clauses that are ANDed together to filter potential servers */
	var array<OnlineGameSearchORClause> OrClauses;
	/** A list of sort operations used to order the servers that match the filtering */
	var array<OnlineGameSearchSortClause> SortClauses;
};

/** Holds the query to use when filtering servers and they require non-predefined queries */
var OnlineGameSearchQuery FilterQuery;

`if (`__TW_ONLINESUBSYSTEM_)
	var array<string> MasterServerSearchKeys;
	var array<string> MasterServerSearchValues;
`endif

/** String that is tacked onto the end of the search query (GameSpy only) */
var string AdditionalSearchCriteria;

/**
 * Used to sort games into buckets since a the difference in terms of feel for ping
 * in the same bucket is often not a useful comparison and skill is better
 */
var int PingBucketSize;

/** The number of probes used to determine ping */
var int NumPingProbes;

/** The max amount of data to use when pinging */
var int MaxPingBytes;

//@SABER_BEGIN - The max ping of the crossplay server
var int MaxPing;
//@SABER_END

/**
 * Sets the information needed to do a manual specification of the skill to use when searching
 *
 * @param LeaderboardId the skill leaderboard to read from
 * @param Players the set of players to use when determining the skill
 */
function SetSkillOverride(int LeaderboardId,const out array<UniqueNetId> Players)
{
	// Copy and zero the skill data
	ManualSkillOverride.LeaderboardId = LeaderboardId;
	ManualSkillOverride.Players = Players;
	ManualSkillOverride.Mus.Length = 0;
	ManualSkillOverride.Sigmas.Length = 0;
}

/**
 * Allows a search object to provide a customized sort routine to order the results in
 * a way that best fits the game type
 */
native event SortSearchResults();

//@ZOMBIE_PS4_BEING - AGM - Adding support for settings values to be pasted to OSS
event native bool SetNamedProperty(name PropertyName, String value);
event native bool GetNamedProperty(name PropertyName, out String value);
//@ZOMBIE_PS4_END


//@HSL_BEGIN - BWJ - 7-5-16 - Removing this functionality from steam
function ClearServerFilters()
{
	MasterServerSearchKeys.Length = 0;
	MasterServerSearchValues.Length = 0;
}


function AddServerFilter(string Key, optional string Val = "", optional int location = -1)
{
	//`log("AddServerFilter:"@Key@Val@string(location));
	if (location < 0)
	{
		//`log("Adding filter"@Key$"="$Val);
		MasterServerSearchKeys.AddItem(Key);
		MasterServerSearchValues.AddItem(Val);
	}
	else
	{
		//`log("Adding filter"@Key$"="$Val@"at position"@location);
		MasterServerSearchKeys.InsertItem(location, Key);
		MasterServerSearchValues.InsertItem(location, Val);
	}
}


function TestAddServerFilter(bool Test, string Key, optional string Val = "")
{
	if (Test)
	{
		AddServerFilter(Key, Val);
	}
}


function TestAddBoolGametagFilter(out string GametagString, bool Test, name Property, byte BoolVal)
{
	//`log("TestAddBoolGametagFilter:"@string(Test)@string(Property)@string(BoolVal));
	if (Test)
	{
		if (Len(GametagString) > 0)
		{
			GametagString $= ",";
		}
		GametagString $= GetGametagStringBool(Property, BoolVal);
	}
	//`log("TestAddBoolGametagFilter:"@GametagString);
}


function AddGametagFilter(out string GametagString, name Property, string Val)
{
	//`log("AddGametagFilter:"@string(Property)@Val);
	if (Len(GametagString) > 0)
	{
		GametagString $= ",";
	}
	GametagString $= GetGametagString(Property, Val);
	//`log("AddGametagFilter:"@GametagString);
}

native function string GetGametagString(name PropertyName, string StringVal);
native function string GetGametagStringBool(name PropertyName, byte BoolVal);


cpptext
{
	/** encodes a name into a char for game tags */
	static char EncodeNameForGameTag(FName Name);
	static FString ParseGameTagEntry(char *GameTagEntry);
}
//@HSL_END


defaultproperties
{
	// Override this with your game specific class so that metadata can properly
	// expose the game information to the UI
	GameSettingsClass=class'Engine.OnlineGameSettings'
	MaxSearchResults=25
	// Set this to zero to disable ping bucket sorting for arbitrated matches
	PingBucketSize=50
	MaxPing = -1;
}
