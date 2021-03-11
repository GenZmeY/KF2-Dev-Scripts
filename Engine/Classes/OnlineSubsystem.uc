/**
 * Copyright 1998-2013 Epic Games, Inc. All Rights Reserved.
 */

/**
 * This class holds a set of online interfaces that game code uses to talk
 * with the platform layer's services. The set of services are implemented
 * as interface pointers so that we can mix & match services at run time.
 * This also allows licensees the ability to use part of our base services
 * and provide custom implmentations of others.
 */
class OnlineSubsystem extends Object
	native
	abstract
	inherits(FTickableObject)
	dependson(Settings)
	config(Engine);

/** The interface to use for creating and/or enumerating account information */
var OnlineAccountInterface AccountInterface;

/** The interface for accessing online player methods */
var OnlinePlayerInterface PlayerInterface;

/** The interface for accessing online player extension methods */
var OnlinePlayerInterfaceEx PlayerInterfaceEx;

//@HSL_BEGIN_XBOX
/** The interface for accessing online marketplace methods */
var OnlineMarketplaceInterface MarketplaceInterface;
//@HSL_END_XBOX

/** The interface for accessing system wide network functions */
var OnlineSystemInterface SystemInterface;

/** The interface to use for creating, searching for, or destroying online games */
var OnlineGameInterface GameInterface;

/** The interface to use for online content */
var OnlineContentInterface ContentInterface;

/** The interface to use for voice communication */
var OnlineVoiceInterface VoiceInterface;

/** The interface to use for stats read/write operations */
var OnlineStatsInterface StatsInterface;

/** The interface to use for reading game specific news announcements */
var OnlineNewsInterface NewsInterface;

/** The interface to use for accessing online party chat methods */
var OnlinePartyChatInterface PartyChatInterface;

