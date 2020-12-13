//=============================================================================
// PlayFabInterface
//=============================================================================
// Interface class for all playfab calls
//=============================================================================
// Killing Floor 2
// Copyright (C) 2016 Tripwire Interactive LLC
//  - Author 4/5/2016
//=============================================================================
class PlayfabInterface extends Object
	config(Engine)
	native
	inherits(FTickableObject);

`define FillAddDel(aname)\
	if (`aname.Find(InDelegate) == INDEX_NONE)\
	{\
	`aname[`aname.Length] = InDelegate;\
	}\

`define FillClearDel( aname )\
	local int RemoveIndex;\
	RemoveIndex = `aname.Find(InDelegate);\
	if (RemoveIndex != INDEX_NONE)\
	{\
	`aname.Remove(RemoveIndex,1);\
	}\

/** The current pending game search */
var OnlineGameSearch PendingGameSearch;

/** Game search for get player data */
var OnlineGameSearch TempGameSearch;

/** The playfab ID with successful login */
var const init string CachedPlayfabId;
/** The session ticket with successful login */
var const init string CachedSessionTicket;

/** The cached auth code for when talking to a backend */
var const init string CachedAuthCode;
/** Cached auth code for consuming entitlements. Used for XB1 only */
var const init string CachedAuthForEntitlements;

/** TRUE if login process has finished */
var const private bool bLoginProcessFinished;

/** The time of the last auth refresh to determine if re-auth is needed. Represents appseconds converted to an INT */
var const private INT LastAuthRefreshTime;

/** The time in seconds for when auth should be refreshed */
var const private INT SecondsForAuthRefreshTime;

/** The time to verify the certificate at */
var const private float VerifyCertificateTime;

/** The number of login attempts we've had */
var int LoginAttempts;
var const private int MaxRetryLoginAttempts;


/** The name of the catalog to use */
var const init private{private} config string CatalogName;

struct native RegionDefinition
{
	var float		Ping;
	var bool		RegionUp;
	var init string Name;
	var init string Address;

	structdefaultproperties
	{
		Ping=-1.0
		RegionUp=false
		Name=""
		Address=""
	}
};

var const config array<RegionDefinition> KnownRegions;

/** The list of available region names */
// var const config array<string> RegionNames;

/** The list of favourite servers */
var array<string> FavouriteServers;

/** Server history */
var array<string> ServerHistory;

/** The current region index for the player */
var init string CurrRegionName;

/** Service label used to consume PSN entitlements */
var const int PlayfabNPServiceLabel;

/** The title data */
var native Map_Mirror TitleData{TMap<FString, FString>};

// SERVER ONLY
/////////////////////////////////////////////////////////////////

/** TRUE if this server was launched by playfab */
var const private{private} bool bLaunchedByPlayfab;

/** TRUE if this is a cloud server */
var const private{private} bool bCloudServer;

/** The lobby ID of the server */
var const init private{private} string CachedLobbyId;

/** Server ID used for registration with multiplay */
var const init private{private} string CachedServerId;

/** The elapsed time since the last heartbeat for the server */
var const private{private} float ElapsedTimeSinceLastHeartBeat;

/** The interval needed for sending heartbeats to playfab */
var const private{private} float HeartbeatInterval;

/** The cached game settings */
var private{private} OnlineGameSettings CachedGameSettings;

/** Countdown timer for attempting a re-register of the server */
var const private{private} float CountdownToReregister;

/** The interval for server re-register attempts. Only ever set if heartbeat or original registration fails */
var const private{private} float ReregisterInterval;

/** Endpoint APIs specified by multiplay via commandline */
var const init private{private} string AllocateAPIEndpoint;
var const init private{private} string DeallocateAPIEndpoint;

/** TRUE if server is actively allocated with backend */
var private{private} bool bServerAllocated;
/** TRUE if server is de-allocated. Can ONLY be true if bServerAllocated has ever been true */
var private{private} bool bServerDeallocated;
/** The timestamp at which the server was deallocated */
var const private{private} qword DeallocatedTimeStamp;
/** Elapsed time since last update for deallocated server */
var const private{private} float TimeSinceLastDeallocationUpdate;
/** The interval between updates for deallocated servers */
var const private{private} float DeallocateTimeUpdateInterval;

// SERVER END
/////////////////////////////////////////////////////////////////

/** Array of delegates to multicast */
var array<delegate<OnFindOnlineGamesComplete> > FindOnlineGamesCompleteDelegates;
var array<delegate<OnQueryServerInfoComplete> > OnQueryServerInfoCompleteDelegates;
var array<delegate<OnLoginComplete> > LoginCompleteDelegates;
var array<delegate<OnRegionQueryComplete> > RegionQueryCompleteDelegates;
var array<delegate<OnServerStarted> > ServerStartedDelegates;
var array<delegate<OnInventoryRead> > InventoryReadDelegates;
var array<delegate<OnTitleDataRead> > TitleDataReadDelegates;
var array<delegate<OnStoreDataRead> > StoreDataReadDelegates;
var array<delegate<OnCloudScriptExecutionComplete> > CloudScriptExecutionCompleteDelegates;
var array<delegate<OnGetPlayerListComplete> > GetPlayerListCompleteDelegates;

// Client API calls
/////////////////////////////////////////////////////////////////////////

// Login to playfab service. Will create account if login fails
native function bool Login( string UserName );
delegate OnLoginComplete(bool bWasSuccessful, string SessionTicket, string PlayfabId);
function AddOnLoginCompleteDelegate( delegate<OnLoginComplete> InDelegate) { `FillAddDel(LoginCompleteDelegates); }
function ClearOnLoginCompleteDelegate( delegate<OnLoginComplete> InDelegate) { `FillClearDel(LoginCompleteDelegates); }

delegate OnGetPlayerListComplete(OnlineGameSettings PlayerListSettings, bool Success);
function AddGetPlayerListCompleteDelegate(delegate<OnGetPlayerListComplete> InDelegate) { `FillAddDel(GetPlayerListCompleteDelegates); }
function ClearGetPlayerListCompleteDelegate(delegate<OnGetPlayerListComplete> InDelegate) { `FillClearDel(GetPlayerListCompleteDelegates); }

/**
 * For determining if a server that we got in our search results is in our favorite list
 *
 * @return true if the search result at the specified index is a favorite, false if not
 */
native function bool IsSearchResultInFavoritesList(OnlineGameSearch LatestGameSearch, int Index);

native function bool AddSearchResultToFavorites(OnlineGameSearch LatestGameSearch, int Index);
native function bool RemoveSearchResultFromFavorites(OnlineGameSearch LatestGameSearch, int Index);

native function bool AddSearchResultToHistory(string JoinString);

function native int GetRegionIndex(const out string RegionName);
function native SetDefaultRegion(const out string RegionName);

native function UpdateUserTitleDisplayName( string DisplayName );
native function UpdateUserName( string DisplayName );
native function UpdateUserData( string Key, string Data, string Permission );

native function GetUserName( string PlayfabId, int SelectedServerIndex, int PlayerIndex );
native function GetPlayerList( OnlineGameSearch SearchSettings, INT SelectedServerIndex );
native function CheckPlayerDisplayName( string PlayfabId );
native function GetUserData( array<string> Keys, bool CheckData );
native function QueryPlayfabClientTicket( string LobbyId );

// Logout of playfab services when we get disconnected
native function bool Logout();

// Read store data
native function ReadStoreData();
delegate OnStoreDataRead(bool bWasSuccessful);
function AddStoreDataReadCompleteDelegate( delegate<OnStoreDataRead> InDelegate) { `FillAddDel(StoreDataReadDelegates); }
function ClearStoreDataReadCompleteDelegate( delegate<OnStoreDataRead> InDelegate) { `FillClearDel(StoreDataReadDelegates); }

// Read inventory for local user
native function ReadInventory();
delegate OnInventoryRead(bool bWasSuccessful);
function AddInventoryReadCompleteDelegate( delegate<OnInventoryRead> InDelegate) { `FillAddDel(InventoryReadDelegates); }
function ClearInventoryReadCompleteDelegate( delegate<OnInventoryRead> InDelegate) { `FillClearDel(InventoryReadDelegates); }

// Read title data
native function ReadTitleData();
delegate OnTitleDataRead();
function AddTitleDataReadCompleteDelegate( delegate<OnTitleDataRead> InDelegate ) { `FillAddDel(TitleDataReadDelegates); }
function ClearTitleDataReadCompleteDelegate( delegate<OnTitleDataRead> InDelegate ) { `FillClearDel(TitleDataReadDelegates); }
// Retrieves title data value for a particular key
native function string GetTitleDataForKey( string InKey );

// Unlocks a container for the user
native function UnlockContainer(string ContainerId);

// WireService exchange interface
native function PerformRuleExchange( ExchangeRuleSets ForRuleset, bool AllButOne =false );

// Consumes entitlements
native function ConsumeEntitlements(optional bool bWasPurchase = false);

// Find online games. Results will show up in the search settings supplied if successful
native function bool FindOnlineGames( OnlineGameSearch SearchSettings );
delegate OnFindOnlineGamesComplete(bool bWasSuccessful);
function AddFindOnlineGamesCompleteDelegate(delegate<OnFindOnlineGamesComplete> InDelegate) { `FillAddDel(FindOnlineGamesCompleteDelegates); }
function ClearFindOnlineGamesCompleteDelegate(delegate<OnFindOnlineGamesComplete> InDelegate) { `FillClearDel(FindOnlineGamesCompleteDelegates); }
// Cancel the current game search
native function CancelGameSearch();

// Query info for a particular server
native function QueryServerInfo( const string LobbyId );
delegate OnQueryServerInfoComplete(bool bWasSuccessful, string LobbyId, string ServerIp, int ServerPort, string AuthTicket);
function AddQueryServerInfoCompleteDelegate( delegate<OnQueryServerInfoComplete> InDelegate) { `FillAddDel(OnQueryServerInfoCompleteDelegates); }
function ClearQueryServerInfoCompleteDelegate( delegate<OnQueryServerInfoComplete> InDelegate) { `FillClearDel(OnQueryServerInfoCompleteDelegates); }

// Query available regions
delegate OnRegionQueryComplete( bool bWasSuccessful, array<string> OutRegionNames );
native function QueryAvailableRegions();
function AddRegionQueryCompleteDelegate( delegate<OnRegionQueryComplete> InDelegate) { `FillAddDel(RegionQueryCompleteDelegates); }
function ClearRegionQueryCompleteDelegate( delegate<OnRegionQueryComplete> InDelegate) { `FillClearDel(RegionQueryCompleteDelegates); }

// Starts a new server instance
native function StartNewServerInstance( optional string ServerCommandline );
delegate OnServerStarted( bool bWasSuccessful, string ServerLobbyId, string ServerIp, int ServerPort, string ServerTicket );
function AddOnServerStartedDelegate( delegate<OnServerStarted> InDelegate) { `FillAddDel(ServerStartedDelegates); }
function ClearOnServerStartedDelegate( delegate<OnServerStarted> InDelegate) { `FillClearDel(ServerStartedDelegates); }

// Executes a cloud script function
native function ExecuteCloudScript( string FunctionName, JsonObject FunctionParms );
delegate OnCloudScriptExecutionComplete( bool bWasSuccessful, string FunctionName, JsonObject FunctionResult );
function AddOnCloudScriptExecutionCompleteDelegate( delegate<OnCloudScriptExecutionComplete> InDelegate ) { `FillAddDel(CloudScriptExecutionCompleteDelegates); }
function ClearOnCloudScriptExecutionCompleteDelegate( delegate<OnCloudScriptExecutionComplete> InDelegate ) { `FillClearDel(CloudScriptExecutionCompleteDelegates); }


function bool IsRegisteredWithPlayfab()
{
	return CachedLobbyId != "";
}


function string GetCachedLobbyId()
{
	return CachedLobbyId;
}


event bool IsCloudServer()
{
	return bCloudServer;
}


event string GetServerId()
{
	return CachedServerId;
}


function int GetIndexForCurrentRegion()
{
	local int i;

	for( i = 0; i < KnownRegions.Length; i++ )
	{
		if( KnownRegions[i].Name == CurrRegionName )
		{
			return i;
		}
	}

	`warn("Failed to find index for current region"@CurrRegionName);
	return -1;
}


