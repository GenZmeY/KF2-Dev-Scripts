//=============================================================================
// KFGameEngine
//=============================================================================
// KF specific engine class needs
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
// - Andrew "Strago" Ladenberger
//=============================================================================

class KFGameEngine extends GameEngine
	config(Game)
	native;

/** Supported platforms for KF2 */
enum SupportedPlatform
{
	PLATFORM_PC_DX11,
	PLATFORM_PC_DX10
};

//Pre-allocating seasonal events based on quarterly-ish patch cycle even if we aren't currently using them.
enum SeasonalEventIndex
{
	SEI_None,
	SEI_Spring,
	SEI_Summer,
	SEI_Fall,
	SEI_Winter,
};

/** The game state we were in (paused, in game, etc.) when we lost focus */
var int LastFocusedGameStateID;

/** The font to use for drawing canvas text in KF */
var Font KFCanvasFont;
/** The universal scale for KFCanvasFont */
var float KFFontScale;

/** TRUE if we are actively logging into playfab */
var bool bReadingPlayfabStoreData;

/** Currently running event */
var private{private} const int SeasonalEventId;
var private const int LoadedSeasonalEventId;

/** Week index of the year - Used as index into weekly event */
var private int WeeklyEventIndex;


/************************************************************************************
* @name		Content
***********************************************************************************/
/**
	List of packages that were manually added to root for content precaching reasons.
	These are removed from root during server travel in order to allow them to be
	garbage collected while still maintaining a cached list in global space while a
	level is running.
 */
var init array<Object> CachedRootPackages;

/************************************************************************************
 * @name		User Options
 ***********************************************************************************/

// @todo Find a way to reset a options section
var float DefaultGammaMult;
//@HSL_MOD_BEGIN - amiller 5/11/2016 - Adding support to save extra data into profile settings - Removing config flag
var float MusicVolumeMultiplier, SFxVolumeMultiplier, DialogVolumeMultiplier, MasterVolumeMultiplier, PadVolumeMultiplier, VoipVolumeMultiplier, VoipMicVolumeMultiplier;
var float GammaMultiplier;	// a value between 0-1 that scales the gamma to a value between .5 and 3

var bool  bMusicVocalsEnabled;
var bool  bMinimalChatter;
var config float FOVOptionsPercentageValue;
//@HSL_MOD_END
var config bool  bShowWelderInInv;
var config bool  bUseAltAimOnDual;
var config bool  bAntiMotionSickness;

var private config bool bShowCrossHair;
/** Crossair for console builds (default on).  No config since it won't save */
var private bool 		bShowCrossHairConsole;

/** Whether to mute the game if focus is lost. */
var config bool bMuteOnLossOfFocus;

/** Whether to use native 4k resolution on Xbox One X (Scorpio) */
var config bool bEnableNative4k;

/** Cached stat rows used by XB1 only if there's ever a network interruption that won't allow a re-read of existing stats, We use this. */
var array<OnlineStatsRow> CachedStatRows;

/************************************************************************************
 * @name		Connection
 ***********************************************************************************/

// A callback for when a new connection handshake is complete
var transient delegate<HandshakeCompleteCallback> OnHandshakeComplete;

// Different connection errors that can occur during the join process
enum EConnectionError
{
	CE_None,                        // Default value, represents no error

	CE_Generic,                     // General unspecified connection error

	// These will all occur BEFORE a travel, via the GameInfo and AccessControl PreLogin functions
	CE_WrongPassword,               // Connection denied because the password is incorrect
	CE_NeedPassword,                // Connection denied because no password was specified

};

/** The last error we got attempting to connect */
var EConnectionError LastConnectionError;

//@HSL_BEGIN - JRO - 3/21/2016 - PS4 Sessions
var string ConsoleGameSessionGuid;
//@HSL_END

/** The game settings for a pending invite. Used when an idle profile accepts an invite and we need to switch profiles for XB1 */
var OnlineGameSettings GameSettingsForPendingInvite;

/** Title and message for notification that should appear if user ever gets kicked back to IIS */
var string ReturnToIISConnectionErrorTitle;
var string ReturnToIISConnectionErrorMessage;

/** The login status for the one local user */
var ELoginStatus LocalLoginStatus;

/************************************************************************************
 * @name		Debugging
 ***********************************************************************************/