`if(`__TW_)
/** The different statuses for a party */
enum EPartyNotificationStatus
{
	/** Party has not been created yet */
	PNS_NonExistent,
	/** Party is in the process of being created */
	PNS_Creating,
	/** Party has been created */
	PNS_Created,
	/** Party has been created and session request has comeback...everything is ready*/
	PNS_Complete,
	/** Party is in the process of being dissolved/destroyed */
	PNS_Dissolving,
	/** Party has been dissolved/destroyed */
	PNS_Dissolved
};
`endif

//@HSL_BEGIN - JRO - 7/16/2016 - Support for PS4 party interface
/** The interface for party functionality */
var OnlinePartyInterface PartyInterface;
//@HSL_END

/** The interface to use for downloading files from the network platform */
var OnlineTitleFileInterface TitleFileInterface;

/** The interface to use for checking the availability of cached files */
var OnlineTitleFileCacheInterface TitleFileCacheInterface;

/** The interface to use for reading and writing files to the cloud */
var UserCloudFileInterface UserCloudInterface;

/** The interface to use for sharing files on the cloud */
var SharedCloudFileInterface SharedCloudInterface;

/** The interface to use for posting to social networks */
var OnlineSocialInterface SocialInterface;

/** The interface to use for multiplayer authentication */
var OnlineAuthInterface AuthInterface;

`if(`__TW_)
/** The array of delegates that notify that the stats read operation has completed */
var array<delegate<OnInventoryReadComplete> > ReadInventoryCompleteDelegates;
var const bool bInventoryReady;
var array<delegate<OnPingRegionsComplete> > PingRegionsCompleteDelegates;

/** The array of delegates that notify that the avatar read operation has completed */
var array<delegate<OnReadOnlineAvatarComplete> > ReadAvatarCompleteDelegates;
var array<delegate<OnReadOnlineAvatarByNameComplete> > ReadAvatarByNameCompleteDelegates;
`endif


//@HSL_BEGIN_XBOX
/** The interface to use for recording game events */
var OnlineGameDVRInterface GameDVRInterface;

/** The interface to use for recording game events */
var OnlineCommunityContentInterface CommunityContentInterface;
//@HSL_END_XBOX


/** Struct that holds a transient, unique identifier for a player */
struct native UniqueNetId
{
	/** The id used by the network to uniquely identify a player */
	var QWORD Uid;

	structcpptext
	{
		/**
		 * The noinit version of the ctor
		 */
		FORCEINLINE FUniqueNetId(void)
		{
		}

		/**
		 * Zeros the data in the struct
		 *
		 * @param ignored. only present to allow zeroing of data
		 */
		FORCEINLINE FUniqueNetId(EEventParm)
		{
			Uid = (QWORD)0;
		}

		/**
		 * Zeros the data in the struct
		 *
		 * @param ignored. only present to allow zeroing of data
		 */
		FORCEINLINE FUniqueNetId(DWORD)
		{
			Uid = (QWORD)0;
		}

		/**
		 * Initialize from a QWORD
		 *
		 * @param InQWORD	The QWORD the UID should be initialized to
		 */
		FORCEINLINE FUniqueNetId(QWORD InQWORD)
		{
			Uid = InQWORD;
		}

#if WITH_STEAMWORKS && !defined( _WIN32 )
		FORCEINLINE FUniqueNetId(uint64 Id)
		{
			Uid = (QWORD)Id;
		}
#endif

		/** Copy constructor */
		FORCEINLINE FUniqueNetId(const FUniqueNetId& Other)
		{
			Uid = Other.Uid;
		}

		/**
		 * Compares the IDs for equality
		 *
		 * @param Id the value to compare
		 *
		 * @returns TRUE if they are equal, FALSE otherwise
		 */
		FORCEINLINE UBOOL operator==(const FUniqueNetId& Id) const
		{
			return Uid == Id.Uid;
		}

		/**
		 * Compares the IDs for inequality
		 *
		 * @param Id the value to compare
		 *
		 * @returns TRUE if they are not equal, FALSE otherwise
		 */
		FORCEINLINE UBOOL operator!=(const FUniqueNetId& Id) const
		{
			return Uid != Id.Uid;
		}

		/**
		 * Converts a DWORD into our type in network byte order
		 *
		 * @param Id the value to assign
		 */
		FORCEINLINE FUniqueNetId& operator=(const DWORD Id)
		{
//@HSL_BEGIN_XBOX
#if WITH_PANORAMA || XBOX || DINGO || WITH_STEAMWORKS
			check(0 && "Bad conversion loses data");
#else
			Uid = Id;
#endif
//@HSL_END_XBOX
			return *this;
		}

		/**
		 * Converts a QWORD into our type in network byte order
		 *
		 * @param Id the value to assign
		 */
		FORCEINLINE FUniqueNetId& operator=(const QWORD Id)
		{
			Uid = Id;
			return *this;
		}

#if WITH_STEAMWORKS && !defined( _WIN32 )
		FORCEINLINE FUniqueNetId& operator=(const uint64 Id)
		{
			Uid = (QWORD)Id;
			return *this;
		}
#endif

		/**
		 * Converts the unique id to a DWORD
		 *
		 * @return unique id as a DWORD
		 */
		FORCEINLINE DWORD ToDWORD(void) const
		{
//@HSL_BEGIN_XBOX
#if WITH_PANORAMA || XBOX || DINGO || WITH_STEAMWORKS
			check(0 && "Bad conversion loses data");
			return 0;
#else
			return Uid & 0xFFFFFFFF;
#endif
//@HSL_END_XBOX
		}

		/**
		 * Accessor for determining whether this net id has been assigned a value.
		 */
		FORCEINLINE UBOOL HasValue() const
		{
			return (QWORD)0 != Uid;
		}

		/** serialization interface */
		friend FArchive& operator<<(FArchive& Ar, FUniqueNetId& Id)
		{
			Ar << Id.Uid;
			return Ar;
		}
	}
};

//@HSL_BEGIN_XBOX
/** Keeps track of the last player to login to game  */
var native UniqueNetId LoggedInPlayerNetId;

/** Adding support for name-id pairs since Sony uses names and the rest of the world uses Ids*/
struct native PlayerNameIdPair
{
	var init string PlayerName;
	var UniqueNetId UniqueId;
};
//@HSL_END

/** The different login statuses for a player */
enum ELoginStatus
{
	/** Player has not logged in or chosen a local profile */
	LS_NotLoggedIn,
	/** Player is using a local profile but is not logged in */
	LS_UsingLocalProfile,
	/** Player has been validated by the platform specific authentication service */
	LS_LoggedIn
};

//@HSL_BEGIN - JRO - 3/21/2016 - PS4 Sessions - Make sure they have the privileges needed to play online
/** The different types of privileges a user may or may not have */
enum EFeaturePrivilege
{
	/** Can the user play online? */
	FP_OnlinePlay,
	/** Can the user use text communication? */
	FP_CommunicationText,
	/** Can the user use video communication? */
	FP_CommunicationVideo,
	/** Can the user use voice communication? */
	FP_CommunicationVoice,
	/** Can the user share (upload/download) user created content? */
	FP_ShareUserCreatedContent,
	/** Can the user purchase content? */
	FP_PurchaseContent,
	/** Can the user view player profiles? */
	FP_ViewPlayerProfile,
	/** Can the user be shown presence info? */
	FP_ShowPresenceInformation,
	/** Can the user record DVR clips? */
	FP_RecordDVRClips,
	/** Can the user use cloud storage? */
	FP_CloudStorage,
	/** Can the user access premium content? */
	FP_PremiumContent,
	/** Can the user access premium video content? */
	FP_PremiumVideoContent,
	/** Can the user browse the internet? */
	FP_BrowseInternet,
	/** Can the user share content to social networks? */
	FP_SocialNetworkSharing,
	/** Can the user share kinect generated/recorded content with other users? */
	FP_KinectSharing,
	/** Can the user upload fitness info? (eg height, weight, age, gender) */
	FP_FitnessUpload,
};

/** This enum indicates access to major features in the game (parent controls */
enum EFeaturePrivilegeLevel
{
	/** Parental controls have disabled this feature */
	FPL_Disabled,
	/** Parental controls allow this feature only with people on their friends list */
	FPL_EnabledFriendsOnly,
	/** Parental controls allow this feature everywhere */
	FPL_Enabled,
	/** Privilege Check Failed and is Unknown */
	FPL_Unknown,
};

//@HSL_BEGIN_XBOX
enum EReputationFeedbackType
{
    /** Player is using abusive language */
    RFBT_CommunicationsAbusiveVoice,
    /** Player is showing inappropriate video */
    RFBT_CommunicationsInappropriateVideo,
    /** Player is cheating the game */
    RFBT_FairPlayCheater,
    /** Player was kicked from game */
    RFBT_FairPlayKicked,
    /** Player is killing his own teammates */
    RFBT_FairPlayKillsTeammates,
    /** Player quit the game before it was over */
    RFBT_FairPlayQuitter,
    /** Player has tampered with on-disk content */
    RFBT_FairPlayTampering,
    /** Player has inappropriate user generated content */
    RFBT_InappropriateUserGeneratedContent,
    /** Player was helpful to another player */
    RFBT_PositiveHelpfulPlayer,
    /** Player has awesome user generated content */
    RFBT_PositiveHighQualityUserGeneratedContent,
    /** Player is awesome */
    RFBT_PositiveSkilledPlayer,
};
//@HSL_END_XBOX

/** Used to bulk query the friends list */
struct native FriendsQuery
{
	/** The unique player id to check friends status for */
	var UniqueNetId UniqueId;
	/** Out param indicating whether the player is a friend or not */
	var bool bIsFriend;
};

/** Indicates where network notifications should appear on the screen */
enum ENetworkNotificationPosition
{
	NNP_TopLeft,
	NNP_TopCenter,
	NNP_TopRight,
	NNP_CenterLeft,
	NNP_Center,
	NNP_CenterRight,
	NNP_BottomLeft,
	NNP_BottomCenter,
	NNP_BottomRight
};

/** Enum indicating the current state of the online game (in progress, ended, etc.) */
enum EOnlineGameState
{
	/** An online game has not been created yet */
	OGS_NoSession,
	/** Session has been created and the match hasn't started (pre match lobby) */
	OGS_Pending,
	/** Session has been asked to start (may take time due to communication with backend) */
	OGS_Starting,
	/** The current session has started. Matches with join in progress disabled are no longer joinable */
	OGS_InProgress,
	/** The session is still valid, but the match is no longer being played (post match lobby) */
	OGS_Ending,
	/** The session is closed and any stats committed */
	OGS_Ended
};

/** The state of an async enumeration (friends, content, etc) read request */
enum EOnlineEnumerationReadState
{
	OERS_NotStarted,
	OERS_InProgress,
	OERS_Done,
	OERS_Failed
};

//@HSL_BEGIN - JRO - 3/21/2016 - PS4 Sessions
enum OnGameInviteAcceptedResult
{
	OGIAR_Success,
	OGIAR_GeneralFailure,
	OGIAR_ServerActivity,
	OGIAR_WrongAccount,
};
//@HSL_END

//@HSL_BEGIN_XBOX
/** The account tier of this profile */
enum EOnlineAccountTier
{
	OAT_Unknown,
	OAT_NewUser,
	OAT_Silver,
	OAT_Gold,
	OAT_FamilyGold
};

/** Holds information about an online profile for a player */
struct native OnlineProfile
{
	/** The user id for this profile */
	var string UserId;
	/** The account tier of this profile*/
	var EOnlineAccountTier AccountTier;
	/** The total gamerscore for the player associated with this profile */
	var int Gamerscore;
	/** The name displayed in the application for the player associated with this profile */
	var string ApplicationDisplayName;
	/** The user name to display in-game for the player associated with this profile */
	var string GameDisplayName;
	/** The URL of the picture to display for the player associated with this profile */
	var string DisplayPictureURL;
	/** The URL of the resized display picture for the player associated with this profile */
	var string ApplicationDisplayPictureResizeURL;
	/** The URL of the profile's public gamer picture */
	var string PublicGamerPictureURL;
	/** The URL of the resized picture of the user to show in the game */
	var string GameDisplayPictureResizeURL;
};
//@HSL_END_XBOX

/** The possible friend states for a friend entry */
enum EOnlineFriendState
{
	/** Not currently online */
	OFS_Offline,
	/** Signed in and online */
	OFS_Online,
	/** Signed in, online, and idle */
	OFS_Away,
	/** Signed in, online, and asks to be left alone */
	OFS_Busy
};

//@HSL_BEGIN_XBOX
/** Possilbe Flags that can be used to create a Game Session */
enum EOnlineCreateGameSessionFlag
{
	OCGSF_New,
	OCGSF_ReSubmit
};
//@HSL_END_XBOX

//@TW Trial Notification enum
enum EFreeTrialNotification
{
	FTN_FeatureUnavailable,
	FTN_NetworkCheckFailed,
	FTN_BuyGame
};

/** Holds information about a player in a friends list */
struct native OnlineFriend
{
	/** Unique identifier of the friend */
	var const UniqueNetId UniqueId;
	/** The session id that the player is in */
	var const qword SessionId;
	/** Player's nick as published to the online service */
	var const string NickName;
	/** String holding information about the player's game state (cap-ed flag, etc.) */
	var const string PresenceInfo;
	/** The current state for this friend */
	var const EOnlineFriendState FriendState;
	/** Whether the friend is online or not */
	var const bool bIsOnline;
	/** Whether the friend is playing a game or not */
	var const bool bIsPlaying;
	/** Whether the friend is playing the same game or not */
	var const bool bIsPlayingThisGame;
	/** Whether the game the friend is in is joinable or not */
	var const bool bIsJoinable;
	/** Whether the friend can chat via voice or not */
	var const bool bHasVoiceSupport;
	/** Whether the friends has an invitation outstanding from you or not*/
	var bool bHaveInvited;
	/** Whether the friends has sent an invite to you or not */
	var const bool bHasInvitedYou;

	structcpptext
	{
		/**
		 * Zeroes members
		 */
		FOnlineFriend(void)
		{
			appMemzero(this,sizeof(FOnlineFriend));
		}

//@zombie_ps4_begin
		FOnlineFriend(EEventParm)
		{
			appMemzero(this,sizeof(FOnlineFriend));
		}
//@zombie_ps4_end
		/**
		 * Copy constructor. Copies the other into this object
		 *
		 * @param Other the other structure to copy
		 */
		FOnlineFriend(const FOnlineFriend& Other)
		{
			appMemzero(this,sizeof(FOnlineFriend));
			appMemcpy(&UniqueId,&Other.UniqueId,sizeof(FUniqueNetId));
			SessionId = Other.SessionId;
			NickName = Other.NickName;
			PresenceInfo = Other.PresenceInfo;
			FriendState = Other.FriendState;
			bIsOnline = Other.bIsOnline;
			bIsPlaying = Other.bIsPlaying;
			bIsPlayingThisGame = Other.bIsPlayingThisGame;
			bIsJoinable = Other.bIsJoinable;
			bHasVoiceSupport = Other.bHasVoiceSupport;
			bHaveInvited = Other.bHaveInvited;
			bHasInvitedYou = Other.bHasInvitedYou;
		}

		/**
		 * Assignment operator. Copies the other into this object
		 *
		 * @param Other the other structure to copy
		 */
		FOnlineFriend& operator=(const FOnlineFriend& Other)
		{
			if (this != &Other)
			{
				appMemcpy(&UniqueId,&Other.UniqueId,sizeof(FUniqueNetId));
				SessionId = Other.SessionId;
				NickName = Other.NickName;
				PresenceInfo = Other.PresenceInfo;
				FriendState = Other.FriendState;
				bIsOnline = Other.bIsOnline;
				bIsPlaying = Other.bIsPlaying;
				bIsPlayingThisGame = Other.bIsPlayingThisGame;
				bIsJoinable = Other.bIsJoinable;
				bHasVoiceSupport = Other.bHasVoiceSupport;
				bHaveInvited = Other.bHaveInvited;
				bHasInvitedYou = Other.bHasInvitedYou;
			}
			return *this;
		}
	}
};

//@HSL_BEGIN - JRO - 8/11/2016 - Useful data for each party member
struct native PartyMember
{
	var UniqueNetId OnlineId;
	var string NickName;
};
//@HSL_END

/** The type of player owned content */
enum EOnlineContentType
{
	/** Content downloaded digitally from the online market */
	OCT_Downloaded,
	/** Player's save game content */
	OCT_SaveGame,
	/** Game downloaded digitally from the online market */
	OCT_Game,
};

/** Holds information about a single piece of downloaded content */
struct native OnlineContent
{
	/** The type of content this represents */
	var EOnlineContentType ContentType;
	/** Optional user index that content is downloaded for (-1 means it's not associated with any user) */
	var byte UserIndex;
	/** Whether the package is corrupt or not */
	var bool bIsCorrupt;
	/** The device ID the DLC is on */
	var int DeviceId;
	/** The game specific license mask for this item */
	var int LicenseMask;
	/** Displayable name of the content */
	var string FriendlyName;
	/** Non-displayable file name of the content */
	var string Filename;
	/** File system usable reference to the content */
	var string ContentPath;
	/** List of packages in the content */
	var array<string> ContentPackages;
	/** List of all non-package files in the content */
	var array<string> ContentFiles;
};

/** Holds information about a single piece of cross title downloaded content */
struct native OnlineCrossTitleContent extends OnlineContent
{
	/** The title ID the content is from */
	var int TitleId;

	/** The title ID (as string) the content is from */
	var init string TitleIdString;

	/** Whether this item is a trial or not */
	var bool bIsTrial;
};

/**
 * Indicates the connection status with the remote online servers
 */
enum EOnlineServerConnectionStatus
{
	/** Gracefully disconnected from the online servers */
	OSCS_NotConnected,
	/** Connected to the online servers just fine */
	OSCS_Connected,
	/** Connection was lost for some reason */
	OSCS_ConnectionDropped,
	/** Can't connect because of missing network connection */
	OSCS_NoNetworkConnection,
	/** Service is temporarily unavailable */
	OSCS_ServiceUnavailable,
	/** An update is required before connecting is possible */
	OSCS_UpdateRequired,
	/** Servers are too busy to handle the request right now */
	OSCS_ServersTooBusy,
	/** Disconnected due to duplicate login */
	OSCS_DuplicateLoginDetected,
	/** Can't connect because of an invalid/unknown user */
	OSCS_InvalidUser,
//@HSL_BEGIN_PS4
	/** Can't connect because we are banned */
	OSCS_Banned,
	/** Can't connect because user age is too young */
	OSCS_TooYoung,
	/** Can't connect because PSN is not available */
	OSCS_PSNUnavailable,
	/** Can't connect because XBox Live is not available */
	OSCS_XBLiveUnavailable,
//@HSL_END_PS4
};

/**
 * The various NAT types the player may have
 */
enum ENATType
{
	/** Unable to determine the NAT type */
	NAT_Unknown,
	/** Anyone can join without connectivity problems */
	NAT_Open,
	/** Most can join but might have problems with strict */
	NAT_Moderate,
	/** Will most likely have connectivity problems with strict/moderate */
	NAT_Strict
};

/** A player in a session */
struct native OnlineRegistrant
{
	/** Unique id of the player involved in the arbitrated session */
	var const UniqueNetId PlayerNetId;

	structcpptext
	{
		/**
		 * The noinit version of the ctor
		 */
		FORCEINLINE FOnlineRegistrant(void)
		{
		}

		/**
		 * Inits it to the player id specified
		 *
		 * @param InId sets the player id
		 */
		FORCEINLINE FOnlineRegistrant(const FUniqueNetId InId) :
			PlayerNetId(InId)
		{
		}

		/**
		 * Compares the player IDs for equality
		 *
		 * @param Id the value to compare
		 *
		 * @returns TRUE if they are equal, FALSE otherwise
		 */
		FORCEINLINE UBOOL operator==(const FOnlineRegistrant& Other) const
		{
			return PlayerNetId == Other.PlayerNetId;
		}
	}
};

/** Struct holding the information about a single arbitration registrant */
struct native OnlineArbitrationRegistrant extends OnlineRegistrant
{
	/** Unique id of the machine involved in the arbitrated session */
	var const qword MachineId;
	/** Trust level of the machine/player for the arbitrated session */
	var const int Trustworthiness;
};

/**
 * Holds a word/phrase that was recognized by the speech analyzer
 *
 * @note See VoiceInterface.h to change the native layout of this struct
 */
struct SpeechRecognizedWord
{
	/** The id of the word in the vocabulary */
	var int WordId;
	/** the actual word */
	var string WordText;
	/** How confident the analyzer was in the recognition */
	var float Confidence;
};

/** Indicates the state the LAN beacon is in */
enum ELanBeaconState
{
	/** The lan beacon is disabled */
	LANB_NotUsingLanBeacon,
	/** The lan beacon is responding to client requests for information */
	LANB_Hosting,
	/** The lan beacon is querying servers for information */
	LANB_Searching
};

/**
 * Struct holding information used when writing scoring information that is used
 * to determine a player's skill rating
 */
struct native OnlinePlayerScore
{
	/** The player that this score is for */
	var UniqueNetId PlayerId;
	/** The team that the player is on */
	var int TeamId;
	/** The score for this player */
	var int Score;
};

/** The series of status codes that the account creation method can return */
enum EOnlineAccountCreateStatus
{
	/** Created the account successfully */
	OACS_CreateSuccessful,
	/** Failed but no indication why */
	OACS_UnknownError,
	/** The user name is invalid */
	OACS_InvalidUserName,
	/** The password is invalid */
	OACS_InvalidPassword,
	/** The unique user name is invalid */
	OACS_InvalidUniqueUserName,
	/** The user name is invalid */
	OACS_UniqueUserNameInUse,
	/** The backend service is not reachable */
	OACS_ServiceUnavailable
};

/** Information about a local talker */
struct native LocalTalker
{
	/** Whether this talker is currently registered */
	var bool bHasVoice;
	/** Whether the talker should send network data */
	var bool bHasNetworkedVoice;
	/** Whether the player is trying to speak voice commands */
	var bool bIsRecognizingSpeech;
	/** Whether the local talker was speaking last frame */
	var bool bWasTalking;
	/** Whether the remote talker is speaking this frame */
	var bool bIsTalking;
	/** Whether this player was already registered with the voice interface or not */
	var bool bIsRegistered;
//@HSL_BEGIN_XBOX
	/** Used to keep track of whether a player has been talking recently */
	var float TimeSinceLastPacket;
//@HSL_END_XBOX
};

/** Information about a remote talker */
struct native RemoteTalker
{
	/** The unique id for this talker */
	var UniqueNetId TalkerId;
	/** Used to trigger talking delegates only after a certain period of time has passed */
	var float LastNotificationTime;
	/** Whether the remote talker was speaking last frame */
	var bool bWasTalking;
	/** Whether the remote talker is speaking this frame */
	var bool bIsTalking;
	/** Whether this player was already registered with the voice interface or not */
	var bool bIsRegistered;
//@HSL_BEGIN_XBOX
	/** Used to keep track of whether a player has been talking recently */
	var float TimeSinceLastPacket;
	/** Used to keep track of how long the user has been in chat */
	var float TimeSinceJoining;
//@HSL_END_XBOX
};

/** Holds the data used in a friend message */
struct native OnlineFriendMessage
{
	/** The player that is sending the message */
	var UniqueNetId SendingPlayerId;
	/** The nick name of the player that sent the message */
	var string SendingPlayerNick;
	/** Whether this is a friend invite or just a generic message */
	var bool bIsFriendInvite;
	/** Whether this message is a game invite or not */
	var bool bIsGameInvite;
	/** Whether the invite has been accepted or not */
	var bool bWasAccepted;
	/** Whether the invite has been denied or not */
	var bool bWasDenied;
	/** The corresponding message that was sent */
	var string Message;
};

/** Holds a named object interface for dynamically bound interfaces */
struct native NamedInterface
{
	/** The name to bind this object to */
	var name InterfaceName;
	/** The object to store at this location */
	var Object InterfaceObject;
};

/** Holds the set of registered named interfaces */
var private array<NamedInterface> NamedInterfaces;

/** Holds a name to class name mapping for adding the named interfaces automatically */
struct native NamedInterfaceDef
{
	/** The name to bind this object to */
	var name InterfaceName;
	/** The class to load and create for the named interface */
	var string InterfaceClassName;
};

/** The list of named interfaces to automatically create and store */
var config array<NamedInterfaceDef> NamedInterfaceDefs;

/** Holds metadata about a given downloadable file */
struct native EmsFile
{
	/** Hash value, if applicable, of the given file contents */
	var string Hash;
	/** Filename as downloaded */
	var string DLName;
	/** Logical filename, maps to the downloaded filename */
	var string Filename;
	/** File size */
	var int FileSize;
};

/** Holds the data used in downloading a file asynchronously from the online service */
struct native TitleFile
{
	/** The name of the file as requested */
	var string Filename;
	/** The async state the file download is in */
	var EOnlineEnumerationReadState AsyncState;
	/** The buffer of data for the file */
	var array<byte> Data;
};

//@HSL_BEGIN_XBOX
enum EOnlineFileType
{
	OFT_Unknown,
	OFT_Binary,
	OFT_Json
};
//@HSL_END_XBOX

/** Community file info */
struct native CommunityContentFile
{
//@HSL_BEGIN_XBOX
	/** Unique identifier for this content file */
	var int ContentId;
	/** The path to the file on the server */
	var string RemoteContentPath;
	/** Content type field */
	var EOnlineFileType ContentType;
//@HSL_END_XBOX
	/** Size in bytes of the payload in the file */
	var int FileSize;
	/** The original owner of the file */
	var UniqueNetId Owner;
	/** The number of times this file has been downloaded */
	var int DownloadCount;
	/** The average rating for this file from the community */
	var float AverageRating;
	/** The number of times this file has been rated */
	var int RatingCount;
	/** The last rating the user gave this content */
	var int LastRatingGiven;
	/** The path to the file if stored locally */
	var string LocalFilePath;
};

/** Community file metadata */
struct native CommunityContentMetadata
{
//@HSL_BEGIN_XBOX
	/** Content type field */
	var EOnlineFileType ContentType;
	/** The remote path for where the file will live on the server */
	var string RemotePath;
	/** The display (friendly) name for the file */
	var string DisplayName;
};

struct native UserAccountInfo
{
	/** The date of birth of the user */
	var string DateOfBirth;
	/** The e-mail address of the user */
	var string Email;
	/** The first name of the user */
	var string FirstName;
	/** The last name of the user */
	var string LastName;
	/** The gamertag of the user */
	var string Gamertag;
};
//@HSL_END_XBOX

/** Holds the per session information for named sessions */
struct native NamedSession
{
	/** The name of the session */
	var name SessionName;
	/** The platform specific session information */
	var const native transient pointer SessionInfo{void};
	/** The game settings associated with this session */
	var OnlineGameSettings GameSettings;
	/** List of players registered in the session */
	var array<OnlineRegistrant> Registrants;
	/** The set of registered players for arbitration */
	var array<OnlineArbitrationRegistrant> ArbitrationRegistrants;
};

/** The list of sessions currently managed by the online subsystem */
var const protected array<NamedSession> Sessions;

//@HSL_BEGIN_XBOX
/** The type of an achievement reward */
enum EAchievementRewardType
{
	ART_Unknown,
	ART_Gamerscore,
	ART_InApp,
	ART_Art
};

/** The type of an achievement media asset*/
enum EAchievementMediaAssetType
{
	AMAT_Unknown,
	AMAT_Icon,
	AMAT_Art
};

/** The type of an achievement */
enum EAchievementUnlockType
{
	AUT_Unknown,
	AUT_All,
	AUT_Persistent,
	AUT_Challenge
};

/** The participation type of an achievement */
enum EAchievementParticipationType
{
	EAPT_Unknown,
	EAPT_Individual,
	EAPT_Group
};

/** The progress state of an achievement */
enum EAchievementProgressState
{
	APS_Unknown,
	APS_Achieved,
	APS_NotStarted,
	APS_InProgress,
};

/** A reward granted when an achievement is unlocked */
struct native AchievementReward
{
	/** The name of the reward */
	var const string RewardName;
	/** The descrion of the award */
	var const string Description;
	/** The data associated with the reward */
	var const string Data;
	/** Type type of the reward */
	var const EAchievementRewardType RewardType;
};

/** A media asset tied to an achievement */
struct native AchievementMediaAsset
{
	/** The name of the asset */
	var const string AssetName;
	/** The type of the asset */
	var const EAchievementMediaAssetType AssetType;
	/** The URL of the asset */
	var const string AssetURL;
};

/** An association between a title ID and an achievement */
struct native AchievementTitleAssociation
{
	/** The localized name of the title */
	var const string LocalizedTitleName;
	/** The title ID */
	var const int TitleID;
};
//@HSL_END_XBOX

/** Holds the information contained in Live's achievements for this title */
struct native AchievementDetails
{
//@HSL_BEGIN_XBOX
	/** The ID of the achievement DINGO_DEPRECATED in favor of the ID stored as a string */
	var const int Id;
	/** The ID of the achievement as a string */
	var const string StringId;
	/** The name of the achievement */
	var const string AchievementName;
	/** The description of the achievement NOTE: on Dingo this is the "Unlocked Description" */
    var const string Description;
	/** The description of how to meet the requirements of the achievement NOTE: on Dingo this is the "Locked Description"*/
    var const string HowTo;
    /** The image associated with the achievement */
	var Surface Image;
	/** The month of when it was earned DINGO_DEPRECATED */
	var const byte MonthEarned;
	/** The day of the month of when it was earned DINGO_DEPRECATED */
	var const byte DayEarned;
	/** The year of when it was earned (byte is fine since the none of the consoles will last that long :) ) DINGO_DEPRECATED */
	var const byte YearEarned;
	/** The day of week since we have a byte available for padding DINGO_DEPRECATED */
	var const byte DayOfWeekEarned;
	/** How much this achievement is worth NOTE: on Dingo this info will be stored in Rewards */
	var const int GamerPoints;
	/** Whether the achievement is secret (hidden if not achieved) or not */
	var const bool bIsSecret;
	/** Whether the achievement awarded online or not DINGO_DEPRECATED */
	var const bool bWasAchievedOnline;
	/** Whether the achievement awarded offline or not DINGO_DEPRECATED */
	var const bool bWasAchievedOffline;
	/** The type of this achievement (eg Challenge or Persistent) */
	var const EAchievementUnlockType UnlockType;
	/** The start time for a Challenge achievement window */
	var const qword ChallengeWindowBegin;
	/** The end time for a Challenge achievement window */
	var const qword ChallengeWindowEnd;
	/** The in-game Deep Link that specifies the starting point for this achievement */
	var const string DeepLink;
	/** The estimated time the achievement will take to earn */
	var const qword EstimatedUnlockTime;
	/** Whether this achievement has been revoked or not */
	var const bool bIsRevoked;
	/** The participation type of this Achievement */
	var const EAchievementParticipationType ParticipationType;
	/* The platform this achievement was earned on */
	var const array<string> PlatformsAvailableOn;
	/** The progress state of this achievement */
	var const EAchievementProgressState ProgressState;
	/** The rewards associated with this achievement */
	var const array<AchievementReward> Rewards;
	/** The media assets associated with this achievement */
	var const array<AchievementMediaAsset> MediaAssets;
	/** The product ID in which this achievement can be unlocked */
	var const string ProductID;
	/** ID of the service configuration set associated with the achievement */
	var const string ServiceConfigurationID;
	/** The titles associated with the achievement */
	var const array<AchievementTitleAssociation> TitleAssociations;

};

// pseudo-enum for ProductItemType (has to be done this way because it is a bitmask)
const PIT_Game			= 0x0001;
const PIT_App			= 0x0002;
const PIT_Consumable	= 0x0004;
const PIT_Durable		= 0x0008;
const PIT_GameDemo		= 0x0010;
const PIT_All			= 0x001F; // PIT_Game | PIT_App | PIT_Consumable | PIT_Durable | PIT_GameDemo;

/** The order products should be sorted when reading them from the online service */
enum ECatalogSortOrder
{
	CSO_FreeAndPaidCountDaily,
	CSO_PaidCountAllTime,
	CSO_PaidCountDail,
	CSO_DigitalReleaseDate,
	CSO_ReleaseDate,
	CSO_UserRatings
};

/** Holds the details of a marketplace product's availabilty */
struct native MarketplaceProductAvailability
{
	/** The list of acceptable payment types for the catalog item */
	var const array<string>						AcceptablePaymentInstrumentTypes;
	/** Text that describes the catalog item's availability */
	var const string							Description;
    /** The title of the product */
    var const string                            Title;
    /** The number of units available for the catalog item */
    var const int                               ConsumableQuantity;
	/** Identifier for the content of the product */
	var const string							ContentId;
	/** Code for the currency used in the product price */
	var const string							CurrencyCode;
	/** String version of product list price */
	var const string							DisplayListPrice;
	/** String version of product price */
	var const string							DisplayPrice;
	/** Distribution type of the product */
	var const string							DistributionType;
	/** Is this product purchaseable? */
	var const bool								bIsPurchasable;
	/** The published price listed for the catalog item */
	var const float								ListPrice;
    /** An identifier of an offer for the catalog item */
    var const string                            OfferId;
	/** The price of the catalog item, which is the amount the customer actually pays after any specials or discounts are applied */
	var const float								Price;
	/** Text to display to the user to interest them in the product */
	var const string							PromotionalText;
	/** Signed offer for the product */
	var const string							SignedOffer;

};

/** Holds details about an image related to a marketplace product */
struct native MarketplaceProductImage
{
	/** Identifier for the image */
	var const string							Id;
	/** Height of the image */
	var const int								Height;
	/** Width of the image */
	var const int								Width;
	/** String describing the purpose of the image */
	var const string							Purpose;
	/** A list of purposes for the image */
	var const array<string>						Purposes;
	/** URL where alternate sizes of the image are stored */
	var const string							ResizeURL;
};

/** The type of media for a marketplace product */
enum EMediaItemType
{
	MIT_Unknown,
	MIT_Game,
	MIT_Application,
	MIT_GameContent,
	MIT_GameConsumable,
	MIT_Subscription,
	MIT_All
};

/** Holds the information about a marketplace product */
struct native MarketplaceProductDetails
{
	/** The identifier for the product */
	var const string									StandardId;
	/** The type of media of the product */
	var const EMediaItemType							MediaItemType;
	/** The name of the product */
	var const string									ProductName;
	/** The product identifier for the product */
	var const string									ProductId;
	/** The release date of the product */
	var const qword										ReleaseDate;
	/** The sandboxid of the product */
	var const string									SandboxId;
	/** The id of the title this product belongs to */
	var const int										TitleId;
    /** Indicates if this product is a Bundle that includes entitlements to other products */
    var const bool                                      bIsBundle;
    /** Indicates if this Product is a member of a Bundle in the Marketplace */
    var const bool                                      bIsPartOfAnyBundle;
    /** The short version of the name of the catalog item */
    var const string                                    ReducedName;
	/** The images associated with the product */
	var const array<MarketplaceProductImage>			Images;
	/** The state of reading additional details for this product */
	var EOnlineEnumerationReadState						DetailsReadState;
	/** The availability details for the product (NOTE: only filled in after a request for additional details) */
	var const array<MarketplaceProductAvailability>		Availabilities;
	/** The description for the product (NOTE: only filled in after a request for additional details) */
	var const string									ProductDescription;

	structcpptext
	{
		FMarketplaceProductDetails() : DetailsReadState(OERS_NotStarted) {}
	}
};

/** The state of an inventory item */
enum EInventoryItemState
{
	IIS_Unknown,
	IIS_All,
	IIS_Enabled,
	IIS_Suspended,
	IIS_Expired,
	IIS_Canceled
};

/** Holds the information about a marketplace inventory item */
struct native MarketplaceInventoryItem
{
	/** Product identifier of the item */
	var const string				ProductId;
	/** Media type of the item (eg game, consumable, etc) */
	var const EMediaItemType		MediaItemType;
	/** State of the item */
	var const EInventoryItemState	ItemState;
	/** Quantity of the consumable item available */
	var const int					ConsumableBalance;
	/** The title identifier for which the item is valid */
	var const int					TitleId;
	/** A list of content container identifiers that contain this item (eg if this item is available as part of multiple content packs */
	var const array<string>			ContainerIds;
	/** The date the item became available */
	var const qword					StartDate;
	/** The date the item will no longer be available */
	var const qword					EndDate;
	/** The date the user received the rights to access this content */
	var const qword					RightsObtainedDate;
	/** The URL of the item */
	var const string				Url;
	/** The URL of the consumable item */
	var const string				ConsumableUrl;
//@HSL_END_XBOX
};

/** The state of an async enumeration (friends, content, etc) read request */
enum EOnlineNewsType
{
	ONT_Unknown,
	ONT_GameNews,
	ONT_ContentAnnouncements,
	ONT_Misc
};

enum ESessionMemberStatus
{
	DSMS_Reserved,
	DSMS_Inactive,
	DSMS_Ready,
	DSMS_Active
};

struct native SessionMemberInfo
{
	var UniqueNetId PlayerNetId;
	var ESessionMemberStatus MemberStatus;
	var init string SecureAddress;
    /** The gamertag of the player */
    var init string Nickname;
    var bool Muted;
};

struct native PermissionsResult
{
	var SessionMemberInfo User;
	var bool bHasPermission;
};

var array<SessionMemberInfo> PartyMemberList;
var array<SessionMemberInfo> GameMemberList;
//@HSL_END_XBOX

/** Whether to use the override or not */
var config bool bUseBuildIdOverride;

/** Used to specify a build override value */
var config int BuildIdOverride;

/** The class to create our patcher instance from */
var config string IniLocPatcherClassName;

/** The object responsible for patching downloaded INI/loc files */
var transient IniLocPatcher Patcher;

/** Used to introduce latency when communicating with the online layer for testing purposes */
var config float AsyncMinCompletionTime;

/** Holds information about a player in a friends list */
struct native OnlinePartyMember
{
	/** Unique identifier of the friend */
	var const UniqueNetId UniqueId;
	/** The player's nickname */
    var const string Nickname;
	/** The local controller id if local */
	var const byte LocalUserNum;
	/** The NAT type for this player */
    var const ENATType NatType;
	/** The title id of the title the player is in */
	var const int TitleId;
	/** Whether the player is local to this machine or remote */
	var const bool bIsLocal;
	/** Whether the player is in party voice or game voice */
	var const bool bIsInPartyVoice;
	/** Whether the player is talking or not */
	var const bool bIsTalking;
	/** Whether the player is in a game session */
	var const bool bIsInGameSession;
	/** Whether the party member is playing the same game or not */
	var const bool bIsPlayingThisGame;
	/** The session id that the player is in */
	var const qword SessionId;
	/** The first 4 bytes of custom application data */
	var const int Data1;
	/** The second 4 bytes of custom application data */
	var const int Data2;
	/** The third 4 bytes of custom application data */
	var const int Data3;
	/** The fourth 4 bytes of custom application data */
	var const int Data4;
};

/** Flags indicating the privileges allowed for posting to social networking sites */
struct native SocialPostPrivileges
{
	/** The title can post images on social networks */
	var const bool bCanPostImage;
	/** The title can post links on social networks */
	var const bool bCanPostLink;
};

/** Flags describing the posted content */
struct native SocialPostImageFlags
{
	/** Image is user generated content */
	var bool bIsUserGeneratedImage;
	/** Post is the result of miscellaneous game activity */
	var bool bIsGameGeneratedImage;
	/** Post is the result of an earned achievement */
	var bool bIsAchievementImage;
	/** Post is for media */
	var bool bIsMediaImage;
};

/** Info needed to post an image */
struct native SocialPostImageInfo
{
	var SocialPostImageFlags Flags;
	/** On Facebook, this is the text that the user provides to describe the image, which appears directly below the user's name */
	var string MessageText;
	/** On Facebook, clicking this text displays the image at full size */
    var string TitleText;
	/** The caption of the preview image that accompanies this post */
    var string PictureCaption;
	/** On Facebook, this text is displayed below the caption */
    var string PictureDescription;
};

/** Info needed to post an image link */
struct native SocialPostLinkInfo extends SocialPostImageInfo
{
	/** Clicking on the message title text on the social networking site navigates to this URL */
	var string TitleURL;
	/** Clicking on the preview image on the social networking site navigates to this URL */
    var string PictureURL;
};

//@HSL_BEGIN_XBOX
struct native SessionUpdateInfo
{
    var const array<SessionMemberInfo> MembersJoined;
    var const array<SessionMemberInfo> MembersLeft;
	var const bool bHostDeviceTokenChanged;
	var const bool bInitializationStateChanged;
	var const bool bMatchmakingStatusChanged;
	var const bool bMemberJoinedOrLeft;
	var const bool bMemberStatusChanged;
	var const bool bSessionJoinabilityChanged;
	var const bool bCustomPropertyChange;
	var const bool bMemberCustomPropertyChange;
};

var const config string DefaultSessionTemplateName;
var const config string PartySessionTemplateName;
//@HSL_END_XBOX

`if (`__TW_ONLINESUBSYSTEM_)

