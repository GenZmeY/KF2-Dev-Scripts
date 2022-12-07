//=============================================================================
// KFGFxServerBrowser_ServerList
//=============================================================================
// Class Description
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//  - Zane 8/19/2014
//=============================================================================

class KFGFxServerBrowser_ServerList extends KFGFxObject_Container
	native(UI)
	config(UI);

/** Reference to the search datastore. */
var transient KFDataStore_OnlineGameSearch	SearchDataStore;

/** stores the password entered by the user when attempting to connect to a server with a password */
var private transient string		ServerPassword;

/** True if we want to join as a spectator */
var private transient bool bJoinAsSpectator;

var	protected	transient	const	name	SearchDSName;

/** Cached online subsystem pointer */
var transient OnlineSubsystem				OnlineSub;

/** Cached game interface pointer */
var transient OnlineGameInterface			GameInterface;

//A cache for the server list gfx object so we do not have to create them everytime we refresh or update the list
var array<GFxObject> GFxServerObjects;

/** Is an informative dialog about the server browser currently displayed. */
var private transient bool                  bQueryDialogShowing;

var private transient bool                  bIssuedInitialQuery;

var private GFxObject 						DataProvider;

var public int 								FakePlayerIndex;

var public int 								SelectedServerIndex;

var localized string 						LeaveServerBrowserString;

var localized string 						DetailsString;

var localized string 						SpectateString;

var KFGFxMenu_ServerBrowser ServerMenu;

var transient int FilteredCount;

/** Maximum number of server entries in the browser */
var globalconfig int MaxSearchResults;

var int lastServerCount;

/**
 * Different actions to take when a query completes.
 */
var private transient enum EQueryCompletionAction
{
	/** no query action set */
	QUERYACTION_None,

	/** do nothing when the query completes; default behavior */
	QUERYACTION_Default,

	/**
	 * This is set when the user wants to close the scene but we still have active queries.  When the queries are completed
	 * (either through being canceled or receiving all results), close the scene.
	 */
	QUERYACTION_CloseScene,

	/**
	 * This is set when the user has chosen a server from the list.  When the queries are completed or cancelled, join the currently selected server.
	 */
	QUERYACTION_JoinServer,

	/**
	 * This is set when the user switches from LAN to Internet or vice versa.  When the queries are completed of cancelled, clear all results and reissue the
	 * current query.
	 */
	QUERYACTION_RefreshAll,

} QueryCompletionAction;

var private transient enum ESearch_Tab
{
	TAB_ALL,
	TAB_FAVORITES,
	TAB_FRIENDS,
	TAB_HISTORY,
	TAB_LAN,
	TAB_MAX,
} ECurrentSearchTab;

struct native ExtraServerInfo
{
	var bool ServerHeardBackFrom;
	var bool GameRunning;
	var bool RequestDispatched;
	
	var int StartTimer; // if game has not started, how many seconds until it does

	var float Ping; // direct ping to the server from x-tra fetch
	var int Survivors; // current player count
	var int SurvivorsAvgLevel;
	var int ZedPlayers; // current zed-players for vs servers
};

//equivalent to OnViewLoaded from UDK/Unreal Tournement 3
function Initialize( KFGFxObject_Menu NewParentMenu )
{
	local DataStoreClient DSClient;

	super.Initialize( NewParentMenu );
	ServerMenu =KFGFxMenu_ServerBrowser(NewParentMenu);
	LocalizeText();

	DSClient = class'UIInteraction'.static.GetDataStoreClient();
	if ( DSClient != None )
	{
		SearchDataStore = KFDataStore_OnlineGameSearch(DSClient.FindDataStore(SearchDSName));
	}

	OnlineSub = class'GameEngine'.static.GetOnlineSubsystem();
		GameInterface = OnlineSub.GameInterface;

	//OnViewActivated();
}

function OnViewActivated()
{
	//ScriptTrace();
	//local UIDataStore_Registry Registry;
	
	//Registry = UIDataStore_Registry(class'UIRoot'.static.StaticResolveDataStore('Registry'));

	// Default to LAN.
	//Registry.SetData("LanClient", "1");

	// Decide whether we're playing LAN or Online and set MatchType appropriately.
	ValidateServerType();     

	// Push an initial query when the page is first activated.
	if ( !bIssuedInitialQuery )
	{
		bIssuedInitialQuery = TRUE;
		RefreshServerList(FakePlayerIndex);
	}   
	
	// Update the list's data provider.
	UpdateListDataProvider(); 
}

function  SortServerResultsRequest(int ButtonIndex, int SortOrder)
{
	local KFOnlineGameSearch LatestGameSearch;

	LatestGameSearch = KFOnlineGameSearch(SearchDataStore.GetActiveGameSearch());
	if(LatestGameSearch == none)
	{
		return;
	}
	LatestGameSearch.SortResults(ESortType(ButtonIndex), ESortOrder(SortOrder));
	UpdateListDataProvider();
}