/** List of categories to filter */
var(Debug) config array<Name> AILogFilter;

/** A manager for drawing semi-persistent debug lines/spheres/text with optional owners, etc. */
var transient private KFDebugLines	KFDebugLines;
/** Set to true to enable usage of KFDebugLines (see KFDebugLines.uc) */
var config bool	bEnableAdvDebugLines;

cpptext
{
	// static members
	static FString GetSeasonalEventPrefix();
	static FString GetSeasonalEventPackageName(INT EventId = -1, UMapInfo* MapInfo = NULL);
	static FString GetSeasonalEventStatsClassPath();

	// UEngine interface.
	void Init();
	void PreExit();
	void FinishDestroy();
	UBOOL Exec( const TCHAR* Cmd, FOutputDevice& Ar=*GLog );
	virtual UBOOL LoadMap( const FURL& URL, class UPendingLevel* Pending, FString& Error );
	virtual void SetProgress( EProgressMessageType MessageType, const FString& Title, const FString& Message );
	virtual UBOOL Browse(FURL URL, FString& Error);

	/**
	 * Pauses / unpauses the game-play when focus of the game's window gets lost / gained.
	 * @param EnablePause TRUE to pause; FALSE to unpause the game
	 */
	virtual void OnLostFocusPause( UBOOL EnablePause );

	// One-time init
	void LoadContentRootClass();
	void LoadSeekFreePackages();
	void LoadSeekFreeZedPackage();
	void InitGfxSettings();
	void DeallocatePlayfabServer();
	void SyncInventoryProperties();
	void SetSeasonalEventFromTitleData();

	/** Initializes default resolution */
	void InitializeResolution(INT CompatLevel);

	virtual void PerformBetweenMapTasks();

#if __TW_INTERNET_TIME_
    /** Trigger a network time lookup to update any time-based events (Weekly, Seasonal, etc) */
    virtual void UpdateTimedGameEvents();
#endif
}

/************************************************************************************
* @name		Content
***********************************************************************************/
native static function CacheToRoot(Object NewPackage);
native static function ClearCachedRootPackages();

/***********************************************************************************
* @name		Debug
***********************************************************************************/

native static function bool CheckSkipLobby(); // If -skiplobby is added to the command line, return true
native static function bool CheckSkipGammaCheck(); // If -NoGammaStartup is added to the command line, return true
native static function bool CheckNoAutoStart(); // If -NoAutoStart is added to the command line, return true
native static function bool CheckNoMusic(); // If -NoMusic is added to the command line or PIE, return true
native static function bool CheckNoRandomStart(); // If -NoRandomStart is added to the command line or PIE, return true

/** Gets debug information for the number of loaded classes and their resource size*/
native static function GetClassCountAndSize(out int ClassCount, out float ClassSize, out float ResourceSize, class LoadedClass);

/** Returns the debug lines object, will create one if none exists */
native static function KFDebugLines GetDebugLines(); // Accessor for KFDebugLines, if enabled

/***********************************************************************************
* @name		Platform / Online Backend
***********************************************************************************/

//Gets the game version for use on Steam
native static function int GetGameVersion();
/** Gets the current game version */
native static function int GetKFGameVersion();
/** Gets the current game Steam AppID */
native static function int GetAppID();

native static function SupportedPlatform GetPlatform();
native static function InitEventContent();
native static function RefreshEventContent();

// make sure our current tweak values are up-to-date with global
native static function RefreshOnlineGameData(bool RefreshTimeEvent = true);
native static function ApplyTweaks(string MapName);
native static function bool IsLastRefreshTweakParamsSuccessful();

/** returns true if solo play should be disabled for this build */
native static function bool IsSoloPlayDisabled();
/** returns true if the free event has ended */
native static function bool IsFreeConsolePlayOver();

function ReadPFStoreData()
{
	bReadingPlayfabStoreData = true;
	// Read Playfab store data
	GetPlayfabInterface().AddStoreDataReadCompleteDelegate(OnPlayfabStoreReadComplete);
	GetPlayfabInterface().ReadStoreData();
}