/* Used to contain a local list of inventory items fetched from Steam */
struct native CurrentInventoryEntry
{
	var const UniqueNetId Instance;
	/** The original playfab item ID linked to this item */
	var const string PlayfabItemId;
	var const int Definition;
	var const int Quantity;
	var int NewlyAdded;
	var int LastUsedTime;
	var bool InFlight;
	var bool Stale;
};
var const array<CurrentInventoryEntry> CurrentInventory;

/** The list of owned entitlement IDs */
var const array<string> OwnedEntitlementIds;

enum ItemType
{
	ITP_WeaponSkin,
	ITP_CharacterSkin,
	ITP_KeyCrate,
	ITP_Item,
	ITP_CraftingComponent,
	ITP_Emote,
	ITP_SFX,
	ITP_NONE,
};

enum ItemRarity
{
	ITR_Common,
	ITR_Uncommon,
	ITR_Rare,
	ITR_Mythical,
	ITR_Legendary,
	ITR_ExceedinglyRare,
	ITR_NONE,
};

/* fetching the individual properties of an item */
struct native ItemProperties
{
	var int Definition;
	/** The playfab item name. It can differ from Definition if its mapped to an entitlement */
	var string PlayfabItemId;
	/** The product ID as exists in PSN */
	var string ProductID;
	/** signed offer ID for PSN item */
	var string SignedOfferId;
	/** Key ID used to open this item (used for playfab locked containers) */
	var string RequiredKeyId;
	var string Name;
	var ItemType Type;
	var ItemRarity Rarity;
	var string ShortDescription;
	var string Price;
	var int Quality;
	var string IconURL;
	var string IconURLLarge;
	var bool Tradeable;
	var bool Commodity;
	var bool Marketable;
	var string Description;
	var string Exchange;
	var string Bundle;
	var bool UniqueToOwn;
	var int  PerkId; //index bassed off our array
	var int  AltPerkId; //index bassed off our array
	var int  WeaponType;
	var int  FilterIdIndex;
	var bool ItemOnSale;
	var string BasePrice;
	var string DiscountRate;