function SetIndexForCurrentRegion( int InRegionIndex )
{
	if( InRegionIndex >= 0 && InRegionIndex < KnownRegions.Length )
	{
		SetDefaultRegion(KnownRegions[InRegionIndex].Name);
	}
	else
	{
		`warn("Failed to set region index"@InRegionIndex);
	}
}


static function array<string> GetLocalizedRegionList()
{
	local int i;
	local array<string> LocalizedRegions;

	for( i = 0; i < default.KnownRegions.Length; i++ )
	{
		LocalizedRegions.AddItem( Localize( "Regions", default.KnownRegions[i].Name, "KFGameConsole" ) );
	}

	return LocalizedRegions;
}

static function string GetLocalizedRegionName(int RegionIndex)
{
	return Localize( "Regions", default.KnownRegions[RegionIndex].Name, "KFGameConsole" );
}


event OnlineProfileSettings GetProfileSettings( byte LocalUserNum )
{
	return class'GameEngine'.static.GetOnlineSubsystem().PlayerInterface.GetProfileSettings( LocalUserNum );
}



// Server API calls
/////////////////////////////////////////////////////////////////////////
native function ServerValidatePlayer( const string ClientAuthTicket );
native function ServerNotifyPlayerJoined( const string PlayfabId );
native function ServerNotifyPlayerLeft( const string PlayfabId );
native function ServerUpdateOnlineGame();
native function ServerRegisterGame();
native function ServerSetOpenStatus( const bool bOpen );
native function ServerSetSteamServerUID(const qword UID);

native function ServerUpdateInternalUserData( const string ForPlayerId, array<string> InKeys, array<string> InValues );
native function ServerRetrieveInternalUserData( const string ForPlayerId, array<string> InKeys );
native function ServerAddVirtualCurrencyForUser( const string ForPlayerId, const int AmountToAdd, optional string CurrencyName = "GM" );
native function ServerRemoveVirtualCurrencyForUser( const string ForPlayerId, const int AmountToRemove, optional string CurrencyName = "GM" );
native function ServerGrantItemsForUser( const string ForPlayerId, array<string> ItemIds );

native function ServerAllocate();
native function ServerDeallocate( optional bool bForce );

function CreateGameSettings( class<OnlineGameSettings> GameSettingsClass )
{
	if( CachedGameSettings == none )
	{
		CachedGameSettings = new GameSettingsClass;
	}
}

event OnlineGameSettings GetGameSettings()
{
	return CachedGameSettings;
}


// Private calls
/////////////////////////////////////////////////////////////////////////////

// Auths with online service (ex. PSN). Calls into OSS to do this
private event AuthWithOnlineService( byte LocalUserNum, string ForURL )
{
	local OnlineSubsystem OSS;

	OSS = class'GameEngine'.static.GetOnlineSubsystem();
	if( OSS != none && OSS.PlayerInterface != none )
	{
		OSS.PlayerInterface.AddURLTokenRetrievedDelegate( LocalUserNum, OnTokenAndSignatureRetrieved );
		OSS.PlayerInterface.GetTokenAndSignatureForURL( LocalUserNum, ForURL );
	}
}

private function OnTokenAndSignatureRetrieved(byte LocalUserNum, string URL, string Token, string Signature)
{
	class'GameEngine'.static.GetOnlineSubsystem().PlayerInterface.ClearURLTokenRetrievedDelegate(LocalUserNum, OnTokenAndSignatureRetrieved);
	OnlineServiceAuthComplete( URL, Token, Signature );
}


// The rest is handled in native
private native function OnlineServiceAuthComplete( string ForURL, string Token, string Signature );


cpptext
{
	virtual void Initialize();

	virtual UBOOL IsTickable() const
	{
		// We cannot tick objects that are unreachable or are in the process of being loaded in the background.
		return !HasAnyFlags( RF_Unreachable | RF_AsyncLoading );
	}

	virtual UBOOL IsTickableWhenPaused() const
	{
		return TRUE;
	}

	virtual void Tick( FLOAT DeltaSeconds );

	virtual void Shutdown();

	UBOOL WasLaunchedByPlayfab() { return bLaunchedByPlayfab; }

	virtual FString GetLobbyId() { return CachedLobbyId; }
	virtual void SetLobbyId( const FString& InLobbyId ) { CachedLobbyId = InLobbyId; }

	// Notification from OSS after entitlements have been read
	virtual void OnEntitlementsRead();

	// Called on the event inventory is updated
	virtual void InventoryUpdated( TArray<FCurrentInventoryEntry>& NewInvList );

	// Adds durable entitlements to inventory list
	virtual void AddDurableEntitlementsToInventory( TArray<FCurrentInventoryEntry>& InvList );

	// Sets a timer to attempt registration again
	virtual void Reregister();

	// Retrieves the catalog name
	virtual FString GetCatalogName() { return CatalogName; }
}


defaultproperties
{
	CurrRegionName=""
	// Auth refreshed every hour
	SecondsForAuthRefreshTime=3600
	// 60 seconds for every heartbeat
	HeartbeatInterval=60.0
	DeallocateTimeUpdateInterval=30.0
	PlayfabNPServiceLabel=1
	ReregisterInterval=10.0
	MaxRetryLoginAttempts=3
	VerifyCertificateTime=600.0
}