function OnPlayfabStoreReadComplete(bool bSuccessful)
{
	GetPlayfabInterface().ClearStoreDataReadCompleteDelegate(OnPlayfabStoreReadComplete);

	if (bSuccessful)
	{
		if (class'WorldInfo'.static.IsConsoleBuild(CONSOLE_Durango))
		{
			OnlineSubsystem.MarketplaceInterface.ResetAvailableProducts(GamePlayers[0].ControllerId, MIT_GameContent);
			OnlineSubsystem.MarketplaceInterface.ResetAvailableProducts(GamePlayers[0].ControllerId, MIT_GameConsumable);
			OnlineSubsystem.MarketplaceInterface.AddReadAvailableProductsCompleteDelegate(GamePlayers[0].ControllerId, OnReadAvailableProductsComplete);
			OnlineSubsystem.MarketplaceInterface.ReadAvailableProducts(GamePlayers[0].ControllerId, "", MIT_Game, MIT_GameContent);
		}
		else
		{
			// Read PSN store data
			OnlineSubsystem.PlayerInterfaceEx.AddStoreDataReadCompleteDelegate(OnStoreDataRead);
			OnlineSubsystem.PlayerInterfaceEx.ReadStoreData();
		}
	}
}

function OnReadAvailableProductsComplete(EMediaItemType MediaType)
{
	`log("Read products for store items of type"@MediaType);

	// If this was the game content, kick off the consumable read request
	if (MediaType == MIT_GameContent)
	{
		OnlineSubsystem.MarketplaceInterface.ReadAvailableProducts(GamePlayers[0].ControllerId, "", MIT_Game, MIT_GameConsumable);
	}
	// Reads all finished, next step is to read additional details for the products
	else
	{
		OnlineSubsystem.MarketplaceInterface.ClearReadAvailableProductsCompleteDelegate(GamePlayers[0].ControllerId, OnReadAvailableProductsComplete);

		// Now read additional details for the products. We'll start with gamecontent again
		OnlineSubsystem.MarketplaceInterface.AddReadAdditionalProductDetailsCompleteDelegate(GamePlayers[0].ControllerId, OnReadAdditionalProductDetailsComplete);
		OnlineSubsystem.MarketplaceInterface.ReadAdditionalDetailsForProducts(GamePlayers[0].ControllerId, MIT_GameContent);
	}
}

function OnReadAdditionalProductDetailsComplete(EMediaItemType MediaType)
{
	`log("Additional info for products read complete for type"@MediaType);

	// If this was the game content, kick off the consumable read request
	if (MediaType == MIT_GameContent)
	{
		OnlineSubsystem.MarketplaceInterface.ReadAdditionalDetailsForProducts(GamePlayers[0].ControllerId, MIT_GameConsumable);
	}
	else
	{
		OnlineSubsystem.MarketplaceInterface.ClearReadAdditionalProductDetailsCompleteDelegate(GamePlayers[0].ControllerId, OnReadAdditionalProductDetailsComplete);

		// Now read inventory
		OnlineSubsystem.MarketplaceInterface.AddReadInventoryItemsCompleteDelegate(GamePlayers[0].ControllerId, OnReadInventoryItemsComplete);
		OnlineSubsystem.MarketplaceInterface.ResetInventoryItems(GamePlayers[0].ControllerId, MIT_All);
		OnlineSubsystem.MarketplaceInterface.ReadInventoryItems(GamePlayers[0].ControllerId, MIT_All);
	}
}