	structcpptext
	{
	public:
		FItemProperties() {}
		FItemProperties(EEventParm)
		{
			appMemzero(this, sizeof(FItemProperties));
		}

		// Retrieves a list of bundled items based on the Bundle property. This is recursive and returns only items NOT other bundles
		void GetBundledItems( TArray<FItemProperties>& OutList ) const;
		// Localizes properties that require localizing
		void LocalizeProperties();
	private:
		UBOOL LocalizeString( FString& InString );
		const TCHAR* GetLocSectionName();
	}
};
var array<ItemProperties> ItemPropertiesList;

var bool bSalesEvent;
var bool bSalesEventChecked;

struct native ExchangeRule
{
	var int Definition;
	var int Quantity;
};

struct native ExchangeRuleSets
{
	var array<ExchangeRule> Sources;
	var int Target;
	var ItemType Type;
};
var array<ExchangeRuleSets> ExchangeRuleSetList;

native function OpenMarketPlaceSearch(ItemProperties Item);
native function OpenMarketPlaceSearchBySignedOfferId(string SignedOfferId);
native function OpenItemPurchaseOverlay(int SKU);
native function OpenURL(string WebsiteLink);
native function OpenGameStorePage();

//@TW Adam Massingale | Free trial support requires us to check if user owns game
native function bool IsGameOwned();
//@TW Adam Massingale | Free trial period check (checks backend service title data(Playfab))
native function bool IsFreeTrialPeriodActive();
//@TW Adam Massingale | Free trial check - see if we can obtain data to check state of free trial
native function bool CanCheckFreeTrialState();