/**
 * Enables / disables the "match type" control based on whether we are signed in online.
 */
function ValidateServerType()
{
	local int PlayerIndex, PlayerControllerID;
	local LocalPlayer LP;
	
	// Don't worry about remote players
	LP = LocalPlayer(GetPC().Player);
	
	// don't have a link connection, or not allowed to play online, don't allow them to select one.	    
	PlayerIndex = class'UIInteraction'.static.GetPlayerIndex(LP.ControllerID);
	PlayerControllerID = class'UIInteraction'.static.GetPlayerControllerId( PlayerIndex );
	if (!class'UIInteraction'.static.IsLoggedIn(PlayerControllerID, true))
	{
		`log("MUST BE LOGGED IN TO GET SEARCH RESULTS");
		//FORCE A LAN SEARCH HERE.  Attempting an online search here will crash the game if you are not signed into Steam  ** IF WE SUPPORT IT **
	}
}

function ChangeSearchType(ESteamMatchmakingType SearchType, optional bool bPreventNewSearch)
{
	GameInterface.SetMatchmakingTypeMode(SearchType);
	if(!bPreventNewSearch)
	{
		RefreshServerList(FakePlayerIndex);
	}
}

function LocalizeText()
{
	local GFxObject LocalizedObject;
	LocalizedObject = CreateObject( "Object" );
	
	LocalizedObject.SetString("players", ServerMenu.PlayersString);
	LocalizedObject.SetString("name", ServerMenu.NameString);
	LocalizedObject.SetString("mode", ServerMenu.GameModeString);
	LocalizedObject.SetString("difficulty", ServerMenu.DifficultyString);
	LocalizedObject.SetString("map", ServerMenu.MapString);
	LocalizedObject.SetString("filters", ServerMenu.FiltersString);
	LocalizedObject.SetString("search", ServerMenu.SearchString);
	LocalizedObject.SetString("refresh", ServerMenu.RefreshString);
	LocalizedObject.SetString("gamesFound", ServerMenu.GamesFoundString);

	LocalizedObject.SetString("back", LeaveServerBrowserString );
	LocalizedObject.SetString("details", DetailsString);
	LocalizedObject.SetString("spectate", SpectateString);
	LocalizedObject.SetString("join", ServerMenu.JoinString);

	SetObject("localizedText", LocalizedObject);
}

function OnRefeshClick()
{
	RefreshServerList(FakePlayerIndex);
}

function ClearGFXServerList()
{
	local GFxObject TempArray;
	
	TempArray = CreateArray();

	SetObject("dataProvider", TempArray);
}

/** Refreshes the server list. */
function RefreshServerList(int InPlayerIndex)
{
	local KFOnlineGameSearch GameSearch;	

	if(SearchDataStore == none) {
		`log("Can't refresh server list without a Search DS!");
		return;
	}

	ClearGFXServerList();

	//This submits the server list query
	CancelQuery(QUERYACTION_RefreshAll);	
	
	// Get current filter from the string list datastore
	GameSearch = KFOnlineGameSearch(SearchDataStore.GetCurrentGameSearch());

	// Set max results
	if(ServerMenu.FiltersContainer.bLimitServerResults)
	{
		GameSearch.MaxSearchResults = Max(MaxSearchResults, 1);
	}
	else
	{
		GameSearch.MaxSearchResults = MaxInt;
	}
	
}

