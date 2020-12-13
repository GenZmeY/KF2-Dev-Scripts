class TWOnlineLobby extends Object within OnlineSubsystem
	native
	abstract
	config(Engine);

/**
 * A basic key/value pair for holding various lobby settings
 */
struct native LobbyMetaData
{
	var string	Key;	// The key identifying the setting
	var string	Value;	// The value of the setting
};

/**
 * Struct describing basic information about a lobby, typically from a lobby search result
 */
struct native BasicLobbyInfo
{
	var const UniqueNetId		LobbyUID;	// The unique id of the lobby
	var const array<LobbyMetaData>	LobbySettings;	// The list of settings read for this lobby
};

/**
 * Describes information about a member of a lobby we are active in
 */
struct native LobbyMember
{
	var const UniqueNetId		PlayerUID;	// The unique id of the player
	var const array<LobbyMetaData>	PlayerSettings;	// The list of settings read for this player

	// @todo Steam: Decide whether or not to put extra fields here, e.g. avatar/community-name etc. (may be best to leave that up
	//	to the actual ingame implementation of lobbies)
};

/**
 * Describes all available information about a lobby we are active in
 */
struct native ActiveLobbyInfo extends BasicLobbyInfo
{
	var const array<LobbyMember>	Members;	// The list of members of a lobby we are in
};

/**
 * Used for specifying filters based on key/value pairs, when searching for lobbies
 * NOTE: Max size of a key is 255
 */
struct native LobbyFilter
{
	var string				Key;		// The key to be filtered
	var string				Value;		// The value to filter against
	var EOnlineGameSearchComparisonType	Operator;	// The operator to use for comparison

	var bool				bNumeric;	// whether or not this filter is numeric (treated as string otherwise)
};

/**
 * The visibility/connectivity type of a lobby
 */
enum ELobbyVisibility
{
	LV_Public,		// Lobby is visible to everyone
	LV_Friends,		// Visible to friends and invited players only
	LV_Private,		// Can only join by invite
	LV_Invisible		// @todo Steam: Figure out what this does exactly
};

function bool LobbyJoinGame(optional string ServerIP);

function bool LobbyJoinServer(string ServerIP);

function SetServerPassword(string password);

function string GetLobbyURLString();

function bool IsInLobby();

function bool IsLobbyOwner();

function bool QuitLobby();

function bool GetLobbyAdmin(UniqueNetId LobbyId, out UniqueNetId AdminId);

//@HSL_BEGIN - JRO - 7/16/2016 - Make sure we can get the party member ID instead of the account ID on PS4
function UniqueNetId GetMyId();
//@HSL_END

function string GetFriendNickname(UniqueNetId FriendId, optional bool IncludeSelf = true);

function SetLobbyData( string Key, string Value );

function string GetLobbyData( int LobbyIndex, string Key );

function bool SetVisibility( int VisibilityIndex );

function ShowLobbyInviteInterface(string InviteMessage);

//@HSL_BEGIN - JRO - 8/15/2016 - Play Together needs a way to programmatically invite people to the party
function bool SendInviteToUsers(array<string> MembersToInvite, string InviteMessage);
//@HSL_END

function bool LobbyMessage(string Message);

function bool GetCurrentLobby(out ActiveLobbyInfo LobbyInfo);

//@HSL_BEGIN - JRO - 8/17/2016 - Number of party members
function int GetCurrentPartySize();
//@HSL_END

function bool MakeLobby(int MaxPlayers, ELobbyVisibility Type);

function UniqueNetId GetCurrentLobbyId();

function bool GetLobbyFromCommandline(out UniqueNetId LobbyId, optional bool bMarkAsJoined=True);

function LobbyInvite(UniqueNetId LobbyId, UniqueNetId FriendId, bool bAccepted);