// return a list of rulesets this item is a source for (Crates,
// Crafting, ... )
native function int IsExchangeable( int SourceSKU, out array<ExchangeRuleSets> Ret );

native function ClearNewlyAdded();
native function ClearInFlight();

// Are the requirements met to recieve the target SKU with the given
// Rule (from IsExchangeable() above)
native function bool ExchangeReady( const out ExchangeRuleSets Rule );

// Some playfab items require keys that are separate from the exchange system
native function bool HasKeyForItem( const int ItemDefinition, out int OutRequiredItem );

// do the exchange with the given rule. Inventory will be scanned and
// appropriate items removed to make the exchange
native function bool Exchange( const out ExchangeRuleSets Rule, bool AllButOne );

delegate OnInventoryReadComplete();
delegate OnPingRegionsComplete(int RegionIndex);

function AddOnInventoryReadCompleteDelegate(delegate<OnInventoryReadComplete> ReadCompleteDelegate)
{
	if (ReadInventoryCompleteDelegates.Find(ReadCompleteDelegate) == INDEX_NONE)
	{
		ReadInventoryCompleteDelegates.AddItem(ReadCompleteDelegate);
	}
}

function ClearOnInventoryReadCompleteDelegate(delegate<OnInventoryReadComplete> ReadCompleteDelegate)
{
	local int RemoveIndex;

	// Remove this delegate from the array if found
	RemoveIndex = ReadInventoryCompleteDelegates.Find(ReadCompleteDelegate);
	if (RemoveIndex != INDEX_NONE)
	{
		ReadInventoryCompleteDelegates.Remove(RemoveIndex,1);
	}
}