function BuildServerFilters(KFGFxServerBrowser_Filters Filters, OnlineGameSearch Search)
{
	local string GametagSearch;
	local string MapName;
	local int Mode, Difficulty, Length;
	local bool DisableSeasonalSkins;

	Search.ClearServerFilters();

	Search.AddServerFilter("version_match", string(class'KFGameEngine'.static.GetKFGameVersion()));
	Search.TestAddServerFilter( Filters.bNotFull, "notfull");
	Search.TestAddServerFilter( Filters.bNotEmpty, "hasplayers");
	Search.TestAddBoolGametagFilter(GametagSearch, Filters.bNoLocalAdmin, 'bServerExiled', 0);

	DisableSeasonalSkins = Filters.bNoSeasonalSkins;

	if (class'KFGameEngine'.static.GetSeasonalEventID() == SEI_None
		|| class'KFGameEngine'.static.GetSeasonalEventID() == SEI_Spring)
	{
		DisableSeasonalSkins = false;
	}

	Search.TestAddBoolGametagFilter(GametagSearch, DisableSeasonalSkins, 'bNoSeasonalSkins', 1);

	if( !class'WorldInfo'.static.IsConsoleBuild() )
	{
		Search.TestAddServerFilter( Filters.bDedicated, "dedicated");
		if( !class'WorldInfo'.static.IsEOSBuild() )
		{
			Search.TestAddServerFilter( Filters.bVAC_Secure, "secure");
		}
	}

	MapName = Filters.GetSelectedMap();
	if (MapName != "")
	{
		Search.AddServerFilter( "map", MapName);
	}

	if (Filters.bInProgress && !Filters.bInLobby)
	{
		Search.TestAddBoolGametagFilter(GametagSearch, Filters.bInProgress, 'bInProgress', 1);
	}
	else if (Filters.bInLobby)
	{
		Search.TestAddBoolGametagFilter(GametagSearch, Filters.bInLobby, 'bInProgress', 0);
	}

	if( !class'WorldInfo'.static.IsConsoleBuild() )
	{
		Search.TestAddBoolGametagFilter(GametagSearch, Filters.bNoPassword, 'bRequiresPassword', 0);
	}

	Mode = Filters.SavedGameModeIndex;
	if( Mode >= 0 && Mode < 255 )
	{
		Search.AddGametagFilter( GametagSearch, 'Mode', string(Mode) );
	}

	Difficulty = Filters.GetSelectedDifficulty();
	if (Difficulty >= 0)
	{
		Search.AddGametagFilter(GametagSearch, 'Difficulty', string(Difficulty));
	}

	Length = Filters.GetSelectedGameLength();
	if (Length >= 0)
	{
		Search.AddGametagFilter(GametagSearch, 'NumWaves', string(Length));
	}

	//`log("bCustom="$Filters.bCustom);	
	if(Filters.bCustom && !class'WorldInfo'.static.IsConsoleBuild() )
	{
		//`log("adding custom filter");	
		Search.TestAddBoolGametagFilter(GametagSearch, Filters.bCustom, 'bCustom', 0);
	}
	

	if (Len(GametagSearch) > 0)
	{
		Search.AddServerFilter( "gametagsand", GametagSearch);
	}
	if (Search.MasterServerSearchKeys.length > 1)
	{
		Search.AddServerFilter( "and", string(Search.MasterServerSearchKeys.length), 0);
	}
//@SABER_BEGIN - Saving the value for ping filter in server search parameters
	if (class'WorldInfo'.static.IsEOSBuild())
	{
		Search.MaxPing = Filters.GetMaxPing();
	}
//@SABER_END
}

/**
 * Submits a query for the list of servers which match the current configuration.
 */
