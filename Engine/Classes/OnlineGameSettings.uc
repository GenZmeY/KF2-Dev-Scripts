/**
 * Copyright 1998-2013 Epic Games, Inc. All Rights Reserved.
 */

/**
 * Holds the base configuration settings for an online game
 */
class OnlineGameSettings extends Settings
	dependson(OnlineSubsystem)
	native;

/** The number of publicly available connections advertised */
var databinding int NumPublicConnections;

/** The number of connections that are private (invite/password) only */
var databinding int NumPrivateConnections;

/** The number of publicly available connections that are available (read only) */
var databinding int NumOpenPublicConnections;

/** The number of private connections that are available (read only) */
var databinding int NumOpenPrivateConnections;

/** The server's nonce for this session */
var const qword ServerNonce;

//@HSL_BEGIN - JRO - 3/21/2016 - PS4 Sessions
/** UE3 Join string for PS4 invites */
var databinding string JoinString;
//@HSL_END

//@HSL_BEGIN_XBOX
/** ID unique to our game */
var string ServiceConfigId;
/** Template that describes how the session is made and behaves */
var string SessionTemplateName;
/** */
var string MatchHopperName;
/** The session guid */
var string SessionGuid;
/** The handle of the session used strictly for invite purposes */
var string SessionHandle;
/** The list of members to add a reservation for */
var array<UniqueNetId> ReservedMembers;
//@HSL_END_XBOX

/** Whether this match is publicly advertised on the online service */
var databinding bool bShouldAdvertise;

/** This game will be lan only and not be visible to external players */
var databinding bool bIsLanMatch;

/** Whether the match should gather stats or not */
var databinding bool bUsesStats;

/** Whether joining in progress is allowed or not */
var databinding bool bAllowJoinInProgress;

/** Whether the match allows invitations for this session or not */
var databinding bool bAllowInvites;

/** Whether to display user presence information or not */
var databinding bool bUsesPresence;

/** Whether joining via player presence is allowed or not */
var databinding bool bAllowJoinViaPresence;

/** Whether joining via player presence is allowed for friends only or not */
var databinding bool bAllowJoinViaPresenceFriendsOnly;

/** Whether the session should use arbitration or not */
var databinding bool bUsesArbitration;

/** Whether the server employs anti-cheat (punkbuster, vac, etc) */
var databinding bool bAntiCheatProtected;

/** Whether the game is an invitation or searched for game */
var const bool bWasFromInvite;

/** The owner of the game */
var databinding string OwningPlayerName;

/** The unique net id of the player that owns this game */
var UniqueNetId OwningPlayerId;

/** The ping of the server in milliseconds (-1 means the server was unreachable) */
var databinding int PingInMs;

/** Whether this server is a dedicated server or not */
var databinding bool bIsDedicated;

/** Represents how good a match this is in a range from 0 to 1 */
var databinding float MatchQuality;

/** The current state of the online game */
var const databinding EOnlineGameState GameState;

/** Whether there is a skill update in progress or not (don't do multiple at once) */
var const bool bHasSkillUpdateInProgress;

/** Used to keep different builds from seeing each other during searches */
var const int BuildUniqueId;

/** Whether to shrink the session slots when a player leaves the match or not */
var const bool bShouldShrinkArbitratedSessions;

//@HSL_BEGIN - BWJ - 4-11-16 - Playfab support
var string LobbyId;
//@HSL_END

//@SABER_EGS_BEGIN Crossplay support
var databinding int BotPlayers;

// Steam Server UID
var databinding string SteamServerUID;
//@SABER_EGS_END

//@SABER_BEGIN "Exiling" servers which kicks/bans
var databinding bool bServerExiled;
//@SABER_END

`if (`__TW_ONLINESUBSYSTEM_)

//used to keep track of the gfx objects in the serverbrowser's list
var int GfxID;
var int ElementIdx;

var databinding bool bRequiresPassword;

//@HSL_BEGIN - BWJ - 9-14-16 - TRUE if this is a cloud server that needs to be deallocated at some point. Used for multiplay support
var databinding bool bCloudServer;
// Number of seconds this server has been de-allocated for
var databinding int SecondsDeallocated;
// The bucket this server belongs to as far as seconds the server has been deallocated
var databinding int SecondsDeallocatedBucket;
// The bucket size for grouping seconds deallocated
var const int SecondsDeallocatedBucketSize;
// Region for the server
var databinding string Region;
//@HSL_END

var databinding bool bNoSeasonalSkins;

/** Represents a player in the game */
struct native PlayerResult
{
	var string PlayerName;
	var int Score;
	var float TimePlayed;
	var string PlayFabId;
	var bool NameIsSet;

	structdefaultproperties
	{
		PlayerName=""
		Score=0
		TimePlayed=0
		PlayFabId=""
		NameIsSet=false
	}
};

/** List of players in this game */
var array<PlayerResult> PlayersInGame;

`endif //__TW_ONLINESUBSYSTEM_

defaultproperties
{
`if(`__TW_ONLINESUBSYSTEM_)
	GfxID=INDEX_NONE
	ElementIdx=INDEX_NONE
`endif
	bAllowJoinInProgress=true
	bUsesStats=true
	bShouldAdvertise=true
	bAllowInvites=true
	bUsesPresence=true
	bAllowJoinViaPresence=true
	bShouldShrinkArbitratedSessions=true
	SecondsDeallocatedBucketSize=60
	//@SABER_EGS_BEGIN Crossplay support
	BotPlayers=0
	//@SABER_EGS_END
	//@SABER_BEGIN "Exiling" servers which kicks/bans
	bServerExiled=false
	//@SABER_END
	bNoSeasonalSkins=false
}