function ClearAllInventoryReadCompleteDelegates()
{
	ReadInventoryCompleteDelegates.Remove(0,ReadInventoryCompleteDelegates.Length);
}

delegate OnReadOnlineAvatarComplete(const UniqueNetId PlayerNetId, Texture2D Avatar);
delegate OnReadOnlineAvatarByNameComplete(const string PlayerName, const string AvatarURL);

function ReadOnlineAvatar(const UniqueNetId PlayerNetId, int Size);
function ReadOnlineAvatarByName(const string InPlayerName, int Size);

function AddOnReadOnlineAvatarCompleteDelegate(delegate<OnReadOnlineAvatarComplete> ReadCompleteDelegate)
{
	if (ReadAvatarCompleteDelegates.Find(ReadCompleteDelegate) == INDEX_NONE)
	{
		ReadAvatarCompleteDelegates.AddItem(ReadCompleteDelegate);
	}
}

function ClearOnReadOnlineAvatarCompleteDelegate(delegate<OnReadOnlineAvatarComplete> ReadCompleteDelegate)
{
	local int RemoveIndex;

	// Remove this delegate from the array if found
	RemoveIndex = ReadAvatarCompleteDelegates.Find(ReadCompleteDelegate);
	if (RemoveIndex != INDEX_NONE)
	{
		ReadAvatarCompleteDelegates.Remove(RemoveIndex, 1);
	}
}

function ClearAllReadOnlineAvatarCompleteDelegates()
{
	ReadAvatarCompleteDelegates.Remove(0, ReadAvatarCompleteDelegates.Length);
}

function AddOnReadOnlineAvatarByNameCompleteDelegate(delegate<OnReadOnlineAvatarByNameComplete> ReadCompleteDelegate)
{
	if (ReadAvatarByNameCompleteDelegates.Find(ReadCompleteDelegate) == INDEX_NONE)
	{
		ReadAvatarByNameCompleteDelegates.AddItem(ReadCompleteDelegate);
	}
}

function ClearOnReadOnlineAvatarByNameCompleteDelegate(delegate<OnReadOnlineAvatarByNameComplete> ReadCompleteDelegate)
{
	local int RemoveIndex;

	// Remove this delegate from the array if found
	RemoveIndex = ReadAvatarByNameCompleteDelegates.Find(ReadCompleteDelegate);
	if (RemoveIndex != INDEX_NONE)
	{
		ReadAvatarByNameCompleteDelegates.Remove(RemoveIndex, 1);
	}
}

function ClearAllReadOnlineAvatarByNameCompleteDelegates()
{
	ReadAvatarByNameCompleteDelegates.Remove(0, ReadAvatarByNameCompleteDelegates.Length);
}

`endif

cpptext
{
// FTickableObject interface

	/**
	 * Returns whether it is okay to tick this object. E.g. objects being loaded in the background shouldn't be ticked
	 * till they are finalized and unreachable objects cannot be ticked either.
	 *
	 * @return	TRUE if tickable, FALSE otherwise
	 */
	virtual UBOOL IsTickable() const
	{
		// We cannot tick objects that are unreachable or are in the process of being loaded in the background.
		return !HasAnyFlags( RF_Unreachable | RF_AsyncLoading );
	}

	/**
	 * Used to determine if an object should be ticked when the game is paused.
	 *
	 * @return always TRUE as networking needs to be ticked even when paused
	 */
	virtual UBOOL IsTickableWhenPaused() const
	{
		return TRUE;
	}

	/**
	 * Here to complete the interface but needs to be overriden
	 *
	 * @param ignored
	 */
	virtual void Tick(FLOAT)
	{
		check(0 && "Must be overridden");
	}

	/**
	 * Generates a string representation of a UniqueNetId struct.
	 *
	 * @param	IdToConvert		the unique net id that should be converted to a string.
	 *
	 * @return	the specified UniqueNetId represented as a string.
	 */
//@HSL_BEGIN_XBOX
	static FString UniqueNetIdToString( const FUniqueNetId& IdToConvert, UBOOL Hex = TRUE );
//@HSL_END_XBOX

	/**
	 * Converts a string representing a UniqueNetId into a UniqueNetId struct.
	 *
	 * @param	UniqueNetIdString	the string containing the text representation of the unique id.
	 * @param	out_UniqueId		will receive the UniqueNetId generated from the string.
	 *
	 * @return	TRUE if the string was successfully converted into a UniqueNetId; FALSE if the string was not a valid UniqueNetId.
	 */
	static UBOOL StringToUniqueNetId( const FString& UniqueNetIdString, FUniqueNetId& out_UniqueId);

#if __TW_
	/**
	 * Same as StringToUniqueNetId but assumes the string is decimal
	 */
	static UBOOL StringToUniqueNetIdDec( const FString& UniqueNetIdString, FUniqueNetId& out_UniqueId);
#endif

	/**
	 * Searches the named session array for the specified session
	 *
	 * @param SessionName the name to search for
	 *
	 * @return pointer to the struct if found, NULL otherwise
	 */
//@HSL_BEGIN_XBOX
	virtual FNamedSession* GetNamedSession(FName SessionName)
//@HSL_END_XBOX
	{
		for (INT SearchIndex = 0; SearchIndex < Sessions.Num(); SearchIndex++)
		{
			if (Sessions(SearchIndex).SessionName == SessionName)
			{
				return &Sessions(SearchIndex);
			}
		}
		return NULL;
	}

	/**
	 * Searches the named session array for the specified session
	 *
	 * @param SessionName the name to search for
	 *
	 * @return TRUE if found, FALSE otherwise
	 */
	inline UBOOL HasNamedSession(FName SessionName)
	{
		return GetNamedSession(SessionName) != NULL;
	}

	/**
	 * Adds a new named session to the list
	 *
	 * @param SessionName the name to search for
	 * @param GameSettings the game settings to add
	 *
	 * @return a pointer to the struct that was added
	 */
	inline FNamedSession* AddNamedSession(FName SessionName,UOnlineGameSettings* GameSettings)
	{
		INT AddIndex = Sessions.AddZeroed();
		Sessions(AddIndex).SessionName = SessionName;
		Sessions(AddIndex).GameSettings = GameSettings;
		return &Sessions(AddIndex);
	}

	/**
	 * Searches the named session array for the specified session and removes it
	 *
	 * @param SessionName the name to search for
	 */
	virtual void RemoveNamedSession(FName SessionName)
	{
		for (INT SearchIndex = 0; SearchIndex < Sessions.Num(); SearchIndex++)
		{
			if (Sessions(SearchIndex).SessionName == SessionName)
			{
				Sessions.Remove(SearchIndex);
				return;
			}
		}
	}

	/**
	 * @return platform specific id for a session
	 */
	virtual QWORD GetSessionId(FName SessionName)
	{
		return 0;
	}

	/**
	 * @return platform specific id for a session from a search result
	 */
	virtual QWORD GetSearchResultSessionId(const struct FOnlineGameSearchResult* SearchResult)
	{
		return 0;
	}

	/**
	 * Notification sent to OnlineSubsystem that pre-travel cleanup is occuring
	 *
	 * @param bSessionEnded		whether or not the game session has ended
	 */
	virtual void NotifyCleanupWorld(UBOOL bSessionEnded)
	{
	}

//@HSL_BEGIN_XBOX
	//@igs(jc): Adding base64 functionality to common OSS
	static TArray<BYTE> DecodeBase64(const TArray<BYTE>& Encoded);
	static TArray<BYTE> EncodeBase64(const TArray<BYTE>& Decoded);
//@HSL_END_XBOX
}

/**
 * Called from engine start up code to allow the subsystem to initialize
 *
 * @return TRUE if the initialization was successful, FALSE otherwise
 */
native event bool Init();

/**
 * Used to trigger any automated tasks that need to happen just after startup
 */
event bool PostInit()
{
	local class<IniLocPatcher> IniLocPatcherClass;

	// Now that the subsystem is setup, try to download any config/loc updates
	if (IniLocPatcherClassName != "")
	{
		`Log("Loading "$IniLocPatcherClassName$" for INI/Loc patching",,'DevMCP');
		IniLocPatcherClass = class<IniLocPatcher>(DynamicLoadObject(IniLocPatcherClassName,class'Class'));
		Patcher = new IniLocPatcherClass;
		if (Patcher != None)
		{
			Patcher.Init();
		}
		else
		{
			return false;
		}
	}
	return true;
}

/**
 * Called from the engine shutdown code to allow the subsystem to release any
 * resources that may have been allocated
 */
//@HSL_BEGIN_XBOX
native event Exit();
//@HSL_END_XBOX

/**
 * Called from native code to assign the account interface
 *
 * @param NewInterface the object to assign as providing the account interface
 *
 * @return TRUE if the interface is valid, FALSE otherwise
 */
event bool SetAccountInterface(Object NewInterface)
{
	AccountInterface = OnlineAccountInterface(NewInterface);
	// This will return false, if the interface wasn't supported
	return AccountInterface != None;
}

/**
 * Called from native code to assign the player interface
 *
 * @param NewInterface the object to assign as providing the player interface
 *
 * @return TRUE if the interface is valid, FALSE otherwise
 */
event bool SetPlayerInterface(Object NewInterface)
{
	PlayerInterface = OnlinePlayerInterface(NewInterface);
	// This will return false, if the interface wasn't supported
	return PlayerInterface != None;
}