function SubmitServerListQuery( int PlayerIndex )
{
	// ToDo delete
	`log("SubmitServerListQuery called!");
	//ScriptTrace();
	BuildServerFilters(ServerMenu.FiltersContainer, SearchDataStore.GetCurrentGameSearch());

	if( class'WorldInfo'.static.IsConsoleBuild() || class'WorldInfo'.static.IsEOSBuild())
	{
		class'GameEngine'.static.GetPlayfabInterface().AddFindOnlineGamesCompleteDelegate( OnFindOnlineGamesCompleteDelegate );
	}
	else
	{
		// Add a delegate for when the search completes.  We will use this callback to do any post searching work.
		GameInterface.AddFindOnlineGamesCompleteDelegate(OnFindOnlineGamesCompleteDelegate);
	}

	// Start a search
	if ( !SearchDataStore.SubmitGameSearch(class'UIInteraction'.static.GetPlayerControllerId(PlayerIndex), false) )
	{
		if( class'WorldInfo'.static.IsConsoleBuild() || class'WorldInfo'.static.IsEOSBuild())
		{
			class'GameEngine'.static.GetPlayfabInterface().ClearFindOnlineGamesCompleteDelegate( OnFindOnlineGamesCompleteDelegate );
		}
		else
		{
			GameInterface.ClearFindOnlineGamesCompleteDelegate(OnFindOnlineGamesCompleteDelegate);
		}
		
		//Set Refreshing to false  **UI of we want to show it**
		SetRefreshingIndicator(false);
	}
	else
	{
		//We're starting a new search, create a new DataProvider array
		FilteredCount = 0;
		DataProvider = CreateArray();	
		SetRefreshingIndicator(true);
	}
}
/**
 *  @return True if the entry was filtered, false if it wasn't
 */
native function bool FilterEntry(OnlineGameSearch Search, KFGFxServerBrowser_Filters filter, int entry);

/**
 * Delegate fired each time a new server is received, or when the action completes (if there was an error)
 *
 * @param bWasSuccessful true if the async action completed without error, false if there was an error
 */
function OnFindOnlineGamesCompleteDelegate(bool bWasSuccessful)
{
	local bool bSearchCompleted;
	local OnlineGameSearch Search;

	`log("OnFindOnlineGamesCompleteDelegate called!, bWasSuccessful is" @ bWasSuccessful);
	Search = SearchDataStore.GetActiveGameSearch();
	bSearchCompleted = Search == none || Search.Results.length == lastServerCount;
	if ( !bSearchCompleted )
	{
		if ( Search.Results.length > 0 && (!ServerMenu.ApplyFilters || !FilterEntry(Search, ServerMenu.FiltersContainer, Search.Results.length-1)) )
		{
			`TimerHelper.SetTimer( 0.01, false, nameof(UpdateListDataProvider), self );
		}
		lastServerCount = Search.Results.length;
	}
	else
	{
		`log("OnFindOnlineGamesCompleteDelegate complete!");

		if( class'WorldInfo'.static.IsConsoleBuild() || class'WorldInfo'.static.IsEOSBuild())
		{
			class'GameEngine'.static.GetPlayfabInterface().ClearFindOnlineGamesCompleteDelegate( OnFindOnlineGamesCompleteDelegate );
		}
		else
		{
			GameInterface.ClearFindOnlineGamesCompleteDelegate(OnFindOnlineGamesCompleteDelegate);
		}

		OnFindOnlineGamesComplete(bWasSuccessful);
		lastServerCount = -1;
	}

	// update the enabled state of the button bar buttons
	//UpdateButtonStates();
}

function OnClose()
{
	`log("KFGFxServerBrowser_ServerList::OnClose called.");
	//Make sure delegate isn't still set
	CancelQuery(QUERYACTION_CloseScene);
	ChangeSearchType(SMT_Internet, true);
	KFGameEngine(Class'Engine'.static.GetEngine()).OnHandshakeComplete = None;

	if( class'WorldInfo'.static.IsConsoleBuild() || class'WorldInfo'.static.IsEOSBuild())
	{
		class'GameEngine'.static.GetPlayfabInterface().ClearFindOnlineGamesCompleteDelegate( OnFindOnlineGamesCompleteDelegate );
		class'GameEngine'.static.GetPlayfabInterface().ClearQueryServerInfoCompleteDelegate( OnQueryAdditionalServerInfoComplete );
		if (class'WorldInfo'.static.IsEOSBuild()) {
			class'GameEngine'.static.GetPlayfabInterface().ClearGetPlayerListCompleteDelegate(OnGetPlayerListComplete);
		}
	}
	else
	{
		GameInterface.ClearFindOnlineGamesCompleteDelegate(OnFindOnlineGamesCompleteDelegate);
		GameInterface.ClearJoinOnlineGameCompleteDelegate(OnJoinGameComplete);
		GameInterface.ClearCancelFindOnlineGamesCompleteDelegate(OnCancelSearchComplete);
		GameInterface.ClearGetPlayerListCompleteDelegate(OnGetPlayerListComplete);
	}
}

function OnGetPlayerListComplete(OnlineGameSettings Settings, bool Success)
{
	local int i;
	if (SearchDataStore.GetCurrentGameSearch().Results[SelectedServerIndex].GameSettings != Settings)
	{
		`log("KFGFxServerBrowser_ServerList.OnGetPlayerListComplete got player list for unselected server",, 'DevOnline');
		return;
	}

	if (class'WorldInfo'.static.IsEOSBuild()) {
		class'GameEngine'.static.GetPlayfabInterface().ClearGetPlayerListCompleteDelegate(OnGetPlayerListComplete);
	} else {
		GameInterface.ClearGetPlayerListCompleteDelegate(OnGetPlayerListComplete);
	}

	if (Success)
	{
		ServerMenu.ServerDetailsContainer.UpdatePlayerList(Settings); 
		`log("***Server Browser got player list:");
		for (i = 0; i < Settings.PlayersInGame.Length; ++i)
		{
			`log(i+1 $ ":" @ Settings.PlayersInGame[i].PlayerName);
		}
		`log("***End of player list");
	}
	else
	{
		`log("***Server didn't respond with player list!");
	}
}

/**
 * Delegate fired when the search for an online game has completed
 *
 * @param bWasSuccessful true if the async action completed without error, false if there was an error
 */