function OnReadInventoryItemsComplete(EMediaItemType MediaType)
{
	`log("Inventory items read for"@MediaType);
	OnlineSubsystem.MarketplaceInterface.ClearReadInventoryItemsCompleteDelegate(GamePlayers[0].ControllerId, OnReadInventoryItemsComplete);
	OnStoreDataRead(true);
}

function OnStoreDataRead(bool bSuccessful)
{
	OnlineSubsystem.PlayerInterfaceEx.ClearStoreDataReadCompleteDelegate(OnStoreDataRead);
	// Read playfab inventory
	GetPlayfabInterface().AddInventoryReadCompleteDelegate(OnPlayfabInventoryReadComplete);
	GetPlayfabInterface().ReadInventory();
}

function OnPlayfabInventoryReadComplete(bool bSuccessful)
{
	bReadingPlayfabStoreData = false;
	GetPlayfabInterface().ClearInventoryReadCompleteDelegate(OnPlayfabInventoryReadComplete);
	OnlineSubsystem.ClearNewlyAdded();
}

function OnLinkStatusChange(bool bIsConnected)
{
	OnConnectionStatusChanged(bIsConnected ? OSCS_Connected : OSCS_ConnectionDropped);
}

function OnConnectionStatusChanged(EOnlineServerConnectionStatus ConnectionStatus)
{
	local KFGameViewportClient GVC;

	// Let player controller handle state change
	if (GamePlayers[0].Actor != none && KFPlayerController(GamePlayers[0].Actor) != none)
	{
		KFPlayerController(GamePlayers[0].Actor).HandleConnectionStatusChange(ConnectionStatus);
	}
	// Must be in a transition, kick back to main menu
	else
	{
		GetOnlineSubsystem().GameInterface.DestroyOnlineGame('Game');
		GVC = KFGameViewportClient(class'GameEngine'.static.GetEngine().GameViewport);
		GVC.bNeedDisconnectMessage = true;
		GVC.ConsoleCommand("open KFMainMenu");
	}
}

function OnLoginChange(byte LocalUserNum)
{
	local OnlinePlayerInterface PlayerInterface;

	PlayerInterface = GetOnlineSubsystem().PlayerInterface;

	// Xbox kicks player back to IIS if active player signs out after an active user has been established
	if( class'WorldInfo'.static.IsConsoleBuild(CONSOLE_Durango) &&
		( KFGameViewportClient(GameViewport).bSeenIIS || (KFPlayerController(GamePlayers[0].Actor) != none && KFPlayerController(GamePlayers[0].Actor).HasActiveUserEstablished()) ) )
	{
		// Kick previously active player back to IIS with an error message.
		if( LocalUserNum == GamePlayers[0].ControllerId && PlayerInterface.GetLoginStatus(LocalUserNum) != LS_LoggedIn )
		{
			KickBackToIIS("LoggedOutTitle", "LoggedOutMessage");
		}
		// Also kick back offline player if a user has signed in
		else if( LocalLoginStatus == LS_UsingLocalProfile && PlayerInterface.GetLoginStatus(LocalUserNum) == LS_LoggedIn )
		{
			KickBackToIIS("LoggedInTitle", "LoggedOutMessage");
		}
	}
}

function OnLoginStatusChanged(ELoginStatus NewStatus, UniqueNetId NewId)
{
	local KFGameViewportClient GVC;
	local UniqueNetId ZeroId, LocalPlayerId;

	LocalPlayerId = GamePlayers[0].GetUniqueNetId();

	// Only bother with active user
	if (LocalPlayerId == NewId && NewId != ZeroId)
	{
		// Let player controller handle state change
		if (GamePlayers[0].Actor != none && KFPlayerController(GamePlayers[0].Actor) != none)
		{
			KFPlayerController(GamePlayers[0].Actor).HandleLoginStatusChange(NewStatus == LS_LoggedIn);
		}
		// Logged out
		else if (NewStatus == LS_NotLoggedIn)
		{
			GetOnlineSubsystem().GameInterface.DestroyOnlineGame('Game');
			GVC = KFGameViewportClient(GameViewport);
			GVC.bNeedSignoutMessage = true;
			GVC.ConsoleCommand("open KFMainMenu");
		}
	}
}

function KickBackToIIS(string ErrorTitleKey, string ErrorMessageKey)
{
	// Set the cached errors
	ReturnToIISConnectionErrorTitle = Localize("Notifications", ErrorTitleKey, "KFGameConsole");
	ReturnToIISConnectionErrorMessage = Localize("Notifications", ErrorMessageKey, "KFGameConsole");;

	// Now perform logout
	PerformLogout();
}

function PerformLogout()
{
	local UIDataStore_OnlinePlayerData PlayerDataDS;

	OnlineSubsystem.PlayerInterface.Logout(GamePlayers[0].ControllerId);
	if (PlayfabInterfaceInst != none)
	{
		PlayfabInterfaceInst.Logout();
	}

	// Logout active player
	OnlineSubsystem.PlayerInterface.Logout(GamePlayers[0].ControllerId);

	// Reset the async state for the profile settings so a full read will complete
	PlayerDataDS = UIDataStore_OnlinePlayerData(class'UIInteraction'.static.GetDataStoreClient().FindDataStore('OnlinePlayerData', GamePlayers[0]));
	PlayerDataDS.ProfileProvider.Profile.AsyncState = OPAS_NotStarted;

	// Clear seen IIS flag
	KFGameViewportClient(GameViewport).bSeenIIS = false;

	// Destroy active game session
	OnlineSubsystem.GameInterface.DestroyOnlineGame('Game');

	// If we have a player controller, let it handle the state
	if (GamePlayers[0].Actor != none && KFPlayerController(GamePlayers[0].Actor) != none)
	{
		KFPlayerController(GamePlayers[0].Actor).PerformLogout();
	}
	// Must be in a transition. Kick back to the menu
	else
	{
		GameViewport.ConsoleCommand("open KFMainMenu");
	}
}

function RegisterOnlineDelegates()
{
	local int i;

	OnlineSubsystem.SystemInterface.AddConnectionStatusChangeDelegate(OnConnectionStatusChanged);

	for (i = 0; i < `MAX_NUM_PLAYERS; i++)
	{
		OnlineSubsystem.PlayerInterface.AddLoginStatusChangeDelegate(OnLoginStatusChanged, i);
	}

	OnlineSubsystem.PlayerInterface.AddLoginChangeDelegate(OnLoginChange);
}