/**
 * Called from native code to assign the extended player interface
 *
 * @param NewInterface the object to assign as providing the player interface
 *
 * @return TRUE if the interface is valid, FALSE otherwise
 */
event bool SetPlayerInterfaceEx(Object NewInterface)
{
	PlayerInterfaceEx = OnlinePlayerInterfaceEx(NewInterface);
	// This will return false, if the interface wasn't supported
	return PlayerInterfaceEx != None;
}

//@HSL_BEGIN_XBOX
/**
 * Called from native code to assign the marketplace interface
 *
 * @param NewInterface the object to assign as providing the marketplace interface
 *
 * @return TRUE if the interface is valid, FALSE otherwise
 */
event bool SetMarketplaceInterface(Object NewInterface)
{
	MarketplaceInterface = OnlineMarketplaceInterface(NewInterface);
	// This will return false, if the interface wasn't supported
	return MarketplaceInterface != None;
}
//@HSL_END_XBOX

/**
 * Called from native code to assign the system interface
 *
 * @param NewInterface the object to assign as providing the system interface
 *
 * @return TRUE if the interface is valid, FALSE otherwise
 */
event bool SetSystemInterface(Object NewInterface)
{
	SystemInterface = OnlineSystemInterface(NewInterface);
	// This will return false, if the interface wasn't supported
	return SystemInterface != None;
}

/**
 * Called from native code to assign the game interface
 *
 * @param NewInterface the object to assign as providing the game interface
 *
 * @return TRUE if the interface is valid, FALSE otherwise
 */
event bool SetGameInterface(Object NewInterface)
{
	GameInterface = OnlineGameInterface(NewInterface);
	// This will return false, if the interface wasn't supported
	return GameInterface != None;
}

/**
 * Called from native code to assign the content interface
 *
 * @param NewInterface the object to assign as providing the content interface
 *
 * @return TRUE if the interface is valid, FALSE otherwise
 */
event bool SetContentInterface(Object NewInterface)
{
	ContentInterface = OnlineContentInterface(NewInterface);
	// This will return false, if the interface wasn't supported
	return ContentInterface != None;
}

/**
 * Called from native code to assign the voice interface
 *
 * @param NewInterface the object to assign as providing the voice interface
 *
 * @return TRUE if the interface is valid, FALSE otherwise
 */
event bool SetVoiceInterface(Object NewInterface)
{
	VoiceInterface = OnlineVoiceInterface(NewInterface);
	// This will return false, if the interface wasn't supported
	return VoiceInterface != None;
}

/**
 * Called from native code to assign the stats interface
 *
 * @param NewInterface the object to assign as providing the stats interface
 *
 * @return TRUE if the interface is valid, FALSE otherwise
 */
event bool SetStatsInterface(Object NewInterface)
{
	StatsInterface = OnlineStatsInterface(NewInterface);
	// This will return false, if the interface wasn't supported
	return StatsInterface != None;
}

/**
 * Called from native code to assign the news interface
 *
 * @param NewInterface the object to assign as providing the news interface
 *
 * @return TRUE if the interface is valid, FALSE otherwise
 */
event bool SetNewsInterface(Object NewInterface)
{
	NewsInterface = OnlineNewsInterface(NewInterface);
	// This will return false, if the interface wasn't supported
	return NewsInterface != None;
}

/**
 * Called from native code to assign the party chat interface
 *
 * @param NewInterface the object to assign as providing the party chat interface
 *
 * @return TRUE if the interface is valid, FALSE otherwise
 */
event bool SetPartyChatInterface(Object NewInterface)
{
	PartyChatInterface = OnlinePartyChatInterface(NewInterface);
	// This will return false, if the interface wasn't supported
	return PartyChatInterface != None;
}

//@HSL_BEGIN - JRO - 7/16/2016 - Support for PS4 party interface
event bool SetPartyInterface(Object NewInterface)
{
	PartyInterface = OnlinePartyInterface(NewInterface);
	return PartyInterface != none;
}
//@HSL_END

/**
 * Called from native code to assign the title file interface
 *
 * @param NewInterface the object to assign as providing the file downloading interface
 *
 * @return TRUE if the interface is valid, FALSE otherwise
 */
event bool SetTitleFileInterface(Object NewInterface)
{
	TitleFileInterface = OnlineTitleFileInterface(NewInterface);
	// This will return false, if the interface wasn't supported
	return TitleFileInterface != None;
}

/**
 * Called from native code to assign the title file caching interface
 *
 * @param NewInterface the object to assign as providing the file caching interface
 *
 * @return TRUE if the interface is valid, FALSE otherwise
 */
event bool SetTitleFileCacheInterface(Object NewInterface)
{
	TitleFileCacheInterface = OnlineTitleFileCacheInterface(NewInterface);
	// This will return false, if the interface wasn't supported
	return TitleFileCacheInterface != None;
}

/**
 * Called from native code to assign the social interface
 *
 * @param SocialInterface the object to assign as providing the interface for posting to social networks
 *
 * @return TRUE if the interface is valid, FALSE otherwise
 */
event bool SetSocialInterface(Object InSocialInterface)
{
	SocialInterface = OnlineSocialInterface(InSocialInterface);
	// This will return false, if the interface wasn't supported
	return SocialInterface != None;
}

/**
 * Called from native code to assign the auth interface
 *
 * @param AuthInterface the object to assign as providing the interface for multiplayer authentication
 *
 * @return TRUE if the interface is valid, FALSE otherwise
 */
event bool SetAuthInterface(Object InAuthInterface)
{
	AuthInterface = OnlineAuthInterface(InAuthInterface);
	// This will return false, if the interface wasn't supported
	return AuthInterface != None;
}

/**
 * Called from native code to assign the user cloud interface
 *
 * @param InCloudInterface the object to assign as providing the interface for user cloud access
 *
 * @return TRUE if the interface is valid, FALSE otherwise
 */
event bool SetUserCloudInterface(Object InCloudInterface)
{
	UserCloudInterface = UserCloudFileInterface(InCloudInterface);
	// This will return false, if the interface wasn't supported
	return UserCloudInterface != None;
}

/**
 * Called from native code to assign the shared cloud interface
 *
 * @param InCloudInterface the object to assign as providing the interface for shared cloud access
 *
 * @return TRUE if the interface is valid, FALSE otherwise
 */
event bool SetSharedCloudInterface(Object InCloudInterface)
{
	SharedCloudInterface = SharedCloudFileInterface(InCloudInterface);
	// This will return false, if the interface wasn't supported
	return SharedCloudInterface != None;
}

//@HSL_BEGIN_XBOX
/**
 * Called from native code to assign the game DVR interface
 *
 * @param GameDVRInterface the object to assign as providing the interface for game DVR
 *
 * @return TRUE if the interface is valid, FALSE otherwise
 */
event bool SetGameDVRInterface(Object InGameDVRInterface)
{
	GameDVRInterface = OnlineGameDVRInterface(InGameDVRInterface);
	// This will return false, if the interface wasn't supported
	return GameDVRInterface != None;
}

/**
 * Called from native code to assign the Community Content interface
 *
 * @param InCommunityContentInterface the object to assign as providing the interface for Community Content
 *
 * @return TRUE if the interface is valid, FALSE otherwise
 */
event bool SetCommunityContentInterface(Object InCommunityContentInterface)
{
	CommunityContentInterface = OnlineCommunityContentInterface(InCommunityContentInterface);
	// This will return false, if the interface wasn't supported
	return CommunityContentInterface != None;
}
//@HSL_END_XBOX

/**
 * Adds the interface object to the named interface list with the specified name
 *
 * @param InterfaceName the name of the interface to add it as
 * @param NewInterface the object/interface that is being cached
 */
event SetNamedInterface(name InterfaceName,Object NewInterface)
{
	local int InterfaceIndex;

	// Determine whether to add or replace
	InterfaceIndex = NamedInterfaces.Find('InterfaceName',InterfaceName);
	if (InterfaceIndex == INDEX_NONE)
	{
		// We are adding to the list
		InterfaceIndex = NamedInterfaces.Length;
		NamedInterfaces.Length = NamedInterfaces.Length + 1;
		NamedInterfaces[InterfaceIndex].InterfaceName = InterfaceName;
	}
	// Replace whatever pointer was previously there
	NamedInterfaces[InterfaceIndex].InterfaceObject = NewInterface;
}

/**
 * Returns the interface object associated with the specified name
 *
 * @param InterfaceName the name of the interface to retrieve
 *
 * @return The object that matches the interface name if found
 */
event Object GetNamedInterface(name InterfaceName)
{
	local int InterfaceIndex;

	// Find the index in the array for this interface
	InterfaceIndex = NamedInterfaces.Find('InterfaceName',InterfaceName);
	if (InterfaceIndex != INDEX_NONE)
	{
		return NamedInterfaces[InterfaceIndex].InterfaceObject;
	}
	return None;
}

//@HSL_BEGIN_XBOX
/**
 * Signals the online service that the given event occurred
 *
 * @param EventName the name of the event to signal
 * @param EventParams the parameters to pass with the event
 */
native event bool RaiseEvent(const string EventName, const array<string> EventParams);
//@HSL_END_XBOX

/**
 * Generates a string representation of a UniqueNetId struct.
 *
 * @param	IdToConvert		the unique net id that should be converted to a string.
 *
 * @return	the specified UniqueNetId represented as a string.
 */
//@HSL_BEGIN_XBOX
static final native noexportheader function string UniqueNetIdToString(const out UniqueNetId IdToConvert, optional bool Hex=true);
//@HSL_END_XBOX