function OnFindOnlineGamesComplete(bool bWasSuccessful)
{	
	// ToDo delete
	`log("OnFindOnlineGamesComplete called!");
	SetRefreshingIndicator(false);
	if ( QueryCompletionAction != QUERYACTION_None )
	{
		/*if ( bQueryDialogShowing )
		{
			MenuManager.PopView();
			bQueryDialogShowing = false;
		}
		else
		{*/
			OnCancelSearchComplete(true);
		//}
	}    
	
	// refresh the list with the items from the currently selected gametype's cached query
	
}

/**
 * Fires an asynchronous task to cancels all active queries.
 *
 * @param	DesiredCancelAction		specifies what should happen when the asynchronous task completes.
 */
function CancelQuery( optional EQueryCompletionAction DesiredCancelAction=QUERYACTION_Default )
{
	// ToDo delete
	`Log("CancelQuery called!");
	if ( QueryCompletionAction == QUERYACTION_None )
	{
		QueryCompletionAction = DesiredCancelAction;
		if ( SearchDataStore.GetActiveGameSearch() != none )
		{
			if( class'WorldInfo'.static.IsConsoleBuild() || class'WorldInfo'.static.IsEOSBuild())
			{
				class'GameEngine'.static.GetPlayfabInterface().CancelGameSearch();
				OnCancelSearchComplete(true);
			}
			else
			{
				// we don't check for none so that we get warning in the log if GameInterface is none (this would be bad)
				GameInterface.AddCancelFindOnlineGamesCompleteDelegate(OnCancelSearchComplete);
				GameInterface.CancelFindOnlineGames();
			}
		}
		else if ( SearchDataStore.GetCurrentGameSearch().Results.length > 0 || QueryCompletionAction == QUERYACTION_RefreshAll )
		{
			OnCancelSearchComplete(true);
		}
		// If no cancel delegate will get kicked off, reset the QueryCompletionAction value, or it gets stuck in 'cancelling' mode
		else
		{
			QueryCompletionAction = QUERYACTION_None;
		}
	}
	else
	{
		`log("Could not cancel query because query cancel already in progress:" @ GetEnum(enum'EQueryCompletionAction', QueryCompletionAction));
	}
}


/**
 * Handler for the 'cancel query' asynchronous task completion.  Performs the actions dictated by the current QueryCompletionAction, as
 * set when CancelQuery was called.
 */
function OnCancelSearchComplete( bool bWasSuccessful )
{
	local EQueryCompletionAction CurrentAction;	
	GameInterface.ClearCancelFindOnlineGamesCompleteDelegate(OnCancelSearchComplete);

	CurrentAction = QueryCompletionAction;
	QueryCompletionAction = QUERYACTION_None;
	SetRefreshingIndicator(false);

	switch ( CurrentAction )
	{
	case QUERYACTION_CloseScene:
		ClearSearchResults();
		break;

	case QUERYACTION_JoinServer:
		JoinServer(SelectedServerIndex);            	            
		break;

	case QUERYACTION_RefreshAll:
		// if we're leaving the server browser area - clear all stored server query searches
		ClearSearchResults();
		
		// Refresh the server browser after our cancel query has completely finished
		GetPC().SetTimer(0.25f, false, nameof(DelayedRefresh), self);
		break;

	default:

		break;
	}
}

/** If we've just cancelled our search, always delay the next search so the queries 
* are not confused */
function DelayedRefresh()
{
	SubmitServerListQuery(FakePlayerIndex);
}

function JoinServer(optional int SearchResultIndex = -1, optional string WithPassword = "", optional bool JoinAsSpectator = false)
{
	local KFOnlineGameSettings ServerSettings;
	local OnlineGameSearchResult SearchResult;

	//ScriptTrace();
	if( SearchResultIndex >= 0 && SearchResultIndex < SearchDataStore.GetCurrentGameSearch().Results.Length ) 
	{
		SearchResult = SearchDataStore.GetCurrentGameSearch().Results[SearchResultIndex];
	} else 
	{
		return;
		// If the index is invalid, then we will assume its the query by ip result  //leaving this in here because this is valid.  Currently, OnlineGameSearch does not have this variable.  
		//SearchResult = SearchDataStore.GetCurrentGameSearch().QueryByIpResult;
	}

	// Store this in case we need it later
	SelectedServerIndex = SearchResultIndex;

	// Get the settings
	ServerSettings = KFOnlineGameSettings(SearchResult.GameSettings);
	if(ServerSettings == none) 
	{
		return;
	}

	// Just try joining, password or other checks will come back before the travel
	ServerPassword = WithPassword;
	bJoinAsSpectator = JoinAsSpectator;
	ProcessJoin(SearchResult);
}


private function ProcessJoin(OnlineGameSearchResult SearchResult)
{
	// ToDo delete
	`Log("ProcessJoin called!");
	if ( GameInterface != None )
	{
		if (SearchResult.GameSettings != None)
		{
			if( (class'WorldInfo'.static.IsConsoleBuild() || class'WorldInfo'.static.IsEOSBuild()) && !class'WorldInfo'.static.IsE3Build() )
			{
				// Make sure EOS game has GameSettings for crossplay needs.
				if ((GameInterface.GetGameSettings('Game') == None) && class'WorldInfo'.static.IsEOSBuild())
				{
					GameInterface.JoinOnlineGame(0, 'Game', SearchResult);
				}
				class'GameEngine'.static.GetPlayfabInterface().AddSearchResultToHistory( SearchResult.GameSettings.JoinString );
				class'GameEngine'.static.GetPlayfabInterface().AddQueryServerInfoCompleteDelegate( OnQueryAdditionalServerInfoComplete );
				class'GameEngine'.static.GetPlayfabInterface().QueryServerInfo( SearchResult.GameSettings.LobbyId );
			}
			else
			{
				// Set the delegate for notification
				GameInterface.AddJoinOnlineGameCompleteDelegate(OnJoinGameComplete);

				if (OnlineGameInterfaceImpl(GameInterface).GetGameSearch() != none)
				{
					`log("Already have an online game session when trying to join an online game. Destroying it.",,'DevOnline');
					//Despite dire warnings to the contrary, DestroyOnlineGame completes synchronously.
					GameInterface.DestroyOnlineGame('Game');
				}

				// Start the async task
				GameInterface.JoinOnlineGame(0, 'Game', SearchResult);
			}
		}
		else
		{
			OnJoinGameComplete('Game', false);
		}
	}
	else
	{
		ServerPassword = "";
		bJoinAsSpectator = false;
	}
}

function OnJoinGameComplete(name SessionName, bool bSuccessful)
{
	local string URL;

	// Figure out if we have an online subsystem registered
	if (GameInterface != None)
	{
		if (bSuccessful)
		{
			// Get the platform specific information
			if (GameInterface.GetResolvedConnectString(SessionName, URL))
			{
				KFGameViewportClient(LocalPlayer(GetPC().Player).ViewPortClient).LastConnectionAttemptAddress = URL;
				`Log("- Join Game Successful, Traveling: " $ URL);
				JoinGameURL();
			}
		}
		// Remove the delegate from the list
	

		GameInterface.ClearJoinOnlineGameCompleteDelegate(OnJoinGameComplete);
	}
	
	if( !bSuccessful )
	{
		if(GetServerDetails(SelectedServerIndex).bRequiresPassword)
		{
			ServerMenu.ShowPasswordPopup();
		}
	}

	ServerPassword = "";
}


function OnQueryAdditionalServerInfoComplete( bool bWasSuccessful, string LobbyId, string ServerIp, int ServerPort, string ServerTicket )
{
	local string OpenCommand;

	`log("OnQueryAdditionalServerInfoComplete with success"@bWasSuccessful@"and lobbyID"@LobbyId@"and server IP"@ServerIp@"and port"@ServerPort);
	class'GameEngine'.static.GetPlayfabInterface().ClearQueryServerInfoCompleteDelegate( OnQueryAdditionalServerInfoComplete );

	if( !bWasSuccessful || ServerIp == "" )
	{
		// TODO: Popup?
		`warn("Failed to connect to server for some reason");
	}
	else
	{
		OpenCommand = "open"@ServerIp$":"$ServerPort;
		OpenCommand $= "?AuthTicket="$ServerTicket;
		OpenCommand $= "?PlayfabPlayerId="$class'GameEngine'.static.GetPlayfabInterface().CachedPlayfabId;

		if( bJoinAsSpectator )
		{
			OpenCommand $= "?SpectatorOnly=1";
		}

		if (class'WorldInfo'.static.IsEOSBuild() && ( ServerPassword != "" ))
		{
				OpenCommand $= "?Password=" $ ServerPassword;
		}

		KFGameEngine(Class'Engine'.static.GetEngine()).OnHandshakeComplete = OnHandshakeComplete;

		`log("Going to connect with URL:"@OpenCommand);
		ConsoleCommand( OpenCommand );
	}
}



function bool OnHandshakeComplete(bool bSuccess, string Error, out int SuppressPasswordRetry)
{
	KFGameEngine(Class'Engine'.static.GetEngine()).OnHandshakeComplete = None;
	if (bSuccess)
	{
		OnlineSub.GetLobbyInterface().LobbyJoinServer(KFGameViewportClient(LocalPlayer(GetPC().Player).ViewPortClient).LastConnectionAttemptAddress);
	}
	SuppressPasswordRetry = 1;
	`log("*******OnHandshakeComplete"@bSuccess@Error);
	ScriptTrace();
	return false;
}

private native function ServerConnect(string URL);

function JoinGameURL()
{
	local string URL;

	// Call the game specific function to appending/changing the URL
	URL = BuildJoinURL();

	KFGameEngine(Class'Engine'.static.GetEngine()).OnHandshakeComplete = OnHandshakeComplete;
	//`log("join url:" @ URL);
	// Get the resolved URL and build the part to start it
	ServerConnect(URL);
	ServerPassword = "";
}

function string BuildJoinURL()
{
	local string ConnectURL;

	ConnectURL = KFGameViewportClient(LocalPlayer(GetPC().Player).ViewPortClient).LastConnectionAttemptAddress;

	if ( ServerPassword != "" )
	{
		ConnectURL $= "?Password=" $ ServerPassword;
		OnlineSub.GetLobbyInterface().SetServerPassword(ServerPassword);
	}
	else
	{
		OnlineSub.GetLobbyInterface().SetServerPassword("");
	}

	if(bJoinAsSpectator)
	{
		ConnectURL $= "?SpectatorOnly=1";
	}
	ConnectURL $= OnlineSub.GetLobbyInterface().GetLobbyURLString();
	//ConnectURL $= BuildJoinFiltersRequestURL();
	return ConnectURL;
}


function string BuildJoinFiltersRequestURL()
{
	local string FiltersURL;
	local int GameDifficulty;

	GameDifficulty = ServerMenu.FiltersContainer.GetSelectedDifficulty();

	if( ServerMenu.FiltersContainer.SavedGameModeIndex >= 0 )
	{
		FiltersURL $= "?Game="$class'KFGameInfo'.static.GetGameModeClassFromNum(ServerMenu.FiltersContainer.SavedGameModeIndex);
	}

	if( GameDifficulty >= 0)
	{
		FiltersURL $= "?Difficulty="$GameDifficulty;
	}

	if( ServerMenu.FiltersContainer.SavedLengthIndex >= 0 )
	{
		FiltersURL $= "?GameLength="$ServerMenu.FiltersContainer.SavedLengthIndex;
	}

	return FiltersURL;
}


function OnRefreshServerDetails()
{
	local KFOnlineGameSearch GameSearch;

	GameSearch = KFOnlineGameSearch(SearchDataStore.GetCurrentGameSearch());

	if(GameSearch != none)
	{
		`log("Refeshing Server: " @GameSearch.Results[SelectedServerIndex].GameSettings.OwningPlayerName);
		//send the once the server is refreshed, ServerDetailsContainer::SetDetails(KFOnlineGameSettings ServerResult);
	}
}

function ClearSearchResults()
{
	if(SearchDataStore != none)
	{
		SearchDataStore.ClearAllSearchResults();
	}
}

function KFOnlineGameSettings GetServerDetails(int ServerIndex)
{
	local KFOnlineGameSearch GameSearch;
	local KFOnlineGameSettings KFOGS;

	GameSearch = KFOnlineGameSearch(SearchDataStore.GetCurrentGameSearch());

	if(GameSearch != none)
	{
		KFOGS = KFOnlineGameSettings(GameSearch.Results[ServerIndex].GameSettings);
	}
	return KFOGS;
}

function SetRefreshingIndicator(bool bRefreshing)
{
	SetBool("refreshing", bRefreshing);
}

function OnServerSelected(int ServerIndex)
{
	local bool success;
	local PlayfabInterface PlayfabInter;

	SelectedServerIndex = ServerIndex;
	`log("***Attempting to get player list for server" @ SelectedServerIndex);

	PlayfabInter = class'GameEngine'.static.GetPlayfabInterface();
	if( class'WorldInfo'.static.IsEOSBuild() && PlayfabInter != none )
	{
		PlayfabInter.AddGetPlayerListCompleteDelegate(OnGetPlayerListComplete);
		success = SearchDataStore.FindServerPlayerList(SelectedServerIndex);
		if (!success)
		{
			`log("***Failed to get player list for server" @ SelectedServerIndex);
			PlayfabInter.ClearGetPlayerListCompleteDelegate(OnGetPlayerListComplete);
		}
	} else {
		GameInterface.AddGetPlayerListCompleteDelegate(OnGetPlayerListComplete);
		success = SearchDataStore.FindServerPlayerList(SelectedServerIndex);
		if (!success)
		{
			`log("***Failed to get player list for server" @ SelectedServerIndex);
			GameInterface.ClearGetPlayerListCompleteDelegate(OnGetPlayerListComplete);
		}
	}
}

//native function bool FilterEntry(KFOnlineGameSettings Settings);

function UpdateListDataProvider()
{
	local int i, NewServerCount;
	
	local GFxObject TempObj;
	local KFOnlineGameSearch LatestGameSearch;
	local int Ping, PlayerCount;
	local KFOnlineGameSettings TempOnlineGamesSettings;

	LatestGameSearch = KFOnlineGameSearch(SearchDataStore.GetActiveGameSearch());

	if (LatestGameSearch != none && DataProvider != none )
	{
		for (i = 0; i < LatestGameSearch.Results.Length; i++)
		{
			if ( LatestGameSearch.Results[i].GameSettings.GfxId == INDEX_NONE || LatestGameSearch.Results[i].GameSettings.GfxId >= GFxServerObjects.length  )
			{
				if ( NewServerCount > 10 )
				{
					// delay
					`TimerHelper.SetTimer( 0.01, false, nameof(UpdateListDataProvider), self );
					break;
				}
				TempOnlineGamesSettings = KFOnlineGameSettings(LatestGameSearch.Results[i].GameSettings);

				if (class'WorldInfo'.static.IsEOSBuild() && i >= LatestGameSearch.MaxSearchResults)
				{
					break;
				}

				//@SABER_EGS_BEGIN - Add to the list only servers with measured ping
				if (class'WorldInfo'.static.IsEOSBuild() && TempOnlineGamesSettings.PingInMs == -1) {
					`TimerHelper.SetTimer( 0.1, false, nameof(UpdateListDataProvider), self );
					break;
				}
				//@SABER_EGS_END

				TempObj = CreateObject("Object");

				TempObj.SetString("serverName",    		TempOnlineGamesSettings.OwningPlayerName);

				PlayerCount = TempOnlineGamesSettings.NumPublicConnections-TempOnlineGamesSettings.NumOpenPublicConnections;

				if (PlayerCount < 0)
				{
					PlayerCount = 0;
				}

				TempObj.SetFloat("playerCount",        	PlayerCount);
				TempObj.SetFloat("maxPlayerCount",     	TempOnlineGamesSettings.NumPublicConnections);
				TempObj.SetFloat("waveCount",     		TempOnlineGamesSettings.CurrentWave);
				TempObj.SetFloat("maxWaveCount",		IsEndlessModeIndex(TempOnlineGamesSettings.Mode) ? INDEX_NONE : TempOnlineGamesSettings.NumWaves);
				TempObj.SetFloat("zedCount",     		TempOnlineGamesSettings.ZedCount);
				TempObj.SetFloat("maxZedCount",     	TempOnlineGamesSettings.MaxZedCount);
				TempObj.SetBool("vacEnable",          	TempOnlineGamesSettings.bAntiCheatProtected);
				TempObj.SetBool("mutators",          	TempOnlineGamesSettings.bMutators);
				TempObj.SetBool("bRanked",           	TempOnlineGamesSettings.bUsesStats);
				TempObj.SetBool("bCustom",           	TempOnlineGamesSettings.bCustom);

				Ping = 									TempOnlineGamesSettings.PingInMs;
				TempObj.SetString("ping",          		(Ping < 0) ? ("-") : (String(Ping)) );
				TempObj.SetString("difficulty",          Class'KFCommon_LocalizedStrings'.static.GetDifficultyString(TempOnlineGamesSettings.difficulty));
				
				TempObj.SetString("mode",           	class'KFCommon_LocalizedStrings'.static.GetGameModeString(TempOnlineGamesSettings.Mode) );
				TempObj.SetString("map",           		TempOnlineGamesSettings.MapName);
				TempObj.SetBool("locked",           	TempOnlineGamesSettings.bRequiresPassword);
				TempObj.SetBool("serverExiled",           	TempOnlineGamesSettings.bServerExiled);
				//Get Game State from var const databinding EOnlineGameState GameState;
				TempObj.SetString("gameStatus",         String(TempOnlineGamesSettings.GameState));		

				GFxServerObjects.AddItem(TempObj);
				TempOnlineGamesSettings.GfxId = GFxServerObjects.Length - 1;

				NewServerCount++;
			}


			if ( LatestGameSearch.Results[i].GameSettings.ElementIdx != i )
			{
				DataProvider.SetElementObject(i, GFxServerObjects[LatestGameSearch.Results[i].GameSettings.GfxId]); 
				LatestGameSearch.Results[i].GameSettings.ElementIdx = i;
			}
		}    
		SetObject("dataProvider", DataProvider);
	}
}

function bool IsEndlessModeIndex(int ModeIndex)
{
	return ModeIndex == 3;
}

function bool IsSelectedServerFavorited(int ServerSearchIndex)
{
	local PlayfabInterface PlayfabInter;
	local OnlineGameSearch LatestGameSearch;

	PlayfabInter = class'GameEngine'.static.GetPlayfabInterface();
	if( class'WorldInfo'.static.IsEOSBuild() && PlayfabInter != none )
	{
		LatestGameSearch = SearchDataStore.GetActiveGameSearch();
		return PlayfabInter.IsSearchResultInFavoritesList(LatestGameSearch, ServerSearchIndex);
	} else {
		return GameInterface.IsSearchResultInFavoritesList(ServerSearchIndex);
	}
}

function bool SetSelectedServerFavorited(bool bFavorited)
{
	local PlayfabInterface PlayfabInter;
	local OnlineGameSearch LatestGameSearch;

	PlayfabInter = class'GameEngine'.static.GetPlayfabInterface();
	if (bFavorited)
	{
		if( class'WorldInfo'.static.IsEOSBuild() && PlayfabInter != none )
		{
			LatestGameSearch = SearchDataStore.GetActiveGameSearch();
			return PlayfabInter.AddSearchResultToFavorites(LatestGameSearch, SelectedServerIndex);
		} else {
			return GameInterface.AddSearchResultToFavorites(SelectedServerIndex);
		}
	}
	else
	{
		if( class'WorldInfo'.static.IsEOSBuild() && PlayfabInter != none )
		{
			LatestGameSearch = SearchDataStore.GetActiveGameSearch();
			return PlayfabInter.RemoveSearchResultFromFavorites(LatestGameSearch, SelectedServerIndex);
		} else {
			return GameInterface.RemoveSearchResultFromFavorites(SelectedServerIndex);
		}
	}
}

cpptext
{
	inline UBOOL CheckFilters(const UKFOnlineGameSettings& settings, const UKFGFxServerBrowser_Filters& filter);
}

DefaultProperties
{
	lastServerCount=-1
	FakePlayerIndex=0
	ServerPassword=""
	SearchDSName=KFGameSearch
	bIssuedInitialQuery=FALSE
	bQueryDialogShowing=FALSE
	SelectedServerIndex=-1
}