function ClearOnlineDelegates()
{
	local int i;

	OnlineSubsystem.SystemInterface.ClearConnectionStatusChangeDelegate(OnConnectionStatusChanged);

	for (i = 0; i < `MAX_NUM_PLAYERS; i++)
	{
		OnlineSubsystem.PlayerInterface.ClearLoginStatusChangeDelegate(OnLoginStatusChanged, i);
	}

	OnlineSubsystem.PlayerInterface.ClearLoginChangeDelegate(OnLoginChange);
}

/** Static because these are both called on default object */
native static function int GetSeasonalEventID();
native static function int GetWeeklyEventIndex();
native static function bool IsSalesEventActive();
native static function bool IsSalesEventChecked();
/***********************************************************************************
* @name		Game Options
***********************************************************************************/
native static function InitAudioOptions();
native static function InitGamma();

native static function SetWWiseSFXVolume( float Volume );
native static function SetWWiseMusicVolume( float Volume );
native static function SetWWiseVoiceVolume( float Volume );
native static function SetWWiseMasterVolume( float Volume );
native static function SetWWisePADVolume( float Volume );
native static function SetVoIPRecieveVolume( float Volume );
native static function SetVoIPMicRecieveVolume( float Volume );
native static function GetVoIPVolumeRange(out float MinVol, out float MaxVol, out float CurrentVol);
native static function PlayFullScreenMovie(string MovieName);
native static function bool IsFullScreenMoviePlaying();

/**
* Sets the current gamma value.
*
* @param New Gamma Value, must be between 0.0 and 1.0
*/
native static function SetGamma(float InGammaMultiplier);
native static function SetNative4k(bool InEnableNative4k);
native static function SwitchNative4k();

/***********************************************************************************
* @name		Server takeover/reconfigure
***********************************************************************************/

/**
* Helper function that will return an enum value representative of the actual error that occurred
* We have to do this by comparing the localized connection error message to what we know exists in the localization files
*
* @param Message the localized connection error message
*
* @return The EConnectionError representing the actual error that occurred
*/
static function EConnectionError GetConnectionErrorForMessage(out string Message, out string Title)
{
	if (Message == "<Strings:Engine.AccessControl.NeedPassword>") {
		return CE_NeedPassword;
	}

	if (Message == "<Strings:Engine.AccessControl.WrongPassword>") {
		return CE_WrongPassword;
	}

	return CE_Generic;
}

function SetLastConnectionError(string Message, string Title)
{
	if (LastConnectionError == CE_None) {
		// Let's try to determine what exactly happened here ... and unfortunately we only have these localized strings to do it
		LastConnectionError = GetConnectionErrorForMessage(Message, Title);
	}
}

delegate bool HandshakeCompleteCallback(bool bSuccess, string Error, out int SuppressPasswordRetry);

event bool CheckHandshakeComplete(EProgressMessageType MessageType, string Title, out int SuppressPasswordRetry, out int Cleanup)
{
	local bool SuppressPopup;

	SuppressPopup = false;
	Cleanup = 0;

	if (OnHandshakeComplete != None)
	{
		switch (MessageType)
		{
		case PMT_ConnectionFailure:
		case PMT_PeerConnectionFailure:
		case PMT_PeerHostMigrationFailure:
		case PMT_SocketFailure:
			Cleanup = 1;
			SuppressPopup = OnHandshakeComplete(false, Title, SuppressPasswordRetry);
			break;
		case PMT_Information:
			if (Title == "HandshakeDone") //This string is set in UnPenLev.cpp UNetPendingLevel::NotifyControlMessage
			{
				SuppressPopup = OnHandshakeComplete(true, Title, SuppressPasswordRetry);
			}
			break;
		}
	}
	return SuppressPopup;
}

native static function CancelPendingLevel();

function bool IsLockedServer()
{
	return bUsedForTakeover && !bAvailableForTakeover;
}

function UnlockServer()
{
	local UniqueNetId NullId;

	if (class'WorldInfo'.static.GetWorldInfo().NetMode == NM_DedicatedServer)
	{
		//`REMOVEMESOON_ServerTakeoverLog("KFGameEngine.UnlockServer - bUsedForTakeover: "$bUsedForTakeover);
	}

	if (bUsedForTakeover)
	{
		`log("***The server is now unlocked and available for takeover!");
		ConsoleGameSessionGuid = "";
		KFGameReplicationInfo(class'WorldInfo'.static.GetWorldInfo().GRI).ConsoleGameSessionHost = NullId;
		bAvailableForTakeover = true;
		bPrivateServer = false;
	}
}

native function KillPendingServerConnection();

/***********************************************************************************
* @name		Misc Helpers
***********************************************************************************/
/**
 * Wrapper for engine fast trace
 * Very fast, uses RBCC_Visibility. Returns TRUE if did not hit world geometry. Does not use extents or complex collision.
 * @NOTE: Will not hit KFDoorActors, KFDestructibleActors, KFFracturedMeshActors, or CanBecomeDynamic() actors
 */
native static function bool FastTrace_PhysX( vector TraceEnd, vector TraceStart );

/* TODO: Using LoadPackageAsync

* Calling "LoadPackageAsync" will load the entirety of a package (ex. all of KFGameContent), however all unused classes will be garbage collected shortly after
* Create separate arrays of loaded and pending load classes for weapons, characters and possibly zeds
* By storing a loaded class in an array, it will not get garbage collected and we will not need to reload a package for a class that we already have
* To access this class, search through the array and spawn it whereever it is needed

* Gears of War 3 uses LoadPackageAsync only when they are using SeekFreeLoading, otherwise classes will be DLO'd immediately
* Gears of War 3 uses a different cooking method to read from smaller cooked packages that can be loaded asynchronously without having to load something like "GearGame"
* Gears of War 3 has an object class that exists specifically for holding loaded classes of a certain package (ex. class GearMPCharacterStore)
*/

/** Get the canvas font used for KF */
static function Font GetKFCanvasFont()
{
	return default.KFCanvasFont;
}

/** Get the universal scalar for the KFCanvasFont */
static function float GetKFFontScale()
{
	return default.KFFontScale;
}

/** Get value of crosshair option */
static function bool IsCrosshairEnabled()
{
	return default.bShowCrossHair;
}

/** Set value of crosshair option */
static function SetCrosshairEnabled(bool bEnable)
{
	default.bShowCrossHair = bEnable;

	if ( !Class'WorldInfo'.Static.IsConsoleBuild() )
	{
		StaticSaveConfig();
	}
}

DefaultProperties
{
	DefaultGammaMult=.68
	KFCanvasFont=Font'UI_Canvas_Fonts.Font_Main'
	KFFontScale=0.65f
	SeasonalEventId=-1
	LoadedSeasonalEventId=-1
    WeeklyEventIndex=-1
	LocalLoginStatus=LS_LoggedIn
	SafeFrameScale=1.0

	MasterVolumeMultiplier=50.0
	DialogVolumeMultiplier=50.0
	MusicVolumeMultiplier=50.0
	SFxVolumeMultiplier=50.0

	// By default disable AILogging (see `define AILog)
	// by command line: '-enableailogging'
	// by cheat: 'ToggleAILogging'
	bDisableAILogging=true
}