/**
 * Converts a string representing a UniqueNetId into a UniqueNetId struct.
 *
 * @param	UniqueNetIdString	the string containing the text representation of the unique id.
 * @param	out_UniqueId		will receive the UniqueNetId generated from the string.
 *
 * @return	TRUE if the string was successfully converted into a UniqueNetId; FALSE if the string was not a valid UniqueNetId.
 */
static final native noexportheader function bool StringToUniqueNetId(string UniqueNetIdString,out UniqueNetId out_UniqueId);

`if(`__TW_)
/**
 * Same as StringToUniqueNetId but assumes the string is decimal
 */
static final native noexportheader function bool StringToUniqueNetIdDec(string UniqueNetIdString,out UniqueNetId out_UniqueId);
`endif //__TW_

/**
 * Returns the unique id of the player for the specified index
 *
 * @param UserIndex the user to return the id of
 *
 * @return the unique id of the player at the specified index
 */
event UniqueNetId GetPlayerUniqueNetIdFromIndex(int UserIndex)
{
	local UniqueNetId ReturnVal, NullId;

	if (PlayerInterface == none || !PlayerInterface.GetUniquePlayerId(UserIndex, ReturnVal))
	{
		ReturnVal = NullId;
	}

	return ReturnVal;
}

/**
 * Generates a unique number based off of the current script compilation
 *
 * @return the unique number from the current script compilation
 */
native function int GetBuildUniqueId();

/**
 * Returns the number of players that can be signed in on this platform
 */
static final native function int GetNumSupportedLogins();

//@HSL_BEGIN - JRO - 3/21/2016 - PS4 Sessions
function bool IsInSession( name SessionName )
{
	local int i;

	for( i = 0; i < Sessions.Length; i++ )
	{
		if( Sessions[i].SessionName == SessionName )
		{
			return true;
		}
	}

	return false;
}
//@HSL_END_XBOX

/**
 * Logs the game settings object
 *
 * @param GameSettings settings to dump
 */
static function DumpGameSettings(const OnlineGameSettings GameSettings)
{
	`Log("    OnlineGameSettings: "$GameSettings);
	`Log("      OwningPlayerName: "$GameSettings.OwningPlayerName);
	`Log("      OwningPlayerId: "$UniqueNetIdToString(GameSettings.OwningPlayerId));
	`Log("      PingInMs: "$GameSettings.PingInMs);
	`Log("      NumPublicConnections: "$GameSettings.NumPublicConnections);
	`Log("      NumOpenPublicConnections: "$GameSettings.NumOpenPublicConnections);
	`Log("      NumPrivateConnections: "$GameSettings.NumPrivateConnections);
	`Log("      NumOpenPrivateConnections: "$GameSettings.NumOpenPrivateConnections);
	`Log("      bIsLanMatch: "$GameSettings.bIsLanMatch);
	`Log("      bIsDedicated: "$GameSettings.bIsDedicated);
	`Log("      bUsesStats: "$GameSettings.bUsesStats);
	`Log("      bServerExiled: "$GameSettings.bServerExiled);
	`Log("      bUsesArbitration: "$GameSettings.bUsesArbitration);
	`Log("      bAntiCheatProtected: "$GameSettings.bAntiCheatProtected);
	`Log("      bShouldAdvertise: "$GameSettings.bShouldAdvertise);
	`Log("      bAllowJoinInProgress: "$GameSettings.bAllowJoinInProgress);
	`Log("      bAllowInvites: "$GameSettings.bAllowInvites);
	`Log("      bUsesPresence: "$GameSettings.bUsesPresence);
	`Log("      bWasFromInvite: "$GameSettings.bWasFromInvite);
	`Log("      bAllowJoinViaPresence: "$GameSettings.bAllowJoinViaPresence);
	`Log("      bAllowJoinViaPresenceFriendsOnly: "$GameSettings.bAllowJoinViaPresenceFriendsOnly);
	`Log("      GameState: "$GameSettings.GameState);
}

/**
 * Logs the session state for all sessions present
 */
function DumpSessionState()
{
	local int Index;
	local int PlayerIndex;
	local UniqueNetId NetId;
	local UniqueNetId ZeroId;

	// To make the dumb warning go away even though it is used
	NetId = ZeroId;
	ZeroId = NetId;

	`Log("Unreal online session state");
	`Log("-------------------------------------------------------------");
	`Log("");
	`Log("Number of sessions: "$Sessions.Length);

	// Iterate through the sessions listing the session plus the registrants
	for (Index = 0; Index < Sessions.Length; Index++)
	{
		`Log("  Session: "$Sessions[Index].SessionName);
		DumpGameSettings(Sessions[Index].GameSettings);
		`Log("");

		`Log("    Number of players: "$Sessions[Index].Registrants.Length);
		// List each player in the session
		for (PlayerIndex = 0; PlayerIndex < Sessions[Index].Registrants.Length; PlayerIndex++)
		{
			NetId = Sessions[Index].Registrants[PlayerIndex].PlayerNetId;
			`Log("      Player: "$UniqueNetIdToString(NetId));
		}
		`Log("    Number of arbitrated players: "$Sessions[Index].ArbitrationRegistrants.Length);
		// List each arbitrated player in the session
		for (PlayerIndex = 0; PlayerIndex < Sessions[Index].ArbitrationRegistrants.Length; PlayerIndex++)
		{
			NetId = Sessions[Index].ArbitrationRegistrants[PlayerIndex].PlayerNetId;
			`Log("      Player: "$UniqueNetIdToString(NetId));
		}
	}
}

`if(`notdefined(FINAL_RELEASE))
	/**
	 * Log list of players' netids for debugging
	 */
	static function DumpNetIds(const out array<UniqueNetId> Players, string DebugLabel)
	{
		local int PlayerIdx;
		local UniqueNetId NetId;
		for (PlayerIdx=0; PlayerIdx<Players.Length; PlayerIdx++)
		{
			NetId = Players[PlayerIdx];
			`Log(DebugLabel$": "
				$" PlayerIdx="$PlayerIdx
				$" UniqueId="$UniqueNetIdToString(NetId));
		}
	}
`endif

/**
 * Logs the list of players that are registered for voice
 */
function DumpVoiceRegistration();

/**
 * Sets the debug output level for the platform specific API (if applicable)
 *
 * @param DebugSpewLevel the level to set
 */
function SetDebugSpewLevel(int DebugSpewLevel);

`if (`__TW_ONLINESUBSYSTEM_)

function TWOnlineLobby GetLobbyInterface();

function bool RegisterLocalTalker(byte LocalUserNum, optional byte ChannelIndex);

function bool ResetStats(bool bResetAchievements);

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
 * Removes a friend from the player's friend list
 *
 * @param LocalUserNum the user that is removing the friend
 * @param FormerFriend the player to remove from the friend list
 *
 * @return true if successful, false otherwise
 */
function bool RemoveFriend(byte LocalUserNum,UniqueNetId FormerFriend);

function ShowVoIPConfigUI();

/**
 * Gets the platform specific unique id for the specified player
 *
 * @param LocalUserNum the controller number of the associated user
 * @param PlayerId the byte array that will receive the id
 *
 * @return TRUE if the call succeeded, FALSE otherwise
 */
function bool GetUniquePlayerId(byte LocalUserNum,out UniqueNetId PlayerId);

/**
 * Converts the specified string (representing a 64bit int), into a UID
 *
 * @param UIDString	The string representing a 64bit int
 * @param OutUID	The returned UID
 * @return		whether or not the conversion was successful
 */
function bool Int64ToUniqueNetId(string UIDString, out UniqueNetId OutUID);

/**
 * Converts the specified UID, into a string representing a 64bit int
 * NOTE: Primarily for use with 'open Steam.#', when P2P sockets are enabled
 *
 * @param UID		The players UID
 * @result		The string representation of the 64bit integer, made from the UID
 */
function string UniqueNetIdToInt64(const out UniqueNetId UID);

/**
 * Converts the specified UID, into the players Steam Community name
 *
 * @param UID		The players UID
 * @return		The username of the player, as stored on the Steam backend
 */
function string UniqueNetIdToPlayerName(const out UniqueNetId UID);

/**
 * Fetches the login status for a given player
 *
 * @param LocalUserNum the controller number of the associated user
 *
 * @return the enum value of their status
 */
function ELoginStatus GetLoginStatus(byte LocalUserNum);

/**
 * Determines the NAT type the player is using
 */
function ENATType GetNATType();

native function TWOnlineUGCInterface GetUGCInterface();

/**
 * Gets the friends' groups of which the player is a member
 *
 * @param UserGroups the list of groups
 *
 */
native function GetPlayerGroups(out array<UniqueNetId> UserGroups);

/**
 * Checks the player's membership in a friends' group
 *
 * @param UserGroups the group to check
 *
 * @return whether the player is a member of that group
 */
native function bool CheckPlayerGroup(UniqueNetId Group);

 /**
  * Set a password that will be shared with friends, so they can log into your server.
  * Set it to empty string to disable.
  */
function SetSharedPassword(string ServerPassword);

function StartRegionPingAndSelectDefaultRegion(delegate<OnPingRegionsComplete> Callback) {};
function CancelRegionPing() {};

//@HSL_BEGIN - BWJ - 10-4-16 - Detecting if local player has a chat restriction
native function bool HasChatRestriction( byte LocalUserNum );
//@HSL_END

//@HSL_BEGIN - BWJ - 12-12-16 - Support for activating user. Used for XB1
function ManuallyActivateUser( const UniqueNetId ForUniqueId );
// Activates a game pad to whichever user is active for it
function ActivateGamepad( const int GamepadIndex );
//@HSL_END


//@HSL_BEGIN - BWJ - 1-11-17 - Support for setting a cached profile
function SetCachedProfile( OnlineProfileSettings InSettings );
//@HSL_END

`endif //(`__TW_ONLINESUBSYSTEM_)